pageextension 50111 SalesCancleQtyExtension extends "Sales Order"
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
            field("Cancellation Reason"; Rec."Cancellation Reason")
            {
                ApplicationArea = All;
                Editable = not Rec.Cancelled;
            }
        }
    }
    actions
    {
        addlast(processing)
        {
            action(CancelQtySO)
            {
                ApplicationArea = All;
                Caption = 'Cancel';
                Image = Cancel;
                Enabled = not Rec.Cancelled;
                ToolTip = 'Cancel the remaining Qty. to Ship on this sales order and log the cancellation.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    SalesCode: Codeunit "CloseCancSalesCode";
                begin
                    SalesCode.CancelQtySO(Rec);
                end;
            }
        }
    }
}