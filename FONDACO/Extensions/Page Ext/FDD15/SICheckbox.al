pageextension 50118 "Sales Invoice Page Checkbox" extends "Sales Invoice"
{
    layout
    {
        addafter("Shipment Method Code")
        {
            field(Delivered; Rec.Delivered)
            {
                ApplicationArea = All;
                Caption = 'Delivered';
            }
            field("Courier Name"; Rec."Courier Name")
            {
                ApplicationArea = All;
                Caption = 'Courier Name';
            }
        }
    }
}