tableextension 50163 "Sales Shipment Hdr Ext" extends "Sales Shipment Header"
{
    fields
    {
        field(50163; "InstallationDate"; Date)
        {
            Caption = 'Installation Date';
            DataClassification = CustomerContent;
        }
    }
}