pageextension 50137 "Service Contract Ext." extends "Service Contract"
{
    layout
    {
        addafter("Expiration Date")
        {
            field(DaysDue; DaysDue)
            {
                ApplicationArea = All;
                Caption = 'Days Due';
                Editable = false;
                Style = Attention;
                StyleExpr = DaysDue < 0;
                ToolTip = 'Shows the number of days remaining until this service contract expires. Negative value means already expired.';
            }
        }
    }

    var
        DaysDue: Integer;

    trigger OnAfterGetCurrRecord()
    begin
        CalcDaysDue();
    end;

    local procedure CalcDaysDue()
    begin
        if Rec."Expiration Date" <> 0D then
            DaysDue := Rec."Expiration Date" - Today
        else
            DaysDue := 0;
    end;
}