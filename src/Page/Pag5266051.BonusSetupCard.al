page 5266051 "lbt Bonus Setup"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    PageType = Card;
    SourceTable = "lbt Bonus Setup";
    Caption = 'Bonus Setup', comment = 'DEU="Bonus Einrichtung"';

    layout
    {
        area(content)
        {
            group("lbt General")
            {
                Caption = 'General', comment = 'DEU="Allgmein"';
                field("lbt Primary Key"; "lbt Primary Key")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action("lbt Bonus Contract")
            {
                Caption = 'Bonus Contract', comment = 'DEU="Bonusverträge"';
                ApplicationArea = All;
                Image= ContractPayment;
                RunObject= page "lbt Bonus Contract List";
                trigger OnAction()
                begin

                end;
            }

        }

    }

}
