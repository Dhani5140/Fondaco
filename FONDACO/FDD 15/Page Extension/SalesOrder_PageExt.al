pageextension 50133 "Unit Price (SO) Ext." extends "Sales Order Subform"
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