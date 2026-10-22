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
            field("Cicilan Advance Account No."; Rec."Cicilan Advance Account No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the G/L account used as balancing account (uang muka) when posting Sales Contract Cicilan invoices.';
            }
        }
    }
}