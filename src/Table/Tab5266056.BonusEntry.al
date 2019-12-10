table 5266056 "lbt Bonus Entry"
{
    Caption = 'Bonus Entry', comment = 'DEU="Bonusposten"';
    DataClassification = CustomerContent;
    LookupPageId = "lbt Bonus Entry";
    DrillDownPageId = "lbt Bonus Entry";


    fields
    {
        field(1; "lbt Entry No."; Integer)
        {
            Caption = 'Entry No.', comment = 'DEU="Lfd. Nr."';
            DataClassification = CustomerContent;
        }

        field(2; "lbt Entry Type"; Option)
        {
            Caption = 'Entry Type', comment = 'DEU="Postenart"';
            OptionMembers = "Bonus","Reserve","Liquidation of Reserves";
            OptionCaption = 'Bonus,Reserve,Liquidation of Reserves', comment = 'DEU="Bonus,Rückstellung,Rückstellungsauflösung"';
            DataClassification = CustomerContent;
        }
        field(3; "lbt Contract"; Code[20])
        {
            Caption = 'Contract', comment = 'DEU="Vertrag"';
            DataClassification = CustomerContent;
            TableRelation = "lbt Bonus Contract"."lbt Contract";
        }
        field(4; "lbt Bonus Contract Line"; Integer)
        {
            Caption = 'Bonus Contract Line', comment = 'DEU="Bonusvetragszeilen"';
            ;
            DataClassification = CustomerContent;
            TableRelation = "lbt Bonus Contract Line" where("lbt Contract" = field("lbt Contract"));
        }
        field(5; "lbt Entry Date"; Date)
        {
            Caption = 'Date', comment = 'DEU="Datum"';
            DataClassification = CustomerContent;
        }
        field(6; "lbt Base Amount"; Decimal)
        {
            Caption = 'lbt Base Amount', Comment = 'DEU="Basisbetrag"';
            DataClassification = CustomerContent;
        }
        field(7; "lbt General Ledger Entry No."; Integer)
        {
            Caption = 'General Ledger Entry No.', comment = 'DEU="Sachposten Lfd. Nr."';
            DataClassification = CustomerContent;
        }
        field(8; "lbt Posted Amount"; Decimal)
        {
            Caption = 'Posted Amount', comment = 'DEU="gebuchter Betrag"';
            DataClassification = CustomerContent;
        }
        field(9; "lbt Customer"; Code[20])
        {
            Caption = 'Customer', comment = 'DEU="Debitor"';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(10; "lbt Ship-to Code"; Code[10])
        {
            Caption = 'lbt Ship-to Code', Comment = 'DEU="Lief. an Code"';
            DataClassification = CustomerContent;
            TableRelation = "Ship-to Address".Code where("Customer No." = Field("lbt Customer"));
        }
        field(11; "lbt Invoice Customer No."; Code[20])
        {
            Caption = 'lbt Invoice Customer No.', Comment = 'DEU="Rechnungsempfänger"';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(12; "lbt Bonus Document Type"; Option)
        {
            Caption = 'Bonus Document Type', Comment = 'DEU="Bonusbelegtyp"';
            DataClassification = CustomerContent;


            OptionMembers = ,"Sales Invoice","Sales Credit Memo";
            OptionCaption = ',Sales Invoice,Sales Credit Memo', comment = 'DEU=" ,Verkaufsrechnung,Verkaufsgutschrift"';
        }

        field(13; "lbt Bonus Document No."; Code[20])
        {
            Caption = 'Bonus Document No.', Comment = 'DEU="Bonusbelegnummer"';
            DataClassification = CustomerContent;
        }
        field(14; "lbt Bonus Document Line"; Integer)
        {
            Caption = 'Bonus Document Line', Comment = 'DEU="Bonusbelegzeile"';
            DataClassification = CustomerContent;
        }
        field(15; "lbt From Document Type"; Option)
        {
            Caption = 'From Document Type', Comment = 'DEU="Quellbelegart"';
            DataClassification = CustomerContent;


            OptionMembers = ,"Sales Invoice","Sales Credit Memo";
            OptionCaption = ',Sales Invoice,Sales Credit Memo', comment = 'DEU=" ,Verkaufsrechnung,Verkaufsgutschrift"';
        }

        field(16; "lbt From Document No."; Code[20])
        {
            Caption = 'From Document No.', Comment = 'DEU="Quellbelegnummer"';
            DataClassification = CustomerContent;
        }
        field(17; "lbt From Document Line"; Integer)
        {
            Caption = 'From Document Line', Comment = 'DEU="Quellbelegzeile"';
            DataClassification = CustomerContent;
        }
        field(18; "lbt Sales Quantity"; decimal)
        {
            Caption = 'Sales Quantity', Comment = 'DEU="Absatzmenge"';
            DataClassification = CustomerContent;
        }
        field(19; "lbt Calculated Amount"; Decimal)
        {
            Caption = 'Calculated Amount', Comment = 'DEU="berechneter Betrag"';
            DataClassification = CustomerContent;
        }
        field(20; "lbt calc. Amount incl. VAT"; Decimal)
        {
            Caption = 'calculated Amount incl. VAT', Comment = 'DEU="errechneter Betrag inkl. MwSt."';
            DataClassification = CustomerContent;
        }
        field(21; "lbt Pmt. Discount Amount"; Decimal)
        {
            Caption = 'Pmt. Discount Amount', Comment = 'DEU="Skontobetrag"';
            DataClassification = CustomerContent;
        }
        field(22; "lbt Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount', Comment = 'DEU="Rabattbetrag"';
            DataClassification = CustomerContent;
        }
        field(23; "lbt Assignment Document Type"; Option)
        {
            Caption = 'Assignment Document Type', Comment = 'DEU="Zuweisungsbelegart"';
            DataClassification = CustomerContent;
            OptionMembers = ,"Sales Shipment","Sales Return Receipt";
            OptionCaption = ' ,Sales Shipment,Sales Return Receipt', Comment = 'DEU=" ,Verkaufslieferung,Verkaufsrücksendung"';
        }
        field(24; "lbt Assignment Document No."; Code[20])
        {
            Caption = 'Assignment Document No.', Comment = 'DEU="Zuweisungsbelegnr."';
            DataClassification = CustomerContent;
        }
        field(25; "lbt Assignment Doc. Line No."; Integer)
        {
            Caption = 'Assignment Doc. Line No.', Comment = 'DEU="Zuweisungsbelegzeilennr."';
            DataClassification = CustomerContent;
        }
        field(26; "Process No."; Code[50])
        {
            Caption = 'Process No.', comment = 'DEU="Prozessnr."';
            DataClassification = ToBeClassified;
            TableRelation = "LBT Process";
        }

    }

    keys
    {
        key(PK; "lbt Entry No.")
        {
            Clustered = true;
        }
    }

}