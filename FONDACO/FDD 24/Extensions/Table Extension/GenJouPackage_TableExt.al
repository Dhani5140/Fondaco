tableextension 50108 "Gen. Journal Line Package Ext" extends "Gen. Journal Line"
{
    fields
    {
        field(50100; "Sales Package No."; Code[20])
        {
            Caption = 'Sales Package No.';
            DataClassification = CustomerContent;
        }
    }
}