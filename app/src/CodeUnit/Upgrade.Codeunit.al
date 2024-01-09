codeunit 5266064 "lbtbn Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        MoveItemUnitToBonusContract();
    end;

    local procedure MoveItemUnitToBonusContract()
    var
        BonusContract: Record "lbtbn Bonus Contract";
        BonusContractLine: Record "lbtbn Bonus Contract Line";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(MoveItemUnitToBonusContractLbl) then exit;

        BonusContract.SetRange("Bonus Scale Type", BonusContract."Bonus Scale Type"::"Sales Qty.");
        if BonusContract.FindSet() then
            repeat
                BonusContractLine.SetRange(Contract, BonusContract."No.");
                BonusContractLine.SetFilter("Item Unit of Measure", '<>%1', '');
                if BonusContractLine.FindFirst() then begin
                    BonusContract."Item Unit of Measure" := BonusContractLine."Item Unit of Measure";
                    BonusContract.Modify();
                end;
            until BonusContract.Next() = 0;

        UpgradeTag.SetUpgradeTag(MoveItemUnitToBonusContractLbl);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure OnGetPerCompanyUpgradeTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(MoveItemUnitToBonusContractLbl);
    end;


    var
        MoveItemUnitToBonusContractLbl: Label 'lbtbn-MoveItemUnitToBonusContract-20231228', Locked = true;
}