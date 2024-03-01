tableextension 5266060 "lbtbn SalesLine" extends "Sales Line" //37
{
    fields
    {
        field(5266060; "lbtbn Bonus Entry No."; Integer)
        {
            Caption = 'Bonus Entry No.';
            DataClassification = CustomerContent;
        }

    }

    trigger OnDelete()
    var
        BonusEntry: Record "lbtbn Bonus Entry";
        ReserveBonusEntry: Record "lbtbn Bonus Entry";
    begin
        if Rec."lbtbn Bonus Entry No." = 0 then
            exit;
        if not BonusEntry.Get(Rec."lbtbn Bonus Entry No.") then
            exit;
        if BonusEntry."Entry Type" <> BonusEntry."Entry Type"::"Liquidation of Reserves" then
            exit;
        BonusEntry.Reversed := true;
        BonusEntry.Modify(false);
        ReserveBonusEntry.SetCurrentKey("Reversed by Entry No.");
        ReserveBonusEntry.SetRange("Reversed by Entry No.", BonusEntry."Entry No.");
        ReserveBonusEntry.SetRange(Reversed, true);
        if ReserveBonusEntry.FindFirst() then begin
            ReserveBonusEntry.Reversed := false;
            ReserveBonusEntry."Reversed by Entry No." := 0;
            ReserveBonusEntry.Modify(false);
        end;
    end;

}