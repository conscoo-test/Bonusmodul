codeunit 5266054 "lbtbn Bonus Triggers"
{

    #region EventSubscriber Codeunit "Gen. Jnl.-Post Line" OnAfterInitGLEntry 
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitGLEntry', '', true, true)]
    local procedure UpdateBonusEntryFromGLEntry(var GLEntry: Record "G/L Entry"; GenJournalLine: Record "Gen. Journal Line")
    var
        BonusManagement: Codeunit "lbtbn Bonus Management";
    begin
        BonusManagement.UpdateFromGenLedgEntry(GLEntry);
    end;
    #endregion EventSubscriber Codeunit "Gen. Jnl.-Post Line" OnAfterInitGLEntry 

    #region EventSubscriber Codeunit "Gen. Jnl.-Post Reverse" OnReverseGLEntryOnBeforeInsertGLEntry 
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Reverse", 'OnReverseGLEntryOnBeforeInsertGLEntry', '', true, true)]
    local procedure UpdateBonusEntryFromGLEntryReverse(var GLEntry: Record "G/L Entry"; GLEntry2: Record "G/L Entry"; GenJnlLine: Record "Gen. Journal Line")
    var
        BonusManagement: Codeunit "lbtbn Bonus Management";
    begin
        BonusManagement.UpdateFromGenLedgEntry(GLEntry);
    end;
    #endregion EventSubscriber Codeunit "Gen. Jnl.-Post Reverse" OnReverseGLEntryOnBeforeInsertGLEntry 

    #region EventSubscriber Table "G/L Entry" OnAfterCopyGLEntryFromGenJnlLine 
    [EventSubscriber(ObjectType::Table, Database::"G/L Entry", 'OnAfterCopyGLEntryFromGenJnlLine', '', true, true)]
    local procedure CopyBonusEntryNo(var GLEntry: Record "G/L Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        GLEntry."lbtbn Bonus Entry No" := GenJournalLine."lbtbn Bonus Entry No";
    end;
    #endregion EventSubscriber Table "G/L Entry" OnAfterCopyGLEntryFromGenJnlLine 

    #region EventSubscriber Codeunit "Gen. Jnl.-Post Line" OnAfterFinishPosting 
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterFinishPosting', '', false, false)]
    local procedure OnAfterFinishPosting(var GlobalGLEntry: Record "G/L Entry"; var GLRegister: Record "G/L Register"; var IsTransactionConsistent: Boolean; var GenJournalLine: Record "Gen. Journal Line");
    var
        ReverseReserve: Codeunit "lbtbn Reverse Reserve";
    begin
        if GenJournalLine."lbtbn Reserve Transaction No." = 0 then
            exit;

        ReverseReserve.BonusReverseReserve(GlobalGLEntry, GenJournalLine);
    end;
    #endregion EventSubscriber Codeunit "Gen. Jnl.-Post Line" OnAfterFinishPosting 

    #region EventSubscriber Codeunit "Gen. Jnl.-Post Line" OnBeforeCode 
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeCode', '', false, false)]
    local procedure OnBeforeCode(var GenJnlLine: Record "Gen. Journal Line"; CheckLine: Boolean; var IsPosted: Boolean; var GLReg: Record "G/L Register")
    var
        ReverseReserve: Codeunit "lbtbn Reverse Reserve";
    begin
        if GenJnlLine."lbtbn Reserve Entry No" = 0 then
            exit;
        GenJnlLine."lbtbn Bonus Entry No" := ReverseReserve.BonusEntryReserveExploding(GenJnlLine."lbtbn Reserve Entry No", GenJnlLine."Posting Date");

    end;
    #endregion EventSubscriber Codeunit "Gen. Jnl.-Post Line" OnBeforeCode 

}