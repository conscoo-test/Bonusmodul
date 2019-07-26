table 5266056 "lbt Bonus Entry"
{
    Caption = 'Bonus Entry', comment = 'DEU="Bonusposten"';
    DataClassification = CustomerContent;


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
            OptionCaptionML = DEU = 'Bonus,Rückstellung,Rückstellungsauflösung';
            DataClassification = CustomerContent;
        }
        field(3; "lbt Contract"; Code[20])
        {
           Caption = 'Contract', comment = 'DEU="Vertrag"';
           DataClassification = CustomerContent;
           TableRelation="lbt Bonus Contract"."lbt Contract";
           
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