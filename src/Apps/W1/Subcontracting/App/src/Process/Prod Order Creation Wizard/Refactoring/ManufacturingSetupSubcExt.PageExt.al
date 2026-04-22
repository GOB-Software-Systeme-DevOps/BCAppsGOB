// ------------------------------------------------------------------------------------------------
// Copyright (c) GOB Software Systeme GmbH. All rights reserved.
// ------------------------------------------------------------------------------------------------
namespace MS.Subcontracting;

using Microsoft.Manufacturing.Setup;

pageextension 99001567 "Mfg. Setup Subc. Wizard Ext" extends "Manufacturing Setup"
{
    layout
    {
        addlast(WizardDefaults)
        {
            field("Put-Away Work Center No."; Rec."Put-Away Work Center No.")
            {
                ApplicationArea = Manufacturing;
                ToolTip = 'Specifies the work center used for the subcontracting put-away routing operation.';
            }
        }
    }
}
