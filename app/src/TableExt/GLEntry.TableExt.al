tableextension 5266061 "lbtbn GLEntry" extends "G/L Entry" //17
{
    fields
    {
        field(5266051; "lbtbn Bonus Entry No"; Integer)
        {
            Caption = 'Bonus Entry No.';
            DataClassification = CustomerContent;
        }
        field(5266052; "lbtbn In Reserve"; Boolean)
        {
            Caption = 'In Reserve';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = exist("Gen. Journal Line" where("lbtbn Reserve Entry No" = field("Entry No.")));
        }

    }

    keys
    {
        key("lbtbn Key1"; "Transaction No.", "G/L Account No.", "Document No.") { }
    }

}