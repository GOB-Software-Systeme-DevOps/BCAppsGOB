// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.Subcontracting;

page 99001561 "WIP Adjustment"
{
    ApplicationArea = Manufacturing;
    Caption = 'WIP Adjustment';
    PageType = StandardDialog;
    SourceTable = "Subcontractor WIP Ledger Entry";
    SourceTableTemporary = true;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            group(Adjustment)
            {
                Caption = 'Adjustment';
                field("Posting Date"; PostingDate)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Posting Date';
                    ToolTip = 'Specifies the posting date applied to all created adjustment entries.';
                }
                field("Document Type"; DocumentType)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Document Type';
                    ToolTip = 'Specifies the document type applied to all created adjustment entries.';
                }
                field("Document No."; DocumentNo)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Document No.';
                    ToolTip = 'Specifies the document number applied to all created adjustment entries.';
                }
                field(Description; AdjustmentDescription)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Description';
                    ToolTip = 'Specifies a description applied to all created adjustment entries.';
                }
            }
            group("Production Order")
            {
                Caption = 'Production Order';
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the item number.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the variant code.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the unit of measure code.';
                }
                field("Prod. Order Status"; Rec."Prod. Order Status")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the production order status.';
                }
                field("Prod. Order No."; Rec."Prod. Order No.")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the production order number.';
                }
                field("Prod. Order Line No."; Rec."Prod. Order Line No.")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the production order line number.';
                }
                field("Routing No."; Rec."Routing No.")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the routing number.';
                }
            }
            group(General)
            {
                Caption = 'General';
                Visible = LineCount = 1;
                field("Routing Reference No."; Rec."Routing Reference No.")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the routing reference number identifying the prod. order routing line.';
                }
                field("Operation No."; Rec."Operation No.")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the operation number.';
                }
                field("Work Center No."; Rec."Work Center No.")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the work center number.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the location code.';
                }
                field("Current Quantity"; Rec."Quantity (Base)")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Current Quantity';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    ToolTip = 'Specifies the current WIP quantity for this operation and location.';
                }
                field("New Quantity"; NewQuantity)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'New Quantity';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies the new target WIP quantity after adjustment.';

                    trigger OnValidate()
                    begin
                        NewQuantities.Set(Rec."Entry No.", NewQuantity);
                        UpdateQuantityStyle();
                    end;
                }
                field("Quantity to Adjust"; QuantityToAdjust)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Quantity to Adjust';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    StyleExpr = QuantityStyle;
                    ToolTip = 'Specifies the quantity that will be adjusted (New Quantity minus Current Quantity).';
                }
            }
            repeater(Lines)
            {
                Caption = 'Lines';
                Visible = LineCount > 1;
                field("Routing Reference No. Line"; Rec."Routing Reference No.")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Routing Reference No.';
                    Editable = false;
                    ToolTip = 'Specifies the routing reference number identifying the prod. order routing line.';
                }
                field("Operation No. Line"; Rec."Operation No.")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Operation No.';
                    Editable = false;
                    ToolTip = 'Specifies the operation number.';
                }
                field("Work Center No. Line"; Rec."Work Center No.")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Work Center No.';
                    Editable = false;
                    ToolTip = 'Specifies the work center number.';
                }
                field("Location Code Line"; Rec."Location Code")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Location Code';
                    Editable = false;
                    ToolTip = 'Specifies the location code.';
                }
                field("Current Quantity Line"; Rec."Quantity (Base)")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Current Quantity';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    ToolTip = 'Specifies the current WIP quantity for this operation and location.';
                }
                field("New Quantity Line"; NewQuantity)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'New Quantity';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies the new target WIP quantity after adjustment.';

                    trigger OnValidate()
                    begin
                        NewQuantities.Set(Rec."Entry No.", NewQuantity);
                        UpdateQuantityStyle();
                    end;
                }
                field("Quantity to Adjust Line"; QuantityToAdjust)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Quantity to Adjust';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    StyleExpr = QuantityStyle;
                    ToolTip = 'Specifies the quantity that will be adjusted (New Quantity minus Current Quantity).';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        NewQuantities.Get(Rec."Entry No.", NewQuantity);
        UpdateQuantityStyle();
    end;

    trigger OnOpenPage()
    begin
        PostingDate := WorkDate();
        DocumentType := DocumentType::"Adjustment (Manual)";
        if Rec.FindFirst() then;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction in [ACTION::OK, ACTION::LookupOK] then
            CreateAdjustmentEntries();
        exit(true);
    end;

    var
        NewQuantities: Dictionary of [BigInteger, Decimal];
        PostingDate: Date;
        DocumentType: Enum "WIP Document Type";
        DocumentNo: Code[20];
        AdjustmentDescription: Text[100];
        NewQuantity: Decimal;
        QuantityToAdjust: Decimal;
        QuantityStyle: Text;
        LineCount: Integer;

    /// <summary>
    /// Populates the page source table with one row per (Routing Reference No., Operation No., Location Code)
    /// combination, aggregating the current WIP quantity from the supplied ledger entries.
    /// Must be called before running the page.
    /// </summary>
    procedure SetWIPLedgerEntry(var WIPLedgerEntry: Record "Subcontractor WIP Ledger Entry")
    var
        TempBuffer: Record "Subcontractor WIP Ledger Entry" temporary;
        NothingToAdjustErr: Label 'There are no WIP quantities to adjust, because there are no existing ledger entries for the specified source.';
        EntrySeq: BigInteger;
    begin
        EntrySeq := 1;
        if not WIPLedgerEntry.FindSet() then
            Error(NothingToAdjustErr);

        repeat
            TempBuffer.SetRange("Prod. Order Status", WIPLedgerEntry."Prod. Order Status");
            TempBuffer.SetRange("Prod. Order No.", WIPLedgerEntry."Prod. Order No.");
            TempBuffer.SetRange("Prod. Order Line No.", WIPLedgerEntry."Prod. Order Line No.");
            TempBuffer.SetRange("Routing Reference No.", WIPLedgerEntry."Routing Reference No.");
            TempBuffer.SetRange("Routing No.", WIPLedgerEntry."Routing No.");
            TempBuffer.SetRange("Operation No.", WIPLedgerEntry."Operation No.");
            TempBuffer.SetRange("Location Code", WIPLedgerEntry."Location Code");
            if TempBuffer.FindFirst() then begin
                TempBuffer."Quantity (Base)" += WIPLedgerEntry."Quantity (Base)";
                TempBuffer.Modify();
            end else begin
                TempBuffer.Reset();
                TempBuffer.Init();
                TempBuffer.TransferFields(WIPLedgerEntry);
                TempBuffer."Entry No." := EntrySeq;
                TempBuffer."Quantity (Base)" := WIPLedgerEntry."Quantity (Base)";
                TempBuffer.Insert();
                EntrySeq += 1;
            end;
        until WIPLedgerEntry.Next() = 0;

        TempBuffer.Reset();
        if TempBuffer.FindSet() then
            repeat
                Rec := TempBuffer;
                Rec.Insert();
                NewQuantities.Add(Rec."Entry No.", Rec."Quantity (Base)");
            until TempBuffer.Next() = 0;


        LineCount := Rec.Count();
        if Rec.FindFirst() then;
    end;

    local procedure CreateAdjustmentEntries()
    var
        WIPLedgerEntry: Record "Subcontractor WIP Ledger Entry";
        AdjEntryType: Enum "WIP Ledger Entry Type";
        NextEntryNo: BigInteger;
        TargetQty: Decimal;
    begin
        if WIPLedgerEntry.FindLast() then
            NextEntryNo := WIPLedgerEntry."Entry No." + 1
        else
            NextEntryNo := 1;

        if not Rec.FindSet() then
            exit;

        repeat
            NewQuantities.Get(Rec."Entry No.", TargetQty);
            if TargetQty <> Rec."Quantity (Base)" then begin
                WIPLedgerEntry.Init();
                WIPLedgerEntry.TransferFields(Rec);
                WIPLedgerEntry."Entry No." := NextEntryNo;
                WIPLedgerEntry."Posting Date" := PostingDate;
                WIPLedgerEntry."Document Type" := DocumentType;
                WIPLedgerEntry."Document No." := DocumentNo;
                WIPLedgerEntry.Description := CopyStr(AdjustmentDescription, 1, MaxStrLen(WIPLedgerEntry.Description));
                WIPLedgerEntry."Quantity (Base)" := TargetQty - Rec."Quantity (Base)";
                if WIPLedgerEntry."Quantity (Base)" >= 0 then
                    WIPLedgerEntry."Entry Type" := AdjEntryType::"Positive Adjustment"
                else
                    WIPLedgerEntry."Entry Type" := AdjEntryType::"Negative Adjustment";
                WIPLedgerEntry.Insert(true);
                NextEntryNo += 1;
            end;
        until Rec.Next() = 0;
    end;

    local procedure UpdateQuantityStyle()
    begin
        QuantityToAdjust := NewQuantity - Rec."Quantity (Base)";
        if QuantityToAdjust >= 0 then
            QuantityStyle := 'Strong'
        else
            QuantityStyle := 'Unfavorable';
    end;
}