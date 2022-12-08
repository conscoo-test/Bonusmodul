codeunit 52051 "lbtbn Bonus Reserve Test"
{
    Subtype = Test;

    var
        BonusSetup: Record "lbtbn Bonus Setup";
        Customer: Record Customer;
        BonusContract: Record "lbtbn Bonus Contract";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryERM: Codeunit "Library - ERM";
        Assert: Codeunit Assert;
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";

    [Test]
    #region ReserveToCreditMemo
    [HandlerFunctions('HandleReserveRequestPage,HandleSalesCreditMemo')]
    procedure ReserveToCreditMemo()
    var
        BonusReserves: Report "lbtbn Bonus Reserves";
    begin
        //GIVEN
        Init(true);
        CreateSalesCrMemoAndPost();

        //WHEN
        BonusContract.SetRecFilter();
        BonusReserves.SetTableView(BonusContract);
        BonusReserves.Run();

        //THEN
        ValidateCrMemoCreated(-SalesCrMemoLine.Amount, 0);
    end;
    #endregion ReserveToCreditMemo

    [Test]
    #region ReserveAmountJournal__ReserveType_Amount
    [HandlerFunctions('HandleReserveRequestPage,HandleGeneralJournal')]
    procedure ReserveAmountJournal__ReserveType_Amount()
    var
        BonusReserves: Report "lbtbn Bonus Reserves";
    begin
        //GIVEN
        Init(false);
        BonusContract."Reserve Type" := BonusContract."Reserve Type"::"Amount (LCY)";
        BonusContract.Modify();
        Commit(); //ansonsonsten kryptische Fehlermeldung

        //WHEN
        BonusContract.SetRecFilter();
        BonusReserves.SetTableView(BonusContract);
        BonusReserves.Run();

        //THEN
        ValidateBonusEntryCreated(0, 0);
        ValidateGenJnlLineCreated(0, 0);
    end;
    #endregion ReserveAmountJournal__ReserveType_Amount

    [Test]
    #region ReserveAmountMemo__ReserveType_Amount
    [HandlerFunctions('HandleReserveRequestPage,HandleSalesCreditMemo')]
    procedure ReserveAmountMemo__ReserveType_Amount()
    var
        BonusReserves: Report "lbtbn Bonus Reserves";
    begin
        //GIVEN
        Init(true);
        BonusContract."Reserve Type" := BonusContract."Reserve Type"::"Amount (LCY)";
        BonusContract.Modify();
        Commit(); //ansonsonsten kryptische Fehlermeldung

        //WHEN
        BonusContract.SetRecFilter();
        BonusReserves.SetTableView(BonusContract);
        BonusReserves.Run();

        //THEN
        ValidateBonusEntryCreated(0, 0);
        ValidateCrMemoCreated(BonusContract."Reserve Value", 0);
    end;
    #endregion ReserveAmountMemo__ReserveType_Amount

    [Test]
    #region Journal__FromCrMemo__ReserveType_AmountPerUnit
    [HandlerFunctions('HandleReserveRequestPage,HandleGeneralJournal')]
    procedure Journal__FromCrMemo__ReserveType_AmountPerUnit()
    var
        BonusReserves: Report "lbtbn Bonus Reserves";
    begin
        //GIVEN
        Init(false);
        BonusContract."Reserve Type" := BonusContract."Reserve Type"::"Amount per Unit";
        BonusContract.Modify();
        CreateSalesCrMemoAndPost();

        //WHEN
        BonusContract.SetRecFilter();
        BonusReserves.SetTableView(BonusContract);
        BonusReserves.Run();

        //THEN
        ValidateBonusEntryCreated(-SalesCrMemoLine.Amount, -SalesCrMemoLine.Quantity);
        ValidateGenJnlLineCreated(-SalesCrMemoLine.Amount, -SalesCrMemoLine.Quantity);
    end;
    #endregion Journal__FromCrMemo__ReserveType_AmountPerUnit

    [Test]
    #region Journal__FromInvoice__ReserveType_AmountPerUnit
    [HandlerFunctions('HandleReserveRequestPage,HandleGeneralJournal')]
    procedure Journal__FromInvoice__ReserveType_AmountPerUnit()
    var
        BonusReserves: Report "lbtbn Bonus Reserves";
    begin
        //GIVEN
        Init(false);
        BonusContract."Reserve Type" := BonusContract."Reserve Type"::"Amount per Unit";
        BonusContract.Modify();
        CreateSalesInvoiceAndPost();

        //WHEN
        BonusContract.SetRecFilter();
        BonusReserves.SetTableView(BonusContract);
        BonusReserves.Run();

        //THEN
        ValidateBonusEntryCreated(SalesInvoiceLine.Amount, SalesInvoiceLine.Quantity);
        ValidateGenJnlLineCreated(SalesInvoiceLine.Amount, SalesInvoiceLine.Quantity);
    end;
    #endregion Journal__FromInvoice__ReserveType_AmountPerUnit

    [Test]
    #region Journal__FromInvoice__ReserveType_Percentage
    [HandlerFunctions('HandleReserveRequestPage,HandleGeneralJournal')]
    procedure Journal__FromInvoice__ReserveType_Percentage()
    var
        BonusContractCard: TestPage "lbtbn Bonus Contract";
    begin
        //GIVEN
        Init(false);
        CreateSalesInvoiceAndPost();

        //WHEN
        BonusContractCard.OpenView();
        BonusContractCard.GoToRecord(BonusContract);
        BonusContractCard."Create Reserves".Invoke();

        //THEN
        ValidateGenJnlLineCreated(SalesInvoiceLine.Amount, SalesInvoiceLine.Quantity);
        ValidateBonusEntryCreated(SalesInvoiceLine.Amount, SalesInvoiceLine.Quantity);
    end;
    #endregion Journal__FromInvoice__ReserveType_Percentage

    [Test]
    #region Journal__FromCrMemo__ReserveType_Percentage
    [HandlerFunctions('HandleReserveRequestPage,HandleGeneralJournal')]
    procedure Journal__FromCrMemo__ReserveType_Percentage()
    var
        BonusContractCard: TestPage "lbtbn Bonus Contract";
    begin
        //GIVEN
        Init(false);
        CreateSalesCrMemoAndPost();

        //WHEN
        BonusContractCard.OpenView();
        BonusContractCard.GoToRecord(BonusContract);
        BonusContractCard."Create Reserves".Invoke();

        //THEN
        ValidateGenJnlLineCreated(-SalesCrMemoLine.Amount, SalesCrMemoLine.Quantity);
        ValidateBonusEntryCreated(-SalesCrMemoLine.Amount, -SalesCrMemoLine.Quantity);
    end;
    #endregion Journal__FromCrMemo__ReserveType_Percentage

    [Test]
    #region ReserveFromInvoiceAndPostGenJournal
    [HandlerFunctions('HandleReserveRequestPage,HandleGeneralJournal')]
    procedure ReserveFromInvoiceAndPostGenJournal()
    var
        GenJournalLine: Record "Gen. Journal Line";
        BonusEntry: Record "lbtbn Bonus Entry";
        BonusContractCard: TestPage "lbtbn Bonus Contract";
    begin
        //GIVEN
        Init(false);
        CreateSalesInvoiceAndPost();
        BonusContractCard.OpenView();
        BonusContractCard.GoToRecord(BonusContract);
        BonusContractCard."Create Reserves".Invoke();

        //WHEN
        GenJournalLine.SetRange("Journal Batch Name", BonusSetup."Gen. Jnl. Bonus Reserve");
        GenJournalLine.SetRange("Journal Template Name", BonusSetup."Gen.Jnl.Templ.BonusReserve");
        GenJournalLine.FindFirst();
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        //THEN
        BonusEntry.SetRange(Contract, BonusContract."No.");
        BonusEntry.FindFirst();
        Assert.AreNotEqual(0, BonusEntry."Posted Amount", 'Posted Amount should be set');

    end;
    #endregion ReserveFromInvoiceAndPostGenJournal

    #region SetPermissions
    local procedure SetPermissions()
    begin
        LibraryLowerPermissions.SetO365BusFull();
        LibraryLowerPermissions.AddPermissionSet('lbtbn Bonus');
    end;
    #endregion SetPermissions

    #region ValidateBonusEntryCreated
    local procedure ValidateBonusEntryCreated(Amount: Decimal; Quantity: Decimal): Decimal
    var
        BonusEntry: Record "lbtbn Bonus Entry";
        Expected: Decimal;
    begin
        Expected := GetExpectedAmount(Amount, Quantity);
        BonusEntry.SetRange(Contract, BonusContract."No.");
        Assert.AreEqual(1, BonusEntry.Count(), 'one bonus entry created');
        BonusEntry.FindFirst();
        Assert.AreNearlyEqual(Expected, BonusEntry."Calculated Amount", 0.005, '');
        exit(BonusEntry."Calculated Amount");
    end;
    #endregion ValidateBonusEntryCreated

    #region ValidateCrMemoCreated
    local procedure ValidateCrMemoCreated(Amount: Decimal; Quantity: Decimal): Decimal
    var
        SalesLine: Record "Sales Line";
        Expected: Decimal;
    begin
        Expected := GetExpectedAmount(Amount, Quantity);
        SalesLine.FindLast();
        // Assert.AreEqual(1, BonusEntry.count(), 'one bonus entry created');
        Assert.AreNearlyEqual(Expected, SalesLine.Amount, 0.005, '');
        exit(SalesLine.Amount);
    end;
    #endregion ValidateCrMemoCreated

    #region GetExpectedAmount
    local procedure GetExpectedAmount(Amount: Decimal; Quantity: Decimal) Expected: Decimal
    begin
        case BonusContract."Reserve Type" of
            BonusContract."Reserve Type"::"%":
                Expected := Amount * BonusContract."Reserve Value" / 100;
            BonusContract."Reserve Type"::"Amount per Unit":
                Expected := Quantity * BonusContract."Reserve Value";
            BonusContract."Reserve Type"::"Amount (LCY)":
                Expected := BonusContract."Reserve Value";
        end;
    end;
    #endregion GetExpectedAmount

    #region ValidateGenJnlLineCreated
    local procedure ValidateGenJnlLineCreated(Amount: Decimal; Quantity: Decimal)
    var
        GenJournalLine: Record "Gen. Journal Line";
        Expected: Decimal;
    begin
        GenJournalLine.SetRange("Journal Batch Name", BonusSetup."Gen. Jnl. Bonus Reserve");
        GenJournalLine.SetRange("Journal Template Name", BonusSetup."Gen.Jnl.Templ.BonusReserve");
        Assert.AreEqual(1, GenJournalLine.Count(), 'One Line created');
        GenJournalLine.FindFirst();
        Expected := GetExpectedAmount(Amount, Quantity);
        Assert.AreNearlyEqual(Expected, GenJournalLine.Amount, 0.005, 'The amount');
    end;
    #endregion ValidateGenJnlLineCreated

    #region HandleGeneralJournal
    [PageHandler]
    procedure HandleGeneralJournal(var GeneralJournal: TestPage "General Journal")
    begin
    end;
    #endregion HandleGeneralJournal

    #region HandleSalesCreditMemo
    [PageHandler]
    procedure HandleSalesCreditMemo(var SalesCreditMemo: TestPage "Sales Credit Memo")
    begin
    end;
    #endregion HandleSalesCreditMemo

    #region HandleReserveRequestPage
    [RequestPageHandler]
    procedure HandleReserveRequestPage(var BonusReserves: TestRequestPage "lbtbn Bonus Reserves")
    begin
        BonusReserves."Date From".Value := Format(WorkDate());
        BonusReserves."Date To".Value := Format(WorkDate());

        BonusReserves.OK().Invoke();
    end;
    #endregion HandleReserveRequestPage

    #region Init
    local procedure Init(ReserverModeCreditMemo: Boolean)
    var
        ItemChargeNo: Code[20];
    begin
        SetPermissions();
        if ReserverModeCreditMemo then
            InitBonusSetupForCrMemo()
        else
            InitBonusSetupForJournal();
        ItemChargeNo := CreateCustomerAndItemCharge();
        CreateBonusContract(ItemChargeNo);
        CreateBonusCustomer();
        CreateBonusItems();
    end;
    #endregion Init

    #region CreateSalesInvoiceAndPost
    local procedure CreateSalesInvoiceAndPost()
    var
        SalesHeader: Record "Sales Header";
        DocNo: Code[20];
    begin
        LibrarySales.CreateSalesInvoiceForCustomerNo(SalesHeader, Customer."No.");
        DocNo := LibrarySales.PostSalesDocument(SalesHeader, false, true);
        SalesInvoiceLine.SetRange("Document No.", DocNo);
        SalesInvoiceLine.FindFirst();
    end;
    #endregion CreateSalesInvoiceAndPost

    #region CreateSalesCrMemoAndPost
    local procedure CreateSalesCrMemoAndPost()
    var
        SalesHeader: Record "Sales Header";
        Item: Record Item;
        SalesLine: Record "Sales Line";
        DocNo: Code[20];
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::"Credit Memo", Customer."No.");
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(
          Item, LibraryRandom.RandDecInRange(1, 100, 2), LibraryRandom.RandDecInRange(1, 100, 2));
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", LibraryRandom.RandInt(100));

        DocNo := LibrarySales.PostSalesDocument(SalesHeader, false, true);
        SalesCrMemoLine.SetRange("Document No.", DocNo);
        SalesCrMemoLine.FindFirst();
    end;
    #endregion CreateSalesCrMemoAndPost

    #region CreateBonusContract
    local procedure CreateBonusContract(ItemChargeNo: Code[20])
    var
        ReserveCustomer: Record Customer;
    begin
        LibrarySales.CreateCustomer(ReserveCustomer);

        BonusContract.Init();
        BonusContract."No." := LibraryUtility.GenerateRandomCode20(BonusContract.FieldNo("No."), Database::"lbtbn Bonus Contract");
        BonusContract."Reserve Value" := LibraryRandom.RandDecInDecimalRange(2.0, 12.0, 1);
        BonusContract."Reserve Item Charge" := ItemChargeNo;
        BonusContract."Customer Reserve Cr.Memo" := ReserveCustomer."No.";
        BonusContract.Insert();
    end;
    #endregion CreateBonusContract

    #region CreateNoSeriesAndLine
    local procedure CreateNoSeriesAndLine(): Code[20]
    var
        NoSeriesLine: Record "No. Series Line";
        NoSeries: Record "No. Series";
    begin
        LibraryUtility.CreateNoSeries(NoSeries, true, true, true);
        LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, NoSeries.Code, '');
        exit(NoSeries.Code);
    end;
    #endregion CreateNoSeriesAndLine

    #region CreateBonusCustomer
    local procedure CreateBonusCustomer()
    var
        BonusCustomers: Record "lbtbn Bonus Customer";
    begin
        BonusCustomers.Init();
        BonusCustomers.Contract := BonusContract."No.";
        BonusCustomers."Customer No." := Customer."No.";
        BonusCustomers.Insert();
    end;
    #endregion CreateBonusCustomer

    #region CreateCustomerAndItemCharge
    local procedure CreateCustomerAndItemCharge(): Code[20]
    var
        VATPostingSetup: Record "VAT Posting Setup";
        ItemCharge: Record "Item Charge";
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        LibraryInventory.CreateItemCharge(ItemCharge);
        LibrarySales.CreateCustomer(Customer);

        CustomerPostingGroup.Get(Customer."Customer Posting Group");
        CustomerPostingGroup."lbtbn Reserve Account" := LibraryERM.CreateGLAccountNo();
        CustomerPostingGroup."lbtbn Reserve Bal. Account" := LibraryERM.CreateGLAccountNo();
        CustomerPostingGroup.Modify();

        if not VATPostingSetup.Get(Customer."VAT Bus. Posting Group", ItemCharge."VAT Prod. Posting Group") then
            LibraryERM.CreateVATPostingSetup(VATPostingSetup, Customer."VAT Bus. Posting Group", ItemCharge."VAT Prod. Posting Group");
        exit(ItemCharge."No.");
    end;
    #endregion CreateCustomerAndItemCharge

    #region InitBonusSetupForJournal
    local procedure InitBonusSetupForJournal()
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        BonusSetup.Init();
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        BonusSetup."Reserve Mode" := BonusSetup."Reserve Mode"::Journal;
        BonusSetup."Gen.Jnl.Templ.BonusReserve" := GenJournalTemplate.Name;
        BonusSetup."Gen. Jnl. Bonus Reserve" := GenJournalBatch.Name;
        BonusSetup.Modify();
    end;
    #endregion InitBonusSetupForJournal

    #region InitBonusSetupForCrMemo
    local procedure InitBonusSetupForCrMemo()
    begin
        BonusSetup.Init();
        BonusSetup."Reserve Mode" := BonusSetup."Reserve Mode"::CreditMemo;
        BonusSetup."Reserve Cr.Memo Nos." := CreateNoSeriesAndLine();
        BonusSetup.Modify();
    end;
    #endregion InitBonusSetupForCrMemo

    #region CreateBonusItems
    local procedure CreateBonusItems()
    var
        BonusItem: Record "lbtbn Bonus Item";
    begin
        BonusItem.Init();
        BonusItem."Contract No." := BonusContract."No.";
        BonusItem.Insert(true);
    end;
    #endregion CreateBonusItems
}