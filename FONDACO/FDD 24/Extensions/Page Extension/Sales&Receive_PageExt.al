pageextension 50100 "Sales & Receive. PageExt." extends "Sales & Receivables Setup"
{
    layout
    {
        addafter("Posted Prepmt. Cr. Memo Nos.")
        {
            field("Sales Package"; Rec."Sales Package")
            {
                ApplicationArea = All;
                Caption = 'Sales Package Nos.';
            }
        }
    }
}