page 50105 "Paket Kategori List"
{
    Caption = 'Paket Categories';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Paket Kategori";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Code; Rec.Code) { }
                field(Description; Rec.Description) { }
                field(Blocked; Rec.Blocked) { }
            }
        }
    }
}