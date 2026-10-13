pageextension 50101 "Posted SI Contract Ext." extends "Posted Sales Invoice Subform"
{
    layout
    {
        addafter("No.")
        {
            field("Contract No."; Rec."Contract No.")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the sales contract this invoice was posted against.';
            }
        }
    }
}