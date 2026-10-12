pageextension 50132 "Unit Price (SI) Ext." extends "Sales Invoice Subform"
{
    layout
    {
        modify("Unit Price")
        {
            Editable = UnitPriceEditable;
        }
    }

    var
        UnitPriceEditable: Boolean;

    trigger OnOpenPage()
    var
        UnitPriceEditMgt: Codeunit "Unit Price Edit Mgt.";
    begin
        UnitPriceEditable := UnitPriceEditMgt.CanEditUnitPrice();
    end;
}