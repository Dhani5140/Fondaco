tableextension 50136 "Days Due Table Ext." extends "Activities Cue"
{
    fields
    {
        field(50136; "Service Contracts Due"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Service Contract Header" where(Status = const(Signed), "Expiration Date" = field("Date Filter Service")));
            Caption = 'Service Contracts Due';
            Editable = false;
        }
        field(50137; "Date Filter Service"; Date)
        {
            FieldClass = FlowFilter;
            Caption = 'Date Filter';
        }
    }
}