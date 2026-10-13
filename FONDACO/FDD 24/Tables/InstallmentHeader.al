table 50103 "Installment Header"
{
    DataClassification = CustomerContent;
    Caption = 'Installment Header';
    LookupPageId = "Installment Schedule";
    DrillDownPageId = "Installment Schedule";

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            TableRelation = "Sales Header"."No." where("Document Type" = const("Blanket Order"));
            NotBlank = true;
        }
        field(2; "No. of Periods"; Integer)
        {
            Caption = 'No. of Periods';
            DataClassification = CustomerContent;
            MinValue = 1;

            trigger OnValidate()
            begin
                if "No. of Periods" <= 0 then
                    Error('No. of Periods must be greater than 0.');
            end;
        }
        field(3; "Amount to Installment"; Decimal)
        {
            Caption = 'Amount to Installment';
            DataClassification = CustomerContent;
            MinValue = 0;
            AutoFormatType = 1;
        }
        field(4; "Start Date"; Date)
        {
            Caption = 'Start Date';
            DataClassification = CustomerContent;
        }
        field(5; "Bank No."; Code[20])
        {
            Caption = 'Bank No.';
            DataClassification = CustomerContent;
            TableRelation = "Bank Account"."No.";
        }
        field(6; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            DataClassification = CustomerContent;
            TableRelation = "Sales Contract Header";

            trigger OnValidate()
            var
                SalesContract: Record "Sales Contract Header";
            begin
                if "Contract No." = '' then exit;
                SalesContract.Get("Contract No.");
            end;
        }
    }

    keys
    {
        key(PK; "Document No.")
        {
            Clustered = true;
        }
    }
}
