// ------------------------------------------------------------------------------------------------
// Copyright (c) GOB Software Systeme GmbH. All rights reserved.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.Subcontracting;

using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.Setup;
using Microsoft.Manufacturing.Wizard;

pageextension 99001564 TempProdOrderCompSubcExt extends "Temp Prod. Order Comp. List"
{
    layout
    {
        addafter("Location Code")
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
                        GetManufacturingSetup();
                        Rec."Routing Link Code" := ManufacturingSetup."Rtng. Link Code Purch. Prov.";
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
        GetManufacturingSetup();
        Rec."Routing Link Code" := ManufacturingSetup."Rtng. Link Code Purch. Prov.";
    end;

    var
        ManufacturingSetup: Record "Manufacturing Setup";
        ManufacturingSetupRead: Boolean;

    local procedure GetManufacturingSetup()
    begin
        if not ManufacturingSetupRead then begin
            ManufacturingSetup.SetLoadFields("Rtng. Link Code Purch. Prov.");
            ManufacturingSetup.Get();
            ManufacturingSetupRead := true;
        end;
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterSubcontractingTypeChangedToNonTransfer(var ProdOrderComponent: Record "Prod. Order Component")
    begin
    end;
}