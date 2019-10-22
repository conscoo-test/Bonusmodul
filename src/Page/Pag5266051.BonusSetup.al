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
            group("lbt General")
            {
                Caption = 'General', comment = 'DEU="Allgmein"';
                field("Bonus Nos."; "Bonus Nos.")
                {
                    ApplicationArea = All;
                }
                group("lbt Reserve")
                {
                    Caption = 'Reserve', comment = 'DEU="Rückstellungen"';
                    field("lbt Reserve Mode"; "lbt Reserve Mode")
                    {
                        ToolTip = 'Here you can choose the variant for accruals that is to be generated.', comment = 'DEU="Hier können Sie die Variante für Rückstellungen wählen, die erzeugt werden soll."';
                        ApplicationArea = All;
                        trigger OnValidate()

                        begin
                            SetEnabledOnAfterValidate();
                        end;
                    }
                    field("lbt Gen.Jnl.Templ.BonusReserve"; "lbt Gen.Jnl.Templ.BonusReserve")
                    {
                        ToolTip = 'Here you can choose a financial book template for the Bonusreverse.', comment = 'DEU="Hier können Sie eine FIBU Buchblattvorlage für die Bonusrückstellung auswählen."';
                        ApplicationArea = All;
                        Enabled = GenJnlTemplBonusReserve_Enabled;
                    }
                    field("lbt Gen. Jnl. Bonus Reserve"; "lbt Gen. Jnl. Bonus Reserve")
                    {
                        ToolTip = 'Here you can choose a book sheet template name. ', comment = 'DEU="Hier können Sie Buch.- Blattvorlagennamen auswählen."';
                        ApplicationArea = All;
                        Enabled = GenJnlBonusReserve_Enabled;
                    }
                    field("lbt Bus.Post.Gr.f.Res.Cr.Memo"; "lbt Bus.Post.Gr.f.Res.Cr.Memo")
                    {
                        ToolTip = 'Here you can choose a business booking group for the reserve credit.', comment = 'DEU="Hier wählen Sie eine Geschäftsbuchungsgruppe für die Rückstell- Gutschrift aus."';
                        ApplicationArea = All;
                        Enabled = BusPostGrResCrMemo_Enabled;
                    }
                    field("lbt Cust Gr. Reserve Cr. Memo"; "lbt Cust Gr. Reserve Cr. Memo")
                    {
                        ToolTip = 'Here you can choose a customer posting group for the reserve credit.', comment = 'DEU="Hier wählen Sie eine Debitorbuchungsgruppe für die Rückstell- Gutschrift aus."';
                        ApplicationArea = All;
                        Enabled = CustGrReserveCrMemo_Enabled;
                    }




                }
                group("lbt Revers Reserve")
                {
                    Caption = 'Revers Reserve', comment = 'DEU="Rückstellungsauflösungen"';
                    field("lbt Revers Reserve Mode"; "lbt Revers Reserve Mode")
                    {
                        ToolTip = 'Here you specify whether reserves are to be reversed manually or automatically. If you have selected the automatic reversal mode, there is no need to post an extra book page.', comment = 'DEU="Hier geben Sie an, ob Rückstellungen manuell oder automatisch aufgelöst werden sollen. Ist für den Auflösungsmodus ‚automatisch‘ gewählt muss kein extra Buchblatt verbucht werden. "';
                        ApplicationArea = All;
                        Enabled = ReversReserve_Enabled;

                    }
                    field("lbt GenJnlBonusReversReserve"; "lbt GenJnlBonusReversReserve")
                    {
                        ToolTip = 'Here you select the book page for reversing the posted bonus reserves.', comment = 'DEU="Hier wählen Sie das Buchblatt zur Auflösung der verbuchten Bonusrückstellungen."';
                        ApplicationArea = All;
                        Enabled = GenJnlBonusReversReserve_Enabled;
                    }
                }




            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action("lbt Bonus Contract")
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
        GenJnlBonusReserve_Enabled: Boolean;
        GenJnlTemplBonusReserve_Enabled: Boolean;
        BusPostGrResCrMemo_Enabled: Boolean;
        CustGrReserveCrMemo_Enabled: Boolean;
        ReversReserve_Enabled: Boolean;
        GenJnlBonusReversReserve_Enabled: Boolean;

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
        GenJnlBonusReserve_Enabled := "lbt Reserve Mode" = "lbt Reserve Mode"::Journal;
        GenJnlTemplBonusReserve_Enabled := "lbt Reserve Mode" = "lbt Reserve Mode"::Journal;
        CustGrReserveCrMemo_Enabled := "lbt Reserve Mode" = "lbt Reserve Mode"::CreditMemo;
        BusPostGrResCrMemo_Enabled := "lbt Reserve Mode" = "lbt Reserve Mode"::CreditMemo;
        ReversReserve_Enabled := "lbt Reserve Mode" = "lbt Reserve Mode"::Journal;
        GenJnlBonusReversReserve_Enabled := "lbt Reserve Mode" = "lbt Reserve Mode"::Journal;
    end;

    trigger OnOpenPage()
    begin
        SetEnabledOnOpenPage();
    end;

}
