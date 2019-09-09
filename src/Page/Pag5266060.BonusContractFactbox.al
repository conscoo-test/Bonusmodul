page 5266060 "lbt Bonus Contract Factbox"
{
    PageType = CardPart;
    SourceTable = "lbt Bonus Contract";
    Caption = 'Bonus Contract Details', comment = 'DEU="Bonusvertrag Details"';

    layout
    {
        area(content)
        {

            field("lbt Last Reserve at"; "lbt Last Reserve at")
            {
                ToolTip = 'Displays the last reset performed.', comment = 'DEU="Zeigt die letzte durchgeführte Rückstellung an."';
                ApplicationArea = All;
            }
            field("lbt Last Billing at"; "lbt Last Billing at")
            {
                ToolTip = 'Displays when the last settlement was performed.', comment = 'DEU="Zeigt an, wann die letzte Abrechnung durchgeführt wurde."';
                ApplicationArea = All;
            }

            field("lbt No. of Customer"; "lbt No. of Customers")
            {
                ToolTip = 'Indicates the number of customers.', comment = 'DEU="Gibt die Anzahl der Debitoren an."';
                ApplicationArea = All;
            }
            field("lbt No. of Attribute"; "lbt No. of Attribute")
            {
                ToolTip = 'Indicates the number of existing attributes.', comment = 'DEU="Gibt die Anzahl der vorhandenen Attribute an."';
                ApplicationArea = All;
            }
            field("lbt No. of Dimensions"; "lbt No. of Dimensions")
            {
                ToolTip = 'Indicates the number of dimensions.', comment = 'DEU="Gibt die Anzahl der Dimensionen an."';
                ApplicationArea = All;
            }

            field("lbt Balance of Reserve"; "lbt Balance of Reserve")
            {
                ToolTip = 'Indicates the balance of provisions.', comment = 'DEU="Gibt den Saldo der Rückstellungen an."';
                ApplicationArea = All;
            }
            field("lbt Balance of Liquid Reserves"; "lbt Balance of Liquid Reserves")
            {
                ToolTip = 'Indicates the Balance of Liquid Reserves.', comment = 'DEU="Gibt den Saldo der Liquiditätsreserven an."';
                ApplicationArea = All;
            }
            field("lbt Balance of Bonus"; "lbt Balance of Bonus")
            {
                ToolTip = 'Indicates the balance of the bonus.', comment = 'DEU="Gibt den Saldo vom Bonus an."';
                ApplicationArea = All;
            }

        }



    }

}
