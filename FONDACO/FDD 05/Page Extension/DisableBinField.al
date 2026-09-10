pageextension 50145 "Disable Bin Toggle" extends "Inventory Setup"
{
    layout
    {
        addafter("Allow Inventory Adjustment")
        {
            field("Disable Bin"; Rec."Disable Bin")
            {
                ApplicationArea = All;
                Caption = 'Disable Manual Bin & Lot Selection';
                ToolTip = 'Specifies whether users can manually change Bin Code and Lot No. during warehouse picking.';
            }
        }
    }
}