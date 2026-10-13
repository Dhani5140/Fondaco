page 50102 "Sales Contract List"
{
    PageType = List;
    SourceTable = "Sales Contract Header";
    Caption = 'Sales Contract List';
    UsageCategory = Lists;
    ApplicationArea = All;
    CardPageId = "Sales Contract";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Contracts)
            {
                field("No."; Rec."No.") { ApplicationArea = All; ToolTip = 'Specifies the contract number.'; }
                field("Customer No."; Rec."Customer No.") { ApplicationArea = All; ToolTip = 'Specifies the customer number.'; }
                field("Customer Name"; Rec."Customer Name") { ApplicationArea = All; ToolTip = 'Specifies the customer name.'; }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer''s reference for this contract.';
                }
                field("Contract Date"; Rec."Contract Date") { ApplicationArea = All; ToolTip = 'Specifies the contract date.'; }
                field("Expiry Date"; Rec."Expiry Date") { ApplicationArea = All; ToolTip = 'Specifies the expiry date.'; }
                field(Status; Rec.Status) { ApplicationArea = All; ToolTip = 'Specifies the current status.'; }
                field("Max. Quantity"; Rec."Max. Quantity") { ApplicationArea = All; ToolTip = 'Specifies the contracted quantity ceiling.'; }
                field("Max. Amount"; Rec."Max. Amount") { ApplicationArea = All; ToolTip = 'Specifies the contracted amount ceiling.'; }
            }
        }
        area(FactBoxes)
        {
            systempart(Links; Links) { ApplicationArea = All; }
            systempart(Notes; Notes) { ApplicationArea = All; }
        }
    }
}