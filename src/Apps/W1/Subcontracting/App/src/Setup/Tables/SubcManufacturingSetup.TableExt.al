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

tableextension 99001501 "Subc. Manufacturing Setup" extends "Manufacturing Setup"
{
    fields
    {
        field(99001500; "Create Prod. Order Info Line"; Boolean)
        {
            Caption = 'Create Prod. Order Info Line';
            DataClassification = CustomerContent;
        }
        field(99001501; "Subcontracting Template Name"; Code[10])
        {
            Caption = 'Subcontracting Journal Template Name';
            DataClassification = CustomerContent;
#pragma warning disable AL0432
#pragma warning disable AL0520
            TableRelation = "Req. Wksh. Template" where(Type = const(Subcontracting));
#pragma warning restore AL0432
#pragma warning restore AL0520
        }
        field(99001502; "Subcontracting Batch Name"; Code[10])
        {
            Caption = 'Subcontracting Journal Batch Name';
            DataClassification = CustomerContent;
#pragma warning disable AL0432
#pragma warning disable AL0520
            TableRelation = "Requisition Wksh. Name".Name where("Template Type" = const(Subcontracting),
                                                                "Worksheet Template Name" = field("Subcontracting Template Name"));
#pragma warning restore AL0432
#pragma warning restore AL0520
        }
        field(99001503; "Direct Transfer"; Boolean)
        {
            Caption = 'Direct Transfer for Subcontracting';
            DataClassification = CustomerContent;
        }
        field(99001504; "Component Direct Unit Cost"; Option)
        {
            Caption = 'Component Direct Unit Cost';
            DataClassification = CustomerContent;
            OptionCaption = 'Standard,Prod. Order Component';
            OptionMembers = Standard,"Prod. Order Component";
        }
        field(99001505; "Subc. Inb. Whse. Handling Time"; DateFormula)
        {
            Caption = 'Subcontracting Inbound Whse. Handling Time';
            DataClassification = CustomerContent;
        }
        field(99001506; "Rtng. Link Code Purch. Prov."; Code[10])
        {
            Caption = 'Routing Link Code Purchase Provision';
            DataClassification = CustomerContent;
            TableRelation = "Routing Link";
        }
        field(99001509; "Subc. Comp. at Location"; Enum "Components at Location")
        {
            Caption = 'Component at Location';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                CompanyInformation: Record "Company Information";
                ManufacturingSetup: Record "Manufacturing Setup";
            begin
                case "Subc. Comp. at Location" of
                    "Subc. Comp. at Location"::Company:
                        begin
                            CompanyInformation.Get();
                            CompanyInformation.TestField("Location Code");
                        end;
                    "Subc. Comp. at Location"::Manufacturing:
                        begin
                            ManufacturingSetup.Get();
                            ManufacturingSetup.TestField("Components at Location");
                        end;
                end;
            end;
        }
        field(99001510; RefItemChargeToRcptSubLines; Boolean)
        {
            Caption = 'Item Charge to Subcontracting Purch. Receipt Lines';
            DataClassification = CustomerContent;
        }
        field(99001566; "Put-Away Work Center No."; Code[20])
        {
            Caption = 'Put-Away Work Center No.';
            DataClassification = CustomerContent;
            TableRelation = "Work Center";
            ToolTip = 'Specifies the work center used for the subcontracting put-away routing operation.';
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