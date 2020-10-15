codeunit 5266053 "lbt Bonus Assisted Setup"
{
    var
        SetupLbl: Label 'Setup LeBit Bonus', Comment = 'DEU="LeBit Bonus einrichten"';
        NotificationIdTxt: Label '9c975145-0d59-400f-8eaa-dd087f421cb8';
        NotificationMsg: Label 'The setup for LeBit Bonus is incomplete', Comment = 'DEU="Die Einrichtung für LeBit Bonus ist unvollständig."';
        ActionMsg: Label 'To Wizard...', Comment = 'DEU="Zum Wizard..."';
        ExtensionGuidTxt: Label '1716d377-7e43-42d6-ae75-ad9977f24a69';
        AppLbl: Label 'LeBit Bonus', Comment = 'DEU="LeBit Bonus"';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assisted Setup", 'OnRegister', '', true, true)]
    local procedure AggregatedSetup_OnRegisterAssistedSetup()
    begin
        AddAssistedSetup();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Role Center Notification Mgt.", 'OnBeforeShowNotifications', '', true, true)]
    local procedure ShowAssistedSetupNotCompleteNotification()
    var
        AssistedSetup: Codeunit "Assisted Setup";
    begin
        if not AssistedSetup.IsComplete(GetPageId()) then
            CreateNotification();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Manual Setup", 'OnRegisterManualSetup', '', true, true)]
    local procedure RegisterManualSetup(sender: Codeunit "Manual Setup")
    var
        ManualSetupCategory: Enum "Manual Setup Category";
    begin
        sender.Insert(AppLbl, SetupLbl, '', Page::"lbt Bonus Setup", GetAppId(), ManualSetupCategory::Uncategorized);
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
        if AssistedSetup.ExistsAndIsNotComplete(GetPageId()) then
            AssistedSetup.Run(GetPageId());
    end;

    procedure AddAssistedSetup()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        AssistedSetupGroup: Enum "Assisted Setup Group";
    begin
        if not AssistedSetup.Exists(GetPageId()) then
            AssistedSetup.Add(GetAppId(), GetPageId(), SetupLbl, AssistedSetupGroup::Extensions);
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


}