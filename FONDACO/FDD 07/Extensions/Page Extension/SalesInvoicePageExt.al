pageextension 50161 "Sales Invoice Ext" extends "Sales Invoice"
{
    layout
    {
        addafter(BillToOptions)
        {
            field("Installation Date"; Rec."InstallationDate")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the installation date carried over automatically from the related Warehouse Shipment.';
                Editable = false;
            }
        }
    }
}