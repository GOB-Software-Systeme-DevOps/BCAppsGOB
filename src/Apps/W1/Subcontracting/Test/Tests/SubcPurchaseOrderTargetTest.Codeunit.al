// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.Subcontracting.Test;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Requisition;
using Microsoft.Manufacturing.Subcontracting;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Vendor;
using System.TestLibraries.Utilities;

codeunit 139980 "Subc. Purchase Order Target Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    TestType = IntegrationTest;

    [Test]
    procedure TargetedLineAppendsAndFollowingUntargetedLineCreatesAnotherOrder()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        RequisitionLine: Record "Requisition Line";
        UntargetedLine: Record "Requisition Line";
        CarryOutActionMsgReq: Report "Carry Out Action Msg. - Req.";
    begin
        // [GIVEN] An existing order and two accepted suggestions for the same vendor.
        CreateTargetedSuggestion(RequisitionLine, PurchaseHeader);
        CreateSuggestion(UntargetedLine, RequisitionLine."Worksheet Template Name", RequisitionLine."Journal Batch Name",
            RequisitionLine."Vendor No.", RequisitionLine."No.");
        RequisitionLine.SetRange("Worksheet Template Name", RequisitionLine."Worksheet Template Name");
        RequisitionLine.SetRange("Journal Batch Name", RequisitionLine."Journal Batch Name");

        // [WHEN] The requisition Carry Out report processes both lines.
        CarryOutActionMsgReq.SetReqWkshLine(RequisitionLine);
        CarryOutActionMsgReq.UseRequestPage(false);
        CarryOutActionMsgReq.RunModal();

        // [THEN] The chosen order receives only the targeted line, and the other line creates a new order.
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        Assert.AreEqual(1, PurchaseLine.Count(), 'The selected order should receive exactly one line.');
        PurchaseLine.SetRange("Document No.");
        PurchaseLine.SetFilter("Document No.", '<>%1', PurchaseHeader."No.");
        PurchaseLine.SetRange("No.", UntargetedLine."No.");
        Assert.IsTrue(not PurchaseLine.IsEmpty(), 'The untargeted line should create a separate order.');
    end;

    [Test]
    procedure InvalidAcceptedTargetBlocksBatchBeforeChangingOrders()
    var
        PurchaseHeader: Record "Purchase Header";
        RequisitionLine: Record "Requisition Line";
        InvalidLine: Record "Requisition Line";
        PurchaseLine: Record "Purchase Line";
        CarryOutActionMsgReq: Report "Carry Out Action Msg. - Req.";
    begin
        // [GIVEN] A valid target followed by an accepted suggestion pointing at a missing order.
        CreateTargetedSuggestion(RequisitionLine, PurchaseHeader);
        CreateSuggestion(InvalidLine, RequisitionLine."Worksheet Template Name", RequisitionLine."Journal Batch Name",
            RequisitionLine."Vendor No.", RequisitionLine."No.");
        InvalidLine."Ref. Order No." := 'MISSING-TARGET';
        InvalidLine.Modify(true);
        RequisitionLine.SetRange("Worksheet Template Name", RequisitionLine."Worksheet Template Name");
        RequisitionLine.SetRange("Journal Batch Name", RequisitionLine."Journal Batch Name");

        // [WHEN] The report attempts to carry out the batch.
        CarryOutActionMsgReq.SetReqWkshLine(RequisitionLine);
        CarryOutActionMsgReq.UseRequestPage(false);
        asserterror CarryOutActionMsgReq.RunModal();

        // [THEN] The missing order is named, the original order is unchanged, and both lines remain.
        Assert.ExpectedError('MISSING-TARGET');
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        Assert.IsTrue(PurchaseLine.IsEmpty(), 'Preflight must not append to the valid target.');
        Assert.IsTrue(RequisitionLine.Get(RequisitionLine."Worksheet Template Name", RequisitionLine."Journal Batch Name",
            RequisitionLine."Line No."), 'The first suggestion must remain.');
        Assert.IsTrue(InvalidLine.Get(InvalidLine."Worksheet Template Name", InvalidLine."Journal Batch Name",
            InvalidLine."Line No."), 'The invalid suggestion must remain.');
        Assert.AreEqual('MISSING-TARGET', InvalidLine."Ref. Order No.", 'The target assignment must remain visible.');
    end;

    [Test]
    procedure InvalidUnacceptedTargetDoesNotBlockAcceptedSuggestion()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        RequisitionLine: Record "Requisition Line";
        UnacceptedLine: Record "Requisition Line";
        CarryOutActionMsgReq: Report "Carry Out Action Msg. - Req.";
    begin
        // [GIVEN] An accepted target and an unaccepted line with a missing target.
        CreateTargetedSuggestion(RequisitionLine, PurchaseHeader);
        CreateSuggestion(UnacceptedLine, RequisitionLine."Worksheet Template Name", RequisitionLine."Journal Batch Name",
            RequisitionLine."Vendor No.", RequisitionLine."No.");
        UnacceptedLine."Ref. Order No." := 'MISSING-TARGET';
        UnacceptedLine."Accept Action Message" := false;
        UnacceptedLine.Modify(true);
        RequisitionLine.SetRange("Worksheet Template Name", RequisitionLine."Worksheet Template Name");
        RequisitionLine.SetRange("Journal Batch Name", RequisitionLine."Journal Batch Name");

        // [WHEN] The accepted work is carried out.
        CarryOutActionMsgReq.SetReqWkshLine(RequisitionLine);
        CarryOutActionMsgReq.UseRequestPage(false);
        CarryOutActionMsgReq.RunModal();

        // [THEN] The valid target receives its line and the unaccepted assignment remains untouched.
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        Assert.AreEqual(1, PurchaseLine.Count(), 'The accepted suggestion should append to the target.');
        UnacceptedLine.Get(UnacceptedLine."Worksheet Template Name", UnacceptedLine."Journal Batch Name", UnacceptedLine."Line No.");
        Assert.AreEqual('MISSING-TARGET', UnacceptedLine."Ref. Order No.", 'Unaccepted work should remain unchanged.');
    end;

    [Test]
    procedure ChangingActionWithoutTableTriggerClearsOnlyTargetReference()
    var
        PurchaseHeader: Record "Purchase Header";
        RequisitionLine: Record "Requisition Line";
    begin
        // [GIVEN] A new suggestion assigned to an existing order.
        CreateTargetedSuggestion(RequisitionLine, PurchaseHeader);

        // [WHEN] The action changes without running the table OnModify trigger.
        RequisitionLine."Action Message" := RequisitionLine."Action Message"::Cancel;
        RequisitionLine.Modify(false);
        RequisitionLine.Get(RequisitionLine."Worksheet Template Name", RequisitionLine."Journal Batch Name", RequisitionLine."Line No.");

        // [THEN] The header target is removed from the persisted line.
        Assert.AreEqual('', RequisitionLine."Ref. Order No.", 'A non-New action must not retain a target.');
        Assert.AreEqual(0, RequisitionLine."Ref. Line No.", 'An exact supply-line reference must not be created.');
    end;

    [Test]
    procedure ClearingTargetOnWorksheetAffectsOnlyCurrentLine()
    var
        PurchaseHeader: Record "Purchase Header";
        RequisitionLine: Record "Requisition Line";
        OtherLine: Record "Requisition Line";
        Worksheet: TestPage "Subc. Subcontracting Worksheet";
    begin
        // [GIVEN] Two new suggestions and an assigned order on the first line.
        CreateTargetedSuggestion(RequisitionLine, PurchaseHeader);
        CreateSuggestion(OtherLine, RequisitionLine."Worksheet Template Name", RequisitionLine."Journal Batch Name",
            RequisitionLine."Vendor No.", RequisitionLine."No.");
        OtherLine."Ref. Order No." := PurchaseHeader."No.";
        OtherLine.Modify(true);
        Worksheet.OpenEdit();
        Worksheet.GoToRecord(RequisitionLine);
        Assert.IsTrue(Worksheet.ShowPurchaseOrder.Enabled(), 'A referenced order must be navigable.');

        // [WHEN] Clearing the selected order on the current worksheet line.
        Worksheet.ClearPurchaseOrder.Invoke();

        // [THEN] Only that line returns to an untargeted New purchase reference.
        RequisitionLine.Get(RequisitionLine."Worksheet Template Name", RequisitionLine."Journal Batch Name", RequisitionLine."Line No.");
        Assert.AreEqual('', RequisitionLine."Ref. Order No.", 'The assigned order should be cleared.');
        Assert.AreEqual(RequisitionLine."Ref. Order Type"::Purchase, RequisitionLine."Ref. Order Type",
            'The line should remain a purchase suggestion.');
        Assert.IsFalse(Worksheet.ShowPurchaseOrder.Enabled(), 'A blank reference must not enable navigation.');
        OtherLine.Get(OtherLine."Worksheet Template Name", OtherLine."Journal Batch Name", OtherLine."Line No.");
        Assert.AreEqual(PurchaseHeader."No.", OtherLine."Ref. Order No.", 'Clearing one line must not change another line.');
        Worksheet.Close();
    end;

    local procedure CreateTargetedSuggestion(var RequisitionLine: Record "Requisition Line"; var PurchaseHeader: Record "Purchase Header")
    var
        Item: Record Item;
        Vendor: Record Vendor;
        ReqWkshTemplate: Record "Req. Wksh. Template";
        RequisitionWkshName: Record "Requisition Wksh. Name";
    begin
        SubcontractingMgmtLibrary.CreateReqWkshTemplateAndName(ReqWkshTemplate, RequisitionWkshName);
        LibraryInventory.CreateItem(Item);
        LibraryPurchase.CreateVendor(Vendor);
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, Vendor."No.");
        CreateSuggestion(RequisitionLine, ReqWkshTemplate.Name, RequisitionWkshName.Name, Vendor."No.", Item."No.");
        RequisitionLine."Ref. Order No." := PurchaseHeader."No.";
        RequisitionLine.Modify(true);
    end;

    local procedure CreateSuggestion(var RequisitionLine: Record "Requisition Line"; TemplateName: Code[10]; BatchName: Code[10]; VendorNo: Code[20]; ItemNo: Code[20])
    begin
        LibraryPlanning.CreateRequisitionLine(RequisitionLine, TemplateName, BatchName);
        RequisitionLine.Validate(Type, RequisitionLine.Type::Item);
        RequisitionLine.Validate("No.", ItemNo);
        RequisitionLine.Validate("Vendor No.", VendorNo);
        RequisitionLine.Validate(Quantity, 1);
        RequisitionLine."Replenishment System" := RequisitionLine."Replenishment System"::Purchase;
        RequisitionLine."Ref. Order Type" := RequisitionLine."Ref. Order Type"::Purchase;
        RequisitionLine."Action Message" := RequisitionLine."Action Message"::New;
        RequisitionLine."Accept Action Message" := true;
        RequisitionLine.Modify(true);
    end;

    var
        Assert: Codeunit Assert;
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPlanning: Codeunit "Library - Planning";
        LibraryPurchase: Codeunit "Library - Purchase";
        SubcontractingMgmtLibrary: Codeunit "Subc. Management Library";
}
