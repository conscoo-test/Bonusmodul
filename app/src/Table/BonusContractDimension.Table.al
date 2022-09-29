table 5266054 "lbtbn Bonus Contract Dimension"
{
    DataClassification = ToBeClassified;
    Caption = 'Bonus Contract Dimensions';
    LookupPageId = "lbtbn Bonus Contract Dimension";
    DrillDownPageId = "lbtbn Bonus Contract Dimension";

    fields
    {
        field(1; Contract; Code[20])
        {
            Caption = 'Contract';
            DataClassification = CustomerContent;
            TableRelation = "lbtbn Bonus Contract"."No.";
        }
        field(2; "Dimension Code"; Code[20])
        {
            Caption = 'Dimension Code';
            DataClassification = CustomerContent;
            TableRelation = Dimension;

        }
        field(3; "Dimension Value"; Code[20])
        {
            Caption = 'Dimension Value';
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