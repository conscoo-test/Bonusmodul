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
                Visible = false;
                ToolTip = 'Indicates the number of customers.';
                ApplicationArea = All;
            }
            field("No. of Attribute"; Rec."No. of Attribute")
            {
                Visible = false;
                ToolTip = 'Indicates the number of existing attributes.';
                ApplicationArea = All;
            }
            field("Item Count"; Rec."Item Count")
            {
                Caption = 'Item Count';
                ApplicationArea = All;
                Editable = false;

                trigger OnDrillDown()
                var
                    Item: Record Item;
                    PageManagement: Codeunit "Page Management";
                begin
                    Rec.SetItemView(Item);
                    Item."No." := ''; // Force PageManagement to open List
                    PageManagement.PageRun(Item);
                end;
            }
            field(CustomerCount; CustomerCount)
            {
                Caption = 'Customer Count';
                ApplicationArea = All;
                Editable = false;

                trigger OnDrillDown()
                var
                    Customer: Record Customer;
                    PageManagement: Codeunit "Page Management";
                begin
                    Rec.SetCustomerView(Customer);
                    Customer."No." := ''; // Force PageManagement to open List
                    PageManagement.PageRun(Customer);
                end;
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
    trigger OnAfterGetCurrRecord()
    begin
        SetCount();
    end;

    local procedure SetCount()
    var
        Customer: Record Customer;
    begin
        Rec.SetCustomerView(Customer);
        CustomerCount := Customer.Count();
    end;

    var
        CustomerCount: Integer;
}
