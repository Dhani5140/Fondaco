pageextension 50113 ShowSalesCancelStatus extends "Sales Order List"
{
    layout
    {
        addafter(Status)
        {
            field("Cancelled"; Rec."Cancelled")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("Cancelled Date"; Rec."Cancelled Date")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("Cancelled By"; Rec."Cancelled By")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }
}