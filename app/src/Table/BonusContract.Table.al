table 5266052 "lbt Bonus Contract"
{
    DataClassification = ToBeClassified;
    Caption = 'Bonus Contract', comment = 'DEU="Bonusvertrag"';
    LookupPageId = "lbt Bonus Contract List";
    DrillDownPageId = "lbt Bonus Contract List";

    fields
    {
        field(1; Contract; Code[20])
        {
            Caption = 'Contract', comment = 'DEU="Vertrag"';
            DataClassification = CustomerContent;
            NotBlank = true;
        }

        field(2; "Valid from"; Date)
        {
            Caption = 'Valid from', comment = 'DEU="Gültig von"';
            DataClassification = CustomerContent;
        }

        field(3; "Valid to"; Date)
        {
            Caption = 'Valid to', comment = 'DEU="Gültig bis"';
            DataClassification = CustomerContent;
        }
        field(4; "Billing Period"; DateFormula)
        {
            Caption = 'Billing Period', comment = 'DEU="Abrechnungsintervall"';
            DataClassification = CustomerContent;
        }
        field(5; "Reserve Value"; Decimal)
        {
            Caption = 'Reserve Value', comment = 'DEU="Rückstellungswert"';
            DataClassification = CustomerContent;
        }
        field(6; "Reserve Type"; Option)
        {
            Caption = 'Reverse Type', comment = 'DEU="Rückstellungsart"';
            OptionMembers = "%","Amount (LCY)","Amount per Unit";
            OptionCaption = '%,Amount (LCY),Amount per Unit', comment = 'DEU="%,Festbetrag (MW),Betrag je Einheit"';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                IF "Reserve Type" <> "Reserve Type"::"%" THEN BEGIN
                    "Pmt. Discount %" := 0;
                    "Discount %" := 0;
                END;
            end;
        }
        field(7; "Reserve Unit"; Code[10])
        {
            Caption = 'Reserve Unit', comment = 'DEU="Rückstellungseinheit"';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure".Code;
        }

        field(8; "Last Reserve at"; Date)
        {
            Caption = 'Last Reserve at', comment = 'DEU="letzte Rückstellung am"';
            DataClassification = CustomerContent;
        }

        field(9; "Bonus Billing Type"; Option)
        {
            Caption = 'Bonus Billing Type', comment = 'DEU="Bonusabrechnungsart"';
            DataClassification = CustomerContent;
            OptionMembers = "%","Amount (LCY)","Amount per Unit";
            OptionCaption = '%,Amount (LCY),Amount per Unit', comment = 'DEU="%,Festbetrag (MW),Betrag je Einheit"';

            trigger OnValidate()
            begin
                IF "Bonus Billing Type" <> "Bonus Billing Type"::"%" THEN BEGIN
                    "Pmt. Discount %" := 0;
                    "Discount %" := 0;
                END;
            end;
        }

        field(10; "Bonus Billing Unit"; Code[10])
        {
            Caption = 'Bonus Billing Unit', comment = 'DEU="Bonusabrechnungseinheit"';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure".Code;
        }
        field(11; "Last Billing at"; Date)
        {
            Caption = 'Last Billing at', comment = 'DEU="letzte Abrechnung am"';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                IF ("Last Billing at" < xRec."Last Billing at") OR ("Last Billing at" = 0D) THEN
                    SalesHeaderRec.RESET();
                SalesHeaderRec.SETCURRENTKEY("Document Type", "Sell-to Customer No.", "Salesperson Code",
                                             "Shortcut Dimension 1 Code", "Document Date");
                SalesHeaderRec.SETRANGE("Document Type", SalesHeaderRec."Document Type"::"Credit Memo");
                SalesHeaderRec.SETRANGE("Sell-to Customer No.", "Bonus Recipient");
                SalesHeaderRec.SETRANGE("Posting Description", 'Bonusgutschrift');
                ///LBIS02
                IF NOT SalesHeaderRec.ISEMPTY() THEN
                    ERROR(Text001Msg);


            end;
        }

        field(12; "Bonus Scale Type"; Option)
        {
            Caption = 'Bonus Scale Type', comment = 'DEU="Bonusstaffelart"';
            DataClassification = CustomerContent;
            OptionMembers = "Sales Qty.","Sales (LCY)";
            OptionCaption = 'Sales Qty.,Sales (LCY)', comment = 'DEU="Absatz,Umsatz"';

            trigger OnValidate()
            begin
                IF "Bonus Scale Type" <> xRec."Bonus Scale Type" THEN
                    BonusContractEntryRec.SETRANGE("Contract", "Contract");
                IF NOT BonusContractEntryRec.ISEMPTY() THEN
                    ERROR(Text005Msg);
                BonusContractLineRec.SETRANGE("Contract", "Contract");

                IF NOT BonusContractLineRec.ISEMPTY() THEN
                    ERROR(Text004Msg);

                IF "Bonus Scale Type" = "Bonus Scale Type"::"Sales (LCY)" THEN
                    IF "Bonus Billing Type" <> "Bonus Billing Type"::"%" THEN
                        FIELDERROR("Bonus Billing Type");

            end;

        }

        field(13; "Bonus Recipient"; Code[20])
        {
            Caption = 'Bonus Recipient', comment = 'DEU="Bonusempfänger"';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
        field(14; "Bonus Group"; Code[20])
        {
            Caption = 'Bonus Group', comment = 'DEU="Bonusgruppe"';
            DataClassification = CustomerContent;
            TableRelation = "lbt Bonus Group"."Code";
        }

        field(15; "Contract Type"; Option)
        {
            Caption = 'Contract Type', comment = 'DEU="Vertragsart"';
            DataClassification = CustomerContent;
            OptionMembers = "Bonus","Advertising Costs";
            OptionCaption = 'Bonus,Advertising Costs', comment = 'DEU="Bonus,Werbekosten"';
        }

        field(16; "No. of Customers"; Integer)
        {
            Caption = 'No. of Customers', comment = 'DEU="Anzahl Debitoren"';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count ("lbt Bonus Customers" where("Contract" = field("Contract")));

        }
        field(17; "Balance of Bonus"; Decimal)
        {
            Caption = 'Balance of Bonus', comment = 'DEU="Saldo Bonus"';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum ("lbt Bonus Entry"."Posted Amount" where("Contract" = field("Contract"), "Entry Type" = const("Bonus")));

        }
        field(18; "Balance of Reserve"; Decimal)
        {
            Caption = 'Balance of Reserve', comment = 'DEU="Saldo Rückstellungen"';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum ("lbt Bonus Entry"."Posted Amount" where("Contract" = field("Contract"), "Entry Type" = const("Reserve")));
        }


        field(19; "Balance of Liquid Reserves"; Decimal)
        {
            Caption = 'Balance of Liquidation Reserve', comment = 'DEU="Saldo Rückstellungsauflösung"';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum ("lbt Bonus Entry"."Posted Amount" where("Contract" = field("Contract"), "Entry Type" = const("Liquidation of Reserves")));
        }
        field(20; "No. of Dimensions"; Integer)
        {
            Caption = 'No. of Dimensions', comment = 'DEU="Anzahl der Dimensionen"';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count ("lbt Bonus Contract Dimensions" where("Contract" = field("Contract")));
        }
        field(21; "No. of Attribute"; Integer)
        {
            Caption = 'No. of Attribute', comment = 'DEU="Anzahl der Attribute"';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count ("lbt BonusContractAttribute" where("Contract" = field("Contract")));
        }

        field(22; "Reserve Item Charge"; Code[20])
        {
            Caption = 'Reserve Item Charge', comment = 'DEU="Rückstellungszuschlag"';
            DataClassification = CustomerContent;
            TableRelation = "Item Charge"."No.";
        }

        field(23; "Accounting Item Charge"; Code[20])
        {
            Caption = 'Accounting Item Charge', comment = 'DEU="Abrechnungszuschlag"';
            DataClassification = CustomerContent;
            TableRelation = "Item Charge"."No.";
        }

        field(24; "Pmt. Discount %"; Decimal)
        {
            Caption = 'Payment Discount %', comment = 'DEU="Skonto %"';
            DataClassification = CustomerContent;
        }

        field(25; "Discount %"; Decimal)
        {
            Caption = 'Discount %', comment = 'DEU="Rabatt %"';
            DataClassification = CustomerContent;
        }
        field(26; "Process No."; Code[20])
        {
            Caption = 'Process No.', comment = 'DEU="Prozessnr."';
            DataClassification = CustomerContent;
            TableRelation = "lbt Process";
        }
        field(27; Description; Text[50])
        {
            Caption = 'Description', comment = 'DEU="Beschreibung"';
            DataClassification = CustomerContent;
        }

        field(28; "No. Series"; Code[20])
        {
            Caption = 'No. Series', comment = 'DEU="Nummernserie"';
            DataClassification = CustomerContent;
        }

        field(29; "Customer Reserve Cr.Memo"; Code[20])
        {
            Caption = 'Customer Reserve Cr.Memo', comment = 'DEU="Debitor Rückstellungsgutschrift"';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }

    }
    keys
    {
        key(PK; "Contract")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        BonusSetup: Record "lbt Bonus Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        if "Contract" = '' then begin
            BonusSetup.Get();
            BonusSetup.TestField("Bonus Nos.");
            NoSeriesManagement.InitSeries(BonusSetup."Bonus Nos.", xRec."No. Series", 0D, "Contract", "No. Series");
            SetProcessNo();
        end;
    end;

    trigger OnDelete()
    begin
        IF "Contract" <> '' THEN BEGIN
            BonusContractEntryRec.SETRANGE("Contract", "Contract");
            IF NOT BonusContractEntryRec.ISEMPTY() THEN
                ERROR(Text002Msg, "Contract");
            BonusContractLineRec.SETRANGE("Contract", "Contract");
            IF NOT BonusContractLineRec.ISEMPTY() THEN
                BonusContractLineRec.DELETEALL();
            BonusContractDimRec.SETRANGE("Contract", "Contract");
            IF NOT BonusContractDimRec.ISEMPTY() THEN
                BonusContractDimRec.DELETEALL();
            BonusContractAttributRec.SETRANGE("Contract", "Contract");
            IF NOT BonusContractAttributRec.ISEMPTY() THEN
                BonusContractAttributRec.DELETEALL();
            BonusCustRec.SETRANGE("Contract", "Contract");
            IF NOT BonusCustRec.ISEMPTY() THEN
                BonusCustRec.DELETEALL();
        END;
    end;

    local procedure SetProcessNo()
    var
        Process: Record "lbt Process";
    begin
        "Process No." := "Contract";
        if not Process.get("Process No.") then begin
            Process.Init();
            Process."No." := "Process No.";
            Process.Insert(true);
        end;
    end;

    procedure AssistEdit(OldBonusContract: Record "lbt Bonus Contract"): Boolean
    var
        BonusContract: Record "lbt Bonus Contract";
        BonusSetup: Record "lbt Bonus Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        with BonusContract do begin
            BonusContract := Rec;
            BonusSetup.Get();
            BonusSetup.TestField("Bonus Nos.");
            if NoSeriesManagement.SelectSeries(BonusSetup."Bonus Nos.", OldBonusContract."No. Series", "No. Series") then begin
                NoSeriesManagement.SetSeries("Contract");
                Rec := BonusContract;
                SetProcessNo();
                exit(true);
            end;
        end;

    end;

    var
        BonusContractEntryRec: Record "lbt Bonus Entry";
        BonusContractLineRec: Record "lbt Bonus Contract Line";
        BonusContractDimRec: Record "lbt Bonus Contract Dimensions";
        BonusContractAttributRec: Record "lbt BonusContractAttribute";
        BonusCustRec: Record "lbt Bonus Customers";
        SalesHeaderRec: Record "Sales Header";
        Text001Msg: Label 'You can not reset the date, while there are unposted bonus credit memos.',
        Comment = 'DEU="Sie können das Datum nicht zurücksetzen, solange es ungebuchte Bonusgutschriften für diesen Kunden gibt"';

        Text002Msg: Label 'For contract %1 bonus contract entries exists. The contract can not be deleted.',
        Comment = 'DEU="Zum Vertrag %1 sind Bonusposten im System vorhanden. Der Bonusvertrag kann nicht gelöscht werden."';
        Text004Msg: Label 'You must delete Bonus Contract Lines before you modify the contract',
        Comment = 'DEU="Sie müssen die Vertragszeilen löschen, bevor Sie die Bonusart ändern."';

        Text005Msg: Label 'There are already Bonus Contract Entries. You cannot modify the contract.',
        Comment = 'DEU="Es existieren bereits Bonusposten. Der Vertrag kann nicht geändert werden."';

}