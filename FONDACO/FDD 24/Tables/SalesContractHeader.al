table 50100 "Sales Contract Header"
{
    Caption = 'Sales Contract Header';
    DataClassification = CustomerContent;
    LookupPageId = "Sales Contract List";
    DrillDownPageId = "Sales Contract List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;

            trigger OnValidate()
            var
                Cust: Record Customer;
            begin
                if "Customer No." = '' then begin
                    "Customer Name" := '';
                    exit;
                end;
                if Cust.Get("Customer No.") then
                    "Customer Name" := Cust.Name;
            end;
        }
        field(3; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
        }
        field(4; "Contract Date"; Date)
        {
            Caption = 'Contract Date';
            DataClassification = CustomerContent;
        }
        field(5; "Expiry Date"; Date)
        {
            Caption = 'Expiry Date';
            DataClassification = CustomerContent;
        }
        field(6; "Max. Quantity"; Decimal)
        {
            Caption = 'Max. Quantity';
            DataClassification = CustomerContent;
            MinValue = 0;
            DecimalPlaces = 0 : 5;
        }
        field(7; "Max. Amount"; Decimal)
        {
            Caption = 'Max. Amount';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(8; Status; Enum "Sales Contract Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(9; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser";
        }
        field(10; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }
        field(11; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
        }
        field(12; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            Editable = false;
        }
        field(13; Notes; Text[250])
        {
            Caption = 'Notes';
            DataClassification = CustomerContent;
        }
        field(14; "Qty. On Open Orders"; Decimal)
        {
            Caption = 'Qty. On Open Orders';
            FieldClass = FlowField;
            CalcFormula = Sum("Sales Line".Quantity WHERE("Contract No." = FIELD("No."),
              "Document Type" = FILTER(Order)));
            Editable = false;
        }
        field(15; "Qty. Contracted"; Decimal)
        {
            Caption = 'Qty. Contracted';
            DataClassification = CustomerContent;
            Editable = false;
            DecimalPlaces = 0 : 5;
        }
        field(16; "Amount Contracted"; Decimal)
        {
            Caption = 'Amount Contracted';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(17; "Manually Reopened"; Boolean)
        {
            Caption = 'Manually Reopened';
            DataClassification = CustomerContent;
        }
        field(18; "Media"; Media)
        {
            Caption = 'Contract Image';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "No.") { Clustered = true; }
        key(K1; "Customer No.") { }
        key(K2; Status) { }
    }

    trigger OnInsert()
    var
        NoSeries: Codeunit "No. Series";
    begin
        if "No." = '' then
            "No." := NoSeries.GetNextNo('SCON', Today(), true);
        if "Contract Date" = 0D then
            "Contract Date" := Today();
    end;

    trigger OnDelete()
    var
        SalesContractLine: Record "Sales Contract Line";
    begin
        SalesContractLine.SetRange("Contract No.", "No.");
        SalesContractLine.DeleteAll(true);
    end;

}
