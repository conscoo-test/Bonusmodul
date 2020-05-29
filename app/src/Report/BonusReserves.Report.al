report 5266051 "lbt Bonus Reserves"
{
    Caption = 'Bonus Reserves', comment = 'DEU="Bonusrückstellungslauf"';
    UsageCategory = None;
    ProcessingOnly = true;

    dataset
    {
        dataitem("Bonus Contract"; "lbt Bonus Contract")
        {
            DataItemTableView = sorting("contract");
            RequestFilterFields = "Contract", "Billing Period";

            dataitem("Bonus Customers"; "lbt Bonus Customers")
            {
                DataItemTableView = sorting("Contract", "Customer", "Ship-to Code");
                DataItemLink = "Contract" = field("Contract");

                dataitem("Sales Invoice Header"; "Sales Invoice Header")
                {
                    DataItemTableView = sorting("Sell-to Customer No.", "Posting Date");
                    DataItemLink = "Sell-to Customer No." = field("Customer");

                    trigger OnPreDataItem()
                    begin
                        if "Bonus Contract"."Reserve Type" = "Bonus Contract"."Reserve Type"::"Amount (LCY)" then
                            CurrReport.Break();

                        SetRange("Posting Date", DateFrom, DateTo);
                        PostingDate := DateTo;
                        if "Bonus Customers"."Ship-to Code" <> '' then
                            SetRange("Ship-to Code", "Bonus Customers"."Ship-to Code")
                        else
                            SetRange("Ship-to Code");
                    end;

                    trigger OnAfterGetRecord()
                    begin
                        CalcFromSalesInvoice();
                    end;
                }

                dataitem("Sales Cr.Memo Header"; "Sales Cr.Memo Header")
                {
                    DataItemTableView = sorting("Sell-to Customer No.", "Posting Date");
                    DataItemLink = "Sell-to Customer No." = field("Customer");

                    trigger OnPreDataItem()
                    begin
                        if "Bonus Contract"."Reserve Type" = "Bonus Contract"."Reserve Type"::"Amount (LCY)" then
                            CurrReport.Break();

                        SetRange("Posting Date", DateFrom, DateTo);
                        if "Bonus Customers"."Ship-to Code" <> '' then
                            SetRange("Ship-to Code", "Bonus Customers"."Ship-to Code")
                        else
                            SetRange("Ship-to Code");
                    end;

                    trigger OnAfterGetRecord()
                    begin
                        CalcFromCrMemo();
                    end;
                }
                dataitem("Fixed Amount"; Integer)
                {
                    DataItemTableView = sorting(Number) Where(Number = const(1));

                    trigger OnPreDataItem()
                    begin
                        if "Bonus Contract"."Reserve Type" <> "Bonus Contract"."Reserve Type"::"Amount (LCY)" then
                            CurrReport.Break();
                    end;

                    trigger OnAfterGetRecord()
                    var
                        SalesLine: Record "Sales Line";
                    begin
                        case BonusSetup."Reserve Mode" of
                            BonusSetup."Reserve Mode"::CreditMemo:
                                begin
                                    CreateBonusCrMemoLine(0, '', 0, "Bonus Contract"."Reserve Value", 0, SalesLine);
                                    CreateBonusEntryForFixedAmount(SalesLine);
                                end;
                            BonusSetup."Reserve Mode"::Journal:
                                CreateJournalLine(0, "Bonus Contract"."Contract", 0, "Bonus Customers"."Customer", "Bonus Contract"."Reserve Value", 0,
                                  0, 0);
                        end;
                    end;
                }
            }

            // DataItem "Bonus Contract"
            trigger OnPreDataItem()
            begin
                Dia.Open(CustomerProgressTxt + ContractProgressTxt);
                PostingDate := DateTo;
            end;

            trigger OnAfterGetRecord()
            begin
                Dia.Update(1, "No. of Customers");
                Dia.Update(2, "Contract");

                if not CheckDates() then
                    CurrReport.Skip();

                "Last Reserve at" := PostingDate;
                Modify();
            end;

            trigger OnPostDataItem()
            begin
                Dia.Close();
                Commit();

                OpenPage();
            end;
        }
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
                        Caption = 'Date from', comment = 'DEU="Datum von"';
                        ToolTip = 'In consideration of the sart date, all invoice and credit lines of the period are used, which are additionally checked for relevance of the corresponding contract conditions (calculation rules).', comment = 'DEU="Unter Berücksichtigung des Sartdatums, werden alle Rechnungs-und Gutschriftszeilen des Zeitraums herangezogen, welche zusätzlich auf Relevanz der entsprechenden Vertragsbedingungen (Berechnungsregeln) geprüft werden."';
                        ApplicationArea = All;
                    }
                    field("Date To"; DateTo)
                    {
                        Caption = 'Date to', comment = 'DEU="Datum Bis"';
                        ToolTip = 'In Consideration of the end date, all invoice and credit memo lines of the period are used, which are also checked for relevance of the corresponding contract conditions (calculation rules).', comment = 'DEU="Unter Berücksichtigung des Enddatums, werden alle Rechnungs-und Gutschriftszeilen des Zeitraums herangezogen, welche zusätzlich auf Relevanz der entsprechenden Vertragsbedingungen (Berechnungsregeln) geprüft werden."';
                        ApplicationArea = All;
                    }

                }
            }
        }
    }

    trigger OnInitReport()
    begin

    end;

    trigger OnPreReport()
    var
        GenJournalLine: Record "Gen. Journal Line";

    begin
        if (DateFrom = 0D) or (DateTo = 0D) then
            Error(InputAccountingPeriodMsg);
        if DateFrom > DateTo then
            Error(CheckAccountingPeriodMsg);
        BonusSetup.Get();
        if BonusSetup."Reserve Mode" = BonusSetup."Reserve Mode"::CreditMemo then begin
            // BonusSetup.TestField("Customer Reserve Cr.Memo")
        end
        else begin
            BonusSetup.TestField("Gen.Jnl.Templ.BonusReserve");
            BonusSetup.TestField("Gen. Jnl. Bonus Reserve");
        end;
        GenJournalLine.Reset();
        GenJournalLine.SetRange("Journal Template Name", BonusSetup."Gen.Jnl.Templ.BonusReserve");
        GenJournalLine.SetRange("Journal Batch Name", BonusSetup."Gen. Jnl. Bonus Reserve");
        if GenJournalLine.FindLast() then
            LineNo := GenJournalLine."Line No."
        else
            LineNo := 0;

    end;

    local procedure CreateBonusEntryForFixedAmount(var SalesLine: Record "Sales Line")
    begin
        BonusMgt.SetBonusDoc(2, SalesLine."Document No.", SalesLine."Line No.");
        BonusEntryNo := BonusMgt.CreateBonusContractEntry(
                                   "Bonus Contract",
                                   "Bonus Customers",
                                   1, PostingDate, 0,
                                   0, SalesLine.Amount, 0,
                                   SalesLine.Amount,
                                   0, 0);
        SalesLine."lbt Process No." := "Bonus Contract"."Process No.";
        SalesLine."lbt Bonus Entry No." := BonusEntryNo;
        SalesLine.Modify();
    end;

    local procedure OpenPage()
    var
        GenJournalLine: Record "Gen. Journal Line";
        SalesHeader: Record "Sales Header";
        SalesCreditMemoPage: Page "Sales Credit Memo";
        GenJnlPage: Page "General Journal";

    begin
        case BonusSetup."Reserve Mode" of
            BonusSetup."Reserve Mode"::CreditMemo:
                begin
                    if not CrMemoHeaderCreated then
                        exit;
                    SalesHeader.SetRange("Document Type", SalesHeader."Document Type");
                    SalesHeader.SetRange("No.", SalesHeader."No.");
                    SalesCreditMemoPage.SetTableView(SalesHeader);
                    SalesCreditMemoPage.Run();
                end;
            BonusSetup."Reserve Mode"::Journal:
                begin
                    GenJournalLine.SetRange("Journal Batch Name", BonusSetup."Gen. Jnl. Bonus Reserve");
                    GenJournalLine.SetRange("Journal Template Name", BonusSetup."Gen.Jnl.Templ.BonusReserve");
                    GenJnlPage.SetTableView(GenJournalLine);
                    GenJnlPage.Run();
                end;
        end;

    end;

    local procedure CheckDates(): Boolean
    begin
        with "Bonus Contract" do begin
            if (PostingDate < "Valid from") or (("Valid to" <> 0D) and (PostingDate > "Valid to")) then
                exit(false);

            if "Last Reserve at" >= DateFrom then
                exit(false);
        end;
        exit(true);
    end;

    local procedure getTotalAmount(): Decimal
    var
        BonusCust: Record "lbt Bonus Customers";
        ContractTotalAmt: Decimal;
    begin
        ContractTotalAmt := 0;
        BonusCust.Reset();
        BonusCust.SetRange("Contract", "Bonus Contract"."Contract");
        if BonusCust.FindSet() then
            Repeat
                SalesShipmentLineRec.Reset();
                SalesShipmentLineRec.SetRange("Sell-to Customer No.", BonusCust."Customer");
                SalesShipmentLineRec.SetRange("Posting Date", DateFrom, DateTo);
                SalesShipmentLineRec.SetRange(Type, SalesShipmentLineRec.Type::Item);
                SalesShipmentLineRec.SetFilter(Quantity, '<>%1', 0);
                SalesShipmentLineRec.SetFilter("Unit Price", '<>%1', 0);
                if SalesShipmentLineRec.FindSet() then
                    Repeat
                        SalesShipmentHeaderRec.Get(SalesShipmentLineRec."Document No.");
                        if SalesShipmentHeaderRec."Currency Code" = '' then
                            ContractTotalAmt += SalesShipmentLineRec."Item Charge Base Amount"
                        else
                            ContractTotalAmt += Round(SalesShipmentLineRec."Item Charge Base Amount" / SalesShipmentHeaderRec."Currency Factor", 0.01);
                    until SalesShipmentLineRec.Next() = 0;
            until BonusCust.Next() = 0;
        Exit(ContractTotalAmt);
    end;

    local procedure FindQuantity(TableNo: Integer; DocNo: Code[20]; DocLineNo: Integer): Decimal
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        case TableNo of
            Database::"Sales Invoice Line":
                if SalesInvoiceLine.Get(DocNo, DocLineNo) then
                    exit(SalesInvoiceLine.Quantity);
            Database::"Sales Cr.Memo Line":
                if SalesCrMemoLine.Get(DocNo, DocLineNo) then
                    exit(SalesCrMemoLine.Quantity);
        end;
    end;

    local procedure FindQuantity(quantity: decimal): Decimal
    begin
        //TODO: implementation
        // PostDocItemUnitRec.Reset;
        // PostDocItemUnitRec.SetRange("Table ID", Database::"Sales Invoice Line");
        // PostDocItemUnitRec.SetRange("Document No.", PostedSalesInvLineRec."Document No.");
        // PostDocItemUnitRec.SetRange("Document Line No.", PostedSalesInvLineRec."Line No.");
        // PostDocItemUnitRec.SetRange("Item Unit", "Bonus Contract"."Unit Reserves Base");

        // if PostDocItemUnitRec.FindFirst() then 
        //   exit(PostDocItemUnitRec.Quantity)
        exit(quantity);
    end;

    local procedure CheckAttributes(ItemNo: Code[20]): Boolean
    var
        BonusContractAttribute: Record "lbt BonusContractAttribute";
        ItemAttributeValue: Record "Item Attribute Value";
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
    begin
        exit(true);
        BonusContractAttribute.SetRange(Contract, "Bonus Contract".Contract);
        if BonusContractAttribute.FindSet() then
            repeat
                if ItemAttributeValueMapping.Get(Database::Item, ItemNo, BonusContractAttribute."Attribute ID") then begin
                    ItemAttributeValue.Get(ItemAttributeValueMapping."Item Attribute ID", ItemAttributeValueMapping."Item Attribute Value ID");
                    case BonusContractAttribute."Attribute Type" of
                        BonusContractAttribute."Attribute Type"::Decimal:
                            ;
                        BonusContractAttribute."Attribute Type"::Integer:
                            ;
                        BonusContractAttribute."Attribute Type"::Text:

                            ;
                        BonusContractAttribute."Attribute Type"::Option:
                            if ItemAttributeValue."Attribute ID" = BonusContractAttribute."Attribute ID" then
                                exit(true);
                    end;
                end;

            //     if PostParaDocLineRec.FindFirst then begin

            //         case BonusContractAttribute."Attribute Type" of
            //             BonusContractAttribute."Attribute Type"::Text:
            //                 begin
            //                     PostParaDocLineRec.SetFilter("Parameter Domain", BonusContractAttribute."Parameter Filter");

            //                     if PostParaDocLineRec.ISEMPTY then
            //                         Continue := false;
            //                 end;
            //             BonusContractAttribute."Attribute Type"::Decimal:
            //                 begin
            //                     if BonusContractAttribute."Parameter Filter" <> '' then begin
            //                         if StrPos(BonusContractAttribute."Parameter Filter", '<>') = 1 then
            //                             PostParaDocLineRec.SetFilter("Decimal from", BonusContractAttribute."Parameter Filter")
            //                         else begin
            //                             if StrPos(BonusContractAttribute."Parameter Filter", '..') = 1 then
            //                                 PostParaDocLineRec.SetFilter("Decimal from", '..' + ForMAT(BonusContractAttribute."Decimal to"))
            //                             else
            //                                 PostParaDocLineRec.SetFilter("Decimal to", ForMAT(BonusContractAttribute."Decimal from") + '..');
            //                         end;
            //                     end else begin
            //                         if (BonusContractAttribute."Decimal from" <> 0) and (BonusContractAttribute."Decimal to" <> 0) then begin
            //                             PostParaDocLineRec.SetFilter("Decimal from", ForMAT(BonusContractAttribute."Decimal from") + '..' +
            //                                                                         ForMAT(BonusContractAttribute."Decimal to"));
            //                             PostParaDocLineRec.SetFilter("Decimal to", ForMAT(BonusContractAttribute."Decimal from") + '..' +
            //                                                                       ForMAT(BonusContractAttribute."Decimal to"));
            //                         end;
            //                         if (BonusContractAttribute."Decimal from" <> 0) and (BonusContractAttribute."Decimal to" = 0) then
            //                             PostParaDocLineRec.SetFilter("Decimal from", ForMAT(BonusContractAttribute."Decimal from") + '..');

            //                         if (BonusContractAttribute."Decimal from" < 0) and (BonusContractAttribute."Decimal to" = 0) then begin
            //                             PostParaDocLineRec.SetFilter("Decimal from", ForMAT(BonusContractAttribute."Decimal from") + '..' +
            //                                                                         ForMAT(BonusContractAttribute."Decimal to"));
            //                             PostParaDocLineRec.SetFilter("Decimal to", ForMAT(BonusContractAttribute."Decimal from") + '..' +
            //                                                                       ForMAT(BonusContractAttribute."Decimal to"));
            //                         end;

            //                         if (BonusContractAttribute."Decimal from" = 0) and (BonusContractAttribute."Decimal to" <> 0) then
            //                             PostParaDocLineRec.SetFilter("Decimal to", ForMAT(BonusContractAttribute."Decimal from") + '..' +
            //                                                                       ForMAT(BonusContractAttribute."Decimal to"));

            //                         if (BonusContractAttribute."Decimal from" = 0) and (BonusContractAttribute."Decimal to" < 0) then
            //                             PostParaDocLineRec.SetFilter("Decimal to", '..' + ForMAT(BonusContractAttribute."Decimal to"));
            //                     end;
            //                     ///LBIS01
            //                     //if not PostParaDocLineRec.FindSet then
            //                     if PostParaDocLineRec.ISEMPTY then
            //                         ///LBIS01-
            //                         Continue := false;
            //                 end;
            //         end;
            //     end else
            //         Continue := false;
            until (BonusContractAttribute.Next() = 0);
    end;

    local procedure CalcItemCharge(TableNo: Integer; LineNo: Integer; var DocAmtInclVAT: Decimal; var DocAmount: Decimal)
    var
        ValueEntry: Record "Value Entry";
        ValueEntry2: Record "Value Entry";
        SalesInvLineRec: Record "Sales Invoice Line";
        ItemCharge: Record "Item Charge";
        ItemLedgerEntry: Record "Item Ledger Entry";
        l_Sign: Integer;
    begin
        ValueEntry.Reset();
        ValueEntry.SetCurrentKey("Document No.");
        case TableNo of
            Database::"Sales Invoice Line":
                begin
                    ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Invoice");
                    ValueEntry.SetRange("Document No.", "Sales Invoice Header"."No.");
                    l_Sign := 1;
                end;
            Database::"Sales Cr.Memo Line":
                begin
                    ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Credit Memo");
                    ValueEntry.SetRange("Document No.", "Sales Cr.Memo Header"."No.");
                    l_Sign := -1;
                end;

        end;
        ValueEntry.SetRange("Document Line No.", LineNo);
        if ValueEntry.FindSet() then
            Repeat
                if ValueEntry."Sales Amount (Actual)" <> 0 then begin
                    if ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.") then
                        ValueEntry2.Reset();
                    ValueEntry2.SetCurrentKey("Item Ledger Entry No.");
                    ValueEntry2.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
                    ValueEntry2.SetFilter("Item Charge No.", '<>%1', '');
                    if ValueEntry2.FindSet() then
                        Repeat
                            ItemCharge.Get(ValueEntry2."Item Charge No.");
                            if ItemCharge."lbt Bonus consider" then
                                DocAmount += l_Sign * ValueEntry2."Sales Amount (Actual)";
                            if SalesInvLineRec.Get(ValueEntry2."Document No.", ValueEntry2."Document Line No.") then
                                DocAmtInclVAT += l_Sign * Round(ValueEntry2."Sales Amount (Actual)" *
                                          (100 + SalesInvLineRec."VAT %") / 100, 0.0001)

                        until ValueEntry2.Next() = 0;
                end;

            until ValueEntry.Next() = 0;

    end;

    local procedure CreateForReserveMode_CreditMemo(TableNo: Integer; DocNo: Code[20]; p_LineNo: Integer; Qty: Decimal; BonusAmt: Decimal; PmtDiscAmt: Decimal; DocAmount: Decimal; DiscAmt: Decimal)
    var
        ValueEntry: Record "Value Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        SalesLine: Record "Sales Line";
        DocTypeMatches: Boolean;
    begin
        "Bonus Contract".TestField("Reserve Item Charge");
        ValueEntry.Reset();
        ValueEntry.SetCurrentKey("Document No.");
        ValueEntry.SetRange("Document No.", DocNo);
        case TableNo of
            Database::"Sales Invoice Line":
                ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Invoice");
            Database::"Sales Cr.Memo Line":
                ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Credit Memo");
        end;
        ValueEntry.SetRange("Document Line No.", p_LineNo);
        if ValueEntry.FindFirst() then begin
            case TableNo of
                Database::"Sales Invoice Line":
                    DocTypeMatches := (ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Sales Shipment");
                Database::"Sales Cr.Memo Line":
                    DocTypeMatches := (ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Sales Return Receipt");
            end;
            CreateBonusCrMemoLine(TableNo, DocNo, p_LineNo, BonusAmt, DocAmount, SalesLine);
            AddItemChargeToSalesLine(SalesLine, TableNo, DocNo, p_LineNo, DocAmount, BonusAmt);
            if ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.") and DocTypeMatches then begin
                Clear(BonusMgt);
                BonusMgt.SetAssignmentDoc(1, ItemLedgerEntry."Document No.", ItemLedgerEntry."Document Line No.");
                BonusMgt.SetSourceDoc(1, DocNo, p_LineNo);
                BonusMgt.SetBonusDoc(2, SalesLine."Document No.", SalesLine."Line No.");
                BonusEntryNo := BonusMgt.CreateBonusContractEntry(
                                    "Bonus Contract",
                                    "Bonus Customers",
                                    1,
                                    PostingDate,
                                    0,
                                    Qty, ////PostDocItemUnitRec.Quantity,
                                    BonusAmt,
                                    BonusAmt,
                                    DocAmount,
                                    -DiscAmt,
                                    -PmtDiscAmt);
                SalesLine."lbt Bonus Entry No." := BonusEntryNo;
                SalesLine.Modify();
            end;
        end;

    end;

    local procedure CreateBonusCrMemoLine(TableNo: Integer; DocNoP: Code[20]; LineNoP: Integer; BonusAmt: Decimal; DocAmount: Decimal; var SalesLineRec: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
    begin
        CreateCrMemoHeader(SalesHeader);

        SalesLineRec.Init();
        SalesLineRec."Document Type" := SalesHeader."Document Type";
        SalesLineRec."Document No." := SalesHeader."No.";
        SalesLineNo += 10000;
        SalesLineRec."Line No." := SalesLineNo;
        SalesLineRec.Validate(Type, SalesLineRec.Type::"Charge (Item)");
        SalesLineRec.Validate("No.", "Bonus Contract"."Reserve Item Charge");
        SalesLineRec.Validate("Unit Price", BonusAmt);
        SalesLineRec.Validate(Quantity, 1);
        SalesLineRec."Shipment Date" := WorkDate();
        SalesLineRec."Allow Invoice Disc." := true;
        SalesLineRec.Description := BonusReserveForLbl;
        case TableNo of
            Database::"Sales Invoice Line":
                SalesLineRec."Description 2" := InvoiceLbl + DocNoP;
            Database::"Sales Cr.Memo Line":
                SalesLineRec."Description 2" := CrMemoLbl + DocNoP;
            0:
                SalesLineRec."Description 2" := FixedAmountLbl;
        end;
        SalesLineRec."lbt Process No." := "Bonus Contract"."Process No.";
        //TODO: 
        // if Sign = 1 then begin
        //     SalesLine."Shortcut Dimension 1 Code" := PostedSalesInvLineRec."Shortcut Dimension 1 Code";
        //     SalesLine."Shortcut Dimension 2 Code" := PostedSalesInvLineRec."Shortcut Dimension 2 Code";
        //     SalesLine."Dimension Set ID" := PostedSalesInvLineRec."Dimension Set ID";

        // end else begin
        //     SalesLine."Shortcut Dimension 1 Code" := PostedCrMemoLineRec."Shortcut Dimension 1 Code";
        //     SalesLine."Shortcut Dimension 2 Code" := PostedCrMemoLineRec."Shortcut Dimension 2 Code";
        //     CrMemoLSalesLineineRec."Dimension Set ID" := PostedCrMemoLineRec."Dimension Set ID";
        // end;
        if SalesHeader."Shortcut Dimension 1 Code" <> '' then
            SalesLineRec.Validate("Shortcut Dimension 1 Code", SalesHeader."Shortcut Dimension 1 Code");
        SalesLineRec.Insert();
    end;

    local procedure AddItemChargeToSalesLine(var SalesLine: Record "Sales Line"; TableNo: Integer; DocNo: Code[20]; DocLineNo: Integer; DocAmount: Decimal; BonusAmount: Decimal)
    var
        ItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)";
    begin
        ItemChargeAssignmentSales.Init();
        ItemChargeAssignmentSales."Document Type" := SalesLine."Document Type";
        ItemChargeAssignmentSales."Document No." := SalesLine."Document No.";
        ItemChargeAssignmentSales."Document Line No." := SalesLine."Line No.";
        ItemChargeAssignmentSales."Line No." := 10000;
        ItemChargeAssignmentSales."Item Charge No." := SalesLine."No.";

        case TableNo of
            Database::"Sales Invoice Line":
                //begin TODO:
                // ItemChargeAssignmentSales."Item No." := PostedSalesInvLineRec."No.";
                // ItemChargeAssignmentSales.Description := PostedSalesInvLineRec.Description;
                ItemChargeAssignmentSales."Applies-to Doc. Type" := ItemChargeAssignmentSales."Applies-to Doc. Type"::Shipment;
            //end 
            Database::"Sales Cr.Memo Line":
                //begin
                // ItemChargeAssignmentSales."Item No." := PostedCrMemoLineRec."No.";
                // ItemChargeAssignmentSales.Description := PostedCrMemoLineRec.Description;
                ItemChargeAssignmentSales."Applies-to Doc. Type" := ItemChargeAssignmentSales."Applies-to Doc. Type"::"Return Receipt";
        //end;
        end;
        ItemChargeAssignmentSales."Applies-to Doc. Line Amount" := DocAmount;
        ItemChargeAssignmentSales."Applies-to Doc. No." := DocNo;
        ItemChargeAssignmentSales."Applies-to Doc. Line No." := DocLineNo;
        ItemChargeAssignmentSales."Unit Cost" := 1;
        ItemChargeAssignmentSales.Validate("Qty. to Assign", BonusAmount);
        ItemChargeAssignmentSales.Insert();
    end;


    local procedure CreateCrMemoHeader(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        if CrMemoHeaderCreated then
            exit;

        with SalesHeader do begin
            Reset();
            SetCurrentKey("Document Type", "Sell-to Customer No.");
            SetRange("Document Type", "Document Type"::"Credit Memo");
            SetRange("Sell-to Customer No.", BonusSetup."Customer Reserve Cr.Memo");
            SetRange("Posting Description", BonusReserveLbl);
            if FindFirst() then
                Error(UnpostedCreditMemoErr);

            Init();
            "Document Type" := "Document Type"::"Credit Memo";
            "No. Series" := BonusSetup."Reserve Cr.Memo Nos.";
            "Posting No. Series" := BonusSetup."Reserve Cr.Memo Nos.";
            "Shipping No. Series" := BonusSetup."Reserve Cr.Memo Nos.";
            "Return Receipt No. Series" := BonusSetup."Reserve Cr.Memo Nos.";
            "No." := NoSeriesManagement.GetNextNo("No. Series", WorkDate(), true);
            Insert(true);
            SetHideValidationDialog(true);
            Validate("Sell-to Customer No.", BonusSetup."Customer Reserve Cr.Memo");
            // Validate("Gen. Bus. Posting Group", BonusSetupRec."Bus.Post.Gr.f.Res.Cr.Memo");
            // Validate("Customer Posting Group", BonusSetupRec."Cust Gr. Reserve Cr. Memo");
            "Posting Description" := BonusReserveLbl;
            PostingDate := 0D;
            "lbt Process No." := "Bonus Contract"."Process No.";
            Modify();

            CrMemoHeaderCreated := true;
        end;

        with SalesLine do begin
            SalesLineNo := 10000;
            Init();
            "Document Type" := SalesHeader."Document Type";
            "Document No." := SalesHeader."No.";
            "Line No." := SalesLineNo;
            Description := StrSubstNo(BonusAccountingLbl, "Bonus Contract".Contract);
            Insert();

            SalesLineNo += 10000;
            "Line No." := SalesLineNo;
            Description := StrSubstNo(AccountingPeriodLbl, DateFrom, DateTo);
            Insert();
        end;
    end;

    local procedure CreateJournalLine(TableID: Integer; var DocNo: Code[20]; DocLineNo: Integer; var CustNo: Code[20]; var Amt: Decimal; DocAmt: Decimal; DiscAmount: Decimal; PmtDiscAmount: Decimal)
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        CustomerPostingGroup: Record "Customer Posting Group";
        DimMgt: Codeunit DimensionManagement;

        DocType: Integer;
        vz: Integer;
    begin
        if Customer.Get(CustNo) then
            if CustomerPostingGroup.Get(Customer."Customer Posting Group") then begin
                CustomerPostingGroup.TestField("lbt Bonus Reserve Account");
                CustomerPostingGroup.TestField("lbt Bonus Reserve Bal. Account");
                DocType := 0;
                vz := 1;
                case TableID of
                    Database::"Sales Invoice Header", Database::"Sales Invoice Line":
                        DocType := 1;

                    Database::"Sales Cr.Memo Header", Database::"Sales Cr.Memo Line":
                        begin
                            DocType := 2;
                            vz := -1;
                        end;
                end;
                Clear(BonusMgt);
                BonusMgt.SetSourceDoc(DocType, DocNo, DocLineNo);
                BonusMgt.SetBonusDoc(0, '', 0);
                BonusEntryNo := BonusMgt.CreateBonusContractEntry(
                    "Bonus Contract",
                    "Bonus Customers",
                    1,                //Postenart Rückstellung
                    PostingDate,
                    0,                //Bonusregelzeile
                    0,                //Menge
                    Amt * vz,              //Betrag
                    Amt * vz,              //Betrag inkl. Vat
                    DocAmt * vz,         //Belegbetrag
                    DiscAmount * vz,
                    PmtDiscAmount * vz);

                GenJournalLine.Init();
                GenJournalLine."Journal Template Name" := BonusSetup."Gen.Jnl.Templ.BonusReserve";
                GenJournalLine."Journal Batch Name" := BonusSetup."Gen. Jnl. Bonus Reserve";
                GenJournalLine."Line No." := LineNo + 10000;
                LineNo := GenJournalLine."Line No.";
                GenJournalLine.Validate("Posting Date", PostingDate);
                GenJournalLine."Document No." := DocNo;
                GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
                GenJournalLine.Validate("Account No.", CustomerPostingGroup."lbt Bonus Reserve Account");
                GenJournalLine.Validate("Bal. Account No.", CustomerPostingGroup."lbt Bonus Reserve Bal. Account");
                GenJournalLine."Gen. Bus. Posting Group" := '';
                GenJournalLine."Gen. Prod. Posting Group" := '';
                GenJournalLine.Description := BonusReserveForLbl + FORMAT("Bonus Contract".Contract);
                GenJournalLine.Validate(Amount, Amt * vz);
                GenJournalLine."lbt Process No." := "Bonus Contract"."Process No.";
                GenJournalLine."lbt Bonus Entry No" := BonusEntryNo;
                GenJournalLine."Reason Code" := BonusSetup."Reason Code";
                if (TableID <> 0) then
                    case TableID of
                        database::"Sales Invoice Line":
                            begin
                                SalesInvoiceLine.Get(DocNo, DocLineNo);
                                GenJournalLine."Shortcut Dimension 1 Code" := SalesInvoiceLine."Shortcut Dimension 1 Code";
                                GenJournalLine."Shortcut Dimension 2 Code" := SalesInvoiceLine."Shortcut Dimension 2 Code";
                                GenJournalLine."Dimension Set ID" := SalesInvoiceLine."Dimension Set ID";
                            end;
                        Database::"Sales Cr.Memo Line":
                            begin
                                SalesCrMemoLine.Get(DocNo, DocLineNo);
                                GenJournalLine."Shortcut Dimension 1 Code" := SalesCrMemoLine."Shortcut Dimension 1 Code";
                                GenJournalLine."Shortcut Dimension 2 Code" := SalesCrMemoLine."Shortcut Dimension 2 Code";
                                GenJournalLine."Dimension Set ID" := SalesCrMemoLine."Dimension Set ID";
                            end;
                    end
                else begin
                    GenJournalLine."Dimension Set ID" := CreateDimSetID("Bonus Contract".Contract);
                    DimMgt.UpdateGlobalDimFromDimSetID(GenJournalLine."Dimension Set ID",
                                                         GenJournalLine."Shortcut Dimension 1 Code",
                                                          GenJournalLine."Shortcut Dimension 2 Code");
                end;
                GenJournalLine.Insert();
            end;
    end;

    local procedure CreateDimSetID(var ContractNo: Code[20]): Integer
    var
        BonusContractDimensions: Record "lbt Bonus Contract Dimensions";
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        DimMgt: Codeunit DimensionManagement;
    begin
        BonusContractDimensions.SetRange(Contract, "Bonus Contract".Contract);
        if BonusContractDimensions.FindSet() then
            repeat
                TempDimensionSetEntry.Init();
                TempDimensionSetEntry."Dimension Code" := BonusContractDimensions."Dimension Code";
                TempDimensionSetEntry.Validate("Dimension Value Code", BonusContractDimensions."Dimension Value");
                if TempDimensionSetEntry.Insert() then;
            until BonusContractDimensions.Next() = 0;

        exit(DimMgt.GetDimensionSetID(TempDimensionSetEntry));
    end;


    local procedure CalcFromCrMemo()
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        with SalesCrMemoLine do begin

            SetRange("Document No.", "Sales Cr.Memo Header"."No.");
            SetRange(Type, Type::Item);
            if FindSet() then
                repeat
                    if CheckAttributes("No.") then
                        case "Bonus Contract"."Reserve Type" of
                            "Bonus Contract"."Reserve Type"::"%":
                                CalcPercentage(Database::"Sales Cr.Memo Line", "Document No.", "Line No.", Amount, "Amount Including VAT");
                            "Bonus Contract"."Reserve Type"::"Amount per Unit":
                                CalcPerUnit(Database::"Sales Cr.Memo Line", "Document No.", "Line No.");
                        end;
                until Next() = 0;
        end;
    end;

    local procedure CalcFromSalesInvoice()
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        with SalesInvoiceLine do begin
            SetRange("Document No.", "Sales Invoice Header"."No.");
            SetRange(Type, Type::Item);
            if FindSet() then
                repeat
                    if CheckAttributes("No.") then
                        case "Bonus Contract"."Reserve Type" of
                            "Bonus Contract"."Reserve Type"::"%":
                                CalcPercentage(Database::"Sales Invoice Line", "Document No.", "Line No.", Amount, "Amount Including VAT");
                            "Bonus Contract"."Reserve Type"::"Amount per Unit":
                                CalcPerUnit(Database::"Sales Invoice Line", "Document No.", "Line No.");
                        end;
                until Next() = 0;
        end;
    end;

    local procedure CalcPerUnit(TableNo: Integer; DocNo: Code[20]; DocLineNo: Integer)
    var
        Quantity: Decimal;
        BonusAmt: Decimal;
    begin
        Quantity := FindQuantity(TableNo, DocNo, DocLineNo);
        BonusAmt := Round(Quantity * "Bonus Contract"."Reserve Value", 0.01);
        if BonusAmt = 0 then
            exit;

        if BonusSetup."Reserve Mode" = BonusSetup."Reserve Mode"::CreditMemo then
            CreateForReserveMode_CreditMemo(TableNo, DocNo, DocLineNo, Quantity, BonusAmt, 0, 0, 0)
        else
            CreateJournalLine(TableNo, DocNo, DocLineNo, "Bonus Customers"."Customer", BonusAmt, 0, 0, 0);
    end;



    local procedure CalcPercentage(TableNo: Integer; DocNo: Code[20]; DocLineNo: Integer; Amount: Decimal; AmtInclVat: Decimal)
    var
        DocAmtInclVAT: Decimal;
        BonusAmt: Decimal;
        PmtDiscAmt: Decimal;
        DocAmount: Decimal;
        DiscAmt: Decimal;
    begin
        if "Sales Invoice Header"."Currency Code" = '' then begin
            DocAmount := Amount;
            DocAmtInclVAT := AmtInclVat;
        end else begin
            DocAmount := Round(Amount / "Sales Invoice Header"."Currency Factor", 0.01);
            DocAmtInclVAT := Round(AmtInclVat / "Sales Invoice Header"."Currency Factor", 0.01);
        end;
        CalcItemCharge(TableNo, DocLineNo, DocAmtInclVAT, DocAmount);

        PmtDiscAmt := DocAmount * "Bonus Contract"."Pmt. Discount %" / 100;
        DiscAmt := (DocAmount - PmtDiscAmt) * "Bonus Contract"."Discount %" / 100;
        BonusAmt := Round("Bonus Contract"."Reserve Value" * (DocAmount - DiscAmt - PmtDiscAmt) / 100, 0.01);

        // Filter ItemLedgerEntry & ValueEntry

        if BonusAmt = 0 then
            exit;

        if BonusSetup."Reserve Mode" = BonusSetup."Reserve Mode"::CreditMemo then
            CreateForReserveMode_CreditMemo(TableNo, DocNo, DocLineNo, 0, BonusAmt, PmtDiscAmt, DocAmount, DiscAmt)
        else
            CreateJournalLine(TableNo, DocNo, DocLineNo,
                            "Bonus Customers"."Customer",
                            BonusAmt, DocAmount,
                            -DiscAmt, -PmtDiscAmt);
    end;


    var
        BonusSetup: Record "lbt Bonus Setup";
        // SalesLineRec: Record "Sales Line";
        SalesShipmentLineRec: Record "Sales Shipment Line";
        SalesShipmentHeaderRec: Record "Sales Shipment Header";
        BonusMgt: Codeunit "lbt Bonus Management";
        Dia: Dialog;
        LineNo: Integer;
        DateFrom: Date;
        DateTo: Date;
        PostingDate: Date;
        CrMemoHeaderCreated: Boolean;
        BonusEntryNo: Integer;
        SalesLineNo: Integer;
        InputAccountingPeriodMsg: Label 'Please input the accounting period.', Comment = 'DEU="Geben Sie den Abrechnungszeitraum ein."';
        CheckAccountingPeriodMsg: Label 'Please check the accounting period.', Comment = 'DEU="Überprüfen Sie den Abrechnungszeitraum."';
        UnpostedCreditMemoErr: Label 'There is an unposted credit memo for bonus reserve.\\Please post or delete it at first.',
            Comment = 'DEU="Es existiert eine ungebuchte Gutschrift zur Bonusrückstellung.\\Diese muss erst gebucht oder gelöscht werden."';
        CustomerProgressTxt: Label 'Customer #1##############\', Comment = 'DEU="Debitor    #1##############\"';
        ContractProgressTxt: Label 'Contract   #2##############', Comment = 'DEU="Vertrag    #2##############"';
        BonusReserveForLbl: Label 'Bonus Reserve for ', Comment = 'DEU="Bonusrückstellung für "';
        BonusReserveLbl: Label 'Bonus Reserve', Comment = 'DEU="Bonusrückstellung"';
        InvoiceLbl: Label 'Invoice ', Comment = 'DEU="Rechnung "';
        CrMemoLbl: Label 'Credit Memo ', Comment = 'DEU="Gutschrift "';
        FixedAmountLbl: Label 'Bonus Fixed Amount', Comment = 'DEU="Bonusfestbetrag"';
        BonusAccountingLbl: Label 'Bonus Accounting accordingly Bonus Contract %1.', Comment = 'DEU="Rückstellungen gem. Vertrag %1"';
        AccountingPeriodLbl: Label 'Accounting Period %1 to %2', Comment = 'DEU="Abrechnungszeitraum %1 bis %2"';
}



