pageextension 50104 "Sales Order Contract Ext." extends "Sales Order"
{
    layout
    {
        addafter("External Document No.")
        {
            field("Contract No."; Rec."Contract No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the sales contract for this order.';

                trigger OnLookup(var Text: Text): Boolean
                var
                    SalesContract: Record "Sales Contract Header";
                    SalesContractList: Page "Sales Contract List";
                begin
                    SalesContract.SetRange("Customer No.", Rec."Sell-to Customer No.");
                    SalesContract.SetFilter(Status, '<>%1', SalesContract.Status::Closed);

                    SalesContractList.SetTableView(SalesContract);
                    SalesContractList.LookupMode(true);

                    if SalesContractList.RunModal() = Action::LookupOK then begin
                        SalesContractList.GetRecord(SalesContract);
                        Rec.Validate("Contract No.", SalesContract."No.");
                        Text := SalesContract."No.";
                        exit(true);
                    end;

                    exit(false);
                end;

                trigger OnValidate()
                var
                    SalesContract: Record "Sales Contract Header";
                begin
                    
                    if Rec."Contract No." = '' then exit;

                    if not SalesContract.Get(Rec."Contract No.") then
                        Error('Contract %1 does not exist.', Rec."Contract No.");
                    if SalesContract."Customer No." <> Rec."Sell-to Customer No." then
                        Error('Contract %1 does not belong to customer %2.', Rec."Contract No.", Rec."Sell-to Customer No.");
                    if SalesContract.Status = SalesContract.Status::Closed then
                        Error('Contract %1 is closed and cannot be used.', Rec."Contract No.");
                end;
            }
        }
    }

    var
        ClosedNotif: Notification;
        NearLimitNotif: Notification;
}