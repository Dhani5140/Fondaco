pageextension 50179 "Catatan SI PageExt." extends "Sales Invoice Subform"
{
    layout
    {
        addafter(Description)
        {
            field("Catatan 1"; Rec."Catatan 1") { ApplicationArea = All; }
            field("Catatan 2"; Rec."Catatan 2") { ApplicationArea = All; }
            field("Catatan 3"; Rec."Catatan 3") { ApplicationArea = All; }
            field("Catatan 4"; Rec."Catatan 4") { ApplicationArea = All; }
        }
    }
}