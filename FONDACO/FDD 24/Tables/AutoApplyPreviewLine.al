table 50104 "Auto Apply Preview Line"
{
    TableType = Temporary;
    Caption = 'Auto Apply Preview Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(3; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(4; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
        }
        field(5; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
        }
        field(6; "Original Amount"; Decimal)
        {
            Caption = 'Original Amount';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
        }
        field(7; "Remaining Amount"; Decimal)
        {
            Caption = 'Remaining Amount';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
        }
        field(8; "Amount to Apply"; Decimal)
        {
            Caption = 'Amount to Apply';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
        }
        field(9; "BSO Document No."; Code[20])
        {
            Caption = 'BSO Document No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(PostingDate; "Posting Date")
        {
        }
    }
}
