report 5266051 "lbtbn Bonus Reserves"
{
    ApplicationArea = All;
    Caption = 'Bonus Reserves';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        #region dataitem
        dataitem("Bonus Contract"; "lbtbn Bonus Contract")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Billing Period";

            #region dataitems
            dataitem(Invoices; Integer)
            {
                DataItemTableView = sorting(Number);
                #region OnPreDataItem
                trigger OnPreDataItem()
                begin
                    if InvoiceNos.Count = 0 then
                        CurrReport.Break();
                    Invoices.SetRange(Number, 1, InvoiceNos.Count);
                end;
                #endregion OnPreDataItem

                #region OnAfterGetRecord
                trigger OnAfterGetRecord()
                var
                    SalesInvoiceHeader: Record "Sales Invoice Header";
                begin
                    SalesInvoiceHeader.Get(InvoiceNos.Get(Invoices.Number));
                    CreateBonus.SetDocument(SalesInvoiceHeader."Sell-to Customer No.", SalesInvoiceHeader."Ship-to Code", SalesInvoiceHeader."Currency Factor");
                    CalcFromSalesInvoice(SalesInvoiceHeader);
                end;
                #endregion OnAfterGetRecord
            }
            dataitem(CrMemos; Integer)
            {
                DataItemTableView = sorting(Number);
                #region OnPreDataItem
                trigger OnPreDataItem()
                begin
                    if CrMemoNos.Count = 0 then
                        CurrReport.Break();
                    CrMemos.SetRange(Number, 1, CrMemoNos.Count);
                end;
                #endregion OnPreDataItem

                #region OnAfterGetRecord
                trigger OnAfterGetRecord()
                var
                    SalesCrMemoHeader: Record "Sales Cr.Memo Header";
                begin
                    SalesCrMemoHeader.Get(CrMemoNos.Get(CrMemos.Number));
                    CreateBonus.SetDocument(SalesCrMemoHeader."Sell-to Customer No.", SalesCrMemoHeader."Ship-to Code", SalesCrMemoHeader."Currency Factor");
                    CalcFromCrMemo(SalesCrMemoHeader);
                end;
                #endregion OnAfterGetRecord
            }
            dataitem("Bonus Customer"; "lbtbn Bonus Customer")
            {
                DataItemLink = Contract = field("No.");
                DataItemTableView = sorting(Contract, "Customer No.", "Ship-to Code");

                #region dataitems
                dataitem("Fixed Amount"; Integer)
                {
                    DataItemTableView = sorting(Number) where(Number = const(1));

                    #region OnPreDataItem
                    trigger OnPreDataItem()
                    begin
                        if "Bonus Contract"."Reserve Type" <> "Bonus Contract"."Reserve Type"::"Amount (LCY)" then
                            CurrReport.Break();
                    end;
                    #endregion OnPreDataItem

                    #region OnAfterGetRecord
                    trigger OnAfterGetRecord()
                    var
                        SalesLine: Record "Sales Line";
                        FixedAmount: Codeunit "lbtbn Fixed Amount";
                    begin
                        I := FixedAmount;
                        FixedAmount.SetCustomerNo("Bonus Customer"."Customer No.");
                        case BonusSetup."Reserve Mode" of
                            BonusSetup."Reserve Mode"::CreditMemo:
                                begin
                                    CreateBonusCrMemoLine("Bonus Contract"."Reserve Value", SalesLine);
                                    CreateBonusEntryForFixedAmount(SalesLine);
                                end;
                            BonusSetup."Reserve Mode"::Journal:
                                CreateJournalLine("Bonus Contract"."Reserve Value", 0,
                                  0, 0);
                        end;
                    end;
                    #endregion OnAfterGetRecord
                }
                #endregion dataitems
            }
            #endregion dataitems

            // DataItem "Bonus Contract"
            #region OnPreDataItem
            trigger OnPreDataItem()
            begin
                Dialog.Open(CustomerProgressTxt + ContractProgressTxt);
                PostingDate := DateTo;
            end;
            #endregion OnPreDataItem

            #region OnAfterGetRecord
            trigger OnAfterGetRecord()
            var
                FindDocumentNos: Codeunit "lbtbn Find Document Nos.";
            begin
                Dialog.Update(1, "No. of Customers");
                Dialog.Update(2, "No.");

                if not CheckDates() then
                    CurrReport.Skip();
                FindDocumentNos.FindDocumentNos("Bonus Contract"."No.", InvoiceNos, CrMemoNos, DateFrom, DateTo);

                "Bonus Contract"."Last Reserve at" := PostingDate;
                "Bonus Contract".Modify();
            end;
            #endregion OnAfterGetRecord

            #region OnPostDataItem
            trigger OnPostDataItem()
            begin
                Dialog.Close();
                Commit(); // after each Contract to not lose progress

                OpenPage();
            end;
            #endregion OnPostDataItem
        }
        #endregion dataitem
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
                    field("Date From"; DateFrom)
                    {
                        ApplicationArea = All;
                        Caption = 'Date from';
                        ToolTip = 'In consideration of the sart date, all invoice and credit lines of the period are used, which are additionally checked for relevance of the corresponding contract conditions (calculation rules).';
                    }
                    field("Date To"; DateTo)
                    {
                        ApplicationArea = All;
                        Caption = 'Date to';
                        ToolTip = 'In Consideration of the end date, all invoice and credit memo lines of the period are used, which are also checked for relevance of the corresponding contract conditions (calculation rules).';
                    }
                }
            }
        }
    }

    #region OnPreReport
    trigger OnPreReport()
    var
        GenJournalLine: Record "Gen. Journal Line";

    begin
        if (DateFrom = 0D) or (DateTo = 0D) then
            Error(InputAccountingPeriodMsg);
        if DateFrom > DateTo then
            Error(CheckAccountingPeriodMsg);
        BonusSetup.Get();
        if BonusSetup."Reserve Mode" = BonusSetup."Reserve Mode"::CreditMemo then begin
            // BonusSetup.TestField("Customer Reserve Cr.Memo")
            ;
            ;
        end
        else begin
            BonusSetup.TestField("Gen.Jnl.Templ.BonusReserve");
            BonusSetup.TestField("Gen. Jnl. Bonus Reserve");
        end;
        GenJournalLine.Reset();
        GenJournalLine.SetRange("Journal Template Name", BonusSetup."Gen.Jnl.Templ.BonusReserve");
        GenJournalLine.SetRange("Journal Batch Name", BonusSetup."Gen. Jnl. Bonus Reserve");
        if GenJournalLine.FindLast() then
            LineNo := GenJournalLine."Line No."
        else
            LineNo := 0;
    end;
    #endregion OnPreReport

    var
        I: Interface "lbtbn I";
        BonusSetup: Record "lbtbn Bonus Setup";
        SalesHeader: Record "Sales Header";
        BonusManagement: Codeunit "lbtbn Bonus Management";
        CheckItemMeth: Codeunit "lbtbn CheckItem Meth";
        CreateBonus: Codeunit "lbtbn Create Bonus";
        InvoiceNos: List of [Code[20]];
        CrMemoNos: List of [Code[20]];
        CrMemoHeaderCreated: Boolean;
        DateFrom: Date;
        DateTo: Date;
        PostingDate: Date;
        Dialog: Dialog;
        BonusEntryNo: Integer;
        LineNo: Integer;
        SalesLineNo: Integer;
        AccountingPeriodLbl: Label 'Accounting Period %1 to %2', Comment = '%1 from %2 to';
        BonusAccountingLbl: Label 'Bonus Accounting accordingly Bonus Contract %1.', Comment = '%1 No.';
        BonusReserveForLbl: Label 'Bonus Reserve for ';
        BonusReserveLbl: Label 'Bonus Reserve';
        CheckAccountingPeriodMsg: Label 'Please check the accounting period.';
        ContractProgressTxt: Label 'Contract   #2##############', Comment = '%1 No.';
        CustomerProgressTxt: Label 'Customer #1##############\', Comment = '%1 No.';
        InputAccountingPeriodMsg: Label 'Please input the accounting period.';
        UnpostedCreditMemoErr: Label 'There is an unposted credit memo for bonus reserve.\\Please post or delete it at first.',
            Comment = 'DEU="Es existiert eine ungebuchte Gutschrift zur Bonusrückstellung.\\Diese muss erst gebucht oder gelöscht werden."';

    #region AddItemChargeToSalesLine
    local procedure AddItemChargeToSalesLine(var SalesLine: Record "Sales Line"; DocAmount: Decimal; BonusAmount: Decimal)
    var
        ItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)";
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemChargeAssignmentSales.Init();
        ItemChargeAssignmentSales."Document Type" := SalesLine."Document Type";
        ItemChargeAssignmentSales."Document No." := SalesLine."Document No.";
        ItemChargeAssignmentSales."Document Line No." := SalesLine."Line No.";
        ItemChargeAssignmentSales."Line No." := 10000;
        ItemChargeAssignmentSales."Item Charge No." := SalesLine."No.";

        ItemChargeAssignmentSales."Applies-to Doc. Type" := I.GetAppliesToDocType();
        ItemChargeAssignmentSales."Applies-to Doc. Line Amount" := DocAmount;
        ItemLedgerEntry := GetItemLedgerEntry();
        ItemChargeAssignmentSales."Applies-to Doc. No." := ItemLedgerEntry."Document No.";
        ItemChargeAssignmentSales."Applies-to Doc. Line No." := ItemLedgerEntry."Document Line No.";
        ItemChargeAssignmentSales."Unit Cost" := BonusAmount;
        ItemChargeAssignmentSales.Validate("Qty. to Assign", 1);
        ItemChargeAssignmentSales.Insert();
    end;
    #endregion AddItemChargeToSalesLine

    #region CalcFromCrMemo
    local procedure CalcFromCrMemo(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesCrLine: Codeunit "lbtbn Sales Cr.Line";
    begin
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
        if SalesCrMemoLine.FindSet() then
            repeat
                I := SalesCrLine;
                SalesCrLine.SetLine(SalesCrMemoLine);
                if CheckItemMeth.CheckItem("Bonus Contract"."No.", SalesCrMemoLine."No.") then
                    case "Bonus Contract"."Reserve Type" of
                        "Bonus Contract"."Reserve Type"::"%":
                            CalcPercentage(
                                            SalesCrMemoHeader."Currency Factor");
                        "Bonus Contract"."Reserve Type"::"Amount per Unit":
                            CalcPerUnit();
                    end;
            until SalesCrMemoLine.Next() = 0;
    end;
    #endregion CalcFromCrMemo

    #region CalcFromSalesInvoice
    local procedure CalcFromSalesInvoice(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesInvoiceLineCU: Codeunit "lbtbn Sales Invoice Line";
    begin

        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
        if SalesInvoiceLine.FindSet() then
            repeat
                I := SalesInvoiceLineCU;
                SalesInvoiceLineCU.SetLine(SalesInvoiceLine);
                if CheckItemMeth.CheckItem("Bonus Contract"."No.", SalesInvoiceLine."No.") then
                    case "Bonus Contract"."Reserve Type" of
                        "Bonus Contract"."Reserve Type"::"%":
                            CalcPercentage(
                                            SalesInvoiceHeader."Currency Factor");
                        "Bonus Contract"."Reserve Type"::"Amount per Unit":
                            CalcPerUnit();
                    end;
            until SalesInvoiceLine.Next() = 0;
    end;
    #endregion CalcFromSalesInvoice

    #region CalcPercentage
    local procedure CalcPercentage(CurrencyFactor: Decimal)
    var
        BonusAmt: Decimal;
        DiscAmt: Decimal;
        DocAmount: Decimal;
        PmtDiscAmt: Decimal;
    begin
        DocAmount := I.GetAmount();
        if CurrencyFactor <> 0 then
            DocAmount := Round(DocAmount / CurrencyFactor, 0.01);

        CreateBonus.UpdateDocAmountFromValueEntry(I, DocAmount);

        PmtDiscAmt := DocAmount * "Bonus Contract"."Pmt. Discount %" / 100;
        DiscAmt := (DocAmount - PmtDiscAmt) * "Bonus Contract"."Discount %" / 100;
        BonusAmt := Round("Bonus Contract"."Reserve Value" * (DocAmount - DiscAmt - PmtDiscAmt) / 100, 0.01);

        if BonusAmt = 0 then
            exit;

        if BonusSetup."Reserve Mode" = BonusSetup."Reserve Mode"::CreditMemo then
            CreateForReserveMode_CreditMemo(0, BonusAmt, PmtDiscAmt, DocAmount, DiscAmt)
        else
            CreateJournalLine(

                            BonusAmt, DocAmount,
                            -DiscAmt, -PmtDiscAmt);
    end;
    #endregion CalcPercentage

    #region CalcPerUnit
    local procedure CalcPerUnit()
    var
        BonusAmt: Decimal;
        Quantity: Decimal;
    begin
        Quantity := I.Quantity();
        BonusAmt := Round(Quantity * "Bonus Contract"."Reserve Value", 0.01);
        if BonusAmt = 0 then
            exit;

        BonusAmt *= I.Sign();

        if BonusSetup."Reserve Mode" = BonusSetup."Reserve Mode"::CreditMemo then
            CreateForReserveMode_CreditMemo(Quantity, BonusAmt, 0, 0, 0)
        else
            CreateJournalLine(BonusAmt, 0, 0, 0);
    end;
    #endregion CalcPerUnit

    // local procedure FindQuantity(quantity: decimal): Decimal
    // begin
    //     //TODO: implementation
    //     // PostDocItemUnitRec.Reset;
    //     // PostDocItemUnitRec.SetRange("Table ID", Database::"Sales Invoice Line");
    //     // PostDocItemUnitRec.SetRange("Document No.", PostedSalesInvLineRec."Document No.");
    //     // PostDocItemUnitRec.SetRange("Document Line No.", PostedSalesInvLineRec."Line No.");
    //     // PostDocItemUnitRec.SetRange("Item Unit", "Bonus Contract"."Unit Reserves Base");

    //     // if PostDocItemUnitRec.FindFirst() then
    //     //   exit(PostDocItemUnitRec.Quantity)
    //     exit(quantity);
    // end;

    #region CheckDates
    local procedure CheckDates(): Boolean
    begin
        if (PostingDate < "Bonus Contract"."Valid from") or (("Bonus Contract"."Valid to" <> 0D) and (PostingDate > "Bonus Contract"."Valid to")) then
            exit(false);

        if "Bonus Contract"."Last Reserve at" >= DateFrom then
            exit(false);
        exit(true);
    end;
    #endregion CheckDates

    #region CreateBonusCrMemoLine
    local procedure CreateBonusCrMemoLine(BonusAmt: Decimal; var SalesLine: Record "Sales Line")
    var
        DimensionManagement: Codeunit DimensionManagement;
    begin
        CreateCrMemoHeader();

        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLineNo += 10000;
        SalesLine."Line No." := SalesLineNo;
        SalesLine.Validate(Type, SalesLine.Type::"Charge (Item)");
        SalesLine.Validate("No.", "Bonus Contract"."Reserve Item Charge");
        SalesLine.Validate("Unit Price", BonusAmt);
        SalesLine.Validate(Quantity, 1);
        SalesLine."Shipment Date" := WorkDate();
        SalesLine."Allow Invoice Disc." := true;
        SalesLine.Description := BonusReserveForLbl;
        SalesLine.Description += I.GetDescription();
        SalesLine."lbt Process No." := "Bonus Contract"."Process No.";
        SalesLine."Dimension Set ID" := I.GetDimensionSetId();
        DimensionManagement.UpdateGlobalDimFromDimSetID(SalesLine."Dimension Set ID", SalesLine."Shortcut Dimension 1 Code", SalesLine."Shortcut Dimension 2 Code");
        if SalesHeader."Shortcut Dimension 1 Code" <> '' then
            SalesLine.Validate("Shortcut Dimension 1 Code", SalesHeader."Shortcut Dimension 1 Code");
        SalesLine.Insert();
    end;
    #endregion CreateBonusCrMemoLine

    #region CreateBonusEntryForFixedAmount
    local procedure CreateBonusEntryForFixedAmount(var SalesLine: Record "Sales Line")
    begin
        BonusManagement.SetBonusDoc(2, SalesLine."Document No.", SalesLine."Line No.");
        BonusEntryNo := BonusManagement.CreateBonusContractEntry(
                                   "Bonus Contract",
                                   "Bonus Customer",
                                   1, PostingDate, 0,
                                   0, SalesLine.Amount, 0,
                                   SalesLine.Amount,
                                   0, 0);
        SalesLine."lbt Process No." := "Bonus Contract"."Process No.";
        SalesLine."lbtbn Bonus Entry No." := BonusEntryNo;
        SalesLine.Modify();
    end;
    #endregion CreateBonusEntryForFixedAmount

    #region CreateCrMemoHeader
    local procedure CreateCrMemoHeader()
    var
        SalesLine: Record "Sales Line";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        if CrMemoHeaderCreated then
            exit;

        SalesHeader.Reset();
        SalesHeader.SetCurrentKey("Document Type", "Sell-to Customer No.");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Credit Memo");
        SalesHeader.SetRange("Sell-to Customer No.", "Bonus Contract"."Customer Reserve Cr.Memo");
        SalesHeader.SetRange("Posting Description", BonusReserveLbl);
        if SalesHeader.FindFirst() then
            Error(UnpostedCreditMemoErr);

        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::"Credit Memo";
        SalesHeader."No. Series" := BonusSetup."Reserve Cr.Memo Nos.";
        SalesHeader."Posting No. Series" := BonusSetup."Reserve Cr.Memo Nos.";
        SalesHeader."Shipping No. Series" := BonusSetup."Reserve Cr.Memo Nos.";
        SalesHeader."Return Receipt No. Series" := BonusSetup."Reserve Cr.Memo Nos.";
        SalesHeader."No." := NoSeriesManagement.GetNextNo(SalesHeader."No. Series", WorkDate(), true);
        SalesHeader.Insert(true);
        SalesHeader.SetHideValidationDialog(true);
        "Bonus Contract".TestField("Customer Reserve Cr.Memo");
        SalesHeader.Validate("Sell-to Customer No.", "Bonus Contract"."Customer Reserve Cr.Memo");
        // Validate("Gen. Bus. Posting Group", BonusSetupRec."Bus.Post.Gr.f.Res.Cr.Memo");
        // Validate("Customer Posting Group", BonusSetupRec."Cust Gr. Reserve Cr. Memo");
        SalesHeader."Posting Description" := BonusReserveLbl;
        PostingDate := DateTo;
        SalesHeader."lbt Process No." := "Bonus Contract"."Process No.";
        SalesHeader.Modify();

        CrMemoHeaderCreated := true;

        SalesLineNo := 10000;
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := SalesLineNo;
        SalesLine.Description := StrSubstNo(BonusAccountingLbl, "Bonus Contract"."No.");
        SalesLine.Insert();

        SalesLineNo += 10000;
        SalesLine."Line No." := SalesLineNo;
        SalesLine.Description := StrSubstNo(AccountingPeriodLbl, DateFrom, DateTo);
        SalesLine.Insert();
    end;
    #endregion CreateCrMemoHeader

    #region CreateDimSetID
    local procedure CreateDimSetID(): Integer
    var
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        BonusContractDimensions: Record "lbtbn Bonus Contract Dimension";
        DimensionManagement: Codeunit DimensionManagement;
    begin
        BonusContractDimensions.SetRange(Contract, "Bonus Contract"."No.");
        if BonusContractDimensions.FindSet() then
            repeat
                TempDimensionSetEntry.Init();
                TempDimensionSetEntry."Dimension Code" := BonusContractDimensions."Dimension Code";
                TempDimensionSetEntry.Validate("Dimension Value Code", BonusContractDimensions."Dimension Value");
                if TempDimensionSetEntry.Insert() then;
            until BonusContractDimensions.Next() = 0;

        exit(DimensionManagement.GetDimensionSetID(TempDimensionSetEntry));
    end;
    #endregion CreateDimSetID

    #region CreateForReserveMode_CreditMemo
    local procedure CreateForReserveMode_CreditMemo(Qty: Decimal; BonusAmt: Decimal; PmtDiscAmt: Decimal; DocAmount: Decimal; DiscAmt: Decimal)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        SalesLine: Record "Sales Line";
        ValueEntry: Record "Value Entry";
    begin
        "Bonus Contract".TestField("Reserve Item Charge");
        ValueEntry.Reset();
        ValueEntry.SetCurrentKey("Document No.");
        I.ValueEntrySetRangeDocumentType(ValueEntry);
        if not ValueEntry.FindFirst() then
            exit;
        if not ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.") then
            exit;
        CreateBonusCrMemoLine(BonusAmt, SalesLine);
        AddItemChargeToSalesLine(SalesLine, DocAmount, BonusAmt);
        if I.GetShipmentDocType() = ItemLedgerEntry."Document Type" then begin
            Clear(BonusManagement);
            BonusManagement.SetAssignmentDoc(1, ItemLedgerEntry."Document No.", ItemLedgerEntry."Document Line No.");
            BonusManagement.SetSourceDoc(I);
            BonusManagement.SetBonusDoc(2, SalesLine."Document No.", SalesLine."Line No.");
            BonusEntryNo := BonusManagement.CreateBonusContractEntry(
                                "Bonus Contract",
                                "Bonus Customer",
                                1,
                                PostingDate,
                                0,
                                Qty, ////PostDocItemUnitRec.Quantity,
                                BonusAmt,
                                BonusAmt,
                                DocAmount,
                                -DiscAmt,
                                -PmtDiscAmt);
            SalesLine."lbtbn Bonus Entry No." := BonusEntryNo;
            SalesLine.Modify();
        end;
    end;
    #endregion CreateForReserveMode_CreditMemo

    #region CreateJournalLine
    local procedure CreateJournalLine(Amt: Decimal; DocAmt: Decimal; DiscAmount: Decimal; PmtDiscAmount: Decimal)
    var
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
        GenJournalLine: Record "Gen. Journal Line";
        DimensionManagement: Codeunit DimensionManagement;
    begin
        if not Customer.Get(I.CustNo()) then
            exit;
        if not CustomerPostingGroup.Get(Customer."Customer Posting Group") then
            exit;
        CustomerPostingGroup.TestField("lbtbn Reserve Account");
        CustomerPostingGroup.TestField("lbtbn Reserve Bal. Account");

        Clear(BonusManagement);
        BonusManagement.SetSourceDoc(I);
        BonusManagement.SetBonusDoc(0, '', 0);
        BonusEntryNo := BonusManagement.CreateBonusContractEntry(
            "Bonus Contract",
            "Bonus Customer",
            1,                //Postenart Rückstellung
            PostingDate,
            0,                //Bonusregelzeile
            0,                //Menge
            Amt,              //Betrag
            Amt,              //Betrag inkl. Vat
            DocAmt,         //Belegbetrag
            DiscAmount,
            PmtDiscAmount);

        GenJournalLine.Init();
        GenJournalLine."Journal Template Name" := BonusSetup."Gen.Jnl.Templ.BonusReserve";
        GenJournalLine."Journal Batch Name" := BonusSetup."Gen. Jnl. Bonus Reserve";
        GenJournalLine."Line No." := LineNo + 10000;
        LineNo := GenJournalLine."Line No.";
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine."Document No." := I.DocumentNo();
        GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
        GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
        GenJournalLine.Validate("Account No.", CustomerPostingGroup."lbtbn Reserve Account");
        GenJournalLine.Validate("Bal. Account No.", CustomerPostingGroup."lbtbn Reserve Bal. Account");
        GenJournalLine."Gen. Bus. Posting Group" := '';
        GenJournalLine."Gen. Prod. Posting Group" := '';
        GenJournalLine.Description := BonusReserveForLbl + Format("Bonus Contract"."No.");
        GenJournalLine.Validate(Amount, Amt);
        GenJournalLine."lbt Process No." := "Bonus Contract"."Process No.";
        GenJournalLine."lbtbn Bonus Entry No" := BonusEntryNo;
        GenJournalLine."Reason Code" := BonusSetup."Reason Code";
        GenJournalLine."Dimension Set ID" := I.GetDimensionSetId();
        if GenJournalLine."Dimension Set ID" = 0 then
            GenJournalLine."Dimension Set ID" := CreateDimSetID();
        DimensionManagement.UpdateGlobalDimFromDimSetID(GenJournalLine."Dimension Set ID",
                                             GenJournalLine."Shortcut Dimension 1 Code",
                                              GenJournalLine."Shortcut Dimension 2 Code");
        GenJournalLine.Insert();
    end;
    #endregion CreateJournalLine

    // local procedure getTotalAmount(): Decimal
    // var
    //     BonusCust: Record "lbtbn Bonus Customers";
    //     ContractTotalAmt: Decimal;
    // begin
    //     ContractTotalAmt := 0;
    //     BonusCust.Reset();
    //     BonusCust.SetRange("Contract", "Bonus Contract"."Contract");
    //     if BonusCust.FindSet() then
    //         Repeat
    //             SalesShipmentLineRec.Reset();
    //             SalesShipmentLineRec.SetRange("Sell-to Customer No.", BonusCust."Customer");
    //             SalesShipmentLineRec.SetRange("Posting Date", DateFrom, DateTo);
    //             SalesShipmentLineRec.SetRange(Type, SalesShipmentLineRec.Type::Item);
    //             SalesShipmentLineRec.SetFilter(Quantity, '<>%1', 0);
    //             SalesShipmentLineRec.SetFilter("Unit Price", '<>%1', 0);
    //             if SalesShipmentLineRec.FindSet() then
    //                 Repeat
    //                     SalesShipmentHeaderRec.Get(SalesShipmentLineRec."Document No.");
    //                     if SalesShipmentHeaderRec."Currency Code" = '' then
    //                         ContractTotalAmt += SalesShipmentLineRec."Item Charge Base Amount"
    //                     else
    //                         ContractTotalAmt += Round(SalesShipmentLineRec."Item Charge Base Amount" / SalesShipmentHeaderRec."Currency Factor", 0.01);
    //                 until SalesShipmentLineRec.Next() = 0;
    //         until BonusCust.Next() = 0;
    //     Exit(ContractTotalAmt);
    // end;

    #region OpenPage
    local procedure OpenPage()
    var
        GenJournalLine: Record "Gen. Journal Line";
        PageManagement: Codeunit "Page Management";
    begin
        if not GuiAllowed then
            exit;
        case BonusSetup."Reserve Mode" of
            BonusSetup."Reserve Mode"::CreditMemo:
                begin
                    if not CrMemoHeaderCreated then
                        exit;
                    PageManagement.PageRun(SalesHeader);
                end;
            BonusSetup."Reserve Mode"::Journal:
                begin
                    GenJournalLine.SetRange("Journal Batch Name", BonusSetup."Gen. Jnl. Bonus Reserve");
                    GenJournalLine.SetRange("Journal Template Name", BonusSetup."Gen.Jnl.Templ.BonusReserve");
                    if GenJournalLine.FindFirst() then
                        PageManagement.PageRun(GenJournalLine);
                end;
        end;
    end;
    #endregion OpenPage
    local procedure GetItemLedgerEntry() ItemLedgerEntry: Record "Item Ledger Entry"
    var
        ValueEntry: Record "Value Entry";
    begin
        I.ValueEntrySetRangeDocumentType(ValueEntry);
        ValueEntry.FindFirst();
        ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.");
    end;

}
