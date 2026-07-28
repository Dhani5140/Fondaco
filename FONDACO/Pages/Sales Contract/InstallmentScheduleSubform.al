page 50103 "Installment Schedule Subform"
{
    PageType = ListPart;
    SourceTable = "Installment Line";
    Caption = 'Schedule Payment Detail';
    InsertAllowed = false;
    DeleteAllowed = false;
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Open;
                    StyleExpr = LineStyle;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Open;
                    StyleExpr = LineStyle;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = LineStyle;
                }
                field(Post; Rec.Post)
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Open;
                    StyleExpr = LineStyle;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Open;
                    StyleExpr = LineStyle;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;
                }
                field("Cust. Ledger Entry No."; Rec."Cust. Ledger Entry No.")
                {
                    ApplicationArea = All;
                    Caption = 'CustLedgerNo';
                    Editable = false;
                    StyleExpr = LineStyle;

                    trigger OnDrillDown()
                    var
                        CustLedgerEntry: Record "Cust. Ledger Entry";
                    begin
                        if Rec."Cust. Ledger Entry No." <> 0 then begin
                            CustLedgerEntry.SetRange("Entry No.", Rec."Cust. Ledger Entry No.");
                            Page.Run(Page::"Customer Ledger Entries", CustLedgerEntry);
                        end;
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CancelPosting)
            {
                Caption = 'Cancel Posting';
                ApplicationArea = All;
                Image = Cancel;
                ToolTip = 'Reverse the selected posted installment line and reset it to Open.';

                trigger OnAction()
                var
                    InstMgmt: Codeunit InstallmentManagement;
                begin
                    if (Rec.Status <> Rec.Status::Invoice) and (Rec.Status <> Rec.Status::Paid) then
                        Error('You can only cancel a line with status Invoice or Paid.');

                    if not Confirm('Reverse installment line dated %1 with amount %2 and reset it to Open?',
                        false, Rec."Posting Date", Rec.Amount) then
                        exit;

                    InstMgmt.CancelPostInstallment(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetLineStyle();
    end;

    local procedure SetLineStyle()
    begin
        case Rec.Status of
            Rec.Status::Open:
                LineStyle := 'Standard';
            Rec.Status::Invoice:
                LineStyle := 'Favorable';
            Rec.Status::Paid:
                LineStyle := 'Strong';
        end;
    end;

    var
        LineStyle: Text;
}