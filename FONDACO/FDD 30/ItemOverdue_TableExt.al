tableextension 50186 "Item Upcoming Expiration" extends "Activities Cue"
{
    fields
    {
        field(50186; "Items Near Exp. Filter"; Date)
        {
            Caption = 'Item Exp. Filter';
            FieldClass = FlowFilter;
        }
        field(50187; "Items Near Expiration"; Integer)
        {
            Caption = 'Items Near Expiration';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = count("Item Ledger Entry" where("Expiration Date" = field("Items Near Exp. Filter"),
                                                          "Remaining Quantity" = filter(> 0)));
        }
    }
}