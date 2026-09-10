pageextension 50146 "Disable bin pick subform" extends "Whse. Pick Subform"
{
    layout
    {
        modify("Bin Code")
        {
            Editable = not DisableBinSelection;
        }
        modify("Lot No.")
        {
            Editable = not DisableBinSelection;
        }
    }

    trigger OnOpenPage()
    var
        InvSetup: Record "Inventory Setup";
    begin
        if InvSetup.Get() then
            DisableBinSelection := InvSetup."Disable Bin";
    end;

    var
        DisableBinSelection: Boolean;
}