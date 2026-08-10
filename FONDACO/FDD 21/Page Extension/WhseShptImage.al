pageextension 50127 WarehouseShipmentAttachExt extends "Warehouse Shipment"
{
    layout
    {
        addlast(factboxes)
        {
            part(Attachments; "Doc. Attachment List Factbox")
            {
                ApplicationArea = All;
                Caption = 'Documents';
                UpdatePropagation = Both;
                SubPageLink = "Table ID" = const(Database::"Warehouse Shipment Header"),
                                           "No." = field("No."),
                                           "Line No." = const(0);
            }
        }
    }
}