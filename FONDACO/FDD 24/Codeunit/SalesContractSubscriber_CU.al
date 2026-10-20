codeunit 50103 "Sales Contract Order Subs."
{

    // Copy to Cust Ledger Entry
    [EventSubscriber(ObjectType::Table, Database::"Cust. Ledger Entry", 'OnAfterCopyCustLedgerEntryFromGenJnlLine', '', false, false)]
    local procedure CopyPackageNoToCustLedgerEntry(var CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        CustLedgerEntry."Sales Package No." := GenJournalLine."Sales Package No.";
    end;

    // Copy to GLEntry
    [EventSubscriber(ObjectType::Table, Database::"G/L Entry", 'OnAfterCopyGLEntryFromGenJnlLine', '', false, false)]
    local procedure CopyPackageNoToGLEntry(var GLEntry: Record "G/L Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        GLEntry."Sales Package No." := GenJournalLine."Sales Package No.";
    end;

    // --- Sales Line: contract-driven ---

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeValidateEvent', 'No.', false, false)]
    local procedure LineNoBeforeValidate(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        OrderMgt.CheckLineItemChange(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure LineNoAfterValidate(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        OrderMgt.OnAfterValidateLineNo(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'Quantity', false, false)]
    local procedure LineQuantityAfterValidate(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        OrderMgt.OnAfterValidateLineQuantity(Rec);
    end;

    // --- Sales Line: fields locked on package lines ---

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeValidateEvent', 'Type', false, false)]
    local procedure LineTypeBeforeValidate(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        OrderMgt.CheckPackageFieldLocked(Rec, CurrFieldNo, Rec.FieldNo(Type));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeValidateEvent', 'Unit of Measure Code', false, false)]
    local procedure LineUoMBeforeValidate(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        OrderMgt.CheckPackageFieldLocked(Rec, CurrFieldNo, Rec.FieldNo("Unit of Measure Code"));
    end;

    // --- Sales Line: amount fields locked on a cicilan order ---

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeValidateEvent', 'Unit Price', false, false)]
    local procedure LineUnitPriceBeforeValidate(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        OrderMgt.CheckAmountFieldLocked(Rec, CurrFieldNo, Rec.FieldNo("Unit Price"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeValidateEvent', 'Line Discount %', false, false)]
    local procedure LineDiscPctBeforeValidate(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        OrderMgt.CheckAmountFieldLocked(Rec, CurrFieldNo, Rec.FieldNo("Line Discount %"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeValidateEvent', 'Line Discount Amount', false, false)]
    local procedure LineDiscAmtBeforeValidate(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        OrderMgt.CheckAmountFieldLocked(Rec, CurrFieldNo, Rec.FieldNo("Line Discount Amount"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeValidateEvent', 'Line Amount', false, false)]
    local procedure LineAmountBeforeValidate(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        OrderMgt.CheckAmountFieldLocked(Rec, CurrFieldNo, Rec.FieldNo("Line Amount"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeValidateEvent', 'Unit Cost (LCY)', false, false)]
    local procedure LineUnitCostBeforeValidate(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        OrderMgt.CheckAmountFieldLocked(Rec, CurrFieldNo, Rec.FieldNo("Unit Cost (LCY)"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeValidateEvent', 'Inv. Discount Amount', false, false)]
    local procedure LineInvDiscBeforeValidate(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        OrderMgt.CheckAmountFieldLocked(Rec, CurrFieldNo, Rec.FieldNo("Inv. Discount Amount"));
    end;

    // --- Sales Header: customer is fixed once a contract is chosen ---

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeValidateEvent', 'Sell-to Customer No.', false, false)]
    local procedure HeaderCustomerBeforeValidate(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    var
        CustomerLockedErr: Label 'Sell-to Customer No. cannot be changed once a Package No. is selected.';
    begin
        if (CurrFieldNo = Rec.FieldNo("Sell-to Customer No.")) and (Rec."Package No." <> '') and
           (Rec."Sell-to Customer No." <> xRec."Sell-to Customer No.")
        then
            Error(CustomerLockedErr);
    end;

    var
        OrderMgt: Codeunit "Sales Contract Order Mgt.";
}