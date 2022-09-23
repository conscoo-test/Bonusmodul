permissionset 5266051 "lbt Bonus"
{
    Access = Internal;
    Assignable = true;
    Caption = 'Bonus permissions', Locked = true;

    Permissions =
         codeunit "lbt Bonus Assisted Setup" = X,
         codeunit "lbt Bonus Install Logic" = X,
         codeunit "lbt Bonus Management" = X,
         codeunit "lbt Bonus Triggers" = X,
         page "lbt Bonus Assisted Setup" = X,
         page "lbt Bonus Contract" = X,
         page "lbt Bonus Contract Dimension" = X,
         page "lbt Bonus Contract Factbox" = X,
         page "lbt Bonus Contract Line" = X,
         page "lbt Bonus Contracts" = X,
         page "lbt Bonus Customers" = X,
         page "lbt Bonus Entry" = X,
         page "lbt Bonus Group" = X,
         page "lbt Bonus Setup" = X,
         page "lbt BonusContrAttributeFilter" = X,
         page "lbt Explode Bonus Reservation" = X,
         page "lbt Explode Reservation" = X,
         report "lbt Bonus Reserves" = X,
         report "lbt Bonus Run" = X,
         table "lbt Bonus Contract" = X,
         table "lbt Bonus Contract Dimension" = X,
         table "lbt Bonus Contract Line" = X,
         table "lbt Bonus Customer" = X,
         table "lbt Bonus Entry" = X,
         table "lbt Bonus Group" = X,
         table "lbt Bonus Setup" = X,
         table "lbt BonusContractAttribute" = X,
         tabledata "lbt Bonus Contract" = RIMD,
         tabledata "lbt Bonus Contract Dimension" = RIMD,
         tabledata "lbt Bonus Contract Line" = RIMD,
         tabledata "lbt Bonus Customer" = RIMD,
         tabledata "lbt Bonus Entry" = RIMD,
         tabledata "lbt Bonus Group" = RIMD,
         tabledata "lbt Bonus Setup" = RIMD,
         tabledata "lbt BonusContractAttribute" = RIMD;
}