// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.Subcontracting;

page 99001560 "WIP Ledger Entries"
{
    ApplicationArea = Manufacturing;
    Caption = 'WIP Ledger Entries';
    Editable = false;
    PageType = List;
    SourceTable = "Subcontractor WIP Ledger Entry";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                }
                field("Posting Date"; Rec."Posting Date")
                {
                }
                field("Entry Type"; Rec."Entry Type")
                {
                }
                field("Document Type"; Rec."Document Type")
                {
                }
                field("Document No."; Rec."Document No.")
                {
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                }
                field("Item No."; Rec."Item No.")
                {
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    Visible = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                }
                field("Prod. Order Status"; Rec."Prod. Order Status")
                {
                }
                field("Prod. Order No."; Rec."Prod. Order No.")
                {
                }
                field("Prod. Order Line No."; Rec."Prod. Order Line No.")
                {
                }
                field("Routing No."; Rec."Routing No.")
                {
                }
                field("Operation No."; Rec."Operation No.")
                {
                }
                field("Work Center No."; Rec."Work Center No.")
                {
                }
                field(Description; Rec.Description)
                {
                }
                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                }
            }
        }
        area(factboxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }
}
