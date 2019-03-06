table 50100 "lbt Bonus Setup"
{
    DataClassification = ToBeClassified;
    Caption = 'Bonus Setup', comment = 'DEU="Bonus Einrichtung"';

    fields
    {
        field(1; "lbt Primary Key"; code[10])
        {
            Caption = 'Primary Key', comment = 'DEU="Primärschlüssel"';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                
            end;
        }


    }

    keys
    {
        key(PK; "lbt Primary Key")
        {
            Clustered = true;
        }
    }

        
    var
        Contact: Record Contact;
        Txtvar: Text[100];

}