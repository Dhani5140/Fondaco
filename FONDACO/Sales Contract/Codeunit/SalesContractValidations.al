codeunit 50101 "Sales Contract Validation"
{
    procedure CheckItemCategoryItems(ItemCategoryCode: Code[20]; DocumentType: Enum "Sales Document Type")
    var
        Item: Record Item;
    begin
        if DocumentType <> DocumentType::Order then exit;
        if ItemCategoryCode = '' then exit;

        Item.SetRange("Item Category Code", ItemCategoryCode);
        if Item.IsEmpty then
            Error('No items are registered under category %1. Please assign items to this category first.', ItemCategoryCode);
    end;

    procedure GetCategoryFilterForContract(ContractNo: Code[20]): Text
    var
        SalesContractLine: Record "Sales Contract Line";
        CategoryFilter: Text;
    begin
        if ContractNo = '' then exit('');

        SalesContractLine.SetRange("Contract No.", ContractNo);
        if not SalesContractLine.FindSet() then exit('');

        repeat
            if CategoryFilter <> '' then
                CategoryFilter += '|';
            CategoryFilter += SalesContractLine."Item Category Code";
        until SalesContractLine.Next() = 0;

        exit(CategoryFilter);
    end;

    procedure CheckItemInLineContractCategory(ItemNo: Code[20]; ContractNo: Code[20])
    var
        SalesContractLine: Record "Sales Contract Line";
        Item: Record Item;
    begin
        if ItemNo = '' then exit;
        if ContractNo = '' then exit;

        if not Item.Get(ItemNo) then exit;

        SalesContractLine.SetRange("Contract No.", ContractNo);
        SalesContractLine.SetRange("Item Category Code", Item."Item Category Code");

        if SalesContractLine.IsEmpty then
            Error('Item %1 (Category: %2) is not included in contract %3.', ItemNo, Item."Item Category Code", ContractNo);
    end;
}