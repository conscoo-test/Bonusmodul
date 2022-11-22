codeunit 5266058 "lbtbn Find Document Nos."
{
    procedure FindDocumentNos(ContractNo: Code[20]; var Invoices: List of [Code[20]]; var CreditMemos: List of [Code[20]]; DateFrom: Date; DateTo: Date)
    var
        BonusCustomer: Record "lbtbn Bonus Customer";
        Customer: Record Customer;
    begin
        Clear(Invoices);
        Clear(CreditMemos);
        BonusCustomer.SetRange(Contract, ContractNo);
        if BonusCustomer.FindSet() then
            repeat
                if BonusCustomer."Customer Group" <> '' then begin
                    Customer.SetRange("lbtbn Customer Group", BonusCustomer."Customer Group");
                    if Customer.FindSet() then
                        repeat
                            FindInvoiceNosForCustomer(Customer."No.", Invoices, DateFrom, DateTo);
                            FindCreditMemoNosForCustomer(Customer."No.", CreditMemos, DateFrom, DateTo);
                        until Customer.Next() = 0;
                end;
                if BonusCustomer."Customer No." <> '' then begin
                    FindInvoiceNosForCustomer(BonusCustomer."Customer No.", BonusCustomer."Ship-to Code", Invoices, DateFrom, DateTo);
                    FindCreditMemoNosForCustomer(BonusCustomer."Customer No.", BonusCustomer."Ship-to Code", CreditMemos, DateFrom, DateTo);
                end;
            until BonusCustomer.Next() = 0;
    end;

    local procedure FindInvoiceNosForCustomer(CustomerNo: Code[20]; var Invoices: List of [Code[20]]; DateFrom: Date; DateTo: Date)
    begin
        FindInvoiceNosForCustomer(CustomerNo, '', Invoices, DateFrom, DateTo);
    end;

    local procedure FindInvoiceNosForCustomer(CustomerNo: Code[20]; ShipToCode: Code[20]; var Invoices: List of [Code[20]]; DateFrom: Date; DateTo: Date)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        SalesInvoiceHeader.SetRange("Sell-to Customer No.", CustomerNo);
        SalesInvoiceHeader.SetRange("Posting Date", DateFrom, DateTo);
        if ShipToCode <> '' then
            SalesInvoiceHeader.SetRange("Ship-to Code", ShipToCode);
        if SalesInvoiceHeader.FindSet() then
            repeat
                if not Invoices.Contains(SalesInvoiceHeader."No.") then
                    Invoices.Add(SalesInvoiceHeader."No.");
            until SalesInvoiceHeader.Next() = 0;
    end;

    local procedure FindCreditMemoNosForCustomer(CustomerNo: Code[20]; var CreditMemos: List of [Code[20]]; DateFrom: Date; DateTo: Date)
    begin
        FindCreditMemoNosForCustomer(CustomerNo, '', CreditMemos, DateFrom, DateTo);
    end;

    local procedure FindCreditMemoNosForCustomer(CustomerNo: Code[20]; ShipToCode: Code[20]; var CreditMemos: List of [Code[20]]; DateFrom: Date; DateTo: Date)
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        SalesCrMemoHeader.SetRange("Sell-to Customer No.", CustomerNo);
        SalesCrMemoHeader.SetRange("Posting Date", DateFrom, DateTo);
        if ShipToCode <> '' then
            SalesCrMemoHeader.SetRange("Ship-to Code", ShipToCode);
        if SalesCrMemoHeader.FindSet() then
            repeat
                if not CreditMemos.Contains(SalesCrMemoHeader."No.") then
                    CreditMemos.Add(SalesCrMemoHeader."No.");
            until SalesCrMemoHeader.Next() = 0;
    end;
}