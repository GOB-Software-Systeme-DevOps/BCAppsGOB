// ------------------------------------------------------------------------------------------------
// Copyright (c) GOB Software Systeme GmbH. All rights reserved.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.Subcontracting;

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
        }
        addlast(General)
        {
            group(SubcontractingGroup)
            {
                Caption = 'Subcontracting';
                field("Create Prod. Order Info Line"; Rec."Create Prod. Order Info Line")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies whether an additional Information Line of the Production Order Line will be created in a Subcontracting Purchase Order.';
                }
                field("Subc. Inb. Whse. Handling Time"; Rec."Subc. Inb. Whse. Handling Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the time to calculate the Receipt Date in Transfer Line. The Calculation will be Due Date from Prod. Order Component minus the entered date formula.';
                }
                field("Subcontracting Template Name"; Rec."Subcontracting Template Name")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the name of the subcontracting journal template to be used for the direct creation of subcontracting orders from a released routing.';
                }
                field("Subcontracting Batch Name"; Rec."Subcontracting Batch Name")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the name of the subcontracting journal batch to be used for the direct creation of subcontracting orders from a released routing.';
                }
                field("Component Direct Unit Cost"; Rec."Component Direct Unit Cost")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies which Direct Unit Cost of a Prod. Order Component is to be used in the subcontracting purchase order.';
                }
                field(RefSubItemChargeToRcptSubLines; Rec.RefItemChargeToRcptSubLines)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies whether to enable the item charge assignment to purchase receipt lines with subcontracting.';
                }
            }
            group(PurchaseProvisionGroup)
            {
                Caption = 'Purchase Provision';
                field("Rtng. Link Code Purch. Prov."; Rec."Rtng. Link Code Purch. Prov.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the routing link code used to connect purchase provision components to their routing operation.';
                }
                field("Direct Transfer"; Rec."Direct Transfer")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies that the transfer for subcontracting components does not use an in-transit location.';
                }
                field("Component at Location"; Rec."Component at Location")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies which location code is to be used as the transfer-from location when creating a transfer order of external production components.';
                }
            }
        }
    }
}