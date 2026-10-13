tableextension 50106 "Sales Cr. Memo Header Contract" extends "Sales Cr.Memo Header"
{
    fields
    {
        field(50100; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            DataClassification = CustomerContent;
            TableRelation = "Sales Contract Header";
            Editable = false;
        }
    }
}
