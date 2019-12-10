report 5266052 "lbt Bonus Run"
{
    UsageCategory = Tasks;
    ApplicationArea = All;

    dataset
    {
        dataitem("Bonus Contract"; "lbt Bonus Contract")
        {

            dataitem("Bonus Customer"; "lbt Bonus Customers")
            {
                DataItemLink = "lbt Contract" = field("lbt Contract");

                dataitem("Sales Invoice Header"; "Sales Invoice Header")
                {
                    DataItemLink = "Sell-to Customer No." = field("lbt Customer");

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
                            //GetDocAmount();
                            //UpdateDocAmountFromValueEntry();
                            case "Bonus Contract"."lbt Bonus Billing Type" of
                                "Bonus Contract"."lbt Bonus Billing Type"::"%":
                                    begin
                                        if "Bonus Contract"."lbt Pmt. Discount %" <> 0 then
                                            PmtDiscAmt := DocAmount * "Bonus Contract"."lbt Pmt. Discount %" / 100;
                                        if "Bonus Contract"."lbt Discount %" <> 0 then
                                            DiscAmt := (DocAmount - PmtDiscAmt) * "Bonus Contract"."lbt Discount %" / 100;
                                        BonusAmount := Round((DocAmount - PmtDiscAmt - DiscAmt) * BonusContractLine."lbt Value" / 100, 0.01);

                                        if BonusAmount <> 0 then
                                            if BonusSetup."lbt Reserve Mode" = BonusSetup."lbt Reserve Mode"::CreditMemo then begin
                                                ValueEntry.SetCurrentKey("Document No.");
                                                ValueEntry.SetRange("Document No.", "Document No.");
                                                ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Invoice");
                                                ValueEntry.SetRange("Document Line No.", "Line No.");
                                                if ValueEntry.FindFirst() then begin
                                                    if ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.") then
                                                        if ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Sales Shipment" then
                                                            CreateSalesCreditMemo2(Database::"Sales Invoice Line", "Document No.", "Line No.", DocAmount, BonusAmount, -DiscAmt, -PmtDiscAmt);
                                                end;

                                            end;
                                    end;
                                "Bonus Contract"."lbt Bonus Billing Type"::"Amount (LCY)":
                                    begin
                                    end;
                                "Bonus Contract"."lbt Bonus Billing Type"::"Amount per Unit":
                                    begin

                                    end;
                            end;
                        end;
                    }

                    trigger OnPreDataItem()
                    begin
                        SetRange("Posting Date", DateFrom, DateTo);
                        if "Bonus Customer"."lbt Ship-to Code" <> '' then
                            SetRange("Ship-to Code", "Bonus Customer"."lbt Ship-to Code")
                        else
                            SetRange("Ship-to Code");
                    end;

                    trigger OnAfterGetRecord()
                    var
                        Customer: Record Customer;
                    begin
                        dia.Update(3, "No.");
                        SalesPersonCode := '';
                        //TODO: 
                        // if "Bonus Contract"."Agent From Document" then 
                        //     SalesPersonCode := "Salesperson Code"
                        // else
                        if Customer.Get("Bonus Contract"."lbt Bonus Recipient") then
                            SalesPersonCode := Customer."Salesperson Code";
                    end;
                }
                dataitem("Sales Cr.Memo Header"; "Sales Cr.Memo Header")
                {
                    DataItemLink = "Sell-to Customer No." = field("lbt Customer");

                    dataitem("Sales Cr.Memo Line"; "Sales Cr.Memo Line")
                    {
                        DataItemLink = "Document No." = field("No.");
                    }
                }
            }
            trigger OnPreDataItem()
            begin
                dia.Open(CustomerProgressTxt + ContractProgressTxt + SalesDocProgressTxt);
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
                    field(DateFrom; DateFrom)
                    {
                        ApplicationArea = All;
                        Caption = 'Date from', Comment = 'DEU="Datum von"';
                    }

                    field(DateTo; DateTo)
                    {
                        ApplicationArea = All;
                        Caption = 'Date to', Comment = 'DEU="Datum bis"';
                        trigger OnValidate()
                        begin
                            if ReversePostingDate = 0D then
                                ReversePostingDate := DateTo;
                        end;
                    }
                    field(ReversePostingDate; ReversePostingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Posting date of exploding bonus reserves', Comment = 'DEU="Buchungsdatum für Rückstellungsauflösung"';
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
        if BonusSetup."lbt Reserve Mode" = BonusSetup."lbt Reserve Mode"::CreditMemo then begin
            //TODO: Fehlendes Feld?
            //BonusSetup.TestField("Billing Code");
            BonusSetup.TestField("lbt Cust Gr. Reserve Cr. Memo");
            BonusSetup.TestField("lbt Bus.Post.Gr.f.Res.Cr.Memo");
            CustomerPostingGroup.Get(BonusSetup."lbt Cust Gr. Reserve Cr. Memo");
            CustomerPostingGroup.TestField("Receivables Account");
            GenBusinessPostingGroup.Get(BonusSetup."lbt Bus.Post.Gr.f.Res.Cr.Memo");
        end;
    end;

    trigger OnPostReport()
    begin
        //TODO: 
        //GlobVarCU.s_date(0D,9);
    end;

    local procedure GetCustCode(): Code[20]
    var
        CustCode: Code[20];

    begin
        // TODO: ?
        // if "Bonus Contract"."lbt Bonus Recipient" = '' then 
        //     exit("Bonus Contract".Customer);
        exit("Bonus Contract"."lbt Bonus Recipient");
    end;

    local procedure InitSalesHeader(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::"Credit Memo";
        SalesHeader."No." := '';
        SalesHeader.Insert(true);
        SalesHeader.Correction := false;
        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.Validate("Sell-to Customer No.", GetCustCode);
        // TODO: ?
        // SalesHeader.Validate("Shortcut Dimension 1 Code", "Bonus Contract"."Allocation Group");
        SalesHeader."Salesperson Code" := SalesPersonCode;
        SalesHeader."Document Date" := PostingDate;
        SalesHeader."Document Date" := 0D;
        SalesHeader."Posting Description" := BonusCreditMemoLbl;
        SalesHeader."lbt Process No." := "Bonus Contract"."Process No.";
        SalesHeader.Modify();
    end;

    local procedure CreateTextLine(SalesHeader: Record "Sales Header"; LineNo: Integer; Description: Text)
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
        SalesHeader.SetRange("Sell-to Customer No.", GetCustCode);
        // TODO: ?
        // SalesHeader.SetRange("Shortcut Dimension 1 Code", "Bonus Contract"."Allocation Group");
        SalesHeader.SetRange("Document Date", PostingDate);
        SalesHeader.SetRange("Posting Description", BonusCreditMemoLbl);
        if not SalesHeader.FindFirst() then begin
            InitSalesHeader(SalesHeader);
            CreateTextLine(SalesHeader, 10000, StrSubstNo(BonusSettlementTxt, "Bonus Contract"."lbt Contract"));
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

    local procedure CreateSalesCreditMemo2(TableId: Integer; DocNo: Code[20]; DocLineNo: Integer; DocAmount: Decimal; BonusAmount: Decimal; DiscAmount: Decimal; PmtDiscAmount: Decimal) Amount: Decimal
    var
        SalesHeader: Record "Sales Header";
        FirstLine: Boolean;
    begin
        GetSalesHeader(SalesHeader);
        if IsFixedAmountAndAlreadyCreated() then
            exit;

    end;

    var
        BonusSetup: Record "lbt Bonus Setup";
        BonusContractLine: Record "lbt Bonus Contract Line";
        CustomerPostingGroup: Record "Customer Posting Group";
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        DateFormelLeer: DateFormula;
        DateFrom: Date;
        DateTo: Date;
        ReversePostingDate: Date;
        PostingDate: Date;
        SalesPersonCode: Code[20];
        dia: Dialog;
        BonusAmount: Decimal;


        AccountingPeriodMissingErr: Label 'Please input the accounting period.', Comment = 'DEU="Geben Sie den Abrechnungszeitraum ein."';
        CustomerProgressTxt: Label 'Customer    #1##############\', Comment = 'DEU="Debitor        #1##############\"';
        ContractProgressTxt: Label 'Bonus Contract #2##############\', Comment = 'DEU="Bonusvertrag   #2##############\"';
        SalesDocProgressTxt: Label 'Sales Document #3##############', Comment = 'DEU="Verkaufsbeleg  #3##############"';
        BonusCreditMemoLbl: Label 'Bonus Credit Memo', Comment = 'DEU="Bonusgutschrift"';
        BonusSettlementTxt: Label 'Bonus Settlement according to Bonus Contract %1', Comment = 'DEU="Bonusabrchn. gem. Vertrag %1"';
        AccountingPeriodTxt: Label 'Accounting Period %1 to %2', Comment = 'DEU="Abrechnungszeitraum %1 bis %2"';
}