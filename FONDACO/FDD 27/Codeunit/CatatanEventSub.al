codeunit 50175 "Catatan Flow Mgt."
{
    // Order -> Warehouse Shipment Line
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Create Source Document", 'OnBeforeWhseShptLineInsert', '', false, false)]
    local procedure CopyToWhseShptLine(var WarehouseShipmentLine: Record "Warehouse Shipment Line")
    var
        SalesLine: Record "Sales Line";
    begin
        if WarehouseShipmentLine."Source Type" <> Database::"Sales Line" then
            exit;

        if SalesLine.Get(
            Enum::"Sales Document Type".FromInteger(WarehouseShipmentLine."Source Subtype"),
            WarehouseShipmentLine."Source No.",
            WarehouseShipmentLine."Source Line No.")
        then
            WarehouseShipmentLine."Catatan 1" := SalesLine."Catatan 1";
        WarehouseShipmentLine."Catatan 2" := SalesLine."Catatan 2";
        WarehouseShipmentLine."Catatan 3" := SalesLine."Catatan 3";
        WarehouseShipmentLine."Catatan 4" := SalesLine."Catatan 4";
    end;

    // Posted Shipment Line -> Sales Invoice Line (Get Shipment Lines)
    [EventSubscriber(ObjectType::Table, Database::"Sales Shipment Line", 'OnAfterInsertInvLineFromShptLine', '', false, false)]
    local procedure CopyToInvoiceLine(var SalesLine: Record "Sales Line"; SalesOrderLine: Record "Sales Line"; var NextLineNo: Integer; var SalesShipmentLine: Record "Sales Shipment Line")
    var
        NeedsModify: Boolean;
    begin
        if SalesLine."Catatan 1" <> SalesShipmentLine."Catatan 1" then begin
            SalesLine."Catatan 1" := SalesShipmentLine."Catatan 1";
            NeedsModify := true;
        end;
        if SalesLine."Catatan 2" <> SalesShipmentLine."Catatan 2" then begin
            SalesLine."Catatan 2" := SalesShipmentLine."Catatan 2";
            NeedsModify := true;
        end;
        if SalesLine."Catatan 3" <> SalesShipmentLine."Catatan 3" then begin
            SalesLine."Catatan 3" := SalesShipmentLine."Catatan 3";
            NeedsModify := true;
        end;
        if SalesLine."Catatan 4" <> SalesShipmentLine."Catatan 4" then begin
            SalesLine."Catatan 4" := SalesShipmentLine."Catatan 4";
            NeedsModify := true;
        end;

        if NeedsModify then
            SalesLine.Modify();
    end;
}