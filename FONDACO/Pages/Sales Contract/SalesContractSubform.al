page 50101 "Sales Contract Subform"
{
    PageType = ListPart;
    SourceTable = "Sales Contract Line";
    Caption = 'Contract Lines';
    AutoSplitKey = true;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item category included in this contract.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Auto-filled from the item category.';
                }
            }
        }
    }
}