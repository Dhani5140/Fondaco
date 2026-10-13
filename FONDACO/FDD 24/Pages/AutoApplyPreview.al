page 50105 "Auto Apply Preview"
{
    PageType = List;
    SourceTable = "Auto Apply Preview Line";
    SourceTableTemporary = true;
    Caption = 'Auto Apply Preview';
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            group(PaymentInfo)
            {
                Caption = 'Payment Entry';
                field(PaymentEntryNo; PaymentEntryNo)
                {
                    ApplicationArea = All;
                    Caption = 'Payment Entry No.';
                    Editable = false;
                }
                field(PaymentDocNo; PaymentDocNo)
                {
                    ApplicationArea = All;
                    Caption = 'Payment Document No.';
                    Editable = false;
                }
                field(PaymentDate; PaymentDate)
                {
                    ApplicationArea = All;
                    Caption = 'Payment Date';
                    Editable = false;
                }
                field(PaymentAmount; PaymentAmount)
                {
                    ApplicationArea = All;
                    Caption = 'Payment Amount';
                    Editable = false;
                    AutoFormatType = 1;
                }
                field(TotalToApply; TotalToApply)
                {
                    ApplicationArea = All;
                    Caption = 'Total to Apply';
                    Editable = false;
                    AutoFormatType = 1;
                    Style = Strong;
                }
            }
            repeater(Lines)
            {
                Caption = 'Invoices to Apply';
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Caption = 'Invoice Entry No.';
                    Editable = false;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Original Amount"; Rec."Original Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Remaining Amount"; Rec."Remaining Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Amount to Apply"; Rec."Amount to Apply")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Style = Favorable;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ConfirmApply)
            {
                Caption = 'Confirm & Apply';
                ApplicationArea = All;
                Image = ApplyEntries;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Execute the auto apply based on the preview above.';

                trigger OnAction()
                var
                    InstMgmt: Codeunit InstallmentManagement;
                begin
                    if not Confirm('Apply %1 invoice(s) against Payment Entry No. %2 with total amount %3? This cannot be undone.',
                        false, Rec.Count(), PaymentEntryNo, TotalToApply) then
                        exit;

                    InstMgmt.ExecuteAutoApply(PaymentEntryNo, Rec);
                    Message('Auto Apply completed. %1 invoice(s) have been applied successfully.', Rec.Count());
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CalcTotalToApply();
    end;

    trigger OnOpenPage()
    begin
        CalcTotalToApply();
    end;

    local procedure CalcTotalToApply()
    var
        PreviewLine: Record "Auto Apply Preview Line";
    begin
        TotalToApply := 0;
        PreviewLine.Copy(Rec, true);
        if PreviewLine.FindSet() then
            repeat
                TotalToApply += PreviewLine."Amount to Apply";
            until PreviewLine.Next() = 0;
    end;

    procedure SetPaymentInfo(EntryNo: Integer; DocNo: Code[20]; PostingDate: Date; Amount: Decimal)
    begin
        PaymentEntryNo := EntryNo;
        PaymentDocNo := DocNo;
        PaymentDate := PostingDate;
        PaymentAmount := Amount;
    end;

    procedure SetLines(var TempPreviewLine: Record "Auto Apply Preview Line" temporary)
    begin
        Rec.Copy(TempPreviewLine, true);
    end;

    var
        PaymentEntryNo: Integer;
        PaymentDocNo: Code[20];
        PaymentDate: Date;
        PaymentAmount: Decimal;
        TotalToApply: Decimal;
}
