page 5266063 "lbt Explode Bonus Reservation"
{

    PageType = Worksheet;
    SourceTable = "lbt Bonus Entry";
    SourceTableView = where("Entry Type" = const(Reserve));
    Caption = 'Explode Bonus Reservation', Comment = 'DEU="Bonusrückstellungen auflösen"';
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Customer; Customer)
                {
                    ApplicationArea = All;
                }
                field(Contract; Contract)
                {
                    ApplicationArea = All;
                }
                field("Entry Date"; "Entry Date")
                {
                    ApplicationArea = All;
                }
                field("From Document Type"; "From Document Type")
                {
                    ApplicationArea = All;
                }
                field("From Document No."; "From Document No.")
                {
                    ApplicationArea = All;
                }
                field("From Document Line"; "From Document Line")
                {
                    ApplicationArea = All;
                }
                field("Posted Amount"; "Posted Amount")
                {
                    ApplicationArea = All;
                }
            }

            group(y)
            {
                field("Sum Amount"; SumAmount)
                {
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    begin
                        GetSumAmount();
                    end;
                }
            }
        }


    }

    actions
    {
        area(Processing)
        {
            action("Explode Reservation")
            {
                Caption = 'Explode Reservation', Comment = 'DEU="Rückstellungen auflösen"';
                ApplicationArea = All;
                Image = CashFlow;

                trigger OnAction()
                var
                    BonusEntry: Record "lbt Bonus Entry";
                begin
                    GetSumAmount();
                    CurrPage.SetSelectionFilter(BonusEntry);
                    if not Confirm(ConfirmExplodeTxt, true, BonusEntry.Count(), SumAmount) then
                        exit;
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        BonusSetup: Record "lbt Bonus Setup";
        CustomerPostingGroup: Record "Customer Posting Group";
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
    begin
        BonusSetup.Get();
        BonusSetup.TestField("Cust Gr. Reserve Cr. Memo");
        BonusSetup.TestField("Bus.Post.Gr.f.Res.Cr.Memo");
        //TODO: BonusSetup.TestField("Billing Code");
        CustomerPostingGroup.Get(BonusSetup."Cust Gr. Reserve Cr. Memo");
        CustomerPostingGroup.TestField("Receivables Account");
        GenBusinessPostingGroup.Get(BonusSetup."Bus.Post.Gr.f.Res.Cr.Memo");
    end;

    local procedure GetSumAmount()
    var
        BonusEntry: Record "lbt Bonus Entry";
    begin
        CurrPage.SetSelectionFilter(BonusEntry);
        BonusEntry.CalcSums("Posted Amount");
        SumAmount := BonusEntry."Posted Amount";
    end;


    var
        ConfirmExplodeTxt: Label 'You have selected %1 rows with a total amount of %2. Do you want to clear the provisions?',
            Comment = 'DEU="Sie haben %1 Zeilen mit einer Betragssumme von %2 ausgewählt. Wollen Sie die Rückstellungen auflösen?"';
        SumAmount: Decimal;

}
