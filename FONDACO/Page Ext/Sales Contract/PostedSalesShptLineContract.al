pageextension 50103 "Posted Sales Shpt. Lines" extends "Posted Sales Shipment Lines"
{
    layout
    {
        addafter("No.")
        {
            field("Contract No."; Rec."Contract No.")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the sales contract this line relates to.';
            }
        }
    }
}