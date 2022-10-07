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

            #region dataitem
            dataitem("Bonus Customer"; "lbtbn Bonus Customer")
            {
                DataItemLink = "Contract" = field("No.");

                #region dataitems
                dataitem("Sales Invoice Header"; "Sales Invoice Header")
                {
                    DataItemLink = "Sell-to Customer No." = field("Customer No.");

                    #region dataitem
                    dataitem("Sales Invoice Line"; "Sales Invoice Line")
                    {
                        DataItemLink = "Document No." = field("No.");

                        #region OnPreDataItem
                        trigger OnPreDataItem()
                        begin
                            //TODO:
                            //SetFilter("No.", '<>%1', "Bonus Contract"."Billing Item");
                            BonusAmount := 0;
                        end;
                        #endregion OnPreDataItem

                        #region OnAfterGetRecord
                        trigger OnAfterGetRecord()
                        var
                            ItemLedgerEntry: Record "Item Ledger Entry";
                            ValueEntry: Record "Value Entry";
                            DiscAmt: Decimal;
                            DocAmount: Decimal;
                            PmtDiscAmt: Decimal;
                        begin
                            if not "Bonus Contract".CheckAttributes("Sales Invoice Line"."No.") then
                                CurrReport.Skip();
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
                                                            CreateSalesCreditMemo3("Bonus Contract", SalesPersonCode, Database::"Sales Invoice Line", "Sales Invoice Header"."No.", "Sales Invoice Line"."Line No.", DocAmount, BonusAmount, DiscAmt, PmtDiscAmt);
                                                //Contract: Record "lbtbn Bonus Contract"; Salesperson: Code[20]; TableID: Integer; DocNo: Code[20]; DocLineNo: Integer; DocAmt: Decimal; BonusSumme: Decimal; DiscAmount: Decimal; PmtDiscAmount: Decimal; Sign: Integer) Betrag: Decimal
                                            end;
                                    end;
                                "Bonus Contract"."Bonus Billing Type"::"Amount (LCY)":
                                    ;
                                "Bonus Contract"."Bonus Billing Type"::"Amount per Unit":
                                    ;
                            end;
                        end;
                        #endregion OnAfterGetRecord
                    }
                    #endregion dataitem

                    #region OnPreDataItem
                    trigger OnPreDataItem()
                    begin
                        SetRange("Posting Date", DateFrom, DateTo);
                        if "Bonus Customer"."Ship-to Code" <> '' then
                            SetRange("Ship-to Code", "Bonus Customer"."Ship-to Code")
                        else
                            SetRange("Ship-to Code");
                    end;
                    #endregion OnPreDataItem

                    #region OnAfterGetRecord
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
                    #endregion OnAfterGetRecord
                }
                dataitem("Sales Cr.Memo Header"; "Sales Cr.Memo Header")
                {
                    DataItemLink = "Sell-to Customer No." = field("Customer No.");

                    #region dataitem
                    dataitem("Sales Cr.Memo Line"; "Sales Cr.Memo Line")
                    {
                        DataItemLink = "Document No." = field("No.");
                    }
                    #endregion dataitem
                }
                #endregion dataitems
            }
            #endregion dataitem
            #region OnPreDataItem
            trigger OnPreDataItem()
            begin
                Dialog.Open(CustomerProgressTxt + ContractProgressTxt + SalesDocProgressTxt);
            end;
            #endregion OnPreDataItem

            #region OnAfterGetRecord
            trigger OnAfterGetRecord()
            var
                BonusCustomer: Record "lbtbn Bonus Customer";
                Amount: Decimal;
                Quantity: Decimal;
            begin
                Clear(Quantity);
                Clear(Amount);
                BonusCustomer.SetRange(Contract, "Bonus Contract"."No.");
                if BonusCustomer.FindSet() then
                    repeat
                        AddQuantityAndAmountBonusCustomer(Quantity, Amount, BonusCustomer);
                    until BonusCustomer.Next() = 0;
                BonusContractLine.SetRange(Contract, "Bonus Contract"."No.");
                BonusContractLine.SetFilter("From Quantity", '<=%1', Amount);
                if not BonusContractLine.FindLast() then
                    CurrReport.Skip();
                //ReverseBonusEntry
                // or ReverseGenLedgEntry
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
    #region CreateSalesCreditMemo3
    procedure CreateSalesCreditMemo3(Contract: Record "lbtbn Bonus Contract"; Salesperson: Code[20]; TableID: Integer; DocNo: Code[20]; DocLineNo: Integer; DocAmt: Decimal; BonusSumme: Decimal; DiscAmount: Decimal; PmtDiscAmount: Decimal) Betrag: Decimal
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocType: Integer;
        LineNo: Integer;
        OldLineNo: Integer;
        Sign: Integer;
        Zusatz: Text;
        AccountingTxt: Label 'Bonus Accounting';
    begin
        case TableID of
            Database::"Sales Invoice Line":
                Sign := 1;
            Database::"Sales Cr.Memo Line":
                Sign := -1;
        end;

        GetOrCreateSalesHeader(SalesHeader);

        SalesLine.Reset();
        SalesLine.SetCurrentKey("Document Type", "Document No.", "lbt Process No.");
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::"Credit Memo");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("lbt Process No.", Contract."Process No.");
        if (SalesLine.FindLast()) and
          (Contract."Bonus Billing Type" = Contract."Bonus Billing Type"::"Amount (LCY)")
        then
            exit;
        LineNo := SalesLine."Line No.";

        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        OldLineNo := LineNo;

        LineNo += 10000;
        SalesLine."Line No." := LineNo;
        SalesLine.Validate("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
        SalesLine.Insert(true);

        SalesLine.Validate(Type, SalesLine.Type::"Charge (Item)");
        SalesLine.Validate("No.", Contract."Accounting Item Charge");
        SalesLine.Description := AccountingTxt;
        if Contract."Bonus Billing Type" <> Contract."Bonus Billing Type"::"Amount (LCY)" then
            SalesLine.Description += ' ' + Format(DocNo);
        // SalesLine.VALIDATE("Location Code", VertriebEinrRec."Location Bonus Item");
        SalesLine.Validate("Unit Price", 1);
        SalesLine."lbt Process No." := Contract."Process No.";
        SalesLine.Modify();
        DocType := 0;
        case Sign of
            1:
                DocType := 1;
            -1:
                DocType := 2;
        end;

        case Contract."Bonus Billing Type" of
            Contract."Bonus Billing Type"::"%":
                Zusatz := CreateItemChargeForBillingTypePercent(DocAmt, BonusSumme, Sign, SalesLine);
            Contract."Bonus Billing Type"::"Amount (LCY)":
                CreateItemChargeForBillingTypeAmount(Contract, TableID, DocNo, DocLineNo, BonusSumme, DiscAmount, PmtDiscAmount, SalesHeader, SalesLine, DocType, OldLineNo, Sign, Betrag);
            Contract."Bonus Billing Type"::"Amount per Unit":
                Zusatz := CreateItemChargeForBillingTypeAmountPerUnit(DocAmt, BonusSumme, SalesLine, Sign);
        end;

        if Contract."Bonus Billing Type" = Contract."Bonus Billing Type"::"Amount (LCY)" then
            exit;

        SalesLine."Description 2" := ContractTxt + Format(Contract."No.") + ': ' + Zusatz;
        SalesLine.Modify(true);

        // SalesHeader.Status := SalesHeader.Status::Released;
        // SalesHeader.Modify();
        SalesLine.UpdateAmounts();
        // SalesHeader.Status := SalesHeader.Status::Open;
        // SalesHeader.Modify();

        CreateBonusEntry(Contract, DocNo, DocLineNo, DocAmt, DiscAmount, PmtDiscAmount, Sign, SalesLine, DocType);

        SetDimensions(TableID, DocNo, DocLineNo, SalesHeader, SalesLine);
        SalesLine.Modify(true);
    end;
    #endregion CreateSalesCreditMemo3

    #region OnPreReport
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
    #endregion OnPreReport

    #region OnPostReport
    trigger OnPostReport()
    begin
        //TODO: 
        //GlobVarCU.s_date(0D,9);
    end;
    #endregion OnPostReport

    #region GetCustCode
    local procedure GetCustCode(): Code[20]
    begin
        // TODO: ?
        // if "Bonus Contract"."Bonus Recipient" = '' then 
        //     exit("Bonus Contract".Customer);
        exit("Bonus Contract"."Bonus Recipient");
    end;
    #endregion GetCustCode

    #region InitSalesHeader
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
    #endregion InitSalesHeader

    #region CreateTextLine
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
    #endregion CreateTextLine

    #region GetSalesHeader
    local procedure GetOrCreateSalesHeader(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.SetCurrentKey("Document Type", "Sell-to Customer No.", "Salesperson Code", "Shortcut Dimension 1 Code", "Shortcut Dimension 1 Code");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Credit Memo");
        SalesHeader.SetRange("Sell-to Customer No.", GetCustCode());
        SalesHeader.SetRange("Document Date", PostingDate);
        SalesHeader.SetRange("Posting Description", BonusCreditMemoLbl);
        if not SalesHeader.FindFirst() then begin
            InitSalesHeader(SalesHeader);
            CreateTextLine(SalesHeader, 10000, StrSubstNo(BonusSettlementTxt, "Bonus Contract"."No."));
            CreateTextLine(SalesHeader, 20000, StrSubstNo(AccountingPeriodTxt, DateFrom, DateTo));
        end;
    end;
    #endregion GetSalesHeader

    #region GetDocAmount
    local procedure GetDocAmount(Amount: Decimal) DocAmount: Decimal
    begin
        if "Sales Invoice Header"."Currency Code" = '' then
            DocAmount := Amount
        else
            DocAmount := Round(Amount / "Sales Invoice Header"."Currency Factor", 0.01);
    end;
    #endregion GetDocAmount

    #region AddQuantityAndAmountBonusCustomer
    local procedure AddQuantityAndAmountBonusCustomer(var Quantity: Decimal; var Amount: Decimal; BonusCustomer: Record "lbtbn Bonus Customer")
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        SalesInvoiceHeader.SetRange("Sell-to Customer No.", BonusCustomer."Customer No.");
        SalesInvoiceHeader.SetRange("Posting Date", DateFrom, DateTo);
        if BonusCustomer."Ship-to Code" <> '' then
            SalesInvoiceHeader.SetRange("Ship-to Code", BonusCustomer."Ship-to Code");
        if SalesInvoiceHeader.FindSet() then
            repeat
                GetQuantityAndAmountInvoice(Quantity, Amount, SalesInvoiceHeader."No.");
            until SalesInvoiceHeader.Next() = 0;

        SalesCrMemoHeader.SetRange("Posting Date", DateFrom, DateTo);
        SalesCrMemoHeader.SetRange("Sell-to Customer No.", BonusCustomer."Customer No.");
        if BonusCustomer."Ship-to Code" <> '' then
            SalesCrMemoHeader.SetRange("Ship-to Code", BonusCustomer."Ship-to Code");
        if SalesCrMemoHeader.FindSet() then
            repeat
                GetQuantityAndAmountCrMemo(Quantity, Amount, SalesCrMemoHeader."No.");
            until SalesCrMemoHeader.Next() = 0;
    end;
    #endregion AddQuantityAndAmountBonusCustomer

    #region GetQuantityAndAmountInvoice
    local procedure GetQuantityAndAmountInvoice(var Quantity: Decimal; var Amount: Decimal; No: Code[20])
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        SalesInvoiceLine.SetRange("Document No.", No);
        SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
        if SalesInvoiceLine.FindSet() then
            repeat
                if "Bonus Contract".CheckAttributes(SalesInvoiceLine."No.") then begin
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
                if "Bonus Contract".CheckAttributes(SalesCrMemoLine."No.") then begin
                    Quantity -= SalesCrMemoLine.Quantity;
                    Amount -= SalesCrMemoLine.Amount;
                end;
            until SalesCrMemoLine.Next() = 0;
    end;
    #endregion GetQuantityAndAmountCrMemo
    #region CreateBonusEntry
    local procedure CreateBonusEntry(var Contract: Record "lbtbn Bonus Contract"; DocNo: Code[20]; DocLineNo: Integer; DocAmt: Decimal; DiscAmount: Decimal; PmtDiscAmount: Decimal; Sign: Integer; var SalesLine: Record "Sales Line"; DocType: Integer)
    var
        BonusMgt: Codeunit "lbtbn Bonus Management";
    begin
        Clear(BonusMgt);
        BonusMgt.SetSourceDoc(DocType, DocNo, DocLineNo);
        BonusMgt.SetBonusDoc(2, SalesLine."Document No.", SalesLine."Line No.");
        BillingEntry := BonusMgt.CreateBonusContractEntry(
          Contract,
          "Bonus Customer",
          0,                                          //Postenart Bonus
          PostingDate,
          BonusContractLine."Line No.",           //Bonusregelzeile
          SalesLine.Quantity,                //Menge
          SalesLine.Amount,                  //Betrag
          SalesLine."Amount Including VAT",  //Betrag inkl. Vat
          DocAmt * Sign,                             //Belegbetrag
          DiscAmount,
          PmtDiscAmount);
    end;
    #endregion CreateBonusEntry

    #region SetDimensions
    local procedure SetDimensions(TableID: Integer; DocNo: Code[20]; DocLineNo: Integer; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        // SalesLine."Billing Code" := VertriebEinrRec."Billing Code";
        SalesLine."lbtbn Bonus Entry No." := BillingEntry;
        if TableID <> 0 then
            case TableID of
                Database::"Sales Invoice Line":
                    begin
                        SalesInvoiceLine.Get(DocNo, DocLineNo);
                        SalesLine."Shortcut Dimension 1 Code" := SalesInvoiceLine."Shortcut Dimension 1 Code";
                        SalesLine."Shortcut Dimension 2 Code" := SalesInvoiceLine."Shortcut Dimension 2 Code";
                        SalesLine."Dimension Set ID" := SalesInvoiceLine."Dimension Set ID";
                    end;
                Database::"Sales Cr.Memo Line":
                    begin
                        SalesCrMemoLine.Get(DocNo, DocLineNo);
                        SalesLine."Shortcut Dimension 1 Code" := SalesCrMemoLine."Shortcut Dimension 1 Code";
                        SalesLine."Shortcut Dimension 2 Code" := SalesCrMemoLine."Shortcut Dimension 2 Code";
                        SalesLine."Dimension Set ID" := SalesCrMemoLine."Dimension Set ID";
                    end;
            end
#pragma warning disable AA0005
        else begin
            // SalesLine."Dimension Set ID" := CreateDimSetID("Bonus Contract".Contract);
            // DimMgt.UpdateGlobalDimFromDimSetID(SalesLine."Dimension Set ID",
            //                                      SalesLine."Shortcut Dimension 1 Code",
            //                                       SalesLine."Shortcut Dimension 2 Code");
        end;
#pragma warning restore AA0005
        if SalesHeader."Shortcut Dimension 1 Code" <> '' then
            SalesLine.Validate("Shortcut Dimension 1 Code", SalesHeader."Shortcut Dimension 1 Code");
    end;
    #endregion SetDimensions



    #region CreateItemChargeForBillingTypePercent
    local procedure CreateItemChargeForBillingTypePercent(DocAmt: Decimal; BonusSumme: Decimal; Sign: Integer; var SalesLine: Record "Sales Line") Zusatz: Text
    var
        ItemChargeAssRec: Record "Item Charge Assignment (Sales)";
        ItemLedgEntryRec: Record "Item Ledger Entry"; // TODO make global
    begin
        SalesLine.Validate(Quantity, BonusSumme);
        SalesLine.Modify();
        ItemChargeAssRec.Init();
        ItemChargeAssRec."Document Type" := SalesLine."Document Type";
        ItemChargeAssRec."Document No." := SalesLine."Document No.";
        ItemChargeAssRec."Document Line No." := SalesLine."Line No.";
        ItemChargeAssRec."Line No." := 10000;
        ItemChargeAssRec."Item Charge No." := SalesLine."No.";
        if Sign = 1 then
            ItemChargeAssRec."Applies-to Doc. Type" := ItemChargeAssRec."Applies-to Doc. Type"::Shipment
        else
            ItemChargeAssRec."Applies-to Doc. Type" := ItemChargeAssRec."Applies-to Doc. Type"::"Return Receipt";

        ItemChargeAssRec."Applies-to Doc. Line Amount" := Sign * DocAmt;
        ItemChargeAssRec."Item No." := ItemLedgEntryRec."Item No.";
        ItemChargeAssRec.Description := ItemLedgEntryRec.Description;
        ItemChargeAssRec."Applies-to Doc. No." := ItemLedgEntryRec."Document No.";
        ItemChargeAssRec."Applies-to Doc. Line No." := ItemLedgEntryRec."Document Line No.";
        ItemChargeAssRec."Unit Cost" := 1;
        ItemChargeAssRec.Validate("Qty. to Assign", BonusSumme);
        ItemChargeAssRec.Insert();
        Zusatz := Format(BonusContractLine.Value) + ' %';
    end;
    #endregion CreateItemChargeForBillingTypePercent

#pragma warning disable AA0137
    #region CreateSeparateLines
    local procedure CreateSeparateLines(var SalesLine: Record "Sales Line"; var ItemChargeAssRec: Record "Item Charge Assignment (Sales)")
#pragma warning restore AA0137
    begin
        // IF NOT ItemChargeAssRec.ISEMPTY THEN
        //     ItemChargeAssRec.CreateSeparateLines(SalesLine);
    end;
    #endregion CreateSeparateLines

    #region HandleSeparatedLines
    local procedure HandleSeparatedLines(var Contract: Record "lbtbn Bonus Contract"; TableID: Integer; DocNo: Code[20]; DocLineNo: Integer; DiscAmount: Decimal; PmtDiscAmount: Decimal; var ItemChargeAssRec: Record "Item Charge Assignment (Sales)"; var SalesHeader: Record "Sales Header"; DocType: Integer; OldLineNo: Integer; Sign: Integer; Zusatz: Text)
    var
        SalesLine: Record "Sales Line";
        BonusMgt: Codeunit "lbtbn Bonus Management";
    begin
        SalesLine.Reset();
        SalesLine.SetCurrentKey("Document Type", "Document No.", "lbt Process No.");
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::"Credit Memo");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("lbt Process No.", Contract."Process No.");
        SalesLine.SetFilter("Line No.", '>%1', OldLineNo);
        if SalesLine.FindSet() then
            repeat
                ItemChargeAssRec.SetRange("Document Line No.", SalesLine."Line No.");
                if ItemChargeAssRec.FindFirst() then begin
                    SalesHeader.Status := SalesHeader.Status::Released;
                    SalesHeader.Modify();
                    SalesLine.UpdateAmounts();
                    SalesHeader.Status := SalesHeader.Status::Open;
                    SalesHeader.Modify();

                    Clear(BonusMgt);
                    //BonusMgt.SetSourceDoc(DocType,DocNo,DocLineNo);
                    BonusMgt.SetSourceDoc(
                      DocType,
                      ItemChargeAssRec."Applies-to Doc. No.",
                      ItemChargeAssRec."Applies-to Doc. Line No."
                      );
                    BonusMgt.SetBonusDoc(2, SalesLine."Document No.", SalesLine."Line No.");
                    BillingEntry := BonusMgt.CreateBonusContractEntry(
                      Contract,
                      "Bonus Customer",
                      0,                                          //Postenart Bonus
                      PostingDate,
                      BonusContractLine."Line No.",           //Bonusregelzeile
                      SalesLine.Quantity,                //Menge
                      SalesLine.Amount,                  //Betrag
                      SalesLine."Amount Including VAT",  //Betrag inkl. Vat
                                                         //DocAmt * Sign,                             //Belegbetrag
                      ItemChargeAssRec."Applies-to Doc. Line Amount" * Sign,
                      DiscAmount,
                      PmtDiscAmount);

                    SalesLine."Description 2" := ContractTxt + Format(Contract."No.") + ': ' + Zusatz;
                    // SalesLine.Printoption := SalesLine.Printoption::"Line Invisible";
                    // SalesLine."Billing Code" := VertriebEinrRec."Billing Code";
                    SetDimensions(TableID, DocNo, DocLineNo, SalesHeader, SalesLine);
                    SalesLine.Modify(true);
                end;
            until SalesLine.Next() = 0;
    end;
    #endregion HandleSeparatedLines

    #region CreateItemChargeForBillingTypeAmount
    local procedure CreateItemChargeForBillingTypeAmount(var Contract: Record "lbtbn Bonus Contract"; TableID: Integer; DocNo: Code[20]; DocLineNo: Integer; BonusSumme: Decimal; DiscAmount: Decimal; PmtDiscAmount: Decimal; SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; DocType: Integer; OldLineNo: Integer; Sign: Integer; var Betrag: Decimal)
    var
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        CustRec: Record Customer;
        ItemChargeAssRec: Record "Item Charge Assignment (Sales)";
        PostedSalesShptLineRec: Record "Sales Shipment Line";
        AssignItemChargeSales: Codeunit "Item Charge Assgnt. (Sales)";
        AmountCust: Decimal;
        TotalQuantity: Decimal;
        FixedAmountTxt: Label 'Fixed Amount';
        Zusatz: Text;
    begin
        if CustRec."Currency Code" = '' then
            AmountCust := BonusContractLine.Value
        else
            if Currency.Get(CustRec."Currency Code") then begin
                Currency.TestField("Unit-Amount Rounding Precision");
                AmountCust :=
                  Round(
                   CurrExchRate.ExchangeAmtLCYToFCY(
                    PostingDate, CustRec."Currency Code", BonusContractLine.Value,
                     CurrExchRate.ExchangeRate(PostingDate, CustRec."Currency Code")),
                      Currency."Unit-Amount Rounding Precision");
            end;
        Zusatz := FixedAmountTxt;
        PostedSalesShptLineRec.Reset();
        //PostedSalesShptLineRec.SETRANGE("Sell-to Customer No.","Bonus Contract".Customer);
        PostedSalesShptLineRec.SetRange("Sell-to Customer No.", "Bonus Customer"."Customer No.");
        PostedSalesShptLineRec.SetRange("Posting Date", DateFrom, DateTo);
        PostedSalesShptLineRec.SetRange(Type, PostedSalesShptLineRec.Type::Item);
        PostedSalesShptLineRec.SetFilter(Quantity, '<>%1', 0);
        ItemChargeAssRec."Document Type" := SalesLine."Document Type";
        ItemChargeAssRec."Document No." := SalesLine."Document No.";
        ItemChargeAssRec."Document Line No." := SalesLine."Line No.";
        ItemChargeAssRec."Unit Cost" := SalesLine."Unit Price";
        ItemChargeAssRec."Item Charge No." := SalesLine."No.";
        // ItemChargeAssRec."lbt Process No." := SalesLine."lbt Process No.";
        AssignItemChargeSales.CreateShptChargeAssgnt(PostedSalesShptLineRec, ItemChargeAssRec);
        AssignItemChargeSales.AssignItemCharges(SalesLine, AmountCust, TotalQuantity, AssignItemChargeSales.AssignByAmountMenuText());
        ItemChargeAssRec.Reset();
        ItemChargeAssRec.SetRange("Document Type", SalesLine."Document Type");
        ItemChargeAssRec.SetRange("Document No.", SalesLine."Document No.");
        ItemChargeAssRec.SetRange("Document Line No.", SalesLine."Line No.");
        CreateSeparateLines(SalesLine, ItemChargeAssRec);
        HandleSeparatedLines(Contract, TableID, DocNo, DocLineNo, DiscAmount, PmtDiscAmount, ItemChargeAssRec, SalesHeader, DocType, OldLineNo, Sign, Zusatz);
        Betrag := AmountCust * BonusSumme;
    end;
    #endregion CreateItemChargeForBillingTypeAmount

    #region CreateItemChargeForBillingTypeAmountPerUnit
    local procedure CreateItemChargeForBillingTypeAmountPerUnit(DocAmt: Decimal; BonusSumme: Decimal; var SalesLine: Record "Sales Line"; Sign: Integer) Zusatz: Text
    var
        ItemChargeAssRec: Record "Item Charge Assignment (Sales)";
        ItemLedgEntryRec: Record "Item Ledger Entry";
        CustRec: Record Customer;
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        AmountCust: Decimal;
        PerTxt: Label ' per ';
    begin
        SalesLine.Validate(Quantity, BonusSumme);
        ItemChargeAssRec.Init();
        ItemChargeAssRec."Document Type" := SalesLine."Document Type";
        ItemChargeAssRec."Document No." := SalesLine."Document No.";
        ItemChargeAssRec."Document Line No." := SalesLine."Line No.";
        ItemChargeAssRec."Line No." := 10000;
        ItemChargeAssRec."Item Charge No." := SalesLine."No.";
        if Sign = 1 then
            ItemChargeAssRec."Applies-to Doc. Type" := ItemChargeAssRec."Applies-to Doc. Type"::Shipment
        else
            ItemChargeAssRec."Applies-to Doc. Type" := ItemChargeAssRec."Applies-to Doc. Type"::"Return Receipt";
        ItemChargeAssRec."Applies-to Doc. Line Amount" := Sign * DocAmt;
        ItemChargeAssRec."Item No." := ItemLedgEntryRec."Item No.";
        ItemChargeAssRec.Description := ItemLedgEntryRec.Description;
        ItemChargeAssRec."Applies-to Doc. No." := ItemLedgEntryRec."Document No.";
        ItemChargeAssRec."Applies-to Doc. Line No." := ItemLedgEntryRec."Document Line No.";
        ItemChargeAssRec."Unit Cost" := 1;
        ItemChargeAssRec.Validate("Qty. to Assign", BonusSumme);
        ItemChargeAssRec.Insert();

        CustRec.Get("Bonus Customer"."Customer No.");
        if CustRec."Currency Code" = '' then
            AmountCust := BonusContractLine.Value
        else
            if Currency.Get(CustRec."Currency Code") then begin
                Currency.TestField("Unit-Amount Rounding Precision");
                AmountCust :=
                  Round(
                   CurrExchRate.ExchangeAmtLCYToFCY(
                    PostingDate, CustRec."Currency Code", BonusContractLine.Value,
                     CurrExchRate.ExchangeRate(PostingDate, CustRec."Currency Code")),
                      Currency."Unit-Amount Rounding Precision");
            end;
        Zusatz := Format(AmountCust) + PerTxt + Format(BonusContractLine."Item Unit of Measure");
    end;
    #endregion CreateItemChargeForBillingTypeAmountPerUnit





    var
        BonusContractLine: Record "lbtbn Bonus Contract Line";
        BonusSetup: Record "lbtbn Bonus Setup";
        CustomerPostingGroup: Record "Customer Posting Group";
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        Dialog: Dialog;
        SalesPersonCode: Code[20];
        DateFrom: Date;
        DateTo: Date;
        PostingDate: Date;
        ReversePostingDate: Date;
        BonusAmount: Decimal;
        BillingEntry: Integer;
        AccountingPeriodMissingErr: Label 'Please input the accounting period.';
        AccountingPeriodTxt: Label 'Accounting Period %1 to %2', Comment = '%1 from, %2 to';
        BonusCreditMemoLbl: Label 'Bonus Credit Memo';
        BonusSettlementTxt: Label 'Bonus Accounting according to Bonus Contract %1', Comment = '%1 No.';
        ContractProgressTxt: Label 'Bonus Contract #2##############\', Comment = '%1 No.';
        CustomerProgressTxt: Label 'Customer    #1##############\', Comment = '%1 No.';
        SalesDocProgressTxt: Label 'Sales Document #3##############', Comment = '%1 No.';
        ContractTxt: Label 'Contract';



}