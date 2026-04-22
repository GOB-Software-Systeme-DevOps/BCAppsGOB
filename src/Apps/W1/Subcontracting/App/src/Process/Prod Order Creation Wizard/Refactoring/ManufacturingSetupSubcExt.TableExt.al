// ------------------------------------------------------------------------------------------------
// Copyright (c) GOB Software Systeme GmbH. All rights reserved.
// ------------------------------------------------------------------------------------------------
namespace MS.Subcontracting;

using Microsoft.Manufacturing.Setup;
using Microsoft.Manufacturing.WorkCenter;

tableextension 99001566 "Mfg. Setup Subc. Wizard Ext" extends "Manufacturing Setup"
{
    fields
    {
        field(99001019; "Put-Away Work Center No."; Code[20])
        {
            Caption = 'Put-Away Work Center No.';
            DataClassification = CustomerContent;
            TableRelation = "Work Center";
            ToolTip = 'Specifies the work center used for the subcontracting put-away routing operation.';
        }
    }
}
