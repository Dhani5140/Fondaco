pageextension 50140 "Service Item Warranty Exp." extends "O365 Activities"
{
    layout
    {
        addafter("Service Contracts Due")
        {
            field("Parts Warranty Exp."; Rec."Parts Warranty Exp.")
            {
                ApplicationArea = all;
                Caption = 'Warranty Expiring (Parts)';
                ToolTip = 'Shows the number of parts warranty expiring within the next 30 days.';
                DrillDownPageId = "Service Items";

            }
            field("Labor Warranty Exp."; Rec."Labor Warranty Exp.")
            {
                ApplicationArea = all;
                Caption = 'Warranty Expiring (Labor)';
                ToolTip = 'Shows the number of labor warranty expiring within the next 30 days.';
                DrillDownPageId = "Service Items";
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

        Rec.SetFilter("Warranty Date Filter", '%1..%2', Today, CalcDate('<+30D>', Today));
        Rec.CalcFields("Parts Warranty Exp.", "Labor Warranty Exp.");
    end;
}