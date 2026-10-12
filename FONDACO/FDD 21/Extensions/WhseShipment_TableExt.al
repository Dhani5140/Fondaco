tableextension 50170 "Whse Receipt Ext." extends "Warehouse Receipt Line"
{
    fields
    {
        field(50170; "Direct Unit Cost Excl. VAT"; Decimal)
        {
            Caption = 'Direct Unit Cost Excl. VAT';
            FieldClass = FlowField;
            CalcFormula = lookup("Purchase Line"."Direct Unit Cost" where(
                "Document Type" = const(Order),
                "Document No." = field("Source No."),
                "Line No." = field("Source Line No.")));
            Editable = false;
            DecimalPlaces = 2 : 5;
        }
        field(50171; "Line Amount"; Decimal)
        {
            Caption = 'Line Amount';
            FieldClass = FlowField;
            CalcFormula = lookup("Purchase Line"."Line Amount" where(
                "Document Type" = const(Order),
                "Document No." = field("Source No."),
                "Line No." = field("Source Line No.")));
            Editable = false;
            DecimalPlaces = 2 : 2;
        }
        field(50172; "Line Discount %"; Decimal)
        {
            Caption = 'Line Discount %';
            FieldClass = FlowField;
            CalcFormula = lookup("Purchase Line"."Line Discount %" where(
                "Document Type" = const(Order),
                "Document No." = field("Source No."),
                "Line No." = field("Source Line No.")));
            Editable = false;
            DecimalPlaces = 0 : 5;
        }
    }
}