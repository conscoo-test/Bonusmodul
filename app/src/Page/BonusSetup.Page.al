page 5266051 "lbt Bonus Setup"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    PageType = Card;
    SourceTable = "lbt Bonus Setup";
    Caption = 'Bonus Setup', comment = 'DEU="Bonus Einrichtung"';

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General', comment = 'DEU="Allgmein"';
                group("Number Series")
                {
                    Caption = 'Number Series', comment = 'DEU="Nummernserie"';
                    field("Bonus Nos."; "Bonus Nos.")
                    {
                        ToolTip = 'Here you select the number series for bonus contracts.', comment = 'DEU="Hier wählt man die Nummernserie für Bonusverträge aus."';
                        ApplicationArea = All;
                    }
                }
                group(Reserve)
                {
                    Caption = 'Reserve', comment = 'DEU="Rückstellungen"';
                    field("Reserve Mode"; "Reserve Mode")
                    {
                        ToolTip = 'Here you can choose the variant for accruals that is to be generated.', comment = 'DEU="Hier können Sie die Variante für Rückstellungen wählen, die erzeugt werden soll."';
                        ApplicationArea = All;
                        trigger OnValidate()

                        begin
                            SetEnabledOnAfterValidate();
                        end;
                    }
                    field("Gen.Jnl.Templ.BonusReserve"; "Gen.Jnl.Templ.BonusReserve")
                    {
                        ToolTip = 'Here you can choose a financial book template for the Bonusreverse.', comment = 'DEU="Hier können Sie eine FIBU Buchblattvorlage für die Bonusrückstellung auswählen."';
                        ApplicationArea = All;
                        Enabled = ReserveMode_Journal;
                    }
                    field("Gen. Jnl. Bonus Reserve"; "Gen. Jnl. Bonus Reserve")
                    {
                        ToolTip = 'Here you can choose a book sheet template name. ', comment = 'DEU="Hier können Sie Buch.- Blattvorlagennamen auswählen."';
                        ApplicationArea = All;
                        Enabled = ReserveMode_Journal;
                    }
                    field("Bus.Post.Gr.f.Res.Cr.Memo"; "Bus.Post.Gr.f.Res.Cr.Memo")
                    {
                        ToolTip = 'Here you can choose a business booking group for the reserve credit.', comment = 'DEU="Hier wählen Sie eine Geschäftsbuchungsgruppe für die Rückstell- Gutschrift aus."';
                        ApplicationArea = All;
                        Enabled = ReserveMode_CreditMemo;
                    }
                    field("Cust Gr. Reserve Cr. Memo"; "Cust Gr. Reserve Cr. Memo")
                    {
                        ToolTip = 'Here you can choose a customer posting group for the reserve credit.', comment = 'DEU="Hier wählen Sie eine Debitorbuchungsgruppe für die Rückstell- Gutschrift aus."';
                        ApplicationArea = All;
                        Enabled = ReserveMode_CreditMemo;
                    }
                    field("Customer Reserve Cr.Memo"; "Customer Reserve Cr.Memo")
                    {
                        //TODO: Tooltip
                        ApplicationArea = All;
                        Enabled = ReserveMode_Journal;
                    }
                    field("Reason Code"; "Reason Code")
                    {
                        //TODO: Tooltip
                        ApplicationArea = All;
                        Enabled = ReserveMode_Journal;

                    }
                    field("Reserve Cr.Memo Nos."; "Reserve Cr.Memo Nos.")
                    {
                        //TODO: Tooltip
                        ApplicationArea = All;
                        Enabled = ReserveMode_Journal;
                    }
                }
                group("Revers Reserve")
                {
                    Caption = 'Revers Reserve', comment = 'DEU="Rückstellungsauflösungen"';
                    field("Revers Reserve Mode"; "Revers Reserve Mode")
                    {
                        ToolTip = 'Here you specify whether reserves are to be reversed manually or automatically. If you have selected the automatic reversal mode, there is no need to post an extra book page.', comment = 'DEU="Hier geben Sie an, ob Rückstellungen manuell oder automatisch aufgelöst werden sollen. Ist für den Auflösungsmodus ‚automatisch‘ gewählt muss kein extra Buchblatt verbucht werden. "';
                        ApplicationArea = All;
                        Enabled = ReserveMode_Journal;

                    }
                    field(GenJnlBonusReversReserve; "GenJnlBonusReversReserve")
                    {
                        ToolTip = 'Here you select the book page for reversing the posted bonus reserves.', comment = 'DEU="Hier wählen Sie das Buchblatt zur Auflösung der verbuchten Bonusrückstellungen."';
                        ApplicationArea = All;
                        Enabled = ReserveMode_Journal;
                    }
                }




            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action("Bonus Contract")
            {
                Caption = 'Bonus Contract', comment = 'DEU="Bonusverträge"';
                ToolTip = 'Here you can open the bonus contract list.', comment = 'DEU="Hier öffnen Sie die Liste der Bonusverträge."';
                ApplicationArea = All;
                Image = ContractPayment;
                RunObject = page "lbt Bonus Contract List";
                Promoted = true;
                trigger OnAction()
                begin

                end;
            }

        }

    }
    var
        ReserveMode_Journal: Boolean;
        ReserveMode_CreditMemo: Boolean;

    local procedure SetEnabledOnAfterValidate()
    begin
        EnabledFields();
    end;

    local procedure SetEnabledOnOpenPage()
    begin
        EnabledFields();
    end;

    local procedure EnabledFields()
    begin
        ReserveMode_Journal := "Reserve Mode" = "Reserve Mode"::Journal;
        ReserveMode_CreditMemo := "Reserve Mode" = "Reserve Mode"::CreditMemo;
    end;

    trigger OnOpenPage()
    begin
        SetEnabledOnOpenPage();
    end;

}
