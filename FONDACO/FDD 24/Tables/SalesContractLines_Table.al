table 50101 "Sales Contract Lines"
{
    Caption = 'Sales Contract Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Package No."; Code[20]) { Caption = 'Package No.'; TableRelation = "Sales Contract Header"; }
        field(2; "Line No."; Integer) { Caption = 'Line No.'; }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            trigger OnValidate()
            var
                Item: Record Item;
            begin
                TestOpen();
                if "Item No." = '' then begin
                    "Item Category Code" := '';
                    exit;
                end;
                if "Item Category Options" <> '' then
                    Error(EitherItemOrCategoryErr);
                Item.Get("Item No.");
                Item.TestField(Blocked, false);
                "Item Category Code" := Item."Item Category Code";
                "Unit of Measure Code" := Item."Base Unit of Measure";
                "VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";
                CalcAmounts();
            end;
        }
        field(4; "Item Category Code"; Code[20]) { Caption = 'Item Category'; TableRelation = "Item Category"; Editable = false; }
        field(5; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure';
            TableRelation = if ("Item No." = filter('')) "Unit of Measure"
            else
            "Item Unit of Measure".Code where("Item No." = field("Item No."));
            trigger OnValidate()
            begin
                TestOpen();
            end;
        }
        field(6; "Item Category Options"; Text[250])
        {
            Caption = 'Item Category Options';
            trigger OnValidate()
            var
                ItemCategory: Record "Item Category";
                CatCode: Text;
            begin
                TestOpen();
                if "Item Category Options" = '' then
                    exit;
                if "Item No." <> '' then
                    Error(EitherItemOrCategoryErr);
                foreach CatCode in "Item Category Options".Split('|') do
                    ItemCategory.Get(CatCode);
            end;
        }
        field(7; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            trigger OnValidate()
            var
                Consumed: Decimal;
            begin
                TestOpen();
                CalcFields("Quantity on SO", "Quantity Invoiced", "Quantity Returned");
                Consumed := "Quantity on SO" + "Quantity Invoiced" - "Quantity Returned";
                if Quantity < Consumed then
                    Error(QtyBelowConsumedErr, Consumed);
                CalcAmounts();
            end;
        }
        field(8; "Direct Unit Price"; Decimal)
        {
            Caption = 'Direct Unit Price';
            trigger OnValidate()
            begin
                TestOpen();
                CalcAmounts();
            end;
        }
        field(9; "Total Excl. VAT"; Decimal) { Caption = 'Total Excl. VAT'; Editable = false; }
        field(10; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
            trigger OnValidate()
            begin
                TestOpen();
                CalcAmounts();
            end;
        }
        field(11; "Total Incl. VAT"; Decimal) { Caption = 'Total Incl. VAT'; Editable = false; }
        field(12; "Quantity on SO"; Decimal)
        {
            Caption = 'Quantity on SO';
            FieldClass = FlowField;
            CalcFormula = sum("Sales Line"."Outstanding Quantity" where("Document Type" = const(Order),
                "Package No." = field("Package No."), "Package Line No." = field("Line No.")));
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(13; "Quantity Received"; Decimal)
        {
            Caption = 'Quantity Received';
            FieldClass = FlowField;
            CalcFormula = sum("Sales Shipment Line".Quantity where("Package No." = field("Package No."),
                "Package Line No." = field("Line No.")));
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(14; "Quantity Invoiced"; Decimal)
        {
            Caption = 'Quantity Invoiced';
            FieldClass = FlowField;
            CalcFormula = sum("Sales Invoice Line".Quantity where("Package No." = field("Package No."),
                "Package Line No." = field("Line No.")));
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(15; "Quantity Returned"; Decimal)
        {
            Caption = 'Quantity Returned';
            FieldClass = FlowField;
            CalcFormula = sum("Return Receipt Line".Quantity where("Package No." = field("Package No."),
                "Package Line No." = field("Line No.")));
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
    }

    keys { key(PK; "Package No.", "Line No.") { Clustered = true; } }

    var
        EitherItemOrCategoryErr: Label 'Fill in either Item No. or Item Category Options, not both.';
        QtyBelowConsumedErr: Label 'Quantity cannot be lower than the quantity already consumed (%1).', Comment = '%1 = consumed qty';

    trigger OnInsert()
    var
        Line: Record "Sales Contract Lines";
    begin
        TestOpen();
        if "Line No." = 0 then begin
            Line.SetRange("Package No.", "Package No.");
            if Line.FindLast() then
                "Line No." := Line."Line No." + 10000
            else
                "Line No." := 10000;
        end;
    end;

    trigger OnModify()
    begin
        TestOpen();
    end;

    trigger OnDelete()
    begin
        TestOpen();
    end;

    local procedure TestOpen()
    var
        Header: Record "Sales Contract Header";
    begin
        Header.Get("Package No.");
        Header.TestOpen();
    end;

    procedure CalcAmounts()
    var
        Header: Record "Sales Contract Header";
        Factor: Decimal;
    begin
        Header.Get("Package No.");
        Factor := 1 + GetVATPercent(Header) / 100;
        if Header."Prices Include VAT" then begin
            "Total Incl. VAT" := Round(Quantity * "Direct Unit Price", 0.01);
            "Total Excl. VAT" := Round("Total Incl. VAT" / Factor, 0.01);
        end else begin
            "Total Excl. VAT" := Round(Quantity * "Direct Unit Price", 0.01);
            "Total Incl. VAT" := Round("Total Excl. VAT" * Factor, 0.01);
        end;
    end;

    local procedure GetVATPercent(Header: Record "Sales Contract Header"): Decimal
    var
        Customer: Record Customer;
        VATSetup: Record "VAT Posting Setup";
    begin
        if "VAT Prod. Posting Group" = '' then
            exit(0);
        Header.TestField("Customer No.");
        Customer.Get(Header."Customer No.");
        VATSetup.Get(Customer."VAT Bus. Posting Group", "VAT Prod. Posting Group");
        exit(VATSetup."VAT %");
    end;

    procedure GetUnitPriceInclVAT(): Decimal
    begin
        if Quantity = 0 then
            exit(0);
        exit("Total Incl. VAT" / Quantity);
    end;

    procedure GetRemainingQuantity(): Decimal
    begin
        CalcFields("Quantity on SO", "Quantity Invoiced", "Quantity Returned");
        exit(Quantity - "Quantity on SO" - "Quantity Invoiced" + "Quantity Returned");
    end;

    procedure LookupItemCategoryOptions(var Text: Text): Boolean
    var
        ItemCategory: Record "Item Category";
        ItemCategories: Page "Item Categories";
    begin
        ItemCategories.LookupMode(true);
        if ItemCategories.RunModal() <> Action::LookupOK then
            exit(false);
        ItemCategories.SetSelectionFilter(ItemCategory);
        Text := '';
        if ItemCategory.FindSet() then
            repeat
                if Text <> '' then
                    Text += '|';
                Text += ItemCategory.Code;
            until ItemCategory.Next() = 0;
        exit(true);
    end;
}