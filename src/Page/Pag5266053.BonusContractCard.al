page 5266053 "lbt Bonus Contract Card"
{
    Caption = 'Bonus Contract Card', comment = 'DEU="Bonusvertragskarte"';
    PageType = Card;
    SourceTable = "lbt Bonus Contract";
    UsageCategory = none;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General', comment = 'DEU="Allgemein"';

                field("lbt Contract"; "lbt Contract")
                {
                    ApplicationArea = All;
                }
                field("lbt Billing Period"; "lbt Billing Period")
                {
                    ApplicationArea = All;
                }
                field("lbt Valid from"; "lbt Valid from")
                {
                    ApplicationArea = All;
                }
                field("lbt Valid to"; "lbt Valid to")
                {
                    ApplicationArea = All;
                }
            }
            group(Reserve)

            {
                Caption = 'Reserve', comment = 'DEU="Rückstellung"';

                field("lbt Reserve Value"; "lbt Reserve Value")
                {
                    ApplicationArea = All;
                }
                field("lbt Reserve Type"; "lbt Reserve Type")
                {
                    ApplicationArea = All;
                }



            }
            part(Bonusstaffeln; "lbt Bonus Contract Line")
            {
                ApplicationArea = All;
                SubPageLink = "lbt Contract" = field ("lbt Contract");

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
                RunPageLink = "lbt Contract" = field ("lbt Contract");
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