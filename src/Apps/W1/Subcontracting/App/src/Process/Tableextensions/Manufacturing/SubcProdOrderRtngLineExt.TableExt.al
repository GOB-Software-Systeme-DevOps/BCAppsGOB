// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.Subcontracting;

using Microsoft.Manufacturing.Document;
using Microsoft.Inventory.Transfer;
using Microsoft.Manufacturing.WorkCenter;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Vendor;

tableextension 99001506 "Subc. ProdOrderRtngLine Ext." extends "Prod. Order Routing Line"
{
    fields
    {
        field(99001550; "Vendor No. Subc. Price"; Code[20])
        {
            AllowInCustomizations = AsReadOnly;
            Caption = 'Vendor No. Subcontracting Prices';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = Vendor;
        }
        field(99001551; Subcontracting; Boolean)
        {
            AllowInCustomizations = AsReadOnly;
            CalcFormula = exist("Work Center" where("No." = field("Work Center No."),
                                                    "Subcontractor No." = filter(<> '')));
            Caption = 'Subcontracting';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies whether the Work Center Group is set up with a Vendor for Subcontracting.';
        }
        field(99001560; "Transfer WIP Item"; Boolean)
        {
            AllowInCustomizations = AsReadWrite;
            Caption = 'Transfer WIP Item';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the production order parent item (WIP item) is transferred to the subcontractor for this operation.';
        }
        field(99001561; "Transfer Description"; Text[100])
        {
            AllowInCustomizations = AsReadWrite;
            Caption = 'Transfer Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the operation-specific description used on transfer orders for the semi-finished item as it is shipped to the subcontracting location. If empty, the standard description is used.';
        }
        field(99001562; "Transfer Description 2"; Text[50])
        {
            AllowInCustomizations = AsReadWrite;
            Caption = 'Transfer Description 2';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies an additional operation-specific description line used on transfer orders for the semi-finished item as it is shipped to the subcontracting location.';
        }
        field(99001563; "WIP Qty. (Base) at Subc."; Decimal)
        {
            AllowInCustomizations = AsReadOnly;
            AutoFormatType = 0;
            CalcFormula = sum("Subcontractor WIP Ledger Entry"."Quantity (Base)" where("Prod. Order Status" = field(Status),
                                                                                        "Prod. Order No." = field("Prod. Order No."),
                                                                                        "Prod. Order Line No." = field("Routing Reference No."),
                                                                                        "Routing Reference No." = field("Routing Reference No."),
                                                                                        "Routing No." = field("Routing No."),
                                                                                        "Operation No." = field("Operation No."),
                                                                                        "Location Code" = field("WIP Location Filter")));
            Caption = 'WIP Qty. (Base) at Subcontractor';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the total work-in-progress quantity (base) of the production order parent item currently held at the subcontractor location for this operation, as tracked by Subcontractor WIP Ledger Entries.';
        }
        field(99001564; "WIP Qty. (Base) in Transit"; Decimal)
        {
            AllowInCustomizations = AsReadOnly;
            AutoFormatType = 0;
            CalcFormula = sum("Subcontractor WIP Ledger Entry"."Quantity (Base)" where("Prod. Order Status" = field(Status),
                                                                                        "Prod. Order No." = field("Prod. Order No."),
                                                                                        "Prod. Order Line No." = field("Routing Reference No."),
                                                                                        "Routing Reference No." = field("Routing Reference No."),
                                                                                        "Routing No." = field("Routing No."),
                                                                                        "Operation No." = field("Operation No."),
                                                                                        "Location Code" = field("WIP Location Filter"),
                                                                                        "In Transit" = const(true)));
            Caption = 'WIP Qty. (Base) in Transit';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the outstanding quantity of the production order parent item on transfer orders that is currently in transit to the subcontractor for this operation.';
        }
        field(99001534; "WIP Location Filter"; Code[10])
        {
            Caption = 'WIP Location Filter';
            FieldClass = FlowFilter;
            ToolTip = 'Specifies the location filter for the WIP inventory transactions related to this production operation.';
        }
    }

    trigger OnBeforeDelete()
    begin
        CheckForSubcontractingPurchaseLineTypeMismatchOnDeleteLine();
    end;

    internal procedure CheckForSubcontractingPurchaseLineTypeMismatch()
    var
        ProdOrderLine: Record "Prod. Order Line";
        PurchLine: Record "Purchase Line";
        PurchaseLineTypeMismatchLastOperationErr: Label 'There is at least one Purchase Line (%1) which is linked to Production Order Routing Line (%2). Because the Production Order Routing Line is not the last operation, the Purchase Line cannot be of type Last Operation. Please delete the Purchase line first before changing the Production Order Routing Line.',
        Comment = '%1 = PurchaseLine Record Id, %2 = Production Order Routing Line Record Id';
        PurchaseLineTypeMismatchNotLastOperationErr: Label 'There is at least one Purchase Line (%1) which is linked to Production Order Routing Line (%2). Because the Production Order Routing Line is the last operation, the Purchase Line cannot be of type Not Last Operation. Please delete the Purchase line first before changing the Production Order Routing Line.',
        Comment = '%1 = PurchaseLine Record Id, %2 = Production Order Routing Line Record Id';
    begin
        if Status <> "Production Order Status"::Released then
            exit;

        ProdOrderLine.SetLoadFields(SystemId);
        ProdOrderLine.SetRange(Status, Status);
        ProdOrderLine.SetRange("Prod. Order No.", "Prod. Order No.");
        ProdOrderLine.SetRange("Routing Reference No.", "Routing Reference No.");
        ProdOrderLine.SetRange("Routing No.", "Routing No.");
        if ProdOrderLine.Find('-') then
            repeat
                PurchLine.SetLoadFields(SystemId);
                PurchLine.SetCurrentKey(
                  "Document Type", Type, "Prod. Order No.", "Prod. Order Line No.", "Routing No.", "Operation No.");
                PurchLine.SetRange("Document Type", PurchLine."Document Type"::Order);
                PurchLine.SetRange(Type, PurchLine.Type::Item);
                PurchLine.SetRange("Prod. Order No.", "Prod. Order No.");
                PurchLine.SetRange("Prod. Order Line No.", ProdOrderLine."Line No.");
                PurchLine.SetRange("Operation No.", "Operation No.");
                if "Next Operation No." <> '' then begin
                    PurchLine.SetRange("Subc. Purchase Line Type", "Subc. Purchase Line Type"::LastOperation);
                    if PurchLine.FindFirst() then
                        Error(PurchaseLineTypeMismatchLastOperationErr, PurchLine.RecordId(), RecordId());
                end else begin
                    PurchLine.SetRange("Subc. Purchase Line Type", "Subc. Purchase Line Type"::NotLastOperation);
                    if PurchLine.FindFirst() then
                        Error(PurchaseLineTypeMismatchNotLastOperationErr, PurchLine.RecordId(), RecordId());
                end;
            until ProdOrderLine.Next() = 0;
    end;

    local procedure CheckForSubcontractingPurchaseLineTypeMismatchOnDeleteLine()
    var
        ProdOrderLine: Record "Prod. Order Line";
        PurchLine: Record "Purchase Line";
        PrevProdOrderRoutingLine: Record "Prod. Order Routing Line";
        PurchaseLineTypeMismatchNotLastOperationErr: Label 'There is at least one Purchase Line (%1) which is linked to Production Order Routing Line (%2). Because the Production Order Routing Line is the last operation after delete, the Purchase Line cannot be of type Not Last Operation. Please delete the Purchase line first before changing the Production Order Routing Line.',
        Comment = '%1 = PurchaseLine Record Id, %2 = Previous Production Order Routing Line Record Id';
    begin
        if Status <> "Production Order Status"::Released then
            exit;
        ProdOrderLine.SetLoadFields(SystemId);
        ProdOrderLine.SetRange(Status, Status);
        ProdOrderLine.SetRange("Prod. Order No.", "Prod. Order No.");
        ProdOrderLine.SetRange("Routing Reference No.", "Routing Reference No.");
        ProdOrderLine.SetRange("Routing No.", "Routing No.");
        if ProdOrderLine.Find('-') then
            repeat
                PurchLine.SetLoadFields(SystemId);
                PurchLine.SetCurrentKey(
                  "Document Type", Type, "Prod. Order No.", "Prod. Order Line No.", "Routing No.", "Operation No.");
                PurchLine.SetRange("Document Type", PurchLine."Document Type"::Order);
                PurchLine.SetRange(Type, PurchLine.Type::Item);
                PurchLine.SetRange("Prod. Order No.", "Prod. Order No.");
                PurchLine.SetRange("Prod. Order Line No.", ProdOrderLine."Line No.");
                if "Next Operation No." = '' then begin
                    PrevProdOrderRoutingLine := Rec;
                    PrevProdOrderRoutingLine.SetRecFilter();
                    PrevProdOrderRoutingLine.SetFilter("Operation No.", "Previous Operation No.");
                    PrevProdOrderRoutingLine.SetLoadFields(SystemId);
                    if PrevProdOrderRoutingLine.FindSet() then
                        repeat
                            PurchLine.SetRange("Operation No.", PrevProdOrderRoutingLine."Operation No.");
                            PurchLine.SetRange("Subc. Purchase Line Type", "Subc. Purchase Line Type"::NotLastOperation);
                            if PurchLine.FindFirst() then
                                Error(PurchaseLineTypeMismatchNotLastOperationErr, PurchLine.RecordId(), PrevProdOrderRoutingLine.RecordId());
                        until PrevProdOrderRoutingLine.Next() = 0;
                end;
            until ProdOrderLine.Next() = 0;
    end;
}