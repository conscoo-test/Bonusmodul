table 5266054 "lbt Bonus Contract Dimension"
{
    DataClassification = ToBeClassified;
    Caption = 'Bonus Contract Dimensions', comment = 'DEU="Bonusvetrag Dimensionen"';
    LookupPageId = "lbt Bonus Contract Dimension";
    DrillDownPageId = "lbt Bonus Contract Dimension";

    fields
    {
        field(1; Contract; Code[20])
        {
            Caption = 'Contract', comment = 'DEU="Vertrag"';
            DataClassification = CustomerContent;
            TableRelation = "lbt Bonus Contract"."No.";
        }
        field(2; "Dimension Code"; Code[20])
        {
            Caption = 'Dimension Code', comment = 'DEU="Dimensionscode"';
            DataClassification = CustomerContent;
            TableRelation = Dimension;

        }
        field(3; "Dimension Value"; Code[20])
        {
            Caption = 'Dimension Value', comment = 'DEU="Dimensionswert"';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Dimension Code" = field("Dimension Code"));
        }

    }

    keys
    {
        key(PK; "Contract", "Dimension Code")
        {
            Clustered = true;
        }
    }

}