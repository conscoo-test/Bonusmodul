table 5266058 "lbt Bonus Customer"
{
    DataClassification = CustomerContent;
    LookupPageId = "lbt Bonus Customers";
    DrillDownPageId = "lbt Bonus Customers";
    Caption = 'Bonus Customer';

    fields
    {
        field(1; Contract; Code[20])
        {
            Caption = 'Contract';
            DataClassification = CustomerContent;
            TableRelation = "lbt Bonus Contract"."No.";
        }

        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";

            trigger OnValidate()
            begin
                if Customer.Get("Customer No.") then
                    "Customer Name" := Customer.Name
                else
                    "Customer Name" := '';
            end;
        }

        field(3; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code';
            DataClassification = CustomerContent;
            TableRelation = "Ship-to Address".Code where("Customer No." = field("Customer No."));

            trigger OnValidate()
            begin
                if ShipToAdress.Get("Customer No.", "Ship-to Code") then
                    "Ship-to Name" := ShipToAdress.Name
                else
                    "Ship-to Name" := '';
            end;

        }
        field(4; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
        }

        field(5; "Ship-to Name"; Text[100])
        {
            Caption = 'Ship-to Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Contract, "Customer No.", "Ship-to Code")
        {
            Clustered = true;
        }
    }

    var
        Customer: Record Customer;
        ShipToAdress: Record "Ship-to Address";
}