codeunit 5266052 "lbtbn Bonus Management"
{
    #region SetAssignmentDoc
    procedure SetAssignmentDoc(AssignmentDocTypeP: Option " ","Sales Shipment","Sales Return Receipt";
                               AssignmentDocNoP: Code[20];
                               AssignmentDocLineNoP: Integer)
    begin
        AssignmentDocType := AssignmentDocTypeP;
        AssignmentDocNo := AssignmentDocNoP;
        AssignmentDocLineNo := AssignmentDocLineNoP;
    end;
    #endregion SetAssignmentDoc

    #region SetSourceDoc
    procedure SetSourceDoc(SourceDocTypeP: Enum "lbtbn Document Type"; SourceDocNoP: Code[20]; SourceDocLineNoP: Integer)
    begin
        SourceDocType := SourceDocTypeP;
        SourceDocNo := SourceDocNoP;
        SourceDocLineNo := SourceDocLineNoP;
    end;
    #endregion SetSourceDoc

    #region SetBonusDoc
    procedure SetBonusDoc(BonusDocTypeP: Integer; BonusDocNoP: Code[20]; BonusDocLineNoP: Integer)
    begin
        BonusDocType := BonusDocTypeP;
        BonusDocNo := BonusDocNoP;
        BonusDocLineNo := BonusDocLineNoP;
    end;
    #endregion SetBonusDoc

    #region CreateBonusContractEntry
    procedure CreateBonusContractEntry(var BonusContract: Record "lbtbn Bonus Contract";
                                        CustomerNo: Code[20];
                                        ShipToCode: Code[10];
                                        EntryType: Option "Bonus","Rückstellung","Rückstellungsauflösung";
                                        EntryDate: Date;
                                        BonusRule: Integer;
                                        Qty: Decimal;
                                        Amt: Decimal;
                                        AmtIncVAT: Decimal;
                                        DocAmt: Decimal;
                                        DiscAmt: Decimal;
                                        PmtDiscAmt: Decimal;
                                        DimSetId: Integer
    ): Integer
    var
        EntryNo: Integer;
    begin

        if BonusEntry.FindLast() then
            EntryNo := BonusEntry."Entry No."
        else
            EntryNo := 0;
        Clear(BonusEntry);
        BonusEntry.Init();
        BonusEntry."Entry No." := EntryNo + 1;
        BonusEntry."Entry Type" := EntryType;
        BonusEntry."Contract" := BonusContract."No.";
        BonusEntry."Customer" := CustomerNo;
        BonusEntry."Ship-to Code" := ShipToCode;
        BonusEntry."Process No." := BonusContract."Process No.";
        BonusEntry."Invoice Customer No." := BonusContract."Bonus Recipient";
        BonusEntry."Entry Date" := EntryDate;
        BonusEntry."Bonus Contract Line" := BonusRule;
        BonusEntry."Bonus Document Type" := BonusDocType;
        BonusEntry."Bonus Document No." := BonusDocNo;
        BonusEntry."Bonus Document Line" := BonusDocLineNo;
        BonusEntry."From Document Type" := SourceDocType;
        BonusEntry."From Document No." := SourceDocNo;
        BonusEntry."From Document Line" := SourceDocLineNo;
        BonusEntry."Sales Quantity" := Qty;
        BonusEntry."Calculated Amount" := Amt;
        BonusEntry."calc. Amount incl. VAT" := AmtIncVAT;
        BonusEntry."Base Amount" := DocAmt;
        BonusEntry."Assignment Document Type" := AssignmentDocType;
        BonusEntry."Assignment Document No." := AssignmentDocNo;
        BonusEntry."Assignment Doc. Line No." := AssignmentDocLineNo;
        BonusEntry."Pmt. Discount Amount" := PmtDiscAmt;
        BonusEntry."Discount Amount" := DiscAmt;
        BonusEntry."Dimension Set ID" := DimSetId;
        BonusEntry.Insert();

        exit(BonusEntry."Entry No.");
    end;
    #endregion CreateBonusContractEntry

    #region UpdateFromGenLedgEntry
    procedure UpdateFromGenLedgEntry(var GLEntry: Record "G/L Entry")
    begin
        BonusSetup.Get();
        if BonusSetup."Reserve Mode" = BonusSetup."Reserve Mode"::CreditMemo then
            exit;
        if BonusEntry.Get(GLEntry."lbtbn Bonus Entry No") then begin
            BonusEntry."General Ledger Entry No." := GLEntry."Entry No.";
            if BonusEntry."Posted Amount" = 0 then
                if BonusEntry."Entry Type" <> BonusEntry."Entry Type"::"Liquidation of Reserves" then   ///Betrag wird in BonusRückstellauflösung gefüllt
                    BonusEntry."Posted Amount" := GLEntry.Amount
                else begin
                    BonusSetup.Get();
                    if BonusSetup."Reserve Mode" <> BonusSetup."Reserve Mode"::Journal then
                        BonusEntry."Posted Amount" := GLEntry.Amount;
                end;
            BonusEntry."Entry Date" := GLEntry."Posting Date";
            BonusEntry.Modify();
        end;
    end;
    #endregion UpdateFromGenLedgEntry

    #region EventSubscriber Page Navigate onAfterInsertDocEntries 
    [EventSubscriber(ObjectType::Page, Page::Navigate, 'onAfterInsertDocEntries', '', true, true)]
    local procedure FindBonusContracts(var DocEntry: Record "Document Entry"; ProcessNo: Code[50])
    var
        BonusContract: Record "lbtbn Bonus Contract";
        BonusEntryL: Record "lbtbn Bonus Entry";
        Navigate: Page Navigate;
    begin
        BonusContract.SetRange("Process No.", ProcessNo);
        Navigate.InsertIntoDocEntry(DocEntry, Database::"lbtbn Bonus Contract", Enum::"Document Entry Document Type"::" ", CopyStr(BonusContract.TableCaption(), 1, 1024), BonusContract.Count());
        BonusEntryL.SetRange("Process No.", ProcessNo);
        Navigate.InsertIntoDocEntry(DocEntry, Database::"lbtbn Bonus Entry", BonusEntryL.TableCaption(), BonusEntryL.Count());
    end;
    #endregion EventSubscriber Page Navigate onAfterInsertDocEntries 

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnPostSalesLineOnAfterTestUpdatedSalesLine', '', false, false)]
    local procedure OnPostSalesLineOnAfterTestUpdatedSalesLine(var SalesLine: Record "Sales Line"; var EverythingInvoiced: Boolean; SalesHeader: Record "Sales Header");
    var
        BonusEntryL: Record "lbtbn Bonus Entry";
    begin
        if SalesLine."lbtbn Bonus Entry No." = 0 then
            exit;
        if not BonusEntryL.Get(SalesLine."lbtbn Bonus Entry No.") then
            exit;

        case SalesLine."Document Type" of
            SalesLine."Document Type"::Invoice:
                BonusEntryL."Posted Amount" := -SalesLine."Line Amount";
            SalesLine."Document Type"::"Credit Memo":
                BonusEntryL."Posted Amount" := SalesLine."Line Amount";
        end;
        BonusEntryL.Modify();
    end;

    var
        BonusEntry: Record "lbtbn Bonus Entry";
        BonusSetup: Record "lbtbn Bonus Setup";
        AssignmentDocType: Option;
        AssignmentDocNo: Code[20];
        AssignmentDocLineNo: Integer;
        SourceDocType: Enum "lbtbn Document Type";
        SourceDocNo: Code[20];
        SourceDocLineNo: Integer;
        BonusDocType: Integer;
        BonusDocNo: Code[20];
        BonusDocLineNo: Integer;
}