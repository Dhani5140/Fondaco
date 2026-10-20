pageextension 50104 "Sales Order Package PageExt." extends "Sales Order"
{
    layout
    {
        addafter(Status)
        {
            field("Package No."; Rec."Package No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Sales Contract Cicilan this order delivers goods for.';

                trigger OnLookup(var Text: Text): Boolean
                var
                    ContractLookup: Page "Sales Contract Lookup";
                begin
                    Rec.TestField("Sell-to Customer No.");
                    ContractLookup.SetCustomer(Rec."Sell-to Customer No.");
                    ContractLookup.LookupMode(true);
                    if ContractLookup.RunModal() <> Action::LookupOK then
                        exit(false);
                    Text := ContractLookup.GetSelectedPackageNo();
                    exit(true);
                end;
            }
        }
    }
}