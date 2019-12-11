table 5266054 "lbt Bonus Contract Dimensions"
{
    DataClassification = ToBeClassified;
    Caption = 'Bonus Contract Dimensions', comment = 'DEU="Bonusvetrag Dimensionen"';
    LookupPageId = "lbt Bonus Contract Dimension";
    DrillDownPageId = "lbt Bonus Contract Dimension";

    fields
    {
        field(1; "lbt Contract"; Code[20])
        {
            Caption = 'Contract', comment = 'DEU="Vertrag"';
            DataClassification = CustomerContent;
            TableRelation = "lbt Bonus Contract"."lbt Contract";
        }
        field(2; "lbt Dimension Code"; Code[20])
        {
            Caption = 'Dimension Code', comment = 'DEU="Dimensionscode"';
            DataClassification = CustomerContent;
            TableRelation = Dimension;

        }
        field(3; "lbt Dimension Value"; Code[20])
        {
            Caption = 'Dimension Value', comment = 'DEU="Dimensionswert"';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Dimension Code" = field("lbt Dimension Code"));
        }

    }

    keys
    {
        key(PK; "lbt Contract", "lbt Dimension Code")
        {
            Clustered = true;
        }
    }

}