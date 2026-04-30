// ------------------------------------------------------------------------------------------------
// Copyright (c) GOB Software Systeme GmbH. All rights reserved.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.Subcontracting;

using Microsoft.Manufacturing.Setup;
using Microsoft.Manufacturing.Wizard;

pageextension 99001563 TempBOMLineSubcExt extends "Temp BOM Lines"
{
    layout
    {
        addlast(Lines)
        {
            field(SubcontractingType; Rec."Subcontracting Type")
            {
                ApplicationArea = Manufacturing;
                Caption = 'Subcontracting Type';
                ToolTip = 'Specifies the subcontracting type for this BOM component.';

                trigger OnValidate()
                begin
                    if Rec."Subcontracting Type" = Rec."Subcontracting Type"::Purchase then
                        Rec.FieldError("Subcontracting Type");

                    if (Rec."Routing Link Code" = '') and (Rec."Subcontracting Type" <> Rec."Subcontracting Type"::Empty) then begin
                        GetManufacturingSetup();
                        Rec."Routing Link Code" := ManufacturingSetup."Rtng. Link Code Purch. Prov.";
                    end;
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Subcontracting Type" := xRec."Subcontracting Type";
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
}