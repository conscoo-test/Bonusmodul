report 5266051 "lbtbn Bonus Reserves"
{
    ApplicationArea = All;
    Caption = 'Bonus Reserves';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        #region dataitem
        dataitem("Bonus Contract"; "lbtbn Bonus Contract")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Billing Period";

            #region dataitems
            dataitem(Invoices; Integer)
            {
                DataItemTableView = sorting(Number);
                #region OnPreDataItem
                trigger OnPreDataItem()
                begin
                    if InvoiceNos.Count = 0 then
                        CurrReport.Break();
                    Invoices.SetRange(Number, 1, InvoiceNos.Count);
                end;
                #endregion OnPreDataItem

                #region OnAfterGetRecord
                trigger OnAfterGetRecord()
                var
                    SalesInvoiceHeader: Record "Sales Invoice Header";
                    SalesInvoiceLine: Record "Sales Invoice Line";
                begin
                    SalesInvoiceHeader.Get(InvoiceNos.Get(Invoices.Number));
                    CreateBonus.SetDocument(SalesInvoiceHeader."Sell-to Customer No.", SalesInvoiceHeader."Ship-to Code", SalesInvoiceHeader."Currency Factor");
                    SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
                    SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
                    if SalesInvoiceLine.FindSet() then
                        repeat
                            CreateBonus.CreateReserve(SalesInvoiceLine);
                        until SalesInvoiceLine.Next() = 0;
                end;
                #endregion OnAfterGetRecord
            }
            dataitem(CrMemos; Integer)
            {
                DataItemTableView = sorting(Number);
                #region OnPreDataItem
                trigger OnPreDataItem()
                begin
                    if CrMemoNos.Count = 0 then
                        CurrReport.Break();
                    CrMemos.SetRange(Number, 1, CrMemoNos.Count);
                end;
                #endregion OnPreDataItem

                #region OnAfterGetRecord
                trigger OnAfterGetRecord()
                var
                    SalesCrMemoHeader: Record "Sales Cr.Memo Header";
                    SalesCrMemoLine: Record "Sales Cr.Memo Line";
                begin
                    SalesCrMemoHeader.Get(CrMemoNos.Get(CrMemos.Number));
                    CreateBonus.SetDocument(SalesCrMemoHeader."Sell-to Customer No.", SalesCrMemoHeader."Ship-to Code", SalesCrMemoHeader."Currency Factor");
                    SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
                    SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
                    if SalesCrMemoLine.FindSet() then
                        repeat
                            CreateBonus.CreateReserve(SalesCrMemoLine);
                        until SalesCrMemoLine.Next() = 0;
                end;
                #endregion OnAfterGetRecord
            }
            dataitem("Bonus Customer"; "lbtbn Bonus Customer")
            {
                DataItemLink = Contract = field("No.");
                DataItemTableView = sorting(Contract, "Customer No.", "Ship-to Code");

                #region dataitems
                dataitem("Fixed Amount"; Integer)
                {
                    DataItemTableView = sorting(Number) where(Number = const(1));

                    #region OnPreDataItem
                    trigger OnPreDataItem()
                    begin
                        if "Bonus Contract"."Reserve Type" <> "Bonus Contract"."Reserve Type"::"Amount (LCY)" then
                            CurrReport.Break();
                    end;
                    #endregion OnPreDataItem

                    #region OnAfterGetRecord
                    trigger OnAfterGetRecord()
                    var
                    begin
                        CreateBonus.CreateReserveFixed();
                    end;
                    #endregion OnAfterGetRecord
                }
                #endregion dataitems

                trigger OnAfterGetRecord()
                begin
                    CreateBonus.SetDocument("Bonus Customer"."Customer No.", "Bonus Customer"."Ship-to Code", 0);
                end;
            }
            #endregion dataitems

            // DataItem "Bonus Contract"
            #region OnPreDataItem
            trigger OnPreDataItem()
            begin
                Dialog.Open(CustomerProgressTxt + ContractProgressTxt);
                PostingDate := DateTo;
                CreateBonus.SetGlobal(PostingDate, DateFrom, DateTo, CheckItemMeth);
            end;
            #endregion OnPreDataItem

            #region OnAfterGetRecord
            trigger OnAfterGetRecord()
            var
                FindDocumentNos: Codeunit "lbtbn Find Document Nos.";
            begin
                Dialog.Update(1, "No. of Customers");
                Dialog.Update(2, "No.");

                if not CheckDates() then
                    CurrReport.Skip();
                FindDocumentNos.FindDocumentNos("Bonus Contract"."No.", InvoiceNos, CrMemoNos, DateFrom, DateTo);

                "Bonus Contract"."Last Reserve at" := PostingDate;
                "Bonus Contract".Modify();

                CreateBonus.SetBonusContract("Bonus Contract");
            end;
            #endregion OnAfterGetRecord

            #region OnPostDataItem
            trigger OnPostDataItem()
            begin
                Dialog.Close();
                Commit(); // after each Contract to not lose progress

                CreateBonus.OpenPage();
            end;
            #endregion OnPostDataItem
        }
        #endregion dataitem
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Optionen)
                {
                    Caption = 'Option', comment = 'DEU ="Optionen"';
                    field("Date From"; DateFrom)
                    {
                        ApplicationArea = All;
                        Caption = 'Date from';
                        ToolTip = 'In consideration of the sart date, all invoice and credit lines of the period are used, which are additionally checked for relevance of the corresponding contract conditions (calculation rules).';
                    }
                    field("Date To"; DateTo)
                    {
                        ApplicationArea = All;
                        Caption = 'Date to';
                        ToolTip = 'In Consideration of the end date, all invoice and credit memo lines of the period are used, which are also checked for relevance of the corresponding contract conditions (calculation rules).';
                    }
                }
            }
        }
    }

    #region OnPreReport
    trigger OnPreReport()
    begin
        if (DateFrom = 0D) or (DateTo = 0D) then
            Error(InputAccountingPeriodMsg);
        if DateFrom > DateTo then
            Error(CheckAccountingPeriodMsg);
        BonusSetup.Get();
        if BonusSetup."Reserve Mode" = BonusSetup."Reserve Mode"::Journal then begin
            BonusSetup.TestField("Gen.Jnl.Templ.BonusReserve");
            BonusSetup.TestField("Gen. Jnl. Bonus Reserve");
        end;
    end;
    #endregion OnPreReport

    var
        BonusSetup: Record "lbtbn Bonus Setup";
        CheckItemMeth: Codeunit "lbtbn CheckItem Meth";
        CreateBonus: Codeunit "lbtbn Create Bonus";
        InvoiceNos: List of [Code[20]];
        CrMemoNos: List of [Code[20]];
        DateFrom: Date;
        DateTo: Date;
        PostingDate: Date;
        Dialog: Dialog;
        CheckAccountingPeriodMsg: Label 'Please check the accounting period.';
        ContractProgressTxt: Label 'Contract   #2##############', Comment = '%1 No.';
        CustomerProgressTxt: Label 'Customer #1##############\', Comment = '%1 No.';
        InputAccountingPeriodMsg: Label 'Please input the accounting period.';

    #region CheckDates
    local procedure CheckDates(): Boolean
    begin
        if (PostingDate < "Bonus Contract"."Valid from") or (("Bonus Contract"."Valid to" <> 0D) and (PostingDate > "Bonus Contract"."Valid to")) then
            exit(false);

        if "Bonus Contract"."Last Reserve at" >= DateFrom then
            exit(false);
        exit(true);
    end;
    #endregion CheckDates
}
