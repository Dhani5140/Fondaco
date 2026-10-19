page 50107 "Batch Posting PopUp"
{
    Caption = 'Batch Post Invoice';
    PageType = StandardDialog;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            field(FromDate; FromDate)
            {
                Caption = 'From Date';
                ShowMandatory = true;
            }
            field(ToDate; ToDate)
            {
                Caption = 'To Date';
                ShowMandatory = true;
            }
        }
    }

    var
        FromDate: Date;
        ToDate: Date;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = Action::OK then
            if (FromDate = 0D) or (ToDate = 0D) or (FromDate > ToDate) then
                Error('Fill in both From Date and To Date, and make sure From Date is not after To Date.');
    end;

    procedure GetDates(var NewFromDate: Date; var NewToDate: Date)
    begin
        NewFromDate := FromDate;
        NewToDate := ToDate;
    end;
}