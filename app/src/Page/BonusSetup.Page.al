page 5266051 "lbtbn Bonus Setup"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    PageType = Card;
    SourceTable = "lbtbn Bonus Setup";
    Caption = 'LeBit Bonus Setup';

    layout
    {
        area(content)
        {
            group("Number Series")
            {
                Caption = 'Number Series';
                field("Bonus Nos."; Rec."Bonus Contract Nos.")
                {
                    ToolTip = 'Specifies the code for the number series that will be used to assign numbers to bonus contracts.';
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
                Caption = 'Reserve';
                field("Reserve Mode"; Rec."Reserve Mode")
                {
                    ToolTip = 'Here you can choose the variant for accruals that is to be generated.';
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
                    ToolTip = 'Here you can choose a financial book template for the Bonusreverse.';
                    ApplicationArea = All;
                    Enabled = ReserveMode_Journal;
                }
                field("Gen. Jnl. Bonus Reserve"; Rec."Gen. Jnl. Bonus Reserve")
                {
                    Caption = 'Journal Batch';
                    ToolTip = 'Here you can choose a book sheet template name. ';
                    ApplicationArea = All;
                    Enabled = ReserveMode_Journal;
                }
                field("Bus.Post.Gr.f.Res.Cr.Memo"; Rec."Bus.Post.Gr.f.Res.Cr.Memo")
                {
                    Caption = 'Gen. Bus. Posting Group';
                    ToolTip = 'Here you can choose a business booking group for the reserve credit.';
                    ApplicationArea = All;
                    Enabled = ReserveMode_CreditMemo;
                }
                field("Cust Gr. Reserve Cr. Memo"; Rec."Cust Gr. Reserve Cr. Memo")
                {
                    Caption = 'Customer Posting Group';
                    ToolTip = 'Here you can choose a customer posting group for the reserve credit.';
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
                Caption = 'Revers Reserve';
                field("Revers Reserve Mode"; Rec."Revers Reserve Mode")
                {
                    ToolTip = 'Here you specify whether reserves are to be reversed manually or automatically. If you have selected the automatic reversal mode, there is no need to post an extra book page.';
                    ApplicationArea = All;
                    Enabled = ReserveMode_Journal;
                }
                field(GenJnlBonusReversReserve; Rec."GenJnlBonusReversReserve")
                {
                    ToolTip = 'Here you select the book page for reversing the posted bonus reserves.';
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
                Caption = 'Bonus Contract';
                ToolTip = 'Here you can open the bonus contract list.';
                ApplicationArea = All;
                Image = ContractPayment;
                RunObject = page "lbtbn Bonus Contracts";
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
