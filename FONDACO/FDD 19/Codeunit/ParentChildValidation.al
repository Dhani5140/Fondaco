codeunit 50155 "Parent Child Relationship Val."
{
    [EventSubscriber(ObjectType::Table, Database::Customer, OnBeforeInsertEvent, '', false, false)]
    local procedure BeforeInsertCustomerValidation(var Rec: Record Customer)
    begin
        CheckParentMandatory(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, OnBeforeModifyEvent, '', false, false)]
    local procedure BeforeModifyCustomerValidation(var Rec: Record Customer)
    begin
        CheckParentMandatory(Rec);
    end;

    local procedure CheckParentMandatory(var CustomerRec: Record Customer)
    begin
        if (not CustomerRec."Is Parent Customer") and (CustomerRec."Parent Customer No." = '') then
            Error('Parent Customer No. must be specified when Is Parent Customer is set to No.');
    end;
}