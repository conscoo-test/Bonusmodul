tableextension 5266056 "lbtbn Sales Header" extends "Sales Header"
{
    trigger OnAfterDelete()
    var
        BonusEntry: Record "lbtbn Bonus Entry";
    begin
        BonusEntry.SetRange("Bonus Document No.", Rec."No.");
        BonusEntry.ModifyAll("Bonus Document Deleted", true);
    end;
}