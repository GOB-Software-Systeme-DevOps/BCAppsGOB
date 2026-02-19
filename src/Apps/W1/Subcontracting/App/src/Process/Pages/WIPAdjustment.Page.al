// // ------------------------------------------------------------------------------------------------
// // Copyright (c) Microsoft Corporation. All rights reserved.
// // Licensed under the MIT License. See License.txt in the project root for license information.
// // ------------------------------------------------------------------------------------------------
// namespace Microsoft.Manufacturing.Subcontracting;

// using Microsoft.Inventory.Location;

// page 99001561 "WIP Adjustment"
// {
//     ApplicationArea = Manufacturing;
//     Caption = 'WIP Adjustment';
//     PageType = StandardDialog;
//     SourceTable = Location;
//     SourceTableTemporary = true;
//     DeleteAllowed = false;
//     InsertAllowed = false;

//     layout
//     {
//         area(Content)
//         {
//             group(General)
//             {
//                 Caption = 'General';
//                 Visible = LocationCount <= 1;
//                 field("Posting Date"; TempWIPLedgerEntry."Posting Date")
//                 {
//                     ApplicationArea = Manufacturing;
//                     ToolTip = 'Specifies the posting date for the adjustment.';
//                 }
//                 field("Entry Type"; TempWIPLedgerEntry."Entry Type")
//                 {
//                     ApplicationArea = Manufacturing;
//                     ToolTip = ''Specifies which type of transaction that the entry is created from.'';
//                 }
//                 field("Document Type"; TempWIPLedgerEntry."Document Type")
//                 {
//                     ApplicationArea = Manufacturing;
//                     ToolTip = 'Specifies the type of document that created this WIP adjustment entry.';
//                 }
//                 field("Document No."; TempWIPLedgerEntry."Document No.")
//                 {
//                     ApplicationArea = Manufacturing;
//                     ToolTip = 'Specifies the document number.';
//                 }
//                 field("Document Line No."; TempWIPLedgerEntry."Document Line No.")
//                 {
//                     ApplicationArea = Manufacturing;
//                     ToolTip = 'Specifies the line number of the document associated with this WIP adjustment.';
//                 }
//                 field("Item No."; TempWIPLedgerEntry."Item No.")
//                 {
//                     ApplicationArea = Manufacturing;
//                     Editable = false;
//                     ToolTip = 'Specifies the item number.';
//                 }
//                 field("Variant Code"; TempWIPLedgerEntry."Variant Code")
//                 {
//                     ApplicationArea = Manufacturing;
//                     Editable = false;
//                     ToolTip = 'Specifies the variant code.';
//                 }
//                 field("Unit of Measure Code"; TempWIPLedgerEntry."Unit of Measure Code")
//                 {
//                     ApplicationArea = Manufacturing;
//                     Editable = false;
//                     ToolTip = 'Specifies the unit of measure code.';
//                 }
//                 field("Current Quantity"; CurrentQuantity)
//                 {
//                     ApplicationArea = Manufacturing;
//                     Caption = 'Current Quantity';
//                     DecimalPlaces = 0 : 5;
//                     Editable = false;
//                     ToolTip = 'Specifies the current WIP quantity.';
//                 }
//                 field("New Quantity"; NewQuantity)
//                 {
//                     ApplicationArea = Manufacturing;
//                     Caption = 'New Quantity';
//                     DecimalPlaces = 0 : 5;
//                     ToolTip = 'Specifies the new WIP quantity after adjustment.';

//                     trigger OnValidate()
//                     begin
//                         UpdateQuantityToAdjust();
//                     end;
//                 }
//                 field("Quantity to Adjust"; QuantityToAdjust)
//                 {
//                     ApplicationArea = Manufacturing;
//                     Caption = 'Quantity to Adjust';
//                     DecimalPlaces = 0 : 5;
//                     Editable = false;
//                     StyleExpr = QuantityStyle;
//                     ToolTip = 'Specifies the quantity that will be adjusted.';
//                 }
//                 field(Description; TempWIPLedgerEntry.Description)
//                 {
//                     ApplicationArea = Manufacturing;
//                     Editable = false;
//                     ToolTip = 'Specifies the description.';
//                 }
//             }
//             repeater(Control5)
//             {
//                 ShowCaption = false;
//                 Visible = LocationCount > 1;
//                 field("Location Code"; Rec.Code)
//                 {
//                     ApplicationArea = Location;
//                     Caption = 'Location Code';
//                     Editable = false;
//                     ToolTip = 'Specifies the location code.';
//                 }
//                 field("Location Name"; Rec.Name)
//                 {
//                     ApplicationArea = Location;
//                     Caption = 'Location Name';
//                     Editable = false;
//                     ToolTip = 'Specifies the location name.';
//                 }
//                 field("Current Quantity Location"; CurrentQuantity)
//                 {
//                     ApplicationArea = Manufacturing;
//                     Caption = 'Current Quantity';
//                     DecimalPlaces = 0 : 5;
//                     Editable = false;
//                     ToolTip = 'Specifies the current WIP quantity at this location.';
//                 }
//                 field("New Quantity Location"; NewQuantity)
//                 {
//                     ApplicationArea = Manufacturing;
//                     Caption = 'New Quantity';
//                     DecimalPlaces = 0 : 5;
//                     ToolTip = 'Specifies the new WIP quantity after adjustment.';

