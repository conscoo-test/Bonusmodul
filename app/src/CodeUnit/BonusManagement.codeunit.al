codeunit 5266052 "lbt Bonus Management"
{
    trigger OnRun()
    var
        Rec: Record "G/L Entry";
    begin
        UpdateFromGenLedgEntry(Rec);
    end;

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

    procedure GenLedgEntryToBilling(var GenLedgEntryRec: Record "G/L Entry"; BillingCode: Code[10]; BillingEntryNo: Integer)
    begin
        //TODO: Prüfen ob "Billing Code" noch benötigt wird
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
            EntryNo := BonusContractEntryRec."lbt Entry No."
        else
            EntryNo := 0;
        CLEAR(BonusContractEntryRec);
        BonusContractEntryRec.Init();
        BonusContractEntryRec."lbt Entry No." := EntryNo + 1;
        BonusContractEntryRec."lbt Entry Type" := EntryType;
        BonusContractEntryRec."lbt Contract" := ContractRec."lbt Contract";
        BonusContractEntryRec."lbt Customer" := BonusCustRec."lbt Customer";
        BonusContractEntryRec."lbt Ship-to Code" := BonusCustRec."lbt Ship-to Code";
        BonusContractEntryRec."Process No." := ContractRec."Process No.";
        BonusContractEntryRec."lbt Invoice Customer No." := ContractRec."lbt Bonus Recipient";
        BonusContractEntryRec."lbt Entry Date" := EntryDate;
        BonusContractEntryRec."lbt Bonus Contract Line" := BonusRule;
        BonusContractEntryRec."lbt Bonus Document Type" := BonusDocType;
        BonusContractEntryRec."lbt Bonus Document No." := BonusDocNo;
        BonusContractEntryRec."lbt Bonus Document Line" := BonusDocLineNo;
        BonusContractEntryRec."lbt From Document Type" := SourceDocType;
        BonusContractEntryRec."lbt From Document No." := SourceDocNo;
        BonusContractEntryRec."lbt From Document Line" := SourceDocLineNo;
        BonusContractEntryRec."lbt Sales Quantity" := Qty;
        BonusContractEntryRec."lbt Calculated Amount" := Amt;
        BonusContractEntryRec."lbt calc. Amount incl. VAT" := AmtIncVAT;
        BonusContractEntryRec."lbt Base Amount" := DocAmt;
        BonusContractEntryRec."lbt Assignment Document Type" := AssignmentDocType;
        BonusContractEntryRec."lbt Assignment Document No." := AssignmentDocNo;
        BonusContractEntryRec."lbt Assignment Doc. Line No." := AssignmentDocLineNo;
        BonusContractEntryRec."lbt Pmt. Discount Amount" := PmtDiscAmt;
        BonusContractEntryRec."lbt Discount Amount" := DiscAmt;
        BonusContractEntryRec.Insert();

        exit(BonusContractEntryRec."lbt Entry No.");
    end;

    procedure UpdateFromGenLedgEntry(var GenLedgEntryRec: Record "G/L Entry")
    begin
        if BonusEntryRec.Get(GenLedgEntryRec."lbt Bonus Entry No") AND (BonusEntryRec."lbt General Ledger Entry No." = 0) then begin
            BonusEntryRec."lbt General Ledger Entry No." := GenLedgEntryRec."Entry No.";
            if BonusEntryRec."lbt Posted Amount" = 0 then
                if BonusEntryRec."lbt Entry Type" <> BonusEntryRec."lbt Entry Type"::"Liquidation of Reserves" then   ///Betrag wird in BonusRückstellauflösung gefüllt
                    BonusEntryRec."lbt Posted Amount" := GenLedgEntryRec.Amount
                else begin
                    BonusSetupRec.Get();
                    if BonusSetupRec."lbt Reserve Mode" <> BonusSetupRec."lbt Reserve Mode"::Journal then
                        BonusEntryRec."lbt Posted Amount" := GenLedgEntryRec.Amount;
                end;
            BonusEntryRec."lbt Entry Date" := GenLedgEntryRec."Posting Date";
            BonusEntryRec.Modify();
        end;
    end;

    local procedure UpdateFromSalesLine(var SalesLineRec: Record "Sales Line")
    begin
        if BonusEntryRec.GET(SalesLineRec."lbt Bonus Entry No.") then begin

            CASE SalesLineRec."Document Type" OF
                SalesLineRec."Document Type"::Invoice:
                    BonusEntryRec."lbt Posted Amount" := -SalesLineRec."Line Amount";
                SalesLineRec."Document Type"::"Credit Memo":
                    BonusEntryRec."lbt Posted Amount" := SalesLineRec."Line Amount";
            end;

            BonusEntryRec.Modify();
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
        BonusEntryRec: Record "lbt Bonus Entry";
        BonusSetupRec: Record "lbt Bonus Setup";

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