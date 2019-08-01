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

                group("lbt Reserve")
                {
                    Caption = 'Reserve', comment = 'DEU="Rückstellungen"';
                    field("lbt Reserve Mode"; "lbt Reserve Mode")
                    {
                        ApplicationArea = All;
                        trigger OnValidate()

                        begin
                            SetEnabledOnAfterValidate();
                        end;
                    }
                    field("lbt Gen.Jnl.Templ.BonusReserve"; "lbt Gen.Jnl.Templ.BonusReserve")
                    {
                        ApplicationArea = All;
                        Enabled = GenJnlTemplBonusReserve_Enabled;
                    }
                    field("lbt Gen. Jnl. Bonus Reserve"; "lbt Gen. Jnl. Bonus Reserve")
                    {
                        ApplicationArea = All;
                        Enabled = GenJnlBonusReserve_Enabled;
                    }
                    field("lbt Bus.Post.Gr.f.Res.Cr.Memo";"lbt Bus.Post.Gr.f.Res.Cr.Memo")
                    {
                        ApplicationArea = All;
                        Enabled = BusPostGrResCrMemo_Enabled;
                    }
                    field("lbt Cust Gr. Reserve Cr. Memo";"lbt Cust Gr. Reserve Cr. Memo")
                    {
                        ApplicationArea = All;
                        Enabled = CustGrReserveCrMemo_Enabled;
                    }
                    



                }
                group("lbt Revers Reserve")
                {
                    Caption = 'Revers Reserve', comment = 'DEU="Rückstellungsauflösungen"';
                    field("lbt Revers Reserve Mode"; "lbt Revers Reserve Mode")
                    {
                        ApplicationArea = All;
                        Enabled = ReversReserve_Enabled;

                    }
                    field("lbt GenJnlBonusReversReserve";"lbt GenJnlBonusReversReserve")
                    {
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
                ApplicationArea = All;
                Image = ContractPayment;
                RunObject = page "lbt Bonus Contract List";
                Promoted=true;
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
