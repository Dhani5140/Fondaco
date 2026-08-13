pageextension 50152 "PI Subform Ext" extends "Purch. Invoice Subform"
{
    layout
    {
        modify("No.")
        {
            trigger OnAfterValidate()
            var
                VendorValidation: Codeunit "Purchases Vendor Validation";
            begin
                VendorValidation.CheckItemVendorNo(Rec."No.", Rec."Document Type", Rec.Type);
            end;

            trigger OnLookup(var Text: Text): Boolean
            var
                Item: Record Item;
                ItemList: Page "Item List";
            begin

                if Rec.Type <> Rec.Type::Item then
                    exit(false);

                if Rec."Document Type" <> Rec."Document Type"::Invoice then
                    exit(false);

                Rec.CalcFields("Vendor No. Filter");

                if Rec."Vendor No. Filter" = '' then
                    exit(false);

                Item.SetRange("Vendor No.", Rec."Vendor No. Filter");

                if Item.IsEmpty then begin
                    Message('No items registered for vendor %1.', Rec."Vendor No. Filter");
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
    }

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Vendor No. Filter");
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.CalcFields("Vendor No. Filter");
    end;
}