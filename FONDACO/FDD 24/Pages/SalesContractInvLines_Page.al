page 50104 "Sales Contract Invoice Lines"
{
    Caption = 'Invoicing Lines';
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "Sales Contract Inv. Lines";
    InsertAllowed = false;
    DeleteAllowed = false;

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
            action(GenerateInvoiceLines)
            {
                Caption = 'Generate Invoice Lines';
                Image = CreateLinesFromJob;
                Enabled = ParentEditable;
                trigger OnAction()
                var
                    Header: Record "Sales Contract Header";
                    ContractMgt: Codeunit "Sales Contract Mgt.";
                begin
                    Header.Get(PackageNo);
                    ContractMgt.GenerateInvoiceLine(Header);
                    CurrPage.Update(false);
                end;
            }
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