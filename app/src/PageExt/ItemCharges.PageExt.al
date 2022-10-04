pageextension 5266062 "lbtbn Item Charges" extends "Item Charges" //5800
{
    layout
    {
        addlast(Control1)
        {


            field("lbtbn Bonus consider"; Rec."lbtbn Bonus consider")
            {
                ToolTip = 'Indicate which surcharges and discounts are relevant for bonus.';
                ApplicationArea = All;
            }
        }

    }

    actions
    {
    }
}