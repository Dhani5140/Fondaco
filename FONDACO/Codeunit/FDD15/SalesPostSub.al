codeunit 50116 "Sales Post Sub"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesInvHeaderInsert', '', false, false)]
    local procedure OnBeforeSalesInvHeaderInsert(
        var SalesInvHeader: Record "Sales Invoice Header";
        SalesHeader: Record "Sales Header")
    begin
        SalesInvHeader.Delivered := SalesHeader.Delivered;
        SalesInvHeader."Courier Name" := SalesHeader."Courier Name";
    end;
}