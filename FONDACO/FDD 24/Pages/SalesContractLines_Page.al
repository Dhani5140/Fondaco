page 50103 "Sales Contract Lines"
{
    Caption = 'Lines';
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "Sales Contract Lines";

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                Editable = ParentEditable;

                field("Item No."; Rec."Item No.") { }
                field("Item Category Code"; Rec."Item Category Code") { Editable = false; }
                field("Unit of Measure Code"; Rec."Unit of Measure Code") { ShowMandatory = true; }
                field("Item Category Options"; Rec."Item Category Options")
                {
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(Rec.LookupItemCategoryOptions(Text));
                    end;
                }
                field(Quantity; Rec.Quantity) { }
                field("Direct Unit Price"; Rec."Direct Unit Price") { }
                field("Total Excl. VAT"; Rec."Total Excl. VAT") { Editable = false; }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group") { }
                field("Total Incl. VAT"; Rec."Total Incl. VAT") { Editable = false; }
                field("Quantity on SO"; Rec."Quantity on SO") { }
                field("Quantity Received"; Rec."Quantity Received") { }
                field("Quantity Invoiced"; Rec."Quantity Invoiced") { }
                field("Quantity Returned"; Rec."Quantity Returned") { }
                field(RemainingQuantity; RemainingQuantity)
                {
                    Caption = 'Remaining Quantity';
                    Editable = false;
                    DecimalPlaces = 0 : 5;
                }
            }
        }
    }

    var
        ParentEditable: Boolean;
        RemainingQuantity: Decimal;

    trigger OnAfterGetRecord()
    begin
        RemainingQuantity := Rec.GetRemainingQuantity();
    end;

    procedure SetParentEditable(NewEditable: Boolean)
    begin
        ParentEditable := NewEditable;
    end;
}