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

                field("lbt Bonus Group"; "lbt Bonus Group")
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
                field("lbt Contract Type"; "lbt Contract Type")
                {
                    ApplicationArea = All;
                }







                group(Billing)
                {
                    Caption = 'Billing', comment = 'DEU="Abrechnung"';
                    field("lbt Bonus Billing Type"; "lbt Bonus Billing Type")
                    {
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            TypeOnAfterValidate();
                        end;
                    }
                    field("lbt Bonus Billing Unit"; "lbt Bonus Billing Unit")
                    {
                        ApplicationArea = All;
                        Enabled = BonusBillingType_Enable;
                    }

                    field("lbt Bonus Scale Type"; "lbt Bonus Scale Type")
                    {
                        ApplicationArea = All;
                    }
                    field("lbt Last Billing at"; "lbt Last Billing at")
                    {
                        ApplicationArea = All;
                    }
                    field("lbt Bonus Recipient"; "lbt Bonus Recipient")
                    {
                        ApplicationArea = All;
                    }
                    field("lbt Accounting Item Charge";"lbt Accounting Item Charge")
                    {
                        ApplicationArea = All;
                    }
                    
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

                    trigger OnValidate()
                    begin
                        TypeOnAfterValidate();
                    end;
                }
                field("lbt Reserve Unit"; "lbt Reserve Unit")
                {
                    ApplicationArea = All;
                    Enabled=BonusReserveType_Enable;
                }
                field("lbt last Reserve at"; "lbt Last Reserve at")
                {
                    ApplicationArea = All;
                }
                field("lbt Reserve Item Charge";"lbt Reserve Item Charge")
                {
                    ApplicationArea = All;
                }
                
            }
            part(Bonusstaffeln; "lbt Bonus Contract Line")
            {
                ApplicationArea = All;
                SubPageLink = "lbt Contract" = field ("lbt Contract");
            }
             group(Discounts)
             {
                 
                 field("lbt Discount %";"lbt Discount %")
                 {
                     ApplicationArea = All;
                     blankzero = true;
                 }
                 field("lbt Pmt. Discount %";"lbt Pmt. Discount %")
                 {
                     ApplicationArea = All;
                     BlankZero= true;
                 }
             }
        }


        area(Factboxes)
        {
            part("lbt Bonus Contract Factbox"; "lbt Bonus Contract Factbox")
            {
                ApplicationArea = all;
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
                RunPageLink = "lbt Contract" = field ("lbt Contract");

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
        }
    }

    var
        Navigate: Page Navigate;
        BonusBillingType_Enable: Boolean;
        BonusReserveType_Enable:Boolean;

    local procedure TypeOnAfterValidate()
    begin
        EnableFields();
    end;

    local procedure EnableFields()
    begin
        BonusBillingType_Enable := "lbt Bonus Billing Type" = "lbt Bonus Billing Type"::"Amount per Unit";
        BonusReserveType_Enable := "lbt Reserve Type" = "lbt Reserve Type"::"Amount per Unit";

    end;


}