// ------------------------------------------------------------------------------------------------
// Copyright (c) GOB Software Systeme GmbH. All rights reserved.
// ------------------------------------------------------------------------------------------------
namespace MS.Subcontracting;

using Microsoft.Manufacturing.Wizard;

pageextension 99001564 TempProdOrderCompSubcExt extends "Temp Prod. Order Comp. List"
{
    layout
    {
        addafter("Item No.")
        {
            field(SubcontractingType; Rec."Subcontracting Type")
            {
                ApplicationArea = Manufacturing;
                Caption = 'Subcontracting Type';
                ToolTip = 'Specifies the subcontracting type for this production order component.';
            }
        }
    }
}