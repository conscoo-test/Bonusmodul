table 5266052 "lbt Bonus Contract"
{
    DataClassification = ToBeClassified;
    Caption = 'Bonus Contracts', comment = 'DEU="Bonusverträge"';

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
            Caption = 'Reverse Type', comment = 'DEU="Rückstellungsart';
            OptionMembers = "%","Amount (LCY)","Amount per Unit";
            OptionCaptionML = DEU = '%,Festbetrag (MW),Betrag je Einheit';
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



}