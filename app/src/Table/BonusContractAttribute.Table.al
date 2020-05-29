table 5266055 "lbt BonusContractAttribute"
{
    Caption = 'Bonus Contract Attribute', comment = 'DEU="Bonusvertrag Attribute"';
    DataClassification = CustomerContent;
    LookupPageId = "lbt BonusContrAttributeFilter";
    DrillDownPageId = "lbt BonusContrAttributeFilter";

    fields
    {
        field(1; Contract; Code[20])
        {
            Caption = 'Contract', comment = 'DEU="Vertrag"';
            DataClassification = CustomerContent;
            TableRelation = "lbt Bonus Contract"."Contract";
        }
        field(2; ID; Integer)
        {
            Caption = 'ID', comment = 'DEU="ID"';
            DataClassification = CustomerContent;
        }

        field(3; "Attribute ID"; Integer)
        {
            Caption = 'Attribute ID', comment = 'DEU="Attribute ID"';
            DataClassification = CustomerContent;
            TableRelation = "Item Attribute".ID;

            trigger OnValidate()
            var
                ItemAttribute: Record "Item Attribute";
            begin
                if ItemAttribute.Get("Attribute ID") then begin
                    "Attribute Name" := ItemAttribute.Name;
                    "Attribute Type" := ItemAttribute.Type;
                end;
            end;
        }
        field(4; "Attribute Name"; Text[250])
        {
            Caption = 'Attribute Name', comment = 'DEU="Attribute Name"';
            DataClassification = CustomerContent;
            TableRelation = "Item Attribute".Name;
        }
        field(5; "Attribute Type"; Option)
        {
            Caption = 'Type', comment = 'DEU="Art"';
            DataClassification = CustomerContent;
            OptionMembers = "Option","Text","Integer","Decimal";
            OptionCaption = 'Option,Text,Integer,Decimal', comment = 'DEU="Option,Text,Ganzzahl,Dezimalzahl"';
            Editable = false;
        }
        field(6; "Attribute Value ID"; Integer)
        {
            Caption = 'Value ID', comment = 'DEU="Wert"';
            DataClassification = CustomerContent;
            TableRelation = "Item Attribute Value".ID where("Attribute ID" = field("Attribute ID"));
            trigger OnValidate()
            var
                ItemAttributeValue: Record "Item Attribute Value";
            begin
                if ItemAttributeValue.Get("Attribute ID", "Attribute Value ID") then
                    "Attribute Value Name" := ItemAttributeValue.Value
                else
                    "Attribute Value Name" := '';
            end;
        }
        field(7; "Attribute Value Name"; Text[250])
        {
            Caption = 'Value Name', comment = 'DEU="Wertname"';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Contract", "Attribute ID", "Attribute Value ID")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        ContractAttribut: Record "lbt BonusContractAttribute";
        NewID: Integer;
    begin
        if "ID" = 0 then
            ContractAttribut.SetRange("Contract", "Contract");
        if ContractAttribut.FindLast() then
            NewID := ContractAttribut."ID";
        NewID += 1;
        "ID" := NewID;
    end;
}