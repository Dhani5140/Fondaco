pageextension 50186 "Item Upcoming Expiration" extends "O365 Activities"
{
    layout
    {
        addlast(content)
        {
            cuegroup(OperationalAlerts)
            {
                Caption = 'Operational Alerts';

                field("Items Near Expiration"; Rec."Items Near Expiration")
                {
                    ApplicationArea = All;
                    Caption = 'Items Near Expiration';
                    ToolTip = 'Items with remaining stock expiring within the next month.';
                    DrillDownPageID = "Item Ledger Entries";
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetRange("Items Near Exp. Filter", Today(), CalcDate('<1M>', Today()));
    end;
}