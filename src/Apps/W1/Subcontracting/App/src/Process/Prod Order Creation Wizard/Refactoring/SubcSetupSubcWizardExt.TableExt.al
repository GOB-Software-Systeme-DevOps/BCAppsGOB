// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.Subcontracting;

using Microsoft.Foundation.Company;
using Microsoft.Inventory.Requisition;
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
            Caption = 'Routing Link Code Purchase Provision';
            DataClassification = CustomerContent;
            TableRelation = "Routing Link";
            ToolTip = 'Specifies the routing link code used to connect purchase provision components to their routing operation.';
        }
        field(99001568; "Create Prod. Order Info Line"; Boolean)
        {
            Caption = 'Create Prod. Order Info Line';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether an additional Information Line of the Production Order Line will be created in a Subcontracting Purchase Order.';
        }
        field(99001569; "Subcontracting Template Name"; Code[10])
        {
            Caption = 'Subcontracting Journal Template Name';
            DataClassification = CustomerContent;
            TableRelation = "Req. Wksh. Template" where(Type = const(Subcontracting));
            ToolTip = 'Specifies the name of the subcontracting journal template to be used for the direct creation of subcontracting orders from a released routing.';
        }
        field(99001570; "Subcontracting Batch Name"; Code[10])
        {
            Caption = 'Subcontracting Journal Batch Name';
            DataClassification = CustomerContent;
            TableRelation = "Requisition Wksh. Name".Name where("Template Type" = const(Subcontracting),
                                                                "Worksheet Template Name" = field("Subcontracting Template Name"));
            ToolTip = 'Specifies the name of the subcontracting journal batch to be used for the direct creation of subcontracting orders from a released routing.';
        }
        field(99001571; "Direct Transfer"; Boolean)
        {
            Caption = 'Direct Transfer for Subcontracting';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies that the transfer for subcontracting components does not use an in-transit location.';
        }
        field(99001572; "Component Direct Unit Cost"; Option)
        {
            Caption = 'Component Direct Unit Cost';
            DataClassification = CustomerContent;
            OptionCaption = 'Standard,Prod. Order Component';
            OptionMembers = Standard,"Prod. Order Component";
            ToolTip = 'Specifies which Direct Unit Cost of a Prod. Order Component is to be used in the subcontracting purchase order.';
        }
        field(99001573; "Subc. Inb. Whse. Handling Time"; DateFormula)
        {
            Caption = 'Subcontracting Inbound Whse. Handling Time';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the time to calculate the Receipt Date in Transfer Line.';
        }
        field(99001574; "Component at Location"; Enum "Components at Location")
        {
            Caption = 'Component at Location';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies which location code is to be used as the transfer-from location when creating a transfer order of external production components.';
            trigger OnValidate()
            var
                CompanyInformation: Record "Company Information";
            begin
                case "Component at Location" of
                    Enum::"Components at Location"::Company:
                        begin
                            CompanyInformation.Get();
                            CompanyInformation.TestField("Location Code");
                        end;
                    Enum::"Components at Location"::Manufacturing:
                        TestField("Components at Location");
                end;
            end;
        }
        field(99001575; RefItemChargeToRcptSubLines; Boolean)
        {
            Caption = 'Item Charge to Subcontracting Purch. Receipt Lines';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether to enable the item charge assignment to purchase receipt lines with subcontracting.';
        }
    }

    procedure ItemChargeToRcptSubReferenceEnabled(): Boolean
    var
        ManufacturingSetup: Record "Manufacturing Setup";
    begin
        ManufacturingSetup.SetLoadFields(RefItemChargeToRcptSubLines);
        if not ManufacturingSetup.Get() then
            exit(false);

        exit(ManufacturingSetup.RefItemChargeToRcptSubLines);
    end;
}