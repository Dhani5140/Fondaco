pageextension 50155 "Parent Customer Field" extends "Customer Card"
{
    layout
    {
        addafter("Last Date Modified")
        {
            field("Is Parent Customer"; Rec."Is Parent Customer")
            {
                ApplicationArea = all;
                Caption = 'Is Parent Customer';
                ToolTip = 'Specify whether this customer is a parent customer.';

                trigger OnValidate()
                begin
                    CurrPage.Update();
                end;
            }
            field("Parent Customer No."; Rec."Parent Customer No.")
            {
                ApplicationArea = all;
                Caption = 'Parent Customer No.';
                ToolTip = 'Specify the parent customer this customer belongs to.';
                Editable = not Rec."Is Parent Customer";
            }
        }
    }
}