report 5266052 "lbtbn Bonus Run"
{
    UsageCategory = Tasks;
    ApplicationArea = All;
    Caption = 'Bonus Run';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Bonus Contract"; "lbtbn Bonus Contract")
        {

            dataitem("Bonus Customer"; "lbtbn Bonus Customer")
            {
                DataItemLink = "Contract" = field("No.");

                dataitem("Sales Invoice Header"; "Sales Invoice Header")
                {
                    DataItemLink = "Sell-to Customer No." = field("Customer No.");

                    dataitem("Sales Invoice Line"; "Sales Invoice Line")
                    {
                        DataItemLink = "Document No." = field("No.");

                        trigger OnPreDataItem()
                        begin
                            //TODO:
                            //SetFilter("No.", '<>%1', "Bonus Contract"."Billing Item");
                            BonusAmount := 0;
                        end;

                        trigger OnAfterGetRecord()
                        var
                            ValueEntry: Record "Value Entry";
                            ItemLedgerEntry: Record "Item Ledger Entry";
                            DocAmount: Decimal;
                            PmtDiscAmt: Decimal;
                            DiscAmt: Decimal;
                        begin
                            DocAmount := GetDocAmount("Sales Invoice Line".Amount);
                            //UpdateDocAmountFromValueEntry();
                            case "Bonus Contract"."Bonus Billing Type" of
                                "Bonus Contract"."Bonus Billing Type"::"%":
                                    begin
                                        if "Bonus Contract"."Pmt. Discount %" <> 0 then
                                            PmtDiscAmt := DocAmount * "Bonus Contract"."Pmt. Discount %" / 100;
                                        if "Bonus Contract"."Discount %" <> 0 then
                                            DiscAmt := (DocAmount - PmtDiscAmt) * "Bonus Contract"."Discount %" / 100;
                                        BonusAmount := Round((DocAmount - PmtDiscAmt - DiscAmt) * BonusContractLine."Value" / 100, 0.01);

                                        if BonusAmount <> 0 then
                                            if BonusSetup."Reserve Mode" = BonusSetup."Reserve Mode"::CreditMemo then begin
                                                ValueEntry.SetCurrentKey("Document No.");
                                                ValueEntry.SetRange("Document No.", "Document No.");
                                                ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Invoice");
                                                ValueEntry.SetRange("Document Line No.", "Line No.");
                                                if ValueEntry.FindFirst() then
                                                    if ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.") then
                                                        if ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Sales Shipment" then
                                                            CreateSalesCreditMemo2();
                                            end;
                                    end;
                                "Bonus Contract"."Bonus Billing Type"::"Amount (LCY)":
                                    ;
                                "Bonus Contract"."Bonus Billing Type"::"Amount per Unit":
                                    ;
                            end;
                        end;
                    }

                    trigger OnPreDataItem()
                    begin
                        SetRange("Posting Date", DateFrom, DateTo);
                        if "Bonus Customer"."Ship-to Code" <> '' then
                            SetRange("Ship-to Code", "Bonus Customer"."Ship-to Code")
                        else
                            SetRange("Ship-to Code");
                    end;

                    trigger OnAfterGetRecord()
                    var
                        Customer: Record Customer;
                    begin
                        Dialog.Update(3, "No.");
                        SalesPersonCode := '';
                        //TODO: 
                        // if "Bonus Contract"."Agent From Document" then 
                        //     SalesPersonCode := "Salesperson Code"
                        // else
                        if Customer.Get("Bonus Contract"."Bonus Recipient") then
                            SalesPersonCode := Customer."Salesperson Code";
                    end;
                }
                dataitem("Sales Cr.Memo Header"; "Sales Cr.Memo Header")
                {
                    DataItemLink = "Sell-to Customer No." = field("Customer No.");

                    dataitem("Sales Cr.Memo Line"; "Sales Cr.Memo Line")
                    {
                        DataItemLink = "Document No." = field("No.");
                    }
                }
            }
            trigger OnPreDataItem()
            begin
                Dialog.Open(CustomerProgressTxt + ContractProgressTxt + SalesDocProgressTxt);
            end;



        }
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
                        trigger OnValidate()
                        begin
                            if ReversePostingDate = 0D then
                                ReversePostingDate := DateTo;
                        end;
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

    trigger OnPreReport()
    begin
        if (DateFrom = 0D) or (DateTo = 0D) or (ReversePostingDate = 0D) then
            Error(AccountingPeriodMissingErr);
        PostingDate := DateTo;
        //TODO: setzt Datum für BonusMgt.ReverseBonusReserve - die Funktion gibt es in 365 noch nicht
        //GlobVarCU.s_date(ReversePostingDate,9);

        BonusSetup.Get();
        if BonusSetup."Reserve Mode" = BonusSetup."Reserve Mode"::CreditMemo then begin
            //TODO: Fehlendes Feld?
            //BonusSetup.TestField("Billing Code");
            BonusSetup.TestField("Cust Gr. Reserve Cr. Memo");
            BonusSetup.TestField("Bus.Post.Gr.f.Res.Cr.Memo");
            CustomerPostingGroup.Get(BonusSetup."Cust Gr. Reserve Cr. Memo");
            CustomerPostingGroup.TestField("Receivables Account");
            GenBusinessPostingGroup.Get(BonusSetup."Bus.Post.Gr.f.Res.Cr.Memo");
        end;
    end;

    trigger OnPostReport()
    begin
        //TODO: 
        //GlobVarCU.s_date(0D,9);
    end;

    local procedure GetCustCode(): Code[20]
    begin
        // TODO: ?
        // if "Bonus Contract"."Bonus Recipient" = '' then 
        //     exit("Bonus Contract".Customer);
        exit("Bonus Contract"."Bonus Recipient");
    end;

    local procedure InitSalesHeader(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::"Credit Memo";
        SalesHeader."No." := '';
        SalesHeader.Insert(true);
        SalesHeader.Correction := false;
        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.Validate("Sell-to Customer No.", GetCustCode());
        // TODO: ?
        // SalesHeader.Validate("Shortcut Dimension 1 Code", "Bonus Contract"."Allocation Group");
        SalesHeader."Salesperson Code" := SalesPersonCode;
        SalesHeader."Document Date" := PostingDate;
        SalesHeader."Document Date" := 0D;
        SalesHeader."Posting Description" := BonusCreditMemoLbl;
        SalesHeader."lbt Process No." := "Bonus Contract"."Process No.";
        SalesHeader.Modify();
    end;

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

    local procedure GetSalesHeader(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.SetCurrentKey("Document Type", "Sell-to Customer No.", "Salesperson Code", "Shortcut Dimension 1 Code", "Shortcut Dimension 1 Code");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Credit Memo");
        SalesHeader.SetRange("Sell-to Customer No.", GetCustCode());
        // TODO: ?
        // SalesHeader.SetRange("Shortcut Dimension 1 Code", "Bonus Contract"."Allocation Group");
        SalesHeader.SetRange("Document Date", PostingDate);
        SalesHeader.SetRange("Posting Description", BonusCreditMemoLbl);
        if not SalesHeader.FindFirst() then begin
            InitSalesHeader(SalesHeader);
            CreateTextLine(SalesHeader, 10000, StrSubstNo(BonusSettlementTxt, "Bonus Contract"."No."));
            CreateTextLine(SalesHeader, 20000, StrSubstNo(AccountingPeriodTxt, DateFrom, DateTo));
        end;
    end;

    local procedure IsFixedAmountAndAlreadyCreated(): Boolean

    begin
        // SalesCrMemoLineRec.RESET;
        // SalesCrMemoLineRec.SETCURRENTKEY("Document Type", "Document No.", "Process No.");
        // SalesCrMemoLineRec.SETRANGE("Document Type", SalesCrMemoLineRec."Document Type"::"Credit Memo");
        // SalesCrMemoLineRec.SETRANGE("Document No.", SalesCrMemoRec."No.");
        // SalesCrMemoLineRec.SETRANGE("Process No.", BonusvertragRec."Process No.");
        // IF (NOT SalesCrMemoLineRec.ISEMPTY) AND
        //TODO: "Value Unit"::Fixed Amount
        //   (BonusvertragRec."Value Unit" = BonusvertragRec."Value Unit"::"Fixed Amount")
        // THEN
        //     EXIT;

    end;

    local procedure CreateSalesCreditMemo2()
    var
        SalesHeader: Record "Sales Header";
    begin
        GetSalesHeader(SalesHeader);
        if IsFixedAmountAndAlreadyCreated() then
            exit;

    end;

    local procedure GetDocAmount(Amount: Decimal) DocAmount: Decimal
    begin
        if "Sales Invoice Header"."Currency Code" = '' then
            DocAmount := Amount
        else
            DocAmount := Round(Amount / "Sales Invoice Header"."Currency Factor", 0.01);
    end;

    var
        BonusSetup: Record "lbtbn Bonus Setup";
        BonusContractLine: Record "lbtbn Bonus Contract Line";
        CustomerPostingGroup: Record "Customer Posting Group";
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        DateFrom: Date;
        DateTo: Date;
        ReversePostingDate: Date;
        PostingDate: Date;
        SalesPersonCode: Code[20];
        Dialog: Dialog;
        BonusAmount: Decimal;


        AccountingPeriodMissingErr: Label 'Please input the accounting period.';
        CustomerProgressTxt: Label 'Customer    #1##############\', Comment = '%1 No.';
        ContractProgressTxt: Label 'Bonus Contract #2##############\', Comment = '%1 No.';
        SalesDocProgressTxt: Label 'Sales Document #3##############', Comment = '%1 No.';
        BonusCreditMemoLbl: Label 'Bonus Credit Memo';
        BonusSettlementTxt: Label 'Bonus Settlement according to Bonus Contract %1', Comment = '%1 No.';
        AccountingPeriodTxt: Label 'Accounting Period %1 to %2', Comment = '%1 from %2 to';
}