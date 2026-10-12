pageextension 50181 "AR Overdue Cue" extends "O365 Activities"
{
    layout
    {
        addafter("Outstanding Vendor Invoices")
        {
            field("AR Overdue"; Rec."AR Overdue")
            {
                ApplicationArea = All;
                Caption = 'Upcoming AR Overdue';
                ToolTip = 'Shows the number of open customer invoices with remaining amount > 0, due within the next 7 days or already overdue.';
                Style = Attention;

                trigger OnDrillDown()
                var
                    CustLedEntry: Record "Cust. Ledger Entry";
                begin
                    SetARFilters(CustLedEntry);
                    Page.Run(Page::"Customer Ledger Entries", CustLedEntry);
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        CustLedEntry: Record "Cust. Ledger Entry";
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;

        SetARFilters(CustLedEntry);
        Rec."AR Overdue" := CustLedEntry.Count();
    end;

    local procedure SetARFilters(var CustLedEntry: Record "Cust. Ledger Entry")
    begin
        CustLedEntry.SetFilter("Remaining Amount", '>0');
        CustLedEntry.SetFilter("Due Date", '..%1', CalcDate('<+7D>', Today));
    end;
}