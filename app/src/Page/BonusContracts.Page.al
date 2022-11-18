page 5266052 "lbtbn Bonus Contracts"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "lbtbn Bonus Contract";
    CardPageId = "lbtbn Bonus Contract";
    Caption = 'Bonus Contracts';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Contract; Rec."No.")
                {
                    ToolTip = 'This field contains the name of the bonus contract.';
                    ApplicationArea = All;
                }
                field("Process No."; Rec."Process No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the process no.';
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
                field("Billing Period"; Rec."Billing Period")
                {
                    ToolTip = 'Specifies the interval in which billing takes place.';
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {
            part("Bonus Contract Factbox"; "lbtbn Bonus Contract Factbox")
            {
                ApplicationArea = all;
                SubPageLink = "No." = field("No.");
                Visible = true;
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
                ToolTip = 'This function starts the reservation run.';
                ApplicationArea = all;
                Image = CashReceiptJournal;

                trigger OnAction();
                begin
                    BonusContractRec.Reset();
                    BonusContractRec.SetCurrentKey("No.");
                    BonusContractRec.SetRange("No.", Rec."No.");
                    Clear(BonusReserves);
                    BonusReserves.SetTableView(BonusContractRec);
                    BonusReserves.RunModal();
                end;
            }

            action("Exlode Reservation")
            {
                Caption = 'Exlode Reservation';
                ToolTip = 'You use this function to cancel a reserve.';
                ApplicationArea = All;
                Image = CashFlow;
                RunObject = Page "lbtbn Explode Reservation";
            }

            action("Bonus Run")
            {
                Caption = 'Bonus Run';
                ToolTip = 'This triggers the report for settling bonus contracts. The screen opens prefiltered for the respective contract.';
                ApplicationArea = All;
                Image = AccountingPeriods;

                trigger OnAction()
                begin
                    Message('not implemented'); //TODO:
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
                RunObject = Page "lbtbn Bonus Customers";
                RunPageLink = "Customer No." = field("No.");

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
                RunObject = Page "lbtbn Bonus Contract Dimension";
                RunPageLink = "Contract" = field("No.");

                trigger OnAction()
                begin
                end;
            }

            action("Bonus Items")
            {
                Caption = 'Bonus Items';
                ApplicationArea = All;
                Image = Item;
                RunObject = page "lbtbn Bonus Items";
                RunPageLink = "Contract No." = field("No.");
            }

            action("Bonus Entry")
            {
                Caption = 'Bonus Entry';
                ToolTip = 'Bonus items are written in the background each time reserves or rebate settlements are created.  These bonus items can be called up for each bonus contract using this button.';
                ApplicationArea = All;
                Image = LedgerEntries;
                RunObject = Page "lbtbn Bonus Entry";
                RunPageLink = "Contract" = field("No.");

                trigger OnAction()
                begin
                end;
            }

            action(Navigate)
            {
                Caption = 'Search in Entries';
                ToolTip = 'This button displays all data records that are marked with the process number of the bonus contract. This includes posted and unposted documents (invoice, credit memo), as well as the various items (G/L items, customer items, bonus items, etc.).';
                ApplicationArea = All;
                Image = Navigate;

                trigger OnAction()
                begin
                    Rec.Navigate();
                end;
            }

            action("Bonus Setup")
            {
                Caption = 'Bonus Setup';
                ToolTip = 'This takes you to the Bonus Setup screen where you can set up reserves and reverse reserves.';
                ApplicationArea = All;
                Image = Setup;
                RunObject = Page "lbtbn Bonus Setup";
            }
        }
    }

    var
        BonusContractRec: Record "lbtbn Bonus Contract";
        BonusReserves: Report "lbtbn Bonus Reserves";


}
