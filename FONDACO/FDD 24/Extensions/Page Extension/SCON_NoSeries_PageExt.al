pageextension 50101 "No. Series Cicilan Ext" extends "No. Series"
{
    layout
    {
        addafter(AllowGapsCtrl)
        {
            field("Nomor Faktur Cicilan"; Rec."Nomor Faktur Cicilan")
            {
                ApplicationArea = All;
                Caption = 'Nomor Faktur Cicilan';
            }
            field("Nomor Faktur Pengiriman Cicilan"; Rec."Nomor Faktur Pengiriman")
            {
                ApplicationArea = All;
                Caption = 'Nomor Faktur Pengiriman Cicilan';
            }
        }
    }
}