table 5266053 "lbt Bonus Contract Line"
{
    Caption = 'bonus scales', comment = 'DEU="Bonusstaffeln"';
    DataClassification = ToBeClassified;



    fields
    {
        field(1; Contract; Code[20])
        {
            Caption = 'Contract', comment = 'DEU="Vertrag"';
            DataClassification = CustomerContent;
            TableRelation = "lbt Bonus Contract"."Contract";
        }

        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.', comment = 'DEU="Zeilennummer"';
            DataClassification = CustomerContent;
        }
        field(3; "Item Unit of Measure"; Code[10])
        {
            Caption = 'Item Unit of Measure', comment = 'DEU="Artikeleinheit"';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure".Code;

            trigger OnValidate()
            begin
                TestField("Bonus Scale Type", "Bonus Scale Type"::"Sales Qty.");
            end;
        }
        field(4; "From Quantity"; Decimal)
        {
            Caption = 'From Quantity', comment = 'DEU="ab Menge"';
            DataClassification = CustomerContent;
        }
        field(5; Value; Decimal)
        {
            Caption = 'Value', comment = 'DEU="Wert"';
            DataClassification = CustomerContent;
        }
        field(6; "Bonus Scale Type"; Option)
        {
            Caption = 'Bonus Scale Type', comment = 'DEU="Bonusstaffelart"';
            OptionMembers = "Sales Qty.","Sales (LCY)'";
            OptionCaption = 'Sales Qty.,Sales (LCY)', comment = 'DEU="Absatz,Umsatz"';

            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Contract", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()

    var
        BonusContractRec: Record "lbt Bonus Contract";
    begin
        if BonusContractRec.Get("Contract") then
            "Bonus Scale Type" := BonusContractRec."Bonus Scale Type";

        if "Bonus Scale Type" = "Bonus Scale Type"::"Sales Qty." then
            TestField("Item Unit of Measure");
    end;


}