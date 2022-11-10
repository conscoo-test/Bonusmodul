pageextension 5266052 "lbtbn Customer Card" extends "Customer Card"
{
    layout
    {
        addlast(content)
        {
            group("lbtbn ")
            {
                Caption = 'Bonus';
                field("lbtbn Customer Group"; Rec."lbtbn Customer Group")
                {
                    ToolTip = 'The customer bonus groups can be assigned to the customer.';
                    ApplicationArea = All;
                }
            }
        }
    }
}