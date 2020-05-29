codeunit 5266054 "lbt Bonus Triggers"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitGLEntry', '', true, true)]
    local procedure UpdateBonusEntryFromGLEntry(var GLEntry: Record "G/L Entry"; GenJournalLine: Record "Gen. Journal Line")
    var
        BonusManagement: Codeunit "lbt Bonus Management";
    begin
        BonusManagement.UpdateFromGenLedgEntry(GLEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Reverse", 'OnReverseGLEntryOnBeforeInsertGLEntry', '', true, true)]
    local procedure UpdateBonusEntryFromGLEntryReverse(var GLEntry: Record "G/L Entry"; GLEntry2: Record "G/L Entry"; GenJnlLine: Record "Gen. Journal Line")
    var
        BonusManagement: Codeunit "lbt Bonus Management";
    begin
        BonusManagement.UpdateFromGenLedgEntry(GLEntry);
    end;

    [EventSubscriber(ObjectType::Table, Database::"G/L Entry", 'OnAfterCopyGLEntryFromGenJnlLine', '', true, true)]
    local procedure CopyBonusEntryNo(var GLEntry: Record "G/L Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        GLEntry."lbt Bonus Entry No" := GenJournalLine."lbt Bonus Entry No";
    end;
}