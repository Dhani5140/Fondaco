pageextension 50191 "Uninvoiced SO" extends "O365 Activities"
{
    layout
    {
        addfirst(OperationalAlerts)
        {
            field("Uninvoiced SO"; Rec."Uninvoiced SO")
            {
                ApplicationArea = All;
                Caption = 'Uninvoiced Shipments';
                ToolTip = 'Show sales order with remaining shipment amounts (uninvoice shipment)';
                DrillDownPageId = "Sales Order List";
            }
        }
    }
}