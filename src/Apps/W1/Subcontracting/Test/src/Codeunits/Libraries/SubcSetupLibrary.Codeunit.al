// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.Subcontracting.Test;

using Microsoft.Inventory.Item;
using Microsoft.Manufacturing.Routing;
using Microsoft.Manufacturing.Setup;
using Microsoft.Manufacturing.Wizard;
using Microsoft.Manufacturing.WorkCenter;

codeunit 139988 "Subc. Setup Library"
{
    var
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryManufacturing: Codeunit "Library - Manufacturing";
        SubCreateProdOrdWizLibrary: Codeunit "Subc. CreateProdOrdWizLibrary";

    procedure InitSetupFields()
    var
        Item: Record Item;
        RoutingLink: Record "Routing Link";
        ManufacturingSetup: Record "Manufacturing Setup";
        WorkCenter: Record "Work Center";
    begin
        // Create Work Center for subcontracting
        SubCreateProdOrdWizLibrary.CreateAndCalculateNeededWorkCenter(WorkCenter, true);

        // Create routing link for purchase provisioning
        LibraryManufacturing.CreateRoutingLink(RoutingLink);

        LibraryInventory.CreateItem(Item);

        ManufacturingSetup.Get();

        // Set required fields for production order creation
        ManufacturingSetup."Default Work Center No." := WorkCenter."No.";
        ManufacturingSetup."Rtng. Link Code Purch. Prov." := RoutingLink."Code";
        ManufacturingSetup."Def. Wiz. Flushing Method" := "Flushing Method Routing"::Backward;
        ManufacturingSetup."Component at Location" := ManufacturingSetup."Component at Location"::Purchase;

        // Set wizard fields on Manufacturing Setup
        ManufacturingSetup."Default Component Item No." := Item."No.";

        // Set all Select fields to Edit as default
        ManufacturingSetup."Show Prod Comp Select Nothing" := "Prod. Definition Display"::Edit;
        ManufacturingSetup."Show Rtng BOM Select Partial" := "Prod. Definition Display"::Edit;
        ManufacturingSetup."Show Rtng BOM Select Both" := "Prod. Definition Display"::Edit;
        ManufacturingSetup."Show Prod Comp Select Nothing" := "Prod. Definition Display"::Edit;
        ManufacturingSetup."Show Prod Comp Select Partial" := "Prod. Definition Display"::Edit;
        ManufacturingSetup."Show Prod Comp Select Both" := "Prod. Definition Display"::Edit;

        ManufacturingSetup.Modify();
    end;

    procedure ConfigureSubManagementForNothingPresentScenario(ShowRtngBOMSelect: Enum "Prod. Definition Display"; ShowProdCompSelect: Enum "Prod. Definition Display")
    var
        ManufacturingSetup: Record "Manufacturing Setup";
    begin
        ManufacturingSetup.Get();

        // Configure for NothingPresent scenario
        ManufacturingSetup."Show Rtng BOM Select Nothing" := ShowRtngBOMSelect;
        ManufacturingSetup."Show Prod Comp Select Nothing" := ShowProdCompSelect;

        ManufacturingSetup.Modify();
    end;

    procedure ConfigureSubManagementForPartiallyPresentScenario(ShowRtngBOMSelect: Enum "Prod. Definition Display"; ShowProdCompSelect: Enum "Prod. Definition Display")
    var
        ManufacturingSetup: Record "Manufacturing Setup";
    begin
        ManufacturingSetup.Get();

        // Configure for PartiallyPresent scenario
        ManufacturingSetup."Show Rtng BOM Select Partial" := ShowRtngBOMSelect;
        ManufacturingSetup."Show Prod Comp Select Partial" := ShowProdCompSelect;

        ManufacturingSetup.Modify();
    end;

    procedure ConfigureSubManagementForBothPresentScenario(ShowRtngBOMSelect: Enum "Prod. Definition Display"; ShowProdCompSelect: Enum "Prod. Definition Display")
    var
        ManufacturingSetup: Record "Manufacturing Setup";
    begin
        ManufacturingSetup.Get();

        // Configure for BothPresent scenario
        ManufacturingSetup."Show Rtng BOM Select Both" := ShowRtngBOMSelect;
        ManufacturingSetup."Show Prod Comp Select Both" := ShowProdCompSelect;

        ManufacturingSetup.Modify();
    end;

    internal procedure InitialSetupForGenProdPostingGroup()
    var
        GenProdPostingGroup1: Record Microsoft.Finance.GeneralLedger.Setup."Gen. Product Posting Group";
        GenProdPostingGroup2: Record Microsoft.Finance.GeneralLedger.Setup."Gen. Product Posting Group";
    begin
        // Assign Def. VAT Prod. Posting Group to a Gen. Prod. Posting Group based on W1.
        GenProdPostingGroup2.SetFilter("Def. VAT Prod. Posting Group", '<>%1', '');
        if not GenProdPostingGroup2.FindFirst() then
            exit; // All Gen. Prod. Posting Groups have Def. VAT Prod. Posting Group assigned.

        GenProdPostingGroup1.SetFilter("Def. VAT Prod. Posting Group", '');
        if GenProdPostingGroup1.FindSet(true) then
            repeat
                GenProdPostingGroup1."Def. VAT Prod. Posting Group" := GenProdPostingGroup2."Def. VAT Prod. Posting Group";
                GenProdPostingGroup1.Modify(true);
            until GenProdPostingGroup1.Next() = 0;
    end;
}