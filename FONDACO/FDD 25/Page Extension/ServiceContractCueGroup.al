pageextension 50136 "Service Contract Mgt. Ext." extends "O365 Activities"
{
    layout
    {
        addlast(content)
        {
            cuegroup(ServiceContractsDueCueGroup)
            {
                Caption = 'Service Management';

                field("Service Contracts Due"; Rec."Service Contracts Due")
                {
                    ApplicationArea = All;
                    Caption = 'Service Contracts Due';
                    ToolTip = 'Shows the number of signed service contracts expiring within the next 30 days.';
                    DrillDownPageId = "Service Contracts";
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;

        Rec.SetFilter("Date Filter Service", '%1..%2', Today, CalcDate('<+30D>', Today));
        Rec.CalcFields("Service Contracts Due");
    end;
}