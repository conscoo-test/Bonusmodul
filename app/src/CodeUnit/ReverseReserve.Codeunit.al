codeunit 5266056 "lbtbn Reverse Reserve"
{
    #region ReverseBonusEntry
    procedure ReverseBonusEntry(BonusContract: Record "lbtbn Bonus Contract"; DateFrom: Date; DateTo: Date)
    var
        BonusEntry: Record "lbtbn Bonus Entry";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesShipmentLine: Record "Sales Shipment Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        ReturnReceiptLine: Record "Return Receipt Line";
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        BonusEntry2: Record "lbtbn Bonus Entry";
        BonusSetup: Record "lbtbn Bonus Setup";
        BonusMgt: Codeunit "lbtbn Bonus Management";
        Text007: Label 'Line %1 in the posted %2 %3 does not exist anywhere.', Comment = 'Die Zeile %1 in der geb. %2 %3 existiert nicht mehr.';
        Text016: Label 'Invoice';
        Text017: Label 'Shipment';
        Sign: Integer;
        Text018: Label 'Credit Memo';
        Text019: Label 'Return Receipt';
        BillingEntry: Integer;
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
        if BonusEntry.FindSet() then
            repeat
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
                AddItemChargeInvoiceLine(BonusEntry, BonusContract, Sign, SalesInvoiceLine, SalesCrMemoLine, SalesShipmentLine, DateFrom, DateTo);
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
            until BonusEntry.Next() = 0;
    end;
    #endregion ReverseBonusEntry

    #region AddItemChargeInvoiceLine
    local procedure AddItemChargeInvoiceLine(BonusEntry: Record "lbtbn Bonus Entry"; BonusContract: Record "lbtbn Bonus Contract"; Sign: Integer; SalesInvoiceLine: Record "Sales Invoice Line"; SalesCrMemoLine: Record "Sales Cr.Memo Line"; SalesShipmentLine: Record "Sales Shipment Line"; DateFrom: Date; DateTo: Date)
    var
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        ItemChargeAssRec: Record "Item Charge Assignment (Sales)";
        LineNo: Integer;
        Text021: Label 'Exploding Bonus Reserve for', Comment = 'Auflösung Bonusrückstellung für';
        Text022: Label 'Invoice ';
        Text023: Label 'Credit Memo ';
        Text024: Label 'Bonus Fixed Amount Contract ';
    begin
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
    var
        InvoiceHeaderCreated: Boolean;
}