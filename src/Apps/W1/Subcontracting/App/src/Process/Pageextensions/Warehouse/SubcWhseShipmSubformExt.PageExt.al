// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.Subcontracting;

using Microsoft.Warehouse.Document;

pageextension 99001535 "Subc. Whse Shipm. Subform Ext." extends "Whse. Shipment Subform"
{
    actions
    {
        modify(ItemTrackingLines)
        {
            Enabled = not Rec."Transfer WIP Item";
        }
    }
}