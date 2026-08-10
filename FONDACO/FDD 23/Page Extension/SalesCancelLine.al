pageextension 50112 "Sales Order Line Cancel Qty." extends "Sales Order Subform"
{
    layout
    {
        modify("Qty. to Ship")
        {
            Editable = not IsCancelled;
        }
        addafter("Qty. to Invoice")
        {
            field("Cancel Qty."; Rec."Cancel Qty.")
            {
                ApplicationArea = all;
                Editable = false;
            }
        }
        addafter("Quantity Invoiced")
        {
            field("Cancel Status"; Rec."Cancel Status")
            {
                ApplicationArea = all;
                Editable = false;
            }
        }
    }

    var
        IsCancelled: Boolean;


    trigger OnAfterGetRecord()
    var
        SalesHeader: Record "Sales Header";
    begin
        if SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            IsCancelled := SalesHeader.Cancelled
        else
            IsCancelled := false;

        if Rec."Cancel Qty." <> 0 then
            Rec."Cancel Status" := Rec."Cancel Status"::Yes
        else
            Rec."Cancel Status" := Rec."Cancel Status"::" ";
    end;
}