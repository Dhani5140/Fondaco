tableextension 50116 "Posted Sales Inv. Checkbox" extends "Sales Header"
{
    fields
    {
        field(50120; Delivered; Boolean)
        {
            Caption = 'Delivered';
            DataClassification = CustomerContent;
        }
        field(50121; "Courier name"; Text[100])
        {
            Caption = 'Courier Name';
            DataClassification = CustomerContent;
        }
    }
}