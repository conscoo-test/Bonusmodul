report 5266051 "lbt Bonus Reserves"
{
    Caption = 'Bonus Reserves', comment = 'DEU="Bonsrückstellungslauf"';
    UsageCategory = None;
    ProcessingOnly = true;

    dataset
    {
        dataitem("lbt Bonus Contract"; "lbt Bonus Contract")
        {
            DataItemTableView = sorting ("lbt contract");
            RequestFilterFields = "lbt Contract", "lbt Billing Period";



            dataitem("lbt Bonus Customers"; "lbt Bonus Customers")
            {

                DataItemTableView = sorting ("lbt Contract", "lbt Customer", "lbt Ship-to Code");
                DataItemLink = "lbt Contract" = field ("lbt Contract");

                dataitem("Sales Invoice Header"; "Sales Invoice Header")
                {
                    DataItemTableView = sorting ("Sell-to Customer No.", "Posting Date"); //OS!?!
                    DataItemLink = "Sell-to Customer No." = field ("lbt Customer");

                    trigger OnPreDataItem()
                    begin
                        IF "Lbt Bonus Contract"."lbt Reserve Type" = "lbt Bonus Contract"."lbt Reserve Type"::"Amount (LCY)" THEN
                            CurrReport.BREAK();

                        SETRANGE("Posting Date", DateFrom, DateTo);
                        PostingDate := DateTo;
                        IF "lbt Bonus Customers"."lbt Ship-to Code" <> '' THEN
                            SETRANGE("Ship-to Code", "lbt Bonus Customers"."lbt Ship-to Code")
                        ELSE
                            SETRANGE("Ship-to Code");
                    end;

                    trigger OnAfterGetRecord()
                    begin
                        Sign := 1;
                        S_Quantity := 0;
                        S_Amount := 0;
                        DocumentBonusAmt := 0;
                        PmtDiscAmt := 0;
                        DiscAmt := 0;
                        CALCFIELDS(Amount);
                        CASE "lbt Bonus Contract"."lbt Reserve Type" OF
                            "lbt Bonus Contract"."lbt Reserve Type"::"%":
                                BEGIN
                                    BonusAmt := 0;
                                    PostedSalesInvLineRec.RESET();
                                    PostedSalesInvLineRec.SETRANGE("Document No.", "No.");
                                    PostedSalesInvLineRec.SETRANGE(Type, PostedSalesInvLineRec.Type::Item);
                                    IF PostedSalesInvLineRec.FINDSET() THEN
                                        REPEAT
                                            //TODO Parameter auskommentier, muss noch auf Atributefilter umgestellt werden!
                                            /*                                           Continue := TRUE;
                                                                                        BonusContractAttributeRec.RESET;
                                                                                       BonusContractAttributeRec.SETRANGE("lbt Contract", "lbt Bonus Contract"."lbt Contract");
                                                                                       IF BonusContractAttributeRec.FINDSET THEN
                                                                                           REPEAT
                                                                                               PostParaDocLineRec.RESET;
                                                                                               PostParaDocLineRec.SETRANGE("Table ID", DATABASE::"Sales Invoice Line");
                                                                                               PostParaDocLineRec.SETRANGE("Document No.", PostedSalesInvLineRec."Document No.");
                                                                                               PostParaDocLineRec.SETRANGE("Document Line No.", PostedSalesInvLineRec."Line No.");
                                                                                               PostParaDocLineRec.SETRANGE(Parameter, BonusContractAttributeRec."Parameter Code");
                                                                                               PostParaDocLineRec.SETRANGE("Lot No.", '');

                                                                                               IF PostParaDocLineRec.FINDFIRST THEN BEGIN

                                                                                                   CASE BonusContractAttributeRec.Type OF
                                                                                                       BonusContractAttributeRec.Type::Text:
                                                                                                           BEGIN
                                                                                                               PostParaDocLineRec.SETFILTER("Parameter Domain", BonusContractAttributeRec."Parameter Filter");

                                                                                                               IF PostParaDocLineRec.ISEMPTY THEN

                                                                                                                   Continue := FALSE;
                                                                                                           END;
                                                                                                       BonusContractAttributeRec.Type::Boolean:
                                                                                                           IF PostParaDocLineRec.Boolean <> BonusContractAttributeRec.Boolean THEN
                                                                                                               Continue := FALSE;
                                                                                                       BonusContractAttributeRec.Type::Decimal:
                                                                                                           BEGIN
                                                                                                               IF BonusContractAttributeRec."Parameter Filter" <> '' THEN BEGIN
                                                                                                                   IF STRPOS(BonusContractAttributeRec."Parameter Filter", '<>') = 1 THEN
                                                                                                                       PostParaDocLineRec.SETFILTER("Decimal from", BonusContractAttributeRec."Parameter Filter")
                                                                                                                   ELSE BEGIN
                                                                                                                       IF STRPOS(BonusContractAttributeRec."Parameter Filter", '..') = 1 THEN
                                                                                                                           PostParaDocLineRec.SETFILTER("Decimal from", '..' + FORMAT(BonusContractAttributeRec."Decimal to"))
                                                                                                                       ELSE
                                                                                                                           PostParaDocLineRec.SETFILTER("Decimal to", FORMAT(BonusContractAttributeRec."Decimal from") + '..');
                                                                                                                   END;
                                                                                                               END ELSE BEGIN
                                                                                                                   IF (BonusContractAttributeRec."Decimal from" <> 0) AND (BonusContractAttributeRec."Decimal to" <> 0) THEN BEGIN
                                                                                                                       PostParaDocLineRec.SETFILTER("Decimal from", FORMAT(BonusContractAttributeRec."Decimal from") + '..' +
                                                                                                                                                                   FORMAT(BonusContractAttributeRec."Decimal to"));
                                                                                                                       PostParaDocLineRec.SETFILTER("Decimal to", FORMAT(BonusContractAttributeRec."Decimal from") + '..' +
                                                                                                                                                                 FORMAT(BonusContractAttributeRec."Decimal to"));
                                                                                                                   END;
                                                                                                                   IF (BonusContractAttributeRec."Decimal from" <> 0) AND (BonusContractAttributeRec."Decimal to" = 0) THEN
                                                                                                                       PostParaDocLineRec.SETFILTER("Decimal from", FORMAT(BonusContractAttributeRec."Decimal from") + '..');

                                                                                                                   IF (BonusContractAttributeRec."Decimal from" < 0) AND (BonusContractAttributeRec."Decimal to" = 0) THEN BEGIN
                                                                                                                       PostParaDocLineRec.SETFILTER("Decimal from", FORMAT(BonusContractAttributeRec."Decimal from") + '..' +
                                                                                                                                                                   FORMAT(BonusContractAttributeRec."Decimal to"));
                                                                                                                       PostParaDocLineRec.SETFILTER("Decimal to", FORMAT(BonusContractAttributeRec."Decimal from") + '..' +
                                                                                                                                                                 FORMAT(BonusContractAttributeRec."Decimal to"));
                                                                                                                   END;

                                                                                                                   IF (BonusContractAttributeRec."Decimal from" = 0) AND (BonusContractAttributeRec."Decimal to" <> 0) THEN
                                                                                                                       PostParaDocLineRec.SETFILTER("Decimal to", FORMAT(BonusContractAttributeRec."Decimal from") + '..' +
                                                                                                                                                                 FORMAT(BonusContractAttributeRec."Decimal to"));

                                                                                                                   IF (BonusContractAttributeRec."Decimal from" = 0) AND (BonusContractAttributeRec."Decimal to" < 0) THEN
                                                                                                                       PostParaDocLineRec.SETFILTER("Decimal to", '..' + FORMAT(BonusContractAttributeRec."Decimal to"));
                                                                                                               END;
                                                                                                               ///LBIS01
                                                                                                               //IF NOT PostParaDocLineRec.FINDSET THEN
                                                                                                               IF PostParaDocLineRec.ISEMPTY THEN
                                                                                                                   ///LBIS01-
                                                                                                                   Continue := FALSE;
                                                                                                           END;
                                                                                                   END;
                                                                                               END ELSE
                                                                                                   Continue := FALSE;
                                                                                           UNTIL (BonusContractAttributeRec.NEXT = 0) OR (Continue = FALSE); 
                                                                                           */
                                            IF Continue THEN BEGIN
                                                IF "Sales Invoice Header"."Currency Code" = '' THEN BEGIN
                                                    DocAmount := PostedSalesInvLineRec.Amount;
                                                    DocAmtInclVAT := PostedSalesInvLineRec."Amount Including VAT";
                                                END ELSE BEGIN
                                                    DocAmount := ROUND(PostedSalesInvLineRec.Amount / "Sales Invoice Header"."Currency Factor", 0.01);
                                                    DocAmtInclVAT := ROUND(PostedSalesInvLineRec."Amount Including VAT" / "Sales Invoice Header"."Currency Factor", 0.01);
                                                END;
                                                // Zu- und Abschläge
                                                ValueEntryRec.RESET();
                                                ValueEntryRec.SETCURRENTKEY("Document No.");
                                                ValueEntryRec.SETRANGE("Document No.", "Sales Invoice Header"."No.");
                                                ValueEntryRec.SETRANGE("Document Type", ValueEntryRec."Document Type"::"Sales Invoice");
                                                ValueEntryRec.SETRANGE("Document Line No.", PostedSalesInvLineRec."Line No.");
                                                IF ValueEntryRec.FINDSET() THEN
                                                    REPEAT
                                                        IF ValueEntryRec."Sales Amount (Actual)" <> 0 THEN BEGIN
                                                            IF ItemLedgEntryRec.GET(ValueEntryRec."Item Ledger Entry No.") THEN 
                                                                ValueEntryRec2.RESET();
                                                                ValueEntryRec2.SETCURRENTKEY("Item Ledger Entry No.");
                                                                ValueEntryRec2.SETRANGE("Item Ledger Entry No.", ItemLedgEntryRec."Entry No.");
                                                                ValueEntryRec2.SETFILTER("Item Charge No.", '<>%1', '');
                                                                IF ValueEntryRec2.FINDSET() THEN
                                                                    REPEAT
                                                                        ItemCharge2Rec.GET(ValueEntryRec2."Item Charge No.");
                                                                        IF ItemCharge2Rec."lbt Bonus consider" THEN BEGIN
                                                                            DocAmount += ValueEntryRec2."Sales Amount (Actual)";
                                                                            IF SalesInvLineRec.GET(ValueEntryRec2."Document No.", ValueEntryRec2."Document Line No.") THEN
                                                                                DocAmtInclVAT += ROUND(ValueEntryRec2."Sales Amount (Actual)" *
                                                                                          (100 + SalesInvLineRec."VAT %") / 100, 0.0001)
                                                                        END;
                                                                    UNTIL ValueEntryRec2.NEXT() = 0;
                                                            END;
                                                        
                                                    UNTIL ValueEntryRec.NEXT() = 0;
                                                S_Amount := Amount;

                                                IF "lbt Bonus Contract"."lbt Pmt. Discount %" <> 0 THEN
                                                    PmtDiscAmt := DocAmount * "lbt Bonus Contract"."lbt Pmt. Discount %" / 100;
                                                IF "lbt Bonus Contract"."lbt Discount %" <> 0 THEN
                                                    DiscAmt := (DocAmount - PmtDiscAmt) * "lbt Bonus Contract"."lbt Discount %" / 100;
                                                BonusAmt := ROUND("lbt Bonus Contract"."lbt Reserve Value" * (DocAmount - DiscAmt - PmtDiscAmt) / 100, 0.01);

                                                DocumentBonusAmt += BonusAmt;
                                                IF BonusAmt <> 0 THEN
                                                    IF BonusSetupRec."lbt Reserve Mode" = BonusSetupRec."lbt Reserve Mode"::CreditMemo THEN BEGIN
                                                        IF ValueEntryRec.FINDFIRST() THEN BEGIN
                                                            IF ItemLedgEntryRec.GET(ValueEntryRec."Item Ledger Entry No.") AND
                                                              (ItemLedgEntryRec."Document Type" = ItemLedgEntryRec."Document Type"::"Sales Shipment")
                                                            THEN BEGIN
                                                                AddItemChargeCrMemoLine(PostedSalesInvLineRec."Document No.");
                                                                CLEAR(BonusMgt);
                                                                BonusMgt.SetAssignmentDoc(1, ItemLedgEntryRec."Document No.", ItemLedgEntryRec."Document Line No.");
                                                                BonusMgt.SetSourceDoc(1, "No.", PostedSalesInvLineRec."Line No.");
                                                                BonusMgt.SetBonusDoc(2, CrMemoLineRec."Document No.", CrMemoLineRec."Line No.");
                                                                BonusEntryNo :=
                                                                 BonusMgt.CreateBonusContractEntry(
                                                                "lbt Bonus Contract",
                                                                "lbt Bonus Customers",
                                                                1,
                                                                PostingDate,
                                                                0,
                                                                0,
                                                                BonusAmt,
                                                                BonusAmt,
                                                                DocAmount,
                                                                -DiscAmt,
                                                                -PmtDiscAmt);

                                                                CrMemoLineRec."lbt Bonus Entry No." := BonusEntryNo;
                                                                CrMemoLineRec.MODIFY();
                                                            END ELSE 
                                                                DocumentBonusAmt -= BonusAmt;
                                                            
                                                        END ELSE 
                                                            DocumentBonusAmt -= BonusAmt;
                                                        
                                                    END ELSE
                                                        CreateJournalLine(DATABASE::"Sales Invoice Line", "No.", PostedSalesInvLineRec."Line No.",
                                                                        "lbt Bonus Customers"."lbt Customer",
                                                                        BonusAmt, DocAmount,
                                                                        -DiscAmt, -PmtDiscAmt);
                                            END;
                                        UNTIL PostedSalesInvLineRec.NEXT() = 0;

                                END;
                            BonusContractRec."lbt Reserve Type"::"Amount per Unit":
                                /* BEGIN
                                    BonusAmt := 0;
                                    PostedSalesInvLineRec.RESET();
                                    PostedSalesInvLineRec.SETRANGE("Document No.", "No.");
                                    PostedSalesInvLineRec.SETRANGE(Type, PostedSalesInvLineRec.Type::Item);
                                    IF PostedSalesInvLineRec.FINDSET() THEN
                                        REPEAT
                                            PostDocItemUnitRec.RESET;
                                            PostDocItemUnitRec.SETRANGE("Table ID", DATABASE::"Sales Invoice Line");
                                            PostDocItemUnitRec.SETRANGE("Document No.", PostedSalesInvLineRec."Document No.");
                                            PostDocItemUnitRec.SETRANGE("Document Line No.", PostedSalesInvLineRec."Line No.");
                                            PostDocItemUnitRec.SETRANGE("Item Unit", "Bonus Contract"."Unit Reserves Base");
 
                                            
                                            IF PostDocItemUnitRec.FINDFIRST() THEN BEGIN

                                                Continue := TRUE;
                                                BonusContractAttributeRec.RESET();
                                                BonusContractAttributeRec.SETRANGE("lbt Bonus Contract", "lbt Bonus Contract"."lbt Contract");
                                                IF BonusContractAttributeRec.FINDSET() THEN
                                                    REPEAT
                                                        PostParaDocLineRec.RESET;
                                                        PostParaDocLineRec.SETRANGE("Table ID", DATABASE::"Sales Invoice Line");
                                                        PostParaDocLineRec.SETRANGE("Document No.", PostedSalesInvLineRec."Document No.");
                                                        PostParaDocLineRec.SETRANGE("Document Line No.", PostedSalesInvLineRec."Line No.");
                                                        PostParaDocLineRec.SETRANGE(Parameter, BonusContractAttributeRec."Parameter Code");
                                                        PostParaDocLineRec.SETRANGE("Lot No.", '');
                                                        ///LBIS01
                                                        //IF PostParaDocLineRec.FINDSET THEN BEGIN
                                                        IF PostParaDocLineRec.FINDFIRST THEN BEGIN
                                                            ///LBIS01-
                                                            CASE BonusContractAttributeRec.Type OF
                                                                BonusContractAttributeRec.Type::Text:
                                                                    BEGIN
                                                                        PostParaDocLineRec.SETFILTER("Parameter Domain", BonusContractAttributeRec."Parameter Filter");
                                                                        ///LBIS01
                                                                        //IF NOT PostParaDocLineRec.FINDSET THEN
                                                                        IF PostParaDocLineRec.ISEMPTY THEN
                                                                            ///LBIS01-
                                                                            Continue := FALSE;
                                                                    END;
                                                                BonusContractAttributeRec.Type::Boolean:
                                                                    IF PostParaDocLineRec.Boolean <> BonusContractAttributeRec.Boolean THEN
                                                                        Continue := FALSE;
                                                                BonusContractAttributeRec.Type::Decimal:
                                                                    BEGIN
                                                                        IF BonusContractAttributeRec."Parameter Filter" <> '' THEN BEGIN
                                                                            IF STRPOS(BonusContractAttributeRec."Parameter Filter", '<>') = 1 THEN
                                                                                PostParaDocLineRec.SETFILTER("Decimal from", BonusContractAttributeRec."Parameter Filter")
                                                                            ELSE BEGIN
                                                                                IF STRPOS(BonusContractAttributeRec."Parameter Filter", '..') = 1 THEN
                                                                                    PostParaDocLineRec.SETFILTER("Decimal from", '..' + FORMAT(BonusContractAttributeRec."Decimal to"))
                                                                                ELSE
                                                                                    PostParaDocLineRec.SETFILTER("Decimal to", FORMAT(BonusContractAttributeRec."Decimal from") + '..');
                                                                            END;
                                                                        END ELSE BEGIN
                                                                            IF (BonusContractAttributeRec."Decimal from" <> 0) AND (BonusContractAttributeRec."Decimal to" <> 0) THEN BEGIN
                                                                                PostParaDocLineRec.SETFILTER("Decimal from", FORMAT(BonusContractAttributeRec."Decimal from") + '..' +
                                                                                                                            FORMAT(BonusContractAttributeRec."Decimal to"));
                                                                                PostParaDocLineRec.SETFILTER("Decimal to", FORMAT(BonusContractAttributeRec."Decimal from") + '..' +
                                                                                                                          FORMAT(BonusContractAttributeRec."Decimal to"));
                                                                            END;
                                                                            IF (BonusContractAttributeRec."Decimal from" <> 0) AND (BonusContractAttributeRec."Decimal to" = 0) THEN
                                                                                PostParaDocLineRec.SETFILTER("Decimal from", FORMAT(BonusContractAttributeRec."Decimal from") + '..');

                                                                            IF (BonusContractAttributeRec."Decimal from" < 0) AND (BonusContractAttributeRec."Decimal to" = 0) THEN BEGIN
                                                                                PostParaDocLineRec.SETFILTER("Decimal from", FORMAT(BonusContractAttributeRec."Decimal from") + '..' +
                                                                                                                            FORMAT(BonusContractAttributeRec."Decimal to"));
                                                                                PostParaDocLineRec.SETFILTER("Decimal to", FORMAT(BonusContractAttributeRec."Decimal from") + '..' +
                                                                                                                          FORMAT(BonusContractAttributeRec."Decimal to"));
                                                                            END;

                                                                            IF (BonusContractAttributeRec."Decimal from" = 0) AND (BonusContractAttributeRec."Decimal to" <> 0) THEN
                                                                                PostParaDocLineRec.SETFILTER("Decimal to", FORMAT(BonusContractAttributeRec."Decimal from") + '..' +
                                                                                                                          FORMAT(BonusContractAttributeRec."Decimal to"));

                                                                            IF (BonusContractAttributeRec."Decimal from" = 0) AND (BonusContractAttributeRec."Decimal to" < 0) THEN
                                                                                PostParaDocLineRec.SETFILTER("Decimal to", '..' + FORMAT(BonusContractAttributeRec."Decimal to"));
                                                                        END;                                                                        
                                                                        IF PostParaDocLineRec.ISEMPTY() THEN

                                                                            Continue := FALSE;
                                                                  END;  
                                                            END;
                                                        END ELSE
                                                            Continue := FALSE;
                                                    UNTIL (BonusContractAttributeRec.NEXT() = 0) OR (Continue = FALSE);
                                                IF Continue THEN BEGIN
                                                    BonusAmt := ROUND(PostDocItemUnitRec.Quantity *
                                                                      "lbt Bonus Contract"."lbt Reserve Value", 0.01);
                                                    DocumentBonusAmt += BonusAmt;
                                                    S_Quantity := PostDocItemUnitRec.Quantity;
                                                    IF BonusAmt <> 0 THEN
                                                        IF BonusSetupRec."lbt Reserve Mode" = BonusSetupRec."lbt Reserve Mode"::CreditMemo THEN BEGIN
                                                            ValueEntryRec.RESET();
                                                            ValueEntryRec.SETCURRENTKEY("Document No.");
                                                            ValueEntryRec.SETRANGE("Document No.", PostedSalesInvLineRec."Document No.");
                                                            ValueEntryRec.SETRANGE("Document Type", ValueEntryRec."Document Type"::"Sales Invoice");
                                                            ValueEntryRec.SETRANGE("Document Line No.", PostedSalesInvLineRec."Line No.");
                                                            IF ValueEntryRec.FINDFIRST() THEN BEGIN
                                                                IF ItemLedgEntryRec.GET(ValueEntryRec."Item Ledger Entry No.") AND
                                                                  (ItemLedgEntryRec."Document Type" = ItemLedgEntryRec."Document Type"::"Sales Shipment")
                                                                THEN BEGIN
                                                                    AddItemChargeCrMemoLine(PostedSalesInvLineRec."Document No.");
                                                                    CLEAR(BonusMgt);
                                                                    BonusMgt.SetAssignmentDoc(1, ItemLedgEntryRec."Document No.", ItemLedgEntryRec."Document Line No.");
                                                                    BonusMgt.SetSourceDoc(1, "No.", PostedSalesInvLineRec."Line No.");
                                                                    BonusMgt.SetBonusDoc(2, CrMemoLineRec."Document No.", CrMemoLineRec."Line No.");
                                                                    BonusEntryNo := BonusMgt.CreateBonusContractEntry("lbt Bonus Contract",
                                                                                    "lbt Bonus Customers",
                                                                                    1, PostingDate, 0,
                                                                                    SalesInvLineRec.Quantity, ////PostDocItemUnitRec.Quantity,
                                                                                    BonusAmt, 
                                                                                    BonusAmt, 
                                                                                    DocAmount,
                                                                                    0, 
                                                                                    0);
                                                                    CrMemoLineRec."lbt Bonus Entry No." := BonusEntryNo;
                                                                    CrMemoLineRec.MODIFY();
                                                                END ELSE 
                                                                    DocumentBonusAmt -= BonusAmt;
                                                                
                                                            END ELSE 
                                                                DocumentBonusAmt -= BonusAmt;
                                                           ;
                                                        END ELSE
                                                            CreateJournalLine(DATABASE::"Sales Invoice Line",
                                                                                 "No.", 
                                                                                 PostedSalesInvLineRec."Line No.",
                                                                                "lbt Bonus Customers"."lbt Customer",
                                                                                BonusAmt, 
                                                                                0,
                                                                                0, 
                                                                                0);
                                                END;
                                            END;
                                        UNTIL PostedSalesInvLineRec.NEXT() = 0;
                                END;
                        END; */

                        IF DocumentBonusAmt = 0 THEN
                            CurrReport.SKIP();
                        //TODO Auskommentiert
                        /*                        
                        SumAmounts[1] += S_Amount;
                        SumAmounts[2] += S_Amount;
                        SumAmounts[3] += S_Amount;
                        SumAmounts[4] += S_Amount;
                        SumQuantity[1] += S_Quantity;
                        SumQuantity[2] += S_Quantity;
                        SumQuantity[3] += S_Quantity;
                        SumQuantity[4] += S_Quantity;
                        SumDocumentAmounts[1] += DocumentBonusAmt;
                        SumDocumentAmounts[2] += DocumentBonusAmt;
                        SumDocumentAmounts[3] += DocumentBonusAmt;
                        SumDocumentAmounts[4] += DocumentBonusAmt; 
                        */
                    end;
                end;

                  
                }
                dataitem("Sales Cr.Memo Header"; "Sales Cr.Memo Header")
                {
                    DataItemTableView = sorting ("Sell-to Customer No.", "Posting Date");
                    DataItemLink = "Sell-to Customer No." = field ("lbt Customer");

                    trigger OnPreDataItem()
                    begin
                        //TODO OnPreDataItem()- dataitem "Sales Cr.Memo Header"
                    end;

                    trigger OnAfterGetRecord()
                    begin
                        //OnAfterGetRecord()- dataitem "Sales Cr.Memo Header"
                    end;

                    trigger OnPostDataItem()
                    begin
                        //TODO OnPostDataItem()- dataitem "Sales Cr.Memo Header"
                    end;
                }
                dataitem(Integer; Integer)
                {
                    DataItemTableView = sorting (Number) Where (Number = const (1));

                    trigger OnPreDataItem()
                    begin
                        //TODO dataitem "Integer" -->OnPreDataItem()
                    end;

                    trigger OnAfterGetRecord()
                    begin
                        //TODO dataitem "Integer" -->OnAfterGetRecord()
                    end;

                    trigger OnPostDataItem()
                    begin
                        //TODO dataitem "Integer" -->OnPostDataItem()
                    end;
                }

                trigger OnPreDataItem()
                begin
                    //TODO OnPreDataItem()
                end;    

                trigger OnAfterGetRecord()
                begin
                    //TODO OnAfterGetRecord()
                end;

                trigger OnPostDataItem()
                begin
                    //TODO OnPostDataItem()
                end;



            }

            trigger OnPreDataItem()
            begin
                Dia.OPEN(Text004Msg + Text005Msg);
                PostingDate := DateTo;
                CLEAR(SumAmounts);
                CLEAR(SumDocumentAmounts);
                CLEAR(SumQuantity);
            end;

            trigger OnAfterGetRecord()
            begin
                CLEAR(ContractTotalApplAmt);
                IF ("BonusContractRec"."lbt Valid from" <= PostingDate) AND
                  (("BonusContractRec"."lbt Valid to" = 0D) OR ("BonusContractRec"."lbt Valid to" >= PostingDate)) THEN BEGIN
                    TESTFIELD("lbt Reserve Item Charge");
                    Dia.UPDATE(1, "lbt Bonus Contract"."lbt No. of Customers");
                    Dia.UPDATE(2, "lbt Bonus Contract"."lbt Contract");
                    Continue := FALSE;
                    IF ("BonusContractRec"."lbt Last Reserve at" = 0D) THEN
                        Continue := TRUE
                    ELSE
                        IF (DateFrom > "lbt Last Reserve at") THEN
                            Continue := TRUE;
                    IF Continue THEN BEGIN
                        "BonusContractRec"."lbt Last Reserve at" := PostingDate;
                        "BonusContractRec".MODIFY();
                        BonusAmt := 0;
                        IF "lbt Reserve Type" = "lbt Reserve Type"::"Amount (LCY)" THEN
                            ContractTotalApplAmt := GetTotalAmount();
                    END ELSE
                        CurrReport.SKIP();
                END ELSE
                    CurrReport.SKIP();
            end;

            trigger OnPostDataItem()
            begin
                Dia.CLOSE();
                COMMIT();
                IF BonusSetupRec."lbt Reserve Mode" = BonusSetupRec."lbt Reserve Mode"::CreditMemo THEN BEGIN
                    IF NOT CrMemoHeaderCreated THEN
                        EXIT;
                    CLEAR(SalesCreditMemoPage);
                    SalesHeaderRec.SETRANGE("Document Type", SalesHeaderRec."Document Type");
                    SalesHeaderRec.SETRANGE("No.", SalesHeaderRec."No.");
                    SalesCreditMemoPage.SETTABLEVIEW(SalesHeaderRec);
                    SalesCreditMemoPage.RUN();
                END ELSE BEGIN
                    CLEAR(GenJnlPage);
                    SetJournalBatch(BonusSetupRec."lbt Gen. Jnl. Bonus Reserve", BonusSetupRec."lbt Gen.Jnl.Templ.BonusReserve");
                    GenJnlPage.RUN();
                END;
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Optionen)
                {
                    Caption = 'Option', comment = 'DEU ="Optionen"';
                    field(DateFrom; DateFrom)
                    {
                        Caption = 'Date from', comment = 'DEU="Datum von"';
                        ApplicationArea = All;
                    }
                    field(DateTo; DateTo)
                    {
                        Caption = 'Date to', comment = 'DEU="Datum Bis"';
                        ApplicationArea = All;
                    }

                }
            }
        }
    }

    trigger OnInitReport()
    begin

    end;

    trigger OnPreReport()
    begin
        IF (DateFrom = 0D) OR (DateTo = 0D) THEN
            ERROR(Text001Msg);
        IF DateFrom > DateTo THEN
            ERROR(Text002Msg);
        BonusSetupRec.GET();
        IF BonusSetupRec."lbt Reserve Mode" = BonusSetupRec."lbt Reserve Mode"::CreditMemo THEN BEGIN
            BonusSetupRec.TESTFIELD("lbt Cust Gr. Reserve Cr. Memo");
            BonusSetupRec.TESTFIELD("lbt Bus.Post.Gr.f.Res.Cr.Memo");
            CustPostGrpRec.GET(BonusSetupRec."lbt Cust Gr. Reserve Cr. Memo");
            CustPostGrpRec.TESTFIELD("Receivables Account");
            GenBussPostGroupRec.GET(BonusSetupRec."lbt Bus.Post.Gr.f.Res.Cr.Memo");
        END ELSE BEGIN
            BonusSetupRec.TESTFIELD("lbt Gen.Jnl.Templ.BonusReserve");
            BonusSetupRec.TESTFIELD("lbt Gen. Jnl. Bonus Reserve");
        END;
        GenJnlLine2Rec.RESET();
        GenJnlLine2Rec.SETRANGE("Journal Template Name", BonusSetupRec."lbt Gen.Jnl.Templ.BonusReserve");
        GenJnlLine2Rec.SETRANGE("Journal Batch Name", BonusSetupRec."lbt Gen. Jnl. Bonus Reserve");
        IF GenJnlLine2Rec.FINDLAST() THEN
            LineNo := GenJnlLine2Rec."Line No."
        ELSE
            LineNo := 0;

    end;

    trigger OnPostReport()
    begin

    end;

    procedure SetJournalBatch(VAR JnlBatchName: Code[10]; VAR JnlTemplateName: Code[10])
    begin

        //TODO Funktion "SetJournalBatch" muss noch umgesetzt werden

    end;

    procedure getTotalAmount(): Decimal
    begin
        //TODO Funktion "getTotalAmount" muss  noch umgesetzt werden
    end;

    procedure AddItemChargeCrMemoLine(DocNoP: Code[20])
    begin
        //TODO Funktion "AddItemChargeCrMemoLine" muss  noch umgesetzt werden
    end;

    procedure CreateJournalLine(TableID: Integer; VAR DocNo: Code[20]; DocLineNo: Integer; VAR CustNo: Code[20]; VAR Amt: Decimal; DocAmt: Decimal; DiscAmount: Decimal; PmtDiscAmount: Decimal)
    begin
        //TODO Funktion "CreateJournalLine"
    end;

    var
        BonusSetupRec: Record "lbt Bonus Setup";
        CustPostGrpRec: Record "Customer Posting Group";
        GenBussPostGroupRec: Record "Gen. Business Posting Group";
        GenJnlLine2Rec: Record "Gen. Journal Line";
        BonusContractRec: Record "lbt Bonus Contract";
        SalesHeaderRec: Record "Sales Header";
        CrMemoLineRec: Record "Sales Line";
        SalesInvLineRec: Record "Sales Invoice Line";
        BonusContractAttributeRec: Record "lbt BonusContractAttribute";
        PostedSalesInvLineRec: Record "Sales Invoice Line";
        PostedCrMemoLineRec: Record "Sales Cr.Memo Line";
        ValueEntryRec: Record "Value Entry";
        ValueEntryRec2: Record "Value Entry";
        ItemLedgEntryRec: Record "Item Ledger Entry";
        ItemCharge2Rec: Record "Item Charge";
        BonusMgt: Codeunit "lbt Bonus Mgt.";





        SalesCreditMemoPage: Page "Sales Credit Memo";
        GenJnlPage: Page "General Journal";
        Dia: Dialog;

        LineNo: Integer;
        DateFrom: Date;
        DateTo: Date;
        PostingDate: Date;
        SumAmounts: Decimal;
        SumDocumentAmounts: Decimal;
        SumQuantity: Decimal;
        ContractTotalApplAmt: Decimal;
        Continue: Boolean;
        BonusAmt: Decimal;
        CrMemoHeaderCreated: Boolean;
        CurrentJnlBatchName2: Code[10];
        Sign: Integer;
        S_Quantity: Integer;
        S_Amount: Integer;
        DocumentBonusAmt: Decimal;
        PmtDiscAmt: Decimal;
        DiscAmt: Decimal;
        DocAmount: Decimal;
        DocAmtInclVAT: Decimal;
        BonusEntryNo: Integer;

        Text001Msg: Label 'Please input the accounting period.', Comment = 'DEU="Geben Sie den Abrechnungszeitraum ein."';
        Text002Msg: Label 'Please check the accounting period.', Comment = 'DEU="Überprüfen Sie den Abrechnungszeitraum."';

        Text004Msg: Label 'Customer #1##############\', Comment = 'DEU="Debitor    #1##############\"';
        Text005Msg: Label 'Contract   #2##############', Comment = 'DEU="Vertrag    #2##############"';

}