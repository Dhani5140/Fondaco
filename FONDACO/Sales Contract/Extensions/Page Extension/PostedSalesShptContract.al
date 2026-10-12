pageextension 50102 "Posted Sales Shpt. Contract" extends "Posted Sales Shipment"
{
    layout
    {
        addafter("External Document No.")
        {
            field("Contract No."; Rec."Contract No.")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the sales contract this shipment relates to.';
            }
        }
    }
}