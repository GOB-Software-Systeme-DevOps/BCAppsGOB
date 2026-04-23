// ------------------------------------------------------------------------------------------------
// Copyright (c) GOB Software Systeme GmbH. All rights reserved.
// ------------------------------------------------------------------------------------------------
namespace MS.Subcontracting;

using Microsoft.Inventory.Location;
using Microsoft.Inventory.Requisition;
using Microsoft.Manufacturing.Capacity;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.ProductionBOM;
using Microsoft.Manufacturing.Routing;
using Microsoft.Manufacturing.Setup;
using Microsoft.Manufacturing.Subcontracting;
using Microsoft.Manufacturing.Wizard;
using Microsoft.Manufacturing.WorkCenter;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Vendor;
using System.Reflection;

codeunit 99001559 "Subc. Prod. Def. Subscriber"
{
    EventSubscriberInstance = Manual;

    var
        StoredPurchLine: Record "Purchase Line";


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Prod. Def. Source Initializer", 'OnBeforeInitializeFromSource', '', false, false)]
    local procedure OnBeforeInitializeFromSource(var TempData: Codeunit "Prod. Definition Temp Data"; Source: Variant; var IsHandled: Boolean)
    var
        PurchLine: Record "Purchase Line";
        DataTypeManagement: Codeunit "Data Type Management";
        SourceRecRef: RecordRef;
    begin
        if not DataTypeManagement.GetRecordRef(Source, SourceRecRef) then
            exit;
        if SourceRecRef.Number <> Database::"Purchase Line" then
            exit;
        SourceRecRef.SetTable(PurchLine);
        TempData.SetGlobalSourceType("Prod. Definition Source"::PurchaseLine);
        ValidatePurchLineForWizard(PurchLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Prod. Def. Source Initializer", 'OnInitializeFromSource', '', false, false)]
    local procedure OnInitializeFromSource(var TempData: Codeunit "Prod. Definition Temp Data"; Source: Variant; var IsHandled: Boolean)
    var
        PurchLine: Record "Purchase Line";
        TempProdOrder: Record "Production Order" temporary;
        DataTypeManagement: Codeunit "Data Type Management";
        SourceRecRef: RecordRef;
        TempProdOrderNoLbl: Label 'TEMP-%1', Locked = true, MaxLength = 20;
    begin
        if TempData.GetGlobalSourceType() <> "Prod. Definition Source"::PurchaseLine then
            exit;

        if not DataTypeManagement.GetRecordRef(Source, SourceRecRef) then
            exit;
        if SourceRecRef.Number <> Database::"Purchase Line" then
            exit;
        SourceRecRef.SetTable(PurchLine);
        StoredPurchLine := PurchLine;

        TempData.SetGlobalItemInfo(PurchLine."No.", PurchLine.Description);
        TempData.SetNewPurchLine(PurchLine);

        TempProdOrder.Init();
        TempProdOrder.Status := "Production Order Status"::Released;
        TempProdOrder."No." := CopyStr(StrSubstNo(TempProdOrderNoLbl, CopyStr(Format(CreateGuid()), 2, 10)), 1, MaxStrLen(TempProdOrder."No."));
        TempProdOrder."Source Type" := "Prod. Order Source Type"::Item;
        TempProdOrder."Source No." := PurchLine."No.";
        if PurchLine."Variant Code" <> '' then
            TempProdOrder."Variant Code" := PurchLine."Variant Code";
        TempProdOrder."Due Date" := PurchLine."Expected Receipt Date";
        TempProdOrder.Quantity := PurchLine."Quantity (Base)";
        TempProdOrder."Location Code" := PurchLine."Location Code";
        TempProdOrder."Created from Purchase Order" := true;
        TempProdOrder.Insert();
        TempData.SetNewProdOrder(TempProdOrder);

        TempData.CreateTemporaryProdOrderLine();
        TempData.ClearTemporaryProductionTables();

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Production Definition Manager", 'OnAfterPostWizardProcessing', '', false, false)]
    local procedure OnAfterPostWizardProcessing(var ProdOrder: Record "Production Order")
    begin
        UpdatePurchaseLineWithProdOrder(StoredPurchLine, ProdOrder);
        HandleSubcontractingAfterUpdate(StoredPurchLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Prod. Definition Temp Data", 'OnBeforeInsertDefaultTemporaryBOMLine', '', false, false)]
    local procedure OnBeforeInsertDefaultTemporaryBOMLine(var TempBOMLine: Record "Production BOM Line" temporary)
    var
        ManufacturingSetup: Record "Manufacturing Setup";
    begin
        ManufacturingSetup.SetLoadFields("Rtng. Link Code Purch. Prov.", "Default Component Item No.");
        ManufacturingSetup.Get();
        TempBOMLine."Subcontracting Type" := "Subcontracting Type"::InventoryByVendor;
        TempBOMLine."Routing Link Code" := ManufacturingSetup."Rtng. Link Code Purch. Prov.";
        if ManufacturingSetup."Default Component Item No." <> '' then
            TempBOMLine."No." := ManufacturingSetup."Default Component Item No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Prod. Definition Temp Data", 'OnAfterInitializeNewTemporaryRoutingInformation', '', false, false)]
    local procedure OnAfterInitializeNewTemporaryRoutingInformation(var TempRoutingHeader: Record "Routing Header" temporary; var TempRoutingLine: Record "Routing Line" temporary; ItemNo: Code[20])
    var
        ManufacturingSetup: Record "Manufacturing Setup";
        Location: Record Location;
        PutAwayOperationLbl: Label 'Put-Away Operation';
    begin
        ManufacturingSetup.Get();

        if ManufacturingSetup."Put-Away Work Center No." <> '' then
            if (StoredPurchLine."Location Code" <> '') and Location.Get(StoredPurchLine."Location Code") then
                if Location."Prod. Output Whse. Handling" <> Location."Prod. Output Whse. Handling"::"No Warehouse Handling" then begin
                    TempRoutingLine.Init();
                    TempRoutingLine."Routing No." := TempRoutingHeader."No.";
                    TempRoutingLine."Operation No." := '20';
                    TempRoutingLine.Type := TempRoutingLine.Type::"Work Center";
                    TempRoutingLine.Validate("No.", ManufacturingSetup."Put-Away Work Center No.");
                    TempRoutingLine.Validate("Work Center No.", ManufacturingSetup."Put-Away Work Center No.");
                    TempRoutingLine.Description := CopyStr(PutAwayOperationLbl, 1, MaxStrLen(TempRoutingLine.Description));
                    TempRoutingLine.Insert();
                end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Prod. Definition Temp Data", 'OnAfterCreateTemporaryComponentFromBOMLine', '', false, false)]
    local procedure OnAfterCreateTemporaryComponentFromBOMLine(var TempProdOrderComponent: Record "Prod. Order Component" temporary; ProductionBOMLine: Record "Production BOM Line")
    var
        ManufacturingSetup: Record "Manufacturing Setup";
        Vendor: Record Vendor;
        SubcontractingManagement: Codeunit "Subcontracting Management";
    begin
        TempProdOrderComponent."Subcontracting Type" := ProductionBOMLine."Subcontracting Type";
        TempProdOrderComponent."Orig. Location Code" := TempProdOrderComponent."Location Code";
        TempProdOrderComponent."Orig. Bin Code" := TempProdOrderComponent."Bin Code";

        ManufacturingSetup.SetLoadFields("Rtng. Link Code Purch. Prov.");
        ManufacturingSetup.Get();
        if TempProdOrderComponent."Routing Link Code" = ManufacturingSetup."Rtng. Link Code Purch. Prov." then
            case TempProdOrderComponent."Subcontracting Type" of
                "Subcontracting Type"::InventoryByVendor, "Subcontracting Type"::Purchase:
                    begin
                        TempProdOrderComponent."Orig. Location Code" := SubcontractingManagement.GetComponentsLocationCode(StoredPurchLine);
                        if Vendor.Get(StoredPurchLine."Buy-from Vendor No.") then
                            if Vendor."Subcontr. Location Code" <> '' then
                                TempProdOrderComponent.Validate("Location Code", Vendor."Subcontr. Location Code");
                    end;
            end;

        TempProdOrderComponent.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Prod. Definition Temp Data", 'OnAfterCreateTemporaryProdOrderRoutingLineFromRouting', '', false, false)]
    local procedure OnAfterCreateTemporaryProdOrderRoutingLineFromRouting(var TempProdOrderRoutingLine: Record "Prod. Order Routing Line" temporary; RoutingLine: Record "Routing Line")
    begin
        TempProdOrderRoutingLine."Vendor No. Subc. Price" := StoredPurchLine."Buy-from Vendor No.";
        TempProdOrderRoutingLine.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Prod. Order Direct Creator", 'OnBeforeInsertProdOrderComponentFromTemp', '', false, false)]
    local procedure OnBeforeInsertProdOrderComponentFromTemp(var ProdOrderComponent: Record "Prod. Order Component"; TempProdOrderComponent: Record "Prod. Order Component" temporary)
    begin
        ProdOrderComponent."Subcontracting Type" := TempProdOrderComponent."Subcontracting Type";
        ProdOrderComponent."Orig. Location Code" := TempProdOrderComponent."Orig. Location Code";
        ProdOrderComponent."Orig. Bin Code" := TempProdOrderComponent."Orig. Bin Code";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Prod. Order Direct Creator", 'OnBeforeInsertProdOrderRoutingLineFromTemp', '', false, false)]
    local procedure OnBeforeInsertProdOrderRoutingLineFromTemp(var ProdOrderRoutingLine: Record "Prod. Order Routing Line"; TempProdOrderRoutingLine: Record "Prod. Order Routing Line" temporary)
    begin
        ProdOrderRoutingLine."Vendor No. Subc. Price" := TempProdOrderRoutingLine."Vendor No. Subc. Price";
    end;

    [EventSubscriber(ObjectType::Page, Page::"Temp Prod. Order Comp. List", 'OnAfterSubcontractingTypeChangedToNonTransfer', '', false, false)]
    local procedure TempProdOrderCompSubcExt_OnAfterSubcontractingTypeChangedToNonTransfer(var ProdOrderComponent: Record "Prod. Order Component")
    var
        Vendor: Record Vendor;
    begin
        if StoredPurchLine."Buy-from Vendor No." = '' then
            exit;
        if Vendor.Get(StoredPurchLine."Buy-from Vendor No.") then
            if Vendor."Subcontr. Location Code" <> '' then
                ProdOrderComponent.Validate("Location Code", Vendor."Subcontr. Location Code");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Prod. Definition Temp Data", 'OnBeforeInsertDefaultRoutingOperation', '', false, false)]
    local procedure OnBeforeInsertDefaultRoutingOperation(var TempRoutingLine: Record "Routing Line" temporary)
    var
        ManufacturingSetup: Record "Manufacturing Setup";
        Vendor: Record Vendor;
    begin
        ManufacturingSetup.SetLoadFields("Rtng. Link Code Purch. Prov.");
        ManufacturingSetup.Get();

        if Vendor.Get(StoredPurchLine."Buy-from Vendor No.") and (Vendor."Work Center No." <> '') then begin
            TempRoutingLine."No." := Vendor."Work Center No.";
            TempRoutingLine.Validate("No.");
            TempRoutingLine.Validate("Work Center No.", Vendor."Work Center No.");
        end;
        TempRoutingLine."Routing Link Code" := ManufacturingSetup."Rtng. Link Code Purch. Prov.";
    end;

    local procedure ValidatePurchLineForWizard(var PurchaseLine: Record "Purchase Line")
    var
        ManufacturingSetup: Record "Manufacturing Setup";
        Vendor: Record Vendor;
    begin
        PurchaseLine.TestField(Type, "Purchase Line Type"::Item);
        PurchaseLine.TestField("Prod. Order No.", '');
        PurchaseLine.TestField("Prod. Order Line No.", 0);
        PurchaseLine.TestField("Qty. Assigned", 0);
        PurchaseLine.TestField("Qty. Rcd. Not Invoiced", 0);

        PurchaseLine.TestStatusOpen();

        ManufacturingSetup.Get();
        ManufacturingSetup.TestField("Rtng. Link Code Purch. Prov.");
        ManufacturingSetup.TestField("Released Order Nos.");
        ManufacturingSetup.TestField("Production BOM Nos.");
        ManufacturingSetup.TestField("Routing Nos.");
        ManufacturingSetup.TestField("Default Work Center No.");
        ManufacturingSetup.TestField("Default Component Item No.");

        Vendor.Get(PurchaseLine."Buy-from Vendor No.");
        Vendor.TestField("Subcontr. Location Code");

        PurchaseLine.TestField(Type, "Purchase Line Type"::Item);
        PurchaseLine.TestField("Prod. Order No.", '');
        PurchaseLine.TestField("Prod. Order Line No.", 0);
        PurchaseLine.TestField(Quantity);
        PurchaseLine.TestField("Location Code");
        PurchaseLine.TestField("Expected Receipt Date");
        PurchaseLine.TestField("Drop Shipment", false);
        PurchaseLine.TestField("Special Order", false);

        PurchaseLine.TestStatusOpen();
    end;

    local procedure UpdatePurchaseLineWithProdOrder(var PurchLine: Record "Purchase Line"; ProdOrder: Record "Production Order")
    var
        ProdOrderLine: Record "Prod. Order Line";
    begin
        PurchLine."Prod. Order No." := ProdOrder."No.";
        PurchLine."Qty. per Unit of Measure" := 0;
        PurchLine."Quantity (Base)" := 0;
        PurchLine."Qty. to Invoice (Base)" := 0;
        PurchLine."Qty. to Receive (Base)" := 0;
        PurchLine."Outstanding Qty. (Base)" := 0;

        ProdOrderLine.SetLoadFields("Line No.");
        ProdOrderLine.SetRange(Status, ProdOrder.Status);
        ProdOrderLine.SetRange("Prod. Order No.", ProdOrder."No.");
        ProdOrderLine.SetRange("Item No.", PurchLine."No.");
        if ProdOrderLine.FindFirst() then
            PurchLine."Prod. Order Line No." := ProdOrderLine."Line No.";

        UpdatePurchLineWithRoutingInfo(PurchLine, ProdOrderLine);
        PurchLine.Modify(true);
    end;

    local procedure UpdatePurchLineWithRoutingInfo(var PurchLine: Record "Purchase Line"; var ProdOrderLine: Record "Prod. Order Line")
    var
        ProdOrderRtngLine: Record "Prod. Order Routing Line";
        WorkCenter: Record "Work Center";
    begin
        if not FindRoutingLinesForProdOrderLine(ProdOrderRtngLine, ProdOrderLine) then
            exit;

        if FindMatchingWorkCenterForVendor(ProdOrderRtngLine, WorkCenter, PurchLine."Buy-from Vendor No.") or
           FindAnySubcontractorWorkCenter(ProdOrderRtngLine, WorkCenter)
        then begin
            UpdatePurchLineFromRoutingLine(PurchLine, ProdOrderRtngLine);
            exit;
        end;

        ProdOrderRtngLine.FindFirst();
        UpdatePurchLineFromRoutingLine(PurchLine, ProdOrderRtngLine);
    end;

    local procedure FindRoutingLinesForProdOrderLine(var ProdOrderRtngLine: Record "Prod. Order Routing Line"; var ProdOrderLine: Record "Prod. Order Line"): Boolean
    begin
        ProdOrderRtngLine.SetLoadFields("Work Center No.", "Operation No.", Description, "Routing No.", "Routing Reference No.");
        ProdOrderRtngLine.SetRange(Status, ProdOrderLine.Status);
        ProdOrderRtngLine.SetRange("Prod. Order No.", ProdOrderLine."Prod. Order No.");
        ProdOrderRtngLine.SetRange("Routing No.", ProdOrderLine."Routing No.");
        ProdOrderRtngLine.SetRange("Routing Reference No.", ProdOrderLine."Line No.");
        ProdOrderRtngLine.SetRange(Type, "Capacity Type Routing"::"Work Center");
        exit(not ProdOrderRtngLine.IsEmpty());
    end;

    local procedure FindMatchingWorkCenterForVendor(var ProdOrderRtngLine: Record "Prod. Order Routing Line"; var WorkCenter: Record "Work Center"; VendorNo: Code[20]): Boolean
    begin
        if ProdOrderRtngLine.FindSet() then
            repeat
                WorkCenter.SetLoadFields("Gen. Prod. Posting Group");
                WorkCenter.SetRange("No.", ProdOrderRtngLine."Work Center No.");
                WorkCenter.SetRange("Subcontractor No.", VendorNo);
                if WorkCenter.FindFirst() then
                    exit(true);
            until ProdOrderRtngLine.Next() = 0;
        exit(false);
    end;

    local procedure FindAnySubcontractorWorkCenter(var ProdOrderRtngLine: Record "Prod. Order Routing Line"; var WorkCenter: Record "Work Center"): Boolean
    begin
        ProdOrderRtngLine.FindSet();
        repeat
            WorkCenter.SetLoadFields("Gen. Prod. Posting Group");
            WorkCenter.SetRange("No.", ProdOrderRtngLine."Work Center No.");
            WorkCenter.SetFilter("Subcontractor No.", '<>%1', '');
            if WorkCenter.FindFirst() then
                exit(true);
        until ProdOrderRtngLine.Next() = 0;
        exit(false);
    end;

    local procedure UpdatePurchLineFromRoutingLine(var PurchLine: Record "Purchase Line"; ProdOrderRtngLine: Record "Prod. Order Routing Line")
    var
        SubPriceManagement: Codeunit "Subc. Price Management";
    begin
        PurchLine.Description := ProdOrderRtngLine.Description;
        PurchLine."Routing No." := ProdOrderRtngLine."Routing No.";
        PurchLine."Routing Reference No." := ProdOrderRtngLine."Routing Reference No.";
        PurchLine."Operation No." := ProdOrderRtngLine."Operation No.";
        PurchLine."Expected Receipt Date" := ProdOrderRtngLine."Ending Date";
        PurchLine.Validate("Work Center No.", ProdOrderRtngLine."Work Center No.");
        SubPriceManagement.GetSubcPriceForPurchLine(PurchLine);
        PurchLine.GetItemTranslation();
    end;

    local procedure HandleSubcontractingAfterUpdate(var PurchLine: Record "Purchase Line")
    var
        RequisitionLine: Record "Requisition Line";
        SubcPurchaseOrderCreator: Codeunit "Subc. Purchase Order Creator";
        NextLineNo: Integer;
    begin
        RequisitionLine."Prod. Order No." := PurchLine."Prod. Order No.";
        RequisitionLine."Prod. Order Line No." := PurchLine."Prod. Order Line No.";
        RequisitionLine."Operation No." := PurchLine."Operation No.";
        RequisitionLine."Routing No." := PurchLine."Routing No.";
        RequisitionLine."Routing Reference No." := PurchLine."Routing Reference No.";

        SubcPurchaseOrderCreator.InsertProdDescriptionOnAfterInsertPurchOrderLine(PurchLine, RequisitionLine);

        NextLineNo := PurchLine."Line No." + 10000;
        SubcPurchaseOrderCreator.TransferSubcontractingProdOrderComp(PurchLine, RequisitionLine, NextLineNo);
    end;
}