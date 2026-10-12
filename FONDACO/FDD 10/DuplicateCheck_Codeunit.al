codeunit 50165 "Customer Duplicate Name Mgt."
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::Customer, OnAfterValidateEvent, Name, false, false)]
    local procedure OnAfterValidateName(var Rec: Record Customer; var xRec: Record Customer)
    begin
        if Rec.IsTemporary() then
            exit;
        if Rec.Name = xRec.Name then
            exit;

        CheckDuplicateName(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, OnBeforeInsertEvent, '', false, false)]
    local procedure OnBeforeInsert(var Rec: Record Customer; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;

        CheckDuplicateName(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, OnBeforeModifyEvent, '', false, false)]
    local procedure OnBeforeModify(var Rec: Record Customer; var xRec: Record Customer; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;
        if Rec.Name = xRec.Name then
            exit;

        CheckDuplicateName(Rec);
    end;

    procedure CheckDuplicateName(CurrentCustomer: Record Customer)
    var
        Customer: Record Customer;
        CustomerName: Text[100];
    begin
        CustomerName := CopyStr(DelChr(CurrentCustomer.Name, '<>', ' '), 1, MaxStrLen(CustomerName));

        if CustomerName = '' then
            exit;

        Customer.SetLoadFields("No.", Name);
        Customer.SetFilter("No.", '<>%1', CurrentCustomer."No.");
        Customer.SetRange(Name, CustomerName);
        if Customer.FindFirst() then
            Error('A customer named %1 already exists. Customer names must be unique', CustomerName);
    end;
}