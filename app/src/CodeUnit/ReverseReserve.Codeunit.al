codeunit 5266056 "lbtbn Reverse Reserve"
{
    #region ReverseBonusEntries
    procedure ReverseBonusEntries(BonusContract: Record "lbtbn Bonus Contract"; DateFrom: Date; DateTo: Date)
    var
        BonusEntry: Record "lbtbn Bonus Entry";
        BonusSetup: Record "lbtbn Bonus Setup";
    begin
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
        ReversalEntry: Record "Reversal Entry";
        GenJnlLineRec: Record "Gen. Journal Line";
        BillingCode: Code[20];
        BillingEntry: Integer;
        LineNo: Integer;
        LBText001: Label 'Reverse', Comment = 'Auflösung';
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
                            GenJnlLineRec.Description := CopyStr(LBText001 + ' ' + GLEntry.Description, 1, 50);
                            GenJnlLineRec.Validate(Amount, -GLEntry.Amount);
                            GenJnlLineRec."lbt Process No." := GLEntry."lbt Process No.";
                            GenJnlLineRec."Reason Code" := BonusSetup."Reason Code";
                            // GenJnlLineRec."Billing Code" := BonusSetup."Billing Code";
                            GenJnlLineRec.Correction := true;
                            GenJnlLineRec."lbtbn Bonus Entry No" := GLEntry."Entry No.";
                            GenJnlLineRec."lbtbn Reserve Transaction No." := GLEntry."Transaction No.";
                            GenJnlLineRec."Dimension Set ID" := GLEntry."Dimension Set ID";
                            GenJnlLineRec.Insert();
                        //Bonusposten werden beim Buchen des Buchblattes aktualisiert
                        until GLEntry.Next() = 0;

                end;
        end;
    end;
    #endregion ReverseBonusReserve

    #region AddItemChargeInvoiceLine
    local procedure AddItemChargeInvoiceLine(BonusEntry: Record "lbtbn Bonus Entry"; Sign: Integer; SalesInvoiceLine: Record "Sales Invoice Line"; SalesCrMemoLine: Record "Sales Cr.Memo Line"; SalesShipmentLine: Record "Sales Shipment Line"; DateFrom: Date; DateTo: Date)
    var
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        ItemChargeAssRec: Record "Item Charge Assignment (Sales)";
        BonusContract: Record "lbtbn Bonus Contract";
        LineNo: Integer;
        Text021: Label 'Exploding Bonus Reserve for', Comment = 'Auflösung Bonusrückstellung für';
        Text022: Label 'Invoice ';
        Text023: Label 'Credit Memo ';
        Text024: Label 'Bonus Fixed Amount Contract ';
    begin
        BonusContract.Get(BonusEntry.Contract);
        CreateInvoiceHeader(SalesHeader, BonusContract, LineNo, DateFrom, DateTo);// TODO: Statistics 

        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        LineNo += 10000;
        SalesLine."Line No." := LineNo;
        SalesLine.Validate(Type, SalesLine.Type::"Charge (Item)");
        SalesLine.Validate("No.", BonusContract."Reserve Item Charge");
        SalesLine.Validate("Unit Price", 1);
        SalesLine.Validate(Quantity, BonusEntry."Posted Amount");
        SalesLine."Shipment Date" := WorkDate();
        SalesLine."Allow Invoice Disc." := true;
        SalesLine.Description := Text021;
        case Sign of
            1:
                SalesLine."Description 2" := Text022 + BonusEntry."From Document No.";
            -1:
                SalesLine."Description 2" := Text023 + BonusEntry."From Document No.";
            2:
                SalesLine."Description 2" := Text024 + BonusEntry."From Document No.";
        end;
        SalesLine."lbt Process No." := BonusEntry."Process No.";
        // SalesLine."Billing Code" := BonusSetup."Billing Code";
        SalesLine.Insert();

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
    local procedure CreateInvoiceHeader(SalesHeader: Record "Sales Header"; BonusContract: Record "lbtbn Bonus Contract"; var LineNo: Integer; DateFrom: Date; DateTo: Date)
    var
        Text020: Label 'Exploding Bonus reserve', Comment = 'Auflösung Bonusrückstellung';
        Text006: Label 'There is an unposted invoice for exploding bonus reservations.\\Please post or delete this at first.',
            Comment = 'Es existiert eine ungebuchte Rechnung zur Auflösung von Bonusrückstellungen.\\Diese muss erst gebucht oder gelöscht werden.';
        NoSeriesMgt: Codeunit NoSeriesManagement;
        SalesLine: Record "Sales Line";
        LBText002: Label 'Bonus Accounting accordingly Bonus Contract %1.', Comment = 'Rückstellungsauflösung gem. Vertrag %1';
        LBText003: Label 'Accounting Period %1 to %2', Comment = 'Abrechnungszeitraum %1 bis %2';
        BonusSetup: Record "lbtbn Bonus Setup";
    begin
        if InvoiceHeaderCreated then
            exit;
        BonusSetup.Get();

        SalesHeader.Reset();
        SalesHeader.SetCurrentKey("Document Type", "Sell-to Customer No.", "No.");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
        // SalesHeader.SetRange("Sell-to Customer No.", BonusSetup."Customer Statistic Postings"); // TODO: 
        SalesHeader.SetRange("lbt Process No.", BonusContract."Process No.");
        if SalesHeader.FindSet() then
            repeat
                if SalesHeader."Posting Description" = Text020 then
                    Error(Text006);
            until SalesHeader.Next() = 0;

        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
        SalesHeader."No. Series" := BonusSetup."Internal Statistic Postings";
        SalesHeader."Posting No. Series" := BonusSetup."Internal Statistic Postings";
        SalesHeader."Shipping No. Series" := BonusSetup."Internal Statistic Postings";
        SalesHeader."No." := NoSeriesMgt.GetNextNo(BonusSetup."Internal Statistic Postings", WorkDate(), true);
        SalesHeader.Insert(true);
        SalesHeader."Posting No. Series" := BonusSetup."Internal Statistic Postings";
        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.Validate("Sell-to Customer No.", BonusSetup."Customer Statistic Postings");
        SalesHeader."Customer Posting Group" := BonusSetup."Cust Gr. Reserve Cr. Memo";
        SalesHeader."Gen. Bus. Posting Group" := BonusSetup."Bus.Post.Gr.f.Res.Cr.Memo";
        SalesHeader."Posting Description" := Text020;
        SalesHeader."Posting Date" := 0D;
        SalesHeader."lbt Process No." := BonusContract."Process No.";
        SalesHeader.Modify();
        InvoiceHeaderCreated := true;
        LineNo := 0;

        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo + 10000;
        LineNo := SalesLine."Line No.";
        SalesLine.Description := StrSubstNo(LBText002, BonusContract."No.");
        SalesLine.Insert();

        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo + 10000;
        LineNo := SalesLine."Line No.";
        SalesLine.Description := StrSubstNo(LBText003, DateFrom, DateTo);
        SalesLine.Insert();
    end;
    #endregion CreateInvoiceHeader

    #region ReverseBonusEntries
    local procedure ReverseBonusEntries(var BonusEntry: Record "lbtbn Bonus Entry"; DateFrom: Date; DateTo: Date)
    begin
        if BonusEntry.FindSet() then
            repeat
                ReverseBonusEntry(DateFrom, DateTo, BonusEntry);
            until BonusEntry.Next() = 0;
    end;
    #endregion ReverseBonusEntries

    #region ReverseBonusEntry
    local procedure ReverseBonusEntry(DateFrom: Date; DateTo: Date; var BonusEntry: Record "lbtbn Bonus Entry")
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesShipmentLine: Record "Sales Shipment Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        ReturnReceiptLine: Record "Return Receipt Line";
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        BonusEntry2: Record "lbtbn Bonus Entry";
        BonusMgt: Codeunit "lbtbn Bonus Management";
        Text007: Label 'Line %1 in the posted %2 %3 does not exist anywhere.', Comment = 'Die Zeile %1 in der geb. %2 %3 existiert nicht mehr.';
        Text016: Label 'Invoice';
        Text017: Label 'Shipment';
        Sign: Integer;
        Text018: Label 'Credit Memo';
        Text019: Label 'Return Receipt';
        BillingEntry: Integer;
    begin
        case BonusEntry."Assignment Document Type" of
            BonusEntry."Assignment Document Type"::"Sales Shipment":
                begin
                    if not SalesInvoiceLine.Get(BonusEntry."From Document No.", BonusEntry."From Document Line") then
                        Error(Text007, BonusEntry."From Document No.", Text016, BonusEntry."From Document Line");
                    if not SalesShipmentLine.Get(BonusEntry."Assignment Document No.",
                           BonusEntry."Assignment Doc. Line No.")
                    then
                        Error(Text007, BonusEntry."Assignment Document No.", Text017,
                              BonusEntry."Assignment Doc. Line No.");
                    Sign := 1;
                end;
            BonusEntry."Assignment Document Type"::"Sales Return Receipt":
                begin
                    if not SalesCrMemoLine.Get(BonusEntry."From Document No.", BonusEntry."From Document Line") then
                        Error(Text007, BonusEntry."From Document No.", Text018, BonusEntry."From Document Line");
                    if not ReturnReceiptLine.Get(BonusEntry."Assignment Document No.",
                           BonusEntry."Assignment Doc. Line No.")
                    then
                        Error(Text007, BonusEntry."Assignment Document No.", Text019,
                              BonusEntry."Assignment Doc. Line No.");
                    Sign := -1;
                end;
        end;
        AddItemChargeInvoiceLine(BonusEntry, Sign, SalesInvoiceLine, SalesCrMemoLine, SalesShipmentLine, DateFrom, DateTo);
        BillingEntry := BonusMgt.BonusEntryReserveExploding(BonusEntry."Entry No.", WorkDate());
        SalesLine."lbtbn Bonus Entry No." := BillingEntry;
        if SalesHeader."Shortcut Dimension 1 Code" <> '' then
            SalesLine.Validate("Shortcut Dimension 1 Code", SalesHeader."Shortcut Dimension 1 Code");
        SalesLine.Modify();
        BonusEntry2.Get(BillingEntry);
        BonusEntry2."Bonus Document Type" := 1;
        BonusEntry2."Bonus Document No." := SalesHeader."No.";
        BonusEntry2."Bonus Document Line" := SalesLine."Line No.";
        BonusEntry2.Modify();
    end;
    #endregion ReverseBonusEntry

    #region BonusEntryReserveExploding
    procedure BonusEntryReserveExploding(EntryNo: Integer; PostingDate: Date): Integer
    var
        BonusSetup: Record "lbtbn Bonus Setup";
        BonusEntry: Record "lbtbn Bonus Entry";
        BonusEntry2: Record "lbtbn Bonus Entry";
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
        VATEntry: Record "VAT Entry";
        NewVATEntry: Record "VAT Entry";
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

    local procedure ReverseGenLedgEntry(CustomerNo: Code[20]; ProcessNo: Code[20]; DateFrom: Date; DateTo: Date; ReversePostingDate: Date)
    var
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
        GLEntry: Record "G/L Entry";
        UserSetupManagement: Codeunit "User Setup Management";
        ReverseReserve: Codeunit "lbtbn Reverse Reserve";
        Text005: Label 'The posting date of exploding bonus reserves is not in the permitted posting period.',
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
                Error(Text005);
            ReverseReserve.ReverseBonusReserve(GLEntry, ReversePostingDate);
        end;
    end;

    var
        InvoiceHeaderCreated: Boolean;
}