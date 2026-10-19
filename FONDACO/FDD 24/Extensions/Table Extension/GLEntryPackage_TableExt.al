tableextension 50107 "G/L Entry Package Ext" extends "G/L Entry"
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