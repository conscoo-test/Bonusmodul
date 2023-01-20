table 5266061 "lbtbn Item Group"
{
    Caption = 'Item Bonus Group';
    DataClassification = CustomerContent;
    LookupPageId = "lbtbn Item Groups";
    DrillDownPageId = "lbtbn Item Groups";
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