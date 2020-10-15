pageextension 5266051 "lbt Customer Posting Groups" extends "Customer Posting Groups" //110
{
    layout
    {
        addlast(Control1)
        {


            field("lbt Bonus Reserve Account"; Rec."lbt Bonus Reserve Account")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the bonus reserve account';
            }
            field("lbt Bonus Reserve Bal. Account"; Rec."lbt Bonus Reserve Bal. Account")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the bonus reserve bal. account';
            }
        }
    }


}