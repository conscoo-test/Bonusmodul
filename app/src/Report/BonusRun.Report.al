report 5266052 "lbtbn Bonus Run"
{
    UsageCategory = Tasks;
    ApplicationArea = All;
    Caption = 'Bonus Run';
    ProcessingOnly = true;

    dataset
    {
        #region dataitem
        dataitem("Bonus Contract"; "lbtbn Bonus Contract")
        {
            RequestFilterFields = "No.";

            #region dataitems
            dataitem(Invoices; Integer)
            {
                DataItemTableView = sorting(Number);

                #region OnAfterGetRecord
                trigger OnAfterGetRecord()
                var
                    SalesInvoiceHeader: Record "Sales Invoice Header";
                    SalesInvoiceLine: Record "Sales Invoice Line";
                begin
                    SalesInvoiceHeader.Get(InvoiceNos.Get(Number));
                    Dialog.Update(3, SalesInvoiceHeader."No.");
                    CreateBonus.SetDocument(SalesInvoiceHeader."Sell-to Customer No.", SalesInvoiceHeader."Ship-to Code", SalesInvoiceHeader."Currency Factor");
                    SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
                    SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
                    if SalesInvoiceLine.FindSet() then
                        repeat
                            CreateBonus.CreateBonus(SalesInvoiceLine);
                        until SalesInvoiceLine.Next() = 0;
                end;
                #endregion OnAfterGetRecord

                #region OnPreDataItem
                trigger OnPreDataItem()
                begin
                    if InvoiceNos.Count = 0 then
                        CurrReport.Break();
                    Invoices.SetRange(Number, 1, InvoiceNos.Count);
                end;
                #endregion OnPreDataItem
            }
            dataitem(CrMemos; Integer)
            {
                DataItemTableView = sorting(Number);

                #region OnAfterGetRecord
                trigger OnAfterGetRecord()
                var
                    SalesCrMemoHeader: Record "Sales Cr.Memo Header";
                    SalesCrMemoLine: Record "Sales Cr.Memo Line";
                begin
                    SalesCrMemoHeader.Get(CrMemoNos.Get(Number));
                    Dialog.Update(3, SalesCrMemoHeader."No.");
                    CreateBonus.SetDocument(SalesCrMemoHeader."Sell-to Customer No.", SalesCrMemoHeader."Ship-to Code", SalesCrMemoHeader."Currency Factor");
                    SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
                    SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
                    if SalesCrMemoLine.FindSet() then
                        repeat
                            CreateBonus.CreateBonus(SalesCrMemoLine);
                        until SalesCrMemoLine.Next() = 0;
                end;
                #endregion OnAfterGetRecord

                #region OnPreDataItem
                trigger OnPreDataItem()
                begin
                    if CrMemoNos.Count = 0 then
                        CurrReport.Break();
                    CrMemos.SetRange(Number, 1, CrMemoNos.Count);
                end;
                #endregion OnPreDataItem
            }
            #endregion dataitems

            #region OnPreDataItem
            trigger OnPreDataItem()
            begin
                Dialog.Open(CustomerProgressTxt + ContractProgressTxt + SalesDocProgressTxt);
                CreateBonus.SetGlobal(PostingDate, DateFrom, DateTo, CheckItemMeth);
            end;
            #endregion OnPreDataItem

            #region OnAfterGetRecord
            trigger OnAfterGetRecord()
            var
                ReverseReserve: Codeunit "lbtbn Reverse Reserve";
                FindDocumentNos: Codeunit "lbtbn Find Document Nos.";
                GetDocumentAmount: Codeunit "lbtbn Get Document Amount";
                Amount: Decimal;
                Quantity: Decimal;
            begin
                Clear(Quantity);
                Clear(Amount);

                if "Bonus Contract"."Last Billing at" <> 0D then
                    if (PostingDate < CalcDate('+' + Format("Bonus Contract"."Billing Period"), "Bonus Contract"."Last Billing at")) then
                        CurrReport.Skip();

                FindDocumentNos.FindDocumentNos("Bonus Contract"."No.", InvoiceNos, CrMemoNos, DateFrom, DateTo);
                GetDocumentAmount.AddQuantityAndAmount(Quantity, Amount, InvoiceNos, CrMemoNos, CheckItemMeth, "Bonus Contract"."No.");

                BonusContractLine.SetRange(Contract, "Bonus Contract"."No.");
                BonusContractLine.SetFilter("From Quantity", '<=%1', Amount);
                if not BonusContractLine.FindLast() then
                    CurrReport.Skip();
                ReverseReserve.ReverseBonusEntries("Bonus Contract", DateFrom, DateTo);
                ReverseReserve.ReverseGenLedgEntry("Bonus Contract", DateFrom, DateTo, ReversePostingDate);

                CreateBonus.SetBonusContract("Bonus Contract");
                CreateBonus.SetBonusContractLine(BonusContractLine);
                "Bonus Contract"."Last Billing at" := PostingDate;
                "Bonus Contract".Modify();
            end;
            #endregion OnAfterGetRecord

        }
        #endregion dataitem
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field("Date From"; DateFrom)
                    {
                        ApplicationArea = All;
                        Caption = 'Date from';
                        ToolTip = 'Specifies Date from';
                    }

                    field("Date To"; DateTo)
                    {
                        ApplicationArea = All;
                        Caption = 'Date to';
                        ToolTip = 'Specifies Date to';
                        #region OnValidate
                        trigger OnValidate()
                        begin
                            if ReversePostingDate = 0D then
                                ReversePostingDate := DateTo;
                        end;
                        #endregion OnValidate
                    }
                    field("Reverse Posting Date"; ReversePostingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Posting date of exploding bonus reserves';
                        ToolTip = 'Specifies date of exploding bonus reserves';
                    }
                }
            }
        }
    }

    #region OnPreReport
    trigger OnPreReport()
    begin
        if (DateFrom = 0D) or (DateTo = 0D) or (ReversePostingDate = 0D) then
            Error(AccountingPeriodMissingErr);
        PostingDate := DateTo;
        //TODO: setzt Datum für BonusMgt.ReverseBonusReserve - die Funktion gibt es in 365 noch nicht
        //GlobVarCU.s_date(ReversePostingDate,9);

        BonusSetup.Get();
        // if BonusSetup."Reserve Mode" = BonusSetup."Reserve Mode"::CreditMemo then begin
        //     //TODO: Fehlendes Feld?
        //     //BonusSetup.TestField("Billing Code");
        //     BonusSetup.TestField("Cust Gr. Reserve Cr. Memo");
        //     BonusSetup.TestField("Bus.Post.Gr.f.Res.Cr.Memo");
        //     CustomerPostingGroup.Get(BonusSetup."Cust Gr. Reserve Cr. Memo");
        //     CustomerPostingGroup.TestField("Receivables Account");
        //     GenBusinessPostingGroup.Get(BonusSetup."Bus.Post.Gr.f.Res.Cr.Memo");
        // end;
    end;
    #endregion OnPreReport


    var
        BonusContractLine: Record "lbtbn Bonus Contract Line";
        BonusSetup: Record "lbtbn Bonus Setup";
        CheckItemMeth: Codeunit "lbtbn CheckItem Meth";
        CreateBonus: Codeunit "lbtbn Create Bonus";
        InvoiceNos: List of [Code[20]];
        CrMemoNos: List of [Code[20]];
        Dialog: Dialog;
        DateFrom: Date;
        DateTo: Date;
        PostingDate: Date;
        ReversePostingDate: Date;
        AccountingPeriodMissingErr: Label 'Please input the accounting period.';
        ContractProgressTxt: Label 'Bonus Contract #2##############\', Comment = '%1 No.';
        CustomerProgressTxt: Label 'Customer    #1##############\', Comment = '%1 No.';
        SalesDocProgressTxt: Label 'Sales Document #3##############', Comment = '%1 No.';
}