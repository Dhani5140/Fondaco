codeunit 50101 "Invoice Posting Mgt."
{
    TableNo = "Sales Contract Inv. Lines";

    trigger OnRun()
    begin
        PostSingle(Rec);
    end;

    procedure PostSingle(var InvLine: Record "Sales Contract Inv. Lines")
    var
        Header: Record "Sales Contract Header";
        SalesSetup: Record "Sales & Receivables Setup";
        SourceCodeSetup: Record "Source Code Setup";
        GenJnlLine: Record "Gen. Journal Line";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        if InvLine."Invoice Posted" then
            Error('Invoice %1 is already posted.', InvLine."Invoice No.");
        InvLine.TestField(Amount);
        InvLine.TestField("Invoice Date");

        Header.Get(InvLine."Package No.");

        if Header.Status = Header.Status::Cancelled then
            Error('Contract %1 was cancelled. Please pick another contract to post', Header."Package No.");
        Header.TestField("Customer No.");

        SourceCodeSetup.Get();

        GenJnlLine.Init();
        GenJnlLine."Posting Date" := InvLine."Invoice Date";
        GenJnlLine."Document Date" := InvLine."Invoice Date";
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Invoice;
        GenJnlLine."Document No." := InvLine."Invoice No.";
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
        GenJnlLine.Validate("Account No.", Header."Customer No.");

        if Header."Customer Posting Group" <> '' then
            GenJnlLine.Validate("Posting Group", Header."Customer Posting Group");

        GenJnlLine.Description := InvLine.Description;
        GenJnlLine.Validate("Currency Code", Header."Currency Code");
        GenJnlLine.Validate(Amount, InvLine.Amount);
        GenJnlLine.Validate("Payment Terms Code", Header."Payment Terms Code");
        GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
        GenJnlLine.Validate("Bal. Account No.", '2.01.04A'); // <- To be confirm
        GenJnlLine."Sales Package No." := Header."Package No.";
        GenJnlLine."Source Code" := SourceCodeSetup."General Journal";
        GenJnlLine.Insert(true);

        GenJnlPostLine.RunWithCheck(GenJnlLine);

        CustLedgerEntry.SetRange("Customer No.", Header."Customer No.");
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange("Document No.", InvLine."Invoice No.");
        CustLedgerEntry.SetRange("Sales Package No.", Header."Package No.");
        CustLedgerEntry.SetRange(Reversed, false);
        if not CustLedgerEntry.FindLast() then
            Error('The customer ledger entry for invoice %1 couldnt be found.', InvLine."Invoice No.");

        InvLine."Cust. Ledger Entry No." := CustLedgerEntry."Entry No.";
        InvLine."Invoice Posted" := true;

        InvLine.Modify(true);
    end;

    procedure PostBatch(PackageNo: Code[20]; FromDate: Date; ToDate: Date)
    var
        InvLine: Record "Sales Contract Inv. Lines";
        Errors: TextBuilder;
        PostedCount: Integer;
        FailedCount: Integer;
    begin
        InvLine.SetCurrentKey("Package No.", "Invoice Date");
        InvLine.SetRange("Invoice Posted", false);
        InvLine.SetRange("Invoice Date", FromDate, ToDate);
        if PackageNo <> '' then
            InvLine.SetRange("Package No.", PackageNo);

        if not InvLine.FindSet() then begin
            Message('No unposted invoice between %1 and %2', FromDate, ToDate);
            exit;

            repeat
                Commit();
                if Codeunit.Run(Codeunit::"Invoice Posting Mgt.", InvLine) then
                    PostedCount += 1
                else begin
                    FailedCount += 1;
                    Errors.AppendLine(StrSubstNo('%1: %2', InvLine."Invoice No.", GetLastErrorText()));
                end;
            until InvLine.Next() = 0;

            if FailedCount = 0 then
                Message('%1 Invoice(s) line succesfully posted', PostedCount)
            else
                Message('%1 Invoice(s) line succesfully posted\ %2 Invoice(s) line failed', PostedCount, FailedCount);
        end;
    end;

    procedure ReverseInvoice()
    var
    begin
        // To be confirm with functional
    end;
}