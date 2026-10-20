tableextension 50102 "Sales Line Package Ext" extends "Sales Line"
{
    fields
    {
        field(50105; "Package No."; Code[20])
        {
            Caption = 'Package No.';
            DataClassification = CustomerContent;
            TableRelation = "Sales Contract Header";
            Editable = false;
        }
        field(50106; "Package Line No."; Integer)
        {
            Caption = 'Package Line No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50107; "Item Category Options"; Text[250])
        {
            Caption = 'Item Category Options';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50108; "Paket Category Code"; Code[20])
        {
            Caption = 'Paket Category Code';
            DataClassification = CustomerContent;
            TableRelation = "Paket Kategori";
            Editable = false;
        }
    }
    keys { key(PackageKey; "Package No.", "Package Line No.") { } }
}