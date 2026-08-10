pageextension 50122 "Sales Order Not Shipped Ext." extends "O365 Activities"
{
    layout
    {
        addafter("Ongoing Sales Invoices")
        {
            field("Sales Order Not Shipped"; Rec."Sales Order Not Shipped")
            {
                ApplicationArea = All;
                Caption = 'Sales Order Not Shipped';
                DrillDownPageId = "Sales Order List";
                Style = Attention;
                ToolTip = 'Shows the number of Sales Orders that are Released but not completely shipped.';
            }
        }
    }
}