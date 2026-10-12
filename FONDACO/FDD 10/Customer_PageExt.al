pageextension 50165 "Customer Mandatory Ext." extends "Customer Card"
{
    layout
    {
        modify(Name)
        {
            ShowMandatory = true;

            trigger OnAfterValidate()
            var
                DuplicateCU: Codeunit "Customer Duplicate Name Mgt.";
            begin
                if xRec.Name = '' then exit;
                if xRec.Name = Rec.Name then exit;
                DuplicateCU.CheckDuplicateName(Rec);
            end;
        }
        modify(Address)
        {
            ShowMandatory = true;
        }
    }
}