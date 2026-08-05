pageextension 50141 "Warranty Exp Service Item List" extends "Service Item List"
{
    views
    {
        addfirst
        {
            view(PartsWarrantyExpiring)
            {
                Caption = 'Parts Warranty Expiring';
                Filters = where("Warranty Ending Date (Parts)" = filter(> 0D));
            }
            view(LaborWarrantyExpiring)
            {
                Caption = 'Labor Warranty Expiring';
                Filters = where("Warranty Ending Date (Labor)" = filter(> 0D));
            }
        }
    }
}