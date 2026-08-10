enum 50101 "Schedule Status"
{
    Extensible = true;
    Caption = 'Schedule Status';

    value(0; Open)
    {
        Caption = 'Open';
    }
    value(1; Invoice)
    {
        Caption = 'Invoice';
    }
    value(2; Paid)
    {
        Caption = 'Paid';
    }
}
