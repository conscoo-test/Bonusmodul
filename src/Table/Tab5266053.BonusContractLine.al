table 5266053 "lbt Bonus Contract Line"
{
    Caption = 'bonus ladders', comment = 'DEU="Bonusstaffeln"';
    DataClassification = ToBeClassified;


    fields
    {
        field(1; "lbt Contract"; Code[20])
        {
            Caption = 'Contract', comment = 'DEU="Vertrag"';
            DataClassification = CustomerContent;
            TableRelation = "lbt Bonus Contract"."lbt Contract";
        }

        field(2; "lbt Line No."; Integer)
        {
            Caption = 'Line No.', comment = 'DEU="Zeilennummer"';
            DataClassification = CustomerContent;
        }
        field(3; "lbt Item Unit of Measure"; Code[10])
        {
            Caption = 'Item Unit of Measure', comment = 'DEU="Artikeleinheit"';
            DataClassification = CustomerContent;
        }
        field(4; "lbt From Quantity"; Decimal)
        {
            Caption = 'From Quantity', comment = 'DEU="ab Menge"';
            DataClassification = CustomerContent;
        }
        field(5; "lbt Value"; Decimal)
        {
            Caption = 'Value', comment = 'DEU="Wert"';
            DataClassification = CustomerContent;
        }
        field(6; "lbt Bonus Type"; Option)
        {
            Caption = 'Type', comment = 'DEU="Art"';
            OptionMembers = "Sales Qty.","Sales (LCY)'";
            OptionCaptionML = DEU ='Absatz,Umsatz';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "lbt Contract", "lbt Line No.")
        {
            Clustered = true;
        }
    }


}