codeunit 5266059 "lbtbn Get Document Amount"
{
    var
        CheckItemMeth: Codeunit "lbtbn CheckItem Meth";
        BonusContractNo: Code[20];

    #region AddQuantityAndAmount
    procedure AddQuantityAndAmount(var Quantity: Decimal; var Amount: Decimal; Invoices: List of [Code[20]]; CreditMemos: List of [Code[20]]; CheckItemMeth2: Codeunit "lbtbn CheckItem Meth"; BonusContractNo2: Code[20])
    var
        DocNo: Code[20];
    begin
        CheckItemMeth := CheckItemMeth2;
        BonusContractNo := BonusContractNo2;
        foreach DocNo in Invoices do
            GetQuantityAndAmountInvoice(Quantity, Amount, DocNo);

        foreach DocNo in CreditMemos do
            GetQuantityAndAmountCrMemo(Quantity, Amount, DocNo);
    end;
    #endregion AddQuantityAndAmount

    #region GetQuantityAndAmountInvoice
    local procedure GetQuantityAndAmountInvoice(var Quantity: Decimal; var Amount: Decimal; No: Code[20])
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        SalesInvoiceLine.SetRange("Document No.", No);
        SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
        if SalesInvoiceLine.FindSet() then
            repeat
                if CheckItemMeth.CheckItem(BonusContractNo, SalesInvoiceLine."No.") then begin
                    Quantity += SalesInvoiceLine.Quantity;
                    Amount += SalesInvoiceLine.Amount;
                end;
            until SalesInvoiceLine.Next() = 0;
    end;
    #endregion GetQuantityAndAmountInvoice

    #region GetQuantityAndAmountCrMemo
    local procedure GetQuantityAndAmountCrMemo(var Quantity: Decimal; var Amount: Decimal; No: Code[20])
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        SalesCrMemoLine.SetRange("Document No.", No);
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
        if SalesCrMemoLine.FindSet() then
            repeat
                if CheckItemMeth.CheckItem(BonusContractNo, SalesCrMemoLine."No.") then begin
                    Quantity -= SalesCrMemoLine.Quantity;
                    Amount -= SalesCrMemoLine.Amount;
                end;
            until SalesCrMemoLine.Next() = 0;
    end;
    #endregion GetQuantityAndAmountCrMemo

}