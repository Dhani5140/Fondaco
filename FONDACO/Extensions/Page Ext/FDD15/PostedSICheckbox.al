pageextension 50116 "Posted Sales Inv. Page Ext." extends "Posted Sales Invoice"
{
    layout
    {
        addafter("Shipment Method Code")
        {
            field(Delivered; Rec.Delivered)
            {
                ApplicationArea = All;
                Caption = 'Delivered';
                Editable = true;
            }
            field("Courier Name"; Rec."Courier Name")
            {
                ApplicationArea = All;
                Caption = 'Courier Name';
                Editable = true;
            }
        }
    }
}