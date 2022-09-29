page 5266062 "lbtbn Bonus Assisted Setup"
{
    PageType = NavigatePage;
    Caption = 'LeBit Bonus Setup';
    SourceTable = "lbtbn Bonus Setup";

    layout
    {
        area(Content)
        {
            group(StandardBanner)
            {
                Caption = '', Locked = true;
                Editable = false;
                Visible = TopBannerVisible and (CurrentStep < 3);
                field("Media Resources"; MediaResources."Media Reference")
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
            }

            group(FinishedBanner)
            {
                Caption = '', Locked = true;
                Editable = false;
                Visible = TopBannerVisible and (CurrentStep = 3);
                field("MediaResources Done"; MediaResourcesDone."Media Reference")
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
            }

            group(Step1)
            {
                Caption = '', Locked = true;
                Visible = CurrentStep = 1;
                group(Welcome)
                {
                    Caption = 'Welcome'; //TODO: 


                    group(Introduction)
                    {
                        Caption = '', Locked = true;
                        InstructionalText = 'english text', //TODO:
                            Comment = 'DEU="german text"';

                    }
                }

                group(LetsGo)
                {
                    Caption = 'Lets go';

                    group("Next")
                    {
                        Caption = '', Locked = true;
                        InstructionalText = 'Choose Next so you can set up.',
                            Comment = 'DEU="Wählen Sie "Weiter" damit Sie den Bonus einrichten können."';
                    }
                }
            }

            group(Step2)
            {
                Caption = '', Locked = true;
                Visible = CurrentStep = 2;
                group("Sales Receivables Setup")
                {
                    Caption = '', Locked = true;
                    InstructionalText = 'englisch', //TODO:
                        Comment = 'DEU="Bei "weiter" werden in der Debitoren & Verkauf Einrichtung die Felder "Lieferschein b VK-Rechnung" und "Rücksendung bei Gutschrift" gesetzt"';
                }
                // field("lbtbn No. Series Commission"; "lbtbn No. Series Commission")
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'english'; //TODO:
                // }
            }
            group(Step3)
            {
                Caption = '', Locked = true;
                Visible = CurrentStep = 3;
                // field("lbtbn Journal Template"; "lbtbn Journal Template")
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'english'; //TODO:
                // }
                // field("lbtbn Journal Batch"; "lbtbn Journal Batch")
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'english'; //TODO:
                // }
            }
        }


    }
    actions
    {
        area(Processing)
        {
            action(ActionBack)
            {
                ApplicationArea = All;
                ToolTip = 'One record back';
                Caption = 'Back';
                Enabled = BackEnabled;
                Visible = BackEnabled;
                Image = PreviousRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    TakeStep(-1);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = All;
                ToolTip = 'One record forward';
                Caption = 'Next';
                Enabled = NextEnabled;
                Image = NextRecord;
                InFooterBar = true;
                trigger OnAction()
                begin
                    TakeStep(1);
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = All;
                ToolTip = 'Complete the configuration';
                Caption = 'Finish';
                Enabled = FinishEnabled;
                Image = Approve;
                InFooterBar = true;
                trigger OnAction()
                begin
                    Finish();
                end;
            }
        }
    }
    trigger OnInit()
    begin
        LoadTopBanners();
    end;

    trigger OnOpenPage()
    begin
        CurrentStep := 1;
        SetControls();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        GuidedExperience: Codeunit "Guided Experience";
        BonusAssistedSetup: Codeunit "lbtbn Bonus Assisted Setup";
    begin
        if CloseAction = Action::OK then
            if not GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, BonusAssistedSetup.GetPageId()) then
                if not Confirm(FinishWhenNotCompleteQst, false) then
                    Error('');
    end;

    local procedure Finish()
    var
        GuidedExperience: Codeunit "Guided Experience";
        BonusAssistedSetup: Codeunit "lbtbn Bonus Assisted Setup";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, BonusAssistedSetup.GetPageId());
        CurrPage.Close();
    end;

    local procedure SetControls()
    begin
        BackEnabled := CurrentStep > 1;
        NextEnabled := CurrentStep < 3;
        FinishEnabled := CurrentStep = 3;
    end;

    local procedure TakeStep(Step: Integer)
    begin
        case CurrentStep of
            2:
                SetSalesReceivables();
        end;
        CurrentStep += Step;
        SetControls();
    end;

    local procedure SetSalesReceivables()
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.Get();
        if not (SalesReceivablesSetup."Shipment on Invoice" and SalesReceivablesSetup."Return Receipt on Credit Memo") then begin
            SalesReceivablesSetup."Shipment on Invoice" := true;
            SalesReceivablesSetup."Return Receipt on Credit Memo" := true;
            Rec.Modify();
        end;

    end;

    local procedure LoadTopBanners();
    begin
        if MediaRepository.Get('AssistedSetup-NoText-400px.png', Format(CurrentClientType())) then
            if MediaResources.Get(MediaRepository."Media Resources Ref") then
                TopBannerVisible := MediaResources."Media Reference".HasValue();
        if MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png', Format(CurrentClientType())) then
            if MediaResourcesDone.Get(MediaRepositoryDone."Media Resources Ref") then
                TopBannerVisible := TopBannerVisible or MediaResourcesDone."Media Reference".HasValue();
    end;

    var
        MediaRepository: Record "Media Repository";
        MediaResources: Record "Media Resources";
        MediaRepositoryDone: Record "Media Repository";
        MediaResourcesDone: Record "Media Resources";

        TopBannerVisible: Boolean;
        NextEnabled: Boolean;
        BackEnabled: Boolean;
        FinishEnabled: Boolean;
        CurrentStep: Integer;
        FinishWhenNotCompleteQst: Label 'Setup has not been completed.\\Are you sure you want to exit?',
            Comment = 'DEU="Die Einrichtung wurde nicht abgeschlossen.\\Möchten Sie den Assistenten wirklich beenden?"';
}
