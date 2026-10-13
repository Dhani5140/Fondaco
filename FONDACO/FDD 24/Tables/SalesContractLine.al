table 50101 "Sales Contract Line"
{
    Caption = 'Sales Contract Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            DataClassification = CustomerContent;
            TableRelation = "Sales Contract Header";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(3; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Category";

            trigger OnValidate()
            var
                ItemCat: Record "Item Category";
            begin
                if "Item Category Code" = '' then begin
                    Description := '';
                    exit;
                end;
                if ItemCat.Get("Item Category Code") then
                    Description := ItemCat.Description;
            end;
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Contract No.", "Line No.") { Clustered = true; }
    }
}