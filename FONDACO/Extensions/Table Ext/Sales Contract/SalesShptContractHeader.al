tableextension 50103 "Sales Shpt. Header Contract" extends "Sales Shipment Header"
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