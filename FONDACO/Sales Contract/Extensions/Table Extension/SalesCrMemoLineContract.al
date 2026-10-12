tableextension 50107 "Sales Cr. Memo Line Contract" extends "Sales Cr.Memo Line"
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
