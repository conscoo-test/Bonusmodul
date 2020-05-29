codeunit 5266052 "lbt Bonus Management"
{
    procedure SetAssignmentDoc(AssignmentDocTypeP: Option " ","Sales Shipment","Sales Return Receipt";
                               AssignmentDocNoP: Code[20];
                               AssignmentDocLineNoP: Integer)
    begin
        AssignmentDocType := AssignmentDocTypeP;
        AssignmentDocNo := AssignmentDocNoP;
        AssignmentDocLineNo := AssignmentDocLineNoP;
    end;

    procedure SetSourceDoc(SourceDocTypeP: Integer; SourceDocNoP: Code[20]; SourceDocLineNoP: Integer)
    begin
        SourceDocType := SourceDocTypeP;
        SourceDocNo := SourceDocNoP;
        SourceDocLineNo := SourceDocLineNoP;
    end;

    procedure SetBonusDoc(BonusDocTypeP: Integer; BonusDocNoP: Code[20]; BonusDocLineNoP: Integer)
    begin
        BonusDocType := BonusDocTypeP;
        BonusDocNo := BonusDocNoP;
        BonusDocLineNo := BonusDocLineNoP;
    end;

    procedure CreateBonusContractEntry(var ContractRec: Record "lbt Bonus Contract";
                                        var BonusCustRec: Record "lbt Bonus Customers";
                                        EntryType: Option "Bonus","Rückstellung","Rückstellungsauflösung";
                                        var EntryDate: Date;
                                        BonusRule: Integer;
                                        Qty: Decimal;
                                        Amt: Decimal;
                                        AmtIncVAT: Decimal;
                                        DocAmt: Decimal;
                                        DiscAmt: Decimal;
                                        PmtDiscAmt: Decimal
    ): Integer
    var
        BonusContractEntryRec: Record "lbt Bonus Entry";
        EntryNo: Integer;
    begin

        if BonusContractEntryRec.FindLast() then
            EntryNo := BonusContractEntryRec."Entry No."
        else
            EntryNo := 0;
        CLEAR(BonusContractEntryRec);
        BonusContractEntryRec.Init();
        BonusContractEntryRec."Entry No." := EntryNo + 1;
        BonusContractEntryRec."Entry Type" := EntryType;
        BonusContractEntryRec."Contract" := ContractRec."Contract";
        BonusContractEntryRec."Customer" := BonusCustRec."Customer";
        BonusContractEntryRec."Ship-to Code" := BonusCustRec."Ship-to Code";
        BonusContractEntryRec."Process No." := ContractRec."Process No.";
        BonusContractEntryRec."Invoice Customer No." := ContractRec."Bonus Recipient";
        BonusContractEntryRec."Entry Date" := EntryDate;
        BonusContractEntryRec."Bonus Contract Line" := BonusRule;
        BonusContractEntryRec."Bonus Document Type" := BonusDocType;
        BonusContractEntryRec."Bonus Document No." := BonusDocNo;
        BonusContractEntryRec."Bonus Document Line" := BonusDocLineNo;
        BonusContractEntryRec."From Document Type" := SourceDocType;
        BonusContractEntryRec."From Document No." := SourceDocNo;
        BonusContractEntryRec."From Document Line" := SourceDocLineNo;
        BonusContractEntryRec."Sales Quantity" := Qty;
        BonusContractEntryRec."Calculated Amount" := Amt;
        BonusContractEntryRec."calc. Amount incl. VAT" := AmtIncVAT;
        BonusContractEntryRec."Base Amount" := DocAmt;
        BonusContractEntryRec."Assignment Document Type" := AssignmentDocType;
        BonusContractEntryRec."Assignment Document No." := AssignmentDocNo;
        BonusContractEntryRec."Assignment Doc. Line No." := AssignmentDocLineNo;
        BonusContractEntryRec."Pmt. Discount Amount" := PmtDiscAmt;
        BonusContractEntryRec."Discount Amount" := DiscAmt;
        BonusContractEntryRec.Insert();

        exit(BonusContractEntryRec."Entry No.");
    end;

    procedure UpdateFromGenLedgEntry(var GLEntry: Record "G/L Entry")
    begin
        BonusSetup.Get();
        if BonusSetup."Reserve Mode" = BonusSetup."Reserve Mode"::CreditMemo then
            exit;
        if BonusEntry.Get(GLEntry."lbt Bonus Entry No") then begin
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

    local procedure UpdateFromSalesLine(var SalesLineRec: Record "Sales Line")
    begin
        if BonusEntry.GET(SalesLineRec."lbt Bonus Entry No.") then begin

            CASE SalesLineRec."Document Type" OF
                SalesLineRec."Document Type"::Invoice:
                    BonusEntry."Posted Amount" := -SalesLineRec."Line Amount";
                SalesLineRec."Document Type"::"Credit Memo":
                    BonusEntry."Posted Amount" := SalesLineRec."Line Amount";
            end;

            BonusEntry.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'onAfterInsertDocEntries', '', true, true)]
    local procedure FindBonusContracts(var DocEntry: Record "Document Entry"; ProcessNo: Code[50])
    var
        BonusContract: Record "lbt Bonus Contract";
        Navigate: Page Navigate;
    begin
        BonusContract.SetRange("Process No.", ProcessNo);
        Navigate.InsertIntoDocEntry(DocEntry, Database::"lbt Bonus Contract", 0, CopyStr(BonusContract.TableCaption(), 1, 1024), BonusContract.Count());
    end;

    var
        BonusEntry: Record "lbt Bonus Entry";
        BonusSetup: Record "lbt Bonus Setup";

        AssignmentDocType: Option;
        AssignmentDocNo: Code[20];
        AssignmentDocLineNo: Integer;

        SourceDocType: Integer;
        SourceDocNo: code[20];
        SourceDocLineNo: Integer;

        BonusDocType: Integer;
        BonusDocNo: Code[20];
        BonusDocLineNo: Integer;




}