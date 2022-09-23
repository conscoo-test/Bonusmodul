table 5266056 "lbt Bonus Entry"
{
    Caption = 'Bonus Entry', comment = 'DEU="Bonusposten"';
    DataClassification = CustomerContent;
    LookupPageId = "lbt Bonus Entry";
    DrillDownPageId = "lbt Bonus Entry";


    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.', comment = 'DEU="Lfd. Nr."';
            DataClassification = CustomerContent;
        }

        field(2; "Entry Type"; Option)
        {
            Caption = 'Entry Type', comment = 'DEU="Postenart"';
            OptionMembers = Bonus,Reserve,"Liquidation of Reserves";
            OptionCaption = 'Bonus,Reserve,Liquidation of Reserves', comment = 'DEU="Bonus,Rückstellung,Rückstellungsauflösung"';
            DataClassification = CustomerContent;
        }
        field(3; Contract; Code[20])
        {
            Caption = 'Contract', comment = 'DEU="Vertrag"';
            DataClassification = CustomerContent;
            TableRelation = "lbt Bonus Contract"."No.";
        }
        field(4; "Bonus Contract Line"; Integer)
        {
            Caption = 'Bonus Contract Line', comment = 'DEU="Bonusvertragszeilen"';
            DataClassification = CustomerContent;
            TableRelation = "lbt Bonus Contract Line" where(Contract = field(Contract));
        }
        field(5; "Entry Date"; Date)
        {
            Caption = 'Date', comment = 'DEU="Datum"';
            DataClassification = CustomerContent;
        }
        field(6; "Base Amount"; Decimal)
        {
            Caption = 'Base Amount', Comment = 'DEU="Basisbetrag"';
            DataClassification = CustomerContent;
        }
        field(7; "General Ledger Entry No."; Integer)
        {
            Caption = 'General Ledger Entry No.', comment = 'DEU="Sachposten Lfd. Nr."';
            DataClassification = CustomerContent;
        }
        field(8; "Posted Amount"; Decimal)
        {
            Caption = 'Posted Amount', comment = 'DEU="gebuchter Betrag"';
            DataClassification = CustomerContent;
        }
        field(9; Customer; Code[20])
        {
            Caption = 'Customer', comment = 'DEU="Debitor"';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(10; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code', Comment = 'DEU="Lief. an Code"';
            DataClassification = CustomerContent;
            TableRelation = "Ship-to Address".Code where("Customer No." = field(Customer));
        }
        field(11; "Invoice Customer No."; Code[20])
        {
            Caption = 'Invoice Customer No.', Comment = 'DEU="Rechnungsempfänger"';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(12; "Bonus Document Type"; Option)
        {
            Caption = 'Bonus Document Type', Comment = 'DEU="Bonusbelegtyp"';
            DataClassification = CustomerContent;


            OptionMembers = ,"Sales Invoice","Sales Credit Memo";
            OptionCaption = ',Sales Invoice,Sales Credit Memo', comment = 'DEU=" ,Verkaufsrechnung,Verkaufsgutschrift"';
        }

        field(13; "Bonus Document No."; Code[20])
        {
            Caption = 'Bonus Document No.', Comment = 'DEU="Bonusbelegnummer"';
            DataClassification = CustomerContent;
        }
        field(14; "Bonus Document Line"; Integer)
        {
            Caption = 'Bonus Document Line', Comment = 'DEU="Bonusbelegzeile"';
            DataClassification = CustomerContent;
        }
        field(15; "From Document Type"; Option)
        {
            Caption = 'From Document Type', Comment = 'DEU="Quellbelegart"';
            DataClassification = CustomerContent;


            OptionMembers = ,"Sales Invoice","Sales Credit Memo";
            OptionCaption = ',Sales Invoice,Sales Credit Memo', comment = 'DEU=" ,Verkaufsrechnung,Verkaufsgutschrift"';
        }

        field(16; "From Document No."; Code[20])
        {
            Caption = 'From Document No.', Comment = 'DEU="Quellbelegnummer"';
            DataClassification = CustomerContent;
        }
        field(17; "From Document Line"; Integer)
        {
            Caption = 'From Document Line', Comment = 'DEU="Quellbelegzeile"';
            DataClassification = CustomerContent;
        }
        field(18; "Sales Quantity"; Decimal)
        {
            Caption = 'Sales Quantity', Comment = 'DEU="Absatzmenge"';
            DataClassification = CustomerContent;
        }
        field(19; "Calculated Amount"; Decimal)
        {
            Caption = 'Calculated Amount', Comment = 'DEU="berechneter Betrag"';
            DataClassification = CustomerContent;
        }
        field(20; "calc. Amount incl. VAT"; Decimal)
        {
            Caption = 'calculated Amount incl. VAT', Comment = 'DEU="errechneter Betrag inkl. MwSt."';
            DataClassification = CustomerContent;
        }
        field(21; "Pmt. Discount Amount"; Decimal)
        {
            Caption = 'Pmt. Discount Amount', Comment = 'DEU="Skontobetrag"';
            DataClassification = CustomerContent;
        }
        field(22; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount', Comment = 'DEU="Rabattbetrag"';
            DataClassification = CustomerContent;
        }
        field(23; "Assignment Document Type"; Option)
        {
            Caption = 'Assignment Document Type', Comment = 'DEU="Zuweisungsbelegart"';
            DataClassification = CustomerContent;
            OptionMembers = ,"Sales Shipment","Sales Return Receipt";
            OptionCaption = ' ,Sales Shipment,Sales Return Receipt', Comment = 'DEU=" ,Verkaufslieferung,Verkaufsrücksendung"';
        }
        field(24; "Assignment Document No."; Code[20])
        {
            Caption = 'Assignment Document No.', Comment = 'DEU="Zuweisungsbelegnr."';
            DataClassification = CustomerContent;
        }
        field(25; "Assignment Doc. Line No."; Integer)
        {
            Caption = 'Assignment Doc. Line No.', Comment = 'DEU="Zuweisungsbelegzeilennr."';
            DataClassification = CustomerContent;
        }
        field(26; "Process No."; Code[20])
        {
            Caption = 'Process No.', comment = 'DEU="Prozessnr."';
            DataClassification = CustomerContent;
            TableRelation = "lbt Process";
        }

    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

}