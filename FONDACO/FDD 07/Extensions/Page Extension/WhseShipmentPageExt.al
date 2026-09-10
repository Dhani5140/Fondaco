pageextension 50160 "Warehouse InstDate PageExt." extends "Warehouse Shipment"
{
    layout
    {
        addafter("Sorting Method")
        {
            field("Installation Date"; Rec."InstallationDate")
            {
                Caption = 'Installation Date';
                ToolTip = 'Specifies the installation date of item';
            }
        }
    }
    actions
    {
        modify("P&ost Shipment")
        {
            trigger OnBeforeAction()
            var
                WhseShptLine: Record "Warehouse Shipment Line";
                SalesHeader: Record "Sales Header";
            begin
                if Rec."InstallationDate" = 0D then
                    exit;

                WhseShptLine.SetRange("No.", Rec."No.");
                WhseShptLine.SetRange("Source Type", Database::"Sales Line");
                if WhseShptLine.FindSet() then
                    repeat
                        if SalesHeader.Get(SalesHeader."Document Type"::Order, WhseShptLine."Source No.") then
                            if SalesHeader."InstallationDate" = 0D then begin
                                SalesHeader."InstallationDate" := Rec."InstallationDate";
                                SalesHeader.Modify();
                            end;
                    until WhseShptLine.Next() = 0;
            end;
        }
    }
}