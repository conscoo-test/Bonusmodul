page 5266053 "lbt Bonus Contract"
{
    Caption = 'Bonus Contract Card';
    PageType = Card;
    SourceTable = "lbt Bonus Contract";
    UsageCategory = none;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field(Contract; Rec."No.")
                {
                    ToolTip = 'This field is filled with the contract number of the bonus agreement.';
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description';
                }
                field("Bonus Group"; Rec."Bonus Group")
                {
                    ToolTip = 'This field is filled with the Bonus group.';
                    ApplicationArea = All;
                }
                field("Billing Period"; Rec."Billing Period")
                {
                    ToolTip = 'This field specifies the interval in which billing takes place.';
                    ApplicationArea = All;
                }
                field("Valid from"; Rec."Valid from")
                {
                    ToolTip = 'Specifies from when the bonus contract is valid.';
                    ApplicationArea = All;
                }
                field("Valid to"; Rec."Valid to")
                {
                    ToolTip = 'Specifies the expiry date of the bonus contract.';
                    ApplicationArea = All;
                }
                field("Process No."; Rec."Process No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the process no.';
                }
                group(Billing)
                {
                    Caption = 'Billing';
                    field("Bonus Billing Type"; Rec."Bonus Billing Type")
                    {
                        ToolTip = 'Here you select the specification of settlement type.';
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            TypeOnAfterValidate();
                        end;
                    }
                    field("Bonus Billing Unit"; Rec."Bonus Billing Unit")
                    {
                        ToolTip = 'If it is specified in the contract that the settlement type is carried out using the "Amount per unit" option, an article unit must be specified for the calculation.';
                        ApplicationArea = All;
                        Enabled = BonusBillingType_Enable;
                    }
                    field("Bonus Scale Type"; Rec."Bonus Scale Type")
                    {
                        ToolTip = 'Indicates whether the bonus calculation is based on sales or turnover.';
                        ApplicationArea = All;
                    }
                    field("Last Billing at"; Rec."Last Billing at")
                    {
                        ToolTip = 'Is filled by the system after bonus settlement.';
                        ApplicationArea = All;
                    }
                    field("Bonus Recipient"; Rec."Bonus Recipient")
                    {
                        ToolTip = 'Here you enter the customer who receives the bonus and is used to create the sales credit memo.';
                        ApplicationArea = All;
                    }
                    field("Accounting Item Charge"; Rec."Accounting Item Charge")
                    {
                        ToolTip = 'Here you must select the appropriate surcharge or discount to be used when creating the settlement credit memo. This is required if the Credit memo reset mode is selected.';
                        ApplicationArea = All;
                    }
                }
            }
            group(Reserve)

            {
                Caption = 'Reserve';
                field("Customer Reserve Cr.Memo"; Rec."Customer Reserve Cr.Memo")
                {
                    ToolTip = 'Customer Reserve Cr.Memo';
                    ApplicationArea = All;
                }
                field("Reserve Value"; Rec."Reserve Value")
                {
                    ToolTip = 'Specification of a reserve value.';
                    ApplicationArea = All;
                }
                field("Reserve Type"; Rec."Reserve Type")
                {
                    ToolTip = 'There are three different ways to make provisions:Provision in %:The provision run makes provisions as a percentage of the receipts. For each invoice or credit memo line, a posting line is created in the reserve ledger sheet. Amount (MW): A fixed amount is reserved depending on the settlement period (the fixed amount is divided proportionally among the document lines included). Amount per unit: Reserves based on the quantity of article units from the contracts. A posting line is created in the provisions ledger sheet for each invoice or credit memo line.',
                        Comment = 'DEU="Es gibt drei verschiedene Arten um Rückstellungen zu bilden:Rückstellung in %:Der Rückstellungslauf bildet prozentual anhand derBelege Rückstellungen. Für jede Rechnungs-bzw. Gutschriftszeile wird eine Buchungszeile im Rückstellungsbuchblatt erzeugt.Betrag (MW):Ein Festbetrag wird je nach Abrechnungszeitraumzurückgestellt(festgelegter Betrag teilt sich dabei anteilig auf die einbezogenen Belegzeilen auf). Betrag je Einheit: Rückstellungen bezogen auf die Menge der Artikeleinheiten aus den Verträgen. Für jede Rechnungs-bzw. Gutschriftszeile wird eine Buchungszeile im Rückstellungsbuchblatt erzeugt"';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        TypeOnAfterValidate();
                    end;
                }
                field("Reserve Unit"; Rec."Reserve Unit")
                {
                    ToolTip = 'If it is specified in the contract that the reserve run is carried out using the "Amount per unit" option, an article unit must be specified for the calculation.',
                        Comment = 'DEU="Ist im Vertrag hinterlegt, dass der Rückstellungslauf anhand der Option "Betrag je Einheit" durchgeführt wird, muss eine Artikeleinheit zur Berechnung hinterlegt werden."';
                    ApplicationArea = All;
                    Enabled = BonusReserveType_Enable;
                }
                field("last Reserve at"; Rec."Last Reserve at")
                {
                    ToolTip = 'Is filled by the system after the bonus reserve.';
                    ApplicationArea = All;
                }
                field("Reserve Item Charge"; Rec."Reserve Item Charge")
                {
                    ToolTip = 'Here you must select the appropriate surcharge/discount to be used in the credit memo for posting the provisions and in the invoice for cancelling the provisions. This is required if the reserve mode credit memo is selected.',
                        Comment = 'DEU="Hier muss der entsprechende Zu-/Abschlag ausgewählt werden, der in der Gutschrift zum Verbuchen der Rückstellungen und der Rechnung zum Auflösen der Rückstellungen, verwendet werden soll. Dieser wird benötigt, wenn der Rückstellungsmodus "Gutschrift" gewählt ist"';
                    ApplicationArea = All;
                    Enabled = ItemChargeEnabled;
                }
            }
            part(Bonusstaffeln; "lbt Bonus Contract Line")
            {
                ApplicationArea = All;
                SubPageLink = "Contract" = field("No.");
            }
            group(Discounts)
            {
                Caption = 'Discounts';
                field("Discount %"; Rec."Discount %")
                {
                    ToolTip = 'Here you can enter a percentage value to calculate an additional discount.',
                        Comment = 'DEU="Hier kann ein prozentualer Wert zur Berechnung eines zusätzlichen Rabattes hinterlegt werden."';
                    ApplicationArea = All;
                    blankzero = true;
                }
                field("Pmt. Discount %"; Rec."Pmt. Discount %")
                {
                    ToolTip = 'Here you can enter a percentage value for the calculation of an additional cash discount.',
                        Comment = 'DEU="Hier kann ein prozentualer Wert zur Berechnung eines zusätzlichen Skontos hinterlegt werden"';
                    ApplicationArea = All;
                    BlankZero = true;
                }
            }
        }

        area(Factboxes)
        {
            part("Bonus Contract Factbox"; "lbt Bonus Contract Factbox")
            {
                ApplicationArea = all;
                SubPageLink = "No." = field("No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Create Reserves")
            {
                Caption = 'Create Reserves';
                ToolTip = 'This function starts the reset run.';
                ApplicationArea = all;
                Image = CashReceiptJournal;

                trigger OnAction();
                var
                    BonusContract: Record "lbt Bonus Contract";
                    BonusReserves: Report "lbt Bonus Reserves";
                begin
                    BonusContract.SetRange("No.", Rec."No.");
                    BonusReserves.SetTableView(BonusContract);
                    BonusReserves.RunModal();
                end;
            }

            action("Exlode Reservation")
            {
                Caption = 'Exlode Reservation';
                ToolTip = 'You use this function to cancel a reserve.';
                ApplicationArea = All;
                Image = CashFlow;

                trigger OnAction()
                var
                    BonusSetup: Record "lbt Bonus Setup";
                    BonusEntry: Record "lbt Bonus Entry";
                    ExplodeReservation: Page "lbt Explode Reservation";
                begin
                    BonusSetup.Get();
                    if BonusSetup."Reserve Mode" = BonusSetup."Reserve Mode"::CreditMemo then begin
                        BonusEntry.SetRange(Contract, Rec."No.");
                        BonusEntry.SetRange("Entry Type", BonusEntry."Entry Type"::Reserve);
                        //TODO: BonusEntry.SetRange(Reversed, false);
                        BonusEntry.SetFilter("Posted Amount", '<>%1', 0);

                        if BonusEntry.IsEmpty() then
                            Error(NoPostedReservesErr);

                        ExplodeReservation.SetTableView(BonusEntry);
                        ExplodeReservation.Run();
                    end;
                    //TODO: "Reserve Mode"::Journal
                end;
            }

            action("Bonus Run")
            {
                Caption = 'Bonus Run';
                ToolTip = 'This triggers the report for settling bonus contracts. The screen opens prefiltered for the respective contract.',
                    Comment = 'DEU="Hiermit wird  der  Report  zum  Abrechnen  der Bonusverträge angestoßen. Die Maske öffnet sich dabei vorgefiltert auf den jeweiligen Vertrag."';
                ApplicationArea = All;
                Image = AccountingPeriods;

                trigger OnAction()
                var
                    BonusContract: Record "lbt Bonus Contract";
                    BonusRun: Report "lbt Bonus Run";
                begin
                    BonusContract.SetRange("No.", Rec."No.");
                    BonusRun.SetTableView(BonusContract);
                    BonusRun.RunModal();
                end;
            }

            action(Reservation)
            {
                Caption = 'Reservation';
                ToolTip = 'Prints a report, listing all the accrual items created for this contract.';
                ApplicationArea = All;
                Image = Print;

                trigger OnAction()
                begin
                    Message('not implemented'); //TODO:
                end;
            }

            action("Bonus Cr. Memo")
            {
                Caption = 'Bonus Cr. Memo';
                ToolTip = 'Prints a report, listing all rebate settlement items posted for this contract.';
                ApplicationArea = All;
                Image = Print;

                trigger OnAction()
                begin
                    Message('not implemented'); //TODO:
                end;
            }
        }
        area(Navigation)
        {
            action(Customer)
            {
                Caption = 'Customer';
                ToolTip = 'Opens the overview of the customers stored for the bonus contract. The overview is the same as the one in the bonus contracts under Number of customers.';
                ApplicationArea = All;
                Image = Customer;
                RunObject = page "lbt Bonus Customers";
                RunPageLink = "Contract" = field("No.");

                trigger OnAction();
                begin
                end;
            }

            action(Dimension)
            {
                Caption = 'Dimension';
                ToolTip = 'Here you can define default dimensions for the reserve for each contract. The dimensions created here are written to the posting lines during the provision run.';
                ApplicationArea = All;
                Image = Dimensions;
                RunObject = page "lbt Bonus Contract Dimension";
                RunPageLink = "Contract" = field("No.");

                trigger OnAction()
                begin
                end;
            }
            action("Bonus Contract Attribute")
            {
                Caption = 'Attribute Filter';
                ToolTip = 'Opens the stored attribute filters for the respective contract. If attribute filters are set up for a bonus contract, only articles with the same attribute values are used for the provision and the bonus run.';
                ApplicationArea = All;
                Image = "Filter";
                RunObject = page "lbt BonusContrAttributeFilter";
                RunPageLink = "Contract" = field("No.");

                trigger OnAction()
                begin
                end;
            }

            action(BonusGroup)
            {
                Caption = 'Bonus Group';
                ToolTip = 'Here you can group bonus contracts.';
                ApplicationArea = All;
                Image = Group;
                RunObject = page "lbt Bonus Group";
                trigger OnAction()
                begin
                end;
            }
            action("Bonus Entry")
            {
                Caption = 'Bonus Entry';
                ToolTip = 'Bonus items are written in the background each time reserves or rebate settlements are created.  These bonus items can be called up for each bonus contract using this button.';
                ApplicationArea = All;
                Image = LedgerEntries;
                RunObject = page "lbt Bonus Entry";
                RunPageLink = "Contract" = field("No.");

                trigger OnAction()
                begin
                end;
            }
            action(Navigate)
            {
                Caption = 'Navigate';
                ToolTip = 'This button displays all data records that are marked with the process number of the bonus contract. This includes posted and unposted documents (invoice, credit memo), as well as the various items (G/L items, customer items, bonus items, etc.).';
                ApplicationArea = All;
                Image = Navigate;

                trigger OnAction()
                begin
                    NavigatePage.SetProcessNo(Rec."Process No.");
                    // Navigate.FindProcess();
                    NavigatePage.Run();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        EnableFields();
    end;

    var
        NavigatePage: Page Navigate;
        BonusBillingType_Enable: Boolean;
        BonusReserveType_Enable: Boolean;
        ItemChargeEnabled: Boolean;
        NoPostedReservesErr: Label 'There are no posted reserves for Reversing.',
            Comment = 'DEU="Es gibt zu diesem Vertrag keine gebuchten Rückstellungen zur Auflösung."';

    local procedure TypeOnAfterValidate()
    begin
        EnableFields();
    end;

    local procedure EnableFields()
    var
        BonusSetup: Record "lbt Bonus Setup";
    begin
        BonusBillingType_Enable := Rec."Bonus Billing Type" = Rec."Bonus Billing Type"::"Amount per Unit";
        BonusReserveType_Enable := Rec."Reserve Type" = Rec."Reserve Type"::"Amount per Unit";
        BonusSetup.Get();
        ItemChargeEnabled := (BonusSetup."Reserve Mode" = BonusSetup."Reserve Mode"::CreditMemo);
    end;
}