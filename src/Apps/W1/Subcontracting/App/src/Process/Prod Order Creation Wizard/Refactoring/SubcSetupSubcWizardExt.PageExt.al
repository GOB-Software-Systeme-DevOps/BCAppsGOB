// ------------------------------------------------------------------------------------------------
// Copyright (c) GOB Software Systeme GmbH. All rights reserved.
// ------------------------------------------------------------------------------------------------
namespace MS.Subcontracting;

using Microsoft.Manufacturing.Setup;

pageextension 99001567 "Subc. Setup Subc. Wizard Ext" extends "Manufacturing Setup"
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
            field("Rtng. Link Code Purch. Prov."; Rec."Rtng. Link Code Purch. Prov.")
            {
                ApplicationArea = Manufacturing;
                ToolTip = 'Specifies the routing link code used to connect purchase provision components to their routing operation.';
            }
        }
    }
}