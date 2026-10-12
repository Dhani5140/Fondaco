tableextension 50181 "AR Overdue Cue" extends "Activities Cue"
{
    fields
    {
        field(50181; "AR Overdue Filter"; Date)
        {
            Caption = 'AR Overdue Filter';
            FieldClass = FlowFilter;
        }
        field(50182; "AR Overdue"; Integer)
        {
            Caption = 'Upcoming AR Overdue';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = count("Cust. Ledger Entry" where("Due Date" = field("AR Overdue Filter")));
        }
    }
}