codeunit 52050 "lbtbn Bonus Run Test"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;

    [Test]
    [HandlerFunctions('HandleBonusRequestPage,HandleSalesCrMemoPage')]
    procedure SalesReturnOrderWithAssignedItemCharge_CreditMemo()
    var
        Amount: Decimal;
    begin
        //GIVEN
        Init(true);
        Amount := PostReturnOrder();

        //WHEN
        ExecuteBonusRun();

        //THEN
        ValidateCreditMemoCreated(Amount, 0);
        ValidateBonusEntryCreated(Amount, 0);
    end;

    [Test]
    #region CreditMemo_From_Invoice
    [HandlerFunctions('HandleBonusRequestPage,HandleSalesCrMemoPage')]
    procedure CreditMemo_From_Invoice()
    begin
        //GIVEN
        Init(true);
        CreateSalesInvoiceAndPost();

        //WHEN
        ExecuteBonusRun();

        //THEN
        ValidateCreditMemoCreated(SalesInvoiceLine.Amount, SalesInvoiceLine.Quantity);
    end;
    #endregion CreditMemo_From_Invoice

    [Test]
    #region CreditMemo_From_CrMemo
    [HandlerFunctions('HandleBonusRequestPage')]
    procedure CreditMemo_From_CrMemo()
    begin
        //GIVEN
        Init(true);
        CreateSalesCrMemoAndPost();

        //WHEN
        ExecuteBonusRun();

        //THEN
        ValidateNoCreditMemoCreated();
    end;
    #endregion CreditMemo_From_CrMemo

    [PageHandler]
    procedure HandleSalesCrMemoPage(var Page: TestPage "Sales Credit Memo")
    begin

    end;

    #region HandleBonusRequestPage
    [RequestPageHandler]
    procedure HandleBonusRequestPage(var BonusRun: TestRequestPage "lbtbn Bonus Run")
    begin
        BonusRun."Date From".Value := Format(WorkDate());
        BonusRun."Date To".Value := Format(WorkDate());

        BonusRun.OK().Invoke();
    end;
    #endregion HandleBonusRequestPage

    #region Init
    local procedure Init(ModeCreditMemo: Boolean)
    var
        ItemChargeNo: Code[20];
    begin
        SetPermissions();
        if ModeCreditMemo then
            InitBonusSetupForCrMemo()
        else
            InitBonusSetupForJournal();
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        ItemChargeNo := CreateCustomerAndItemCharge();
        CreateBonusContract(ItemChargeNo);
        CreateBonusCustomer();
        CreateBonusItems();
    end;
    #endregion Init

    #region SetPermissions
    local procedure SetPermissions()
    begin
        LibraryLowerPermissions.SetO365BusFull();
        LibraryLowerPermissions.AddPermissionSet('lbtbn Bonus');
    end;
    #endregion SetPermissions

    #region CreateSalesInvoiceAndPost
    local procedure CreateSalesInvoiceAndPost()
    var
        SalesHeader: Record "Sales Header";
        BonusRunTest: Codeunit "lbtbn Bonus Run Test";
        DocNo: Code[20];
    begin
        BindSubscription(BonusRunTest);
        BonusRunTest.SetBaseUnitOfMeasure(UnitOfMeasure);
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
        BonusRunTest: Codeunit "lbtbn Bonus Run Test";
    begin
        BonusRunTest.SetBaseUnitOfMeasure(UnitOfMeasure);
        BindSubscription(BonusRunTest);
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
        RecipientCustomer: Record Customer;
    begin
        LibrarySales.CreateCustomer(RecipientCustomer);

        BonusContract.Init();
        BonusContract."No." := LibraryUtility.GenerateRandomCode20(BonusContract.FieldNo("No."), Database::"lbtbn Bonus Contract");
        BonusContract."Bonus Scale Type" := BonusContract."Bonus Scale Type"::"Sales (LCY)";
        BonusContract."Accounting Item Charge" := ItemChargeNo;
        BonusContract."Bonus Recipient" := RecipientCustomer."No.";
        BonusContract."Item Unit of Measure" := UnitOfMeasure.Code;
        BonusContract.Insert();

        BonusContractLine.Init();
        BonusContractLine.Contract := BonusContract."No.";
        BonusContractLine."Line No." := 10000;
        BonusContractLine.Insert();
        BonusContractLine.Validate(Value, LibraryRandom.RandDecInDecimalRange(2.0, 12.0, 1));
        BonusContractLine.Modify();
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
        BonusSetup."Billing Cr.Memo Nos." := CreateNoSeriesAndLine();
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

    #region ValidateNoCreditMemoCreated
    local procedure ValidateNoCreditMemoCreated()
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetRange("Sell-to Customer No.", BonusContract."Bonus Recipient");
        Assert.AreEqual(0, SalesHeader.Count(), 'there should be no credit memo, because the bonus amount is <0');
    end;
    #endregion ValidateNoCreditMemoCreated

    #region ValidateCreditMemoCreated
    local procedure ValidateCreditMemoCreated(Amount: Decimal; Quantity: Decimal)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Expected: Decimal;
    begin
        SalesHeader.SetRange("Sell-to Customer No.", BonusContract."Bonus Recipient");
        SalesHeader.FindLast();
        Assert.AreEqual(SalesHeader."Document Date", WorkDate(), '');

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::"Charge (Item)");

        SalesLine.FindLast();
        Expected := GetExpectedAmount(Amount, Quantity);
        Assert.AreNearlyEqual(Expected, SalesLine.Amount, 0.005, 'The amount');
    end;
    #endregion ValidateCreditMemoCreated
    #region GetExpectedAmount
    local procedure GetExpectedAmount(Amount: Decimal; Quantity: Decimal) Expected: Decimal
    begin
        case BonusContract."Bonus Billing Type" of
            BonusContract."Bonus Billing Type"::"%":
                Expected := Amount * BonusContractLine.Value / 100;
            BonusContract."Bonus Billing Type"::"Amount per Unit":
                Expected := Quantity * BonusContractLine.Value / 100;
            BonusContract."Bonus Billing Type"::"Amount (LCY)":
                Expected := BonusContractLine.Value;
        end;
    end;
    #endregion GetExpectedAmount

    #region ExecuteBonusRun
    local procedure ExecuteBonusRun()
    var
        BonusRun: Report "lbtbn Bonus Run";
    begin
        BonusContract.SetRecFilter();
        BonusRun.SetTableView(BonusContract);
        BonusRun.Run();
    end;
    #endregion ExecuteBonusRun

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

    local procedure PostReturnOrder() Amount: Decimal
    var
        SalesHeader: Record "Sales Header";
        ItemCharge: Record "Item Charge";
        Item: Record Item;
        SalesLine: Record "Sales Line";
        SalesLine2: Record "Sales Line";
        ItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)";
        BonusRunTest: Codeunit "lbtbn Bonus Run Test";
        DocNo: Code[20];
    begin
        BindSubscription(BonusRunTest);
        BonusRunTest.SetBaseUnitOfMeasure(UnitOfMeasure);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::"Return Order", Customer."No.");
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(
          Item, LibraryRandom.RandDecInRange(1, 100, 2), LibraryRandom.RandDecInRange(1, 100, 2));
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", LibraryRandom.RandInt(100));
        LibraryInventory.CreateItemCharge(ItemCharge);
        ItemCharge."lbtbn Bonus consider" := true;
        ItemCharge.Modify();
        LibrarySales.CreateSalesLine(SalesLine2, SalesHeader, SalesLine.Type::"Charge (Item)", ItemCharge."No.", 1);
        SalesLine2.Validate("Unit Price", 500);
        SalesLine2.Modify();
        LibrarySales.CreateItemChargeAssignment(ItemChargeAssignmentSales, SalesLine2, ItemCharge, "Sales Document Type"::"Return Order", SalesHeader."No.", SalesLine."Line No.", SalesLine."No.", 1, SalesLine2."Unit Price");
        ItemChargeAssignmentSales.Insert();

        DocNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesCrMemoLine.SetRange("Document No.", DocNo);
        SalesCrMemoLine.FindFirst();
        Amount := -(SalesLine."Line Amount" + SalesLine2."Line Amount");
    end;

    internal procedure SetBaseUnitOfMeasure(UnitOfMeasure: Record "Unit of Measure")
    begin
        UnitOfMeasureCode := UnitOfMeasure.Code;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Inventory", 'OnAfterCreateItem', '', false, false)]
    local procedure "Library - Inventory_OnAfterCreateItem"(var Item: Record Item)
    begin
        Item.Validate("Base Unit of Measure", UnitOfMeasureCode);
    end;


    var
        BonusSetup: Record "lbtbn Bonus Setup";
        Customer: Record Customer;
        BonusContract: Record "lbtbn Bonus Contract";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        BonusContractLine: Record "lbtbn Bonus Contract Line";
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryERM: Codeunit "Library - ERM";
        Assert: Codeunit Assert;
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        UnitOfMeasure: Record "Unit of Measure";
        UnitOfMeasureCode: Code[10];
}