pageextension 50137 "Service Contracts Due" extends "O365 Activities"
{
    layout
    {
        addlast(content)
        {
            cuegroup(ServiceContracts)
            {
                Caption = 'Service Contracts';

                field("Service Contracts Due"; Rec."Service Contracts Due")
                {
                    ApplicationArea = All;
                    Caption = 'Contracts Due (30 Days)';
                    StyleExpr = ContractsDueStyle;

                    trigger OnDrillDown()
                    var
                        SvcContractHdr: Record "Service Contract Header";
                        ServiceContractList: Page "Service Contract List";
                    begin
                        SvcContractHdr.SetFilter(
                            "Expiration Date", '%1..%2',
                            Today(),
                            CalcDate('<+30D>', Today())
                        );
                        ServiceContractList.SetTableView(SvcContractHdr);
                        ServiceContractList.Run();
                    end;
                }
            }
        }
    }

    var
        ContractsDueStyle: Text;

    trigger OnOpenPage()
    var
        SvcContractHdr: Record "Service Contract Header";
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;

        SvcContractHdr.SetFilter(
            "Expiration Date", '%1..%2',
            Today(),
            CalcDate('<+30D>', Today())
        );
        Rec."Service Contracts Due" := SvcContractHdr.Count();
        Rec.Modify();
    end;

    trigger OnAfterGetRecord()
    begin
        case true of
            Rec."Service Contracts Due" >= 10:
                ContractsDueStyle := 'Unfavorable';
            Rec."Service Contracts Due" >= 5:
                ContractsDueStyle := 'Attention';
            else
                ContractsDueStyle := 'Favorable';
        end;
    end;
}