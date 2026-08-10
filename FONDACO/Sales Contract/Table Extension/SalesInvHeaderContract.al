tableextension 50100 "Sales Inv. Contract Ext." extends "Sales Invoice Header"
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