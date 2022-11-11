pageextension 5266053 "lbtbn Item Card" extends "Item Card"
{
    layout
    {
        addlast(content)
        {
            group("lbtbn lbtbn")
            {
                Caption = 'Bonus';
                field("lbtbn Item Group"; Rec."lbtbn Item Group")
                {
                    ToolTip = 'The Item bonus groups can be assigned to the Item.';
                    ApplicationArea = All;
                }
            }
        }
    }
}