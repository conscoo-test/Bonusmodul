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
                    ToolTip = 'This field contains the name of the bonus contract.', comment = 'DEU="In diesem Feld befindet sich der Name des bonusvertrags. "';
                    ApplicationArea = All;
                }
                field("Process No."; "Process No.")
                {
                    //TODO: Tooltip
                    ApplicationArea = All;
                }
                field("lbt Valid from"; "lbt Valid from")
                {
                    ToolTip = 'Specifies from when the bonus contract is valid.', comment = 'DEU="Gibt an, ab wann der Bonusvertrag gültig ist."';
                    ApplicationArea = All;
                }

                field("lbt Valid to"; "lbt Valid to")
                {
                    ToolTip = 'Specifies the expiry date of the bonus contract.', comment = 'DEU="Gibt an, wann der Bonusvertrag abläuft."';
                    ApplicationArea = All;
                }

                field("lbt Billing Period"; "lbt Billing Period")
                {
                    ToolTip = 'Specifies the interval in which billing takes place.', comment = 'DEU="Gibt an in welchem Intervall abgerechnet wird."';
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
                Caption = 'Create Reserves', comment = 'DEU="Rückstellungen erzeugen"';
                ToolTip = 'This function starts the reservation run.', comment = 'DEU="Mit dieser Funktion wird der Rückstellungslauf gestartet."';
                ApplicationArea = all;
                Image = CashReceiptJournal;

                trigger OnAction();
                begin
                    BonusContractRec.RESET();
                    BonusContractRec.SetCurrentKey("lbt Contract");
                    BonusContractRec.SETRANGE("lbt Contract", "lbt Contract");
                    CLEAR(BonusReserveRep);
                    BonusReserveRep.SETTABLEVIEW(BonusContractRec);
                    BonusReserveRep.RUNMODAL();
                end;
            }

            action("lbt Exlode Reservation")
            {
                Caption = 'Exlode Reservation', comment = 'DEU="Rückstellungen auflösen"';
                ToolTip = 'You use this function to cancel a reserve.', comment = 'DEU="Mit dieser Funktion lösen Sie eine Rückstellung auf."';
                ApplicationArea = All;
                Image = CashFlow;
                RunObject = page "lbt Explode Reservation";
            }


            action("lbt Bonus Run")
            {
                Caption = 'Bonus Run', comment = 'DEU="Bonuslauf"';
                ToolTip = 'This triggers the report for settling bonus contracts. The screen opens prefiltered for the respective contract.', comment = 'DEU="Hiermit wird  der  Report  zum  Abrechnen  der Bonusverträge angestoßen. Die Maske öffnet sich dabei vorgefiltert auf den jeweiligen Vertrag."';
                ApplicationArea = All;
                Image = AccountingPeriods;

                trigger OnAction()
                begin

                end;
            }

            action("lbt Reservation")
            {
                Caption = 'Reservation', comment = 'DEU="Rückstellungen"';
                ToolTip = 'Prints a report, listing all the accrual items created for this contract.', comment = 'DEU="Druckt einen Bericht an, in dem alle für diesen Vertrag erzeugten Rückstellungsposten aufgelistet werden."';
                ApplicationArea = All;
                Image = Print;

                trigger OnAction()
                begin

                end;
            }

            action("lbt Bonus Cr. Memo")
            {
                Caption = 'Bonus Cr. Memo', comment = 'DEU="Bonusgutschriften"';
                ToolTip = 'Prints a report, listing all rebate settlement items posted for this contract.', comment = 'DEU="Druckt einen Bericht, in dem alle für diesen Vertrag verbuchten Bonusabrechnungsposten aufgelistet werden."';
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
                ToolTip = 'Opens the overview of the customers stored for the bonus contract. The overview is the same as the one in the bonus contracts under Number of customers.', comment = 'DEU="Öffnet die Übersicht der zum Bonusvertrag hinterlegten Kunden. Die Übersicht  ist  dabei dieselbe, wie  die, die  in den Bonusverträgen unter "Anzahl Kunden" befindet."';
                ApplicationArea = All;
                Image = Customer;
                RunObject = page "lbt Bonus Customers";
                RunPageLink = "lbt Customer" = field("lbt Contract");


                trigger OnAction();
                begin

                end;
            }

            action("lbt Dimension")
            {
                Caption = 'Dimension', comment = 'DEU="Dimensionen"';
                ToolTip = 'Here you can define default dimensions for the reserve for each contract. The dimensions created here are written to the posting lines during the provision run.', comment = 'DEU="Hier können je Vertrag Vorgabedimensionen für die Rückstellung hinterlegt werden. Die hier angelegten Dimensionen werden beim Rückstellungslauf in die Buchungszeilen geschrieben."';
                ApplicationArea = All;
                Image = Dimensions;
                RunObject = page "lbt Bonus Contract Dimension";
                RunPageLink = "lbt Contract" = field("lbt Contract");


                trigger OnAction()
                begin

                end;
            }
            action("lbt Bonus Contract Attribute")
            {
                Caption = 'Attribute Filter', comment = 'DEU="Attribute Filter"';
                ToolTip = 'Opens the stored attribute filters for the respective contract. If attribute filters are set up for a bonus contract, only articles with the same attribute values are used for the provision and the bonus run.', comment = 'DEU="Öffnet die hinterlegten Attributefilter zum jeweiligen Vertrag. Werden Attributefilter für ein Bonusvertrag eingerichtet, dann werden für die Rückstellung und für den Bonuslauf nur Artikel mit gleichen Attributewerten herangezogen."';
                ApplicationArea = All;
                Image = "Filter";
                RunObject = page "lbt BonusContrAttributeFilter";
                RunPageLink = "lbt Contract" = field("lbt Contract");


                trigger OnAction()
                begin

                end;
            }

            action("Bonus Group")
            {
                Caption = 'Bonus Group', comment = 'DEU="Bonusgruppe"';
                ToolTip = 'Here you can group bonus contracts.', comment = 'DEU="Hier können Sie Bonusverträge gruppieren."';
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
                ToolTip = 'Bonus items are written in the background each time reserves or rebate settlements are created.  These bonus items can be called up for each bonus contract using this button.', comment = 'DEU="Bei  jeder  Erzeugung  von  Rückstellungen oder  Bonusabrechnungen  werden  im  Hintergrund Bonusposten  geschrieben.  Diese  Bonusposten  können über  diese  Schaltfläche  je  Bonusvertrag aufgerufen werden."';
                ApplicationArea = All;
                Image = LedgerEntries;
                RunObject = page "lbt Bonus Entry";
                RunPageLink = "lbt Contract" = field("lbt Contract");

                trigger OnAction()
                begin

                end;
            }

            action("lbt Navigate")
            {
                Caption = 'Navigate', comment = 'DEU="Navigate"';
                ToolTip = 'This button displays all data records that are marked with the process number of the bonus contract. This includes posted and unposted documents (invoice, credit memo), as well as the various items (G/L items, customer items, bonus items, etc.).', comment = 'DEU="Über diesen Button werden alle Datensätze angezeigt, die mit der Vorgangsnummer des Bonusvertrages gekennzeichnet sind. Dazu gehören gebuchte und ungebuchte Belege (Rechnung, Gutschrift), sowie die verschiedenen Posten (Sachposten, Debitorenposten, Bonusposten)."';
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
                ToolTip = 'This takes you to the Bonus Setup screen where you can set up reserves and reverse reserves.', comment = 'DEU="Hier gelangen Sie in die Bonus Einrichtung, um Rückstellungen und Rückstellungsauflösungen einzustellen."';
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
        BonusContractRec: Record "lbt Bonus Contract";
        BonusReserveRep: Report "lbt Bonus Reserves";
        Navigate: Page Navigate;



}
