// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.FixedAssets.FixedAsset;

pageextension 31374 "Fixed Asset Card CZ" extends "Fixed Asset Card"
{
    layout
    {
        addafter("Country/Region of Origin Code")
        {
            field("Statistic Indication CZ"; Rec."Statistic Indication CZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Statistic indication for Intrastat reporting purposes.';
            }
            field("Specific Movement CZ"; Rec."Specific Movement CZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Specific Movement for Intrastat reporting purposes.';
            }
        }
    }
}
