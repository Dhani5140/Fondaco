tableextension 50109 "Sales Header Package Ext." extends "Sales Header"
{
    fields
    {
        field(50100; "Package No."; Code[20])
        {
            Caption = 'Package No.';
            DataClassification = CustomerContent;
            TableRelation = "Sales Contract Header" where("Customer No." = field("Sell-to Customer No."));

            trigger OnValidate()
            var
                OrderMgt: Codeunit "Sales Contract Order Mgt.";
            begin
                OrderMgt.ValidateHeaderPackageNo(Rec, xRec);
            end;
        }
    }
}