pageextension 50138 "Service Contract List Ext" extends "Service Contracts"
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
                Style = Unfavorable;
                StyleExpr = DaysDue < 0;
                ToolTip = 'Shows remaining days until expiration. Negative = already expired.';
            }
        }
    }

    views
    {
        addfirst
        {
            view(ServiceContractsDue)
            {
                Caption = 'Service Contracts Due';
                Filters = where("Expiration Date" = filter(> 0D));
            }
        }
    }

    var
        DaysDue: Integer;

    trigger OnAfterGetRecord()
    begin
        if Rec."Expiration Date" <> 0D then
            DaysDue := Rec."Expiration Date" - Today
        else
            DaysDue := 0;
    end;
}