tableextension 50145 "Disable Bin Indicator" extends "Inventory Setup"
{
    fields
    {
        field(50145; "Disable Bin"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Disable Manual Bin & Lot Selection';
        }
    }
}