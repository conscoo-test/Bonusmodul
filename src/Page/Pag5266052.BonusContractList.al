page 5266052 "lbt Bonus Contract List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "lbt Bonus Contract";
    CardPageId = "lbt Bonus Contract Card";
    Caption = 'Bonus Contract', comment = 'DEU="Bonusverträge"';

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
            part("lbt Bonus Contract Factbox"; "lbt Bonus Contract Factbox")
            {
                ApplicationArea = all;
                Visible = true;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("lbt Create Reserves")
            {
                Caption = 'lbt Create Reserves', comment = 'DEU="Rückstellungen erzeugen"';
                ApplicationArea = all;
                Image = CashReceiptJournal;

                trigger OnAction();
                begin

                end;
            }

            action("lbt Exlode Reservation")
            {
                Caption = 'Exlode Reservation', comment = 'DEU="Rückstellungen auflösen"';
                ApplicationArea = All;
                Image = CashFlow;
                RunObject = page "lbt Explode Reservation";

                trigger OnAction()
                begin

                end;
            }


            action("lbt Bonus Run")
            {
                Caption = 'Bonus Run', comment = 'DEU="Bonuslauf"';
                ApplicationArea = All;
                Image = AccountingPeriods;

                trigger OnAction()
                begin

                end;
            }

            action("lbt Reservation")
            {
                Caption = 'Reservation', comment = 'DEU="Rückstellungen"';
                ApplicationArea = All;
                Image = Print;

                trigger OnAction()
                begin

                end;
            }

            action("lbt Bonus Cr. Memo")
            {
                Caption = 'Bonus Cr. Memo', comment = 'DEU="Bonusgutschriften"';
                ApplicationArea = All;
                Image = Print;

                trigger OnAction()
                begin

                end;
            }
        }
        area(Navigation)
        {
            action("lbt Customer")
            {
                Caption = 'Customer', comment = 'DEU="Debitoren"';
                ApplicationArea = All;
                Image = Customer;
                RunObject = page "lbt Bonus Customers";
                RunPageLink = "lbt Customer" = field ("lbt Contract");


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


                trigger OnAction()
                begin

                end;
            }

            action("Bonus Group")
            {
                Caption = 'Bonus Group', comment = 'DEU="Bonusgruppe"';
                ApplicationArea = All;
                Image = Group;
                RunObject = page "lbt Bonus Group";
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

            action("lbt Navigate")
            {
                Caption = 'Navigate', comment = 'DEU="Navigate"';
                ApplicationArea = All;
                Image = Navigate;

                trigger OnAction()
                begin
                    Navigate.Run();
                end;
            }

            action("lbt Bonus Setup")
            {
                Caption = 'Bonus Setup', comment = 'DEU="Bonus Einrichtung"';
                ApplicationArea = All;
                Image = Setup;
                RunObject = Page "lbt Bonus Setup";

                trigger OnAction()
                begin

                end;
            }


        }

    }

    var
        Navigate: Page Navigate;

}
