// ------------------------------------------------------------------------------------------------
// Copyright (c) GOB Software Systeme GmbH. All rights reserved.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.Subcontracting;

using Microsoft.Manufacturing.Wizard;

pageextension 99001565 TempProdOrdRtngListSubcExt extends "Temp Prod. Ord. Rtng List"
{
    layout
    {
        addafter("No.")
        {
            field(VendorNoSubcPrice; Rec."Vendor No. Subc. Price")
            {
                ApplicationArea = Manufacturing;
                Caption = 'Vendor No. (Subc. Price)';
                ToolTip = 'Specifies the vendor number used to look up the subcontracting price for this routing operation.';
            }
        }
    }
}