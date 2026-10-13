pageextension 50177 "Catatan WhseShip PageExt." extends "Whse. Shipment Subform"
{
    layout
    {
        addafter("Qty. to Ship")
        {
            field("Catatan 1"; Rec."Catatan 1") { ApplicationArea = All; Editable = false; }
            field("Catatan 2"; Rec."Catatan 2") { ApplicationArea = All; Editable = false; }
            field("Catatan 3"; Rec."Catatan 3") { ApplicationArea = All; Editable = false; }
            field("Catatan 4"; Rec."Catatan 4") { ApplicationArea = All; Editable = false; }
        }
    }
}