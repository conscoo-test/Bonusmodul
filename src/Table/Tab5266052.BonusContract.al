table 5266052 "lbt Bonus Contract"
{
    DataClassification = ToBeClassified;
    Caption = 'Bonus Contracts', comment = 'DEU="Bonusverträge"';
    LookupPageId ="lbt Bonus Contract List";
    DrillDownPageId = "lbt Bonus Contract List";

    fields
    {
        field(1; "lbt Contract"; Code[20])
        {
            Caption = 'Contract', comment = 'DEU="Vertrag"';
            DataClassification = CustomerContent;
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
        }

        field(12; "lbt Bonus Scale Type"; Option)
        {
            Caption = 'Bonus Scale Type', comment = 'DEU="Bonusstaffelart"';
            DataClassification = CustomerContent;
            OptionMembers = "Sales Qty.","Sales (LCY)";
            OptionCaption = 'Sales Qty.,Sales (LCY)', comment = 'DEU="Absatz,Umsatz"';

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



    }
    keys
    {
        key(PK; "lbt Contract")
        {
            Clustered = true;
        }
    }



}