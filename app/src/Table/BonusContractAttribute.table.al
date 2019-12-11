table 5266055 "lbt BonusContractAttribute"
{
    Caption = 'Bonus Contract Attribute', comment = 'DEU="Bonusvertrag Attribute"';
    DataClassification = CustomerContent;
    LookupPageId = "lbt BonusContrAttributeFilter";
    DrillDownPageId = "lbt BonusContrAttributeFilter";

    fields
    {
        field(1; "lbt Contract"; Code[20])
        {
            Caption = 'Contract', comment = 'DEU="Vertrag"';
            DataClassification = CustomerContent;
            TableRelation = "lbt Bonus Contract"."lbt Contract";
        }
        field(2; "lbt ID"; Integer)
        {
            Caption = 'ID', comment = 'DEU="ID"';
            DataClassification = CustomerContent;
        }

        field(3; "lbt Attribute ID"; Integer)
        {
            Caption = 'Attribute ID', comment = 'DEU="Attriute ID"';
            DataClassification = CustomerContent;
            TableRelation = "Item Attribute".ID;

            trigger OnValidate()
            begin
                if AttributeRec.Get("lbt Attribute ID") then
                    "lbt Attribute Name" := AttributeRec.Name;
                "lbt Attribute Type" := AttributeRec.Type;

            end;
        }
        field(4; "lbt Attribute Name"; Text[250])
        {
            Caption = 'Attribute Name', comment = 'DEU="Attribute Name"';
            DataClassification = CustomerContent;
            TableRelation = "Item Attribute".Name;
            trigger OnValidate()
            begin
                if AttributeRec.Get("lbt Attribute Name") then
                    "lbt Attribute ID" := AttributeRec.ID;
                "lbt Attribute Type" := AttributeRec.Type;

            end;
        }
        field(5; "lbt Attribute Type"; Option)
        {
            Caption = 'Type', comment = 'DEU="Art"';
            DataClassification = CustomerContent;
            OptionMembers = "Option","Text","Integer","Decimal";
            OptionCaption = 'Option,Text,Integer,Decimal', comment = 'DEU="Option,Text,Ganzzahl,Dezimalzahl"';
            Editable = false;
        }
        field(6; "lbt Attribute Value ID"; Integer)
        {
            Caption = 'Value ID', comment = 'DEU="Wert"';
            DataClassification = CustomerContent;
            TableRelation = "Item Attribute Value".ID where("Attribute ID" = field("lbt Attribute ID"));
            trigger OnValidate()
            begin
                if AttributeValueRec.Get("lbt Attribute ID", "lbt Attribute Value ID") then
                    "lbt Attribute Value Name" := AttributeValueRec.Value
                else
                    "lbt Attribute Value Name" := '';
            end;
        }
        field(7; "lbt Attribute Value Name"; Text[250])
        {
            Caption = 'Value Name', comment = 'DEU="Wertname"';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "lbt Contract", "lbt Attribute ID", "lbt Attribute Value ID")
        {
            Clustered = true;
        }
    }

    var
        AttributeRec: Record "Item Attribute";
        AttributeValueRec: Record "Item Attribute Value";
    /*         ContractAttributRec: Record "lbt BonusContractAttribute";

     trigger OnInsert()
     var NewID: Integer;
      begin
         IF "lbt ID" = 0 then 
             ContractAttributRec.SetRange("lbt Contract","lbt Contract");
             if ContractAttributRec.FindLast() then
             NewID := ContractAttributRec."lbt ID";
             NewID += 1;
             "lbt ID" := NewID;
     end; */
}