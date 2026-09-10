tableextension 50162 "Sales Header Ext." extends "Sales Header"
{
    fields
    {
        field(50162; "Installation Date"; Date)
        {
            Caption = 'Installation Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}