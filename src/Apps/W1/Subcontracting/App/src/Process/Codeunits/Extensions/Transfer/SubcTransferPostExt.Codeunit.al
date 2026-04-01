// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.Subcontracting;

using Microsoft.Finance.GeneralLedger.Preview;
using Microsoft.Inventory.Transfer;

codeunit 99001545 "Subc. TransferPost Ext"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post (Yes/No)", OnCodeOnBeforePostTransferOrder, '', false, false)]
    local procedure OnCodeOnBeforePostTransferOrder(var TransHeader: Record "Transfer Header"; PreviewMode: Boolean; var PostBatch: Boolean; var IsHandled: Boolean)
    begin
        OverrideDefaultTransferPosting(TransHeader, PreviewMode, PostBatch, IsHandled);
    end;

    local procedure OverrideDefaultTransferPosting(var TransferHeader: Record "Transfer Header"; PreviewMode: Boolean; PostBatch: Boolean; var IsHandled: Boolean)
    var
        TransferOrderPostReceipt: Codeunit "TransferOrder-Post Receipt";
        TransferOrderPostShipment: Codeunit "TransferOrder-Post Shipment";
        TransferOrderPostTransfer: Codeunit "TransferOrder-Post Transfer";
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
    begin
        case TransferHeader."Direct Transfer Posting" of
            TransferHeader."Direct Transfer Posting"::"Receipt and Shipment":
                begin
                    TransferOrderPostShipment.SetSuppressCommit(true);
                    TransferOrderPostShipment.SetHideValidationDialog(PostBatch);
                    TransferOrderPostShipment.SetPreviewMode(PreviewMode);
                    TransferOrderPostShipment.Run(TransferHeader);
                    TransferOrderPostReceipt.SetSuppressCommit(true);
                    TransferOrderPostReceipt.SetHideValidationDialog(PostBatch);
                    TransferOrderPostReceipt.SetPreviewMode(PreviewMode);
                    TransferOrderPostReceipt.Run(TransferHeader);
                end;
            TransferHeader."Direct Transfer Posting"::"Direct Transfer":
                begin
                    TransferOrderPostTransfer.SetSuppressCommit(PreviewMode);
                    TransferOrderPostTransfer.SetHideValidationDialog(PostBatch);
                    TransferOrderPostTransfer.Run(TransferHeader);
                end;
            TransferHeader."Direct Transfer Posting"::Empty:
                exit;
        end;
        if PreviewMode then
            GenJnlPostPreview.ThrowError();

        IsHandled := true;
    end;
}