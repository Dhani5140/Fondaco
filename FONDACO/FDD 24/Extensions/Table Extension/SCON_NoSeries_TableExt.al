tableextension 50101 "No. Series Cicilan Ext" extends "No. Series"
{
    fields
    {
        field(50100; "Nomor Faktur Cicilan"; Boolean)
        {
            Caption = 'Nomor Faktur Cicilan';
            DataClassification = CustomerContent;
        }
        field(50101; "Nomor Faktur Pengiriman"; Boolean)
        {
            Caption = 'Nomor Faktur Pengiriman Cicilan';
            DataClassification = CustomerContent;
        }
    }

}