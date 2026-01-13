enum 5266052 "lbtbn Billing Type"
{
    Extensible = false;

    value(0; "%")
    {
        Caption = '%';
    }
    //value(1; "Amount")
    ///Umbenennung auf alten Wert da Umbenennung im APP-Store nicht erlaubt ist (Caption bleibt auf neuem Wert)
    value(1; "Amount (LCY)")
    {
        Caption = 'Amount';
    }
    value(2; "Amount per Unit")
    {
        Caption = 'Amount per Unit';
    }
}