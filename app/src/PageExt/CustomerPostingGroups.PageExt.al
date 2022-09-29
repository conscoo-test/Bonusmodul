pageextension 5266051 "lbtbn Customer Posting Groups" extends "Customer Posting Groups" //110
{
    layout
    {
        addlast(Control1)
        {


            field("lbtbn Bonus Reserve Account"; Rec."lbtbn Bonus Reserve Account")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the bonus reserve account';
            }
            field("lbtbn Bonus Reserve Bal. Account"; Rec."lbtbn Bonus Reserve Bal. Account")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the bonus reserve bal. account';
            }
        }
    }


}