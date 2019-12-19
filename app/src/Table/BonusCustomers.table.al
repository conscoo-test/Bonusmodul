table 5266058 "lbt Bonus Customers"
{
    DataClassification = CustomerContent;
    LookupPageId = "lbt Bonus Customers";
    DrillDownPageId = "lbt Bonus Customers";
    Caption = 'Bonus Customer', Comment = 'DEU="Bonusdebitor"';

    fields
    {
        field(1; Contract; Code[20])
        {
            Caption = 'Contract', comment = 'DEU="Vertrag"';
            DataClassification = CustomerContent;
            TableRelation = "lbt Bonus Contract"."Contract";
        }

        field(2; Customer; Code[20])
        {
            Caption = 'Customer', comment = 'DEU="Debitor"';
            DataClassification = CustomerContent;
            tableRelation = Customer."No.";

            trigger OnValidate()
            begin
                IF CustRec.get("Customer") then
                    "Customer Name" := CustRec.Name
                ELSE
                    "Customer Name" := '';
            end;
        }

        field(3; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code', comment = 'DEU="Lief. an Code"';
            DataClassification = CustomerContent;
            TableRelation = "Ship-to Address".Code where("Customer No." = field("Customer"));

            trigger OnValidate()
            begin
                IF ShipToAdressRec.get("Customer", "Ship-to Code") then
                    "Ship-to Name" := ShipToAdressRec.Name
                else
                    "Ship-to Name" := '';
            end;

        }
        field(4; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name', comment = 'DEU="Debitorname"';
            DataClassification = CustomerContent;
        }

        field(5; "Ship-to Name"; Text[100])
        {
            Caption = 'Ship-to Name', comment = 'DEU="Lieferung an Name"';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Contract", "Customer", "Ship-to Code")
        {
            Clustered = true;
        }
    }

    var
        CustRec: Record Customer;
        ShipToAdressRec: Record "Ship-to Address";


}