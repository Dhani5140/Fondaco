codeunit 50111 CloseCancSalesCode
{
    procedure CancelQtySO(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        HasQtyToShip: Boolean;
        TotalOriginalQty: Decimal;
        TotalCancelQty: Decimal;
        TotalShippedQty: Decimal;
    begin
        // Validasi 1 : Cancelled Reason must be filled
        if SalesHeader."Cancellation Reason" = '' then
            Error('Cannot Cancel SO, because Cancelled Reason must have a value.');

        // Validasi 2 : Qty. to Ship <> 0
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                if SalesLine."Qty. to Ship" <> 0 then
                    HasQtyToShip := true;
            until SalesLine.Next() = 0;

        if not HasQtyToShip then
            Error('Cannot Cancel SO, because Qty. to Ship must have a value.');

        SalesLine.CalcSums("Qty. to Ship", Quantity, "Quantity Shipped");
        TotalOriginalQty := SalesLine.Quantity;
        TotalCancelQty := SalesLine."Qty. to Ship";
        TotalShippedQty := SalesLine."Quantity Shipped";

        if not Confirm('The Quantity for cancel is %1. Are you sure you want to cancel?', false, TotalCancelQty) then
            exit;

        if SalesLine.FindSet(true) then
            repeat
                if SalesLine."Qty. to Ship" <> 0 then begin
                    SalesLine."Cancel Qty." := SalesLine."Qty. to Ship";
                    SalesLine."Qty. to Ship" := 0;
                    SalesLine.Modify(true);
                end;
            until SalesLine.Next() = 0;

        SalesHeader."Cancelled" := true;
        SalesHeader.Status := SalesHeader.Status::Cancelled;
        SalesHeader."Cancelled Date" := Today;
        SalesHeader."Cancelled By" := CopyStr(UserId, 1, 50);
        SalesHeader.Modify(true);

        Message('Sales Order %1 has been Cancelled.', SalesHeader."No.");

    end;
}
