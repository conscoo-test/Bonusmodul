codeunit 5266051 "lbt Bonus Install Logic"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        BonusSetup: Record "lbt Bonus Setup";
        BonusAssistedSetup: Codeunit "lbt Bonus Assisted Setup";
    begin
        if not BonusSetup.get() then begin
            BonusSetup.Init();
            BonusSetup.Insert()
        end;
        BonusAssistedSetup.AddAssistedSetup();
    end;
}