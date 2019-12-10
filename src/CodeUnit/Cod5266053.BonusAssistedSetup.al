codeunit 5266053 "lbt Bonus Assisted Setup"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assisted Setup", 'OnRegister', '', true, true)]
    // [EventSubscriber(ObjectType::Table, Database::"Aggregated Assisted Setup", 'OnRegisterAssistedSetup', '', true, true)]
    local procedure AggregatedSetup_OnRegisterAssistedSetup()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        AssistedSetupGroup: Enum "Assisted Setup Group";
    // CurrentGlobalLanguage: Integer;
    begin
        // CurrentGlobalLanguage := GlobalLanguage();
        AssistedSetup.Add(GetAppId(), GetPageId(), SetupLbl, AssistedSetupGroup::Extensions);
        // GlobalLanguage(1033);
        // AssistedSetup.AddTranslation(ExtensionGuidTxt, Page::"LBT Wizard", 1033, SetupLbl);
        // GlobalLanguage(CurrentGlobalLanguage);

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Role Center Notification Mgt.", 'OnBeforeShowNotifications', '', true, true)]
    local procedure ShowAssistedSetupNotCompleteNotification()
    var
        AssistedSetup: Codeunit "Assisted Setup";
    begin
        if not AssistedSetup.IsComplete(GetAppId(), GetPageId()) then
            CreateNotification();
    end;

    local procedure CreateNotification()
    var
        Note: Notification;
    begin
        Note.Id := GetNotificationId();
        Note.Message(NotificationMsg);
        Note.Scope := NotificationScope::LocalScope;
        Note.AddAction(ActionMsg, Codeunit::"LBT Bonus Assisted Setup", 'HandleNotification');
        Note.Send();
    end;

    procedure HandleNotification(Note: Notification)
    var
        AssistedSetup: Codeunit "Assisted Setup";
    begin
        if AssistedSetup.ExistsAndIsNotComplete(GetAppId(), GetPageId()) then
            AssistedSetup.Run(GetAppId(), GetPageId());
    end;

    local procedure GetNotificationId(): Guid
    var
        NotificationId: Guid;
    begin
        Evaluate(NotificationId, NotificationIdTxt);
        exit(NotificationId);
    end;

    procedure GetAppId(): Text
    begin
        exit(ExtensionGuidTxt);
    end;

    procedure GetPageId(): Integer;
    begin
        exit(Page::"lbt Bonus Assisted Setup")
    end;

    var
        SetupLbl: Label 'Setup LIS365 Bonus', Comment = 'DEU="LIS365 Bonus einrichten"';
        NotificationIdTxt: Label '9c975145-0d59-400f-8eaa-dd087f421cb8';
        NotificationMsg: Label 'The setup for LIS365 Bonus is incomplete', Comment = 'DEU="Die Einrichtung für LIS365 Bonus ist unvollständig."';
        ActionMsg: Label 'To Wizard...', Comment = 'DEU="Zum Wizard..."';
        ExtensionGuidTxt: Label '1716d377-7e43-42d6-ae75-ad9977f24a69';
}