tableextension 50191 "Uninvoiced SO" extends "Activities Cue"
{
    fields
    {
        field(50191; "Uninvoiced SO"; Integer)
        {
            Caption = 'Uninvoiced Shipments';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = count("Sales Header" where("Amt. Ship. Not Inv. (LCY) Base" = filter(> 0)));
        }
    }
}