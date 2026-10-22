tableextension 50100 "Sales & Receive. TableExt." extends "Sales & Receivables Setup"
{
    fields
    {
        field(50100; "Sales Package"; Code[20])
        {
            Caption = 'Sales Package Nos.';
            TableRelation = "No. Series";
        }
        field(50101; "Cicilan Advance Account No."; Code[20])
        {
            Caption = 'Cicilan Advance (Uang Muka) Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" where("Account Type" = const(Posting), Blocked = const(false));
        }
    }
}