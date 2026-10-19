tableextension 50106 "Cust. Ledger Entry Package Ext" extends "Cust. Ledger Entry"
{
    fields
    {
        field(50100; "Sales Package No."; Code[20])
        {
            Caption = 'Sales Package No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}