page 50100 "Sales Contract"
{
    PageType = Document;
    SourceTable = "Sales Contract Header";
    Caption = 'Sales Contract';
    UsageCategory = Documents;
    ApplicationArea = All;
    RefreshOnActivate = true;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the contract number.';
                    Editable = IsEditable;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the customer number.';
                    ShowMandatory = true;
                    Editable = IsEditable;
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    Editable = false;
                    ToolTip = 'Auto-filled from the customer record.';
                }
                field("Contract Date"; Rec."Contract Date")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the contract start date.';
                    Editable = IsEditable;
                }
                field("Expiry Date"; Rec."Expiry Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the contract expires.';
                    ShowMandatory = true;
                    Editable = IsEditable;

                    trigger OnValidate()
                    begin
                        if (Rec."Expiry Date" <> 0D) and (Rec."Expiry Date" <= Today()) then begin
                            Rec.Status := Rec.Status::Closed;
                            Message('Contract %1 has expired on %2 and has been Closed.', Rec."No.", Rec."Expiry Date");
                        end;
                    end;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    Editable = false;
                    ToolTip = 'Specifies the current status of the contract. Automatically updated when invoices are posted.';
                    StyleExpr = StatusStyleExpr;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer reference / PO number.';
                    Editable = IsEditable;
                }
            }
            group(ContractLimits)
            {
                Caption = 'Contract Limits';

                field("Max. Quantity"; Rec."Max. Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the maximum total quantity agreed by the customer.';
                    ShowMandatory = true;
                    Editable = IsEditable;
                }
                field("Qty. Contracted"; Rec."Qty. Contracted")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Net quantity contracted — increases on invoice, decreases on return.';
                    StyleExpr = QtyStyleExpr;
                }
                field("Max. Amount"; Rec."Max. Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the maximum total amount agreed by the customer.';
                    ShowMandatory = true;
                    Editable = IsEditable;
                }
                field("Amount Contracted"; Rec."Amount Contracted")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Net amount contracted — increases on invoice, decreases on return.';
                    StyleExpr = AmountStyleExpr;
                }
            }
            part(SalesContractSubform; "Sales Contract Subform")
            {
                ApplicationArea = All;
                Caption = 'Lines';
                SubPageLink = "Contract No." = FIELD("No.");
                UpdatePropagation = Both;
                Editable = IsEditable;
            }
        }
        area(FactBoxes)
        {
            systempart(Links; Links) { ApplicationArea = All; }
            systempart(Notes; Notes) { ApplicationArea = All; }
            part(AttachedDocumentsList; "Doc. Attachment List Factbox")
            {
                ApplicationArea = All;
                Caption = 'Documents';
                UpdatePropagation = Both;
                SubPageLink = "Table ID" = const(Database::"Sales Contract Header"),
                                           "No." = field("No."),
                                           "Line No." = const(0);
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Reopen)
            {
                ApplicationArea = All;
                Caption = 'Reopen';
                Image = ReOpen;
                Promoted = true;
                PromotedCategory = Process;
                Enabled = not IsEditable;
                ToolTip = 'Reopens the contract for editing or further invoicing.';

                trigger OnAction()
                var
                    ConfirmMsg: Text;
                begin
                    if Rec.Status = Rec.Status::Open then
                        Error('Contract is already open.');

                    if Rec.Status = Rec.Status::Closed then
                        ConfirmMsg := 'Contract %1 is closed (ceiling reached).\Reopen and allow further invoicing?\The contract will close again if ceilings are hit on the next posting.'
                    else
                        ConfirmMsg := 'Reopen contract %1 for editing?';

                    if not Dialog.Confirm(ConfirmMsg, false, Rec."No.") then
                        exit;

                    Rec.Status := Rec.Status::Released;
                    Rec."Manually Reopened" := true;
                    Rec.Modify(true);

                    IsEditable := true;
                    CurrPage.Update(false);
                end;
            }
            action(PrintProformaInvoice)
            {
                ApplicationArea = All;
                Caption = 'Print Proforma Invoice';
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Print a proforma invoice for this contract.';

                trigger OnAction()
                begin
                    // Report not yet created — placeholder
                end;
            }
            action(PreviewAutoApply)
            {
                Caption = 'Preview Auto Apply';
                ApplicationArea = All;
                Image = PreviewChecks;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Preview which invoices will be applied against a selected payment entry.';

                trigger OnAction()
                var
                    CustLedgerEntry: Record "Cust. Ledger Entry";
                    InstMgmt: Codeunit InstallmentManagement;
                    TempPreviewLine: Record "Auto Apply Preview Line" temporary;
                    AutoApplyPreviewPage: Page "Auto Apply Preview";
                    CustomerLedgerEntries: Page "Customer Ledger Entries";
                begin
                    if Rec."Customer No." = '' then begin
                        Message('Please fill in the Customer No. before previewing.');
                        exit;
                    end;

                    CustLedgerEntry.SetRange("Customer No.", Rec."Customer No.");
                    CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Payment);
                    CustLedgerEntry.SetRange(Open, true);

                    CustomerLedgerEntries.SetTableView(CustLedgerEntry);
                    CustomerLedgerEntries.LookupMode(true);

                    if CustomerLedgerEntries.RunModal() <> Action::LookupOK then
                        exit;

                    CustomerLedgerEntries.GetRecord(CustLedgerEntry);

                    if not CustLedgerEntry.Open then
                        Error('The selected payment entry is already closed.');

                    InstMgmt.BuildPreviewLines(CustLedgerEntry, Rec."No.", TempPreviewLine);

                    if TempPreviewLine.IsEmpty then begin
                        Message('No eligible invoices found for payment %1 (posted %2).',
                            CustLedgerEntry."Document No.", CustLedgerEntry."Posting Date");
                        exit;
                    end;

                    CustLedgerEntry.CalcFields("Original Amount");
                    AutoApplyPreviewPage.SetPaymentInfo(
                        CustLedgerEntry."Entry No.",
                        CustLedgerEntry."Document No.",
                        CustLedgerEntry."Posting Date",
                        Abs(CustLedgerEntry."Original Amount"));
                    AutoApplyPreviewPage.SetLines(TempPreviewLine);
                    AutoApplyPreviewPage.RunModal();
                    CurrPage.Update(false);
                end;
            }
            action(ApplyEntries)
            {
                ApplicationArea = All;
                Caption = 'Apply Entries';
                Image = ApplyEntries;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Apply a payment entry against eligible invoices for this contract.';

                trigger OnAction()
                var
                    CustLedgerEntry: Record "Cust. Ledger Entry";
                    InstMgmt: Codeunit InstallmentManagement;
                    TempPreviewLine: Record "Auto Apply Preview Line" temporary;
                    AutoApplyPreview: Page "Auto Apply Preview";
                    CustomerLedgerEntries: Page "Customer Ledger Entries";
                begin
                    if Rec."Customer No." = '' then begin
                        Message('Please fill in the Customer No. before applying entries.');
                        exit;
                    end;

                    CustLedgerEntry.SetRange("Customer No.", Rec."Customer No.");
                    CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Payment);
                    CustLedgerEntry.SetRange(Open, true);

                    CustomerLedgerEntries.SetTableView(CustLedgerEntry);
                    CustomerLedgerEntries.LookupMode(true);

                    if CustomerLedgerEntries.RunModal() <> Action::LookupOK then
                        exit;

                    CustomerLedgerEntries.GetRecord(CustLedgerEntry);

                    InstMgmt.BuildPreviewLines(CustLedgerEntry, Rec."No.", TempPreviewLine);

                    if TempPreviewLine.IsEmpty then begin
                        Message('No eligible invoices found to apply against payment entry %1.', CustLedgerEntry."Document No.");
                        exit;
                    end;

                    CustLedgerEntry.CalcFields("Original Amount");
                    AutoApplyPreview.SetPaymentInfo(
                        CustLedgerEntry."Entry No.",
                        CustLedgerEntry."Document No.",
                        CustLedgerEntry."Posting Date",
                        Abs(CustLedgerEntry."Original Amount"));
                    AutoApplyPreview.SetLines(TempPreviewLine);
                    AutoApplyPreview.RunModal();
                    CurrPage.Update(false);
                end;
            }
            action(PostingTypePayments)
            {
                ApplicationArea = All;
                Caption = 'Installment Schedule';
                Image = Payment;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'View or manage the installment payment schedule for this contract.';

                trigger OnAction()
                var
                    InstHeader: Record "Installment Header";
                    InstSchedule: Page "Installment Schedule";
                begin
                    if Rec."No." = '' then
                        Error('Please save the contract before opening the installment schedule.');

                    if not InstHeader.Get(Rec."No.") then begin
                        InstHeader.Init();
                        InstHeader."Document No." := Rec."No.";
                        InstHeader.Insert(true);
                    end else begin
                        if InstHeader."Amount to Installment" = 0 then begin
                            InstHeader."Amount to Installment" := Rec."Max. Amount";
                            InstHeader.Modify(true);
                        end;
                    end;

                    InstSchedule.SetRecord(InstHeader);
                    InstSchedule.RunModal();
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        NoSeries: Codeunit "No. Series";
    begin
        Rec."No." := NoSeries.GetNextNo('SCON', Today(), false);
        Rec."Contract Date" := Today();
        IsEditable := true;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetStyleExpressions();
        UpdateEditability();
    end;

    local procedure UpdateEditability()
    begin
        IsEditable := (Rec.Status = Rec.Status::Open) or Rec."Manually Reopened";
        CurrPage.Editable := IsEditable;
    end;

    local procedure SetStyleExpressions()
    begin
        if Rec."Max. Quantity" <= 0 then
            QtyStyleExpr := 'Favorable'
        else if Rec."Qty. Contracted" >= Rec."Max. Quantity" then
            QtyStyleExpr := 'Unfavorable'
        else if (Rec."Qty. Contracted" / Rec."Max. Quantity") >= 0.9 then
            QtyStyleExpr := 'Ambiguous'
        else
            QtyStyleExpr := 'Favorable';

        if Rec."Max. Amount" <= 0 then
            AmountStyleExpr := 'Favorable'
        else if Rec."Amount Contracted" >= Rec."Max. Amount" then
            AmountStyleExpr := 'Unfavorable'
        else if (Rec."Amount Contracted" / Rec."Max. Amount") >= 0.9 then
            AmountStyleExpr := 'Ambiguous'
        else
            AmountStyleExpr := 'Favorable';

        case Rec.Status of
            Rec.Status::Open:
                StatusStyleExpr := 'Favorable';
            Rec.Status::Released:
                StatusStyleExpr := 'Ambiguous';
            Rec.Status::Closed:
                StatusStyleExpr := 'Unfavorable';
        end;
    end;

    var
        QtyStyleExpr: Text;
        AmountStyleExpr: Text;
        StatusStyleExpr: Text;
        IsEditable: Boolean;
        ClosedNotif: Notification;
        NearLimitNotif: Notification;
}
