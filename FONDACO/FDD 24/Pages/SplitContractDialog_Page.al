page 50109 "Split Contract Line"
{
    Caption = 'Split Line';
    PageType = StandardDialog;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            field(QtyToSplit; QtyToSplit)
            {
                Caption = 'Quantity for the new line';
                DecimalPlaces = 0 : 5;
                ShowMandatory = true;
            }
        }
    }

    var
        QtyToSplit: Decimal;

    procedure GetQuantity(): Decimal
    begin
        exit(QtyToSplit);
    end;
}