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
        }
        field(2; "Entry Type"; Enum "lbtbn Bonus Entry Type")
        {
            Caption = 'Entry Type';
        }
        field(3; Contract; Code[20])
        {
            Caption = 'Contract';
            TableRelation = "lbtbn Bonus Contract"."No.";
        }
        field(4; "Bonus Contract Line"; Integer)
        {
            Caption = 'Bonus Contract Line';
            TableRelation = "lbtbn Bonus Contract Line" where(Contract = field(Contract));
        }
        field(5; "Entry Date"; Date)
        {
            Caption = 'Date';
        }
        field(6; "Base Amount"; Decimal)
        {
            Caption = 'Base Amount';
        }
        field(7; "General Ledger Entry No."; Integer)
        {
            Caption = 'General Ledger Entry No.';
            TableRelation = "G/L Entry";
        }
        field(8; "Posted Amount"; Decimal)
        {
            Caption = 'Posted Amount';
        }
        field(9; Customer; Code[20])
        {
            Caption = 'Customer';
            TableRelation = Customer;
        }
        field(10; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code';
            TableRelation = "Ship-to Address".Code where("Customer No." = field(Customer));
        }
        field(11; "Invoice Customer No."; Code[20])
        {
            Caption = 'Invoice Customer No.';
            TableRelation = Customer;
        }
        field(12; "Bonus Document Type"; Enum "lbtbn Document Type")
        {
            Caption = 'Bonus Document Type';
        }
        field(13; "Bonus Document No."; Code[20])
        {
            Caption = 'Bonus Document No.';
        }
        field(14; "Bonus Document Line"; Integer)
        {
            Caption = 'Bonus Document Line';
        }
        field(15; "From Document Type"; Enum "lbtbn Document Type")
        {
            Caption = 'From Document Type';
        }
        field(16; "From Document No."; Code[20])
        {
            Caption = 'From Document No.';
        }
        field(17; "From Document Line"; Integer)
        {
            Caption = 'From Document Line';
        }
        field(18; "Sales Quantity"; Decimal)
        {
            Caption = 'Sales Quantity';
        }
        field(19; "Calculated Amount"; Decimal)
        {
            Caption = 'Calculated Amount';
        }
        field(20; "calc. Amount incl. VAT"; Decimal)
        {
            Caption = 'calculated Amount incl. VAT';
        }
        field(21; "Pmt. Discount Amount"; Decimal)
        {
            Caption = 'Pmt. Discount Amount';
        }
        field(22; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
        }
        field(23; "Assignment Document Type"; Enum "lbtbn Bonus Ass. Document Type")
        {
            Caption = 'Assignment Document Type';
        }
        field(24; "Assignment Document No."; Code[20])
        {
            Caption = 'Assignment Document No.';
        }
        field(25; "Assignment Doc. Line No."; Integer)
        {
            Caption = 'Assignment Doc. Line No.';
        }
        field(5266500; "Process No."; Code[20]) // 
        {
            Caption = 'Process No.';
            TableRelation = "lbt Process";
        }
        field(27; Reversed; Boolean)
        {
            Caption = 'Reversed';
        }
        field(28; "Reversed by Entry No."; Integer)
        {
            Caption = 'Reversed by Entry No.';
            BlankZero = true;
            TableRelation = "lbtbn Bonus Entry";
        }
        field(29; "Bonus Document Deleted"; Boolean)
        {
            Caption = 'Bonus Document Deleted';
        }
        field(30; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID', comment = 'DEU="Dimensionssatz-ID"';
            TableRelation = "Dimension Set Entry";
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(key1; Contract, Customer, "Ship-to Code", "Entry Type", "Entry Date", Reversed) { }
    }

    trigger OnDelete()
    var
        DeleteErr: Label 'Bonus entries can''t be deleted when a General Ledger Entry No. is assigned.';
    begin
        if Rec."General Ledger Entry No." <> 0 then
            Error(DeleteErr);
    end;

    procedure OpenSourceDocument()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        PageManagement: Codeunit "Page Management";
    begin
        case Rec."From Document Type" of
            Rec."From Document Type"::"Sales Invoice":
                begin
                    SalesInvoiceHeader.Get(Rec."From Document No.");
                    PageManagement.PageRun(SalesInvoiceHeader);
                end;
            Rec."From Document Type"::"Sales Credit Memo":
                begin
                    SalesCrMemoHeader.Get(Rec."From Document No.");
                    PageManagement.PageRun(SalesCrMemoHeader);
                end;
        end;
    end;

    procedure ShowDimensions()
    var
        DimensionManagement: Codeunit DimensionManagement;
        "1_2_3_4_Lbl": Label '%1 %2 %3 %4', Locked = true;
        Caption: Text;
    begin
        Caption := StrSubstNo("1_2_3_4_Lbl", TableCaption, "From Document Type", "From Document No.", "From Document Line");
        DimensionManagement.ShowDimensionSet("Dimension Set ID", CopyStr(Caption, 1, 250));
    end;
}