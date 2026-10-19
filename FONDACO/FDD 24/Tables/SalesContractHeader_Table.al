table 50100 "Sales Contract Header"
{
    Caption = 'Sales Contract Header';
    DataClassification = CustomerContent;
    LookupPageId = "Sales Contract List";
    DrillDownPageId = "Sales Contract List";

    fields
    {
        field(1; "Package No."; Code[20]) { Caption = 'Package No.'; }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
            trigger OnValidate()
            var
                Cust: Record Customer;
            begin
                TestOpen();
                if "Customer No." = '' then
                    exit;
                Cust.Get("Customer No.");
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
            CalcFormula = lookup(Customer.Name where("No." = field("Customer No.")));
            Editable = false;
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
            trigger OnValidate()
            begin
                TestOpen();
            end;
        }
        field(5; "No. Penawaran"; Text[100])
        {
            Caption = 'No. Penawaran';
            trigger OnValidate()
            begin
                TestOpen();
            end;
        }
        field(6; "Salesperson Code"; Code[20])
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
        field(8; "Paket Category Code"; Code[20])
        {
            Caption = 'Kategori Paket';
            TableRelation = "Paket Kategori" where(Blocked = const(false));
            trigger OnValidate()
            begin
                TestOpen();
            end;
        }
        field(9; "Faktur Cicilan Nos."; Code[20])
        {
            Caption = 'No. Series Faktur Cicilan';
            TableRelation = "No. Series" where("Nomor Faktur Cicilan" = const(true));
            trigger OnValidate()
            begin
                TestOpen();
            end;
        }
        field(10; "Faktur Pengiriman Nos."; Code[20])
        {
            Caption = 'No. Series Faktur Kirim Barang';
            TableRelation = "No. Series" where("Nomor Faktur Cicilan" = const(true));
            trigger OnValidate()
            begin
                TestOpen();
            end;
        }
        field(11; Status; Enum "SCON Status") { Caption = 'Status'; Editable = false; }
        field(12; "Contract Start Date"; Date)
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
            TableRelation = "Ship-to Address".Code where("Customer No." = field("Customer No."));
            trigger OnValidate()
            var
                ShipTo: Record "Ship-to Address";
            begin
                TestOpen();
                if ("Ship-to Code" <> '') and ShipTo.Get("Customer No.", "Ship-to Code") and (ShipTo."E-Mail" <> '') then
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
            CalcFormula = sum("Sales Contract Lines"."Total Incl. VAT" where("Package No." = field("Package No.")));
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

    keys { key(PK; "Package No.") { Clustered = true; } }

    trigger OnInsert()
    var
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeries: Codeunit "No. Series";
    begin
        if "Package No." = '' then begin
            SalesSetup.Get();
            SalesSetup.TestField("Sales Package");
            "No. Series" := SalesSetup."Sales Package";
            "Package No." := NoSeries.GetNextNo("No. Series");
        end;
        if "Contract Start Date" = 0D then
            "Contract Start Date" := WorkDate();
    end;

    trigger OnDelete()
    var
        InvLine: Record "Sales Contract Inv. Lines";
        Line: Record "Sales Contract Lines";
        HasPostedErr: Label 'You cannot delete contract %1 because it has posted installment invoices.', Comment = '%1 = Package No.';
    begin
        TestOpen();
        InvLine.SetRange("Package No.", "Package No.");
        InvLine.SetRange("Invoice Posted", true);
        if not InvLine.IsEmpty() then
            Error(HasPostedErr, "Package No.");
        InvLine.SetRange("Invoice Posted");
        InvLine.DeleteAll();
        Line.SetRange("Package No.", "Package No.");
        Line.DeleteAll();
    end;

    procedure TestOpen()
    begin
        TestField(Status, Status::Open);
    end;

    local procedure UpdateEndDate()
    begin
        if ("Contract Start Date" = 0D) or (Format("Contract Period") = '') then
            exit;
        "Contract End Date" := CalcDate("Contract Period", "Contract Start Date") - 1; // 01/01 + 1Y -> 31/12
    end;

    local procedure UpdatePeriodFromEndDate()
    var
        NextDay: Date;
        Months: Integer;
        EndBeforeStartErr: Label 'Contract End Date cannot be before Contract Start Date.';
    begin
        if ("Contract Start Date" = 0D) or ("Contract End Date" = 0D) then
            exit;
        if "Contract End Date" < "Contract Start Date" then
            Error(EndBeforeStartErr);
        NextDay := "Contract End Date" + 1;
        Months := (Date2DMY(NextDay, 3) - Date2DMY("Contract Start Date", 3)) * 12 +
                  Date2DMY(NextDay, 2) - Date2DMY("Contract Start Date", 2);
        if (Months > 0) and (CalcDate(StrSubstNo('<%1M>', Months), "Contract Start Date") = NextDay) then
            Evaluate("Contract Period", StrSubstNo('<%1M>', Months))
        else
            Evaluate("Contract Period", StrSubstNo('<%1D>', NextDay - "Contract Start Date"));
    end;

    procedure GetTotalPaymentMade(): Decimal
    var
        InvLine: Record "Sales Contract Inv. Lines";
        Total: Decimal;
    begin
        InvLine.SetRange("Package No.", "Package No.");
        InvLine.SetRange("Invoice Posted", true);
        if InvLine.FindSet() then
            repeat
                InvLine.CalcFields("Remaining Amount");
                Total += InvLine.Amount - InvLine."Remaining Amount";
            until InvLine.Next() = 0;
        exit(Total);
    end;

    procedure GetTotalValueOfGoodsToBeSent(): Decimal
    var
        Line: Record "Sales Contract Lines";
        Total: Decimal;
    begin
        Line.SetRange("Package No.", "Package No.");
        if Line.FindSet() then
            repeat
                Total += Line.GetRemainingQuantity() * Line.GetUnitPriceInclVAT();
            until Line.Next() = 0;
        exit(Total);
    end;

    procedure GetTotalValueOfGoodsProcessingSending(): Decimal
    var
        Line: Record "Sales Contract Lines";
        Total: Decimal;
    begin
        Line.SetRange("Package No.", "Package No.");
        if Line.FindSet() then
            repeat
                Line.CalcFields("Quantity on SO");
                Total += Line."Quantity on SO" * Line.GetUnitPriceInclVAT();
            until Line.Next() = 0;
        exit(Total);
    end;

    procedure GetTotalValueOfGoodsSent(): Decimal
    var
        Line: Record "Sales Contract Lines";
        Total: Decimal;
    begin
        Line.SetRange("Package No.", "Package No.");
        if Line.FindSet() then
            repeat
                Line.CalcFields("Quantity Received");
                Total += Line."Quantity Received" * Line.GetUnitPriceInclVAT();
            until Line.Next() = 0;
        exit(Total);
    end;
}