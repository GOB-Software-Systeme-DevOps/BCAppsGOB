// ------------------------------------------------------------------------------------------------
// Copyright (c) GOB Software Systeme GmbH. All rights reserved.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.Subcontracting;

using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.ProductionBOM;
using Microsoft.Manufacturing.Setup;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Vendor;

codeunit 99001560 "Subc. Prod. Order Create Bind"
{
    EventSubscriberInstance = Manual;

    var
        SubcontractingPurchaseLine: Record "Purchase Line";

    /// <summary>
    /// Sets the purchase line for subcontracting context. Must be called before BindSubscription.
    /// </summary>
    procedure SetSubcontractingPurchaseLine(PurchLine: Record "Purchase Line")
    begin
        SubcontractingPurchaseLine := PurchLine;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Routing Line", 'OnBeforeCheckRoutingNoNotBlank', '', false, false)]
    local procedure ProdOrderRoutingLine_OnBeforeCheckRoutingNoNotBlank(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Subcontracting Management", 'OnBeforeGetSubcontractor', '', false, false)]
    local procedure OnBeforeGetSubcontractor(WorkCenterNo: Code[20]; var Vendor: Record Vendor; var HasSubcontractor: Boolean; var IsHandled: Boolean)
    begin
        GetSubcontractorForPurchaseProvision(Vendor, HasSubcontractor, IsHandled);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Subc. Calc. Prod. Order Ext.", 'OnAfterTransferSubcontractingFieldsBOMComponent', '', false, false)]
    local procedure SubCalcProdOrderExt_OnAfterTransferSubcontractingFieldsBOMComponent(var ProductionBOMLine: Record "Production BOM Line"; var ProdOrderComponent: Record "Prod. Order Component")
    begin
        TransferSubcontractingFieldsBOMComponentForPurchaseProvision(ProdOrderComponent);
    end;

    local procedure GetSubcontractorForPurchaseProvision(var Vendor: Record Vendor; var HasSubcontractor: Boolean; var IsHandled: Boolean)
    begin
        if SubcontractingPurchaseLine."Buy-from Vendor No." = '' then
            exit;
        Vendor.Get(SubcontractingPurchaseLine."Buy-from Vendor No.");
        IsHandled := true;
        HasSubcontractor := true;
    end;

    local procedure TransferSubcontractingFieldsBOMComponentForPurchaseProvision(var ProdOrderComponent: Record "Prod. Order Component")
    var
        ManufacturingSetup: Record "Manufacturing Setup";
        SubcontractingManagement: Codeunit "Subcontracting Management";
        ComponentsLocationCode: Code[10];
    begin
        ManufacturingSetup.SetLoadFields("Rtng. Link Code Purch. Prov.");
        ManufacturingSetup.Get();
        if (ProdOrderComponent."Routing Link Code" <> ManufacturingSetup."Rtng. Link Code Purch. Prov.") or
           (ProdOrderComponent."Subcontracting Type" <> "Subcontracting Type"::Transfer)
        then
            exit;

        ComponentsLocationCode := SubcontractingManagement.GetComponentsLocationCode(SubcontractingPurchaseLine);
        ProdOrderComponent.Validate("Location Code", ComponentsLocationCode);
        ProdOrderComponent."Orig. Location Code" := '';
    end;
}