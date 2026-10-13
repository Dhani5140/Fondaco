table 50102 "Installment Line"
{
    DataClassification = CustomerContent;
    Caption = 'Installment Line';

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            TableRelation = "Installment Header"."Document No.";
            NotBlank = true;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(3; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(5; Status; Enum "Schedule Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(6; Post; Boolean)
        {
            Caption = 'Post';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Post then
                    if Status <> Status::Open then
                        Error('You can only mark lines with status Open for posting.');
            end;
        }
        field(7; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
            AutoFormatType = 1;

            trigger OnValidate()
            var
                InstMgmt: Codeunit InstallmentManagement;
            begin
                if Status <> Status::Open then
                    Error('You cannot change the amount on a line that has already been posted.');

                if Amount < 0 then
                    Error('Amount cannot be negative.');

                InstMgmt.RedistributeAmounts(Rec);
            end;
        }
        field(8; "Cust. Ledger Entry No."; Integer)
        {
            Caption = 'CustLedgerNo';
            DataClassification = CustomerContent;
            TableRelation = "Cust. Ledger Entry"."Entry No.";
            Editable = false;
            BlankZero = true;
        }
    }

    keys
    {
        key(PK; "Document No.", "Line No.")
        {
            Clustered = true;
        }
        key(DocStatus; "Document No.", Status)
        {
        }
    }
}
