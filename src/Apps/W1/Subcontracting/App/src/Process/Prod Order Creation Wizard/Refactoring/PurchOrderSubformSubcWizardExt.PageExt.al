// ------------------------------------------------------------------------------------------------
// Copyright (c) GOB Software Systeme GmbH. All rights reserved.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.Subcontracting;

using Microsoft.Purchases.Document;

pageextension 99001562 PurchOrderSubformSubcWizardExt extends "Purchase Order Subform"
{
    actions
    {
        addlast("F&unctions")
        {
            action(CreateSubcProductionOrder)
            {
                ApplicationArea = Manufacturing;
                Caption = 'Create &Production Order';
                Image = NewOrder;
                ToolTip = 'Creates a subcontracting production order for the selected purchase line using the Production Definition Wizard.';

                trigger OnAction()
                begin
                    Rec.CreateSubcontractingProductionOrder();
                end;
            }
        }
    }

}