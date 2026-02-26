// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.Subcontracting;

using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Costing;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Transfer;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.WorkCenter;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Vendor;

report 99001501 "Subc. Create Transf. Order"
{
    ApplicationArea = Manufacturing;
    Caption = 'Create Subcontracting Transfer Order';
    ProcessingOnly = true;
    UsageCategory = Tasks;
    dataset
    {
        dataitem("Purchase Header"; "Purchase Header")
        {
            DataItemTableView = sorting("Document Type", "No.") order(ascending);
            dataitem("Purchase Line"; "Purchase Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document Type", "Document No.", "Line No.") order(ascending) where("Prod. Order No." = filter(<> ''), "Operation No." = filter(<> ''));
                trigger OnAfterGetRecord()
                begin
                    HandleComponentsForPurchLine("Purchase Line", true);
                    HandleWIPTransferForPurchLine("Purchase Line", true);
                end;
            }
            trigger OnAfterGetRecord()
            begin
                "Purchase Header".CalcFields("Subcontracting Order");
                if not "Subcontracting Order" then
                    Error(OrderNoIsNotSubcontractorErr, PurchOrderNo);

                if not CheckTransferCreated() then
                    Error(NothingToCreateErr);

                Vendor.Get("Purchase Header"."Buy-from Vendor No.");
            end;

            trigger OnPostDataItem()
            begin
                ShowDocument();
            end;

            trigger OnPreDataItem()
            begin
                PurchOrderNo := CopyStr("Purchase Header".GetFilter("No."), 1, MaxStrLen(PurchOrderNo));
                if PurchOrderNo = '' then
                    Error(WarningToSpecifyPurchOrderErr);
            end;
        }
    }

    var
        SubcManagementSetup: Record "Subc. Management Setup";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        Vendor: Record Vendor;
        PurchOrderNo: Code[20];
        LineNo: Integer;
        NothingToCreateErr: Label 'Nothing to create. No components or WIP to transfer for the specified subcontracting order.';
        OrderNoDoesNotExistInProdOrderErr: Label 'Operation %1 in the subcontracting order %2 does not exist in the routing %3 of the production order %4.', Comment = '%1=Operation No., %2=Purchase Order No., %3=Routing No., %4=Production Order No.';
        OrderNoIsNotSubcontractorErr: Label 'Order %1 is not a Subcontractor work.', Comment = '%1=Purchase Order No.';
        WarningToSpecifyPurchOrderErr: Label 'Warning. Specify a Purchase Order No. for the Subcontractor work.';

    local procedure InsertTransferHeader(TransferFromLocation: Code[10])
    var
        SubcontractingManagement: Codeunit "Subcontracting Management";
        TransferToLocationCode: Code[10];
    begin
        if not SubcManagementSetup.Get() then
            Clear(SubcManagementSetup);

        GetTransferToLocationCode(TransferToLocationCode);

        TransferHeader.Reset();
        TransferHeader.SetRange("Source Subtype", TransferHeader."Source Subtype"::"2");
        TransferHeader.SetRange("Source ID", "Purchase Header"."Buy-from Vendor No.");
        TransferHeader.SetRange(Status, TransferHeader.Status::Open);
        TransferHeader.SetRange("Completely Shipped", false);
        TransferHeader.SetRange("Transfer-from Code", TransferFromLocation);
        TransferHeader.SetRange("Transfer-to Code", TransferToLocationCode);
        TransferHeader.SetRange("Return Order", false);
        if not TransferHeader.FindFirst() then begin
            TransferHeader.Init();
            TransferHeader."No." := '';
            TransferHeader.Insert(true);
            TransferHeader.Validate("Transfer-from Code", TransferFromLocation);
            TransferHeader.Validate("Transfer-to Code", TransferToLocationCode);
            if SubcManagementSetup."Direct Transfer" then begin
                SubcontractingManagement.CheckDirectTransferIsAllowedForTransferHeader(TransferHeader);
                TransferHeader.Validate("Direct Transfer Posting", "Direct Transfer Post. Type"::"Direct Transfer");
            end;

            TransferHeader."Source Type" := TransferHeader."Source Type"::Subcontracting;
            TransferHeader."Source Subtype" := TransferHeader."Source Subtype"::"2";
            TransferHeader."Source ID" := "Purchase Header"."Buy-from Vendor No.";
            TransferHeader."Subcontr. Purch. Order No." := "Purchase Header"."No.";
            TransferHeader."Subcontr. PO Line No." := "Purchase Line"."Line No.";

            TransferHeader."Transfer-to Name" := Vendor.Name;
            TransferHeader."Transfer-to Name 2" := Vendor."Name 2";
            TransferHeader."Transfer-to Address" := Vendor.Address;
            TransferHeader."Transfer-to Address 2" := Vendor."Address 2";
            TransferHeader."Transfer-to Post Code" := Vendor."Post Code";
            TransferHeader."Transfer-to City" := Vendor.City;
            TransferHeader."Transfer-to County" := Vendor.County;
            TransferHeader."Trsf.-from Country/Region Code" := Vendor."Country/Region Code";

            TransferHeader.Modify();

            LineNo := 0;
        end else begin
            TransferLine.SetRange("Document No.", TransferHeader."No.");
            if TransferLine.FindLast() then
                LineNo := TransferLine."Line No."
            else
                LineNo := 0;
        end;
    end;

    local procedure CheckTransferCreated(): Boolean
    var
        PurchaseLine: Record "Purchase Line";
        TransferCreated: Boolean;
    begin
        PurchaseLine.SetCurrentKey("Document Type", Type, "Prod. Order No.", "Prod. Order Line No.", "Routing No.", "Operation No.");
        PurchaseLine.SetRange("Document No.", PurchOrderNo);
        PurchaseLine.SetFilter("Prod. Order No.", '<>''''');
        PurchaseLine.SetFilter("Prod. Order Line No.", '<>0');
        PurchaseLine.SetFilter("Operation No.", '<>0');
        if PurchaseLine.FindSet() then
            repeat
                if HandleComponentsForPurchLine(PurchaseLine, false) then
                    TransferCreated := true;
                if HandleWIPTransferForPurchLine(PurchaseLine, false) then
                    TransferCreated := true;
            until PurchaseLine.Next() = 0;

        exit(TransferCreated);
    end;

    local procedure HandleComponentsForPurchLine(PurchaseLine: Record "Purchase Line"; InsertLine: Boolean): Boolean
    var
        Item: Record Item;
        ProdOrderComponent: Record "Prod. Order Component";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        MfgCostCalculationMgt: Codeunit "Mfg. Cost Calculation Mgt.";
        SubcProdOrdCompRes: Codeunit "Subc. Prod. Ord. Comp. Res.";
        SubcontractingManagement: Codeunit "Subcontracting Management";
        UnitofMeasureManagement: Codeunit "Unit of Measure Management";
        TransferFromLocationCode: Code[10];
        QtyPerUom: Decimal;
        QtyToPost: Decimal;
    begin
        if not ProdOrderLine.Get("Production Order Status"::Released, PurchaseLine."Prod. Order No.", PurchaseLine."Prod. Order Line No.") then
            exit(false);

        if not ProdOrderRoutingLine.Get("Production Order Status"::Released, PurchaseLine."Prod. Order No.",
             PurchaseLine."Routing Reference No.", PurchaseLine."Routing No.", PurchaseLine."Operation No.")
        then
            Error(OrderNoDoesNotExistInProdOrderErr, PurchaseLine."Operation No.", PurchOrderNo, PurchaseLine."Routing No.", PurchaseLine."Prod. Order No.");

        Item.SetLoadFields("Base Unit of Measure", "Rounding Precision");
        Item.Get(PurchaseLine."No.");
        QtyPerUom := UnitofMeasureManagement.GetQtyPerUnitOfMeasure(Item, PurchaseLine."Unit of Measure Code");

        ProdOrderComponent.SetCurrentKey(Status, "Prod. Order No.", "Routing Link Code");
        ProdOrderComponent.SetRange(Status, "Production Order Status"::Released);
        ProdOrderComponent.SetRange("Prod. Order No.", PurchaseLine."Prod. Order No.");
        ProdOrderComponent.SetRange("Prod. Order Line No.", PurchaseLine."Prod. Order Line No.");
        ProdOrderComponent.SetRange("Routing Link Code", ProdOrderRoutingLine."Routing Link Code");
        ProdOrderComponent.SetRange("Purchase Order Filter", PurchaseLine."Document No.");
        ProdOrderComponent.SetRange("Subcontracting Type", ProdOrderComponent."Subcontracting Type"::Transfer);
        if ProdOrderComponent.FindSet() then
            repeat
                Item.SetLoadFields("Rounding Precision", "Order Tracking Policy");
                Item.Get(ProdOrderComponent."Item No.");
                QtyToPost := MfgCostCalculationMgt.CalcActNeededQtyBase(ProdOrderLine, ProdOrderComponent, Round(PurchaseLine.Quantity * QtyPerUom, UnitofMeasureManagement.QtyRndPrecision()));
                ProdOrderComponent.CalcFields("Qty. on Trans Order (Base)", "Qty. in Transit (Base)", "Qty. transf. to Subcontr");
                if QtyToPost > (ProdOrderComponent."Qty. on Trans Order (Base)" +
                                ProdOrderComponent."Qty. in Transit (Base)" +
                                Abs(ProdOrderComponent."Qty. transf. to Subcontr"))
                then
                    if InsertLine then begin
                        TransferFromLocationCode := GetTransferFromLocationForComponent(ProdOrderComponent);
                        InsertTransferHeader(TransferFromLocationCode);

                        LineNo := LineNo + 10000;

                        TransferLine.Init();
                        TransferLine."Document No." := TransferHeader."No.";
                        TransferLine."Line No." := LineNo;

                        TransferLine.Insert();

                        TransferLine.Validate("Item No.", ProdOrderComponent."Item No.");
                        TransferLine.Validate("Variant Code", ProdOrderComponent."Variant Code");

                        TransferLine."Unit of Measure Code" := ProdOrderComponent."Unit of Measure Code";
                        TransferLine."Qty. per Unit of Measure" := ProdOrderComponent."Qty. per Unit of Measure";

                        QtyToPost := QtyToPost -
                            (ProdOrderComponent."Qty. on Trans Order (Base)" +
                             ProdOrderComponent."Qty. in Transit (Base)" +
                             Abs(ProdOrderComponent."Qty. transf. to Subcontr"));

                        TransferLine.Validate(Quantity, Round(QtyToPost / ProdOrderComponent."Qty. per Unit of Measure", Item."Rounding Precision", '>'));

                        if ProdOrderComponent."Due Date" <> 0D then
                            TransferLine.Validate("Receipt Date", SubcontractingManagement.CalcReceiptDateFromProdCompDueDateWithInbWhseHandlingTime(ProdOrderComponent));

                        TransferLine."Subcontr. Purch. Order No." := PurchaseLine."Document No.";
                        TransferLine."Subcontr. PO Line No." := PurchaseLine."Line No.";
                        TransferLine."Prod. Order No." := PurchaseLine."Prod. Order No.";
                        TransferLine."Prod. Order Line No." := PurchaseLine."Prod. Order Line No.";
                        TransferLine."Prod. Order Comp. Line No." := ProdOrderComponent."Line No.";
                        TransferLine."Routing No." := PurchaseLine."Routing No.";
                        TransferLine."Routing Reference No." := PurchaseLine."Routing Reference No.";
                        TransferLine."Work Center No." := PurchaseLine."Work Center No.";
                        TransferLine."Operation No." := PurchaseLine."Operation No.";
                        TransferLine.Modify();

                        if ProdOrderComponent."Orig. Location Code" = '' then
                            ProdOrderComponent."Orig. Location Code" := ProdOrderComponent."Location Code";
                        if ProdOrderComponent."Orig. Bin Code" = '' then
                            ProdOrderComponent."Orig. Bin Code" := ProdOrderComponent."Bin Code";

                        SubcontractingManagement.TransferReservationEntryFromProdOrderCompToTransferOrder(TransferLine, ProdOrderComponent);
                        if TransferHeader."Transfer-to Code" <> ProdOrderComponent."Location Code" then begin
                            if Item."Order Tracking Policy" = Item."Order Tracking Policy"::None then
                                ProdOrderComponent.Validate("Location Code", TransferHeader."Transfer-to Code")
                            else begin
                                BindSubscription(SubcProdOrdCompRes);
                                ProdOrderComponent.Validate("Location Code", TransferHeader."Transfer-to Code");
                                UnbindSubscription(SubcProdOrdCompRes);
                            end;
                            ProdOrderComponent.GetDefaultBin();
                        end;
                        ProdOrderComponent.Modify();

                        SubcontractingManagement.CreateReservEntryForTransferReceiptToProdOrderComp(TransferLine, ProdOrderComponent);
                    end else
                        exit(true);
            until ProdOrderComponent.Next() = 0;

        exit(false);
    end;

    local procedure ShowDocument()
    begin
        Commit(); // Used for following call of Transfer Pages
        TransferHeader.Reset();
        TransferHeader.SetCurrentKey("Subcontr. Purch. Order No.");
        TransferHeader.SetRange("Subcontr. Purch. Order No.", "Purchase Line"."Document No.");
        if TransferHeader.Count() > 1 then
            Page.Run(Page::"Transfer Orders", TransferHeader)
        else
            Page.Run(Page::"Transfer Order", TransferHeader);
    end;

    local procedure GetTransferFromLocationForComponent(ProdOrderComponent: Record "Prod. Order Component"): Code[10]
    var
        ResultLocationCode: Code[10];
        SubcontrLocationCode: Code[10];
    begin
        SubcontrLocationCode := "Purchase Header"."Subc. Location Code";
        if SubcontrLocationCode = '' then
            SubcontrLocationCode := Vendor."Subcontr. Location Code";

        if (ProdOrderComponent."Location Code" = SubcontrLocationCode) and
           (ProdOrderComponent."Orig. Location Code" <> '')
        then
            ResultLocationCode := ProdOrderComponent."Orig. Location Code"
        else
            ResultLocationCode := ProdOrderComponent."Location Code";
        exit(ResultLocationCode);
    end;

    local procedure GetTransferToLocationCode(var TransferToLocationCode: Code[10])
    begin
        TransferToLocationCode := "Purchase Header"."Subc. Location Code";
        if TransferToLocationCode = '' then begin
            TransferToLocationCode := Vendor."Subcontr. Location Code";
            if TransferToLocationCode = '' then
                Vendor.TestField("Subcontr. Location Code");
        end;
    end;

    local procedure HandleWIPTransferForPurchLine(PurchaseLine: Record "Purchase Line"; InsertLine: Boolean): Boolean
    var
        Item: Record Item;
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        UOMManagement: Codeunit "Unit of Measure Management";
        TransferFromLoc: Code[10];
        WIPQtyBase: Decimal;
        WIPQtyInUOM: Decimal;
        WIPSourceQtyList: Dictionary of [Code[10], Decimal];
        WIPSourceLocationList: List of [Code[10]];
    begin
        if not ProdOrderLine.Get("Production Order Status"::Released, PurchaseLine."Prod. Order No.", PurchaseLine."Prod. Order Line No.") then
            exit(false);

        if not ProdOrderRoutingLine.Get("Production Order Status"::Released, PurchaseLine."Prod. Order No.", PurchaseLine."Routing Reference No.", PurchaseLine."Routing No.", PurchaseLine."Operation No.")
        then
            exit(false);

        if not ProdOrderRoutingLine."Transfer WIP Item" then
            exit(false);

        if WIPTransferLineAlreadyExists(PurchaseLine) then
            exit(false);

        GetWIPTransferFromLocations(ProdOrderLine, ProdOrderRoutingLine, WIPSourceLocationList, WIPSourceQtyList);

        if WIPSourceLocationList.Count() = 0 then
            exit(false);

        if not InsertLine then
            exit(true);

        Item.SetLoadFields("Base Unit of Measure", "Rounding Precision", Description, "Description 2");
        Item.Get(ProdOrderLine."Item No.");

        foreach TransferFromLoc in WIPSourceLocationList do begin
            WIPQtyBase := WIPSourceQtyList.Get(TransferFromLoc);
            if ProdOrderLine."Qty. per Unit of Measure" <> 0 then
                WIPQtyInUOM := Round(WIPQtyBase / ProdOrderLine."Qty. per Unit of Measure", UOMManagement.QtyRndPrecision())
            else
                WIPQtyInUOM := Round(WIPQtyBase, UOMManagement.QtyRndPrecision());
            if WIPQtyInUOM > 0 then begin
                InsertTransferHeader(TransferFromLoc);
                InsertWIPTransferLine(PurchaseLine, ProdOrderLine, ProdOrderRoutingLine, WIPQtyInUOM);
            end;
        end;

        exit(false);
    end;

    local procedure InsertWIPTransferLine(PurchaseLine: Record "Purchase Line"; ProdOrderLine: Record "Prod. Order Line"; ProdOrderRoutingLine: Record "Prod. Order Routing Line"; WIPQty: Decimal)
    begin
        LineNo := LineNo + 10000;

        TransferLine.Init();
        TransferLine."Document No." := TransferHeader."No.";
        TransferLine."Line No." := LineNo;
        TransferLine.Insert();

        TransferLine.Validate("Item No.", ProdOrderLine."Item No.");
        if ProdOrderLine."Variant Code" <> '' then
            TransferLine.Validate("Variant Code", ProdOrderLine."Variant Code");
        TransferLine."Unit of Measure Code" := ProdOrderLine."Unit of Measure Code";
        TransferLine."Qty. per Unit of Measure" := ProdOrderLine."Qty. per Unit of Measure";
        TransferLine."Transfer WIP Item" := true;
        TransferLine.Validate(Quantity, WIPQty);

        if ProdOrderRoutingLine."Transfer Description" <> '' then
            TransferLine.Description := ProdOrderRoutingLine."Transfer Description";

        if ProdOrderRoutingLine."Transfer Description 2" <> '' then
            TransferLine."Description 2" := ProdOrderRoutingLine."Transfer Description 2";

        TransferLine."Subcontr. Purch. Order No." := PurchaseLine."Document No.";
        TransferLine."Subcontr. PO Line No." := PurchaseLine."Line No.";
        TransferLine."Prod. Order No." := ProdOrderLine."Prod. Order No.";
        TransferLine."Prod. Order Line No." := ProdOrderLine."Line No.";
        TransferLine."Routing No." := ProdOrderRoutingLine."Routing No.";
        TransferLine."Routing Reference No." := ProdOrderRoutingLine."Routing Reference No.";
        TransferLine."Work Center No." := ProdOrderRoutingLine."Work Center No.";
        TransferLine."Operation No." := ProdOrderRoutingLine."Operation No.";

        TransferLine.Modify();
    end;

    local procedure GetWIPTransferFromLocations(ProdOrderLine: Record "Prod. Order Line"; ProdOrderRoutingLine: Record "Prod. Order Routing Line"; var WIPSourceLocationList: List of [Code[10]]; var WIPSourceQtyList: Dictionary of [Code[10], Decimal])
    var
        PrevProdOrderRoutingLine: Record "Prod. Order Routing Line";
        IsSerial: Boolean;
        LocCode: Code[10];
        WIPQtyBase: Decimal;
    begin
        // No previous operation: initial transfer directly from Prod. Order Line location
        if ProdOrderRoutingLine."Previous Operation No." = '' then begin
            LocCode := ProdOrderLine."Location Code";
            if LocCode <> '' then begin
                WIPSourceLocationList.Add(LocCode);
                WIPSourceQtyList.Add(LocCode, ProdOrderLine."Quantity (Base)");
            end;
            exit;
        end;

        IsSerial := ProdOrderRoutingLine.IsSerial();

        PrevProdOrderRoutingLine.SetRange(Status, "Production Order Status"::Released);
        PrevProdOrderRoutingLine.SetRange("Prod. Order No.", ProdOrderLine."Prod. Order No.");
        PrevProdOrderRoutingLine.SetRange("Routing Reference No.", ProdOrderRoutingLine."Routing Reference No.");
        PrevProdOrderRoutingLine.SetFilter("Operation No.", ProdOrderRoutingLine."Previous Operation No.");
        PrevProdOrderRoutingLine.SetLoadFields("Operation No.");
        if PrevProdOrderRoutingLine.FindSet() then
            repeat
                GetWIPLocationAndQtyForPreviousOp(
                    ProdOrderLine, PrevProdOrderRoutingLine, IsSerial, LocCode, WIPQtyBase);

                if (LocCode <> '') and (WIPQtyBase > 0) and (not WIPSourceQtyList.ContainsKey(LocCode)) then begin
                    WIPSourceLocationList.Add(LocCode);
                    WIPSourceQtyList.Add(LocCode, WIPQtyBase);
                end;
            until PrevProdOrderRoutingLine.Next() = 0;

        // Fallback: use Prod. Order Line location
        if WIPSourceLocationList.Count() = 0 then begin
            LocCode := ProdOrderLine."Location Code";
            if LocCode <> '' then begin
                WIPSourceLocationList.Add(LocCode);
                WIPSourceQtyList.Add(LocCode, ProdOrderLine."Quantity (Base)");
            end;
        end;
    end;

    local procedure GetWIPLocationAndQtyForPreviousOp(ProdOrderLine: Record "Prod. Order Line"; PrevProdOrderRoutingLine: Record "Prod. Order Routing Line"; IsSerial: Boolean; var LocationCode: Code[10]; var WIPQtyBase: Decimal)
    var
        WIPLedgerEntry: Record "Subcontractor WIP Ledger Entry";
        PrevVendor: Record Vendor;
        PrevWorkCenter: Record "Work Center";
    begin
        LocationCode := ProdOrderLine."Location Code";
        WIPQtyBase := ProdOrderLine."Quantity (Base)";

        if PrevProdOrderRoutingLine."Transfer WIP Item" then begin
            // Previous op has a subcontracting WIP transfer
            PrevWorkCenter.SetLoadFields("Subcontractor No.");
            if PrevWorkCenter.Get(PrevProdOrderRoutingLine."Work Center No.") then
                if PrevWorkCenter."Subcontractor No." <> '' then begin
                    PrevVendor.SetLoadFields("Subcontr. Location Code");
                    if PrevVendor.Get(PrevWorkCenter."Subcontractor No.") then
                        if PrevVendor."Subcontr. Location Code" <> '' then
                            LocationCode := PrevVendor."Subcontr. Location Code";
                end;

            if LocationCode <> '' then begin
                WIPLedgerEntry.SetRange("Prod. Order Status", "Production Order Status"::Released);
                WIPLedgerEntry.SetRange("Prod. Order No.", ProdOrderLine."Prod. Order No.");
                WIPLedgerEntry.SetRange("Prod. Order Line No.", ProdOrderLine."Line No.");
                WIPLedgerEntry.SetRange("Routing No.", PrevProdOrderRoutingLine."Routing No.");
                WIPLedgerEntry.SetRange("Routing Reference No.", PrevProdOrderRoutingLine."Routing Reference No.");
                WIPLedgerEntry.SetRange("Operation No.", PrevProdOrderRoutingLine."Operation No.");
                WIPLedgerEntry.SetRange("Location Code", LocationCode);
                WIPLedgerEntry.SetRange("In Transit", false);
                WIPLedgerEntry.CalcSums("Quantity (Base)");
            end;
        end;

        // Parallel routings always use Prod. Order Line quantity as preset
        if IsSerial and (WIPLedgerEntry."Quantity (Base)" <> 0) then
            WIPQtyBase := WIPLedgerEntry."Quantity (Base)";
    end;

    local procedure WIPTransferLineAlreadyExists(PurchaseLine: Record "Purchase Line"): Boolean
    var
        CheckLine: Record "Transfer Line";
    begin
        CheckLine.SetRange("Subcontr. Purch. Order No.", PurchaseLine."Document No.");
        CheckLine.SetRange("Prod. Order No.", PurchaseLine."Prod. Order No.");
        CheckLine.SetRange("Prod. Order Line No.", PurchaseLine."Prod. Order Line No.");
        CheckLine.SetRange("Operation No.", PurchaseLine."Operation No.");
        CheckLine.SetRange("Transfer WIP Item", true);
        exit(not CheckLine.IsEmpty());
    end;
}