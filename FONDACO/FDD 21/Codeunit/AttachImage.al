codeunit 50126 "Attachment RecRef Handler"
{
    SingleInstance = true;

    var
        PendingContractNo: Code[20];

    [EventSubscriber(ObjectType::Page, Page::"Doc. Attachment List Factbox", 'OnAfterGetRecRefFail', '', false, false)]
    local procedure OnAfterGetRecRefFail(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        SalesContractHeader: Record "Sales Contract Header";
        WhseShipmentHeader: Record "Warehouse Shipment Header";
        WhseReceiptHeader: Record "Warehouse Receipt Header";
    begin
        case DocumentAttachment."Table ID" of
            Database::"Sales Contract Header":
                begin
                    PendingContractNo := DocumentAttachment."No.";
                    RecRef.Open(Database::"Sales Contract Header");
                    if SalesContractHeader.Get(PendingContractNo) then
                        RecRef.GetTable(SalesContractHeader);
                end;
            Database::"Warehouse Shipment Header":
                begin
                    PendingContractNo := DocumentAttachment."No.";
                    RecRef.Open(Database::"Warehouse Shipment Header");
                    if WhseShipmentHeader.Get(PendingContractNo) then
                        RecRef.GetTable(WhseShipmentHeader);
                end;
            Database::"Warehouse Receipt Header":
                begin
                    PendingContractNo := DocumentAttachment."No.";
                    RecRef.Open(Database::"Warehouse Receipt Header");
                    if WhseReceiptHeader.Get(PendingContractNo) then
                        RecRef.GetTable(WhseReceiptHeader);
                end;

        // add more databases if needed

        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Document Attachment", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertDocAttachment(var Rec: Record "Document Attachment"; RunTrigger: Boolean)
    begin
        if (Rec."No." = '') and (PendingContractNo <> '') then
            if Rec."Table ID" in [Database::"Sales Contract Header", Database::"Warehouse Shipment Header", Database::"Warehouse Receipt Header"] then
                Rec."No." := PendingContractNo;
    end;
}