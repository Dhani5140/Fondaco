pageextension 50106 "Sales Return Order Subform" extends "Sales Return Order Subform"
{
    layout
    {
        modify("No.")
        {
            trigger OnAfterValidate()
            begin
                InheritContractFromHeader();
                SalesContractValidation.CheckItemInLineContractCategory(Rec."No.", Rec."Contract No.");
            end;

            trigger OnLookup(var Text: Text): Boolean
            var
                Item: Record Item;
                ItemList: Page "Item List";
                CategoryFilter: Text;
            begin
                if Rec.Type <> Rec.Type::Item then
                    exit(false);

                InheritContractFromHeader();

                if Rec."Contract No." = '' then
                    exit(false);

                CategoryFilter := SalesContractValidation.GetCategoryFilterForContract(Rec."Contract No.");

                if CategoryFilter = '' then begin
                    Message('No categories defined on contract %1.', Rec."Contract No.");
                    exit(false);
                end;

                Item.SetFilter("Item Category Code", CategoryFilter);

                if Item.IsEmpty then begin
                    Message('No items found for the categories in contract %1.', Rec."Contract No.");
                    exit(false);
                end;

                ItemList.SetTableView(Item);
                ItemList.LookupMode(true);

                if ItemList.RunModal() = Action::LookupOK then begin
                    ItemList.GetRecord(Item);
                    Text := Item."No.";
                    exit(true);
                end;

                exit(false);
            end;
        }

        modify(Quantity)
        {
            trigger OnAfterValidate()
            begin
                InheritContractFromHeader();
            end;
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        InheritContractFromHeader();
    end;

    local procedure InheritContractFromHeader()
    var
        SalesHeader: Record "Sales Header";
    begin
        if Rec."Contract No." <> '' then exit;

        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") then exit;
        if SalesHeader."Contract No." = '' then exit;

        Rec."Contract No." := SalesHeader."Contract No.";

        if Rec."Line No." <> 0 then
            Rec.Modify(false);
    end;

    var
        SalesContractValidation: Codeunit "Sales Contract Validation";
}