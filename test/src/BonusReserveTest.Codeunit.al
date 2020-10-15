codeunit 5266062 "lbt Bonus Reserve Test"
{
    Subtype = Test;

    var
        BonusSetup: Record "lbt Bonus Setup";
        Customer: Record Customer;
        BonusContract: Record "lbt Bonus Contract";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryERM: Codeunit "Library - ERM";
        Assert: Codeunit Assert;

    [Test]
    [HandlerFunctions('HandleReserveRequestPage,HandleSalesCreditMemo')]
    procedure ReserveToCreditMemo()
    var
        BonusReserves: Report "lbt Bonus Reserves";
    begin
        //GIVEN
        InitWithReserveModeCreditMemo();
        CreateSalesCrMemoAndPost();
        Commit();

        //WHEN
        BonusContract.SetRecFilter();
        BonusReserves.SetTableView(BonusContract);
        BonusReserves.Run();

        //THEN
        ValidateCrMemoCreated(SalesCrMemoLine.Amount, 0);
    end;



    [Test]
    [HandlerFunctions('HandleReserveRequestPage,HandleGeneralJournal')]
    procedure ReserveAmountJournal__ReserveType_Amount()
    var
        BonusReserves: Report "lbt Bonus Reserves";
    begin
        //GIVEN
        Init();
        BonusContract."Reserve Type" := BonusContract."Reserve Type"::"Amount (LCY)";
        BonusContract.Modify();
        Commit();

        //WHEN
        BonusContract.SetRecFilter();
        BonusReserves.SetTableView(BonusContract);
        BonusReserves.Run();

        //THEN
        ValidateBonusEntryCreated(0, 0);
        ValidateGenJnlLineCreated(0, 0);
    end;

    [Test]
    [HandlerFunctions('HandleReserveRequestPage,HandleSalesCreditMemo')]
    procedure ReserveAmountMemo__ReserveType_Amount()
    var
        BonusReserves: Report "lbt Bonus Reserves";
    begin
        //GIVEN
        InitWithReserveModeCreditMemo();
        BonusContract."Reserve Type" := BonusContract."Reserve Type"::"Amount (LCY)";
        BonusContract.Modify();
        Commit();

        //WHEN
        BonusContract.SetRecFilter();
        BonusReserves.SetTableView(BonusContract);
        BonusReserves.Run();

        Commit();
        //THEN
        ValidateBonusEntryCreated(0, 0);
        ValidateCrMemoCreated(BonusContract."Reserve Value", 0);
    end;


    [Test]
    [HandlerFunctions('HandleReserveRequestPage,HandleGeneralJournal')]
    procedure ReserveAmountPerUnit()
    var
        BonusReserves: Report "lbt Bonus Reserves";
    begin
        //GIVEN
        Init();
        BonusContract."Reserve Type" := BonusContract."Reserve Type"::"Amount per Unit";
        BonusContract.Modify();
        CreateSalesCrMemoAndPost();
        Commit();

        //WHEN
        BonusContract.SetRecFilter();
        BonusReserves.SetTableView(BonusContract);
        BonusReserves.Run();

        //THEN
        ValidateBonusEntryCreatedCrMemo();
    end;

    [Test]
    [HandlerFunctions('HandleReserveRequestPage,HandleGeneralJournal')]
    procedure ReserveAmountPerUnitInvoice()
    var
        BonusReserves: Report "lbt Bonus Reserves";
    begin
        //GIVEN
        Init();
        BonusContract."Reserve Type" := BonusContract."Reserve Type"::"Amount per Unit";
        BonusContract.Modify();
        CreateSalesInvoiceAndPost();
        Commit();

        //WHEN
        BonusContract.SetRecFilter();
        BonusReserves.SetTableView(BonusContract);
        BonusReserves.Run();

        //THEN
        ValidateBonusEntryCreated(SalesInvoiceLine.Amount, SalesInvoiceLine.Quantity);
        ValidateGenJnlLineCreated(0, SalesInvoiceLine.Quantity);
    end;

    [Test]
    [HandlerFunctions('HandleReserveRequestPage,HandleGeneralJournal')]
    procedure ReserveFromInvoice()
    var
        BonusContractCard: TestPage "lbt Bonus Contract Card";
    begin
        //GIVEN
        Init();
        CreateSalesInvoiceAndPost();
        Commit();

        //WHEN
        BonusContractCard.OpenView();
        BonusContractCard.GoToRecord(BonusContract);
        BonusContractCard."Create Reserves".Invoke();

        //THEN
        ValidateGenJnlLineCreated(SalesInvoiceLine.Amount, SalesInvoiceLine.Quantity);
        ValidateBonusEntryCreated(SalesInvoiceLine.Amount, SalesInvoiceLine.Quantity);
    end;

    [Test]
    [HandlerFunctions('HandleReserveRequestPage,HandleGeneralJournal')]
    procedure ReserveFromCrMemo()
    var
        BonusContractCard: TestPage "lbt Bonus Contract Card";
    begin
        //GIVEN
        Init();
        CreateSalesCrMemoAndPost();
        Commit();

        //WHEN
        BonusContractCard.OpenView();
        BonusContractCard.GoToRecord(BonusContract);
        BonusContractCard."Create Reserves".Invoke();

        //THEN
        ValidateGenJnlLineCreated(-SalesCrMemoLine.Amount, SalesCrMemoLine.Quantity);
        ValidateBonusEntryCreatedCrMemo();
    end;

    [Test]
    [HandlerFunctions('HandleReserveRequestPage,HandleGeneralJournal')]
    procedure ReserveFromInvoiceAndPostGenJournal()
    var
        GenJournalLine: Record "Gen. Journal Line";
        BonusEntry: Record "lbt Bonus Entry";
        BonusContractCard: TestPage "lbt Bonus Contract Card";
    begin
        //GIVEN
        Init();
        CreateSalesInvoiceAndPost();
        Commit();
        BonusContractCard.OpenView();
        BonusContractCard.GoToRecord(BonusContract);
        BonusContractCard."Create Reserves".Invoke();

        //WHEN
        GenJournalLine.setrange("Journal Batch Name", BonusSetup."Gen. Jnl. Bonus Reserve");
        GenJournalLine.SetRange("Journal Template Name", BonusSetup."Gen.Jnl.Templ.BonusReserve");
        GenJournalLine.FindFirst();
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        //THEN
        BonusEntry.SetRange(Contract, BonusContract.Contract);
        BonusEntry.FindFirst();
        Assert.AreNotEqual(0, BonusEntry."Posted Amount", 'Posted Amount should be set');

    end;

    local procedure ValidateBonusEntryCreated(Amount: Decimal; Quantity: Decimal): Decimal
    var
        BonusEntry: Record "lbt Bonus Entry";
        Expected: Decimal;
    begin
        Expected := GetExpectedAmount(Amount, Quantity);
        BonusEntry.SetRange(Contract, BonusContract.Contract);
        Assert.AreEqual(1, BonusEntry.count(), 'one bonus entry created');
        BonusEntry.FindFirst();
        Assert.AreNearlyEqual(Expected, BonusEntry."Calculated Amount", 0.005, '');
        exit(BonusEntry."Calculated Amount");
    end;

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

    local procedure ValidateBonusEntryCreatedCrMemo()
    var
        CalculatedAmount: Decimal;
    begin
        ValidateBonusEntryCreated(-SalesCrMemoLine.Amount, -SalesCrMemoLine.Quantity);

        Assert.IsFalse(CalculatedAmount > 0, 'the amount mustn''t be greater than 0');
    end;

    local procedure ValidateGenJnlLineCreated(Amount: Decimal; Quantity: Decimal)
    var
        GenJournalLine: Record "Gen. Journal Line";
        Expected: Decimal;
    begin
        GenJournalLine.setrange("Journal Batch Name", BonusSetup."Gen. Jnl. Bonus Reserve");
        GenJournalLine.SetRange("Journal Template Name", BonusSetup."Gen.Jnl.Templ.BonusReserve");
        Assert.AreEqual(1, GenJournalLine.Count(), 'One Line created');
        GenJournalLine.FindFirst();
        Expected := GetExpectedAmount(Amount, Quantity);
        Assert.AreNearlyEqual(Expected, GenJournalLine.Amount, 0.005, 'The amount');
    end;

    [PageHandler]
    procedure HandleGeneralJournal(var page: TestPage "General Journal")
    begin

    end;

    [PageHandler]
    procedure HandleSalesCreditMemo(var SalesCreditMemo: TestPage "Sales Credit Memo")
    begin

    end;

    [RequestPageHandler]
    procedure HandleReserveRequestPage(var BonusReservesRequest: TestRequestPage "lbt Bonus Reserves")
    begin
        BonusReservesRequest."Date From".Value := format(WorkDate());
        BonusReservesRequest."Date To".Value := format(WorkDate());

        BonusReservesRequest.OK().Invoke();
    end;

    local procedure Init()
    var
        BonusCustomers: Record "lbt Bonus Customers";
        CustomerPostingGroup: Record "Customer Posting Group";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";

    begin
        BonusSetup.Init();
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        BonusSetup."Gen.Jnl.Templ.BonusReserve" := GenJournalTemplate.Name;
        BonusSetup."Gen. Jnl. Bonus Reserve" := GenJournalBatch.Name;
        BonusSetup.Modify();
        LibrarySales.CreateCustomer(Customer);

        CustomerPostingGroup.Get(Customer."Customer Posting Group");
        CustomerPostingGroup."lbt Bonus Reserve Account" := LibraryERM.CreateGLAccountNo();
        CustomerPostingGroup."lbt Bonus Reserve Bal. Account" := LibraryERM.CreateGLAccountNo();
        CustomerPostingGroup.Modify();


        BonusContract.Init();
        BonusContract.Contract := LibraryUtility.GenerateRandomCode20(BonusContract.fieldno(Contract), Database::"lbt Bonus Contract");
        BonusContract."Reserve Value" := LibraryRandom.RandDecInDecimalRange(2.0, 12.0, 1);
        BonusContract."Reserve Item Charge" := LibraryInventory.CreateItemChargeNo();
        BonusContract.Insert();

        BonusCustomers.Init();
        BonusCustomers.Contract := BonusContract.Contract;
        BonusCustomers.Customer := Customer."No.";
        BonusCustomers.Insert();
    end;

    local procedure InitWithReserveModeCreditMemo()
    var
        ItemChargeNo: Code[20];
    begin
        BonusSetup.Init();
        BonusSetup."Reserve Mode" := BonusSetup."Reserve Mode"::CreditMemo;
        BonusSetup."Reserve Cr.Memo Nos." := CreateNoSeriesAndLine();
        BonusSetup.Modify();

        ItemChargeNo := CreateCustomerAndItemCharge();

        CreateBonusContract(ItemChargeNo);
        CreateBonusCustomer();
    end;

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

    local procedure CreateBonusContract(ItemChargeNo: Code[20])
    var
        ReserveCustomer: Record Customer;
    begin
        LibrarySales.createcustomer(ReserveCustomer);

        BonusContract.Init();
        BonusContract.Contract := LibraryUtility.GenerateRandomCode20(BonusContract.fieldno(Contract), Database::"lbt Bonus Contract");
        BonusContract."Reserve Value" := LibraryRandom.RandDecInDecimalRange(2.0, 12.0, 1);
        BonusContract."Reserve Item Charge" := ItemChargeNo;
        BonusContract."Customer Reserve Cr.Memo" := ReserveCustomer."No.";
        BonusContract.Insert();
    end;

    local procedure CreateNoSeriesAndLine(): Code[20]
    var
        NoSeriesLine: Record "No. Series Line";
        NoSeries: Record "No. Series";
    begin
        LibraryUtility.CreateNoSeries(NoSeries, true, true, true);
        LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, NoSeries.Code, '');
        exit(NoSeries.Code);
    end;

    local procedure CreateBonusCustomer()
    var
        BonusCustomers: Record "lbt Bonus Customers";
    begin
        BonusCustomers.Init();
        BonusCustomers.Contract := BonusContract.Contract;
        BonusCustomers.Customer := Customer."No.";
        BonusCustomers.Insert();
    end;

    local procedure CreateCustomerAndItemCharge(): Code[20]
    var
        VATPostingSetup: Record "VAT Posting Setup";
        ItemCharge: Record "Item Charge";
    begin
        LibraryInventory.CreateItemCharge(ItemCharge);
        LibrarySales.CreateCustomer(Customer);

        if not VATPostingSetup.Get(Customer."VAT Bus. Posting Group", ItemCharge."VAT Prod. Posting Group") then
            LibraryERM.CreateVATPostingSetup(VATPostingSetup, Customer."VAT Bus. Posting Group", ItemCharge."VAT Prod. Posting Group");
        exit(ItemCharge."No.");
    end;
}