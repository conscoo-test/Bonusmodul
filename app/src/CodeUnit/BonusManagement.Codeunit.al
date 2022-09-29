codeunit 5266052 "lbtbn Bonus Management"
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

    procedure CreateBonusContractEntry(var BonusContract: Record "lbtbn Bonus Contract";
                                        var BonusCustomer: Record "lbtbn Bonus Customer";
                                        EntryType: Option "Bonus","Rückstellung","Rückstellungsauflösung";
                                        EntryDate: Date;
                                        BonusRule: Integer;
                                        Qty: Decimal;
                                        Amt: Decimal;
                                        AmtIncVAT: Decimal;
                                        DocAmt: Decimal;
                                        DiscAmt: Decimal;
                                        PmtDiscAmt: Decimal
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
        BonusEntry."Customer" := BonusCustomer."Customer No.";
        BonusEntry."Ship-to Code" := BonusCustomer."Ship-to Code";
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
        BonusEntry.Insert();

        exit(BonusEntry."Entry No.");
    end;

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

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'onAfterInsertDocEntries', '', true, true)]
    local procedure FindBonusContracts(var DocEntry: Record "Document Entry"; ProcessNo: Code[50])
    var
        BonusContract: Record "lbtbn Bonus Contract";
        Navigate: Page Navigate;
    begin
        BonusContract.SetRange("Process No.", ProcessNo);
        Navigate.InsertIntoDocEntry(DocEntry, Database::"lbtbn Bonus Contract", Enum::"Document Entry Document Type"::" ", CopyStr(BonusContract.TableCaption(), 1, 1024), BonusContract.Count());
    end;

    var
        BonusEntry: Record "lbtbn Bonus Entry";
        BonusSetup: Record "lbtbn Bonus Setup";

        AssignmentDocType: Option;
        AssignmentDocNo: Code[20];
        AssignmentDocLineNo: Integer;

        SourceDocType: Integer;
        SourceDocNo: Code[20];
        SourceDocLineNo: Integer;

        BonusDocType: Integer;
        BonusDocNo: Code[20];
        BonusDocLineNo: Integer;




}