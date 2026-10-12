pageextension 50131 "User Setup Ext." extends "User Setup"
{
    layout
    {
        addbefore("Allow Posting To")
        {
            field("Allow Change Price"; Rec."Allow Change Price")
            {
                ApplicationArea = All;
                Caption = 'Allow Change Unit Price';
            }
        }
    }
}