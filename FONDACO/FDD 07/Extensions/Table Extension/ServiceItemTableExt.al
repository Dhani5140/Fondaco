tableextension 50164 "Service Item Ext" extends "Service Item"
{
    fields
    {
        field(50164; "InstallationDate"; Date)
        {
            Caption = 'Installation Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}