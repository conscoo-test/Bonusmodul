table 5266059 "lbtbn Customer Group"
{
    Caption = 'Customer Bonus Group';
    DataClassification = CustomerContent;
    LookupPageId = "lbtbn Customer Groups";
    DrillDownPageId = "lbtbn Customer Groups";
    fields
    {
        field(1; "Code"; Code[10])
        {
            NotBlank = true;
            Caption = 'Code';

        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
        }

    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
}