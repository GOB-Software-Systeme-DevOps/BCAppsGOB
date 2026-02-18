// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.Subcontracting;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.Routing;
using Microsoft.Manufacturing.WorkCenter;

table 99001560 "Subcontractor WIP Ledger Entry"
{
    AllowInCustomizations = AsReadOnly;
    Caption = 'Subcontractor WIP Ledger Entry';
    DataClassification = CustomerContent;
    DrillDownPageId = "WIP Ledger Entries";
    LookupPageId = "WIP Ledger Entries";

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the entry number.';
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
            ToolTip = 'Specifies the item number.';
        }
        field(3; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Variant".Code where("Item No." = field("Item No."));
            ToolTip = 'Specifies the variant code.';
        }
        field(4; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
            ToolTip = 'Specifies the location code.';
        }
        field(5; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the posting date of the entry.';
        }
        field(6; "Entry Type"; Enum "WIP Ledger Entry Type")
        {
            Caption = 'Entry Type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the type of entry: Positive or Negative Adjustment.';
        }
        field(7; "Quantity (Base)"; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Quantity (Base)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            ToolTip = 'Specifies the quantity in base unit of measure.';
        }
        field(8; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("Item No."));
            ToolTip = 'Specifies the unit of measure code.';
        }
        field(9; "Document Type"; Enum "WIP Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the document type that created this entry.';
        }
        field(10; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the document number.';
        }
        field(11; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the document line number.';
        }
        field(12; "Prod. Order Status"; Enum "Production Order Status")
        {
            Caption = 'Prod. Order Status';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the production order status.';
        }
        field(13; "Prod. Order No."; Code[20])
        {
            Caption = 'Prod. Order No.';
            DataClassification = CustomerContent;
            TableRelation = "Production Order"."No." where(Status = field("Prod. Order Status"));
            ToolTip = 'Specifies the production order number.';
        }
        field(14; "Prod. Order Line No."; Integer)
        {
            Caption = 'Prod. Order Line No.';
            DataClassification = CustomerContent;
            TableRelation = "Prod. Order Line"."Line No." where(Status = field("Prod. Order Status"),
                                                                 "Prod. Order No." = field("Prod. Order No."));
            ToolTip = 'Specifies the production order line number.';
        }
        field(15; "Routing No."; Code[20])
        {
            Caption = 'Routing No.';
            DataClassification = CustomerContent;
            TableRelation = "Routing Header";
            ToolTip = 'Specifies the routing number.';
        }
        field(17; "Operation No."; Code[10])
        {
            Caption = 'Operation No.';
            DataClassification = CustomerContent;
            TableRelation = "Prod. Order Routing Line"."Operation No." where(Status = field("Prod. Order Status"),
                                                                              "Prod. Order No." = field("Prod. Order No."),
                                                                              "Routing No." = field("Routing No."));
            ToolTip = 'Specifies the operation number.';
        }
        field(18; "Work Center No."; Code[20])
        {
            Caption = 'Work Center No.';
            DataClassification = CustomerContent;
            TableRelation = "Work Center";
            ToolTip = 'Specifies the work center number.';
        }
        field(19; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the description.';
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Item No.", "Variant Code", "Location Code")
        {
            IncludedFields = "Quantity (Base)";
        }
        key(Key3; "Prod. Order Status", "Prod. Order No.", "Prod. Order Line No.", "Routing No.", "Operation No.")
        {
            IncludedFields = "Quantity (Base)";
        }
    }
}
