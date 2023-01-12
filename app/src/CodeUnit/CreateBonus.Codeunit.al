codeunit 5266060 "lbtbn Create Bonus"
{

    var
        BonusSetup: Record "lbtbn Bonus Setup";
        BonusContract: Record "lbtbn Bonus Contract";
        ItemLedgerEntry: Record "Item Ledger Entry";
        BonusContractLine: Record "lbtbn Bonus Contract Line";
        SalesHeader: Record "Sales Header";
        CheckItemMeth: Codeunit "lbtbn CheckItem Meth";
        I: Interface "lbtbn I";
        PostingDate: Date;
        DateFrom: Date;
        DateTo: Date;
        CustomerNo: Code[20];
        ShipToCode: Code[10];
        CurrencyFactor: Decimal;
        SalesLineNo: Integer;
        CrMemoHeaderCreated: Boolean;
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
    var
        DocAmount: Decimal;
        DiscAmt: Decimal;
        PmtDiscAmt: Decimal;
        BonusAmount: Decimal;
    begin
        if not CheckItemMeth.CheckItem(BonusContract."No.", SalesInvoiceLine."No.") then
            exit;
        DocAmount := GetDocAmount(SalesInvoiceLine.Amount);
        UpdateDocAmountFromValueEntry(Database::"Sales Invoice Line", SalesInvoiceLine."Document No.", SalesInvoiceLine."Line No.", DocAmount);
        CalculateBonusAmount(BonusContract."Bonus Billing Type", DocAmount, BonusContractLine.Value, DiscAmt, PmtDiscAmt, BonusAmount, SalesInvoiceLine.Quantity);
        CreateCreditMemo(DocAmount, DiscAmt, PmtDiscAmt, BonusAmount, Database::"Sales Invoice Line", SalesInvoiceLine."Document No.", SalesInvoiceLine."Line No.");
    end;
    #endregion CreateBonus

    #region CreateBonus Credit Memo
    procedure CreateBonus(SalesCrMemoLine: Record "Sales Cr.Memo Line")
    var
        DocAmount: Decimal;
        DiscAmt: Decimal;
        PmtDiscAmt: Decimal;
        BonusAmount: Decimal;
    begin
        if not CheckItemMeth.CheckItem(BonusContract."No.", SalesCrMemoLine."No.") then
            exit;
        DocAmount := -GetDocAmount(SalesCrMemoLine.Amount);
        UpdateDocAmountFromValueEntry(Database::"Sales Cr.Memo Line", SalesCrMemoLine."Document No.", SalesCrMemoLine."Line No.", DocAmount);
        CalculateBonusAmount(BonusContract."Bonus Billing Type", DocAmount, BonusContractLine.Value, DiscAmt, PmtDiscAmt, BonusAmount, SalesCrMemoLine.Quantity);
        CreateCreditMemo(DocAmount, DiscAmt, PmtDiscAmt, BonusAmount, Database::"Sales Cr.Memo Line", SalesCrMemoLine."Document No.", SalesCrMemoLine."Line No.");
    end;
    #endregion CreateBonus

    #region GetDocAmount
    local procedure GetDocAmount(Amount: Decimal) DocAmount: Decimal
    begin
        if CurrencyFactor = 0 then
            DocAmount := Amount
        else
            DocAmount := Round(Amount / CurrencyFactor, 0.01);
    end;
    #endregion GetDocAmount

    #region CreateSalesCreditMemo3
    procedure CreateSalesCreditMemo3(TableID: Integer; DocNo: Code[20]; DocLineNo: Integer; DocAmt: Decimal; BonusSumme: Decimal; DiscAmount: Decimal; PmtDiscAmount: Decimal) Betrag: Decimal
    var
        SalesLine: Record "Sales Line";
        BonusEntry: Record "lbtbn Bonus Entry";
        DimMgt: Codeunit DimensionManagement;
        LineNo: Integer;
        Zusatz: Text;
        AccountingTxt: Label 'Bonus Accounting';
    begin
        GetOrCreateSalesHeader();

        SalesLine.Reset();
        SalesLine.SetCurrentKey("Document Type", "Document No.", "Line No.");
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::"Credit Memo");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if (SalesLine.FindLast()) and
          (BonusContract."Bonus Billing Type" = BonusContract."Bonus Billing Type"::"Amount (LCY)")
        then
            exit;

        LineNo := SalesLine."Line No." + 10000;

        InitSalesLine(SalesLine, LineNo);
        SalesLine.Description := AccountingTxt;
        if BonusContract."Bonus Billing Type" <> BonusContract."Bonus Billing Type"::"Amount (LCY)" then
            SalesLine.Description += ' ' + Format(DocNo);

        SalesLine.Modify();

        CreateItemCharge(TableID, DocAmt, BonusSumme, SalesLine, Zusatz, Betrag);

        if BonusContract."Bonus Billing Type" = BonusContract."Bonus Billing Type"::"Amount (LCY)" then
            exit;

        SalesLine."Description 2" := ContractTxt + Format(BonusContract."No.") + ': ' + Zusatz;
        SalesLine.Modify(true);

        SalesLine.UpdateAmounts();


        SalesLine."lbtbn Bonus Entry No." := CreateBonusEntry(BonusContract, DocNo, DocLineNo, DocAmt, DiscAmount, PmtDiscAmount, TableID, SalesLine);
        if BonusEntry.Get(SalesLine."lbtbn Bonus Entry No.") then
            SalesLine."Dimension Set ID" := BonusEntry."Dimension Set ID";
        DimMgt.UpdateGlobalDimFromDimSetID(SalesLine."Dimension Set ID",
                                             SalesLine."Shortcut Dimension 1 Code",
                                              SalesLine."Shortcut Dimension 2 Code");
        SalesLine.Modify(true);
    end;
    #endregion CreateSalesCreditMemo3

    #region GetOrCreateSalesHeader
    local procedure GetOrCreateSalesHeader()
    begin
        SalesHeader.SetCurrentKey("Document Type", "Sell-to Customer No.");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Credit Memo");
        SalesHeader.SetRange("Sell-to Customer No.", GetCustCode());
        SalesHeader.SetRange("Document Date", PostingDate);
        SalesHeader.SetRange("Posting Description", BonusCreditMemoLbl);
        if not SalesHeader.FindFirst() then begin
            InitSalesHeader();
            CreateTextLine(10000, StrSubstNo(BonusSettlementTxt, BonusContract."No."));
            CreateTextLine(20000, StrSubstNo(AccountingPeriodTxt, DateFrom, DateTo));
        end;
    end;
    #endregion GetOrCreateSalesHeader

    #region GetCustCode
    local procedure GetCustCode(): Code[20]
    begin
        exit(BonusContract."Bonus Recipient");
    end;
    #endregion GetCustCode

    #region InitSalesHeader
    local procedure InitSalesHeader()
    begin
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::"Credit Memo";
        SalesHeader."No." := '';
        SalesHeader.Insert(true);
        SalesHeader.Correction := false;
        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.Validate("Sell-to Customer No.", GetCustCode());
        SalesHeader."Document Date" := PostingDate;
        SalesHeader."Posting Description" := BonusCreditMemoLbl;
        SalesHeader."lbt Process No." := BonusContract."Process No.";
        SalesHeader."Posting No." := SalesHeader."No.";
        SalesHeader.Modify();
        CrMemoHeaderCreated := true;
    end;
    #endregion InitSalesHeader

    #region InitSalesLine
    local procedure InitSalesLine(var SalesLine: Record "Sales Line"; LineNo: Integer)
    var
    begin
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";

        SalesLine."Line No." := LineNo;
        SalesLine.Validate("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
        SalesLine.Insert(true);

        SalesLine.Validate(Type, SalesLine.Type::"Charge (Item)");
        SalesLine.Validate("No.", BonusContract."Accounting Item Charge");
        // SalesLine.VALIDATE("Location Code", VertriebEinrRec."Location Bonus Item");
        SalesLine.Validate("Unit Price", 1);
        SalesLine."lbt Process No." := BonusContract."Process No.";
    end;
    #endregion InitSalesLine

    #region CreateItemCharge
    local procedure CreateItemCharge(TableID: Integer; DocAmt: Decimal; BonusSumme: Decimal; var SalesLine: Record "Sales Line"; var Zusatz: Text; var Betrag: Decimal)
    begin

        case BonusContract."Bonus Billing Type" of
            BonusContract."Bonus Billing Type"::"%":
                Zusatz := CreateItemChargeForBillingTypePercent(DocAmt, BonusSumme, TableID, SalesLine);
            BonusContract."Bonus Billing Type"::"Amount (LCY)":
                CreateItemChargeForBillingTypeAmount(BonusSumme, SalesLine, Betrag);
            BonusContract."Bonus Billing Type"::"Amount per Unit":
                Zusatz := CreateItemChargeForBillingTypeAmountPerUnit(DocAmt, BonusSumme, SalesLine, TableID);
        end;
    end;
    #endregion CreateItemCharge

    #region CreateItemChargeForBillingTypeAmount
    local procedure CreateItemChargeForBillingTypeAmount(BonusSumme: Decimal; var SalesLine: Record "Sales Line"; var Betrag: Decimal)
    var
        ItemChargeAssRec: Record "Item Charge Assignment (Sales)";
        PostedSalesShptLineRec: Record "Sales Shipment Line";
        AssignItemChargeSales: Codeunit "Item Charge Assgnt. (Sales)";
        AmountCust: Decimal;
        TotalQuantity: Decimal;
        FixedAmountTxt: Label 'Fixed Amount';
        Zusatz: Text;
    begin
        CalculateAmountCust(AmountCust);
        Zusatz := FixedAmountTxt;
        PostedSalesShptLineRec.Reset();
        //PostedSalesShptLineRec.SETRANGE("Sell-to Customer No.","Bonus Contract".Customer);
        PostedSalesShptLineRec.SetRange("Sell-to Customer No.", CustomerNo);
        PostedSalesShptLineRec.SetRange("Posting Date", DateFrom, DateTo);
        PostedSalesShptLineRec.SetRange(Type, PostedSalesShptLineRec.Type::Item);
        PostedSalesShptLineRec.SetFilter(Quantity, '<>%1', 0);
        ItemChargeAssRec."Document Type" := SalesLine."Document Type";
        ItemChargeAssRec."Document No." := SalesLine."Document No.";
        ItemChargeAssRec."Document Line No." := SalesLine."Line No.";
        ItemChargeAssRec."Unit Cost" := SalesLine."Unit Price";
        ItemChargeAssRec."Item Charge No." := SalesLine."No.";
        // ItemChargeAssRec."lbt Process No." := SalesLine."lbt Process No.";
        AssignItemChargeSales.CreateShptChargeAssgnt(PostedSalesShptLineRec, ItemChargeAssRec);
        TotalQuantity := 0;
        AssignItemChargeSales.AssignItemCharges(SalesLine, AmountCust, TotalQuantity, AssignItemChargeSales.AssignByAmountMenuText());
        ItemChargeAssRec.Reset();
        ItemChargeAssRec.SetRange("Document Type", SalesLine."Document Type");
        ItemChargeAssRec.SetRange("Document No.", SalesLine."Document No.");
        ItemChargeAssRec.SetRange("Document Line No.", SalesLine."Line No.");
        Betrag := AmountCust * BonusSumme;
    end;
    #endregion CreateItemChargeForBillingTypeAmount

    #region CreateItemChargeForBillingTypeAmountPerUnit
    local procedure CreateItemChargeForBillingTypeAmountPerUnit(DocAmt: Decimal; BonusSumme: Decimal; var SalesLine: Record "Sales Line"; TableId: Integer) Zusatz: Text
    var
        AmountCust: Decimal;
        PerTxt: Label ' per ';
    begin
        SalesLine.Validate(Quantity, BonusSumme);
        CreateItemCharge(DocAmt, BonusSumme, TableId, SalesLine);

        CalculateAmountCust(AmountCust);
        Zusatz := Format(AmountCust) + PerTxt + Format(BonusContractLine."Item Unit of Measure");
    end;
    #endregion CreateItemChargeForBillingTypeAmountPerUnit

    #region CreateTextLine
    local procedure CreateTextLine(LineNo: Integer; Description: Text[100])
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        // TODO: Printoption
        SalesLine.Description := Description;
        SalesLine.Insert();
    end;
    #endregion CreateTextLine

    #region CreateBonusEntry
    local procedure CreateBonusEntry(var Contract: Record "lbtbn Bonus Contract"; DocNo: Code[20]; DocLineNo: Integer; DocAmt: Decimal; DiscAmount: Decimal; PmtDiscAmount: Decimal; TableId: Integer; var SalesLine: Record "Sales Line"): Integer
    var
        BonusMgt: Codeunit "lbtbn Bonus Management";
    begin
        Clear(BonusMgt);
        BonusMgt.SetSourceDoc(TableId, DocNo, DocLineNo);
        BonusMgt.SetBonusDoc(2, SalesLine."Document No.", SalesLine."Line No.");
        exit(BonusMgt.CreateBonusContractEntry(
          Contract,
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

    #region CreateItemChargeForBillingTypePercent
    local procedure CreateItemChargeForBillingTypePercent(DocAmt: Decimal; BonusSumme: Decimal; TableId: Integer; var SalesLine: Record "Sales Line") Zusatz: Text
    begin
        SalesLine.Validate(Quantity, BonusSumme);
        SalesLine.Modify();
        CreateItemCharge(DocAmt, BonusSumme, TableId, SalesLine);
        Zusatz := Format(BonusContractLine.Value) + ' %';
    end;
    #endregion CreateItemChargeForBillingTypePercent

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

    #region CreateCreditMemo
    local procedure CreateCreditMemo(DocAmount: Decimal; DiscAmt: Decimal; PmtDiscAmt: Decimal; BonusAmount: Decimal; TableNo: Integer; DocNo: Code[20]; LineNo: Integer)
    var
    begin
        if CheckValueEntry(TableNo, DocNo, LineNo) then
            CreateSalesCreditMemo3(TableNo, DocNo, LineNo, DocAmount, BonusAmount, DiscAmt, PmtDiscAmt);
    end;
    #endregion CreateCreditMemo

    #region CheckValueEntry
    local procedure CheckValueEntry(TableNo: Integer; DocNo: Code[20]; LineNo: Integer): Boolean
    var
        ValueEntry: Record "Value Entry";
    begin
        BonusSetup.Get();
        if BonusSetup."Reserve Mode" = BonusSetup."Reserve Mode"::CreditMemo then begin
            ValueEntry.SetCurrentKey("Document No.");
            ValueEntry.SetRange("Document No.", DocNo);
            case TableNo of
                Database::"Sales Invoice Line":
                    ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Invoice");
                Database::"Sales Cr.Memo Line":
                    ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Credit Memo");
            end;
            ValueEntry.SetRange("Document Line No.", LineNo);
            if not ValueEntry.FindFirst() then exit(false);
            if not ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.") then exit(false);
            case TableNo of
                Database::"Sales Invoice Line":
                    if ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Sales Shipment" then
                        exit(true);
                Database::"Sales Cr.Memo Line":
                    if ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Sales Return Receipt" then
                        exit(true);
            end;
        end;
    end;
    #endregion CheckValueEntry

    procedure UpdateDocAmountFromValueEntry(var DocAmount: Decimal)
    var
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.Reset();
        ValueEntry.SetCurrentKey("Document No.");
        I.ValueEntrySetRangeDocumentType(ValueEntry);
        if ValueEntry.FindSet() then
            repeat
                if ValueEntry."Sales Amount (Actual)" <> 0 then
                    DocAmount += AddConsideredItemCharges(ValueEntry."Item Ledger Entry No.");
            until ValueEntry.Next() = 0;
    end;

    #region UpdateDocAmountFromValueEntry
    procedure UpdateDocAmountFromValueEntry(TableNo: Integer; DocNo: Code[20]; DocLineNo: Integer; var DocAmount: Decimal)
    var
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.Reset();
        ValueEntry.SetCurrentKey("Document No.");
        case TableNo of
            Database::"Sales Invoice Line":
                ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Invoice");
            Database::"Sales Cr.Memo Line":
                ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Credit Memo");
        end;
        ValueEntry.SetRange("Document No.", DocNo);
        ValueEntry.SetRange("Document Line No.", DocLineNo);
        if ValueEntry.FindSet() then
            repeat
                if ValueEntry."Sales Amount (Actual)" <> 0 then
                    DocAmount += AddConsideredItemCharges(ValueEntry."Item Ledger Entry No.");
            until ValueEntry.Next() = 0;
    end;
    #endregion UpdateDocAmountFromValueEntry

    procedure CreateReserve(SalesCrMemoLine: Record "Sales Cr.Memo Line")
    var
        SalesCrMemoLineCU: Codeunit "lbtbn Sales Cr.Line";
    begin
        I := SalesCrMemoLineCU;
        SalesCrMemoLineCU.SetLine(SalesCrMemoLine);
        if CheckItemMeth.CheckItem(BonusContract."No.", SalesCrMemoLine."No.") then
            DoCreateReserve();
    end;

    procedure CreateReserve(SalesInvoiceLine: Record "Sales Invoice Line")
    var
        SalesInvoiceLineCU: Codeunit "lbtbn Sales Invoice Line";
    begin
        I := SalesInvoiceLineCU;
        SalesInvoiceLineCU.SetLine(SalesInvoiceLine);
        if CheckItemMeth.CheckItem(BonusContract."No.", SalesInvoiceLine."No.") then
            DoCreateReserve();
    end;
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
            I.GetDimensionSetId());

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
        GenJournalLine."Document No." := I.DocumentNo();
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
        GenJournalLine."Dimension Set ID" := I.GetDimensionSetId();
        if GenJournalLine."Dimension Set ID" = 0 then
            GenJournalLine."Dimension Set ID" := BonusContract."Dimension Set ID";
        DimensionManagement.UpdateGlobalDimFromDimSetID(GenJournalLine."Dimension Set ID",
                                             GenJournalLine."Shortcut Dimension 1 Code",
                                              GenJournalLine."Shortcut Dimension 2 Code");
        GenJournalLine.Insert();
    end;
    #endregion CreateJournalLine

    #region CreateForReserveMode_CreditMemo
    local procedure CreateForReserveMode_CreditMemo(Qty: Decimal; BonusAmt: Decimal; PmtDiscAmt: Decimal; DocAmount: Decimal; DiscAmt: Decimal)
    var
        l_ItemLedgerEntry: Record "Item Ledger Entry";
        SalesLine: Record "Sales Line";
        ValueEntry: Record "Value Entry";
        BonusManagement: Codeunit "lbtbn Bonus Management";
        BonusEntryNo: Integer;
    begin
        BonusContract.TestField("Reserve Item Charge");
        ValueEntry.Reset();
        ValueEntry.SetCurrentKey("Document No.");
        I.ValueEntrySetRangeDocumentType(ValueEntry);
        if not ValueEntry.FindFirst() then
            exit;
        if not l_ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.") then
            exit;
        CreateBonusCrMemoLine(BonusAmt, SalesLine);
        AddItemChargeToSalesLine(SalesLine, DocAmount, BonusAmt);
        if I.GetShipmentDocType() = l_ItemLedgerEntry."Document Type" then begin
            Clear(BonusManagement);
            BonusManagement.SetAssignmentDoc(1, l_ItemLedgerEntry."Document No.", l_ItemLedgerEntry."Document Line No.");
            BonusManagement.SetSourceDoc(I);
            BonusManagement.SetBonusDoc(2, SalesLine."Document No.", SalesLine."Line No.");
            BonusEntryNo := BonusManagement.CreateBonusContractEntry(
                                BonusContract,
                                CustomerNo,
                                ShipToCode,
                                1,
                                PostingDate,
                                0,
                                Qty, ////PostDocItemUnitRec.Quantity,
                                BonusAmt,
                                BonusAmt,
                                DocAmount,
                                -DiscAmt,
                                -PmtDiscAmt,
                                SalesLine."Dimension Set ID");
            SalesLine."lbtbn Bonus Entry No." := BonusEntryNo;
            SalesLine.Modify();
        end;
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

        ItemChargeAssignmentSales."Applies-to Doc. Type" := I.GetAppliesToDocType();
        ItemChargeAssignmentSales."Applies-to Doc. Line Amount" := DocAmount;
        ItemLedgerEntryL := GetItemLedgerEntry();
        ItemChargeAssignmentSales."Applies-to Doc. No." := ItemLedgerEntryL."Document No.";
        ItemChargeAssignmentSales."Applies-to Doc. Line No." := ItemLedgerEntryL."Document Line No.";
        ItemChargeAssignmentSales."Unit Cost" := BonusAmount;
        ItemChargeAssignmentSales.Validate("Qty. to Assign", 1);
        ItemChargeAssignmentSales.Insert();
    end;
    #endregion AddItemChargeToSalesLine
    local procedure GetItemLedgerEntry() ItemLedgerEntry: Record "Item Ledger Entry"
    var
        ValueEntry: Record "Value Entry";
    begin
        I.ValueEntrySetRangeDocumentType(ValueEntry);
        ValueEntry.FindFirst();
        ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.");
    end;
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
        SalesLine.Validate("No.", BonusContract."Reserve Item Charge");
        SalesLine.Validate("Unit Price", BonusAmt);
        SalesLine.Validate(Quantity, 1);
        SalesLine."Shipment Date" := WorkDate();
        SalesLine."Allow Invoice Disc." := true;
        SalesLine.Description := BonusReserveForLbl;
        SalesLine.Description += I.GetDescription();
        SalesLine."lbt Process No." := BonusContract."Process No.";
        SalesLine."Dimension Set ID" := I.GetDimensionSetId();
        DimensionManagement.UpdateGlobalDimFromDimSetID(SalesLine."Dimension Set ID", SalesLine."Shortcut Dimension 1 Code", SalesLine."Shortcut Dimension 2 Code");
        if SalesHeader."Shortcut Dimension 1 Code" <> '' then
            SalesLine.Validate("Shortcut Dimension 1 Code", SalesHeader."Shortcut Dimension 1 Code");
        SalesLine.Insert();
    end;
    #endregion CreateBonusCrMemoLine

    #region CreateCrMemoHeader
    local procedure CreateCrMemoHeader()
    var
        SalesLine: Record "Sales Line";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        if CrMemoHeaderCreated then
            exit;
        BonusSetup.Get();
        SalesHeader.Reset();
        SalesHeader.SetCurrentKey("Document Type", "Sell-to Customer No.");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Credit Memo");
        SalesHeader.SetRange("Sell-to Customer No.", BonusContract."Customer Reserve Cr.Memo");
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
        BonusContract.TestField("Customer Reserve Cr.Memo");
        SalesHeader.Validate("Sell-to Customer No.", BonusContract."Customer Reserve Cr.Memo");
        // Validate("Gen. Bus. Posting Group", BonusSetupRec."Bus.Post.Gr.f.Res.Cr.Memo");
        // Validate("Customer Posting Group", BonusSetupRec."Cust Gr. Reserve Cr. Memo");
        SalesHeader."Posting Description" := BonusReserveLbl;
        PostingDate := DateTo;
        SalesHeader."lbt Process No." := BonusContract."Process No.";
        SalesHeader.Modify();

        CrMemoHeaderCreated := true;

        SalesLineNo := 10000;
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := SalesLineNo;
        SalesLine.Description := StrSubstNo(BonusAccountingLbl, BonusContract."No.");
        SalesLine.Insert();

        SalesLineNo += 10000;
        SalesLine."Line No." := SalesLineNo;
        SalesLine.Description := StrSubstNo(AccountingPeriodLbl, DateFrom, DateTo);
        SalesLine.Insert();
    end;
    #endregion CreateCrMemoHeader


    #region AddConsideredItemCharges
    local procedure AddConsideredItemCharges(ItemLedgerEntryNo: Integer) AmountFromItemCharge: Decimal;
    var
        ItemCharge: Record "Item Charge";
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.Reset();
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

    procedure OpenPageBonus()
    var
        PageManagement: Codeunit "Page Management";
    begin
        if not CrMemoHeaderCreated then
            exit;
        PageManagement.PageRun(SalesHeader);
    end;


    internal procedure CreateReserveFixed()
    var
        SalesLine: Record "Sales Line";
        FixedAmount: Codeunit "lbtbn Fixed Amount";

    begin
        BonusSetup.Get();
        I := FixedAmount;
        FixedAmount.SetCustomerNo(CustomerNo);
        case BonusSetup."Reserve Mode" of
            BonusSetup."Reserve Mode"::CreditMemo:
                begin
                    CreateBonusCrMemoLine(BonusContract."Reserve Value", SalesLine);
                    CreateBonusEntryForFixedAmount(SalesLine);
                end;
            BonusSetup."Reserve Mode"::Journal:
                CreateJournalLine(BonusContract."Reserve Value", 0,
                  0, 0);
        end;
    end;

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
    local procedure CreateItemCharge(DocAmt: Decimal; BonusSumme: Decimal; TableId: Integer; var SalesLine: Record "Sales Line")
    var
        ItemChargeAssRec: Record "Item Charge Assignment (Sales)";
    begin
        ItemChargeAssRec.Init();
        ItemChargeAssRec."Document Type" := SalesLine."Document Type";
        ItemChargeAssRec."Document No." := SalesLine."Document No.";
        ItemChargeAssRec."Document Line No." := SalesLine."Line No.";
        ItemChargeAssRec."Line No." := 10000;
        ItemChargeAssRec."Item Charge No." := SalesLine."No.";

        case TableId of
            Database::"Sales Invoice Line":
                ItemChargeAssRec."Applies-to Doc. Type" := ItemChargeAssRec."Applies-to Doc. Type"::Shipment;
            Database::"Sales Cr.Memo Line":
                ItemChargeAssRec."Applies-to Doc. Type" := ItemChargeAssRec."Applies-to Doc. Type"::"Return Receipt";
        end;

        ItemChargeAssRec."Applies-to Doc. Line Amount" := DocAmt;
        ItemChargeAssRec."Item No." := ItemLedgerEntry."Item No.";
        ItemChargeAssRec.Description := ItemLedgerEntry.Description;
        ItemChargeAssRec."Applies-to Doc. No." := ItemLedgerEntry."Document No.";
        ItemChargeAssRec."Applies-to Doc. Line No." := ItemLedgerEntry."Document Line No.";
        ItemChargeAssRec."Unit Cost" := 1;
        ItemChargeAssRec.Validate("Qty. to Assign", BonusSumme);
        ItemChargeAssRec.Insert();
    end;

    local procedure DoCreateReserve()
    var
        BonusAmt: Decimal;
        DiscAmt: Decimal;
        DocAmount: Decimal;
        PmtDiscAmt: Decimal;
        NewQty: Decimal;
    begin
        DocAmount := I.GetAmount();
        if CurrencyFactor <> 0 then
            DocAmount := Round(DocAmount / CurrencyFactor, 0.01);

        UpdateDocAmountFromValueEntry(DocAmount);

        NewQty := CalculateBonusAmount(BonusContract."Reserve Type", DocAmount, BonusContract."Reserve Value", DiscAmt, PmtDiscAmt, BonusAmt, I.Quantity());

        if BonusAmt = 0 then
            exit;
        BonusSetup.Get();
        if BonusSetup."Reserve Mode" = BonusSetup."Reserve Mode"::CreditMemo then
            CreateForReserveMode_CreditMemo(NewQty, BonusAmt, PmtDiscAmt, DocAmount, DiscAmt)
        else
            CreateJournalLine(BonusAmt, DocAmount, -DiscAmt, -PmtDiscAmt);
    end;

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