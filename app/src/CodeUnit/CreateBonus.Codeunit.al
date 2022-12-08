codeunit 5266060 "lbtbn Create Bonus"
{

    var
        BonusContract: Record "lbtbn Bonus Contract";
        ItemLedgerEntry: Record "Item Ledger Entry";
        BonusContractLine: Record "lbtbn Bonus Contract Line";
        CheckItemMeth: Codeunit "lbtbn CheckItem Meth";
        PostingDate: Date;
        DateFrom: Date;
        DateTo: Date;
        CustomerNo: Code[20];
        ShipToCode: Code[10];
        BillingEntry: Integer;
        CurrencyFactor: Decimal;

    #region SetBonusContract
    procedure SetBonusContract(BonusContract2: Record "lbtbn Bonus Contract"; BonusContractLine2: Record "lbtbn Bonus Contract Line")
    begin
        BonusContract := BonusContract2;
        BonusContractLine := BonusContractLine2;
    end;
    #endregion SetBonusContract

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
        //UpdateDocAmountFromValueEntry();
        CalculateBonusAmount(DocAmount, DiscAmt, PmtDiscAmt, BonusAmount, SalesInvoiceLine.Quantity);
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
        //UpdateDocAmountFromValueEntry();
        CalculateBonusAmount(DocAmount, DiscAmt, PmtDiscAmt, BonusAmount, SalesCrMemoLine.Quantity);
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
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LineNo: Integer;
        OldLineNo: Integer;
        Zusatz: Text;
        AccountingTxt: Label 'Bonus Accounting';
    begin
        GetOrCreateSalesHeader(SalesHeader);

        SalesLine.Reset();
        SalesLine.SetCurrentKey("Document Type", "Document No.", "lbt Process No.");
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::"Credit Memo");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if (SalesLine.FindLast()) and
          (BonusContract."Bonus Billing Type" = BonusContract."Bonus Billing Type"::"Amount (LCY)")
        then
            exit;
        OldLineNo := SalesLine."Line No.";
        LineNo := SalesLine."Line No." + 10000;

        InitSalesLine(BonusContract, SalesHeader, SalesLine, LineNo);
        SalesLine.Description := AccountingTxt;
        if BonusContract."Bonus Billing Type" <> BonusContract."Bonus Billing Type"::"Amount (LCY)" then
            SalesLine.Description += ' ' + Format(DocNo);

        SalesLine.Modify();

        CreateItemCharge(BonusContract, TableID, DocNo, DocLineNo, DocAmt, BonusSumme, DiscAmount, PmtDiscAmount, SalesHeader, SalesLine, OldLineNo, Zusatz, Betrag);

        if BonusContract."Bonus Billing Type" = BonusContract."Bonus Billing Type"::"Amount (LCY)" then
            exit;

        SalesLine."Description 2" := ContractTxt + Format(BonusContract."No.") + ': ' + Zusatz;
        SalesLine.Modify(true);

        // SalesHeader.Status := SalesHeader.Status::Released;
        // SalesHeader.Modify();
        SalesLine.UpdateAmounts();
        // SalesHeader.Status := SalesHeader.Status::Open;
        // SalesHeader.Modify();

        CreateBonusEntry(BonusContract, DocNo, DocLineNo, DocAmt, DiscAmount, PmtDiscAmount, TableId, SalesLine);

        SetDimensions(TableID, DocNo, DocLineNo, SalesHeader, SalesLine);
        SalesLine.Modify(true);
    end;
    #endregion CreateSalesCreditMemo3

    #region GetSalesHeader
    local procedure GetOrCreateSalesHeader(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.SetCurrentKey("Document Type", "Sell-to Customer No.");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Credit Memo");
        SalesHeader.SetRange("Sell-to Customer No.", GetCustCode());
        SalesHeader.SetRange("Document Date", PostingDate);
        SalesHeader.SetRange("Posting Description", BonusCreditMemoLbl);
        if not SalesHeader.FindFirst() then begin
            InitSalesHeader(SalesHeader);
            CreateTextLine(SalesHeader, 10000, StrSubstNo(BonusSettlementTxt, BonusContract."No."));
            CreateTextLine(SalesHeader, 20000, StrSubstNo(AccountingPeriodTxt, DateFrom, DateTo));
        end;
    end;
    #endregion GetSalesHeader

    #region GetCustCode
    local procedure GetCustCode(): Code[20]
    begin
        exit(BonusContract."Bonus Recipient");
    end;
    #endregion GetCustCode

    #region InitSalesHeader
    local procedure InitSalesHeader(var SalesHeader: Record "Sales Header")
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
        SalesHeader.Modify();
    end;
    #endregion InitSalesHeader

    #region InitSalesLine
    local procedure InitSalesLine(Contract: Record "lbtbn Bonus Contract"; SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; LineNo: Integer)
    var
    begin
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";

        SalesLine."Line No." := LineNo;
        SalesLine.Validate("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
        SalesLine.Insert(true);

        SalesLine.Validate(Type, SalesLine.Type::"Charge (Item)");
        SalesLine.Validate("No.", Contract."Accounting Item Charge");
        // SalesLine.VALIDATE("Location Code", VertriebEinrRec."Location Bonus Item");
        SalesLine.Validate("Unit Price", 1);
        SalesLine."lbt Process No." := Contract."Process No.";
    end;
    #endregion InitSalesLine

    #region CreateItemCharge
    local procedure CreateItemCharge(var Contract: Record "lbtbn Bonus Contract"; var TableID: Integer; var DocNo: Code[20]; var DocLineNo: Integer; var DocAmt: Decimal; var BonusSumme: Decimal; var DiscAmount: Decimal; var PmtDiscAmount: Decimal; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var OldLineNo: Integer; var Zusatz: Text; var Betrag: Decimal)
    begin

        case Contract."Bonus Billing Type" of
            Contract."Bonus Billing Type"::"%":
                Zusatz := CreateItemChargeForBillingTypePercent(DocAmt, BonusSumme, TableID, SalesLine);
            Contract."Bonus Billing Type"::"Amount (LCY)":
                CreateItemChargeForBillingTypeAmount(Contract, TableID, DocNo, DocLineNo, BonusSumme, DiscAmount, PmtDiscAmount, SalesHeader, SalesLine, OldLineNo, Betrag);
            Contract."Bonus Billing Type"::"Amount per Unit":
                Zusatz := CreateItemChargeForBillingTypeAmountPerUnit(DocAmt, BonusSumme, SalesLine, TableID);
        end;
    end;
    #endregion CreateItemCharge

    #region CreateItemChargeForBillingTypeAmount
    local procedure CreateItemChargeForBillingTypeAmount(var Contract: Record "lbtbn Bonus Contract"; TableID: Integer; DocNo: Code[20]; DocLineNo: Integer; BonusSumme: Decimal; DiscAmount: Decimal; PmtDiscAmount: Decimal; SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; OldLineNo: Integer; var Betrag: Decimal)
    var
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        CustRec: Record Customer;
        ItemChargeAssRec: Record "Item Charge Assignment (Sales)";
        PostedSalesShptLineRec: Record "Sales Shipment Line";
        AssignItemChargeSales: Codeunit "Item Charge Assgnt. (Sales)";
        AmountCust: Decimal;
        TotalQuantity: Decimal;
        DocType: Integer;
        FixedAmountTxt: Label 'Fixed Amount';
        Zusatz: Text;
    begin
        case TableID of
            Database::"Sales Invoice Line":
                DocType := 1;
            Database::"Sales Cr.Memo Line":
                DocType := 2;
        end;
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
        CreateSeparateLines(SalesLine, ItemChargeAssRec);
        HandleSeparatedLines(Contract, TableID, DocNo, DocLineNo, DiscAmount, PmtDiscAmount, ItemChargeAssRec, SalesHeader, DocType, OldLineNo, Zusatz);
        Betrag := AmountCust * BonusSumme;
    end;
    #endregion CreateItemChargeForBillingTypeAmount

    #region CreateItemChargeForBillingTypeAmountPerUnit
    local procedure CreateItemChargeForBillingTypeAmountPerUnit(DocAmt: Decimal; BonusSumme: Decimal; var SalesLine: Record "Sales Line"; TableId: Integer) Zusatz: Text
    var
        ItemChargeAssRec: Record "Item Charge Assignment (Sales)";
        CustRec: Record Customer;
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        AmountCust: Decimal;
        PerTxt: Label ' per ';
    begin
        SalesLine.Validate(Quantity, BonusSumme);
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
        Zusatz := Format(AmountCust) + PerTxt + Format(BonusContractLine."Item Unit of Measure");
    end;
    #endregion CreateItemChargeForBillingTypeAmountPerUnit

    #region CreateTextLine
    local procedure CreateTextLine(SalesHeader: Record "Sales Header"; LineNo: Integer; Description: Text[100])
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
    local procedure CreateBonusEntry(var Contract: Record "lbtbn Bonus Contract"; DocNo: Code[20]; DocLineNo: Integer; DocAmt: Decimal; DiscAmount: Decimal; PmtDiscAmount: Decimal; Sign: Integer; var SalesLine: Record "Sales Line")
    var
        BonusMgt: Codeunit "lbtbn Bonus Management";
        DocType: Integer;
    begin
        case Sign of
            1:
                DocType := 1;
            -1:
                DocType := 2;
        end;
        Clear(BonusMgt);
        BonusMgt.SetSourceDoc(DocType, DocNo, DocLineNo);
        BonusMgt.SetBonusDoc(2, SalesLine."Document No.", SalesLine."Line No.");
        BillingEntry := BonusMgt.CreateBonusContractEntry(
          Contract,
          CustomerNo,
          ShipToCode,
          0,                                          //Postenart Bonus
          PostingDate,
          BonusContractLine."Line No.",           //Bonusregelzeile
          SalesLine.Quantity,                //Menge
          SalesLine.Amount,                  //Betrag
          SalesLine."Amount Including VAT",  //Betrag inkl. Vat
          DocAmt * Sign,                             //Belegbetrag
          DiscAmount,
          PmtDiscAmount);
    end;
    #endregion CreateBonusEntry

    #region SetDimensions
    local procedure SetDimensions(TableID: Integer; DocNo: Code[20]; DocLineNo: Integer; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        // SalesLine."Billing Code" := VertriebEinrRec."Billing Code";
        SalesLine."lbtbn Bonus Entry No." := BillingEntry;
        if TableID <> 0 then
            case TableID of
                Database::"Sales Invoice Line":
                    begin
                        SalesInvoiceLine.Get(DocNo, DocLineNo);
                        SalesLine."Shortcut Dimension 1 Code" := SalesInvoiceLine."Shortcut Dimension 1 Code";
                        SalesLine."Shortcut Dimension 2 Code" := SalesInvoiceLine."Shortcut Dimension 2 Code";
                        SalesLine."Dimension Set ID" := SalesInvoiceLine."Dimension Set ID";
                    end;
                Database::"Sales Cr.Memo Line":
                    begin
                        SalesCrMemoLine.Get(DocNo, DocLineNo);
                        SalesLine."Shortcut Dimension 1 Code" := SalesCrMemoLine."Shortcut Dimension 1 Code";
                        SalesLine."Shortcut Dimension 2 Code" := SalesCrMemoLine."Shortcut Dimension 2 Code";
                        SalesLine."Dimension Set ID" := SalesCrMemoLine."Dimension Set ID";
                    end;
            end
        else begin
            // SalesLine."Dimension Set ID" := CreateDimSetID("Bonus Contract".Contract);
            // DimMgt.UpdateGlobalDimFromDimSetID(SalesLine."Dimension Set ID",
            //                                      SalesLine."Shortcut Dimension 1 Code",
            //                                       SalesLine."Shortcut Dimension 2 Code");
        end;
        if SalesHeader."Shortcut Dimension 1 Code" <> '' then
            SalesLine.Validate("Shortcut Dimension 1 Code", SalesHeader."Shortcut Dimension 1 Code");
    end;
    #endregion SetDimensions

    #region CreateItemChargeForBillingTypePercent
    local procedure CreateItemChargeForBillingTypePercent(DocAmt: Decimal; BonusSumme: Decimal; TableId: Integer; var SalesLine: Record "Sales Line") Zusatz: Text
    var
        ItemChargeAssRec: Record "Item Charge Assignment (Sales)";
    begin
        SalesLine.Validate(Quantity, BonusSumme);
        SalesLine.Modify();
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
        Zusatz := Format(BonusContractLine.Value) + ' %';
    end;
    #endregion CreateItemChargeForBillingTypePercent

    #region CreateSeparateLines
    local procedure CreateSeparateLines(var SalesLine: Record "Sales Line"; var ItemChargeAssRec: Record "Item Charge Assignment (Sales)")
    begin
        // IF NOT ItemChargeAssRec.ISEMPTY THEN
        //     ItemChargeAssRec.CreateSeparateLines(SalesLine);
    end;
    #endregion CreateSeparateLines

    #region HandleSeparatedLines
    local procedure HandleSeparatedLines(var Contract: Record "lbtbn Bonus Contract"; TableID: Integer; DocNo: Code[20]; DocLineNo: Integer; DiscAmount: Decimal; PmtDiscAmount: Decimal; var ItemChargeAssRec: Record "Item Charge Assignment (Sales)"; var SalesHeader: Record "Sales Header"; DocType: Integer; OldLineNo: Integer; Zusatz: Text)
    var
        SalesLine: Record "Sales Line";
        BonusMgt: Codeunit "lbtbn Bonus Management";
    begin
        SalesLine.Reset();
        SalesLine.SetCurrentKey("Document Type", "Document No.", "lbt Process No.");
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::"Credit Memo");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("lbt Process No.", Contract."Process No.");
        SalesLine.SetFilter("Line No.", '>%1', OldLineNo);
        if SalesLine.FindSet() then
            repeat
                ItemChargeAssRec.SetRange("Document Line No.", SalesLine."Line No.");
                if ItemChargeAssRec.FindFirst() then begin
                    SalesHeader.Status := SalesHeader.Status::Released;
                    SalesHeader.Modify();
                    SalesLine.UpdateAmounts();
                    SalesHeader.Status := SalesHeader.Status::Open;
                    SalesHeader.Modify();

                    Clear(BonusMgt);
                    //BonusMgt.SetSourceDoc(DocType,DocNo,DocLineNo);
                    BonusMgt.SetSourceDoc(
                      DocType,
                      ItemChargeAssRec."Applies-to Doc. No.",
                      ItemChargeAssRec."Applies-to Doc. Line No."
                      );
                    BonusMgt.SetBonusDoc(2, SalesLine."Document No.", SalesLine."Line No.");
                    BillingEntry := BonusMgt.CreateBonusContractEntry(
                      Contract,
                      CustomerNo,
                      ShipToCode,
                      0,                                          //Postenart Bonus
                      PostingDate,
                      BonusContractLine."Line No.",           //Bonusregelzeile
                      SalesLine.Quantity,                //Menge
                      SalesLine.Amount,                  //Betrag
                      SalesLine."Amount Including VAT",  //Betrag inkl. Vat
                                                         //DocAmt * Sign,                             //Belegbetrag
                      ItemChargeAssRec."Applies-to Doc. Line Amount",
                      DiscAmount,
                      PmtDiscAmount);

                    SalesLine."Description 2" := ContractTxt + Format(Contract."No.") + ': ' + Zusatz;
                    // SalesLine.Printoption := SalesLine.Printoption::"Line Invisible";
                    // SalesLine."Billing Code" := VertriebEinrRec."Billing Code";
                    SetDimensions(TableID, DocNo, DocLineNo, SalesHeader, SalesLine);
                    SalesLine.Modify(true);
                end;
            until SalesLine.Next() = 0;
    end;
    #endregion HandleSeparatedLines

    local procedure CalculateBonusAmount(DocAmount: Decimal; var DiscAmt: Decimal; var PmtDiscAmt: Decimal; var BonusAmount: Decimal; Quantity: Decimal)
    begin
        case BonusContract."Bonus Billing Type" of
            BonusContract."Bonus Billing Type"::"%":
                begin
                    PmtDiscAmt := DocAmount * BonusContract."Pmt. Discount %" / 100;
                    DiscAmt := (DocAmount - PmtDiscAmt) * BonusContract."Discount %" / 100;
                    BonusAmount := Round((DocAmount - PmtDiscAmt - DiscAmt) * BonusContractLine.Value / 100, 0.01);
                end;
            BonusContract."Bonus Billing Type"::"Amount (LCY)":
                ;
            BonusContract."Bonus Billing Type"::"Amount per Unit":
                BonusAmount := Round(Quantity * BonusContractLine.Value, 0.01);
        end;
    end;

    local procedure CreateCreditMemo(DocAmount: Decimal; DiscAmt: Decimal; PmtDiscAmt: Decimal; BonusAmount: Decimal; TableNo: Integer; DocNo: Code[20]; var LineNo: Integer)
    var
        ValueEntry: Record "Value Entry";
        BonusSetup: Record "lbtbn Bonus Setup";
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
            if ValueEntry.FindFirst() then
                if ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.") then
                    if ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Sales Shipment" then
                        CreateSalesCreditMemo3(TableNo, DocNo, LineNo, DocAmount, BonusAmount, DiscAmt, PmtDiscAmt);
        end;
    end;


    var
        AccountingPeriodTxt: Label 'Accounting Period %1 to %2', Comment = '%1 from, %2 to';
        BonusCreditMemoLbl: Label 'Bonus Credit Memo';
        BonusSettlementTxt: Label 'Bonus Accounting according to Bonus Contract %1', Comment = '%1 No.';
        ContractTxt: Label 'Contract';
}