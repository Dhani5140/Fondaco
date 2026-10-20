codeunit 50102 "Sales Contract Order Mgt."
{

    // ------------- Eligible -------------
    procedure IsEligibleForOrder(ContractHeader: Record "Sales Contract Header"): Boolean
    begin
        exit((ContractHeader.Status = ContractHeader.Status::Locked) and (ContractHeader.GetTotalValueOfGoodsToBeSent() > 0));
    end;

    local procedure CheckContractUsable(ContractHeader: Record "Sales Contract Header"; CustomerNo: Code[20])
    begin
        if ContractHeader.Status <> ContractHeader.Status::Locked then
            Error('Contract %1 is not locked. Please lock the contract first', ContractHeader."Package No.");
        if ContractHeader."Customer No." <> CustomerNo then
            Error('Contract %1 belongs to customer %2, not %3.', ContractHeader."Package No.", ContractHeader."Customer No.", CustomerNo);
        if ContractHeader.GetTotalValueOfGoodsToBeSent() <= 0 then
            Error('Contract %1 has no remaining goods to be sent.', ContractHeader."Package No.");
    end;

    // ------------- Header -------------
    procedure ValidateHeaderPackageNo(var SalesHeader: Record "Sales Header"; var XSalesHeader: Record "Sales Header")
    var
        ContractHeader: Record "Sales Contract Header";
        SalesLine: Record "Sales Line";
    begin
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then exit;
        if SalesHeader."Package No." <> XSalesHeader."Package No." then exit;

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");

        if not SalesLine.IsEmpty() then
            Error('Delete the existing Sales Lines before changing the Package No.');

        if SalesHeader."Package No." = '' then exit;

        SalesHeader.TestField("Sell-to Customer No.");
        ContractHeader.Get(SalesHeader."Package No.");
        CheckContractUsable(ContractHeader, SalesHeader."Sell-to Customer No.");

        CopyContractToSalesHeader(SalesHeader, ContractHeader);
        SalesHeader.Modify();
        AutoFillSalesLine(SalesHeader, ContractHeader);
    end;

    local procedure CopyContractToSalesHeader(var SalesHeader: Record "Sales Header"; ContractHeader: Record "Sales Contract Header")
    begin
        if SalesHeader."Prices Including VAT" <> ContractHeader."Prices Include VAT" then
            SalesHeader.Validate("Prices Including VAT", ContractHeader."Prices Include VAT");
        if SalesHeader."Payment Terms Code" <> ContractHeader."Payment Terms Code" then
            SalesHeader.Validate("Payment Terms Code", ContractHeader."Payment Terms Code");
        if SalesHeader."Currency Code" <> ContractHeader."Currency Code" then
            SalesHeader.Validate("Currency Code", ContractHeader."Currency Code");
        if (ContractHeader."Ship-to Code" <> '') and (SalesHeader."Ship-to Code" <> ContractHeader."Ship-to Code") then
            SalesHeader.Validate("Ship-to Code", ContractHeader."Ship-to Code");
        if (ContractHeader."Customer Posting Group" <> '') and (SalesHeader."Customer Posting Group" <> ContractHeader."Customer Posting Group") then
            SalesHeader.Validate("Customer Posting Group", ContractHeader."Customer Posting Group");
    end;

    // ------------- Create lines -------------
    local procedure AutoFillSalesLine(SalesHeader: Record "Sales Header"; ContractHeader: Record "Sales Contract Header")
    var
        ContractLine: Record "Sales Contract Lines";
        SalesLine: Record "Sales Line";
        RemainingQty: Decimal;
        LineNo: Integer;
    begin
        ContractLine.SetRange("Package No.", ContractHeader."Package No.");

        if ContractLine.FindSet() then exit;

        repeat
            RemainingQty := ContractLine.GetRemainingQuantity();
            if RemainingQty >= 0 then begin
                LineNo += 10000;
                SalesLine.Init();
                SalesLine."Document Type" := SalesHeader."Document Type";
                SalesLine."Document No." := SalesHeader."No.";
                SalesLine."Line No." := LineNo;
                SalesLine.Validate(Type, SalesLine.Type::Item);
                SalesLine."Package No." := ContractLine."Package No.";
                SalesLine."Package Line No." := ContractLine."Line No.";
                SalesLine."Paket Category Code" := ContractHeader."Paket Category Code";
                SalesLine."Item Category Options" := ContractLine."Item Category Options";

                // if category-only line
                if ContractLine."Item No." = '' then begin
                    SalesLine."Unit of Measure Code" := ContractLine."Unit of Measure Code";
                    SalesLine."VAT Prod. Posting Group" := ContractLine."VAT Prod. Posting Group";
                    SalesLine.Insert(true);
                end else begin
                    SalesLine.Insert(true);
                    SalesLine.Validate("No.", ContractLine."Item No.");
                end;

                SalesLine.Validate(Quantity, RemainingQty);
                SalesLine.Modify(true);
            end;
        until ContractLine.Next() = 0;
    end;

    procedure CreateSalesOrder(var ContractHeader: Record "Sales Contract Header")
    var
        SalesHeader: Record "Sales Header";
    begin
        CheckContractUsable(ContractHeader, ContractHeader."Customer No.");
        SalesHeader.Init();
        SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", ContractHeader."Customer No.");
        SalesHeader.Validate("Package No.", ContractHeader."Package No.");
        SalesHeader.Modify(true);
        Page.Run(Page::"Sales Order", SalesHeader);
    end;

    // ------------- Helpers -------------
    local procedure IsPackageOrderLine(SalesLine: Record "Sales Line"): Boolean
    begin
        exit((SalesLine."Document Type" = SalesLine."Document Type"::Order) and (SalesLine."Package Line No." <> 0));
    end;

    local procedure GetContractLine(SalesLine: Record "Sales Line"; var ContractLine: Record "Sales Contract Lines"): Boolean
    begin
        if not IsPackageOrderLine(SalesLine) then
            exit(false);
        exit(ContractLine.Get(SalesLine."Package No.", SalesLine."Package Line No."));
    end;

    local procedure IsCicilanOrder(SalesLine: Record "Sales Line"): Boolean
    var
        SalesHeader: Record "Sales Header";
    begin
        if SalesLine."Document Type" <> SalesLine."Document Type"::Order then
            exit(false);
        if not SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.") then
            exit(false);
        exit(SalesHeader."Package No." <> '');
    end;

    procedure GetLineEditability(SalesLine: Record "Sales Line"; var NoLocked: Boolean; var UoMLocked: Boolean)
    var
        ContractLine: Record "Sales Contract Lines";
    begin
        NoLocked := GetContractLine(SalesLine, ContractLine) and (ContractLine."Item No." <> '');
        UoMLocked := IsPackageOrderLine(SalesLine);
    end;

    // ---------- Validation hooks (called from subscribers) ----------

    procedure CheckLineItemChange(SalesLine: Record "Sales Line"; CurrFieldNo: Integer)
    var
        ContractLine: Record "Sales Contract Lines";
    begin
        if CurrFieldNo <> SalesLine.FieldNo("No.") then
            exit;
        if GetContractLine(SalesLine, ContractLine) and (ContractLine."Item No." <> '') then
            Error('The Item No. comes from the contract line and cannot be changed.');
    end;

    procedure CheckPackageFieldLocked(SalesLine: Record "Sales Line"; CurrFieldNo: Integer; LockedFieldNo: Integer)
    begin
        if (CurrFieldNo = LockedFieldNo) and IsPackageOrderLine(SalesLine) then
            Error('This field comes from the contract line and cannot be changed.');
    end;

    procedure CheckAmountFieldLocked(SalesLine: Record "Sales Line"; CurrFieldNo: Integer; LockedFieldNo: Integer)
    begin
        if (CurrFieldNo = LockedFieldNo) and IsCicilanOrder(SalesLine) then
            Error('Amounts on a contract (cicilan) cannot be edited.');
    end;

    procedure OnAfterValidateLineNo(var SalesLine: Record "Sales Line"; CurrFieldNo: Integer)
    var
        ContractLine: Record "Sales Contract Lines";
    begin
        if (SalesLine."No." = '') or not GetContractLine(SalesLine, ContractLine) then
            exit;

        CheckItemInCategoryOptions(SalesLine);

        if SalesLine."Unit of Measure Code" <> ContractLine."Unit of Measure Code" then
            SalesLine.Validate("Unit of Measure Code", ContractLine."Unit of Measure Code");
        if (ContractLine."VAT Prod. Posting Group" <> '') and (SalesLine."VAT Prod. Posting Group" <> ContractLine."VAT Prod. Posting Group") then
            SalesLine.Validate("VAT Prod. Posting Group", ContractLine."VAT Prod. Posting Group");
        if (CurrFieldNo = SalesLine.FieldNo("No.")) and (SalesLine.Quantity = 0) then
            SalesLine.Validate(Quantity, ContractLine.GetRemainingQuantity());

        ApplyContractPricing(SalesLine);
    end;

    procedure OnAfterValidateLineQuantity(var SalesLine: Record "Sales Line")
    var
        ContractLine: Record "Sales Contract Lines";
        StoredLine: Record "Sales Line";
        StoredOutstanding: Decimal;
        Allowed: Decimal;
    begin
        if not GetContractLine(SalesLine, ContractLine) then
            exit;

        if StoredLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.") then
            StoredOutstanding := StoredLine."Outstanding Quantity";
        Allowed := ContractLine.GetRemainingQuantity() + StoredOutstanding;
        if SalesLine.Quantity > Allowed then
            Error('Quantity cannot exceed the remaining contract quantity (%1).', Allowed);

        ApplyContractPricing(SalesLine);
    end;

    local procedure CheckItemInCategoryOptions(SalesLine: Record "Sales Line")
    var
        Item: Record Item;
        CategoryCode: Text;
    begin
        if SalesLine."Item Category Options" = '' then
            exit;
        Item.Get(SalesLine."No.");
        foreach CategoryCode in SalesLine."Item Category Options".Split('|') do
            if CategoryCode = Item."Item Category Code" then
                exit;
        Error('Item %1 is not in the allowed Item Category Options (%2) of the contract line.', SalesLine."No.", SalesLine."Item Category Options");
    end;

    procedure ApplyContractPricing(var SalesLine: Record "Sales Line")
    var
        ContractLine: Record "Sales Contract Lines";
        StandardPrice: Decimal;
        Discount: Decimal;
    begin
        if (SalesLine."No." = '') or not GetContractLine(SalesLine, ContractLine) then
            exit;

        StandardPrice := SalesLine."Unit Price";
        if (StandardPrice > 0) and (StandardPrice > ContractLine."Direct Unit Price") then
            // Discount(%) Formula = (standard price - contract price) / standard price * 100
            Discount := Round((StandardPrice - ContractLine."Direct Unit Price") / StandardPrice * 100, 0.00001)
        else begin
            if SalesLine."Unit Price" <> ContractLine."Direct Unit Price" then
                SalesLine.Validate("Unit Price", ContractLine."Direct Unit Price");
            Discount := 0;
        end;
        if SalesLine."Line Discount %" <> Discount then
            SalesLine.Validate("Line Discount %", Discount);
    end;

    // ---------- Select item / Split line ----------

    procedure SelectItemForLine(var SalesLine: Record "Sales Line")
    var
        Item: Record Item;
        ItemList: Page "Item List";
        KeptQuantity: Decimal;
    begin
        if not IsPackageOrderLine(SalesLine) then Error('This line does not come from a Sales Contract line.');
        if SalesLine."Item Category Options" = '' then Error('This contract line has a fixed item. There is nothing to select.');

        Item.SetFilter("Item Category Code", SalesLine."Item Category Options");
        Item.SetRange("Sales Blocked", false);
        ItemList.SetTableView(Item);
        ItemList.LookupMode(true);
        if ItemList.RunModal() <> Action::LookupOK then
            exit;
        ItemList.GetRecord(Item);

        KeptQuantity := SalesLine.Quantity;
        SalesLine.Validate("No.", Item."No.");
        if (KeptQuantity <> 0) and (SalesLine.Quantity <> KeptQuantity) then
            SalesLine.Validate(Quantity, KeptQuantity);
        SalesLine.Modify(true);
    end;

    procedure SplitLine(var SalesLine: Record "Sales Line")
    var
        NewLine: Record "Sales Line";
        NextLine: Record "Sales Line";
        SplitDialog: Page "Split Contract Line";
        QtyToSplit: Decimal;
        NewLineNo: Integer;
    begin
        if not IsPackageOrderLine(SalesLine) then Error('This line does not come from a Sales Contract line.');
        SalesLine.TestField(Type, SalesLine.Type::Item);

        if SplitDialog.RunModal() <> Action::OK then
            exit;
        QtyToSplit := SplitDialog.GetQuantity();
        if (QtyToSplit <= 0) or (QtyToSplit >= SalesLine."Outstanding Quantity") then
            Error('Enter a quantity greater than 0 and lower than the outstanding quantity (%1).', SalesLine."Outstanding Quantity");

        NextLine.SetRange("Document Type", SalesLine."Document Type");
        NextLine.SetRange("Document No.", SalesLine."Document No.");
        NextLine.SetFilter("Line No.", '>%1', SalesLine."Line No.");
        if NextLine.FindFirst() then
            NewLineNo := SalesLine."Line No." + (NextLine."Line No." - SalesLine."Line No.") div 2
        else
            NewLineNo := SalesLine."Line No." + 10000;

        if NewLineNo = SalesLine."Line No." then Error('There is no free line number between this line and the next one.');

        SalesLine.Validate(Quantity, SalesLine.Quantity - QtyToSplit);
        SalesLine.Modify(true);

        NewLine.Init();
        NewLine."Document Type" := SalesLine."Document Type";
        NewLine."Document No." := SalesLine."Document No.";
        NewLine."Line No." := NewLineNo;
        NewLine.Validate(Type, NewLine.Type::Item);
        NewLine."Package No." := SalesLine."Package No.";
        NewLine."Package Line No." := SalesLine."Package Line No.";
        NewLine."Paket Category Code" := SalesLine."Paket Category Code";
        NewLine."Item Category Options" := SalesLine."Item Category Options";

        if SalesLine."Item Category Options" = '' then begin
            NewLine.Insert(true);
            NewLine.Validate("No.", SalesLine."No.");
        end else begin
            NewLine."Unit of Measure Code" := SalesLine."Unit of Measure Code";
            NewLine."VAT Prod. Posting Group" := SalesLine."VAT Prod. Posting Group";
            NewLine.Insert(true);
        end;

        NewLine.Validate(Quantity, QtyToSplit);
        NewLine.Modify(true);
    end;
}