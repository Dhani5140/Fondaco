pageextension 50121 "Sales Order List Ext" extends "Sales Order List"
{
    views
    {
        addlast
        {
            view(NotShipped)
            {
                Caption = 'Not Shipped';
                Filters = where("Completely Shipped" = const(false), Status = const(Released));
                SharedLayout = false;
            }
        }
    }
}