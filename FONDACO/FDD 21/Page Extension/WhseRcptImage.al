pageextension 50126 WarehouseReceiptAttachExt extends "Warehouse Receipt"
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
                SubPageLink = "Table ID" = const(Database::"Warehouse Receipt Header"),
                                           "No." = field("No."),
                                           "Line No." = const(0);
            }
        }
    }
}