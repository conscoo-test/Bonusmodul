table 5266051 "lbtbn Bonus Setup"
{
    DataClassification = ToBeClassified;
    Caption = 'Bonus Setup';
    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }

        field(2; "Reserve Mode"; Option)
        {
            Caption = 'Reserve Mode';
            DataClassification = CustomerContent;
            OptionMembers = Journal,CreditMemo;
            OptionCaption = 'Journal,CreditMemo';
        }
        field(3; "Gen.Jnl.Templ.BonusReserve"; Code[10])
        {
            Caption = 'Gen. Jnl. Templ. Bonus Reserve';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Journal Template";
            #region OnLookup
            trigger OnLookup()
            var
                GenJournalTemplate: Record "Gen. Journal Template";
                GeneralJournalTemplates: Page "General Journal Templates";

            begin
                GeneralJournalTemplates.LookupMode(true);
                if GeneralJournalTemplates.RunModal() = Action::LookupOK then begin
                    GeneralJournalTemplates.GetRecord(GenJournalTemplate);
                    "Gen.Jnl.Templ.BonusReserve" := GenJournalTemplate.Name;
                end;
            end;
            #endregion OnLookup
        }

        field(4; "Gen. Jnl. Bonus Reserve"; Code[10])
        {
            Caption = 'Gen. Jnl. Bonus Reserve';
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Gen.Jnl.Templ.BonusReserve"));
            DataClassification = CustomerContent;
        }
        field(5; "Revers Reserve Mode"; Option)
        {
            Caption = 'Revers Reserve Mode';
            DataClassification = CustomerContent;
            OptionMembers = automatic,"Journal Batch";
            OptionCaption = 'automatic,Journal Batch';
        }
        field(6; GenJnlBonusReversReserve; Code[20])
        {
            Caption = ' Gen. Jnl. Bonus Revers Reserve';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Gen.Jnl.Templ.BonusReserve"));
        }
        field(7; "Cust Gr. Reserve Cr. Memo"; Code[20])
        {
            Caption = 'Cust Gr. Reserve Cr. Memo';
            DataClassification = CustomerContent;
            TableRelation = "Customer Posting Group".Code;
        }

        field(8; "Bus.Post.Gr.f.Res.Cr.Memo"; Code[20])
        {
            Caption = 'Bus. Post. Group for Reserve Credit Memo';

            DataClassification = CustomerContent;
            TableRelation = "Gen. Business Posting Group".Code;
        }

        field(9; "Bonus Contract Nos."; Code[20])
        {
            Caption = 'Bonus Contract Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }

        field(10; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Reason Code";
        }

        // field(11; "Customer Reserve Cr.Memo"; Code[20])
        // {
        //     Caption = 'Customer Reserve Cr.Memo';
        //     DataClassification = CustomerContent;
        //     TableRelation = Customer;
        // }

        field(12; "Reserve Cr.Memo Nos."; Code[20])
        {
            Caption = 'Reserve Cr.Memo Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(13; "Billing Cr.Memo Nos."; Code[20])
        {
            Caption = 'Billing Cr.Memo Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    #region OnInsert
    trigger OnInsert()
    begin
        "Primary Key" := '1';
    end;
    #endregion OnInsert



}