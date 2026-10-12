tableextension 50102 "Sales Line Contract Ext." extends "Sales Line"
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
                SalesHeader: Record "Sales Header";
                SalesContract: Record "Sales Contract Header";
            begin
                if "Contract No." = '' then exit;

                SalesContract.Get("Contract No.");

                if SalesHeader.Get("Document Type", "Document No.") then
                    if (SalesHeader."Sell-to Customer No." <> '') and
                       (SalesContract."Customer No." <> SalesHeader."Sell-to Customer No.") then
                        Error('Contract %1 belongs to customer %2, not %3.',
                            "Contract No.", SalesContract."Customer No.", SalesHeader."Sell-to Customer No.");

                if SalesContract.Status = SalesContract.Status::Closed then
                    if "Document Type" <> "Document Type"::"Return Order" then
                        Error('Contract %1 is Closed and fully consumed.', "Contract No.");
            end;
        }
    }
}