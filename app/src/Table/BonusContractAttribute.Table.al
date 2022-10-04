table 5266055 "lbtbn BonusContractAttribute"
{
    Caption = 'Bonus Contract Attribute';
    DataClassification = CustomerContent;
    LookupPageId = "lbtbn Contract Attr. Filter";
    DrillDownPageId = "lbtbn Contract Attr. Filter";

    fields
    {
        field(1; Contract; Code[20])
        {
            Caption = 'Contract';
            TableRelation = "lbtbn Bonus Contract"."No.";
        }
        field(2; ID; Integer)
        {
            Caption = 'ID';
        }

        field(3; "Attribute ID"; Integer)
        {
            Caption = 'Attribute ID';
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
            Caption = 'Attribute Name';
            TableRelation = "Item Attribute".Name;
        }
        field(5; "Attribute Type"; Option)
        {
            Caption = 'Type';
            OptionMembers = "Option","Text","Integer","Decimal";
            OptionCaption = 'Option,Text,Integer,Decimal';
            Editable = false;
        }
        field(6; "Attribute Value ID"; Integer)
        {
            Caption = 'Value ID';
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
            Caption = 'Value Name';
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
        ContractAttribut: Record "lbtbn BonusContractAttribute";
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