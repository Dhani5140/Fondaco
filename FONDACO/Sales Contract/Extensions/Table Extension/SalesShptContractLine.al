tableextension 50104 "Sales Shpt. Line Contract Ext." extends "Sales Shipment Line"
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