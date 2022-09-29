table 5266056 "lbtbn Bonus Entry"
{
    Caption = 'Bonus Entry';
    DataClassification = CustomerContent;
    LookupPageId = "lbtbn Bonus Entry";
    DrillDownPageId = "lbtbn Bonus Entry";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            OptionMembers = Bonus,Reserve,"Liquidation of Reserves";
            OptionCaption = 'Bonus,Reserve,Liquidation of Reserves';
            DataClassification = CustomerContent;
        }
        field(3; Contract; Code[20])
        {
            Caption = 'Contract';
            DataClassification = CustomerContent;
            TableRelation = "lbtbn Bonus Contract"."No.";
        }
        field(4; "Bonus Contract Line"; Integer)
        {
            Caption = 'Bonus Contract Line';
            DataClassification = CustomerContent;
            TableRelation = "lbtbn Bonus Contract Line" where(Contract = field(Contract));
        }
        field(5; "Entry Date"; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }
        field(6; "Base Amount"; Decimal)
        {
            Caption = 'Base Amount';
            DataClassification = CustomerContent;
        }
        field(7; "General Ledger Entry No."; Integer)
        {
            Caption = 'General Ledger Entry No.';
            DataClassification = CustomerContent;
        }
        field(8; "Posted Amount"; Decimal)
        {
            Caption = 'Posted Amount';
            DataClassification = CustomerContent;
        }
        field(9; Customer; Code[20])
        {
            Caption = 'Customer';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(10; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code';
            DataClassification = CustomerContent;
            TableRelation = "Ship-to Address".Code where("Customer No." = field(Customer));
        }
        field(11; "Invoice Customer No."; Code[20])
        {
            Caption = 'Invoice Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(12; "Bonus Document Type"; Option)
        {
            Caption = 'Bonus Document Type';
            DataClassification = CustomerContent;
            OptionMembers = ,"Sales Invoice","Sales Credit Memo";
            OptionCaption = ',Sales Invoice,Sales Credit Memo';
        }
        field(13; "Bonus Document No."; Code[20])
        {
            Caption = 'Bonus Document No.';
            DataClassification = CustomerContent;
        }
        field(14; "Bonus Document Line"; Integer)
        {
            Caption = 'Bonus Document Line';
            DataClassification = CustomerContent;
        }
        field(15; "From Document Type"; Option)
        {
            Caption = 'From Document Type';
            DataClassification = CustomerContent;
            OptionMembers = ,"Sales Invoice","Sales Credit Memo";
            OptionCaption = ',Sales Invoice,Sales Credit Memo';
        }
        field(16; "From Document No."; Code[20])
        {
            Caption = 'From Document No.';
            DataClassification = CustomerContent;
        }
        field(17; "From Document Line"; Integer)
        {
            Caption = 'From Document Line';
            DataClassification = CustomerContent;
        }
        field(18; "Sales Quantity"; Decimal)
        {
            Caption = 'Sales Quantity';
            DataClassification = CustomerContent;
        }
        field(19; "Calculated Amount"; Decimal)
        {
            Caption = 'Calculated Amount';
            DataClassification = CustomerContent;
        }
        field(20; "calc. Amount incl. VAT"; Decimal)
        {
            Caption = 'calculated Amount incl. VAT';
            DataClassification = CustomerContent;
        }
        field(21; "Pmt. Discount Amount"; Decimal)
        {
            Caption = 'Pmt. Discount Amount';
            DataClassification = CustomerContent;
        }
        field(22; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            DataClassification = CustomerContent;
        }
        field(23; "Assignment Document Type"; Option)
        {
            Caption = 'Assignment Document Type';
            DataClassification = CustomerContent;
            OptionMembers = ,"Sales Shipment","Sales Return Receipt";
            OptionCaption = ' ,Sales Shipment,Sales Return Receipt';
        }
        field(24; "Assignment Document No."; Code[20])
        {
            Caption = 'Assignment Document No.';
            DataClassification = CustomerContent;
        }
        field(25; "Assignment Doc. Line No."; Integer)
        {
            Caption = 'Assignment Doc. Line No.';
            DataClassification = CustomerContent;
        }
        field(26; "Process No."; Code[20])
        {
            Caption = 'Process No.';
            DataClassification = CustomerContent;
            TableRelation = "lbt Process";
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        DeleteErr: Label 'Bonus entries can''t be deleted when a General Ledger Entry No. is assigned.';
    begin
        if Rec."General Ledger Entry No." <> 0 then
            Error(DeleteErr);
    end;
}