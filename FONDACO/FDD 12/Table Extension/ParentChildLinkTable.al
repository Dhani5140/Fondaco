tableextension 50155 "Customer Parent Ext" extends Customer
{
    fields
    {
        field(50155; "Is Parent Customer"; Boolean)
        {
            Caption = 'Is Parent Customer';
            InitValue = true;

            trigger OnValidate()
            var
                CustomerRec: Record Customer;
            begin
                if xRec."Is Parent Customer" and (not "Is Parent Customer") then begin
                    CustomerRec.SetRange("Parent Customer No.", Rec."No.");
                    CustomerRec.SetFilter("No.", '<>%1', Rec."No.");
                    if CustomerRec.FindFirst() then
                        Error('Customer %1 has this customer as Parent Customer.', CustomerRec."No.");
                end;

                if "Is Parent Customer" then "Parent Customer No." := '';
            end;
        }
        field(50156; "Parent Customer No."; Code[20])
        {
            Caption = 'Parent Customer No.';
            TableRelation = Customer where("Is Parent Customer" = const(true));

            trigger OnValidate()
            begin
                if ("Parent Customer No." <> '') and ("Parent Customer No." = "No.") then
                    Error('A customer cannot be its own parent.');
            end;
        }
    }
}