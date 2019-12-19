page 5266059 "lbt Bonus Customers"
{

    PageType = List;
    SourceTable = "lbt Bonus Customers";
    Caption = 'Bonus Customers', comment = 'DEU="Bonus Debitoren"';
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {

                field(Customer; "Customer")
                {
                    ToolTip = 'This field is filled with the customer from the bonus contract.', comment = 'DEU="Dieses Feld wird mit dem Debitor aus dem Bonusvertrag gefüllt."';
                    ApplicationArea = All;
                }
                field("Ship-to Code"; "Ship-to Code")
                {
                    ToolTip = 'This field is filled with the delivery contact from the bonus contract.', comment = 'DEU="Dieses Feld wird mit dem Lieferkontakt aus dem Bonusvertrag gefüllt."';
                    ApplicationArea = All;
                }
                field("Customer Name"; "Customer Name")
                {
                    ToolTip = 'This field is filled with the customer name from the bonus contract.', comment = 'DEU="Dieses Feld wird mit dem Debitornamen aus dem Bonusvertrag gefüllt."';
                    ApplicationArea = All;
                }
                field("Ship-to Name"; "Ship-to Name")
                {
                    ToolTip = 'This field is filled with the delivery contact name from the bonus contract.', comment = 'DEU="Dieses Feld wird mit dem Lieferkontaktnamen aus dem Bonusvertrag gefüllt."';
                    ApplicationArea = All;
                }
            }
        }
    }

}
