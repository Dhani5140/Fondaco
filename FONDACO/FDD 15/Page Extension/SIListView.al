pageextension 50119 "SI List View" extends "Sales invoice List"
{
    layout
    {
        addafter(Amount)
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
    views
    {
        addfirst
        {
            view(WarehouseUnrecordedDelivery)
            {
                Caption = 'Unrecorded Delivery';
                Filters = where(
                    Delivered = const(false), "Courier Name" = filter('')
                );
            }
        }
    }
}