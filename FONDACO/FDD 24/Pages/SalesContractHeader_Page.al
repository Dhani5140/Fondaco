page 50101 "Sales Contract Card"
{
    Caption = 'Sales Contract';
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "Sales Contract Header";

    layout
    {
        area(Content)
        {
            group(Header)
            {
                Caption = 'Sales Contract Header';
                field("Package No."; Rec."Package No.") { ShowMandatory = true; }
                field("Customer No."; Rec."Customer No.") { Editable = IsOpen; ShowMandatory = true; }
                field("Customer Name"; Rec."Customer Name") { Editable = false; }
                field(Description; Rec.Description) { Editable = IsOpen; }
                field("No. Penawaran"; Rec."No. Penawaran") { Editable = IsOpen; ShowMandatory = true; }
                field("Salesperson Code"; Rec."Salesperson Code") { Editable = IsOpen; }
                field("Salesperson Name"; Rec."Salesperson Name") { Editable = false; }
                field("Paket Category Code"; Rec."Paket Category Code") { Editable = IsOpen; ShowMandatory = true; }
                field("Faktur Cicilan Nos."; Rec."Faktur Cicilan Nos.") { Editable = IsOpen; ShowMandatory = true; }
                field("Faktur Pengiriman Nos."; Rec."Faktur Pengiriman Nos.") { Editable = IsOpen; }
                field(Status; Rec.Status) { Editable = false; }
                field("Contract Start Date"; Rec."Contract Start Date") { Editable = IsOpen; }
                field("Contract Period"; Rec."Contract Period") { Editable = IsOpen; ShowMandatory = true; }
                field("Contract End Date"; Rec."Contract End Date") { Editable = IsOpen; }
                field("Invoice Period"; Rec."Invoice Period") { Editable = IsOpen; ShowMandatory = true; }
                field("Prices Include VAT"; Rec."Prices Include VAT") { Editable = IsOpen; }
                field("Total Contract Value"; Rec."Total Contract Value") { Editable = false; }
                field("Total Invoiced Value"; Rec."Total Invoiced Value") { Editable = false; }
                field(TotalPaymentMade; TotalPaymentMade) { Caption = 'Total Payment Made'; Editable = false; }
                field(GoodsToBeSent; GoodsToBeSent) { Caption = 'Total Value of Goods to be sent'; Editable = false; }
                field(GoodsProcessing; GoodsProcessing) { Caption = 'Total Value of Goods Processing Sending'; Editable = false; }
                field(GoodsSent; GoodsSent) { Caption = 'Total Value of Goods Sent'; Editable = false; }
            }
            part(Lines; "Sales Contract Lines")
            {
                Caption = 'Contract Lines';
                SubPageLink = "Package No." = field("Package No.");
                UpdatePropagation = Both;
            }
            group(Invoicing)
            {
                Caption = 'Sales Contract Invoicing';
                field("Payment Terms Code"; Rec."Payment Terms Code") { Editable = IsOpen; }
                field("Ship-to Code"; Rec."Ship-to Code") { Editable = IsOpen; }
                field("E-Mail"; Rec."E-Mail") { Editable = IsOpen; }
                field("Customer Posting Group"; Rec."Customer Posting Group") { Editable = IsOpen and AllowMultiplePostingGroups; }
                field("Currency Code"; Rec."Currency Code") { Editable = IsOpen; }
            }
            part(InvoiceLines; "Sales Contract Invoice Lines")
            {
                Caption = 'Invoice Lines';
                SubPageLink = "Package No." = field("Package No.");
                UpdatePropagation = Both;
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
                                           "No." = field("Package No."),
                                           "Line No." = const(0);
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(LockContract)
            {
                Caption = 'Lock Contract';
                Image = Lock;
                Enabled = IsOpen;
                trigger OnAction()
                begin
                    ContractMgt.LockContract(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(ReopenContract)
            {
                Caption = 'Reopen Contract';
                Image = ReOpen;
                Enabled = not IsOpen;
                trigger OnAction()
                begin
                    ContractMgt.ReopenContract(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(CancelContract)
            {
                Caption = 'Cancel Contract';
                Image = Cancel;
                Enabled = Rec.Status <> Rec.Status::Cancelled;
                trigger OnAction()
                begin
                    if Confirm('Cancel contract %1?', false, Rec."Package No.") then begin
                        ContractMgt.CancelContract(Rec);
                        CurrPage.Update(false);
                    end;
                end;
            }
            action(ContractDetails)
            {
                Caption = 'Contract Details';
                Image = ViewDetails;

                // To be confirm by functional
            }
            action(CreateSalesOrders)
            {
                Caption = 'Create Sales Orders';
                Image = PostOrder;
                Enabled = Rec.Status = Rec.Status::Locked;

                trigger OnAction()
                var
                    OrderMgt : Codeunit "Sales Contract Order Mgt.";
                begin
                    OrderMgt.CreateSalesOrder(Rec);
                end;
            }
        }
        area(Promoted)
        {
            actionref(LockContract_Promoted; LockContract) { }
            actionref(ReopenContract_Promoted; ReopenContract) { }
            actionref(CancelContract_Promoted; CancelContract) { }
            actionref(ContractDetails_Promoted; ContractDetails) { }
            actionref(CreateSalesOrders_Promoted; CreateSalesOrders) { }
        }
    }

    var
        ContractMgt: Codeunit "Sales Contract Mgt.";
        IsOpen: Boolean;
        AllowMultiplePostingGroups: Boolean;
        TotalPaymentMade: Decimal;
        GoodsToBeSent: Decimal;
        GoodsProcessing: Decimal;
        GoodsSent: Decimal;

    trigger OnAfterGetCurrRecord()
    var
        Cust: Record Customer;
    begin
        IsOpen := Rec.Status = Rec.Status::Open;
        AllowMultiplePostingGroups := Cust.Get(Rec."Customer No.") and Cust."Allow Multiple Posting Groups";
        TotalPaymentMade := Rec.GetTotalPaymentMade();
        GoodsToBeSent := Rec.GetTotalValueOfGoodsToBeSent();
        GoodsProcessing := Rec.GetTotalValueOfGoodsProcessingSending();
        GoodsSent := Rec.GetTotalValueOfGoodsSent();
        Rec.CalcFields("Total Contract Value", "Total Invoiced Value");
        CurrPage.Lines.Page.SetParentEditable(IsOpen);
        CurrPage.InvoiceLines.Page.SetContext(Rec."Package No.", IsOpen);
    end;
}