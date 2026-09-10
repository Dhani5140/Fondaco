tableextension 50150 "Purchase Line Item Vendor" extends "Purchase Line"
{
    fields
    {
        field(50150; "Vendor No. Filter"; Code[20])
        {
            Caption = 'Vendor No. Filter';
            FieldClass = FlowField;
            CalcFormula = lookup("Purchase Header"."Buy-from Vendor No." where("Document Type" = field("Document Type"), "No." = field("Document No.")));
            Editable = false;
        }

        modify("No.")
        {
            TableRelation = if (Type = const(Item), "Document Type" = const(Order)) Item
                where("Vendor No." = field("Vendor No. Filter"))
            else
            if (Type = const(Item)) Item;
        }
    }

    trigger OnBeforeInsert()
    var
        VendorValidate: Codeunit "Purchases Vendor Validation";
    begin
        VendorValidate.CheckItemVendorNo(Rec."No.", Rec."Document Type", Rec.Type);
    end;

    trigger OnBeforeModify()
    var
        VendorValidate: Codeunit "Purchases Vendor Validation";
    begin
        VendorValidate.CheckItemVendorNo(Rec."No.", Rec."Document Type", Rec.Type);
    end;
}