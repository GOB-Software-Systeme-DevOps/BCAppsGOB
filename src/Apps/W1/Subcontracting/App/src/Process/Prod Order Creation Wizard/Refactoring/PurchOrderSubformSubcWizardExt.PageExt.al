// ------------------------------------------------------------------------------------------------
// Copyright (c) GOB Software Systeme GmbH. All rights reserved.
// ------------------------------------------------------------------------------------------------
namespace MS.Subcontracting;

using Microsoft.Manufacturing.Wizard;
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
                var
                    CurrPurchLine: Record "Purchase Line";
                    SubcSubscriber: Codeunit "Subc. Prod. Def. Subscriber";
                    SubcTempBind: Codeunit "Subc. Temp Prod. Ord. Bind";
                    SubcCreateBind: Codeunit "Subc. Prod. Order Create Bind";
                    ProdDefMgr: Codeunit "Production Definition Manager";
                begin
                    CurrPurchLine := Rec;
                    SubcCreateBind.SetSubcontractingPurchaseLine(CurrPurchLine);
                    BindSubscription(SubcSubscriber);
                    BindSubscription(SubcTempBind);
                    BindSubscription(SubcCreateBind);
                    ProdDefMgr.RunForPurchaseLine(CurrPurchLine, "Prod. Definition Mode"::CreateProductionOrder);
                    UnbindSubscription(SubcSubscriber);
                    UnbindSubscription(SubcTempBind);
                    UnbindSubscription(SubcCreateBind);
                end;
            }
        }
    }
}