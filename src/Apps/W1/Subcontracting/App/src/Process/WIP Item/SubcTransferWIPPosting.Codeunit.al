// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.Subcontracting;

using Microsoft.Foundation.Enums;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Planning;
using Microsoft.Inventory.Requisition;
using Microsoft.Inventory.Tracking;
using Microsoft.Inventory.Transfer;
using Microsoft.Warehouse.Document;

codeunit 99001541 "Subc. Transfer WIP Posting"
{
    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", OnBeforeValidateQuantityShipIsBalanced, '', false, false)]
    local procedure HandleWipTransferOnBeforeValidateQuantityShipIsBalanced(var TransferLine: Record "Transfer Line"; xTransferLine: Record "Transfer Line"; var IsHandled: Boolean)
    begin
        if TransferLine."Transfer WIP Item" then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", OnBeforeValidateQuantityReceiveIsBalanced, '', false, false)]
    local procedure HandleWipTransferOnBeforeValidateQuantityReceiveIsBalanced(var TransferLine: Record "Transfer Line"; xTransferLine: Record "Transfer Line"; var IsHandled: Boolean)
    begin
        if TransferLine."Transfer WIP Item" then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", OnBeforeCheckItemInInventory, '', false, false)]
    local procedure HandleWipTransferOnBeforeCheckItemInInventory(TransferLine: Record "Transfer Line"; var IsHandled: Boolean)
    begin
        if TransferLine."Transfer WIP Item" then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Check Line", OnBeforeCheckEmptyQuantity, '', false, false)]
    local procedure HandleWipTransferOnBeforeCheckEmptyQuantity(ItemJnlLine: Record "Item Journal Line"; var IsHandled: Boolean)
    var
        TransferLine: Record "Transfer Line";
    begin
        TransferLine.SetLoadFields("Transfer WIP Item");
        if ItemJnlLine."Order Type" = "Inventory Order Type"::Transfer then
            if TransferLine.Get(ItemJnlLine."Order No.", ItemJnlLine."Order Line No.") then
                if TransferLine."Transfer WIP Item" then
                    IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Shipment Line", OnAfterCopyFromTransferLine, '', false, false)]
    local procedure HandleWipTransferShipmentLineOnAfterCopyFromTransferLine(var TransferShipmentLine: Record "Transfer Shipment Line"; TransferLine: Record "Transfer Line")
    begin
        TransferShipmentLine."Transfer WIP Item" := TransferLine."Transfer WIP Item";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Receipt Line", OnAfterCopyFromTransferLine, '', false, false)]
    local procedure HandleWipTransferReceiptLineOnAfterCopyFromTransferLine(var TransferReceiptLine: Record "Transfer Receipt Line"; TransferLine: Record "Transfer Line")
    begin
        TransferReceiptLine."Transfer WIP Item" := TransferLine."Transfer WIP Item";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Direct Trans. Line", OnAfterCopyFromTransferLine, '', false, false)]
    local procedure HandleWipDirectTransLineOnAfterCopyFromTransferLine(var DirectTransLine: Record "Direct Trans. Line"; TransferLine: Record "Transfer Line")
    begin
        DirectTransLine."Transfer WIP Item" := TransferLine."Transfer WIP Item";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Undo Transfer Shipment", OnNoItemLedgerEntriesCheckIsNeeded, '', false, false)]
    local procedure HandleWipTransferOnNoItemLedgerEntriesCheckIsNeeded(TransShptLine: Record "Transfer Shipment Line"; var NoCheckNeeded: Boolean)
    begin
        if TransShptLine."Transfer WIP Item" then
            NoCheckNeeded := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", OnBeforeShowReservation, '', false, false)]
    local procedure HandleWipTransferOnBeforeShowReservation(var TransferLine: Record "Transfer Line"; var IsHandled: Boolean)
    begin
        TransferLine.TestField("Transfer WIP Item", false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reservation Management", OnSetReservSource, '', false, false)]
    local procedure HandleWipTransferOnSetReservSource(var Sender: Codeunit "Reservation Management"; SourceRecRef: RecordRef; var ReservEntry: Record "Reservation Entry"; Direction: Enum "Transfer Direction"; var RefOrderType: Enum "Requisition Ref. Order Type"; var PlanningLineOrigin: Enum "Planning Line Origin Type"; Positive: Boolean)
    var
        TransferLine: Record "Transfer Line";
    begin
        if SourceRecRef.Number = Database::"Transfer Line" then begin
            SourceRecRef.SetTable(TransferLine);
            TransferLine.CheckForExistingReservationsOrItemTracking();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", OnBeforeOpenItemTrackingLines, '', false, false)]
    local procedure HandleWipTransferOnBeforeOpenItemTrackingLines(var TransferLine: Record "Transfer Line"; var IsHandled: Boolean)
    begin
        TransferLine.TestField("Transfer WIP Item", false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Transfer Warehouse Mgt.", OnBeforeCheckIfTransLine2ReceiptLine, '', false, false)]
    local procedure HandleWipTransferOnBeforeCheckIfTransLine2ReceiptLine(var TransferLine: Record "Transfer Line"; var IsHandled: Boolean; var ReturnValue: Boolean)
    var
        Location: Record Location;
    begin
        if TransferLine."Transfer WIP Item" then begin
            TransferLine.CalcFields("Whse. Inbnd. Otsdg. Qty");
            if Location.GetLocationSetup(TransferLine."Transfer-to Code", Location) then
                if Location."Use As In-Transit" then begin
                    IsHandled := true;
                    ReturnValue := false;
                    exit;
                end;
            IsHandled := true;
            ReturnValue := (TransferLine."Qty. in Transit" > TransferLine."Whse. Inbnd. Otsdg. Qty");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Transfer Warehouse Mgt.", OnTransLine2ReceiptLineOnAfterInitNewLine, '', false, false)]
    local procedure HandleWipTransferOnTransLine2ReceiptLineOnAfterInitNewLine(var WarehouseReceiptLine: Record "Warehouse Receipt Line"; WarehouseReceiptHeader: Record "Warehouse Receipt Header"; TransferLine: Record "Transfer Line"; var QtyOnRcptLineSet: Boolean)
    begin
        WarehouseReceiptLine."Transfer WIP Item" := TransferLine."Transfer WIP Item";
        if WarehouseReceiptLine."Transfer WIP Item" then begin
            WarehouseReceiptLine.Validate(WarehouseReceiptLine."Qty. Received", TransferLine."Quantity Received");
            TransferLine.CalcFields("Whse. Inbnd. Otsdg. Qty");
            WarehouseReceiptLine.Quantity := TransferLine."Quantity Received" + TransferLine."Qty. in Transit" - TransferLine."Whse. Inbnd. Otsdg. Qty";
            WarehouseReceiptLine."Qty. (Base)" := 0;
            WarehouseReceiptLine.InitOutstandingQtys();
            QtyOnRcptLineSet := true;
        end;
    end;
}