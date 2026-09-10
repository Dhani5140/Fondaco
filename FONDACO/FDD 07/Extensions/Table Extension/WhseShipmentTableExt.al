tableextension 50160 "Warehouse InstDate Ext." extends "Warehouse Shipment Header"
{
    fields
    {
        field(50160; "Installation Date"; Date)
        {
            Caption = 'Installation Date';
            DataClassification = CustomerContent;
        }
    }
}