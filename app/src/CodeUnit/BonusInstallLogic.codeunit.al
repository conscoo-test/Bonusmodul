codeunit 5266051 "lbtbn Bonus Install Logic"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        BonusSetup: Record "lbtbn Bonus Setup";
        BonusAssistedSetup: Codeunit "lbtbn Bonus Assisted Setup";
    begin
        if not BonusSetup.Get() then begin
            BonusSetup.Init();
            BonusSetup.Insert()
        end;
        BonusAssistedSetup.AddAssistedSetup();
    end;
}