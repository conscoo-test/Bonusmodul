table 5266055 "lbt BonusContractAttribute"
{
    Caption = 'Bonus Contract Attribute', comment = 'ESP="Bonusvertrag Attribute"';
    DataClassification = CustomerContent;


    fields
    {
        field(1; "lbt Contract"; Code[20])
        {
            Caption = 'Contract', comment = 'DEU="Vertrag"';
            DataClassification = CustomerContent;
            TableRelation= "lbt Bonus Contract"."lbt Contract";
        }

        field(2; "lbt Attribute ID"; Integer)
        {
            Caption = 'ID', comment = 'DEU="ID"';
            DataClassification = CustomerContent;
        }

        field(3; "lbt Attribute Name"; Text[250])
        {
            Caption = 'Name', comment = 'DEU="Name"';
            DataClassification = CustomerContent;
        }

        field(4; "lbt Attribute Type"; Option)
        {
            Caption = 'Type', comment = 'DEU="Art"';
            DataClassification = CustomerContent;
            OptionMembers = "Option","Text","Integer","Decimal";
            OptionCaptionML = DEU = 'Option,Text,Ganzzahl,Dezimalzahl';
            Editable =false;
        }
        field(5;"lbt Attribute Value"; Text[250] )
        {
           Caption = 'Value', comment = 'DEU="Wert"';
           DataClassification= CustomerContent;
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