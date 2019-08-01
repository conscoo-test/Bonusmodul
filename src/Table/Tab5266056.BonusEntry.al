table 5266056 "lbt Bonus Entry"
{
    Caption = 'Bonus Entry', comment = 'DEU="Bonusposten"';
    DataClassification = CustomerContent;
    LookupPageId = "lbt Bonus Entry";
    DrillDownPageId= "lbt Bonus Entry";


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
           TableRelation="lbt Bonus Contract"."lbt Contract";
        }
        field(4; "lbt Bonus Contract Line"; Integer)
        {
           Caption = 'Bonus Contract Line', comment = 'DEU="Bonusvetragszeilen"';;
            DataClassification = CustomerContent;
            TableRelation = "lbt Bonus Contract Line" where ("lbt Contract" = field("lbt Contract"));
        }
        field(5; "lbt Date"; Date)
        {
            Caption = 'Date', comment = 'DEU="Datum"';
            DataClassification = CustomerContent;
        }
        field(6; "lbt Amount"; Decimal)
        {
            Caption = 'Amount', comment = 'DEU="Betrag"';
            DataClassification = CustomerContent;
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