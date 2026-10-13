pageextension 50178 "Catatan PostedShpt PageExt." extends "Posted Sales Shpt. Subform"
{
    layout
    {
        addafter("Location Code")
        {
            field("Catatan 1"; Rec."Catatan 1") { ApplicationArea = All; }
            field("Catatan 2"; Rec."Catatan 2") { ApplicationArea = All; }
            field("Catatan 3"; Rec."Catatan 3") { ApplicationArea = All; }
            field("Catatan 4"; Rec."Catatan 4") { ApplicationArea = All; }
        }
    }
}