//                     trigger OnValidate()
//                     begin
//                         UpdateQuantityToAdjust();
//                     end;
//                 }
//                 field("Quantity to Adjust Location"; QuantityToAdjust)
//                 {
//                     ApplicationArea = Manufacturing;
//                     Caption = 'Quantity to Adjust';
//                     DecimalPlaces = 0 : 5;
//                     Editable = false;
//                     StyleExpr = QuantityStyle;
//                     ToolTip = 'Specifies the quantity that will be adjusted.';
//                 }
//             }
//             group("Production Order")
//             {
//                 Caption = 'Production Order';
//                 Visible = LocationCount <= 1;
//                 field("Prod. Order Status"; TempWIPLedgerEntry."Prod. Order Status")
//                 {
//                     ApplicationArea = Manufacturing;
//                     Editable = false;
//                     ToolTip = 'Specifies the production order status.';
//                 }
//                 field("Prod. Order No."; TempWIPLedgerEntry."Prod. Order No.")
//                 {
//                     ApplicationArea = Manufacturing;
//                     Editable = false;
//                     ToolTip = 'Specifies the production order number.';
//                 }
//                 field("Prod. Order Line No."; TempWIPLedgerEntry."Prod. Order Line No.")
//                 {
//                     ApplicationArea = Manufacturing;
//                     Editable = false;
//                     ToolTip = 'Specifies the production order line number.';
//                 }
//                 field("Routing No."; TempWIPLedgerEntry."Routing No.")
//                 {
//                     ApplicationArea = Manufacturing;
//                     Editable = false;
//                     ToolTip = 'Specifies the routing number.';
//                 }
//                 field("Operation No."; TempWIPLedgerEntry."Operation No.")
//                 {
//                     ApplicationArea = Manufacturing;
//                     Editable = false;
//                     ToolTip = 'Specifies the operation number.';
//                 }
//                 field("Work Center No."; TempWIPLedgerEntry."Work Center No.")
//                 {
//                     ApplicationArea = Manufacturing;
//                     Editable = false;
//                     ToolTip = 'Specifies the work center number.';
//                 }
//             }
//         }
//     }

//     trigger OnAfterGetRecord()
//     begin
//         TempWIPLedgerEntry.SetRange("Location Code", Rec.Code);
//         if TempWIPLedgerEntry.FindFirst() then begin
//             CurrentQuantity := TempWIPLedgerEntry."Quantity (Base)";
//             NewQuantity := TempWIPLedgerEntry."Quantity (Base)";
//             UpdateQuantityToAdjust();
//         end;
//     end;

//     trigger OnOpenPage()
//     begin
//         LocationCount := 1;
//         if Rec.FindFirst() then;

//         UpdateQuantityToAdjust();
//     end;

//     trigger OnQueryClosePage(CloseAction: Action): Boolean
//     begin
//         if CloseAction in [ACTION::OK, ACTION::LookupOK] then begin
//             // Post adjustments logic would go here
//             // This would typically call a codeunit to process the adjustments
//         end;
//     end;

//     protected var
//         TempWIPLedgerEntry: Record "Subcontractor WIP Ledger Entry" temporary;
//         LocationCount: Integer;
//         CurrentQuantity: Decimal;
//         NewQuantity: Decimal;
//         QuantityToAdjust: Decimal;
//         QuantityStyle: Text;

//     procedure SetWIPLedgerEntry(var WIPLedgerEntry: Record "Subcontractor WIP Ledger Entry")
//     begin
//         TempWIPLedgerEntry.Copy(WIPLedgerEntry, true);
//         CurrentQuantity := TempWIPLedgerEntry."Quantity (Base)";
//         NewQuantity := TempWIPLedgerEntry."Quantity (Base)";
//         if WIPLedgerEntry.FindSet() then
//             repeat
//                 Rec.Init();
//                 Rec.Code := WIPLedgerEntry."Location Code";
//                 if Rec.Get(WIPLedgerEntry."Location Code") then
//                     Rec.Name := Rec.Name;
//                 if not Rec.Insert() then;
//             until WIPLedgerEntry.Next() = 0;

//         LocationCount := Rec.Count();
//         if Rec.FindFirst() then;
//     end;

//     procedure GetNewQuantity(): Decimal
//     begin
//         exit(NewQuantity);
//     end;

//     procedure GetQuantityToAdjust(): Decimal
//     begin
//         exit(QuantityToAdjust);
//     end;

//     local procedure UpdateQuantityToAdjust()
//     begin
//         QuantityToAdjust := NewQuantity - CurrentQuantity;
//         if QuantityToAdjust >= 0 then
//             QuantityStyle := 'Strong'
//         else
//             QuantityStyle := 'Unfavorable';
//     end;
// }
