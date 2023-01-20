tableextension 5266054 "lbtbn Customer" extends Customer
{
    fields
    {
        field(5266051; "lbtbn Customer Group"; Code[10])
        {
            Caption = 'Customer Bonus Group';
            TableRelation = "lbtbn Customer Group";
            DataClassification = CustomerContent;
        }
    }
}