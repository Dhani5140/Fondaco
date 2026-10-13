enum 50100 "Sales Contract Status"
{
    Extensible = true;
    Caption = 'Sales Contract Status';

    value(0; Open)
    {
        Caption = 'Open';
    }
    value(1; Released)
    {
        Caption = 'Released';
    }
    value(2; Closed)
    {
        Caption = 'Closed';
    }
}