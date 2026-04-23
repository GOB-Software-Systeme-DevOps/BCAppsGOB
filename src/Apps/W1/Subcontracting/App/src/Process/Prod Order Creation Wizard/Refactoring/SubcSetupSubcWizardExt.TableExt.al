// ------------------------------------------------------------------------------------------------
// Copyright (c) GOB Software Systeme GmbH. All rights reserved.
// ------------------------------------------------------------------------------------------------
namespace MS.Subcontracting;

using Microsoft.Manufacturing.Routing;
using Microsoft.Manufacturing.Setup;
using Microsoft.Manufacturing.WorkCenter;

tableextension 99001566 "Subc. Setup Subc. Wizard Ext" extends "Manufacturing Setup"
{
    fields
    {
        field(99001566; "Put-Away Work Center No."; Code[20])
        {
            Caption = 'Put-Away Work Center No.';
            DataClassification = CustomerContent;
            TableRelation = "Work Center";
            ToolTip = 'Specifies the work center used for the subcontracting put-away routing operation.';
        }
        field(99001567; "Rtng. Link Code Purch. Prov."; Code[10])
        {
            Caption = 'Rtng. Link Code Purch. Prov.';
            DataClassification = CustomerContent;
            TableRelation = "Routing Link";
            ToolTip = 'Specifies the routing link code used to connect purchase provision components to their routing operation.';
        }
    }
}