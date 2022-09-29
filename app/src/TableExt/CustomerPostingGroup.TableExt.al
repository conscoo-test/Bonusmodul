tableextension 5266051 "lbtbn Customer Posting Group" extends "Customer Posting Group" //92
{
    fields
    {
        field(5266051; "lbtbn Bonus Reserve Account"; Code[20])
        {
            Caption = 'Bonus Reserve Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }

        field(5266052; "lbtbn Bonus Reserve Bal. Account"; Code[20])
        {
            Caption = 'Bonus Reserve Bal. Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }

    }

}