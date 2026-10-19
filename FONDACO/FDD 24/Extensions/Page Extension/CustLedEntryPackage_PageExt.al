pageextension 50102 "Cust. Ledger Entries Pkg Ext" extends "Customer Ledger Entries"
{
    layout
    {
        addafter("Document No.")
        {
            field("Sales Package No."; Rec."Sales Package No.") { ApplicationArea = All; }
        }
    }
}