table 5266051 "lbt Bonus Setup"
{
    DataClassification = ToBeClassified;
    Caption = 'Bonus Setup', comment = 'DEU="Bonus Einrichtung"';
    fields
    {
        field(1; "lbt Primary Key"; code[10])
        {
            Caption = 'Primary Key', comment = 'DEU="Primärschlüssel"';
            DataClassification = CustomerContent;
        }

        field(2; "lbt Reserve Mode"; Option)
        {
            Caption = 'Reserve Mode', comment = 'DEU="Rückstellungsmodus"';
            DataClassification = CustomerContent;
            OptionMembers = "Journal","CreditMemo";
            OptionCaption = 'Journal,CreditMemo', comment = 'DEU="Buchblatt,Gutschrift"';
        }
        field(3; "lbt Gen.Jnl.Templ.BonusReserve"; Code[20])
        {
            Caption = 'Gen. Jnl. Templ. Bonus Reserve', comment = 'DEU="BuchblVorl. Bonusrückstellung"';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Journal Template";

        }

        field(4; "lbt Gen. Jnl. Bonus Reserve"; Code[20])
        {
            Caption = 'Gen. Jnl. Bonus Reserve', comment = 'DEU="Buchblatt Bonusrückstellung"';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Journal Batch";
        }
        field(5; "lbt Revers Reserve Mode"; Option)
        {
            Caption = 'Revers Reserve Mode', Comment = 'DEU="Rückstellungsauflösung Modus"';
            DataClassification = CustomerContent;
            OptionMembers = automatic,"Journal Batch";
            OptionCaption = 'automatic,Journal Batch', Comment = 'DEU="automatisch,Buchblatt"';
        }
        field(6; "lbt GenJnlBonusReversReserve"; Code[20])
        {
            Caption = ' Gen. Jnl. Bonus Revers Reserve', Comment = 'DEU="Buchblatt Bonusrückstellungsauflösung"';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("lbt Gen.Jnl.Templ.BonusReserve"));
        }
        field(7; "lbt Cust Gr. Reserve Cr. Memo"; Code[20])
        {
            Caption = 'Cust Gr. Reserve Cr. Memo', comment = 'DEU="Debitor-Buch.gr. für Rückstell-Gutschr."';
            DataClassification = CustomerContent;
            TableRelation = "Customer Posting Group".Code;
        }

        field(8; "lbt Bus.Post.Gr.f.Res.Cr.Memo"; Code[20])
        {
            Caption = 'Bus. Post. Group for Reserve Credit Memo', comment = 'DEU="Gesch.bu.gr. f. Rückstell-Gutschrift"';

            DataClassification = CustomerContent;
            TableRelation = "Gen. Business Posting Group".Code;
        }
        field(100; Complete; Boolean)
        {
            DataClassification = CustomerContent;
        }



        field(9; "Bonus Nos."; Code[50])
        {
            Caption = 'Bonus Nos.', comment = 'DEU="Bonusnummern"';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }



    }

    keys
    {
        key(PK; "lbt Primary Key")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        "lbt Primary Key" := '1';
    end;



}