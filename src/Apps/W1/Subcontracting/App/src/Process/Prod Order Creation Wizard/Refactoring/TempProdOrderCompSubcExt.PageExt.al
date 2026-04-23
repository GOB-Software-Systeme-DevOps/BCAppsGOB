// ------------------------------------------------------------------------------------------------
// Copyright (c) GOB Software Systeme GmbH. All rights reserved.
// ------------------------------------------------------------------------------------------------
namespace MS.Subcontracting;

using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.Subcontracting;
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

                trigger OnValidate()
                begin
                    if Rec."Subcontracting Type" = Rec."Subcontracting Type"::Purchase then
                        Rec.FieldError("Subcontracting Type");

                    if (Rec."Routing Link Code" = '') and (Rec."Subcontracting Type" <> Rec."Subcontracting Type"::Empty) then begin
                        GetSubManagementSetup();
                        Rec."Routing Link Code" := SubManagementSetup."Rtng. Link Code Purch. Prov.";
                    end;

                    if Rec."Subcontracting Type" = Rec."Subcontracting Type"::Transfer then
                        Rec.Validate("Location Code", Rec."Orig. Location Code")
                    else
                        OnAfterSubcontractingTypeChangedToNonTransfer(Rec);
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Subcontracting Type" := xRec."Subcontracting Type";
        Rec."Orig. Location Code" := xRec."Orig. Location Code";
        GetSubManagementSetup();
        Rec."Routing Link Code" := SubManagementSetup."Rtng. Link Code Purch. Prov.";
    end;

    var
        SubManagementSetup: Record "Subc. Management Setup";
        SubManagementSetupRead: Boolean;

    local procedure GetSubManagementSetup()
    begin
        if not SubManagementSetupRead then begin
            SubManagementSetup.SetLoadFields("Rtng. Link Code Purch. Prov.");
            SubManagementSetup.Get();
            SubManagementSetupRead := true;
        end;
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterSubcontractingTypeChangedToNonTransfer(var ProdOrderComponent: Record "Prod. Order Component")
    begin
    end;
}