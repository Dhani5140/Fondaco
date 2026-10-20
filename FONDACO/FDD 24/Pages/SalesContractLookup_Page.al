page 50108 "Sales Contract Lookup"
{
    Caption = 'Sales Contracts';
    PageType = List;
    ApplicationArea = All;
    SourceTable = "Sales Contract Header";
    SourceTableTemporary = true;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Contracts)
            {
                field("Package No."; Rec."Package No.") { }
                field("No. Penawaran"; Rec."No. Penawaran") { }
                field(Description; Rec.Description) { }
            }
        }
    }

    procedure SetCustomer(CustomerNo: Code[20])
    var
        Contract: Record "Sales Contract Header";
        OrderMgt: Codeunit "Sales Contract Order Mgt.";
    begin
        Rec.Reset();
        Rec.DeleteAll();
        Contract.SetRange("Customer No.", CustomerNo);
        if Contract.FindSet() then
            repeat
                if OrderMgt.IsEligibleForOrder(Contract) then begin
                    Rec := Contract;
                    Rec.Insert();
                end;
            until Contract.Next() = 0;
        if Rec.FindFirst() then;
    end;

    procedure GetSelectedPackageNo(): Code[20]
    begin
        exit(Rec."Package No.");
    end;
}