table 50102 "Sales Contract Inv. Header"
{
    fields
    {
        field(1; "Invoice No."; Code[30])
        {
            Caption = 'Invoice No.';
        }
        field(2; "Invoice Date"; Date)
        {
            Caption = 'Invoice Date';
        }
        field(3; "Fully Paid"; Boolean)
        {
            Caption = 'Fully Paid';
        }
        field(4; "Posted Status"; Boolean)
        {
            Caption = 'Invoice Posted';
        }
        field(5; "Description"; Text[100])
        {
            Caption = 'Invoice Description';
        }
        field(6; "Invoice Last"; Date)
        {
            Caption = 'Invoice Last Printed';
        }
        field(7; "Amount"; Decimal)
        {
            Caption = 'Amount';
        }
        field(8; "Remaining Amount"; Decimal)
        {
            Caption = 'Remaining Amount';
        }
    }

    // keys
    // {
    //     key(Key1; MyField)
    //     {
    //         Clustered = true;
    //     }
    // }
}