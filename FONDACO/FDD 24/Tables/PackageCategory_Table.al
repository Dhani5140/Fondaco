table 50103 "Paket Kategori"
{
    Caption = 'Kategori Paket';
    DataClassification = CustomerContent;
    LookupPageId = "Paket Kategori List";
    DrillDownPageId = "Paket Kategori List";

    fields
    {
        field(1; Code; Code[20]) { Caption = 'Code'; NotBlank = true; }
        field(2; Description; Text[100]) { Caption = 'Description'; }
        field(3; Blocked; Boolean) { Caption = 'Blocked'; }
    }
    keys { key(PK; Code) { Clustered = true; } }

    trigger OnDelete()
    var
        ContractHeader: Record "Sales Contract Header";
    begin
        ContractHeader.SetRange("Paket Category Code", Code);
        if not ContractHeader.IsEmpty() then
            Error('You cannot delete Paket Kategori %1 because it is used by a Sales Contract.', Code);
    end;
}