codeunit 5266053 "lbt Bonus Assisted Setup"
{
    var
        SetupLbl: Label 'Setup LeBit Bonus';
        NotificationIdTxt: Label '9c975145-0d59-400f-8eaa-dd087f421cb8';
        NotificationMsg: Label 'The setup for LeBit Bonus is incomplete';
        ActionMsg: Label 'To Wizard...';
        ExtensionGuidTxt: Label '1716d377-7e43-42d6-ae75-ad9977f24a69';
    // AppLbl: Label 'LeBit Bonus';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterAssistedSetup', '', false, false)]
    local procedure OnRegisterAssistedSetup();
    begin
        AddAssistedSetup();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Role Center Notification Mgt.", 'OnBeforeShowNotifications', '', true, true)]
    local procedure ShowAssistedSetupNotCompleteNotification()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        if GuidedExperience.AssistedSetupExistsAndIsNotComplete(ObjectType::Page, GetPageId()) then
            CreateNotification();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterManualSetup', '', false, false)]
    local procedure OnRegisterManualSetup(var Sender: Codeunit "Guided Experience");
    begin
        Sender.InsertManualSetup(
            SetupLbl, //Title
            SetupLbl, //ShortTitle
            SetupLbl, //Description
            3, //ExpectedDuration
            ObjectType::Page, //ObjectTypeToRun 
            Page::"lbt Bonus Setup", //ObjectIDToRun 
            Enum::"Manual Setup Category"::Uncategorized, //ManualSetupCategory 
            '' //Keywords 
            );
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
        GuidedExperience: Codeunit "Guided Experience";
    begin
        if GuidedExperience.AssistedSetupExistsAndIsNotComplete(ObjectType::Page, GetPageId()) then
            GuidedExperience.Run(Enum::"Guided Experience Type"::"Assisted Setup", ObjectType::Page, GetPageId());
    end;

    procedure AddAssistedSetup()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.InsertAssistedSetup(
            SetupLbl, //Title
            SetupLbl, //ShortTitle
            SetupLbl, //Description
            3, //ExpectedDuration
            ObjectType::Page, //ObjectTypeToRun 
            Page::"lbt Bonus Assisted Setup", //ObjectIDToRun 
            Enum::"Assisted Setup Group"::Uncategorized, //AssistedSetupGroup
            '', // VideoUrl 
            Enum::"Video Category"::Uncategorized,
            '' //HelpUrl
        );
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