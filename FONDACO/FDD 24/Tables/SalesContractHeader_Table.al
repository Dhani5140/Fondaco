table 50100 "Sales Contract Header"
{
    Caption = 'Sales Contract Header';
    DataClassification = CustomerContent;
    LookupPageId = "Sales Contract List";
    DrillDownPageId = "Sales Contract List";

    fields
    {
        field(1; "Package No."; Code[20])
        {
            Caption = 'Package No.';
            Editable = false;
        }

        field(2; "Customer"; Code[30])
        {
            Caption = 'Customer';
            TableRelation = Customer;
            trigger OnValidate()
            var
                Cust: Record Customer;
            begin
                TestOpen();
                if "Customer" = '' then
                    exit;
                Cust.Get("Customer");

                "Payment Terms Code" := Cust."Payment Terms Code";
                "Currency Code" := Cust."Currency Code";
                "E-Mail" := Cust."E-Mail";
                "Customer Posting Group" := Cust."Customer Posting Group";
                "Ship-to Code" := '';
            end;
        }
        field(3; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Customer.Name where("No." = field(Customer)));
            Editable = false;
        }
        field(4; "Description"; Text[150])
        {
            Caption = 'Description';
            trigger OnValidate()
            begin
                TestOpen();
            end;
        }
        field(5; "Nomor Penawaran"; Code[30])
        {
            Caption = 'No. Penawaran';
            trigger OnValidate()
            begin
                TestOpen();
            end;
        }
        field(6; "Salesperson Code"; Code[30])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser";
            trigger OnValidate()
            begin
                TestOpen();
            end;
        }
        field(7; "Salesperson Name"; Text[50])
        {
            Caption = 'Salesperson Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Salesperson/Purchaser".Name where(Code = field("Salesperson Code")));
            Editable = false;
        }
        field(8; "Category Package"; Code[30])
        {
            Caption = 'Kategori Paket';
            TableRelation = "Paket Kategori" where(Blocked = const(false));
            trigger OnValidate()
            begin
                TestOpen();
            end;
        }
        field(9; "No cicilan"; Code[30])
        {
            Caption = 'No. Series Faktur Cicilan';
            TableRelation = "No. Series" where("Nomor Faktur Cicilan" = const(true));
            trigger OnValidate()
            begin
                TestOpen();
            end;
        }
        field(10; "No kirim barang"; Code[30])
        {
            Caption = 'No. Series Faktur Kirim Barang';
            TableRelation = "No. Series" where("Nomor Faktur Cicilan" = const(true));
            trigger OnValidate()
            begin
                TestOpen();
            end;
        }
        field(11; "Status"; Enum "SCON Status")
        {
            Caption = 'Status';
            Editable = false;
        }
        field(12; "Start Date"; Date)
        {
            Caption = 'Contract Start Date';
            trigger OnValidate()
            begin
                TestOpen();
                UpdateEndDate();
            end;
        }
        field(13; "Contract Period"; DateFormula)
        {
            Caption = 'Contract Period';
            trigger OnValidate()
            begin
                TestOpen();
                UpdateEndDate();
            end;
        }
        field(14; "Contract End Date"; Date)
        {
            Caption = 'Contract End Date';
            trigger OnValidate()
            begin
                TestOpen();
                UpdatePeriodFromEndDate();
            end;
        }
        field(15; "Invoice Period"; DateFormula)
        {
            Caption = 'Invoice Period';
            trigger OnValidate()
            begin
                TestOpen();
            end;
        }
        field(16; "Prices Include VAT"; Boolean)
        {
            Caption = 'Prices Include VAT';
            trigger OnValidate()
            var
                Line: Record "Sales Contract Lines";
            begin
                TestOpen();
                Line.SetRange("Package No.", "Package No.");
                if Line.FindSet(true) then
                    repeat
                        Line.CalcAmounts();
                        Line.Modify();
                    until Line.Next() = 0;
            end;
        }
        field(17; "Payment Terms Code"; Code[10])
        {
            Caption = 'Payment Terms Code';
            TableRelation = "Payment Terms";
            trigger OnValidate()
            begin
                TestOpen();
            end;
        }
        field(18; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code';
            TableRelation = "Ship-to Address".Code where("Customer No." = field("Customer"));
            trigger OnValidate()
            var
                ShipTo: Record "Ship-to Address";
            begin
                TestOpen();
                if ("Ship-to Code" <> '') and ShipTo.Get("Customer", "Ship-to Code") and (ShipTo."E-Mail" <> '') then
                    "E-Mail" := ShipTo."E-Mail";
            end;
        }
        field(19; "E-Mail"; Text[80])
        {
            Caption = 'Email';
            ExtendedDatatype = EMail;
            trigger OnValidate()
            begin
                TestOpen();
            end;
        }
        field(20; "Customer Posting Group"; Code[20])
        {
            Caption = 'Customer Posting Group';
            TableRelation = "Customer Posting Group";
            trigger OnValidate()
            begin
                TestOpen();
            end;
        }
        field(21; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
            trigger OnValidate()
            begin
                TestOpen();
            end;
        }
        field(22; "No. Series"; Code[20]) { Caption = 'No. Series'; TableRelation = "No. Series"; Editable = false; }
        field(30; "Total Contract Value"; Decimal)
        {
            Caption = 'Total Contract Value';
            FieldClass = FlowField;
            CalcFormula = sum("Sales Contract Lines"."Total Excl. VAT" where("Package No." = field("Package No.")));
            Editable = false;
        }
        field(31; "Total Invoiced Value"; Decimal)
        {
            Caption = 'Total Invoiced Value';
            FieldClass = FlowField;
            CalcFormula = sum("Sales Contract Inv. Lines".Amount where("Package No." = field("Package No."), "Invoice Posted" = const(true)));
            Editable = false;
        }
    }

    // keys 
    // {
    //     key(PK; "Package No.")
    //     { 
    //         Clustered = true;
    //     } 
    // }

    procedure TestOpen()
    begin
        TestField(Status, Status::Open);
    end;

    local procedure UpdateEndDate()
    begin
        if ("Start Date" = 0D) or (Format("Contract Period") = '') then
            exit;
        "Contract End Date" := CalcDate("Contract Period", "Start Date") - 1; // 01/01 + 1Y -> 31/12
    end;

    local procedure UpdatePeriodFromEndDate()
    var
        NextDay: Date;
        Months: Integer;
        EndBeforeStartErr: Label 'Contract End Date cannot be before Contract Start Date.';
    begin
        if ("Start Date" = 0D) or ("Contract End Date" = 0D) then
            exit;
        if "Contract End Date" < "Start Date" then
            Error(EndBeforeStartErr);
        NextDay := "Contract End Date" + 1;
        Months := (Date2DMY(NextDay, 3) - Date2DMY("Start Date", 3)) * 12 +
                  Date2DMY(NextDay, 2) - Date2DMY("Start Date", 2);
        if (Months > 0) and (CalcDate(StrSubstNo('<%1M>', Months), "Start Date") = NextDay) then
            Evaluate("Contract Period", StrSubstNo('<%1M>', Months))
        else
            Evaluate("Contract Period", StrSubstNo('<%1D>', NextDay - "Start Date"));
    end;
}