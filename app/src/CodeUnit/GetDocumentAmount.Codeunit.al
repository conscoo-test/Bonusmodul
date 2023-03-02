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
        LineAmount: Decimal;
    begin
        SalesInvoiceLine.SetRange("Document No.", No);
        SalesInvoiceLine.SetFilter(Type, '%1|%2', SalesInvoiceLine.Type::Item, SalesInvoiceLine.Type::"Charge (Item)");
        if SalesInvoiceLine.FindSet() then
            repeat
                if CheckItemMeth.CheckItem(BonusContractNo, GetItemNo(SalesInvoiceLine)) then begin
                    Quantity += SalesInvoiceLine.Quantity;
                    LineAmount := SalesInvoiceLine.Amount;
                    UpdateDocAmountFromValueEntry(
                                Database::"Sales Invoice Line",
                                SalesInvoiceLine."Document No.",
                                SalesInvoiceLine."Line No.",
                                LineAmount);
                    Amount += LineAmount;
                end;
            until SalesInvoiceLine.Next() = 0;
    end;
    #endregion GetQuantityAndAmountInvoice

    #region GetQuantityAndAmountCrMemo
    local procedure GetQuantityAndAmountCrMemo(var Quantity: Decimal; var Amount: Decimal; No: Code[20])
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        LineAmount: Decimal;
    begin
        SalesCrMemoLine.SetRange("Document No.", No);
        SalesCrMemoLine.SetFilter(Type, '%1|%2', SalesCrMemoLine.Type::Item, SalesCrMemoLine.Type::"Charge (Item)");
        if SalesCrMemoLine.FindSet() then
            repeat
                if CheckItemMeth.CheckItem(BonusContractNo, GetItemNo(SalesCrMemoLine)) then begin
                    Quantity -= SalesCrMemoLine.Quantity;
                    LineAmount := -SalesCrMemoLine.Amount;
                    UpdateDocAmountFromValueEntry(
                                Database::"Sales Cr.Memo Line",
                                SalesCrMemoLine."Document No.",
                                SalesCrMemoLine."Line No.",
                                LineAmount);
                    Amount += SalesCrMemoLine.Amount;
                end;
            until SalesCrMemoLine.Next() = 0;
    end;
    #endregion GetQuantityAndAmountCrMemo

    #region GetItemNo Credit Memo
    local procedure GetItemNo(var SalesCrMemoLine: Record "Sales Cr.Memo Line") ItemNo: Code[20]
    var
        ValueEntry: Record "Value Entry";
    begin
        if SalesCrMemoLine.Type = SalesCrMemoLine.Type::Item then
            ItemNo := SalesCrMemoLine."No."
        else begin
            ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Credit Memo");
            ValueEntry.SetRange("Document No.", SalesCrMemoLine."Document No.");
            ValueEntry.SetRange("Document Line No.", SalesCrMemoLine."Line No.");
            if ValueEntry.FindFirst() then
                ItemNo := ValueEntry."Item No.";
        end;
    end;
    #endregion GetItemNo

    #region GetItemNo Invoice
    local procedure GetItemNo(var SalesInvoiceLine: Record "Sales Invoice Line") ItemNo: Code[20]
    var
        ValueEntry: Record "Value Entry";
    begin
        if SalesInvoiceLine.Type = SalesInvoiceLine.Type::Item then
            ItemNo := SalesInvoiceLine."No."
        else begin
            ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Invoice");
            ValueEntry.SetRange("Document No.", SalesInvoiceLine."Document No.");
            ValueEntry.SetRange("Document Line No.", SalesInvoiceLine."Line No.");
            if ValueEntry.FindFirst() then
                ItemNo := ValueEntry."Item No.";
        end;
    end;
    #endregion GetItemNo


    #region UpdateDocAmountFromValueEntry
    procedure UpdateDocAmountFromValueEntry(TableNo: Integer; DocNo: Code[20]; DocLineNo: Integer; var DocAmount: Decimal)
    var
        ValueEntry: Record "Value Entry";
        CreateBonus: Codeunit "lbtbn Create Bonus";
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
                    DocAmount += CreateBonus.AddConsideredItemCharges(ValueEntry."Item Ledger Entry No.");
            until ValueEntry.Next() = 0;
    end;
    #endregion UpdateDocAmountFromValueEntry
}