page 50106 "Invoices Installment"
{
    Caption = 'Invoices Installment';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Sales Contract Inv. Lines";
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Invoice No."; Rec."Invoice No.") { Editable = false; }
                field("Invoice Date"; Rec."Invoice Date") { Editable = ParentEditable and not Rec."Invoice Posted"; }
                field(FullyPaid; FullyPaid) { Caption = 'Fully Paid'; Editable = false; }
                field("Invoice Posted"; Rec."Invoice Posted") { Editable = false; }
                field(Description; Rec.Description) { Editable = ParentEditable and not Rec."Invoice Posted"; }
                field("Invoice Last Printed Date"; Rec."Invoice Last Printed Date") { Editable = false; }
                field(Amount; Rec.Amount) { Editable = false; }
                field(RemainingAmountDisplay; RemainingAmountDisplay) { Caption = 'Remaining Amount'; Editable = false; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(PostInvoice)
            {
                Caption = 'Post Invoice';
                Image = PostOrder;
                Enabled = not Rec."Invoice Posted";

                trigger OnAction()
                var
                    ContractPosting: Codeunit "Invoice Posting Mgt.";
                    ConfirmQst: Label 'Post invoice %1?', Comment = '%1 = Invoice No.';
                begin
                    if not Confirm(ConfirmQst, false, Rec."Invoice No.") then
                        exit;
                    ContractPosting.PostSingle(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(BatchPostInvoice)
            {
                Caption = 'Batch Post Invoice';
                Image = PostBatch;

                trigger OnAction()
                var
                    BatchPage: Page "Batch Posting PopUp";
                    FromDate: Date;
                    ToDate: Date;
                    PostingMgt: Codeunit "Invoice Posting Mgt.";
                begin
                    if BatchPage.RunModal() <> Action::OK then exit;
                    BatchPage.GetDates(FromDate, ToDate);
                    PostingMgt.PostBatch(PackageNo, FromDate, ToDate);
                    CurrPage.Update(false);
                end;
            }
            action(SendPrintInvoice)
            {
                Caption = 'Send/Print Invoice';
                Image = PostPrint;

                // To be confirm by functional
            }
            action(PrintInvoice)
            {
                Caption = 'Print Invoice';
                Image = Print;

                // To be confirm by functional
            }
            action(ReverseInvoice)
            {
                Caption = 'Reverse Invoice';
                Image = Create;

                // To be confirm by functional
            }
        }
        area(Promoted)
        {
            actionref(PostInvoice_Promoted; PostInvoice) { }
            actionref(BatchPostInvoice_Promoted; BatchPostInvoice) { }
            actionref(SendPrintInvoice_Promoted; SendPrintInvoice) { }
            actionref(PrintInvoice_Promoted; PrintInvoice) { }
            actionref(ReverseInvoice_Promoted; ReverseInvoice) { }
        }
    }

    var
        PackageNo: Code[20];
        ParentEditable: Boolean;
        FullyPaid: Boolean;
        RemainingAmountDisplay: Decimal;

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Remaining Amount");
        if Rec."Invoice Posted" then
            RemainingAmountDisplay := Rec."Remaining Amount"
        else
            RemainingAmountDisplay := Rec.Amount;
        FullyPaid := Rec."Invoice Posted" and (RemainingAmountDisplay = 0);
    end;

    procedure SetContext(NewPackageNo: Code[20]; NewEditable: Boolean)
    begin
        PackageNo := NewPackageNo;
        ParentEditable := NewEditable;
    end;
}