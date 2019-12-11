codeunit 5266051 "lbt Bonus Install Logic"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        lbtBonusSetup: Record "lbt Bonus Setup";
    begin
        if not lbtBonusSetup.get() then begin
            lbtBonusSetup.Init();
            lbtBonusSetup.Insert()
        end;
    end;
}