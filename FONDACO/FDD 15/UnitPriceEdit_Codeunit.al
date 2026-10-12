codeunit 50131 "Unit Price Edit Mgt."
{
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnBeforeValidateEvent, 'Unit Price', false, false)]
    local procedure CheckUnitPriceOnValidate(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    var
        UnitPriceEditMgt: Codeunit "Unit Price Edit Mgt.";
    begin
        if CurrFieldNo <> Rec.FieldNo("Unit Price") then exit;

        if not UnitPriceEditMgt.CanEditUnitPrice() then
            Error('You are not allowed to change the Unit Price. Contact your administrator.');
    end;

    procedure CanEditUnitPrice(): Boolean
    var
        UserSetup: Record "User Setup";
    begin
        if not UserSetup.Get(UserId()) then exit(false);

        exit(UserSetup."Allow Change Price");
    end;
}