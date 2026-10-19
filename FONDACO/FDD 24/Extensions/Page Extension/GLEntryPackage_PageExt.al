pageextension 50103 "G/L Entries Pkg Ext" extends "General Ledger Entries"
{
    layout
    {
        addafter("Document No.")
        {
            field("Sales Package No."; Rec."Sales Package No.") { ApplicationArea = All; }
        }
    }
}