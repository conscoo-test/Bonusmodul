codeunit 5266056 "lbtbn Reverse Reserve"
{
    #region ReverseBonusEntries
    procedure ReverseBonusEntries(BonusContract: Record "lbtbn Bonus Contract"; DateFrom: Date; DateTo: Date)
    var
        BonusEntry: Record "lbtbn Bonus Entry";
        BonusSetup: Record "lbtbn Bonus Setup";
    begin
        BonusSetup.Get();
        if BonusSetup."Reserve Mode" <> BonusSetup."Reserve Mode"::CreditMemo then
            exit;

        BonusEntry.Reset();
        BonusEntry.SetCurrentKey("Process No.", "Entry Type", "Entry Date", Reversed);
        BonusEntry.SetRange("Entry Type", BonusEntry."Entry Type"::Reserve);
        BonusEntry.SetRange("Process No.", BonusContract."Process No.");
        BonusEntry.SetRange(Reversed, false);
        BonusEntry.SetFilter("Posted Amount", '<>0');
        BonusEntry.SetRange("Entry Date", DateFrom, DateTo);
        ReverseBonusEntries(BonusEntry, DateFrom, DateTo);
    end;
    #endregion ReverseBonusEntries

    #region ReverseBonusReserve
    procedure ReverseBonusReserve(var GLEntry: Record "G/L Entry"; PostingDate: Date)
    var
        BonusSetup: Record "lbtbn Bonus Setup";
        GenJnlLineRec: Record "Gen. Journal Line";
        ReversalEntry: Record "Reversal Entry";
        BillingCode: Code[20];
        BillingEntry: Integer;
        LineNo: Integer;
        ReverseTxt: Label 'Reverse', Comment = 'Auflösung';
    begin
        BonusSetup.Get();
        // BonusSetup.TestField("Billing Code");

        case BonusSetup."Reverse Reserve Mode" of
            BonusSetup."Reverse Reserve Mode"::automatic:
                if GLEntry.FindSet() then
                    repeat
                        GLEntry.TestField("Transaction No.");
                        GLEntry.TestField(Reversed, false);
                        // BillingCode := BonusSetup."Billing Code";
                        BillingCode := '';
                        BillingEntry := BonusEntryReserveExploding(GLEntry."Entry No.", PostingDate);
                        Clear(ReversalEntry);
                        ReversalEntry.ReverseTransaction(GLEntry."Transaction No.");
                    until GLEntry.Next() = 0;
            // GlobVarCU.Reset(9);
            BonusSetup."Reverse Reserve Mode"::"Journal Batch":
                begin
                    BonusSetup.TestField("Gen.Jnl.Templ.BonusReserve");
                    BonusSetup.TestField("Gen. Jnl. Bonus Reserve");

                    GenJnlLineRec.Reset();
                    GenJnlLineRec.SetRange("Journal Template Name", BonusSetup."Gen.Jnl.Templ.BonusReserve");
                    GenJnlLineRec.SetRange("Journal Batch Name", BonusSetup."Gen. Jnl. Bonus Reserve");
                    if GenJnlLineRec.FindLast() then
                        LineNo := GenJnlLineRec."Line No."
                    else
                        LineNo := 0;

                    if GLEntry.FindSet() then
                        repeat
                            GLEntry.TestField("Transaction No.");
                            GLEntry.TestField(Reversed, false);

                            GenJnlLineRec.Init();
                            GenJnlLineRec."Journal Template Name" := BonusSetup."Gen.Jnl.Templ.BonusReserve";
                            GenJnlLineRec."Journal Batch Name" := BonusSetup.GenJnlBonusReversReserve;
                            GenJnlLineRec."Line No." := LineNo + 10000;
                            LineNo := GenJnlLineRec."Line No.";
                            GenJnlLineRec.Validate("Posting Date", PostingDate);
                            GenJnlLineRec."Document No." := GLEntry."Document No.";
                            GenJnlLineRec."Account Type" := GenJnlLineRec."Account Type"::"G/L Account";
                            GenJnlLineRec."Bal. Account Type" := GenJnlLineRec."Bal. Account Type"::"G/L Account";
                            GenJnlLineRec.Validate("Account No.", GLEntry."G/L Account No.");
                            GenJnlLineRec.Validate("Bal. Account No.", GLEntry."Bal. Account No.");
                            GenJnlLineRec."Gen. Bus. Posting Group" := '';
                            GenJnlLineRec."Gen. Prod. Posting Group" := '';
                            GenJnlLineRec.Description := CopyStr(ReverseTxt + ' ' + GLEntry.Description, 1, 50);
                            GenJnlLineRec.Validate(Amount, -GLEntry.Amount);
                            GenJnlLineRec."lbt Process No." := GLEntry."lbt Process No.";
                            GenJnlLineRec."Reason Code" := BonusSetup."Reason Code";
                            // GenJnlLineRec."Billing Code" := BonusSetup."Billing Code";
                            GenJnlLineRec.Correction := true;
                            GenJnlLineRec."lbtbn Reserve Entry No" := GLEntry."Entry No.";
                            GenJnlLineRec."lbtbn Reserve Transaction No." := GLEntry."Transaction No.";
                            GenJnlLineRec."Dimension Set ID" := GLEntry."Dimension Set ID";
                            GenJnlLineRec.Insert();
                        //Bonusposten werden beim Buchen des Buchblattes aktualisiert
                        until GLEntry.Next() = 0;
                    OpenPage();

                end;
        end;
    end;
    #endregion ReverseBonusReserve

    #region AddItemChargeInvoiceLine
    local procedure AddItemChargeInvoiceLine(BonusEntry: Record "lbtbn Bonus Entry"; Sign: Integer; SalesInvoiceLine: Record "Sales Invoice Line"; SalesCrMemoLine: Record "Sales Cr.Memo Line"; SalesShipmentLine: Record "Sales Shipment Line"; DateFrom: Date; DateTo: Date) SalesLine: Record "Sales Line"
    var
        BonusContract: Record "lbtbn Bonus Contract";

    begin
        BonusContract.Get(BonusEntry.Contract);
        CreateInvoiceHeader(BonusContract, DateFrom, DateTo);

        SalesLine := CreateSalesLine(BonusEntry, Sign, BonusContract);

        AssignItemCharge(BonusEntry, Sign, SalesInvoiceLine, SalesCrMemoLine, SalesShipmentLine, SalesLine);

        case Sign of
            -1:
                begin
                    SalesLine."Shortcut Dimension 1 Code" := SalesCrMemoLine."Shortcut Dimension 1 Code";
                    SalesLine."Shortcut Dimension 2 Code" := SalesCrMemoLine."Shortcut Dimension 2 Code";
                    SalesLine."Dimension Set ID" := SalesCrMemoLine."Dimension Set ID";
                end;
            1:
                begin
                    SalesLine."Shortcut Dimension 1 Code" := SalesInvoiceLine."Shortcut Dimension 1 Code";
                    SalesLine."Shortcut Dimension 2 Code" := SalesInvoiceLine."Shortcut Dimension 2 Code";
                    SalesLine."Dimension Set ID" := SalesInvoiceLine."Dimension Set ID";
                end;
            2:
                begin
                    SalesLine."Shortcut Dimension 1 Code" := SalesShipmentLine."Shortcut Dimension 1 Code";
                    SalesLine."Shortcut Dimension 2 Code" := SalesShipmentLine."Shortcut Dimension 2 Code";
                    SalesLine."Dimension Set ID" := SalesShipmentLine."Dimension Set ID";
                end;
        end;
        if SalesHeader."Shortcut Dimension 1 Code" <> '' then
            SalesLine.Validate("Shortcut Dimension 1 Code", SalesHeader."Shortcut Dimension 1 Code");
        SalesLine.Modify();
    end;
    #endregion AddItemChargeInvoiceLine

    #region CreateInvoiceHeader
    local procedure CreateInvoiceHeader(BonusContract: Record "lbtbn Bonus Contract"; DateFrom: Date; DateTo: Date)
    var
        BonusSetup: Record "lbtbn Bonus Setup";
        SalesLine: Record "Sales Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        ReverseReservalTxt: Label 'Reverse Reserve according to Bonus Contract %1.', Comment = '%1 - Contract No.';
        AccountingPeriodLTxt: Label 'Accounting Period %1 to %2', Comment = '%1 - from Date, %2 - to Date';
        UnpostedInvoiceExistsErr: Label 'There is an unposted invoice for exploding bonus reservations.\\Please post or delete this at first.';
        PostingDescriptionTxt: Label 'Exploding Bonus reserve';
        LineNo: Integer;
    begin
        if InvoiceHeaderCreated then
            exit;
        BonusSetup.Get();

        SalesHeader.Reset();
        SalesHeader.SetCurrentKey("Document Type", "Sell-to Customer No.", "No.");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
        SalesHeader.SetRange("Sell-to Customer No.", BonusContract."Customer Reserve Cr.Memo");
        SalesHeader.SetRange("lbt Process No.", BonusContract."Process No.");
        if SalesHeader.FindSet() then
            repeat
                if SalesHeader."Posting Description" = PostingDescriptionTxt then
                    Error(UnpostedInvoiceExistsErr);
            until SalesHeader.Next() = 0;

        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
        SalesHeader."No. Series" := BonusSetup."Reserve Cr.Memo Nos.";
        SalesHeader."Posting No. Series" := BonusSetup."Reserve Cr.Memo Nos.";
        SalesHeader."Shipping No. Series" := BonusSetup."Reserve Cr.Memo Nos.";
        SalesHeader."No." := NoSeriesMgt.GetNextNo(BonusSetup."Reserve Cr.Memo Nos.", WorkDate(), true);
        SalesHeader.Insert(true);
        SalesHeader."Posting No. Series" := BonusSetup."Reserve Cr.Memo Nos.";
        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.Validate("Sell-to Customer No.", BonusContract."Customer Reserve Cr.Memo");
        SalesHeader."Customer Posting Group" := BonusSetup."Cust Gr. Reserve Cr. Memo";
        SalesHeader."Gen. Bus. Posting Group" := BonusSetup."Bus.Post.Gr.f.Res.Cr.Memo";
        SalesHeader."Posting Description" := PostingDescriptionTxt;
        SalesHeader."Posting Date" := DateTo;
        SalesHeader."Posting No." := SalesHeader."No.";
        SalesHeader."lbt Process No." := BonusContract."Process No.";
        SalesHeader.Modify();
        InvoiceHeaderCreated := true;
        LineNo := 0;

        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        LineNo += 10000;
        SalesLine."Line No." := LineNo;
        SalesLine.Description := StrSubstNo(ReverseReservalTxt, BonusContract."No.");
        SalesLine.Insert();

        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        LineNo += 10000;
        SalesLine."Line No." := LineNo;
        SalesLine.Description := StrSubstNo(AccountingPeriodLTxt, DateFrom, DateTo);
        SalesLine.Insert();
    end;
    #endregion CreateInvoiceHeader

    #region ReverseBonusEntries
    procedure ReverseBonusEntries(var BonusEntry: Record "lbtbn Bonus Entry"; DateFrom: Date; DateTo: Date)
    var
        PageManagement: Codeunit "Page Management";
    begin
        if BonusEntry.FindSet() then
            repeat
                ReverseBonusEntry(DateFrom, DateTo, BonusEntry);
            until BonusEntry.Next() = 0;

        if InvoiceHeaderCreated then
            PageManagement.PageRun(SalesHeader);
    end;
    #endregion ReverseBonusEntries

    #region ReverseBonusEntry
    local procedure ReverseBonusEntry(DateFrom: Date; DateTo: Date; var BonusEntry: Record "lbtbn Bonus Entry")
    var
        BonusEntry2: Record "lbtbn Bonus Entry";
        ReturnReceiptLine: Record "Return Receipt Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesLine: Record "Sales Line";
        SalesShipmentLine: Record "Sales Shipment Line";
        DimSetID: Integer;
        BillingEntry: Integer;
        Sign: Integer;
    begin
        case BonusEntry."From Document Type" of
            BonusEntry."From Document Type"::"Sales Invoice":
                begin
                    if not SalesInvoiceLine.Get(BonusEntry."From Document No.", BonusEntry."From Document Line") then
                        Error(LineMissingErr, BonusEntry."From Document No.", InvoiceLbl, BonusEntry."From Document Line");
                    if not SalesShipmentLine.Get(BonusEntry."Assignment Document No.",
                           BonusEntry."Assignment Doc. Line No.")
                    then
                        Error(LineMissingErr, BonusEntry."Assignment Document No.", ShipmentLbl,
                              BonusEntry."Assignment Doc. Line No.");
                    DimSetID := SalesInvoiceLine."Dimension Set ID";
                    Sign := 1;
                end;
            BonusEntry."From Document Type"::"Sales Credit Memo":
                begin
                    if not SalesCrMemoLine.Get(BonusEntry."From Document No.", BonusEntry."From Document Line") then
                        Error(LineMissingErr, BonusEntry."From Document No.", CreditMemoLbl, BonusEntry."From Document Line");
                    if not ReturnReceiptLine.Get(BonusEntry."Assignment Document No.",
                           BonusEntry."Assignment Doc. Line No.")
                    then
                        Error(LineMissingErr, BonusEntry."Assignment Document No.", ReturnReceiptLbl,
                              BonusEntry."Assignment Doc. Line No.");
                    DimSetID := SalesCrMemoLine."Dimension Set ID";
                    Sign := -1;
                end;
            BonusEntry."From Document Type"::" ":
                begin
                    if not SalesShipmentLine.Get(BonusEntry."Assignment Document No.", BonusEntry."Assignment Doc. Line No.") then
                        Error(LineMissingErr, BonusEntry."Assignment Document No.", ShipmentLbl, BonusEntry."Assignment Doc. Line No.");
                    DimSetID := SalesShipmentLine."Dimension Set ID";
                    Sign := 2;
                end;
        end;
        SalesLine := AddItemChargeInvoiceLine(BonusEntry, Sign, SalesInvoiceLine, SalesCrMemoLine, SalesShipmentLine, DateFrom, DateTo);
        BillingEntry := BonusEntryReserveExploding(BonusEntry."Entry No.", WorkDate());
        SalesLine."lbtbn Bonus Entry No." := BillingEntry;
        SalesLine."Dimension Set ID" := DimSetID;
        SalesLine.Modify();
        BonusEntry2.Get(BillingEntry);
        BonusEntry2."Bonus Document Type" := 1;
        BonusEntry2."Bonus Document No." := SalesLine."Document No.";
        BonusEntry2."Bonus Document Line" := SalesLine."Line No.";
        BonusEntry2.Modify();
    end;
    #endregion ReverseBonusEntry

    #region BonusEntryReserveExploding
    procedure BonusEntryReserveExploding(EntryNo: Integer; PostingDate: Date): Integer
    var
        BonusEntry2: Record "lbtbn Bonus Entry";
        BonusEntry: Record "lbtbn Bonus Entry";
        BonusSetup: Record "lbtbn Bonus Setup";
    begin
        BonusEntry.Reset();
        BonusSetup.Get();
        case BonusSetup."Reserve Mode" of
            BonusSetup."Reserve Mode"::CreditMemo:
                begin
                    BonusEntry.SetCurrentKey("Entry No.");
                    BonusEntry.SetRange("Entry No.", EntryNo);
                end;
            BonusSetup."Reserve Mode"::Journal:
                begin
                    BonusEntry.SetCurrentKey("General Ledger Entry No.");
                    BonusEntry.SetRange("General Ledger Entry No.", EntryNo);
                end;
        end;
        if BonusEntry.FindFirst() then begin
            BonusEntry.TestField(Reversed, false);
            if BonusEntry2.FindLast() then
                EntryNo := BonusEntry2."Entry No."
            else
                EntryNo := 0;

            BonusEntry2.Init();
            BonusEntry2 := BonusEntry;
            BonusEntry2."Entry Type" := BonusEntry2."Entry Type"::"Liquidation of Reserves";
            BonusEntry2."Entry No." := EntryNo + 1;
            BonusEntry2."General Ledger Entry No." := 0;
            BonusEntry2."Entry Date" := PostingDate;
            BonusEntry2."Calculated Amount" := -BonusEntry."Calculated Amount";
            BonusEntry2."calc. Amount incl. VAT" := -BonusEntry."calc. Amount incl. VAT";
            BonusEntry2."Posted Amount" := 0;
            if BonusSetup."Reserve Mode" = BonusSetup."Reserve Mode"::Journal then
                BonusEntry2."Posted Amount" := -BonusEntry."Posted Amount";
            BonusEntry2."Base Amount" := -BonusEntry."Base Amount";
            BonusEntry2."Pmt. Discount Amount" := -BonusEntry."Pmt. Discount Amount";
            BonusEntry2."Discount Amount" := -BonusEntry."Discount Amount";
            BonusEntry2.Insert();
            BonusEntry.Reversed := true;
            BonusEntry."Reversed by Entry No." := BonusEntry2."Entry No.";
            BonusEntry.Modify();
            exit(BonusEntry2."Entry No.");
        end;
    end;
    #endregion BonusEntryReserveExploding

    #region BonusReverseReserve
    procedure BonusReverseReserve(var GlobalGLEntry: Record "G/L Entry"; var GenJournalLine: Record "Gen. Journal Line")
    var
        GLEntry: Record "G/L Entry";
        NewGLEntry: Record "G/L Entry";
        NewVATEntry: Record "VAT Entry";
        VATEntry: Record "VAT Entry";
    begin
        GLEntry.Reset();
        NewGLEntry.Reset();
        GLEntry.SetCurrentKey("Transaction No.");
        NewGLEntry.SetCurrentKey("Transaction No.");
        GLEntry.SetRange("Transaction No.", GenJournalLine."lbtbn Reserve Transaction No.");
        if GLEntry.FindSet(true) then
            repeat
                NewGLEntry.SetRange("Transaction No.", GlobalGLEntry."Transaction No.");
                NewGLEntry.SetRange("G/L Account No.", GLEntry."G/L Account No.");
                NewGLEntry.SetRange("Document No.", GLEntry."Document No.");
                NewGLEntry.SetRange(Amount, -GLEntry.Amount);
                if NewGLEntry.FindFirst() then begin
                    GLEntry.Reversed := true;
                    GLEntry."Reversed by Entry No." := NewGLEntry."Entry No.";
                    GLEntry.Modify();
                    NewGLEntry.Reversed := true;
                    NewGLEntry."Reversed Entry No." := GLEntry."Entry No.";
                    NewGLEntry.Modify();
                end;
            until GLEntry.Next() = 0;

        VATEntry.Reset();
        NewVATEntry.Reset();
        VATEntry.SetCurrentKey("Transaction No.");
        NewVATEntry.SetCurrentKey("Transaction No.");
        VATEntry.SetRange("Transaction No.", GenJournalLine."lbtbn Reserve Transaction No.");
        if VATEntry.FindSet(true) then
            repeat
                NewVATEntry.SetRange("Transaction No.", GlobalGLEntry."Transaction No.");
                NewVATEntry.SetRange("Gen. Bus. Posting Group", VATEntry."Gen. Bus. Posting Group");
                NewVATEntry.SetRange("Gen. Prod. Posting Group", VATEntry."Gen. Prod. Posting Group");
                NewVATEntry.SetRange("Document No.", VATEntry."Document No.");
                NewVATEntry.SetRange(Amount, -VATEntry.Amount);
                if NewVATEntry.FindFirst() then begin
                    VATEntry.Reversed := true;
                    VATEntry."Reversed by Entry No." := NewVATEntry."Entry No.";
                    VATEntry.Modify();
                    NewVATEntry.Reversed := true;
                    NewVATEntry."Reversed Entry No." := VATEntry."Entry No.";
                    NewVATEntry.Modify();
                end;
            until VATEntry.Next() = 0;
    end;
    #endregion BonusReverseReserve

    #region ReverseGenLedgEntry
    procedure ReverseGenLedgEntry(BonusContract: Record "lbtbn Bonus Contract"; DateFrom: Date; DateTo: Date; ReversePostingDate: Date)
    var
        BonusCustomer: Record "lbtbn Bonus Customer";
        BonusSetup: Record "lbtbn Bonus Setup";
    begin
        BonusSetup.Get();
        if BonusSetup."Reserve Mode" <> BonusSetup."Reserve Mode"::Journal then
            exit;
        BonusCustomer.SetRange(Contract, BonusContract."No.");
        if BonusCustomer.FindSet() then
            repeat
                ReverseGenLedgEntry(BonusCustomer."Customer No.", BonusContract."Process No.", DateFrom, DateTo, ReversePostingDate);
            until BonusCustomer.Next() = 0;
    end;
    #endregion ReverseGenLedgEntry

    #region ReverseGenLedgEntry
    local procedure ReverseGenLedgEntry(CustomerNo: Code[20]; ProcessNo: Code[20]; DateFrom: Date; DateTo: Date; ReversePostingDate: Date)
    var
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
        GLEntry: Record "G/L Entry";
        ReverseReserve: Codeunit "lbtbn Reverse Reserve";
        UserSetupManagement: Codeunit "User Setup Management";
        PostingDateErr: Label 'The posting date of exploding bonus reserves is not in the permitted posting period.',
            Comment = 'Das Buchungsdatum der Rückstellungsauflösung (%1) liegt nicht im zugelassenen Buchungszeitraum.';
    begin
        if not Customer.Get(CustomerNo) then
            exit;

        CustomerPostingGroup.SetRange(Code, Customer."Customer Posting Group");
        if CustomerPostingGroup.FindFirst() then begin
            GLEntry.Reset();
            GLEntry.SetCurrentKey(GLEntry."G/L Account No.", "lbt Process No.", "Posting Date");
            GLEntry.SetRange("G/L Account No.", CustomerPostingGroup."lbtbn Reserve Account");
            GLEntry.SetRange("lbt Process No.", ProcessNo);
            GLEntry.SetRange("Posting Date", DateFrom, DateTo);
            GLEntry.SetRange(Reversed, false);
            if GLEntry.IsEmpty() then
                exit;
            if not UserSetupManagement.IsPostingDateValid(ReversePostingDate) then
                Error(PostingDateErr);
            ReverseReserve.ReverseBonusReserve(GLEntry, ReversePostingDate);
        end;
    end;
    #endregion ReverseGenLedgEntry

    #region CreateSalesLine
    local procedure CreateSalesLine(BonusEntry: Record "lbtbn Bonus Entry"; Sign: Integer; BonusContract: Record "lbtbn Bonus Contract") SalesLine: Record "Sales Line";
    var
        ReverseTxt: Label 'Reverse Bonus Reserve for', Comment = 'Auflösung Bonusrückstellung für';
        InvoiceTxt: Label 'Invoice ';
        CreditMemoTxt: Label 'Credit Memo ';
        FixedAmountTxt: Label 'Bonus Fixed Amount Contract ';
        LineNo: Integer;
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindLast() then
            LineNo := SalesLine."Line No.";
        LineNo += 10000;

        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Validate(Type, SalesLine.Type::"Charge (Item)");
        SalesLine.Validate("No.", BonusContract."Reserve Item Charge");
        SalesLine.Validate("Unit Price", 1);
        SalesLine.Validate(Quantity, BonusEntry."Posted Amount");
        SalesLine."Shipment Date" := WorkDate();
        SalesLine."Allow Invoice Disc." := true;
        SalesLine.Description := ReverseTxt;
        case Sign of
            1:
                SalesLine."Description 2" := InvoiceTxt + BonusEntry."From Document No.";
            -1:
                SalesLine."Description 2" := CreditMemoTxt + BonusEntry."From Document No.";
            2:
                SalesLine."Description 2" := FixedAmountTxt + BonusEntry."From Document No.";
        end;
        SalesLine."lbt Process No." := BonusEntry."Process No.";
        // SalesLine."Billing Code" := BonusSetup."Billing Code";
        SalesLine.Insert();
    end;
    #endregion CreateSalesLine

    #region AssignItemCharge
    local procedure AssignItemCharge(BonusEntry: Record "lbtbn Bonus Entry"; Sign: Integer; var SalesInvoiceLine: Record "Sales Invoice Line"; var SalesCrMemoLine: Record "Sales Cr.Memo Line"; var SalesShipmentLine: Record "Sales Shipment Line"; var SalesLine: Record "Sales Line")
    var
        ItemChargeAssRec: Record "Item Charge Assignment (Sales)";
    begin
        ItemChargeAssRec.Init();
        ItemChargeAssRec."Document Type" := SalesLine."Document Type";
        ItemChargeAssRec."Document No." := SalesLine."Document No.";
        ItemChargeAssRec."Document Line No." := SalesLine."Line No.";
        ItemChargeAssRec."Line No." := 10000;
        ItemChargeAssRec."Item Charge No." := SalesLine."No.";
        case Sign of
            -1:
                begin
                    ItemChargeAssRec."Item No." := SalesCrMemoLine."No.";
                    ItemChargeAssRec.Description := SalesCrMemoLine.Description;
                    ItemChargeAssRec."Applies-to Doc. Type" := ItemChargeAssRec."Applies-to Doc. Type"::"Return Receipt";
                end;
            1:
                begin
                    ItemChargeAssRec."Item No." := SalesInvoiceLine."No.";
                    ItemChargeAssRec.Description := SalesInvoiceLine.Description;
                    ItemChargeAssRec."Applies-to Doc. Type" := ItemChargeAssRec."Applies-to Doc. Type"::Shipment;
                end;
            2:
                begin
                    ItemChargeAssRec."Item No." := SalesShipmentLine."No.";
                    ItemChargeAssRec.Description := SalesShipmentLine.Description;
                    ItemChargeAssRec."Applies-to Doc. Type" := ItemChargeAssRec."Applies-to Doc. Type"::Shipment;
                end;
        end;
        ItemChargeAssRec."Applies-to Doc. Line Amount" := BonusEntry."Base Amount";
        ItemChargeAssRec."Applies-to Doc. No." := BonusEntry."Assignment Document No.";
        ItemChargeAssRec."Applies-to Doc. Line No." := BonusEntry."Assignment Doc. Line No.";
        ItemChargeAssRec."Unit Cost" := 1;
        ItemChargeAssRec.Validate("Qty. to Assign", BonusEntry."Posted Amount");
        ItemChargeAssRec.Insert();
    end;
    #endregion AssignItemCharge

    #region OpenPage
    local procedure OpenPage()
    var
        BonusSetup: Record "lbtbn Bonus Setup";
        GenJournalLine: Record "Gen. Journal Line";
        PageManagement: Codeunit "Page Management";
    begin
        BonusSetup.Get();
        GenJournalLine.SetRange("Journal Template Name", BonusSetup."Gen.Jnl.Templ.BonusReserve");
        GenJournalLine.SetRange("Journal Batch Name", BonusSetup.GenJnlBonusReversReserve);
        if GenJournalLine.FindFirst() then
            PageManagement.PageRun(GenJournalLine);
    end;
    #endregion OpenPage

    var
        SalesHeader: Record "Sales Header";
        LineMissingErr: Label 'Line %1 in the posted %2 %3 does not exist anywhere.', Comment = 'Die Zeile %1 in der geb. %2 %3 existiert nicht mehr.';
        InvoiceLbl: Label 'Invoice';
        ShipmentLbl: Label 'Shipment';
        CreditMemoLbl: Label 'Credit Memo';
        ReturnReceiptLbl: Label 'Return Receipt';
        InvoiceHeaderCreated: Boolean;
}