page 5266062 "lbt Bonus Assisted Setup"
{
    PageType = NavigatePage;
    Caption = 'LeBit Bonus Setup', Comment = 'DEU="LeBit Bonus Einrichtung"';
    SourceTable = "lbt Bonus Setup";

    layout
    {
        area(Content)
        {
            group(StandardBanner)
            {
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
                Visible = CurrentStep = 1;
                group(Welcome)
                {
                    Caption = 'Welcome', Comment = 'DEU="Willkommen bei der Einrichtung von LeBit Bonus"'; //TODO: 


                    group(Introduction)
                    {
                        Caption = '';
                        InstructionalText = 'english text', //TODO:
                            Comment = 'DEU="german text"';

                    }
                }

                group(LetsGo)
                {
                    Caption = 'Lets go', Comment = 'DEU="Los gehts"';

                    group("Next")
                    {
                        Caption = '';
                        InstructionalText = 'Choose Next so you can set up.',
                            Comment = 'DEU="Wählen Sie "Weiter" damit Sie den Bonus einrichten können."';
                    }
                }
            }

            group(Step2)
            {
                Visible = CurrentStep = 2;
                group("Sales Receivables Setup")
                {
                    Caption = '';
                    InstructionalText = 'englisch', //TODO:
                        Comment = 'DEU="Bei "weiter" werden in der Debitoren & Verkauf Einrichtung die Felder "Lieferschein b VK-Rechnung" und "Rücksendung bei Gutschrift" gesetzt"';
                }
                // field("lbt No. Series Commission"; "lbt No. Series Commission")
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'english', Comment = 'DEU="deutsch"'; //TODO:
                // }
            }
            group(Step3)
            {
                Visible = CurrentStep = 3;
                // field("lbt Journal Template"; "lbt Journal Template")
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'english', Comment = 'DEU="deutsch"'; //TODO:
                // }
                // field("lbt Journal Batch"; "lbt Journal Batch")
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'english', Comment = 'DEU="deutsch"'; //TODO:
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
                ToolTip = 'One record back', comment = 'DEU="Einen Datensatz zurück"';
                Caption = 'Back', Comment = 'DEU="Zurück"';
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
                ToolTip = 'One record forward', comment = 'DEU="Einen Datensatz vor"';
                Caption = 'Next', Comment = 'DEU="Weiter"';
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
                ToolTip = 'Complete the configuration', comment = 'DEU="Konfiguration abschließen"';
                Caption = 'Finish', Comment = 'DEU="Fertig stellen"';
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
        AssistedSetup: Codeunit "Assisted Setup";
        BonusAssistedSetup: Codeunit "lbt Bonus Assisted Setup";
    begin
        if CloseAction = Action::OK then
            if not AssistedSetup.IsComplete(BonusAssistedSetup.GetPageId()) then
                if not Confirm(FinishWhenNotCompleteQst, false) then
                    Error('');
    end;

    local procedure Finish()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        BonusAssistedSetup: Codeunit "lbt Bonus Assisted Setup";
    begin
        AssistedSetup.Complete(BonusAssistedSetup.GetPageId());
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
        if MediaRepository.GET('AssistedSetup-NoText-400px.png', Format(CurrentClientType())) then
            if MediaResources.GET(MediaRepository."Media Resources Ref") then
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
