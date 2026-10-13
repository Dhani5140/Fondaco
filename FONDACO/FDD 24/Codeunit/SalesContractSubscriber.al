codeunit 50100 "Sales Contract Post Subscriber"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure CaptureLineContracts(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        PendingQty: Dictionary of [Code[20], Decimal];
        PendingAmt: Dictionary of [Code[20], Decimal];
        ContractNo: Code[20];
        ProportionalAmt: Decimal;
    begin
        if SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order" then exit;

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter("Contract No.", '<>%1', '');
        if not SalesLine.FindSet() then exit;

        repeat
            if SalesLine."Qty. to Invoice" <= 0 then continue;

            if SalesLine.Quantity <> 0 then
                ProportionalAmt := (SalesLine."Qty. to Invoice" / SalesLine.Quantity) * SalesLine."Line Amount"
            else
                ProportionalAmt := 0;

            if PendingQty.ContainsKey(SalesLine."Contract No.") then begin
                PendingQty.Set(SalesLine."Contract No.",
                    PendingQty.Get(SalesLine."Contract No.") + SalesLine."Qty. to Invoice");
                PendingAmt.Set(SalesLine."Contract No.",
                    PendingAmt.Get(SalesLine."Contract No.") + ProportionalAmt);
            end else begin
                PendingQty.Add(SalesLine."Contract No.", SalesLine."Qty. to Invoice");
                PendingAmt.Add(SalesLine."Contract No.", ProportionalAmt);
            end;
        until SalesLine.Next() = 0;

        foreach ContractNo in PendingQty.Keys do
            ValidateContractCeiling(ContractNo, PendingQty.Get(ContractNo), PendingAmt.Get(ContractNo));
    end;

    local procedure ValidateContractCeiling(ContractNo: Code[20]; PendingQty: Decimal; PendingAmt: Decimal)
    var
        SalesContract: Record "Sales Contract Header";
    begin
        SalesContract.LockTable();
        if not SalesContract.Get(ContractNo) then exit;

        if SalesContract.Status = SalesContract.Status::Closed then
            if not SalesContract."Manually Reopened" then
                Error('Contract %1 is closed and cannot be invoiced against.', ContractNo);

        if SalesContract."Manually Reopened" then exit;

        if SalesContract."Max. Quantity" > 0 then
            if (SalesContract."Qty. Contracted" + PendingQty) > SalesContract."Max. Quantity" then
                Error('Posting would exceed contract %1''s quantity ceiling.\Max: %2 | Contracted: %3 | This Posting: %4',
                    ContractNo,
                    SalesContract."Max. Quantity",
                    SalesContract."Qty. Contracted",
                    PendingQty);

        if SalesContract."Max. Amount" > 0 then
            if (SalesContract."Amount Contracted" + PendingAmt) > SalesContract."Max. Amount" then
                Error('Posting would exceed contract %1''s amount ceiling.\Max: %2 | Contracted: %3 | This Posting: %4',
                    ContractNo,
                    SalesContract."Max. Amount",
                    SalesContract."Amount Contracted",
                    PendingAmt);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesShptLineInsert', '', false, false)]
    local procedure SetContractNoOnShptLine(var SalesShptLine: Record "Sales Shipment Line"; SalesLine: Record "Sales Line")
    begin
        if SalesLine."Contract No." = '' then exit;
        SalesShptLine."Contract No." := SalesLine."Contract No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesInvLineInsert', '', false, false)]
    local procedure SetContractNoOnInvLine(var SalesInvLine: Record "Sales Invoice Line"; SalesInvHeader: Record "Sales Invoice Header"; SalesLine: Record "Sales Line"; CommitIsSuppressed: Boolean; var IsHandled: Boolean; PostingSalesLine: Record "Sales Line"; SalesShipmentHeader: Record "Sales Shipment Header"; SalesHeader: Record "Sales Header"; var ReturnReceiptHeader: Record "Return Receipt Header")
    begin
        if SalesLine."Contract No." = '' then exit;
        SalesInvLine."Contract No." := SalesLine."Contract No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesCrMemoLineInsert', '', false, false)]
    local procedure SetContractNoOnCrMemoLine(var SalesCrMemoLine: Record "Sales Cr.Memo Line"; SalesLine: Record "Sales Line"; CommitIsSuppressed: Boolean; var IsHandled: Boolean)
    begin
        if SalesLine."Contract No." = '' then exit;
        SalesCrMemoLine."Contract No." := SalesLine."Contract No.";
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure UpdateContractOnPost(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean)
    var
        SalesInvLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesContract: Record "Sales Contract Header";
        ContractsTouched: List of [Code[20]];
        ContractNo: Code[20];
        CeilingHit: Boolean;
    begin
        if SalesInvHdrNo <> '' then begin
            SalesInvLine.SetRange("Document No.", SalesInvHdrNo);
            if SalesInvLine.FindSet() then
                repeat
                    if SalesInvLine."Contract No." = '' then continue;

                    SalesContract.LockTable();
                    if not SalesContract.Get(SalesInvLine."Contract No.") then continue;

                    SalesContract."Qty. Contracted" += SalesInvLine.Quantity;
                    SalesContract."Amount Contracted" += SalesInvLine."Line Amount";
                    SalesContract.Modify(true);

                    if not ContractsTouched.Contains(SalesInvLine."Contract No.") then
                        ContractsTouched.Add(SalesInvLine."Contract No.");
                until SalesInvLine.Next() = 0;
        end;

        if SalesCrMemoHdrNo <> '' then begin
            SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHdrNo);
            if SalesCrMemoLine.FindSet() then
                repeat
                    if SalesCrMemoLine."Contract No." = '' then continue;

                    SalesContract.LockTable();
                    if not SalesContract.Get(SalesCrMemoLine."Contract No.") then continue;

                    SalesContract."Qty. Contracted" -= SalesCrMemoLine.Quantity;
                    SalesContract."Amount Contracted" -= SalesCrMemoLine."Line Amount";
                    SalesContract.Modify(true);

                    if not ContractsTouched.Contains(SalesCrMemoLine."Contract No.") then
                        ContractsTouched.Add(SalesCrMemoLine."Contract No.");
                until SalesCrMemoLine.Next() = 0;
        end;

        foreach ContractNo in ContractsTouched do begin
            if not SalesContract.Get(ContractNo) then continue;

            CeilingHit := false;
            if SalesContract."Max. Quantity" > 0 then
                if SalesContract."Qty. Contracted" >= SalesContract."Max. Quantity" then
                    CeilingHit := true;
            if SalesContract."Max. Amount" > 0 then
                if SalesContract."Amount Contracted" >= SalesContract."Max. Amount" then
                    CeilingHit := true;

            if CeilingHit then begin
                SalesContract.Status := SalesContract.Status::Closed;
                SalesContract."Manually Reopened" := false;
            end else begin
                if SalesContract.Status = SalesContract.Status::Closed then begin
                    SalesContract.Status := SalesContract.Status::Released;
                    SalesContract."Manually Reopened" := false;
                end else begin
                    if SalesContract."Manually Reopened" then
                        SalesContract."Manually Reopened" := false
                    else
                        if SalesContract.Status = SalesContract.Status::Open then
                            SalesContract.Status := SalesContract.Status::Released;
                end;
            end;

            SalesContract.Modify(true);
        end;
    end;
}