tableextension 50140 "Warranty Exp Service Items" extends "Activities Cue"
{
    fields
    {
        field(50140; "Parts Warranty Exp."; Integer)
        {
            FieldClass = FlowField;
            Caption = 'Parts Warranty Exp.';
            Editable = false;
            CalcFormula = count("Service Item" where("Warranty Ending Date (Parts)" = field("Warranty Date Filter")));
        }
        field(50141; "Labor Warranty Exp."; Integer)
        {
            FieldClass = FlowField;
            Caption = 'Labor Warranty Exp.';
            Editable = false;
            CalcFormula = count("Service Item" where("Warranty Ending Date (Labor)" = field("Warranty Date Filter")));
        }

        field(50142; "Warranty Date Filter"; Date)
        {
            FieldClass = FlowFilter;
            Caption = 'Warranty Date Filter';
        }
    }
}