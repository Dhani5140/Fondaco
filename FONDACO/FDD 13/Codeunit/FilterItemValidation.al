codeunit 50150 "Purchases Vendor Validation"
{
    procedure CheckItemVendorNo(ItemNo: Code[20]; DocumentType: Enum "Purchase Document Type"; LineType: Enum "Purchase Line Type")
    var
        Item: Record Item;
    begin
        if LineType <> LineType::Item then exit;
        if DocumentType <> DocumentType::Order then exit;
        if ItemNo = '' then exit;
        if not Item.Get(ItemNo) then exit;
        if Item."Vendor No." = '' then
            Error('Vendor No. has not been field on this item');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnAfterValidateEvent, 'No.', false, false)]
    local procedure ValidateItemVendorOnPurchaseLine(var Rec: Record "Purchase Line")
    var
        PurchHeader: Record "Purchase Header";
        Item: Record Item;
    begin
        if Rec.Type <> Rec.Type::Item then
            exit;

        if Rec."No." = '' then
            exit;

        if Rec."Document Type" <> Rec."Document Type"::Order then
            exit;

        if not PurchHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;

        if PurchHeader."Buy-from Vendor No." = '' then
            exit;

        if not Item.Get(Rec."No.") then
            exit;

        if Item."Vendor No." <> PurchHeader."Buy-from Vendor No." then
            Error('Item %1 is not registered for vendor %2.',
                Rec."No.", PurchHeader."Buy-from Vendor No.");
    end;
}