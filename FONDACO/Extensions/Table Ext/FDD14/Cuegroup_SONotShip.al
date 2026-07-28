tableextension 50121 "Sales Order Not Shipped Ext." extends "Activities Cue"
{
    fields
    {
        field(50100; "Sales Order Not Shipped"; Integer)
        {
            Caption = 'Sales Order Not Shipped';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = count("Sales Header" where
                        ("Document Type" = const(Order),
                        Status = const(Released),
                        "Completely Shipped" = const(false)));
        }
    }
}