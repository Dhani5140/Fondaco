tableextension 50103 "Sales Shipment Package Ext" extends "Sales Shipment Line"
{
    fields
    {
        field(50105; "Package No."; Code[20])
        {
            Caption = 'Package No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50106; "Package Line No."; Integer)
        {
            Caption = 'Package Line No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
    keys { key(PackageKey; "Package No.", "Package Line No.") { } }
}