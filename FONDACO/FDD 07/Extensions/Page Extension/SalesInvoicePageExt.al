pageextension 50161 "Sales Invoice Ext" extends "Sales Invoice"
{
    layout
    {
        addafter("Bill-to Address")
        {
            field("Installation Date"; Rec."Installation Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the installation date carried over automatically from the related Warehouse Shipment.';
                Editable = false;
            }
        }
    }
}