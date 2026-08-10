codeunit 50102 InstallmentManagement
{
    procedure CalculateSchedule(var InstHeader: Record "Installment Header")
    var
        InstLine: Record "Installment Line";
        AmountPerPeriod: Decimal;
        SumPosted: Decimal;
        PostingDate: Date;
        LineNo: Integer;
        i: Integer;
    begin
        ValidateHeader(InstHeader);

        InstLine.SetRange("Document No.", InstHeader."Document No.");
        InstLine.SetRange(Status, InstLine.Status::Open);
        InstLine.DeleteAll(true);

        AmountPerPeriod := Round(InstHeader."Amount to Installment" / InstHeader."No. of Periods", 0.01);
        PostingDate := InstHeader."Start Date";
        LineNo := 10000;

        for i := 1 to InstHeader."No. of Periods" do begin
            InstLine.Init();
            InstLine."Document No." := InstHeader."Document No.";
            InstLine."Line No." := LineNo;
            InstLine."Posting Date" := PostingDate;
            InstLine.Description := 'Installment';
            InstLine.Status := InstLine.Status::Open;
            InstLine.Post := false;

            if i = InstHeader."No. of Periods" then
                InstLine.Amount := InstHeader."Amount to Installment" - SumPosted
            else begin
                InstLine.Amount := AmountPerPeriod;
                SumPosted += AmountPerPeriod;
            end;

            InstLine.Insert(true);

            PostingDate := CalcDate('<1M>', PostingDate);
            LineNo += 10000;
        end;
    end;

    procedure RedistributeAmounts(ChangedLine: Record "Installment Line")
    var
        InstHeader: Record "Installment Header";
        OtherLine: Record "Installment Line";
        RemainingAmount: Decimal;
        OtherLineCount: Integer;
        AmountPerLine: Decimal;
        SumAssigned: Decimal;
        LastLineNo: Integer;
    begin
        if not InstHeader.Get(ChangedLine."Document No.") then
            exit;

        if ChangedLine.Amount > InstHeader."Amount to Installment" then
            Error('Amount cannot exceed the total installment amount of %1.', InstHeader."Amount to Installment");

        RemainingAmount := InstHeader."Amount to Installment" - ChangedLine.Amount;

        OtherLine.SetRange("Document No.", ChangedLine."Document No.");
        OtherLine.SetRange(Status, OtherLine.Status::Open);
        OtherLine.SetFilter("Line No.", '<>%1', ChangedLine."Line No.");
        OtherLineCount := OtherLine.Count();

        if OtherLineCount = 0 then begin
            if ChangedLine.Amount <> InstHeader."Amount to Installment" then
                Error('There are no other lines to redistribute to. Amount must equal the total of %1.', InstHeader."Amount to Installment");
            exit;
        end;

        AmountPerLine := Round(RemainingAmount / OtherLineCount, 0.01);

        OtherLine.SetCurrentKey("Document No.", "Line No.");
        OtherLine.FindLast();
        LastLineNo := OtherLine."Line No.";

        OtherLine.SetRange("Document No.", ChangedLine."Document No.");
        OtherLine.SetRange(Status, OtherLine.Status::Open);
        OtherLine.SetFilter("Line No.", '<>%1', ChangedLine."Line No.");
        OtherLine.FindSet(true);

        repeat
            if OtherLine."Line No." = LastLineNo then
                OtherLine.Amount := RemainingAmount - SumAssigned
            else begin
                OtherLine.Amount := AmountPerLine;
                SumAssigned += AmountPerLine;
            end;
            OtherLine.Modify(true);
        until OtherLine.Next() = 0;
    end;

    procedure PostInstallment(var InstHeader: Record "Installment Header")
    var
        InstLine: Record "Installment Line";
        SalesContract: Record "Sales Contract Header";
        GenJnlLine: Record "Gen. Journal Line";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        JnlTemplateName: Code[10];
        JnlBatchName: Code[10];
        NextLineNo: Integer;
        PostedCount: Integer;
        LastEntryNo: Integer;
    begin
        InstLine.SetRange("Document No.", InstHeader."Document No.");
        InstLine.SetRange(Post, true);
        InstLine.SetRange(Status, InstLine.Status::Open);
        if not InstLine.FindSet(true) then
            Error('No installment lines are marked for posting. Please tick the Post checkbox on at least one Open line.');

        if not SalesContract.Get(InstHeader."Document No.") then
            Error('Sales Contract %1 could not be found.', InstHeader."Document No.");

        if not SalesContract.Get(InstHeader."Contract No.") then
            Error('Sales Contract %1 could not be found.', InstHeader."Contract No.");

        if InstHeader."Bank No." = '' then
            Error('Bank No. must be filled in on the Installment Header before posting.');

        GetOrCreateJournalBatch(JnlTemplateName, JnlBatchName);

        GenJnlLine.SetRange("Journal Template Name", JnlTemplateName);
        GenJnlLine.SetRange("Journal Batch Name", JnlBatchName);
        if GenJnlLine.FindLast() then
            NextLineNo := GenJnlLine."Line No." + 10000
        else
            NextLineNo := 10000;

        CustLedgerEntry.SetCurrentKey("Entry No.");
        if CustLedgerEntry.FindLast() then
            LastEntryNo := CustLedgerEntry."Entry No."
        else
            LastEntryNo := 0;

        repeat
            GenJnlLine.Init();
            GenJnlLine.Validate("Journal Template Name", JnlTemplateName);
            GenJnlLine.Validate("Journal Batch Name", JnlBatchName);
            GenJnlLine."Line No." := NextLineNo;
            GenJnlLine.Validate("Posting Date", InstLine."Posting Date");
            GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::Payment);
            GenJnlLine."Document No." := InstHeader."Document No.";
            GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::Customer);
            GenJnlLine.Validate("Account No.", SalesContract."Customer No.");  // ← was: SalesHeader."Sell-to Customer No."
            GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Bal. Account Type"::"Bank Account");
            GenJnlLine.Validate("Bal. Account No.", InstHeader."Bank No.");
            GenJnlLine.Validate(Amount, -InstLine.Amount);
            GenJnlLine.Description := InstLine.Description + ' - ' + InstHeader."Document No.";
            GenJnlLine."Source Code" := 'INSTALLMT';
            GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::" ";
            GenJnlLine."Applies-to Doc. No." := '';
            GenJnlLine."Applies-to ID" := '';
            GenJnlLine.Insert(true);

            GenJnlPostLine.RunWithCheck(GenJnlLine);

            if GenJnlLine.Get(JnlTemplateName, JnlBatchName, NextLineNo) then
                GenJnlLine.Delete(true);

            CustLedgerEntry.Reset();
            CustLedgerEntry.SetFilter("Entry No.", '>%1', LastEntryNo);
            CustLedgerEntry.SetRange("Customer No.", SalesContract."Customer No.");  // ← was: SalesHeader."Sell-to Customer No."
            CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Payment);
            CustLedgerEntry.SetRange("Document No.", InstHeader."Document No.");
            CustLedgerEntry.SetRange("Posting Date", InstLine."Posting Date");
            if CustLedgerEntry.FindLast() then begin
                InstLine."Cust. Ledger Entry No." := CustLedgerEntry."Entry No.";
                LastEntryNo := CustLedgerEntry."Entry No.";
            end;

            InstLine.Status := InstLine.Status::Invoice;
            InstLine.Post := false;
            InstLine.Modify(true);

            NextLineNo += 10000;
            PostedCount += 1;
        until InstLine.Next() = 0;

        Message('%1 installment line(s) have been posted successfully.', PostedCount);
    end;

    procedure CancelPostInstallment(var InstLine: Record "Installment Line")
    var
        InstHeader: Record "Installment Header";
        SalesContract: Record "Sales Contract Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        JnlTemplateName: Code[10];
        JnlBatchName: Code[10];
        NextLineNo: Integer;
    begin
        if not InstHeader.Get(InstLine."Document No.") then
            Error('Installment Header for Document %1 not found.', InstLine."Document No.");

        if not CustLedgerEntry.Get(InstLine."Cust. Ledger Entry No.") then
            Error('Cust. Ledger Entry No. %1 could not be found.', InstLine."Cust. Ledger Entry No.");

        if not SalesContract.Get(InstLine."Document No.") then
            Error('Sales Contract %1 could not be found.', InstLine."Document No.");

        if not SalesContract.Get(InstHeader."Contract No.") then
            Error('Sales Contract %1 could not be found.', InstHeader."Contract No.");

        if InstLine.Status = InstLine.Status::Paid then begin
            InstLine.Status := InstLine.Status::Invoice;
            InstLine.Post := false;
            InstLine.Modify(true);
            Commit();
            UpdateAppliedStatus(InstLine."Document No.");
            Message('Installment line dated %1 has been reset to Invoice. Please unapply the ledger entry manually.', InstLine."Posting Date");
            exit;
        end;

        GetOrCreateJournalBatch(JnlTemplateName, JnlBatchName);

        CustLedgerEntry."Applies-to ID" := 'REVERSAL';
        CustLedgerEntry."Amount to Apply" := CustLedgerEntry."Remaining Amount";
        CustLedgerEntry.Modify(true);

        GenJnlLine.SetRange("Journal Template Name", JnlTemplateName);
        GenJnlLine.SetRange("Journal Batch Name", JnlBatchName);
        if GenJnlLine.FindLast() then
            NextLineNo := GenJnlLine."Line No." + 10000
        else
            NextLineNo := 10000;

        GenJnlLine.Init();
        GenJnlLine.Validate("Journal Template Name", JnlTemplateName);
        GenJnlLine.Validate("Journal Batch Name", JnlBatchName);
        GenJnlLine."Line No." := NextLineNo;
        GenJnlLine.Validate("Posting Date", Today());
        GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::Refund);
        GenJnlLine."Document No." := InstLine."Document No.";
        GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::Customer);
        GenJnlLine.Validate("Account No.", SalesContract."Customer No.");  // ← was: SalesHeader."Sell-to Customer No."
        GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Bal. Account Type"::"Bank Account");
        GenJnlLine.Validate("Bal. Account No.", InstHeader."Bank No.");
        GenJnlLine.Validate(Amount, InstLine.Amount);
        GenJnlLine.Description := 'Reversal - ' + InstLine.Description + ' - ' + InstLine."Document No.";
        GenJnlLine."Applies-to ID" := 'REVERSAL';
        GenJnlLine.Insert(true);

        GenJnlPostLine.RunWithCheck(GenJnlLine);

        if GenJnlLine.Get(JnlTemplateName, JnlBatchName, NextLineNo) then
            GenJnlLine.Delete(true);

        InstLine.Status := InstLine.Status::Open;
        InstLine.Post := false;
        InstLine."Cust. Ledger Entry No." := 0;
        InstLine.Modify(true);

        Message('Installment line dated %1 has been reversed successfully.', InstLine."Posting Date");
    end;

    procedure BuildPreviewLines(PaymentEntry: Record "Cust. Ledger Entry"; ContractNo: Code[20]; var TempPreviewLine: Record "Auto Apply Preview Line" temporary)
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        InvoiceEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        RemainingPayment: Decimal;
        AmountToApply: Decimal;
    begin
        TempPreviewLine.Reset();
        TempPreviewLine.DeleteAll();

        PaymentEntry.CalcFields("Remaining Amount");
        RemainingPayment := Abs(PaymentEntry."Remaining Amount");

        if RemainingPayment <= 0 then exit;

        if Customer.Get(PaymentEntry."Customer No.") then;

        InvoiceEntry.SetCurrentKey("Customer No.", "Posting Date");
        InvoiceEntry.SetRange("Customer No.", PaymentEntry."Customer No.");
        InvoiceEntry.SetRange("Document Type", InvoiceEntry."Document Type"::Invoice);
        InvoiceEntry.SetRange(Open, true);
        InvoiceEntry.SetFilter("Posting Date", '<=%1', PaymentEntry."Posting Date");

        if not InvoiceEntry.FindSet() then exit;

        repeat
            SalesInvoiceLine.SetRange("Document No.", InvoiceEntry."Document No.");
            SalesInvoiceLine.SetRange("Contract No.", ContractNo);

            if SalesInvoiceLine.FindFirst() then begin
                InvoiceEntry.CalcFields("Remaining Amount");

                if InvoiceEntry."Remaining Amount" > 0 then begin
                    if InvoiceEntry."Remaining Amount" <= RemainingPayment then
                        AmountToApply := InvoiceEntry."Remaining Amount"
                    else
                        AmountToApply := RemainingPayment;

                    TempPreviewLine.Init();
                    TempPreviewLine."Entry No." := InvoiceEntry."Entry No.";
                    TempPreviewLine."Document No." := InvoiceEntry."Document No.";
                    TempPreviewLine."Posting Date" := InvoiceEntry."Posting Date";
                    TempPreviewLine."Customer No." := InvoiceEntry."Customer No.";
                    TempPreviewLine."Customer Name" := Customer.Name;
                    TempPreviewLine."Original Amount" := InvoiceEntry.Amount;
                    TempPreviewLine."Remaining Amount" := InvoiceEntry."Remaining Amount";
                    TempPreviewLine."Amount to Apply" := AmountToApply;
                    TempPreviewLine."BSO Document No." := PaymentEntry."Document No.";
                    TempPreviewLine.Insert();

                    RemainingPayment -= AmountToApply;
                end;
            end;
        until (InvoiceEntry.Next() = 0) or (RemainingPayment <= 0);
    end;

    procedure ExecuteAutoApply(PaymentEntryNo: Integer; var TempPreviewLine: Record "Auto Apply Preview Line" temporary)
    var
        PaymentEntry: Record "Cust. Ledger Entry";
        InvoiceEntry: Record "Cust. Ledger Entry";
        CustEntryApplyPostedEntries: Codeunit "CustEntry-Apply Posted Entries";
        ApplyUnapplyParameters: Record "Apply Unapply Parameters";
        AppliesToID: Code[50];
        TotalApplied: Decimal;
    begin
        if not PaymentEntry.Get(PaymentEntryNo) then
            Error('Payment Entry No. %1 could not be found.', PaymentEntryNo);

        if not PaymentEntry.Open then
            Error('Payment entry is already closed.');

        AppliesToID := Format(PaymentEntryNo);

        TempPreviewLine.Reset();
        if TempPreviewLine.FindSet() then
            repeat
                if InvoiceEntry.Get(TempPreviewLine."Entry No.") then begin
                    InvoiceEntry."Applies-to ID" := AppliesToID;
                    InvoiceEntry."Amount to Apply" := TempPreviewLine."Amount to Apply";
                    InvoiceEntry.Modify(true);
                    TotalApplied += TempPreviewLine."Amount to Apply";
                end;
            until TempPreviewLine.Next() = 0;

        PaymentEntry.CalcFields("Remaining Amount");
        PaymentEntry."Applies-to ID" := AppliesToID;
        PaymentEntry."Amount to Apply" := -TotalApplied;
        PaymentEntry.Modify(true);

        ApplyUnapplyParameters.Init();
        ApplyUnapplyParameters."Document No." := PaymentEntry."Document No.";
        ApplyUnapplyParameters."Posting Date" := PaymentEntry."Posting Date";
        ApplyUnapplyParameters."Journal Template Name" := 'GENERAL';
        ApplyUnapplyParameters."Journal Batch Name" := 'INSTALLMT';

        if PaymentEntry."Applies-to ID" = '' then
            Error('Applies-to ID not set on Payment entry.');

        CustEntryApplyPostedEntries.Apply(PaymentEntry, ApplyUnapplyParameters);
        Commit();
        PaymentEntry.CalcFields("Remaining Amount");
        if PaymentEntry."Remaining Amount" <> 0 then
            Error('Apply failed — Payment entry %1 still has remaining amount %2. Check that GENERAL/INSTALLMT journal batch exists.',
                PaymentEntryNo, PaymentEntry."Remaining Amount");
        UpdateAppliedStatus(PaymentEntry."Document No.");
    end;

    procedure UpdateAppliedStatus(DocumentNo: Code[20])
    var
        InstLine: Record "Installment Line";
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        InstLine.SetRange("Document No.", DocumentNo);
        InstLine.SetFilter(Status, '%1|%2', InstLine.Status::Invoice, InstLine.Status::Paid);

        if not InstLine.FindSet(true) then
            exit;

        repeat
            if InstLine."Cust. Ledger Entry No." <> 0 then begin
                CustLedgerEntry.Reset();
                if CustLedgerEntry.Get(InstLine."Cust. Ledger Entry No.") then begin
                    CustLedgerEntry.CalcFields(Amount, "Remaining Amount");

                    if (CustLedgerEntry."Remaining Amount" = 0) and (not CustLedgerEntry.Reversed) then begin
                        InstLine.Status := InstLine.Status::Paid;
                        InstLine.Post := true;
                        InstLine.Modify(true);
                    end else
                        if (CustLedgerEntry."Remaining Amount" = 0) and CustLedgerEntry.Reversed then begin
                            InstLine.Status := InstLine.Status::Open;
                            InstLine.Post := false;
                            InstLine."Cust. Ledger Entry No." := 0;
                            InstLine.Modify(true);
                        end else
                            if Abs(CustLedgerEntry."Remaining Amount") = Abs(CustLedgerEntry.Amount) then begin
                                InstLine.Status := InstLine.Status::Invoice;
                                InstLine.Post := false;
                                InstLine.Modify(true);
                            end;
                end;
            end;
        until InstLine.Next() = 0;
    end;

    local procedure ValidateHeader(InstHeader: Record "Installment Header")
    begin
        if InstHeader."No. of Periods" <= 0 then
            Error('No. of Periods must be greater than 0 before calculating the schedule.');
        if InstHeader."Amount to Installment" <= 0 then
            Error('Amount to Installment must be greater than 0 before calculating the schedule.');
        if InstHeader."Start Date" = 0D then
            Error('Start Date must be filled in before calculating the schedule.');
    end;

    local procedure GetOrCreateJournalBatch(var TemplateName: Code[10]; var BatchName: Code[10])
    var
        GenJnlTemplate: Record "Gen. Journal Template";
    begin
        TemplateName := 'GENERAL';
        BatchName := 'INSTALLMT';

        if not GenJnlTemplate.Get(TemplateName) then
            Error('Journal Template %1 does not exist. Please create it in the General Journal Templates page.', TemplateName);
    end;
}