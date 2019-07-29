table 5266058 "lbt Bonus Customers"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "lbt Contract"; Code[20])
        {
            Caption = 'Contract', comment = 'DEU="Vertrag"';
            DataClassification = CustomerContent;
            TableRelation = "lbt Bonus Contract"."lbt Contract";
        }

        field(2; "lbt Customer"; Code[20])
        {
            Caption = 'Customer', comment = 'DEU="Debitor"';
            DataClassification = CustomerContent;
            tableRelation = Customer."No.";

            trigger OnValidate()
            begin
                IF CustRec.get("lbt Customer") then
                "lbt Customer Name" := CustRec.Name
                ELSE
                "lbt Customer Name" := '';
            end;
        }

        field(3; "lbt Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code', comment = 'DEU="Lief. an Code"';
            DataClassification = CustomerContent;
            TableRelation = "Ship-to Address".Code where ("Customer No." = field ("lbt Customer"));

            trigger OnValidate()
            begin
                IF ShipToAdressRec.get("lbt Customer","lbt Ship-to Code") then
                "lbt Ship-to Name" := ShipToAdressRec.Name
                else
                "lbt Ship-to Name" := '';
            end;

        }
        field(4; "lbt Customer Name"; Text[100])
        {
            Caption = 'Customer Name', comment = 'DEU="Debitorname"';
            DataClassification = CustomerContent;
        }

        field(5; "lbt Ship-to Name"; Text[100])
        {
            Caption = 'Ship-to Name', comment = 'DEU="Lieferung an Name"';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "lbt Contract","lbt Customer","lbt Ship-to Code")
        {
            Clustered = true;
        }
    }

    var 
    CustRec:Record Customer;
    ShipToAdressRec: Record "Ship-to Address";
    

}