// ------------------------------------------------------------------------------------------------
// Copyright (c) GOB Software Systeme GmbH. All rights reserved.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.Subcontracting;

using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.Wizard;

codeunit 99001561 "Subc. Temp Prod. Ord. Bind"
{
    EventSubscriberInstance = Manual;

    var
        DummyProdOrderLine: Record "Prod. Order Line";
        DummyProdOrderRoutingLine: Record "Prod. Order Routing Line";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Prod. Definition Temp Data", 'OnBeforeBuildTemporaryStructureFromBOMRouting', '', false, false)]
    local procedure ProdDefinitionTempData_OnBeforeBuildTemporaryStructureFromBOMRouting(var TempGlobalProdOrderLine: Record "Prod. Order Line" temporary)
    begin
        PrepareDummyProdOrderLine(TempGlobalProdOrderLine, TempGlobalProdOrderLine."Routing No.");
    end;

    [EventSubscriber(ObjectType::Page, Page::"Production Definition Wizard", 'OnClosePageEvent', '', false, false)]
    local procedure OnCloseProductionDefinitionWizard()
    begin
        DeleteDummyProdOrderLine();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Production Definition Manager", 'OnAfterPostWizardProcessing', '', false, false)]
    local procedure OnAfterPostWizardProcessing()
    begin
        DeleteDummyProdOrderLine();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Routing Line", 'OnBeforeCalcStartingEndingDates', '', false, false)]
    local procedure ProdOrderRoutingLine_OnBeforeCalcStartingEndingDates(var ProdOrderRoutingLine: Record "Prod. Order Routing Line"; var Direction: Option; var IsHandled: Boolean)
    begin
        if ProdOrderRoutingLine.IsTemporary() then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Routing Line", 'OnBeforeCheckRoutingNoNotBlank', '', false, false)]
    local procedure ProdOrderRoutingLine_OnBeforeCheckRoutingNoNotBlank(var ProdOrderRoutingLine: Record "Prod. Order Routing Line"; var IsHandled: Boolean)
    begin
        if ProdOrderRoutingLine.IsTemporary() then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Routing Line", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure ProdOrderRoutingLine_OnBeforeDeleteEvent(var Rec: Record "Prod. Order Routing Line")
    begin
        if Rec.IsTemporary() then
            PrepareDummyProdOrderRoutingLine(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Routing Line", 'OnAfterDeleteEvent', '', false, false)]
    local procedure ProdOrderRoutingLine_OnAfterDeleteEvent(var Rec: Record "Prod. Order Routing Line")
    begin
        if Rec.IsTemporary() then
            DeleteDummyProdOrderRoutingLine();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Routing Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure ProdOrderRoutingLine_OnBeforeModifyEvent(var Rec: Record "Prod. Order Routing Line")
    begin
        if Rec.IsTemporary() then
            PrepareDummyProdOrderRoutingLine(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Routing Line", 'OnAfterModifyEvent', '', false, false)]
    local procedure ProdOrderRoutingLine_OnAfterModifyEvent(var Rec: Record "Prod. Order Routing Line")
    begin
        if Rec.IsTemporary() then
            DeleteDummyProdOrderRoutingLine();
    end;

    // ----------------------------------------
    // Internal helpers
    // ----------------------------------------

    local procedure PrepareDummyProdOrderLine(var TempProdOrderLine: Record "Prod. Order Line" temporary; RoutingNo: Code[20])
    begin
        if not DummyProdOrderLine.Get(TempProdOrderLine.Status, TempProdOrderLine."Prod. Order No.", TempProdOrderLine."Line No.") then begin
            DummyProdOrderLine := TempProdOrderLine;
            DummyProdOrderLine."Routing No." := RoutingNo;
            DummyProdOrderLine.Insert();
        end else begin
            DummyProdOrderLine."Routing No." := RoutingNo;
            DummyProdOrderLine.Modify();
        end;
    end;

    local procedure DeleteDummyProdOrderLine()
    begin
        if DummyProdOrderLine.Get(DummyProdOrderLine.Status, DummyProdOrderLine."Prod. Order No.", DummyProdOrderLine."Line No.") then
            DummyProdOrderLine.Delete();
        Clear(DummyProdOrderLine);
    end;

    local procedure PrepareDummyProdOrderRoutingLine(ProdOrderRoutingLineRef: Record "Prod. Order Routing Line")
    begin
        if not DummyProdOrderRoutingLine.Get(
            ProdOrderRoutingLineRef.Status,
            ProdOrderRoutingLineRef."Prod. Order No.",
            ProdOrderRoutingLineRef."Routing Reference No.",
            ProdOrderRoutingLineRef."Routing No.",
            ProdOrderRoutingLineRef."Operation No.")
        then begin
            DummyProdOrderRoutingLine := ProdOrderRoutingLineRef;
            DummyProdOrderRoutingLine.Insert();
        end;
    end;

    local procedure DeleteDummyProdOrderRoutingLine()
    begin
        if DummyProdOrderRoutingLine.Get(
            DummyProdOrderRoutingLine.Status,
            DummyProdOrderRoutingLine."Prod. Order No.",
            DummyProdOrderRoutingLine."Routing Reference No.",
            DummyProdOrderRoutingLine."Routing No.",
            DummyProdOrderRoutingLine."Operation No.")
        then
            DummyProdOrderRoutingLine.Delete();
        Clear(DummyProdOrderRoutingLine);
    end;
}