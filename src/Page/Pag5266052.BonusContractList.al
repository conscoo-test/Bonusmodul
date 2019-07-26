page 5266052 "lbt Bonus Contract List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "lbt Bonus Contract";
    CardPageId = "lbt Bonus Contract Card";
    Caption = 'Bonus Contract List', comment = 'DEU="Bonusverträge Übersicht"';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("lbt Contract"; "lbt Contract")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "lbt Bonus Contract Card";

                }
                field("lbt Valid from"; "lbt Valid from")
                {
                    ApplicationArea = All;
                }

                field("lbt Valid to"; "lbt Valid to")
                {
                    ApplicationArea = All;
                }

                field("lbt Billing Period"; "lbt Billing Period")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Navigation)
        {
            action("lbt Customer")
            {
                Caption = 'Customer', comment = 'DEU="Debitoren"';
                ApplicationArea = All;
                Image = Customer;
                RunObject = page "lbt Bonus Customers";
                RunPageLink = "lbt Customer" = field ("lbt Contract");
                Promoted = true;

                trigger OnAction();
                begin

                end;
            }

            action("lbt Dimension")
            {
                Caption = 'Dimension', comment = 'DEU="Dimensionen"';
                ApplicationArea = All;
                Image = Dimensions;
                RunObject = page "lbt Bonus Contract Dimension";
                RunPageLink = "lbt Contract" = field ("lbt Contract");
                Promoted = true;

                trigger OnAction()
                begin

                end;
            }
            action("lbt Bonus Contract Attribute")
            {
                Caption = 'Attribute Filter', comment = 'DEU="Attribute Filter"';
                ApplicationArea = All;
                Image = "Filter";
                RunObject = page "lbt BonusContrAttributeFilter";
                RunPageLink = "lbt Contract" = field ("lbt Contract");
                Promoted = true;

                trigger OnAction()
                begin

                end;
            }
            action("lbt Bonus Entry")
            {
                Caption = 'Bonus Entry', comment = 'DEU="Bonusposten"';
                ApplicationArea = All;
                Image = LedgerEntries;
                RunObject = page "lbt Bonus Entry";
                RunPageLink = "lbt Contract" = field ("lbt Contract");

                trigger OnAction()
                begin

                end;
            }
        }
    }
}
