// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.Subcontracting;

using Microsoft.Manufacturing.Setup;

codeunit 99001504 "Subcontracting Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        MigrateSubcManagementSetupToManufacturingSetup();
    end;

    local procedure MigrateSubcManagementSetupToManufacturingSetup()
    var
        ManufacturingSetup: Record "Manufacturing Setup";
        SubcMgmtSetupRecRef: RecordRef;
    begin
        SubcMgmtSetupRecRef.Open(99001501);
        if not SubcMgmtSetupRecRef.FindFirst() then begin
            SubcMgmtSetupRecRef.Close();
            exit;
        end;

        if not ManufacturingSetup.Get() then begin
            SubcMgmtSetupRecRef.Close();
            exit;
        end;

        // Migrate fields only if the target fields are still at their defaults
        if not ManufacturingSetup."Create Prod. Order Info Line" then
            ManufacturingSetup."Create Prod. Order Info Line" := SubcMgmtSetupRecRef.Field(10).Value;

        if ManufacturingSetup."Subcontracting Template Name" = '' then
            ManufacturingSetup."Subcontracting Template Name" := SubcMgmtSetupRecRef.Field(40).Value;

        if ManufacturingSetup."Subcontracting Batch Name" = '' then
            ManufacturingSetup."Subcontracting Batch Name" := SubcMgmtSetupRecRef.Field(50).Value;

        if not ManufacturingSetup."Direct Transfer" then
            ManufacturingSetup."Direct Transfer" := SubcMgmtSetupRecRef.Field(60).Value;

        if ManufacturingSetup."Component Direct Unit Cost" = 0 then
            ManufacturingSetup."Component Direct Unit Cost" := SubcMgmtSetupRecRef.Field(70).Value;

        if Format(ManufacturingSetup."Subc. Inb. Whse. Handling Time") = '' then
            Evaluate(ManufacturingSetup."Subc. Inb. Whse. Handling Time", Format(SubcMgmtSetupRecRef.Field(80).Value));

        if ManufacturingSetup."Rtng. Link Code Purch. Prov." = '' then
            ManufacturingSetup."Rtng. Link Code Purch. Prov." := SubcMgmtSetupRecRef.Field(90).Value;

        if ManufacturingSetup."Component at Location" = ManufacturingSetup."Component at Location"::Empty then
            ManufacturingSetup."Component at Location" := SubcMgmtSetupRecRef.Field(120).Value;

        if not ManufacturingSetup.RefItemChargeToRcptSubLines then
            ManufacturingSetup.RefItemChargeToRcptSubLines := SubcMgmtSetupRecRef.Field(130).Value;

        ManufacturingSetup.Modify();

        SubcMgmtSetupRecRef.Close();
    end;
}