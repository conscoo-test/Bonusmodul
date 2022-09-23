table 5266057 "lbt Bonus Group"
{
    Caption = 'Bonus Group';
    DataClassification = CustomerContent;
    LookupPageId = "lbt Bonus Group";
    DrillDownPageId = "lbt Bonus Group";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

}