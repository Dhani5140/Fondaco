page 50104 "Installment Schedule"
{
    PageType = Card;
    SourceTable = "Installment Header";
    Caption = 'Installment Schedule';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = '';
                field("Amount to Installment"; Rec."Amount to Installment")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Promoted;
                }
                field("Contract No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the Sales Contract this installment schedule is linked to.';
                }
                field("Bank No."; Rec."Bank No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("No. of Periods"; Rec."No. of Periods")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
            }
            part(Lines; "Installment Schedule Subform")
            {
                ApplicationArea = All;
                Caption = 'Schedule Payment Detail';
                SubPageLink = "Document No." = field("Document No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CalculateSchedule)
            {
                Caption = 'Calculate Schedule';
                ApplicationArea = All;
                Image = CalculateLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Calculate installment schedule based on Amount, No. of Periods, and Start Date.';

                trigger OnAction()
                var
                    InstMgmt: Codeunit InstallmentManagement;
                begin
                    InstMgmt.CalculateSchedule(Rec);
                    CurrPage.Lines.Page.Update(false);
                    Message('%1 installment line(s) have been calculated.', Rec."No. of Periods");
                end;
            }
            action(PostingInstallment)
            {
                Caption = 'Posting Installment';
                ApplicationArea = All;
                Image = PostDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Post the installment lines that are marked with the Post checkbox.';

                trigger OnAction()
                var
                    InstMgmt: Codeunit InstallmentManagement;
                begin
                    InstMgmt.PostInstallment(Rec);
                    CurrPage.Lines.Page.Update(false);
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    var
        InstMgmt: Codeunit InstallmentManagement;
    begin
        InstMgmt.UpdateAppliedStatus(Rec."Document No.");
        CurrPage.Lines.Page.Update(false);
    end;
}