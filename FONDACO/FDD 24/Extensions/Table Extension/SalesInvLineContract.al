tableextension 50101 "Sales Inv. Line Contract Ext." extends "Sales Invoice Line"
{
    fields
    {
        field(50100; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            DataClassification = CustomerContent;
            TableRelation = "Sales Contract Header";
        }
    }
}