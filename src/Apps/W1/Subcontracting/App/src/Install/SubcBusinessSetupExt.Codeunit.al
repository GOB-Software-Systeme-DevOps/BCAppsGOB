// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.Subcontracting;

using Microsoft.Foundation.Company;

codeunit 99001502 "Subc. Business Setup Ext."
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", OnCompanyInitialize, '', false, false)]
    local procedure OnCompanyInitialize()
    var
        SubcontractingCompInit: Codeunit "Subcontracting Comp. Init.";
    begin
        SubcontractingCompInit.CreateBasicSubcontractingMgtSetup();
    end;
}