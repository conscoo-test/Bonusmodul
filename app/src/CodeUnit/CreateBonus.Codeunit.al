codeunit 5266060 "lbtbn Create Bonus"
{

    var
        BonusSetup: Record "lbtbn Bonus Setup";
        BonusContract: Record "lbtbn Bonus Contract";
        ItemLedgerEntry: Record "Item Ledger Entry";
        BonusContractLine: Record "lbtbn Bonus Contract Line";
        SalesHeader: Record "Sales Header";
        TempSalesInvoiceLine: Record "Sales Invoice Line" temporary;
        CheckItemMeth: Codeunit "lbtbn CheckItem Meth";
        PostingDate: Date;
        DateFrom: Date;
        DateTo: Date;
        CustomerNo: Code[20];
        ShipToCode: Code[10];
        CurrencyFactor: Decimal;
        SalesLineNo: Integer;
        Sign: Integer;
        SourceDocType: Enum "lbtbn Document Type";
        CrMemoHeaderCreated: Boolean;
        GenJournalLineCreated: Boolean;

    #region SetBonusContract
    procedure SetBonusContract(BonusContract2: Record "lbtbn Bonus Contract")
    begin
        BonusContract := BonusContract2;
    end;
    #endregion SetBonusContract

    #region SetBonusContractLine
    procedure SetBonusContractLine(BonusContractLine2: Record "lbtbn Bonus Contract Line")
    begin
        BonusContractLine := BonusContractLine2;
    end;
    #endregion SetBonusContractLine

    #region SetDocument
    procedure SetDocument(CustomerNo2: Code[20]; ShipToCode2: Code[10]; CurrencyFactor2: Decimal)
    begin
        CustomerNo := CustomerNo2;
        ShipToCode := ShipToCode2;
        CurrencyFactor := CurrencyFactor2;
    end;
    #endregion SetDocument

    #region SetGlobal
    procedure SetGlobal(PostingDate2: Date; DateFrom2: Date; DateTo2: Date; CheckItemMeth2: Codeunit "lbtbn CheckItem Meth")
    begin
        PostingDate := PostingDate2;
        DateFrom := DateFrom2;
        DateTo := DateTo2;
        CheckItemMeth := CheckItemMeth2;
    end;
    #endregion SetGlobal

    #region CreateBonus Invoice
    procedure CreateBonus(SalesInvoiceLine: Record "Sales Invoice Line")
    begin
        SetLine(SalesInvoiceLine);
        CreateBonus();
    end;
    #endregion CreateBonus Invoice

    #region CreateBonus
    [Obsolete('this procedure should be local')]
    procedure CreateBonus()
    var
        DocAmount: Decimal;
        DiscAmt: Decimal;
        PmtDiscAmt: Decimal;
        BonusAmount: Decimal;
    begin
        if not LineIsApplicableForBonus() then
            exit;
        DocAmount := Sign * GetDocAmount(TempSalesInvoiceLine.Amount);
        DocAmount += AddItemCharges();
        CalculateBonusAmount(BonusContract."Bonus Billing Type", DocAmount, BonusContractLine.Value, DiscAmt, PmtDiscAmt, BonusAmount, Sign * TempSalesInvoiceLine.Quantity);
        CreateBonusCreditMemoLine(DocAmount, BonusAmount, DiscAmt, PmtDiscAmt);
    end;
    #endregion CreateBonus

    #region CreateBonus Credit Memo
    procedure CreateBonus(SalesCrMemoLine: Record "Sales Cr.Memo Line")
    begin
        SetLine(SalesCrMemoLine);
        CreateBonus();
    end;
    #endregion CreateBonus Credit Memo

    #region GetDocAmount
    local procedure GetDocAmount(Amount: Decimal) DocAmount: Decimal
    begin
        if CurrencyFactor = 0 then
            DocAmount := Amount
        else
            DocAmount := Round(Amount / CurrencyFactor, 0.01);
    end;
    #endregion GetDocAmount

    [Obsolete('this procedure will be removed')]
    procedure CreateSalesCreditMemo3(DocAmt: Decimal; BonusSumme: Decimal; DiscAmount: Decimal; PmtDiscAmount: Decimal) Betrag: Decimal
    begin
        CreateBonusCreditMemoLine(DocAmt, BonusSumme, DiscAmount, PmtDiscAmount);
    end;

    #region CreateSalesCreditMemo3
    local procedure CreateBonusCreditMemoLine(DocAmt: Decimal; BonusSumme: Decimal; DiscAmount: Decimal; PmtDiscAmount: Decimal)
    var
        SalesLine: Record "Sales Line";
        DimMgt: Codeunit DimensionManagement;
    begin
        CreateSalesHeaderBilling();

        if BonusContract."Bonus Billing Type" = BonusContract."Bonus Billing Type"::"Amount (LCY)" then
            if SingleSalesLineExists() then
                exit;

        InitSalesLine(SalesLine);

        case BonusContract."Bonus Billing Type" of
            BonusContract."Bonus Billing Type"::"%",
            BonusContract."Bonus Billing Type"::"Amount per Unit":
                begin
                    SalesLine.Validate("Unit Price", BonusSumme);
                    SalesLine.Modify();
                    CreateItemCharge(DocAmt, BonusSumme, SalesLine);
                end;
            BonusContract."Bonus Billing Type"::"Amount (LCY)":
                CreateItemChargeForBillingTypeAmount(SalesLine);
        end;

        SalesLine."Description 2" := GetDescription2();
        SalesLine.Modify(true);

        SalesLine.UpdateAmounts();
        if BonusContract."Bonus Billing Type" = BonusContract."Bonus Billing Type"::"Amount (LCY)" then
            exit;

        SalesLine."lbtbn Bonus Entry No." := CreateBonusEntry(DocAmt, DiscAmount, PmtDiscAmount, SalesLine);

        DimMgt.UpdateGlobalDimFromDimSetID(SalesLine."Dimension Set ID",
                                             SalesLine."Shortcut Dimension 1 Code",
                                              SalesLine."Shortcut Dimension 2 Code");
        SalesLine.Modify(true);
    end;
    #endregion CreateSalesCreditMemo3

    #region GetOrCreateSalesHeader
    local procedure CreateSalesHeaderBilling()
    begin
        if CrMemoHeaderCreated then
            exit;

        BonusSetup.Get();
        InitSalesHeader(GetCustCode(), BonusSetup."Billing Cr.Memo Nos.", BonusCreditMemoLbl);
        CreateTextLine(StrSubstNo(BonusSettlementTxt, BonusContract."No."));
        CreateTextLine(StrSubstNo(AccountingPeriodTxt, DateFrom, DateTo));
    end;
    #endregion GetOrCreateSalesHeader

    #region GetCustCode
    local procedure GetCustCode(): Code[20]
    begin
        exit(BonusContract."Bonus Recipient");
    end;
    #endregion GetCustCode

    #region InitSalesLine
    local procedure InitSalesLine(var SalesLine: Record "Sales Line")
    var
        AccountingTxt: Label 'Bonus Accounting';
    begin
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";

        SalesLineNo += 10000;
        SalesLine."Line No." := SalesLineNo;
        SalesLine.Validate("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
        SalesLine.Insert(true);

        SalesLine.Validate(Type, SalesLine.Type::"Charge (Item)");
        SalesLine.Validate("No.", BonusContract."Accounting Item Charge");
        // SalesLine.VALIDATE("Location Code", VertriebEinrRec."Location Bonus Item");
        SalesLine.Validate(Quantity, 1);
        SalesLine."lbt Process No." := BonusContract."Process No.";
        SalesLine.Description := AccountingTxt;
        if BonusContract."Bonus Billing Type" <> BonusContract."Bonus Billing Type"::"Amount (LCY)" then
            SalesLine.Description += ' ' + Format(TempSalesInvoiceLine."Document No.");
        SalesLine."Dimension Set ID" := TempSalesInvoiceLine."Dimension Set ID";

        SalesLine.Modify();
    end;
    #endregion InitSalesLine

    local procedure GetDescription2() Description2: Text[50]
    var
        Zusatz: Text;
        FixedAmountTxt: Label 'Fixed Amount';
        AmountCust: Decimal;
        PerTxt: Label ' per ';
    begin
        case BonusContract."Bonus Billing Type" of
            BonusContract."Bonus Billing Type"::"%":
                Zusatz := Format(BonusContractLine.Value) + ' %';
            BonusContract."Bonus Billing Type"::"Amount (LCY)":
                Zusatz := FixedAmountTxt;
            BonusContract."Bonus Billing Type"::"Amount per Unit":
                begin
                    CalculateAmountCust(AmountCust);
                    Zusatz := Format(AmountCust) + PerTxt + Format(BonusContractLine."Item Unit of Measure");
                end;
        end;
        Description2 := ContractTxt + Format(BonusContract."No.") + ': ' + Zusatz;
    end;

    #region CreateItemChargeForBillingTypeAmount
    local procedure CreateItemChargeForBillingTypeAmount(var SalesLine: Record "Sales Line") Zusatz: Text
    var
        ItemChargeAssRec: Record "Item Charge Assignment (Sales)";
        PostedSalesShptLineRec: Record "Sales Shipment Line";
        AssignItemChargeSales: Codeunit "Item Charge Assgnt. (Sales)";
        AmountCust: Decimal;
        TotalQuantity: Decimal;
    begin
        CalculateAmountCust(AmountCust);
        PostedSalesShptLineRec.Reset();
        //PostedSalesShptLineRec.SETRANGE("Sell-to Customer No.","Bonus Contract".Customer);
        PostedSalesShptLineRec.SetRange("Sell-to Customer No.", CustomerNo);
        PostedSalesShptLineRec.SetRange("Posting Date", DateFrom, DateTo);
        PostedSalesShptLineRec.SetRange(Type, PostedSalesShptLineRec.Type::Item);
        PostedSalesShptLineRec.SetFilter(Quantity, '<>%1', 0);
        if not PostedSalesShptLineRec.FindFirst() then
            exit;
        ItemChargeAssRec."Document Type" := SalesLine."Document Type";
        ItemChargeAssRec."Document No." := SalesLine."Document No.";
        ItemChargeAssRec."Document Line No." := SalesLine."Line No.";
        ItemChargeAssRec."Unit Cost" := SalesLine."Unit Price";
        ItemChargeAssRec."Item Charge No." := SalesLine."No.";
        // ItemChargeAssRec."lbt Process No." := SalesLine."lbt Process No.";
        AssignItemChargeSales.CreateShptChargeAssgnt(PostedSalesShptLineRec, ItemChargeAssRec);
        TotalQuantity := 0;
        AssignItemChargeSales.AssignItemCharges(SalesLine, AmountCust, TotalQuantity, AssignItemChargeSales.AssignByAmountMenuText());
    end;
    #endregion CreateItemChargeForBillingTypeAmount

    #region CreateTextLine
    local procedure CreateTextLine(Description: Text[100])
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLineNo += 10000;
        SalesLine."Line No." := SalesLineNo;
        // TODO: Printoption
        SalesLine.Description := Description;
        SalesLine.Insert();
    end;
    #endregion CreateTextLine

    #region CreateBonusEntry
    local procedure CreateBonusEntry(DocAmt: Decimal; DiscAmount: Decimal; PmtDiscAmount: Decimal; var SalesLine: Record "Sales Line"): Integer
    var
        BonusMgt: Codeunit "lbtbn Bonus Management";
    begin
        Clear(BonusMgt);
        BonusMgt.SetAssignmentDoc(1, ItemLedgerEntry."Document No.", ItemLedgerEntry."Document Line No.");
        BonusMgt.SetSourceDoc(SourceDocType, TempSalesInvoiceLine."Document No.", TempSalesInvoiceLine."Line No.");
        BonusMgt.SetBonusDoc(2, SalesLine."Document No.", SalesLine."Line No.");
        exit(BonusMgt.CreateBonusContractEntry(
          BonusContract,
          CustomerNo,
          ShipToCode,
          0,                                          //Postenart Bonus
          PostingDate,
          BonusContractLine."Line No.",           //Bonusregelzeile
          SalesLine.Quantity,                //Menge
          SalesLine.Amount,                  //Betrag
          SalesLine."Amount Including VAT",  //Betrag inkl. Vat
          DocAmt,                             //Belegbetrag
          DiscAmount,
          PmtDiscAmount,
          SalesLine."Dimension Set ID"));
    end;
    #endregion CreateBonusEntry

    #region CalculateBonusAmount
    local procedure CalculateBonusAmount(BillingType: Enum "lbtbn Billing Type"; DocAmount: Decimal; BaseAmount: Decimal; var DiscAmt: Decimal; var PmtDiscAmt: Decimal; var BonusAmount: Decimal; Quantity: Decimal) NewQty: Decimal
    begin
        case BillingType of
            BillingType::"%":
                begin
                    PmtDiscAmt := DocAmount * BonusContract."Pmt. Discount %" / 100;
                    DiscAmt := (DocAmount - PmtDiscAmt) * BonusContract."Discount %" / 100;
                    BonusAmount := Round((DocAmount - PmtDiscAmt - DiscAmt) * BaseAmount / 100, 0.01);
                end;
            BillingType::"Amount (LCY)":
                ;
            BillingType::"Amount per Unit":
                begin
                    BonusAmount := Round(Quantity * BaseAmount, 0.01);
                    NewQty := Quantity;
                end;
        end;
    end;
    #endregion CalculateBonusAmount

    #region CheckValueEntry
    local procedure LineIsShipped(): Boolean
    var
        ValueEntry: Record "Value Entry";
    begin
        Filter(ValueEntry);
        if not ValueEntry.FindFirst() then exit(false);
        if not ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.") then exit(false);
        exit(Matches(ItemLedgerEntry));
    end;
    #endregion CheckValueEntry

    [Obsolete('this procedure will be removed')]
    procedure UpdateDocAmountFromValueEntry(var DocAmount: Decimal)
    begin
        AddItemCharges();
    end;

    #region AddItemCharges
    local procedure AddItemCharges() Result: Decimal
    var
        ValueEntry: Record "Value Entry";
    begin
        if TempSalesInvoiceLine.Type <> TempSalesInvoiceLine.Type::Item then
            exit;
        ValueEntry.Reset();
        ValueEntry.SetCurrentKey("Document No.");
        Filter(ValueEntry);
        if ValueEntry.FindSet() then
            repeat
                if ValueEntry."Sales Amount (Actual)" <> 0 then
                    Result += AddConsideredItemCharges(ValueEntry."Item Ledger Entry No.");
            until ValueEntry.Next() = 0;
    end;
    #endregion AddItemCharges


    #region CreateReserve
    procedure CreateReserve(SalesCrMemoLine: Record "Sales Cr.Memo Line")
    begin
        SetLine(SalesCrMemoLine);
        DoCreateReserve();
    end;
    #endregion CreateReserve

    #region CreateReserve
    procedure CreateReserve(SalesInvoiceLine: Record "Sales Invoice Line")
    begin
        SetLine(SalesInvoiceLine);
        DoCreateReserve();
    end;
    #endregion CreateReserve
    #region CreateJournalLine

    #region CreateJournalLine
    local procedure CreateJournalLine(Amt: Decimal; DocAmt: Decimal; DiscAmount: Decimal; PmtDiscAmount: Decimal)
    var
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
        GenJournalLine: Record "Gen. Journal Line";
        DimensionManagement: Codeunit DimensionManagement;
        BonusManagement: Codeunit "lbtbn Bonus Management";
        BonusEntryNo: Integer;
        LineNo: Integer;
    begin
        BonusSetup.Get();
        if not Customer.Get(CustomerNo) then
            exit;
        if not CustomerPostingGroup.Get(Customer."Customer Posting Group") then
            exit;
        CustomerPostingGroup.TestField("lbtbn Reserve Account");
        CustomerPostingGroup.TestField("lbtbn Reserve Bal. Account");

        Clear(BonusManagement);
        BonusManagement.SetSourceDoc(SourceDocType, TempSalesInvoiceLine."Document No.", TempSalesInvoiceLine."Line No.");
        BonusManagement.SetBonusDoc(0, '', 0);
        BonusEntryNo := BonusManagement.CreateBonusContractEntry(
            BonusContract,
            CustomerNo,
            ShipToCode,
            1,                //Postenart Rückstellung
            PostingDate,
            0,                //Bonusregelzeile
            0,                //Menge
            Amt,              //Betrag
            Amt,              //Betrag inkl. Vat
            DocAmt,         //Belegbetrag
            DiscAmount,
            PmtDiscAmount,
            TempSalesInvoiceLine."Dimension Set ID");

        GenJournalLine.Reset();
        GenJournalLine.SetRange("Journal Template Name", BonusSetup."Gen.Jnl.Templ.BonusReserve");
        GenJournalLine.SetRange("Journal Batch Name", BonusSetup."Gen. Jnl. Bonus Reserve");
        if GenJournalLine.FindLast() then
            LineNo := GenJournalLine."Line No."
        else
            LineNo := 0;

        GenJournalLine.Init();
        GenJournalLine."Journal Template Name" := BonusSetup."Gen.Jnl.Templ.BonusReserve";
        GenJournalLine."Journal Batch Name" := BonusSetup."Gen. Jnl. Bonus Reserve";
        GenJournalLine."Line No." := LineNo + 10000;
        LineNo := GenJournalLine."Line No.";
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine."Document No." := TempSalesInvoiceLine."Document No.";
        GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
        GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
        GenJournalLine.Validate("Account No.", CustomerPostingGroup."lbtbn Reserve Account");
        GenJournalLine.Validate("Bal. Account No.", CustomerPostingGroup."lbtbn Reserve Bal. Account");
        GenJournalLine."Gen. Bus. Posting Group" := '';
        GenJournalLine."Gen. Prod. Posting Group" := '';
        GenJournalLine.Description := BonusReserveForLbl + Format(BonusContract."No.");
        GenJournalLine.Validate(Amount, Amt);
        GenJournalLine."lbt Process No." := BonusContract."Process No.";
        GenJournalLine."lbtbn Bonus Entry No" := BonusEntryNo;
        GenJournalLine."Reason Code" := BonusSetup."Reason Code";
        GenJournalLine."Dimension Set ID" := TempSalesInvoiceLine."Dimension Set ID";
        DimensionManagement.UpdateGlobalDimFromDimSetID(GenJournalLine."Dimension Set ID",
                                             GenJournalLine."Shortcut Dimension 1 Code",
                                              GenJournalLine."Shortcut Dimension 2 Code");
        GenJournalLine.Insert();
        GenJournalLineCreated := true;
    end;
    #endregion CreateJournalLine
    #endregion CreateJournalLine

    #region CreateForReserveMode_CreditMemo
    local procedure CreateForReserveMode_CreditMemo(Qty: Decimal; ReserveAmount: Decimal; PmtDiscAmt: Decimal; DocAmount: Decimal; DiscAmt: Decimal)
    var
        SalesLine: Record "Sales Line";
        BonusManagement: Codeunit "lbtbn Bonus Management";
    begin
        BonusContract.TestField("Reserve Item Charge");
        CreateReserveCrMemoHeader();
        CreateReserveCreditMemoLine(ReserveAmount, SalesLine);
        AddItemChargeToSalesLine(SalesLine, DocAmount, ReserveAmount);
        BonusManagement.SetAssignmentDoc(1, ItemLedgerEntry."Document No.", ItemLedgerEntry."Document Line No.");
        BonusManagement.SetSourceDoc(SourceDocType, TempSalesInvoiceLine."Document No.", TempSalesInvoiceLine."Line No.");
        BonusManagement.SetBonusDoc(2, SalesLine."Document No.", SalesLine."Line No.");
        SalesLine."lbtbn Bonus Entry No." := BonusManagement.CreateBonusContractEntry(
                            BonusContract,
                            CustomerNo,
                            ShipToCode,
                            1,
                            PostingDate,
                            0,
                            Qty,
                            ReserveAmount,
                            ReserveAmount,
                            DocAmount,
                            -DiscAmt,
                            -PmtDiscAmt,
                            SalesLine."Dimension Set ID");
        SalesLine.Modify();
    end;
    #endregion CreateForReserveMode_CreditMemo

    #region AddItemChargeToSalesLine
    local procedure AddItemChargeToSalesLine(var SalesLine: Record "Sales Line"; DocAmount: Decimal; BonusAmount: Decimal)
    var
        ItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)";
        ItemLedgerEntryL: Record "Item Ledger Entry";
    begin
        ItemChargeAssignmentSales.Init();
        ItemChargeAssignmentSales."Document Type" := SalesLine."Document Type";
        ItemChargeAssignmentSales."Document No." := SalesLine."Document No.";
        ItemChargeAssignmentSales."Document Line No." := SalesLine."Line No.";
        ItemChargeAssignmentSales."Line No." := 10000;
        ItemChargeAssignmentSales."Item Charge No." := SalesLine."No.";

        ItemChargeAssignmentSales."Applies-to Doc. Type" := GetAppliesToDoctype();
        ItemChargeAssignmentSales."Applies-to Doc. Line Amount" := DocAmount;
        ItemLedgerEntryL := GetItemLedgerEntry();
        ItemChargeAssignmentSales."Applies-to Doc. No." := ItemLedgerEntryL."Document No.";
        ItemChargeAssignmentSales."Applies-to Doc. Line No." := ItemLedgerEntryL."Document Line No.";
        ItemChargeAssignmentSales."Item No." := ItemLedgerEntryL."Item No.";
        ItemChargeAssignmentSales.Description := ItemLedgerEntryL.Description;
        ItemChargeAssignmentSales."Unit Cost" := BonusAmount;
        ItemChargeAssignmentSales.Validate("Qty. to Assign", 1);
        ItemChargeAssignmentSales.Insert();
    end;
    #endregion AddItemChargeToSalesLine
    #region GetItemLedgerEntry
    local procedure GetItemLedgerEntry() ItemLedgerEntry: Record "Item Ledger Entry"
    var
        ValueEntry: Record "Value Entry";
    begin
        Filter(ValueEntry);
        ValueEntry.FindFirst();
        ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.");
    end;
    #endregion GetItemLedgerEntry

    #region CreateBonusCrMemoLine
    local procedure CreateReserveCreditMemoLine(BonusAmt: Decimal; var SalesLine: Record "Sales Line")
    var
        DimensionManagement: Codeunit DimensionManagement;
    begin
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLineNo += 10000;
        SalesLine."Line No." := SalesLineNo;
        SalesLine.Validate(Type, SalesLine.Type::"Charge (Item)");
        SalesLine.Validate("No.", BonusContract."Reserve Item Charge");
        SalesLine.Validate("Unit Price", BonusAmt);
        SalesLine.Validate(Quantity, 1);
        SalesLine."Shipment Date" := WorkDate();
        SalesLine."Allow Invoice Disc." := true;
        SalesLine.Description := BonusReserveForLbl;
        SalesLine.Description += GetDescription();
        SalesLine."lbt Process No." := BonusContract."Process No.";
        SalesLine."Dimension Set ID" := TempSalesInvoiceLine."Dimension Set ID";
        DimensionManagement.UpdateGlobalDimFromDimSetID(SalesLine."Dimension Set ID", SalesLine."Shortcut Dimension 1 Code", SalesLine."Shortcut Dimension 2 Code");
        if SalesHeader."Shortcut Dimension 1 Code" <> '' then
            SalesLine.Validate("Shortcut Dimension 1 Code", SalesHeader."Shortcut Dimension 1 Code");
        SalesLine.Insert();
    end;
    #endregion CreateBonusCrMemoLine

    #region CreateCrMemoHeader
    local procedure CreateReserveCrMemoHeader()
    begin
        if CrMemoHeaderCreated then
            exit;
        BonusSetup.Get();
        CheckUnpostedReserveCreditMemoExists();

        BonusContract.TestField("Customer Reserve Cr.Memo");
        InitSalesHeader(BonusContract."Customer Reserve Cr.Memo", BonusSetup."Reserve Cr.Memo Nos.", BonusReserveLbl);

        CreateTextLine(StrSubstNo(BonusAccountingLbl, BonusContract."No."));
        CreateTextLine(StrSubstNo(AccountingPeriodLbl, DateFrom, DateTo));
    end;
    #endregion CreateCrMemoHeader


    #region AddConsideredItemCharges
    [Obsolete('this procedure should be local')]
    procedure AddConsideredItemCharges(ItemLedgerEntryNo: Integer) AmountFromItemCharge: Decimal;
    var
        ItemCharge: Record "Item Charge";
        ValueEntry: Record "Value Entry";
    begin
        Filter(ValueEntry);
        ValueEntry.SetRange("Document Line No.");
        ValueEntry.SetCurrentKey("Item Ledger Entry No.");
        ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntryNo);
        ValueEntry.SetFilter("Item Charge No.", '<>%1', '');
        if ValueEntry.FindSet() then
            repeat
                ItemCharge.Get(ValueEntry."Item Charge No.");
                if ItemCharge."lbtbn Bonus consider" then
                    AmountFromItemCharge += ValueEntry."Sales Amount (Actual)";
            until ValueEntry.Next() = 0;
    end;
    #endregion AddConsideredItemCharges

    #region OpenPage
    [Obsolete('this procedure will be replaced by OpenPage')]
    procedure OpenPageReserve()
    var
        GenJournalLine: Record "Gen. Journal Line";
        PageManagement: Codeunit "Page Management";
    begin
        BonusSetup.Get();
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

    procedure OpenPage()
    var
        GenJournalLine: Record "Gen. Journal Line";
        PageManagement: Codeunit "Page Management";
    begin
        if not GuiAllowed then
            exit;
        BonusSetup.Get();
        if CrMemoHeaderCreated then
            PageManagement.PageRun(SalesHeader);
        if GenJournalLineCreated then begin
            GenJournalLine.SetRange("Journal Batch Name", BonusSetup."Gen. Jnl. Bonus Reserve");
            GenJournalLine.SetRange("Journal Template Name", BonusSetup."Gen.Jnl.Templ.BonusReserve");
            if GenJournalLine.FindFirst() then
                PageManagement.PageRun(GenJournalLine);
        end;
    end;

    #region OpenPageBonus

    [Obsolete('this procedure will be replaced by OpenPage')]
    procedure OpenPageBonus()
    var
        PageManagement: Codeunit "Page Management";
    begin
        if not CrMemoHeaderCreated then
            exit;
        PageManagement.PageRun(SalesHeader);
    end;
    #endregion OpenPageBonus


    #region CreateReserveFixed
    procedure CreateReserveFixed()
    var
        SalesLine: Record "Sales Line";
    begin
        BonusSetup.Get();
        case BonusSetup."Reserve Mode" of
            BonusSetup."Reserve Mode"::CreditMemo:
                begin
                    CreateReserveCrMemoHeader();
                    CreateReserveCreditMemoLine(BonusContract."Reserve Value", SalesLine);
                    CreateBonusEntryForFixedAmount(SalesLine);
                end;
            BonusSetup."Reserve Mode"::Journal:
                CreateJournalLine(BonusContract."Reserve Value", 0,
                  0, 0);
        end;
    end;
    #endregion CreateReserveFixed

    #region CreateBonusEntryForFixedAmount
    local procedure CreateBonusEntryForFixedAmount(var SalesLine: Record "Sales Line")
    var
        BonusManagement: Codeunit "lbtbn Bonus Management";
        BonusEntryNo: Integer;
    begin
        BonusManagement.SetBonusDoc(2, SalesLine."Document No.", SalesLine."Line No.");
        BonusEntryNo := BonusManagement.CreateBonusContractEntry(
                                   BonusContract,
                                   CustomerNo,
                                   ShipToCode,
                                   1, PostingDate, 0,
                                   0, SalesLine.Amount, 0,
                                   SalesLine.Amount,
                                   0, 0, SalesLine."Dimension Set ID");
        SalesLine."lbt Process No." := BonusContract."Process No.";
        SalesLine."lbtbn Bonus Entry No." := BonusEntryNo;
        SalesLine.Modify();
    end;
    #endregion CreateBonusEntryForFixedAmount

    #region CreateItemCharge
    local procedure CreateItemCharge(DocAmt: Decimal; BonusSumme: Decimal; var SalesLine: Record "Sales Line")
    var
        ItemChargeAssRec: Record "Item Charge Assignment (Sales)";
    begin
        ItemChargeAssRec.Init();
        ItemChargeAssRec."Document Type" := SalesLine."Document Type";
        ItemChargeAssRec."Document No." := SalesLine."Document No.";
        ItemChargeAssRec."Document Line No." := SalesLine."Line No.";
        ItemChargeAssRec."Line No." := 10000;
        ItemChargeAssRec."Item Charge No." := SalesLine."No.";

        ItemChargeAssRec."Applies-to Doc. Type" := GetAppliesToDoctype();
        ItemChargeAssRec."Applies-to Doc. Line Amount" := DocAmt;

        ItemChargeAssRec."Applies-to Doc. No." := ItemLedgerEntry."Document No.";
        ItemChargeAssRec."Applies-to Doc. Line No." := ItemLedgerEntry."Document Line No.";
        ItemChargeAssRec."Item No." := ItemLedgerEntry."Item No.";
        ItemChargeAssRec.Description := ItemLedgerEntry.Description;

        ItemChargeAssRec."Unit Cost" := BonusSumme;
        ItemChargeAssRec.Validate("Qty. to Assign", 1);
        ItemChargeAssRec.Insert();
    end;
    #endregion CreateItemCharge

    procedure BelongsToSameDocument(): Boolean
    var
        ValueEntry: Record "Value Entry";
    begin
        Filter(ValueEntry);
        if ValueEntry.FindFirst() then begin
            ValueEntry.SetRange("Item Ledger Entry No.", ValueEntry."Item Ledger Entry No.");
            ValueEntry.SetFilter("Document Line No.", '<>%1', ValueEntry."Document Line No.");
            ValueEntry.SetRange("Item Charge No.", '');
            exit(not ValueEntry.IsEmpty);
        end;
    end;

    #region DoCreateReserve
    local procedure DoCreateReserve()
    var
        ReserveAmount: Decimal;
        DiscAmt: Decimal;
        DocAmount: Decimal;
        PmtDiscAmt: Decimal;
        NewQty: Decimal;
    begin
        if not LineIsApplicableForBonus() then
            exit;
        DocAmount := Sign * GetDocAmount(TempSalesInvoiceLine.Amount);
        DocAmount += AddItemCharges();

        NewQty := CalculateBonusAmount(BonusContract."Reserve Type", DocAmount, BonusContract."Reserve Value", DiscAmt, PmtDiscAmt, ReserveAmount, Sign * TempSalesInvoiceLine.Quantity);

        if ReserveAmount = 0 then
            exit;
        BonusSetup.Get();
        if BonusSetup."Reserve Mode" = BonusSetup."Reserve Mode"::CreditMemo then
            CreateForReserveMode_CreditMemo(NewQty, ReserveAmount, PmtDiscAmt, DocAmount, DiscAmt)
        else
            CreateJournalLine(ReserveAmount, DocAmount, -DiscAmt, -PmtDiscAmt);
    end;
    #endregion DoCreateReserve

    #region CalculateAmountCust
    local procedure CalculateAmountCust(var AmountCust: Decimal)
    var
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        CustRec: Record Customer;
    begin
        CustRec.Get(CustomerNo);
        if CustRec."Currency Code" = '' then
            AmountCust := BonusContractLine.Value
        else
            if Currency.Get(CustRec."Currency Code") then begin
                Currency.TestField("Unit-Amount Rounding Precision");
                AmountCust :=
                  Round(
                   CurrExchRate.ExchangeAmtLCYToFCY(
                    PostingDate, CustRec."Currency Code", BonusContractLine.Value,
                     CurrExchRate.ExchangeRate(PostingDate, CustRec."Currency Code")),
                      Currency."Unit-Amount Rounding Precision");
            end;
    end;
    #endregion CalculateAmountCust

    #region Matches
    local procedure Matches(var l_ItemLedgerEntry: Record "Item Ledger Entry"): Boolean
    begin
        case Sign of
            1:
                exit(l_ItemLedgerEntry."Document Type" = l_ItemLedgerEntry."Document Type"::"Sales Shipment");
            -1:
                exit(l_ItemLedgerEntry."Document Type" = l_ItemLedgerEntry."Document Type"::"Sales Return Receipt");
        end;
    end;
    #endregion Matches

    #region GetAppliesToDoctype
    local procedure GetAppliesToDoctype() DocumentType: Enum "Sales Applies-to Document Type"
    begin
        case Sign of
            1:
                exit(DocumentType::Shipment);
            -1:
                exit(DocumentType::"Return Receipt");
        end;
    end;
    #endregion GetAppliesToDoctype

    #region GetDescription
    local procedure GetDescription(): Text[100]
    var
        CrMemoLbl: Label 'Credit Memo ';
        InvoiceLbl: Label 'Invoice ';
    begin
        case Sign of
            1:
                exit(' ' + InvoiceLbl + TempSalesInvoiceLine."Document No.");
            -1:
                exit(' ' + CrMemoLbl + TempSalesInvoiceLine."Document No.");
        end;
    end;
    #endregion GetDescription

    #region SetLine
    local procedure SetLine(var SalesCrMemoLine: Record "Sales Cr.Memo Line")
    begin
        TempSalesInvoiceLine.TransferFields(SalesCrMemoLine);
        Sign := -1;
        SourceDocType := SourceDocType::"Sales Credit Memo";
    end;
    #endregion SetLine

    #region SetLine
    local procedure SetLine(var SalesInvoiceLine: Record "Sales Invoice Line")
    begin
        TempSalesInvoiceLine.TransferFields(SalesInvoiceLine);
        Sign := 1;
        SourceDocType := SourceDocType::"Sales Invoice";
    end;
    #endregion SetLine

    #region Filter
    local procedure Filter(var ValueEntry: Record "Value Entry")
    begin
        case Sign of
            1:
                ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Invoice");
            -1:
                ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Credit Memo");
        end;
        ValueEntry.SetRange("Document No.", TempSalesInvoiceLine."Document No.");
        ValueEntry.SetRange("Document Line No.", TempSalesInvoiceLine."Line No.");
    end;
    #endregion Filter

    #region InitSalesHeader
    local procedure InitSalesHeader(CustNo: Code[20]; NoSeries: Code[20]; PostingDescription: Text[100])
    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::"Credit Memo";
        SalesHeader."No. Series" := NoSeries;
        SalesHeader."Posting No. Series" := NoSeries;
        SalesHeader."Shipping No. Series" := NoSeries;
        SalesHeader."Return Receipt No. Series" := NoSeries;
        SalesHeader."No." := NoSeriesManagement.GetNextNo(SalesHeader."No. Series", WorkDate(), true);
        SalesHeader.Insert(true);
        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.Validate("Sell-to Customer No.", CustNo);
        SalesHeader."Document Date" := PostingDate;
        SalesHeader."Posting Description" := PostingDescription;
        SalesHeader."lbt Process No." := BonusContract."Process No.";
        SalesHeader."Posting No." := SalesHeader."No.";
        SalesHeader.Modify();
        CrMemoHeaderCreated := true;
        SalesLineNo := 10000;
    end;
    #endregion InitSalesHeader

    #region CheckUnpostedReserveCreditMemoExists
    local procedure CheckUnpostedReserveCreditMemoExists()
    begin
        SalesHeader.Reset();
        SalesHeader.SetCurrentKey("Document Type", "Sell-to Customer No.");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Credit Memo");
        SalesHeader.SetRange("Sell-to Customer No.", BonusContract."Customer Reserve Cr.Memo");
        SalesHeader.SetRange("Posting Description", BonusReserveLbl);
        if SalesHeader.FindFirst() then
            Error(UnpostedCreditMemoErr);
    end;
    #endregion CheckUnpostedReserveCreditMemoExists

    local procedure SingleSalesLineExists(): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.Reset();
        SalesLine.SetCurrentKey("Document Type", "Document No.", "Line No.");
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::"Credit Memo");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::"Charge (Item)");
        exit(not SalesLine.IsEmpty);
    end;

    local procedure GetItemNo() ItemNo: Code[20]
    var
        ValueEntry: Record "Value Entry";
    begin
        if TempSalesInvoiceLine.Type = TempSalesInvoiceLine.Type::Item then
            exit(TempSalesInvoiceLine."No.");
        Filter(ValueEntry);
        if not ValueEntry.FindFirst() then
            exit('');
        exit(ValueEntry."Item No.");
    end;

    local procedure LineIsApplicableForBonus(): Boolean
    var
        ItemCharge: Record "Item Charge";
        ItemNo: Code[20];
    begin
        if not LineIsShipped() then
            exit;

        ItemNo := GetItemNo();
        if not CheckItemMeth.CheckItem(BonusContract."No.", ItemNo) then
            exit;

        if TempSalesInvoiceLine.Type = TempSalesInvoiceLine.Type::"Charge (Item)" then begin
            if BelongsToSameDocument() then
                exit;
            if not ItemCharge.Get(TempSalesInvoiceLine."No.") then
                exit;
            if not ItemCharge."lbtbn Bonus consider" then
                exit;
        end;
        exit(true);
    end;


    var
        AccountingPeriodTxt: Label 'Accounting Period %1 to %2', Comment = '%1 from, %2 to';
        BonusCreditMemoLbl: Label 'Bonus Credit Memo';
        BonusSettlementTxt: Label 'Bonus Accounting according to Bonus Contract %1', Comment = '%1 No.';
        ContractTxt: Label 'Contract';
        BonusReserveForLbl: Label 'Bonus Reserve for ';
        BonusReserveLbl: Label 'Bonus Reserve';
        AccountingPeriodLbl: Label 'Accounting Period %1 to %2', Comment = '%1 from %2 to';
        BonusAccountingLbl: Label 'Bonus Accounting accordingly Bonus Contract %1.', Comment = '%1 No.';
        UnpostedCreditMemoErr: Label 'There is an unposted credit memo for bonus reserve.\\Please post or delete it at first.',
            Comment = 'DEU="Es existiert eine ungebuchte Gutschrift zur Bonusrückstellung.\\Diese muss erst gebucht oder gelöscht werden."';

}