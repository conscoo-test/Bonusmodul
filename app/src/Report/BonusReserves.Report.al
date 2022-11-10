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

            #region dataitem
            dataitem("Bonus Customer"; "lbtbn Bonus Customer")
            {
                DataItemLink = Contract = field("No.");
                DataItemTableView = sorting(Contract, "Customer No.", "Ship-to Code");

                #region dataitems
                dataitem(Customer; Customer)
                {
                    #region dataitems
                    dataitem("Sales Invoice Header"; "Sales Invoice Header")
                    {
                        DataItemLink = "Sell-to Customer No." = field("No.");
                        DataItemTableView = sorting("Sell-to Customer No.", "Posting Date");

                        #region OnPreDataItem
                        trigger OnPreDataItem()
                        begin
                            if "Bonus Contract"."Reserve Type" = "Bonus Contract"."Reserve Type"::"Amount (LCY)" then
                                CurrReport.Break();

                            SetRange("Posting Date", DateFrom, DateTo);
                            PostingDate := DateTo;
                            if "Bonus Customer"."Ship-to Code" <> '' then
                                SetRange("Ship-to Code", "Bonus Customer"."Ship-to Code")
                            else
                                SetRange("Ship-to Code");
                        end;
                        #endregion OnPreDataItem

                        #region OnAfterGetRecord
                        trigger OnAfterGetRecord()
                        begin
                            CalcFromSalesInvoice();
                        end;
                        #endregion OnAfterGetRecord
                    }
                    dataitem("Sales Cr.Memo Header"; "Sales Cr.Memo Header")
                    {
                        DataItemLink = "Sell-to Customer No." = field("No.");
                        DataItemTableView = sorting("Sell-to Customer No.", "Posting Date");

                        #region OnPreDataItem
                        trigger OnPreDataItem()
                        begin
                            if "Bonus Contract"."Reserve Type" = "Bonus Contract"."Reserve Type"::"Amount (LCY)" then
                                CurrReport.Break();

                            SetRange("Posting Date", DateFrom, DateTo);
                            if "Bonus Customer"."Ship-to Code" <> '' then
                                SetRange("Ship-to Code", "Bonus Customer"."Ship-to Code")
                            else
                                SetRange("Ship-to Code");
                        end;
                        #endregion OnPreDataItem

                        #region OnAfterGetRecord
                        trigger OnAfterGetRecord()
                        begin
                            CalcFromCrMemo();
                        end;
                        #endregion OnAfterGetRecord
                    }
                    #endregion dataitems

                    #region OnPreDataItem
                    trigger OnPreDataItem()
                    begin
                        if "Bonus Customer"."Customer Group" <> '' then
                            Customer.SetRange("lbtbn Customer Group", "Bonus Customer"."Customer Group");
                        if "Bonus Customer"."Customer No." <> '' then
                            Customer.SetRange("No.", "Bonus Customer"."Customer Group");
                    end;
                    #endregion OnPreDataItem
                }
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
                    begin
                        case BonusSetup."Reserve Mode" of
                            BonusSetup."Reserve Mode"::CreditMemo:
                                begin
                                    CreateBonusCrMemoLine(0, '', "Bonus Contract"."Reserve Value", SalesLine);
                                    CreateBonusEntryForFixedAmount(SalesLine);
                                end;
                            BonusSetup."Reserve Mode"::Journal:
                                CreateJournalLine(0, "Bonus Contract"."No.", 0, "Bonus Customer"."Customer No.", "Bonus Contract"."Reserve Value", 0,
                                  0, 0);
                        end;
                    end;
                    #endregion OnAfterGetRecord
                }
                #endregion dataitems
            }
            #endregion dataitem

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
            begin
                Dialog.Update(1, "No. of Customers");
                Dialog.Update(2, "No.");

                if not CheckDates() then
                    CurrReport.Skip();

                "Last Reserve at" := PostingDate;
                Modify();
            end;
            #endregion OnAfterGetRecord

            #region OnPostDataItem
            trigger OnPostDataItem()
            begin
                Dialog.Close();
                Commit();

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
        BonusSetup: Record "lbtbn Bonus Setup";
        SalesHeader: Record "Sales Header";
        BonusManagement: Codeunit "lbtbn Bonus Management";
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
        CrMemoLbl: Label 'Credit Memo ';
        CustomerProgressTxt: Label 'Customer #1##############\', Comment = '%1 No.';
        FixedAmountLbl: Label 'Bonus Fixed Amount';
        InputAccountingPeriodMsg: Label 'Please input the accounting period.';
        InvoiceLbl: Label 'Invoice ';
        UnpostedCreditMemoErr: Label 'There is an unposted credit memo for bonus reserve.\\Please post or delete it at first.',
            Comment = 'DEU="Es existiert eine ungebuchte Gutschrift zur Bonusrückstellung.\\Diese muss erst gebucht oder gelöscht werden."';

    #region AddItemChargeToSalesLine
    local procedure AddItemChargeToSalesLine(var SalesLine: Record "Sales Line"; TableNo: Integer; DocNo: Code[20]; DocLineNo: Integer; DocAmount: Decimal; BonusAmount: Decimal)
    var
        ItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)";
    begin
        ItemChargeAssignmentSales.Init();
        ItemChargeAssignmentSales."Document Type" := SalesLine."Document Type";
        ItemChargeAssignmentSales."Document No." := SalesLine."Document No.";
        ItemChargeAssignmentSales."Document Line No." := SalesLine."Line No.";
        ItemChargeAssignmentSales."Line No." := 10000;
        ItemChargeAssignmentSales."Item Charge No." := SalesLine."No.";

        case TableNo of
            Database::"Sales Invoice Line":
                //begin TODO:
                // ItemChargeAssignmentSales."Item No." := PostedSalesInvLineRec."No.";
                // ItemChargeAssignmentSales.Description := PostedSalesInvLineRec.Description;
                ItemChargeAssignmentSales."Applies-to Doc. Type" := ItemChargeAssignmentSales."Applies-to Doc. Type"::Shipment;
            //end
            Database::"Sales Cr.Memo Line":
                //begin
                // ItemChargeAssignmentSales."Item No." := PostedCrMemoLineRec."No.";
                // ItemChargeAssignmentSales.Description := PostedCrMemoLineRec.Description;
                ItemChargeAssignmentSales."Applies-to Doc. Type" := ItemChargeAssignmentSales."Applies-to Doc. Type"::"Return Receipt";
        //end;
        end;
        ItemChargeAssignmentSales."Applies-to Doc. Line Amount" := DocAmount;
        ItemChargeAssignmentSales."Applies-to Doc. No." := DocNo;
        ItemChargeAssignmentSales."Applies-to Doc. Line No." := DocLineNo;
        ItemChargeAssignmentSales."Unit Cost" := 1;
        ItemChargeAssignmentSales.Validate("Qty. to Assign", BonusAmount);
        ItemChargeAssignmentSales.Insert();
    end;
    #endregion AddItemChargeToSalesLine

    #region CalcFromCrMemo
    local procedure CalcFromCrMemo()
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        SalesCrMemoLine.SetRange("Document No.", "Sales Cr.Memo Header"."No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
        if SalesCrMemoLine.FindSet() then
            repeat
                if "Bonus Contract".CheckAttributes(SalesCrMemoLine."No.") then
                    case "Bonus Contract"."Reserve Type" of
                        "Bonus Contract"."Reserve Type"::"%":
                            CalcPercentage(Database::"Sales Cr.Memo Line",
                                            SalesCrMemoLine."Document No.",
                                            SalesCrMemoLine."Line No.",
                                            SalesCrMemoLine.Amount,
                                            SalesCrMemoLine."Amount Including VAT");
                        "Bonus Contract"."Reserve Type"::"Amount per Unit":
                            CalcPerUnit(Database::"Sales Cr.Memo Line", SalesCrMemoLine."Document No.", SalesCrMemoLine."Line No.");
                    end;
            until SalesCrMemoLine.Next() = 0;
    end;
    #endregion CalcFromCrMemo

    #region CalcFromSalesInvoice
    local procedure CalcFromSalesInvoice()
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin

        SalesInvoiceLine.SetRange("Document No.", "Sales Invoice Header"."No.");
        SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
        if SalesInvoiceLine.FindSet() then
            repeat
                if "Bonus Contract".CheckAttributes(SalesInvoiceLine."No.") then
                    case "Bonus Contract"."Reserve Type" of
                        "Bonus Contract"."Reserve Type"::"%":
                            CalcPercentage(Database::"Sales Invoice Line",
                                            SalesInvoiceLine."Document No.",
                                            SalesInvoiceLine."Line No.",
                                            SalesInvoiceLine.Amount,
                                            SalesInvoiceLine."Amount Including VAT");
                        "Bonus Contract"."Reserve Type"::"Amount per Unit":
                            CalcPerUnit(Database::"Sales Invoice Line", SalesInvoiceLine."Document No.", SalesInvoiceLine."Line No.");
                    end;
            until SalesInvoiceLine.Next() = 0;
    end;
    #endregion CalcFromSalesInvoice

    #region CalcItemCharge
    local procedure CalcItemCharge(TableNo: Integer; p_LineNo: Integer; var DocAmtInclVAT: Decimal; var DocAmount: Decimal)
    var
        ItemCharge: Record "Item Charge";
        ItemLedgerEntry: Record "Item Ledger Entry";
        SalesInvoiceLine: Record "Sales Invoice Line";
        ValueEntry: Record "Value Entry";
        ValueEntry2: Record "Value Entry";
        l_Sign: Integer;
    begin
        ValueEntry.Reset();
        ValueEntry.SetCurrentKey("Document No.");
        case TableNo of
            Database::"Sales Invoice Line":
                begin
                    ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Invoice");
                    ValueEntry.SetRange("Document No.", "Sales Invoice Header"."No.");
                    l_Sign := 1;
                end;
            Database::"Sales Cr.Memo Line":
                begin
                    ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Credit Memo");
                    ValueEntry.SetRange("Document No.", "Sales Cr.Memo Header"."No.");
                    l_Sign := -1;
                end;
        end;
        ValueEntry.SetRange("Document Line No.", p_LineNo);
        if ValueEntry.FindSet() then
            repeat
                if ValueEntry."Sales Amount (Actual)" <> 0 then begin
                    if ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.") then
                        ValueEntry2.Reset();
                    ValueEntry2.SetCurrentKey("Item Ledger Entry No.");
                    ValueEntry2.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
                    ValueEntry2.SetFilter("Item Charge No.", '<>%1', '');
                    if ValueEntry2.FindSet() then
                        repeat
                            ItemCharge.Get(ValueEntry2."Item Charge No.");
                            if ItemCharge."lbtbn Bonus consider" then
                                DocAmount += l_Sign * ValueEntry2."Sales Amount (Actual)";
                            if SalesInvoiceLine.Get(ValueEntry2."Document No.", ValueEntry2."Document Line No.") then
                                DocAmtInclVAT += l_Sign * Round(ValueEntry2."Sales Amount (Actual)" *
                                          (100 + SalesInvoiceLine."VAT %") / 100, 0.0001)
                        until ValueEntry2.Next() = 0;
                end;
            until ValueEntry.Next() = 0;
    end;
    #endregion CalcItemCharge

    #region CalcPercentage
    local procedure CalcPercentage(TableNo: Integer; DocNo: Code[20]; DocLineNo: Integer; Amount: Decimal; AmtInclVat: Decimal)
    var
        BonusAmt: Decimal;
        DiscAmt: Decimal;
        DocAmount: Decimal;
        DocAmtInclVAT: Decimal;
        PmtDiscAmt: Decimal;
    begin
        if "Sales Invoice Header"."Currency Code" = '' then begin
            DocAmount := Amount;
            DocAmtInclVAT := AmtInclVat;
        end else begin
            DocAmount := Round(Amount / "Sales Invoice Header"."Currency Factor", 0.01);
            DocAmtInclVAT := Round(AmtInclVat / "Sales Invoice Header"."Currency Factor", 0.01);
        end;
        CalcItemCharge(TableNo, DocLineNo, DocAmtInclVAT, DocAmount);

        PmtDiscAmt := DocAmount * "Bonus Contract"."Pmt. Discount %" / 100;
        DiscAmt := (DocAmount - PmtDiscAmt) * "Bonus Contract"."Discount %" / 100;
        BonusAmt := Round("Bonus Contract"."Reserve Value" * (DocAmount - DiscAmt - PmtDiscAmt) / 100, 0.01);

        // Filter ItemLedgerEntry & ValueEntry

        if BonusAmt = 0 then
            exit;

        if BonusSetup."Reserve Mode" = BonusSetup."Reserve Mode"::CreditMemo then
            CreateForReserveMode_CreditMemo(TableNo, DocNo, DocLineNo, 0, BonusAmt, PmtDiscAmt, DocAmount, DiscAmt)
        else
            CreateJournalLine(TableNo, DocNo, DocLineNo,
                            "Bonus Customer"."Customer No.",
                            BonusAmt, DocAmount,
                            -DiscAmt, -PmtDiscAmt);
    end;
    #endregion CalcPercentage

    #region CalcPerUnit
    local procedure CalcPerUnit(TableNo: Integer; DocNo: Code[20]; DocLineNo: Integer)
    var
        BonusAmt: Decimal;
        Quantity: Decimal;
    begin
        Quantity := FindQuantity(TableNo, DocNo, DocLineNo);
        BonusAmt := Round(Quantity * "Bonus Contract"."Reserve Value", 0.01);
        if BonusAmt = 0 then
            exit;

        if BonusSetup."Reserve Mode" = BonusSetup."Reserve Mode"::CreditMemo then
            CreateForReserveMode_CreditMemo(TableNo, DocNo, DocLineNo, Quantity, BonusAmt, 0, 0, 0)
        else
            CreateJournalLine(TableNo, DocNo, DocLineNo, "Bonus Customer"."Customer No.", BonusAmt, 0, 0, 0);
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
    local procedure CreateBonusCrMemoLine(TableNo: Integer; DocNoP: Code[20]; BonusAmt: Decimal; var SalesLineRec: Record "Sales Line")
    begin
        CreateCrMemoHeader();

        SalesLineRec.Init();
        SalesLineRec."Document Type" := SalesHeader."Document Type";
        SalesLineRec."Document No." := SalesHeader."No.";
        SalesLineNo += 10000;
        SalesLineRec."Line No." := SalesLineNo;
        SalesLineRec.Validate(Type, SalesLineRec.Type::"Charge (Item)");
        SalesLineRec.Validate("No.", "Bonus Contract"."Reserve Item Charge");
        SalesLineRec.Validate("Unit Price", BonusAmt);
        SalesLineRec.Validate(Quantity, 1);
        SalesLineRec."Shipment Date" := WorkDate();
        SalesLineRec."Allow Invoice Disc." := true;
        SalesLineRec.Description := BonusReserveForLbl;
        case TableNo of
            Database::"Sales Invoice Line":
                SalesLineRec."Description 2" := InvoiceLbl + DocNoP;
            Database::"Sales Cr.Memo Line":
                SalesLineRec."Description 2" := CrMemoLbl + DocNoP;
            0:
                SalesLineRec."Description 2" := FixedAmountLbl;
        end;
        SalesLineRec."lbt Process No." := "Bonus Contract"."Process No.";
        //TODO:
        // if Sign = 1 then begin
        //     SalesLine."Shortcut Dimension 1 Code" := PostedSalesInvLineRec."Shortcut Dimension 1 Code";
        //     SalesLine."Shortcut Dimension 2 Code" := PostedSalesInvLineRec."Shortcut Dimension 2 Code";
        //     SalesLine."Dimension Set ID" := PostedSalesInvLineRec."Dimension Set ID";

        // end else begin
        //     SalesLine."Shortcut Dimension 1 Code" := PostedCrMemoLineRec."Shortcut Dimension 1 Code";
        //     SalesLine."Shortcut Dimension 2 Code" := PostedCrMemoLineRec."Shortcut Dimension 2 Code";
        //     CrMemoLSalesLineineRec."Dimension Set ID" := PostedCrMemoLineRec."Dimension Set ID";
        // end;
        if SalesHeader."Shortcut Dimension 1 Code" <> '' then
            SalesLineRec.Validate("Shortcut Dimension 1 Code", SalesHeader."Shortcut Dimension 1 Code");
        SalesLineRec.Insert();
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
        SalesHeader.Validate("Sell-to Customer No.", "Bonus Contract"."Customer Reserve Cr.Memo");
        // Validate("Gen. Bus. Posting Group", BonusSetupRec."Bus.Post.Gr.f.Res.Cr.Memo");
        // Validate("Customer Posting Group", BonusSetupRec."Cust Gr. Reserve Cr. Memo");
        SalesHeader."Posting Description" := BonusReserveLbl;
        PostingDate := 0D;
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
    local procedure CreateForReserveMode_CreditMemo(TableNo: Integer; DocNo: Code[20]; p_LineNo: Integer; Qty: Decimal; BonusAmt: Decimal; PmtDiscAmt: Decimal; DocAmount: Decimal; DiscAmt: Decimal)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        SalesLine: Record "Sales Line";
        ValueEntry: Record "Value Entry";
        DocTypeMatches: Boolean;
    begin
        "Bonus Contract".TestField("Reserve Item Charge");
        ValueEntry.Reset();
        ValueEntry.SetCurrentKey("Document No.");
        ValueEntry.SetRange("Document No.", DocNo);
        case TableNo of
            Database::"Sales Invoice Line":
                ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Invoice");
            Database::"Sales Cr.Memo Line":
                ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Credit Memo");
        end;
        ValueEntry.SetRange("Document Line No.", p_LineNo);
        if ValueEntry.FindFirst() then begin
            case TableNo of
                Database::"Sales Invoice Line":
                    DocTypeMatches := (ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Sales Shipment");
                Database::"Sales Cr.Memo Line":
                    DocTypeMatches := (ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Sales Return Receipt");
            end;
            CreateBonusCrMemoLine(TableNo, DocNo, BonusAmt, SalesLine);
            AddItemChargeToSalesLine(SalesLine, TableNo, DocNo, p_LineNo, DocAmount, BonusAmt);
            if ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.") and DocTypeMatches then begin
                Clear(BonusManagement);
                BonusManagement.SetAssignmentDoc(1, ItemLedgerEntry."Document No.", ItemLedgerEntry."Document Line No.");
                BonusManagement.SetSourceDoc(1, DocNo, p_LineNo);
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
    end;
    #endregion CreateForReserveMode_CreditMemo

    #region CreateJournalLine
    local procedure CreateJournalLine(TableID: Integer; DocNo: Code[20]; DocLineNo: Integer; CustNo: Code[20]; Amt: Decimal; DocAmt: Decimal; DiscAmount: Decimal; PmtDiscAmount: Decimal)
    var
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
        GenJournalLine: Record "Gen. Journal Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesInvoiceLine: Record "Sales Invoice Line";
        DimensionManagement: Codeunit DimensionManagement;

        DocType: Integer;
        vz: Integer;
    begin
        if Customer.Get(CustNo) then
            if CustomerPostingGroup.Get(Customer."Customer Posting Group") then begin
                CustomerPostingGroup.TestField("lbtbn Reserve Account");
                CustomerPostingGroup.TestField("lbtbn Reserve Bal. Account");
                DocType := 0;
                vz := 1;
                case TableID of
                    Database::"Sales Invoice Header", Database::"Sales Invoice Line":
                        DocType := 1;

                    Database::"Sales Cr.Memo Header", Database::"Sales Cr.Memo Line":
                        begin
                            DocType := 2;
                            vz := -1;
                        end;
                end;
                Clear(BonusManagement);
                BonusManagement.SetSourceDoc(DocType, DocNo, DocLineNo);
                BonusManagement.SetBonusDoc(0, '', 0);
                BonusEntryNo := BonusManagement.CreateBonusContractEntry(
                    "Bonus Contract",
                    "Bonus Customer",
                    1,                //Postenart Rückstellung
                    PostingDate,
                    0,                //Bonusregelzeile
                    0,                //Menge
                    Amt * vz,              //Betrag
                    Amt * vz,              //Betrag inkl. Vat
                    DocAmt * vz,         //Belegbetrag
                    DiscAmount * vz,
                    PmtDiscAmount * vz);

                GenJournalLine.Init();
                GenJournalLine."Journal Template Name" := BonusSetup."Gen.Jnl.Templ.BonusReserve";
                GenJournalLine."Journal Batch Name" := BonusSetup."Gen. Jnl. Bonus Reserve";
                GenJournalLine."Line No." := LineNo + 10000;
                LineNo := GenJournalLine."Line No.";
                GenJournalLine.Validate("Posting Date", PostingDate);
                GenJournalLine."Document No." := DocNo;
                GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
                GenJournalLine.Validate("Account No.", CustomerPostingGroup."lbtbn Reserve Account");
                GenJournalLine.Validate("Bal. Account No.", CustomerPostingGroup."lbtbn Reserve Bal. Account");
                GenJournalLine."Gen. Bus. Posting Group" := '';
                GenJournalLine."Gen. Prod. Posting Group" := '';
                GenJournalLine.Description := BonusReserveForLbl + Format("Bonus Contract"."No.");
                GenJournalLine.Validate(Amount, Amt * vz);
                GenJournalLine."lbt Process No." := "Bonus Contract"."Process No.";
                GenJournalLine."lbtbn Bonus Entry No" := BonusEntryNo;
                GenJournalLine."Reason Code" := BonusSetup."Reason Code";
                if (TableID <> 0) then
                    case TableID of
                        Database::"Sales Invoice Line":
                            begin
                                SalesInvoiceLine.Get(DocNo, DocLineNo);
                                GenJournalLine."Shortcut Dimension 1 Code" := SalesInvoiceLine."Shortcut Dimension 1 Code";
                                GenJournalLine."Shortcut Dimension 2 Code" := SalesInvoiceLine."Shortcut Dimension 2 Code";
                                GenJournalLine."Dimension Set ID" := SalesInvoiceLine."Dimension Set ID";
                            end;
                        Database::"Sales Cr.Memo Line":
                            begin
                                SalesCrMemoLine.Get(DocNo, DocLineNo);
                                GenJournalLine."Shortcut Dimension 1 Code" := SalesCrMemoLine."Shortcut Dimension 1 Code";
                                GenJournalLine."Shortcut Dimension 2 Code" := SalesCrMemoLine."Shortcut Dimension 2 Code";
                                GenJournalLine."Dimension Set ID" := SalesCrMemoLine."Dimension Set ID";
                            end;
                    end
                else begin
                    GenJournalLine."Dimension Set ID" := CreateDimSetID();
                    DimensionManagement.UpdateGlobalDimFromDimSetID(GenJournalLine."Dimension Set ID",
                                                         GenJournalLine."Shortcut Dimension 1 Code",
                                                          GenJournalLine."Shortcut Dimension 2 Code");
                end;
                GenJournalLine.Insert();
            end;
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

    #region FindQuantity
    local procedure FindQuantity(TableNo: Integer; DocNo: Code[20]; DocLineNo: Integer): Decimal
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        case TableNo of
            Database::"Sales Invoice Line":
                if SalesInvoiceLine.Get(DocNo, DocLineNo) then
                    exit(SalesInvoiceLine.Quantity);
            Database::"Sales Cr.Memo Line":
                if SalesCrMemoLine.Get(DocNo, DocLineNo) then
                    exit(SalesCrMemoLine.Quantity);
        end;
    end;
    #endregion FindQuantity

    #region OpenPage
    local procedure OpenPage()
    var
        GenJournalLine: Record "Gen. Journal Line";
        PageManagement: Codeunit "Page Management";
    begin
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
                    if GenJournalLine.FindFirst() then;
                    PageManagement.PageRun(GenJournalLine);
                end;
        end;
    end;
    #endregion OpenPage
}
