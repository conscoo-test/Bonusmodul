table 5266052 "lbt Bonus Contract"
{
    DataClassification = ToBeClassified;
    Caption = 'Bonus Contracts', comment = 'DEU="Bonusverträge"';
    LookupPageId = "lbt Bonus Contract List";
    DrillDownPageId = "lbt Bonus Contract List";

    fields
    {
        field(1; "lbt Contract"; Code[20])
        {
            Caption = 'Contract', comment = 'DEU="Vertrag"';
            DataClassification = CustomerContent;
            NotBlank= true;
        }

        field(2; "lbt Valid from"; Date)
        {
            Caption = 'Valid from', comment = 'DEU="Gültig von"';
            DataClassification = CustomerContent;
        }

        field(3; "lbt Valid to"; Date)
        {
            Caption = 'Valid to', comment = 'DEU="Gültig bis"';
            DataClassification = CustomerContent;
        }
        field(4; "lbt Billing Period"; DateFormula)
        {
            Caption = 'Billing Period', comment = 'DEU="Abrechnungsintervall"';
            DataClassification = CustomerContent;
        }
        field(5; "lbt Reserve Value"; Decimal)
        {
            Caption = 'Reserve Value', comment = 'DEU="Rückstellungswert"';
            DataClassification = CustomerContent;
        }
        field(6; "lbt Reserve Type"; Option)
        {
            Caption = 'Reverse Type', comment = 'DEU="Rückstellungsart"';
            OptionMembers = "%","Amount (LCY)","Amount per Unit";
            OptionCaption = '%,Amount (LCY),Amount per Unit', comment = 'DEU="%,Festbetrag (MW),Betrag je Einheit"';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                IF "lbt Reserve Type" <> "lbt Reserve Type"::"%" THEN BEGIN
                    "lbt Pmt. Discount %" := 0;
                    "lbt Discount %" := 0;
                END;
            end;
        }
        field(7; "lbt Reserve Unit"; Code[10])
        {
            Caption = 'Reserve Unit', comment = 'DEU="Rückstellungseinheit"';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure".Code;
        }

        field(8; "lbt Last Reserve at"; Date)
        {
            Caption = 'Last Reserve at', comment = 'DEU="letzte Rückstellung am"';
            DataClassification = CustomerContent;
        }

        field(9; "lbt Bonus Billing Type"; Option)
        {
            Caption = 'Bonus Billing Type', comment = 'DEU="Bonusabrechnungsart"';
            DataClassification = CustomerContent;
            OptionMembers = "%","Amount (LCY)","Amount per Unit";
            OptionCaption = '%,Amount (LCY),Amount per Unit', comment = 'DEU="%,Festbetrag (MW),Betrag je Einheit"';

            trigger OnValidate()
            begin
                IF "lbt Bonus Billing Type" <> "lbt Bonus Billing Type"::"%" THEN BEGIN
                    "lbt Pmt. Discount %" := 0;
                    "lbt Discount %" := 0;
                END;
            end;
        }

        field(10; "lbt Bonus Billing Unit"; Code[10])
        {
            Caption = 'Bonus Billing Unit', comment = 'DEU="Bonusabrechnungseinheit"';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure".Code;
        }
        field(11; "lbt Last Billing at"; Date)
        {
            Caption = 'Last Billing at', comment = 'DEU="letzte Abrechnung am"';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                IF ("lbt Last Billing at" < xRec."lbt Last Billing at") OR ("lbt Last Billing at" = 0D) THEN
                    SalesHeaderRec.RESET();
                SalesHeaderRec.SETCURRENTKEY("Document Type", "Sell-to Customer No.", "Salesperson Code",
                                             "Shortcut Dimension 1 Code", "Document Date");
                SalesHeaderRec.SETRANGE("Document Type", SalesHeaderRec."Document Type"::"Credit Memo");
                SalesHeaderRec.SETRANGE("Sell-to Customer No.", "lbt Bonus Recipient");
                SalesHeaderRec.SETRANGE("Posting Description", 'Bonusgutschrift');
                ///LBIS02
                IF NOT SalesHeaderRec.ISEMPTY() THEN
                    ERROR(Text001Msg);


            end;
        }

        field(12; "lbt Bonus Scale Type"; Option)
        {
            Caption = 'Bonus Scale Type', comment = 'DEU="Bonusstaffelart"';
            DataClassification = CustomerContent;
            OptionMembers = "Sales Qty.","Sales (LCY)";
            OptionCaption = 'Sales Qty.,Sales (LCY)', comment = 'DEU="Absatz,Umsatz"';

            trigger OnValidate()
            begin
                IF "lbt Bonus Scale Type" <> xRec."lbt Bonus Scale Type" THEN
                    BonusContractEntryRec.SETRANGE("lbt Contract", "lbt Contract");
                IF NOT BonusContractEntryRec.ISEMPTY() THEN
                    
                    ERROR(Text005Msg);
                BonusContractLineRec.SETRANGE("lbt Contract", "lbt Contract");

                IF NOT BonusContractLineRec.ISEMPTY() THEN
                    ERROR(Text004Msg);

                IF "lbt Bonus Scale Type" = "lbt Bonus Scale Type"::"Sales (LCY)" THEN
                    IF "lbt Bonus Billing Type" <> "lbt Bonus Billing Type"::"%" THEN
                        FIELDERROR("lbt Bonus Billing Type");

            end;

        }

        field(13; "lbt Bonus Recipient"; Code[20])
        {
            Caption = 'Bonus Recipient', comment = 'DEU="Bonusempfänger"';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
        field(14; "lbt Bonus Group"; Code[20])
        {
            Caption = 'Bonus Group', comment = 'DEU="Bonusgruppe"';
            DataClassification = CustomerContent;
            TableRelation = "lbt Bonus Group"."lbt Code";
        }

        field(15; "lbt Contract Type"; Option)
        {
            Caption = 'Contract Type', comment = 'DEU="Vertragsart"';
            DataClassification = CustomerContent;
            OptionMembers = "Bonus","Advertising Costs";
            OptionCaption = 'Bonus,Advertising Costs', comment = 'DEU="Bonus,Werbekosten"';
        }

        field(16; "lbt No. of Customers"; Integer)
        {
            Caption = 'No. of Customers', comment = 'DEU="Anzahl Debitoren"';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count ("lbt Bonus Customers" where ("lbt Contract" = field ("lbt Contract")));

        }
        field(17; "lbt Balance of Bonus"; Decimal)
        {
            Caption = 'Balance of Bonus', comment = 'DEU="Saldo Bonus"';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum ("lbt Bonus Entry"."lbt Amount" where ("lbt Contract" = field ("lbt Contract"), "lbt Entry Type" = const ("Bonus")));

        }
        field(18; "lbt Balance of Reserve"; Decimal)
        {
            Caption = 'Balance of Reserve', comment = 'DEU="Saldo Rückstellungen"';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum ("lbt Bonus Entry"."lbt Amount" where ("lbt Contract" = field ("lbt Contract"), "lbt Entry Type" = const ("Reserve")));
        }


        field(19; "lbt Balance of Liquid Reserves"; Decimal)
        {
            Caption = 'Balance of Liquidation Reserve', comment = 'DEU="Saldo Rückstellungen"';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum ("lbt Bonus Entry"."lbt Amount" where ("lbt Contract" = field ("lbt Contract"), "lbt Entry Type" = const ("Liquidation of Reserves")));
        }
        field(20; "lbt No. of Dimensions"; Integer)
        {
            Caption = 'No. of Dimensions', comment = 'DEU="Anzahl der Dimensionen"';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count ("lbt Bonus Contract Dimensions" where ("lbt Contract" = field ("lbt Contract")));
        }
        field(21; "lbt No. of Attribute"; Integer)
        {
            Caption = 'No. of Attribute', comment = 'DEU="Anzahl der Attribute"';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count ("lbt BonusContractAttribute" where ("lbt Contract" = field ("lbt Contract")));
        }

        field(22; "lbt Reserve Item Charge"; Code[20])
        {
            Caption = 'Reserve Item Charge', comment = 'DEU="Rückstellungszuschlag"';
            DataClassification = CustomerContent;
            TableRelation = "Item Charge"."No.";
        }

        field(23; "lbt Accounting Item Charge"; Code[20])
        {
            Caption = 'Accounting Item Charge', comment = 'DEU="Abrechnungszuschlag"';
            DataClassification = CustomerContent;
            TableRelation = "Item Charge"."No.";
        }

        field(24; "lbt Pmt. Discount %"; Decimal)
        {
            Caption = 'Payment Discount %', comment = 'DEU="Skonto %"';
            DataClassification = CustomerContent;
        }

        field(25; "lbt Discount %"; Decimal)
        {
            Caption = 'Discount %', comment = 'DEU="Rabatt %"';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "lbt Contract")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    begin
        IF "lbt Contract" <> '' THEN BEGIN
            BonusContractEntryRec.SETRANGE("lbt Contract", "lbt Contract");
            IF NOT BonusContractEntryRec.ISEMPTY() THEN
                ERROR(Text002Msg, "lbt Contract");
            BonusContractLineRec.SETRANGE("lbt Contract", "lbt Contract");
            IF NOT BonusContractLineRec.ISEMPTY() THEN
                BonusContractLineRec.DELETEALL();
            BonusContractDimRec.SETRANGE("lbt Contract", "lbt Contract");
            IF NOT BonusContractDimRec.ISEMPTY() THEN
                BonusContractDimRec.DELETEALL();
            BonusContractAttributRec.SETRANGE("lbt Contract", "lbt Contract");
            IF NOT BonusContractAttributRec.ISEMPTY() THEN
                BonusContractAttributRec.DELETEALL();
            BonusCustRec.SETRANGE("lbt Contract", "lbt Contract");
            IF NOT BonusCustRec.ISEMPTY() THEN
                BonusCustRec.DELETEALL();
        END;
    end;

    var
        BonusContractEntryRec: Record "lbt Bonus Entry";
        BonusContractLineRec: Record "lbt Bonus Contract Line";
        BonusContractDimRec: Record "lbt Bonus Contract Dimensions";
        BonusContractAttributRec: Record "lbt BonusContractAttribute";
        BonusCustRec: Record "lbt Bonus Customers";
        SalesHeaderRec: Record "Sales Header";
        Text001Msg: Label 'You can not reset the date, while there are unposted bonus credit memos.',
        Comment = 'DEU="Sie können das Datum nicht zurücksetzen, solange es ungebuchte Bonusgutschriften für diesen Kunden gibt';

        Text002Msg: Label 'For contract %1 bonus contract entries exists. The contract can not be deleted.',
        Comment = 'DEU="Zum Vertrag %1 sind Bonusposten im System vorhanden. Der Bonusvertrag kann nicht gelöscht werden.';
        Text004Msg: Label 'You must delete Bonus Contract Lines before you modify the contract',
        Comment = 'DEU="Sie müssen die Vertragszeilen löschen, bevor Sie die Bonusart ändern.';

        Text005Msg: Label 'There are already Bonus Contract Entries. You cannot modify the contract.',
        Comment = 'DEU="Es existieren bereits Bonusposten. Der Vertrag kann nicht geändert werden.';

}