tableextension 50111 "Sales Cancel Header Table Ext." extends "Sales Header"
{
    fields
    {
        field(50105; "Cancelled"; Boolean) { }
        field(50106; "Cancellation Reason"; Text[200]) { }
        field(50107; "Cancelled Date"; Date) { }
        field(50108; "Cancelled By"; Code[50]) { }
    }
}