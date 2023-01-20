page 5266060 "lbtbn Bonus Contract Factbox"
{
    PageType = CardPart;
    SourceTable = "lbtbn Bonus Contract";
    Caption = 'Bonus Contract Details';

    layout
    {
        area(content)
        {

            field("Last Reserve at"; Rec."Last Reserve at")
            {
                ToolTip = 'Displays the last reset performed.';
                ApplicationArea = All;
            }
            field("Last Billing at"; Rec."Last Billing at")
            {
                ToolTip = 'Displays when the last settlement was performed.';
                ApplicationArea = All;
            }

            field("No. of Customer"; Rec."No. of Customers")
            {
                ToolTip = 'Indicates the number of customers.';
                ApplicationArea = All;
            }
            field("No. of Attribute"; Rec."No. of Attribute")
            {
                ToolTip = 'Indicates the number of existing attributes.';
                ApplicationArea = All;
            }
            field("Balance of Reserve"; Rec."Balance of Reserve")
            {
                ToolTip = 'Indicates the balance of provisions.';
                ApplicationArea = All;
            }
            field("Balance of Liquid Reserves"; Rec."Balance of Liquid Reserves")
            {
                ToolTip = 'Indicates the balance of the reversal of reserves.';
                ApplicationArea = All;
            }
            field("Balance of Bonus"; Rec."Balance of Bonus")
            {
                ToolTip = 'Indicates the balance of the bonus.';
                ApplicationArea = All;
            }
        }
    }
}
