// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.Subcontracting;

using Microsoft.Manufacturing.Planning;

permissionset 99001502 "Subcontract. - Read"
{
    Caption = 'Subcontracting - Read';
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "Subcontract. - Objs";
    Permissions = tabledata "Subcontractor Price" = R,
        table "Subcontractor Price" = X,
        report "Subc. Calculate Subcontracts" = X,
        report "Subc. Create Prod. Routing" = X,
        report "Subc. Create SubCReturnOrder" = X,
        report "Subc. Create Transf. Order" = X,
        report "Subc. Detailed Calculation" = X,
        report "Subc. Dispatching List" = X,
        codeunit "Single Instance Dictionary" = X,
        codeunit "Subc. Business Setup Ext." = X,
        codeunit "Subc. Calc BOM Tree Ext." = X,
        codeunit "Subc. Calc Subcontracts Ext." = X,
        codeunit "Subc. Calc. Prod. Order Ext." = X,
        codeunit "Subc. Calc.StandardCost Ext." = X,
        codeunit "Subc. Carry Out Action Ext." = X,
        codeunit "Subc. DirectTransferLine Ext." = X,
        codeunit "Subc. Factbox Mgmt." = X,
        codeunit "Subc. Item Extension" = X,
        codeunit "Subc. ItemChargeAssPurchExt" = X,
        codeunit "Subc. ItemJnlCheckExt" = X,
        codeunit "Subc. ItemJnlPostLine Ext" = X,
        codeunit "Subc. Notification Mgmt." = X,
        codeunit "Subc. Planning Comp. Ext." = X,
        codeunit "Subc. Planning Line Mgmt Ext." = X,
        codeunit "Subc. Price Management" = X,
        codeunit "Subc. Prod. Def. Subscriber" = X,
        codeunit "Subc. Prod. Ord. Comp. Res." = X,
        codeunit "Subc. Prod. Order Comp. Ext." = X,
        codeunit "Subc. Prod. Order Create Bind" = X,
        codeunit "Subc. Prod. Order Rtng. Ext." = X,
        codeunit "Subc. Purch. Post Ext" = X,
        codeunit "Subc. Purchase Header Ext" = X,
        codeunit "Subc. Purchase Line Ext" = X,
        codeunit "Subc. Purchase Order Creator" = X,
        codeunit "Subc. Reporting Triggers Ext" = X,
        codeunit "Subc. Req. Wksh. Make Ord." = X,
        codeunit "Subc. Req.Line Extension" = X,
        codeunit "Subc. Synchronize Management" = X,
        codeunit "Subc. Trans Rcpt Header Ext" = X,
        codeunit "Subc. Trans Shpt Header Ext" = X,
        codeunit "Subc. Transfer Line Ext." = X,
        codeunit "Subc. Transfer Rcpt Line Ext." = X,
        codeunit "Subc. Transfer Shpt Line Ext." = X,
        codeunit "Subc. TransOrderPostRcpt Ext" = X,
        codeunit "Subc. TransOrderPostShpt Ext" = X,
        codeunit "Subc. TransOrderPostTrans Ext" = X,
        codeunit "Subc. Vendor Extension" = X,
        codeunit "Subc. WhsePostReceipt Ext" = X,
        codeunit "Subc. WhsePurchRelease Ext" = X,
        codeunit "Subc. Work Center Extension" = X,
        codeunit "Subc. Worksheet Handler" = X,
        codeunit "Subcontracting Comp. Init." = X,
        codeunit "Subcontracting Install" = X,
        codeunit "Subcontracting Management" = X,
        codeunit "Subcontracting Management Ext." = X,
        page "Subc. Prod. Order Components" = X,
        page "Subc. Purchase Line Factbox" = X,
        page "Subc. Routing Info Factbox" = X,
        page "Subc. Subcontracting Worksheet" = X,
        page "Subc. Transfer Line Factbox" = X,
        page "Subcontractor Prices" = X;
}