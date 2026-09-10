tableextension 50117 "Sales Inv. Checkbox" extends "Sales Invoice Header"
{
    fields
    {
        field(50121; Delivered; Boolean)
        {
            Caption = 'Delivered';
            DataClassification = CustomerContent;
        }
        field(50122; "Courier name"; Text[100])
        {
            Caption = 'Courier Name';
            DataClassification = CustomerContent;
        }
    }
}