pageextension 50170 "Whse Receipt Ext." extends "Whse. Receipt Subform"
{
    layout
    {
        addafter("Qty. to Receive")
        {
            field("Direct Unit Cost Excl. VAT"; Rec."Direct Unit Cost Excl. VAT")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("Line Amount"; Rec."Line Amount")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("Line Discount %"; Rec."Line Discount %")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }
}