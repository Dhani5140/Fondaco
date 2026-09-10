codeunit 50160 "Installation Date Mgt."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean; InvtPickPutaway: Boolean; var CustLedgerEntry: Record "Cust. Ledger Entry"; WhseShip: Boolean; WhseReceiv: Boolean; PreviewMode: Boolean)
    var
        SalesShptHeader: Record "Sales Shipment Header";
    begin
        if (SalesShptHdrNo = '') or (SalesHeader."InstallationDate" = 0D) then exit;

        if SalesShptHeader.Get(SalesShptHdrNo) then begin
            SalesShptHeader."InstallationDate" := SalesHeader."InstallationDate";
            SalesShptHeader.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure SalesLine_OnAfterInsert(var Rec: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
    begin
        if (Rec."Document Type" <> Rec."Document Type"::Invoice) or (Rec."Shipment No." = '') then
            exit;
        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;
        if SalesHeader."InstallationDate" <> 0D then
            exit;
        if SalesShipmentHeader.Get(Rec."Shipment No.") and (SalesShipmentHeader."InstallationDate" <> 0D) then begin
            SalesHeader."InstallationDate" := SalesShipmentHeader."InstallationDate";
            SalesHeader.Modify();
        end;
    end;
}