page 50102 "Sales Contract List"
{
    Caption = 'Sales Contract';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Sales Contract Header";
    CardPageId = "Sales Contract Card";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Contracts)
            {
                field("Package No."; Rec."Package No.") { Caption = 'No.'; }
                field("Customer No."; Rec."Customer No.") { }
                field("Customer Name"; Rec."Customer Name") { }
                field(Description; Rec.Description) { }
                field("Paket Category Code"; Rec."Paket Category Code") { }
                field("No. Penawaran"; Rec."No. Penawaran") { }
                field("Salesperson Code"; Rec."Salesperson Code") { }
                field(Status; Rec.Status) { }
                field("Contract Start Date"; Rec."Contract Start Date") { }
                field("Contract Period"; Rec."Contract Period") { }
                field("Contract End Date"; Rec."Contract End Date") { }
                field("Total Contract Value"; Rec."Total Contract Value") { }
                field(TotalPaymentMade; TotalPaymentMade) { Caption = 'Total Payment Made'; }
                field(GoodsSent; GoodsSent) { Caption = 'Total Value of Goods Sent'; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CancelContract)
            {
                Caption = 'Cancel';
                Image = Cancel;
                trigger OnAction()
                begin
                    ContractMgt.CancelContract(Rec);
                end;
            }
            action(LockContract)
            {
                Caption = 'Lock Contract';
                Image = Lock;
                trigger OnAction()
                begin
                    ContractMgt.LockContract(Rec);
                end;
            }
        }
        area(Promoted)
        {
            actionref(CancelContract_Promoted; CancelContract) { }
            actionref(LockContract_Promoted; LockContract) { }
        }
    }

    var
        ContractMgt: Codeunit "Sales Contract Mgt.";
        TotalPaymentMade: Decimal;
        GoodsSent: Decimal;

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Total Contract Value");
        TotalPaymentMade := Rec.GetTotalPaymentMade();
        GoodsSent := Rec.GetTotalValueOfGoodsSent();
    end;
}