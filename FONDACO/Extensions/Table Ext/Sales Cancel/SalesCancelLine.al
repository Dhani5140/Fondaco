tableextension 50112 SalesCancleQtyExtension extends "Sales Line"
{
    fields
    {
        field(50101; "Cancel Qty."; Decimal)
        {
            DecimalPlaces = 0 : 5;
            Caption = 'Cancelled Qty.';
            BlankZero = true;
        }

        field(50102; "Cancel Status"; Enum YesOrNoStatus)
        {
            Caption = 'Cancel Status';
        }
    }
}