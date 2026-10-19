table 50102 "Sales Contract Inv. Lines"
{
    Caption = 'Sales Contract Invoice Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Package No."; Code[20]) { Caption = 'Package No.'; TableRelation = "Sales Contract Header"; }
        field(2; "Invoice No."; Code[20]) { Caption = 'Invoice No.'; }
        field(3; "Invoice Date"; Date) { Caption = 'Invoice Date'; }
        field(4; "Invoice Posted"; Boolean) { Caption = 'Invoice Posted'; Editable = false; }
        field(5; Description; Text[100]) { Caption = 'Invoice Description'; }
        field(6; "Invoice Last Printed Date"; Date) { Caption = 'Invoice Last Printed Date'; Editable = false; }
        field(7; Amount; Decimal) { Caption = 'Amount'; Editable = false; }
        field(8; "Cust. Ledger Entry No."; Integer) { Caption = 'Cust. Ledger Entry No.'; Editable = false; }
        field(9; "Remaining Amount"; Decimal)
        {
            Caption = 'Remaining Amount';
            FieldClass = FlowField;
            CalcFormula = sum("Detailed Cust. Ledg. Entry".Amount where("Cust. Ledger Entry No." = field("Cust. Ledger Entry No.")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Package No.", "Invoice No.") { Clustered = true; }
        key(ByDate; "Package No.", "Invoice Date") { }
    }
}