page 5266059 "lbtbn Bonus Customers"
{

    PageType = List;
    SourceTable = "lbtbn Bonus Customer";
    Caption = 'Bonus Customers';
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {

                field(Customer; Rec."Customer No.")
                {
                    ToolTip = 'This field is filled with the customer from the bonus contract.';
                    ApplicationArea = All;
                }
                field("Ship-to Code"; Rec."Ship-to Code")
                {
                    ToolTip = 'This field is filled with the delivery contact from the bonus contract.';
                    ApplicationArea = All;
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ToolTip = 'This field is filled with the customer name from the bonus contract.';
                    ApplicationArea = All;
                }
                field("Ship-to Name"; Rec."Ship-to Name")
                {
                    ToolTip = 'This field is filled with the delivery contact name from the bonus contract.';
                    ApplicationArea = All;
                }
                field("Customer Group"; Rec."Customer Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Bonus Group field.';
                }
            }
        }
    }

}
