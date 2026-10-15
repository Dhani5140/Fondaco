tableextension 50100 "Sales & Receive. TableExt." extends "Sales & Receivables Setup"
{
    fields
    {
        field(50100; "Sales Package"; Code[20])
        {
            Caption = 'Sales Package Nos.';
            TableRelation = "No. Series";
        }
    }
}