tableextension 50105 "Sales Header Contract Ext." extends "Sales Header"
{
    fields
    {
        field(50100; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            DataClassification = CustomerContent;
            TableRelation = "Sales Contract Header";

            trigger OnValidate()
            var
                SalesContract: Record "Sales Contract Header";
                SalesLine: Record "Sales Line";
            begin
                SalesLine.SetRange("Document Type", Rec."Document Type");
                SalesLine.SetRange("Document No.", Rec."No.");

                if "Contract No." = '' then begin
                    SalesLine.ModifyAll("Contract No.", '', false);
                    exit;
                end;

                SalesContract.Get("Contract No.");

                if ("Sell-to Customer No." <> '') and
                   (SalesContract."Customer No." <> "Sell-to Customer No.") then
                    Error('Contract %1 belongs to customer %2, not %3.',
                        "Contract No.", SalesContract."Customer No.", "Sell-to Customer No.");

                if SalesContract.Status = SalesContract.Status::Closed then
                    if "Document Type" <> "Document Type"::"Return Order" then
                        Error('Contract %1 is closed and fully consumed.', "Contract No.");

                if SalesLine.FindSet(true) then
                    repeat
                        if SalesLine.Type = SalesLine.Type::Item then
                            ValidateExistingLineFitsContract(SalesLine, SalesContract."No.");
                        SalesLine."Contract No." := "Contract No.";
                        SalesLine.Modify(false);
                    until SalesLine.Next() = 0;
            end;
        }
    }

    local procedure ValidateExistingLineFitsContract(SalesLine: Record "Sales Line"; ContractNo: Code[20])
    var
        SalesContractLine: Record "Sales Contract Line";
        Item: Record Item;
    begin
        if SalesLine.Type <> SalesLine.Type::Item then exit;
        if SalesLine."No." = '' then exit;
        if not Item.Get(SalesLine."No.") then exit;

        SalesContractLine.SetRange("Contract No.", ContractNo);
        SalesContractLine.SetRange("Item Category Code", Item."Item Category Code");

        if SalesContractLine.IsEmpty then
            Error('Existing line for item %1 (Category: %2) does not belong to contract %3. Remove this line before switching contracts.',
                SalesLine."No.", Item."Item Category Code", ContractNo);
    end;
}