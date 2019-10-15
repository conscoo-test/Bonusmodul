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
                    ToolTip = 'This field is filled with the contract number of the bonus agreement.', comment = 'DEU="Dieses Feld wird mit der Vertragsnummer der Bonusvereinbarung gefüllt"';
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }

                field("lbt Bonus Group"; "lbt Bonus Group")
                {
                    ToolTip = 'This field is filled with the Bonus group.', comment = 'DEU="Dieses Feld wird mit der Bonusgruppe gefüllt"';
                    ApplicationArea = All;
                }
                field("lbt Billing Period"; "lbt Billing Period")
                {
                    ToolTip = 'This field specifies the interval in which billing takes place.', comment = 'DEU="Dieses Feld gibt den Abrechnungsintervall an."';
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
                field("lbt Contract Type"; "lbt Contract Type")
                {
                    ToolTip = 'Here you can choose whether the bonus item is a bonus or an advertising subsidy.', comment = 'DEU="Hier kann man wählen, ob es sich bei dem Bonusposten um einen Bonus oder einen Werbekostenzuschuss handelt. "';
                    ApplicationArea = All;
                }

                field("Process No."; "Process No.")
                {
                    ApplicationArea = All;

                }





                group(Billing)
                {
                    Caption = 'Billing', comment = 'DEU="Abrechnung"';
                    field("lbt Bonus Billing Type"; "lbt Bonus Billing Type")
                    {
                        ToolTip = 'Here you select the specification of settlement type.', comment = 'DEU="Hier wählt man die Abrechnungsart aus."';
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            TypeOnAfterValidate();
                        end;
                    }
                    field("lbt Bonus Billing Unit"; "lbt Bonus Billing Unit")
                    {
                        ToolTip = 'If it is specified in the contract that the settlement type is carried out using the "Amount per unit" option, an article unit must be specified for the calculation.', comment = 'DEU="Ist im Vertrag hinterlegt, dass die Bonusabrechnungsart anhand der Option „Betrag je Einheit“ durchgeführt wird, muss eine Artikeleinheit zur Berechnung hinterlegt werden."';
                        ApplicationArea = All;
                        Enabled = BonusBillingType_Enable;
                    }

                    field("lbt Bonus Scale Type"; "lbt Bonus Scale Type")
                    {
                        ToolTip = 'Indicates whether the bonus calculation is based on sales or turnover.', comment = 'DEU="Gibt an, ob die Bonusberechnung auf Grundlage des Absatzes oder des Umsatzes erfolgt"';
                        ApplicationArea = All;
                    }
                    field("lbt Last Billing at"; "lbt Last Billing at")
                    {
                        ToolTip = 'Is filled by the system after bonus settlement.', comment = 'DEU="Wird nach der Bonusabrechnung vom System gefüllt."';
                        ApplicationArea = All;
                    }
                    field("lbt Bonus Recipient"; "lbt Bonus Recipient")
                    {
                        ToolTip = 'Here you enter the customer who receives the bonus and is used to create the sales credit memo.', comment = 'DEU="Hier wird der Debitor eingetragen, der den Bonus empfängt und bei der Erstellung der Verkaufsgutschrift verwendet wird."';
                        ApplicationArea = All;
                    }
                    field("lbt Accounting Item Charge"; "lbt Accounting Item Charge")
                    {
                        ToolTip = 'Here you must select the appropriate surcharge or discount to be used when creating the settlement credit memo. This is required if the Credit memo reset mode is selected.', comment = 'DEU="Hier muss der entsprechende Zu-/Abschlag ausgewählt werden, der bei der Erstellung der Abrechnungsgutschrift verwendet werden soll. Dieser wird benötigt, wenn der Rückstellungsmodus ‚Gutschrift‘ gewählt ist."';
                        ApplicationArea = All;
                    }

                }

            }
            group(Reserve)

            {
                Caption = 'Reserve', comment = 'DEU="Rückstellung"';

                field("lbt Reserve Value"; "lbt Reserve Value")
                {
                    ToolTip = 'Specification of a reserve value.', comment = 'DEU="Angabe eines Rückstellungswertes."';
                    ApplicationArea = All;

                }
                field("lbt Reserve Type"; "lbt Reserve Type")
                {
                    ToolTip = 'There are three different ways to make provisions:Provision in %:The provision run makes provisions as a percentage of the receipts. For each invoice or credit memo line, a posting line is created in the reserve ledger sheet. Amount (MW): A fixed amount is reserved depending on the settlement period (the fixed amount is divided proportionally among the document lines included). Amount per unit: Reserves based on the quantity of article units from the contracts. A posting line is created in the provisions ledger sheet for each invoice or credit memo line.', comment = 'DEU="Es gibt drei verschiedene Arten um Rückstellungen zu bilden:Rückstellung in %:Der Rückstellungslauf bildet prozentual anhand derBelege Rückstellungen. Für jede Rechnungs-bzw. Gutschriftszeile wird eine Buchungszeile im Rückstellungsbuchblatt erzeugt.Betrag (MW):Ein Festbetrag wird je nach Abrechnungszeitraumzurückgestellt(festgelegter Betrag teilt sich dabei anteilig auf die einbezogenen Belegzeilen auf). Betrag je Einheit: Rückstellungen bezogen auf die Menge der Artikeleinheiten aus den Verträgen. Für jede Rechnungs-bzw. Gutschriftszeile wird eine Buchungszeile im Rückstellungsbuchblatt erzeugt"';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        TypeOnAfterValidate();
                    end;
                }
                field("lbt Reserve Unit"; "lbt Reserve Unit")
                {
                    ToolTip = 'If it is specified in the contract that the reserve run is carried out using the "Amount per unit" option, an article unit must be specified for the calculation.', comment = 'DEU="Ist im Vertrag hinterlegt, dass der Rückstellungslauf anhand der Option „Betrag je Einheit“ durchgeführt wird, muss eine Artikeleinheit zur Berechnung hinterlegt werden."';
                    ApplicationArea = All;
                    Enabled = BonusReserveType_Enable;
                }
                field("lbt last Reserve at"; "lbt Last Reserve at")
                {
                    ToolTip = 'Is filled by the system after the bonus reserve.', comment = 'DEU="Wird nach der Bonusrückstellung vom System gefüllt."';
                    ApplicationArea = All;
                }
                field("lbt Reserve Item Charge"; "lbt Reserve Item Charge")
                {
                    ToolTip = 'Here you must select the appropriate surcharge/discount to be used in the credit memo for posting the provisions and in the invoice for cancelling the provisions. This is required if the reserve mode credit memo is selected.', comment = 'DEU="Hier muss der entsprechende Zu-/Abschlag ausgewählt werden, der in der Gutschrift zum Verbuchen der Rückstellungen und der Rechnung zum Auflösen der Rückstellungen, verwendet werden soll. Dieser wird benötigt, wenn der Rückstellungsmodus ‚Gutschrift‘ gewählt ist"';
                    ApplicationArea = All;
                }

            }
            part(Bonusstaffeln; "lbt Bonus Contract Line")
            {
                ApplicationArea = All;
                SubPageLink = "lbt Contract" = field("lbt Contract");
            }
            group(Discounts)
            {
                Caption = 'Discounts', comment = 'DEU="Rabatte/Skonto"';
                field("lbt Discount %"; "lbt Discount %")
                {
                    ToolTip = 'Here you can enter a percentage value to calculate an additional discount.', comment = 'DEU="Hier kann ein prozentualer Wert zur Berechnung eines zusätzlichen Rabattes hinterlegt werden."';
                    ApplicationArea = All;
                    blankzero = true;
                }
                field("lbt Pmt. Discount %"; "lbt Pmt. Discount %")
                {
                    ToolTip = 'Here you can enter a percentage value for the calculation of an additional cash discount.', comment = 'DEU="Hier kann ein prozentualer Wert zur Berechnung eines zusätzlichen Skontos hinterlegt werden"';
                    ApplicationArea = All;
                    BlankZero = true;
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
                ToolTip = 'This function starts the reset run.', comment = 'DEU="Mit dieser Funktion wird der Rückstellungslauf gestartet."';
                ApplicationArea = all;
                Image = CashReceiptJournal;

                trigger OnAction();
                begin

                end;
            }

            action("lbt Exlode Reservation")
            {
                Caption = 'Exlode Reservation', comment = 'DEU="Rückstellungen auflösen"';
                ToolTip = 'You use this function to cancel a reserve.', comment = 'DEU="Mit dieser Funktion lösen Sie eine Rückstellung auf."';
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
                ToolTip = 'Opens the overview of the customers stored for the bonus contract. The overview is the same as the one in the bonus contracts under Number of customers.', comment = 'DEU="Öffnet die Übersicht der zum Bonusvertrag hinterlegten Kunden. Die Übersicht  ist  dabei dieselbe, wie  die, die  in den Bonusverträgen unter ‚Anzahl Kunden‘ befindet."';
                ApplicationArea = All;
                Image = Customer;
                RunObject = page "lbt Bonus Customers";
                RunPageLink = "lbt Contract" = field("lbt Contract");

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
                ToolTip = 'Opens the stored attribute filters for the respective contract. If attribute filters are set up for a bonus contract, only articles with the same attribute values are used for the provision and the bonus run.', comment = 'DEU=" Öffnet die hinterlegten Attributefilter zum jeweiligen Vertrag. Werden Attributefilter für ein Bonusvertrag eingerichtet, dann werden für die Rückstellung und für den Bonuslauf nur Artikel mit gleichen Attributewerten herangezogen."';
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
                    Navigate.SetProcessNo("Process No.");
                    // Navigate.FindProcess();
                    Navigate.Run();
                end;
            }
        }
    }

    var
        Navigate: Page Navigate;
        BonusBillingType_Enable: Boolean;
        BonusReserveType_Enable: Boolean;

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