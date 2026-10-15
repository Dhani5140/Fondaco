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
    }
    keys { key(PackageKey; "Package No.", "Package Line No.") { } }
}