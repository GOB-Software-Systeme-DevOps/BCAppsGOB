// ------------------------------------------------------------------------------------------------
// Copyright (c) GOB Software Systeme GmbH. All rights reserved.
// ------------------------------------------------------------------------------------------------
namespace MS.Subcontracting;

using Microsoft.Manufacturing.Wizard;

pageextension 99001563 TempBOMLineSubcExt extends "Temp BOM Lines"
{
    layout
    {
        addafter("No.")
        {
            field(SubcontractingType; Rec."Subcontracting Type")
            {
                ApplicationArea = Manufacturing;
                Caption = 'Subcontracting Type';
                ToolTip = 'Specifies the subcontracting type for this BOM component.';
            }
        }
    }
}