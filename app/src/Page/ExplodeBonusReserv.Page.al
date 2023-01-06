page 5266063 "lbtbn Explode Bonus Reserv."
{

    PageType = Worksheet;
    SourceTable = "lbtbn Bonus Entry";
    SourceTableView = where("Entry Type" = const(Reserve), Reversed = const(false));
    Caption = 'Explode Bonus Reservation';
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Customer; Rec.Customer)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer';
                }
                field(Contract; Rec.Contract)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the contract';
                }
                field("Entry Date"; Rec."Entry Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry date';
                }
                field("From Document Type"; Rec."From Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the from document type';
                }
                field("From Document No."; Rec."From Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the from document no.';
                }
                field("From Document Line"; Rec."From Document Line")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the from document line';
                }
                field("Posted Amount"; Rec."Posted Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the posted amount';
                }
            }

            group(y)
            {
                Caption = '', Locked = true;
                field("Sum Amount"; SumAmount)
                {
                    Caption = 'Total';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Total';

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
                Caption = 'Explode Reservation';
                ApplicationArea = All;
                Image = CashFlow;
                ToolTip = 'explode reservation';

                trigger OnAction()
                var
                    BonusEntry: Record "lbtbn Bonus Entry";
                    ReverseReserve: Codeunit "lbtbn Reverse Reserve";
                begin
                    GetSumAmount();
                    CurrPage.SetSelectionFilter(BonusEntry);
                    if not Confirm(ConfirmExplodeTxt, true, BonusEntry.Count(), SumAmount) then
                        exit;

                    ReverseReserve.ReverseBonusEntries(BonusEntry, 0D, WorkDate());
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        BonusSetup: Record "lbtbn Bonus Setup";
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
        BonusEntry: Record "lbtbn Bonus Entry";
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
