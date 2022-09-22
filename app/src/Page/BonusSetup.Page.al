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
            group("Number Series")
            {
                Caption = 'Number Series', comment = 'DEU="Nummernserie"';
                field("Bonus Nos."; Rec."Bonus Contract Nos.")
                {
                    ToolTip = 'Specifies the code for the number series that will be used to assign numbers to bonus contracts.', comment = 'DEU="Hier wählt man die Nummernserie für Bonusverträge aus."';
                    ApplicationArea = All;
                }
                field("Reserve Cr.Memo Nos."; Rec."Reserve Cr.Memo Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for the number series that will be used to assign numbers to Reserve Cr.Memo Nos.';
                }
                field("Billing Cr.Memo Nos."; Rec."Billing Cr.Memo Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for the number series that will be used to assign numbers to Billing Cr.Memo Nos.';
                }
            }

            group(Reserve)
            {
                Caption = 'Reserve', comment = 'DEU="Rückstellungen"';
                field("Reserve Mode"; Rec."Reserve Mode")
                {
                    ToolTip = 'Here you can choose the variant for accruals that is to be generated.', comment = 'DEU="Hier können Sie die Variante für Rückstellungen wählen, die erzeugt werden soll."';
                    ApplicationArea = All;
                    #region OnValidate
                    trigger OnValidate()

                    begin
                        SetEnabledOnAfterValidate();
                    end;
                    #endregion OnValidate
                }
                field("Gen.Jnl.Templ.BonusReserve"; Rec."Gen.Jnl.Templ.BonusReserve")
                {
                    Caption = 'Journal Template';
                    ToolTip = 'Here you can choose a financial book template for the Bonusreverse.', comment = 'DEU="Hier können Sie eine FIBU Buchblattvorlage für die Bonusrückstellung auswählen."';
                    ApplicationArea = All;
                    Enabled = ReserveMode_Journal;
                }
                field("Gen. Jnl. Bonus Reserve"; Rec."Gen. Jnl. Bonus Reserve")
                {
                    Caption = 'Journal Batch';
                    ToolTip = 'Here you can choose a book sheet template name. ', comment = 'DEU="Hier können Sie Buch.- Blattvorlagennamen auswählen."';
                    ApplicationArea = All;
                    Enabled = ReserveMode_Journal;
                }
                field("Bus.Post.Gr.f.Res.Cr.Memo"; Rec."Bus.Post.Gr.f.Res.Cr.Memo")
                {
                    Caption = 'Gen. Bus. Posting Group';
                    ToolTip = 'Here you can choose a business booking group for the reserve credit.', comment = 'DEU="Hier wählen Sie eine Geschäftsbuchungsgruppe für die Rückstell- Gutschrift aus."';
                    ApplicationArea = All;
                    Enabled = ReserveMode_CreditMemo;
                }
                field("Cust Gr. Reserve Cr. Memo"; Rec."Cust Gr. Reserve Cr. Memo")
                {
                    Caption = 'Customer Posting Group';
                    ToolTip = 'Here you can choose a customer posting group for the reserve credit.', comment = 'DEU="Hier wählen Sie eine Debitorbuchungsgruppe für die Rückstell- Gutschrift aus."';
                    ApplicationArea = All;
                    Enabled = ReserveMode_CreditMemo;
                }

                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = All;
                    Enabled = ReserveMode_Journal;
                    ToolTip = 'Specifies the reason code';
                }
            }

            group("Revers Reserve")
            {
                Caption = 'Revers Reserve', comment = 'DEU="Rückstellungsauflösungen"';
                field("Revers Reserve Mode"; Rec."Revers Reserve Mode")
                {
                    ToolTip = 'Here you specify whether reserves are to be reversed manually or automatically. If you have selected the automatic reversal mode, there is no need to post an extra book page.', comment = 'DEU="Hier geben Sie an, ob Rückstellungen manuell oder automatisch aufgelöst werden sollen. Ist für den Auflösungsmodus ‚automatisch‘ gewählt muss kein extra Buchblatt verbucht werden. "';
                    ApplicationArea = All;
                    Enabled = ReserveMode_Journal;
                }
                field(GenJnlBonusReversReserve; Rec."GenJnlBonusReversReserve")
                {
                    ToolTip = 'Here you select the book page for reversing the posted bonus reserves.', comment = 'DEU="Hier wählen Sie das Buchblatt zur Auflösung der verbuchten Bonusrückstellungen."';
                    ApplicationArea = All;
                    Enabled = ReserveMode_Journal;
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
            }
        }
    }
    var
        ReserveMode_Journal: Boolean;
        ReserveMode_CreditMemo: Boolean;

    #region SetEnabledOnAfterValidate
    local procedure SetEnabledOnAfterValidate()
    begin
        EnabledFields();
    end;
    #endregion SetEnabledOnAfterValidate

    #region SetEnabledOnOpenPage
    local procedure SetEnabledOnOpenPage()
    begin
        EnabledFields();
    end;
    #endregion SetEnabledOnOpenPage

    #region EnabledFields
    local procedure EnabledFields()
    begin
        ReserveMode_Journal := Rec."Reserve Mode" = Rec."Reserve Mode"::Journal;
        ReserveMode_CreditMemo := Rec."Reserve Mode" = Rec."Reserve Mode"::CreditMemo;
    end;
    #endregion EnabledFields

    #region OnOpenPage
    trigger OnOpenPage()
    begin
        SetEnabledOnOpenPage();
    end;
    #endregion OnOpenPage

}
