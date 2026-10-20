codeunit 50100 "Sales Contract Mgt."
{
    procedure ReopenContract(var Header: Record "Sales Contract Header")
    begin
        if Header.Status = Header.Status::Open then
            Error('Cannot re-open contract when the contract is open.');

        Header.Status := Header.Status::Open;
        Header.Modify(true);

        // Confirmation archive sales contract ke functional
    end;

    procedure CancelContract(var Header: Record "Sales Contract Header")
    begin
        if Header.Status = Header.Status::Cancelled then
            Error('The contract is already cancelled.');

        Header.Status := Header.Status::Cancelled;
        Header.Modify(true);

        // Confirmation cancel function ke functional
    end;

    procedure LockContract(var Header: Record "Sales Contract Header")
    begin
        Header.TestField(Status, Header.Status::Open);
        ValidateLockContract(Header);
        Header.Status := Header.Status::Locked;
        Header.Modify(true);
    end;

    local procedure ValidateLockContract(Header: Record "Sales Contract Header")
    var
        Line: Record "Sales Contract Lines";
    begin
        Line.SetRange("Package No.", Header."Package No.");

        if not Line.FindSet() then
            Error('The contract has no lines');
        repeat
            if ((Line."Item No." = '') = (Line."Item Category Options" = '')) or
               (Line."Unit of Measure Code" = '') or (Line.Quantity <= 0) or
               (Line."VAT Prod. Posting Group" = '')
                        then
                Error('Line %1: fill in either Item No. or Item Category Options, plus Unit of Measure and Quantity.', Line."Line No.");
        until Line.Next() = 0;
    end;

    procedure GenerateInvoiceLine(var Header: Record "Sales Contract Header")
    var
        InvLine: Record "Sales Contract Inv. Lines";
        NoSeries: Codeunit "No. Series";
        ReusableNos: List of [Code[20]];
        InvoiceDates: List of [Date];
        NextDate: Date;
        PrevDate: Date;
        InvoiceNo: Code[20];
        PostedCount, TotalCount, UnpostedCount, i : Integer;
        PostedTotal, Remaining, Instalment, Assigned : Decimal;
        DescriptionTxt: Label 'Cicilan %1/%2 [%3]', Locked = true;
    begin
        Header.TestField(Status, Header.Status::Open);
        Header.TestField("Faktur Cicilan Nos.");
        Header.TestField("Faktur Pengiriman Nos.");
        Header.TestField("Invoice Period");
        Header.TestField("Contract End Date");
        Header.TestField("No. Penawaran");
        Header.CalcFields("Total Contract Value");

        // Calculate schedule
        NextDate := Header."Contract Start Date";
        while NextDate <= Header."Contract End Date" do begin
            InvoiceDates.Add(NextDate);
            PrevDate := NextDate;
            NextDate := CalcDate(Header."Invoice Period", NextDate);
            if NextDate <= PrevDate then
                Error('Invoice period must move the date forward');
        end;
        TotalCount := InvoiceDates.Count();

        // Posted lines are kept while refreshing unposted lines
        InvLine.SetRange("Package No.", Header."Package No.");
        InvLine.SetRange("Invoice Posted", true);
        PostedCount := InvLine.Count();
        InvLine.CalcSums(Amount);
        PostedTotal := InvLine.Amount;

        UnpostedCount := TotalCount - PostedCount;
        if UnpostedCount <= 0 then
            Error('The posted invoices already cover the whole schedule. Nothing to generate.');

        // Remove old unposted lines
        InvLine.SetRange("Invoice Posted", false);
        InvLine.SetCurrentKey("Package No.", "Invoice Date");
        if InvLine.FindSet() then
            repeat
                ReusableNos.Add(InvLine."Invoice No.");
            until InvLine.Next() = 0;
        InvLine.DeleteAll();

        // Create new lines
        Remaining := Header."Total Contract Value" - PostedTotal;
        Instalment := Round(Remaining / UnpostedCount, 0.01);
        for i := PostedCount + 1 to TotalCount do begin
            if ReusableNos.Count() > 0 then begin
                InvoiceNo := ReusableNos.Get(1);
                ReusableNos.RemoveAt(1);
            end else
                InvoiceNo := NoSeries.GetNextNo(Header."Faktur Cicilan Nos.");

            InvLine.Init();
            InvLine."Package No." := Header."Package No.";
            InvLine."Invoice No." := InvoiceNo;
            InvLine."Invoice Date" := InvoiceDates.Get(i);
            InvLine.Description := CopyStr(StrSubstNo(DescriptionTxt, i, TotalCount, Header."No. Penawaran"), 1, MaxStrLen(InvLine.Description));
            if i = TotalCount then
                InvLine.Amount := Remaining - Assigned
            else
                InvLine.Amount := Instalment;
            Assigned += InvLine.Amount;
            InvLine.Insert(true);
        end;
    end;
}