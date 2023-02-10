table 5266052 "lbtbn Bonus Contract"
{
    DataClassification = CustomerContent;
    Caption = 'Bonus Contract';
    LookupPageId = "lbtbn Bonus Contracts";
    DrillDownPageId = "lbtbn Bonus Contracts";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            #region OnValidate
            trigger OnValidate()
            begin
                TestNoSeries();
            end;
            #endregion OnValidate
        }
        field(2; "Valid from"; Date)
        {
            Caption = 'Valid from';
        }
        field(3; "Valid to"; Date)
        {
            Caption = 'Valid to';
        }
        field(4; "Billing Period"; DateFormula)
        {
            Caption = 'Billing Period';
        }
        field(5; "Reserve Value"; Decimal)
        {
            Caption = 'Reserve Value';
        }
        field(6; "Reserve Type"; Enum "lbtbn Billing Type")
        {
            Caption = 'Reverse Type';

            #region OnValidate
            trigger OnValidate()
            begin
                if "Reserve Type" <> "Reserve Type"::"%" then begin
                    "Pmt. Discount %" := 0;
                    "Discount %" := 0;
                end;
            end;
            #endregion OnValidate
        }
        field(7; "Reserve Unit"; Code[10])
        {
            Caption = 'Reserve Unit';
            TableRelation = "Unit of Measure".Code;
        }
        field(8; "Last Reserve at"; Date)
        {
            Caption = 'Last Reserve at';
        }
        field(9; "Bonus Billing Type"; Enum "lbtbn Billing Type")
        {
            Caption = 'Bonus Billing Type';

            #region OnValidate
            trigger OnValidate()
            begin
                if "Bonus Billing Type" <> "Bonus Billing Type"::"%" then begin
                    "Pmt. Discount %" := 0;
                    "Discount %" := 0;
                end;
            end;
            #endregion OnValidate
        }
        field(10; "Bonus Billing Unit"; Code[10])
        {
            Caption = 'Bonus Billing Unit';
            TableRelation = "Unit of Measure".Code;
        }
        field(11; "Last Billing at"; Date)
        {
            Caption = 'Last Billing at';

            #region OnValidate
            trigger OnValidate()
            var
                SalesHeaderRec: Record "Sales Header";
            begin
                if ("Last Billing at" < xRec."Last Billing at") or ("Last Billing at" = 0D) then
                    SalesHeaderRec.Reset();
                SalesHeaderRec.SetCurrentKey("Document Type", "Sell-to Customer No.", "Salesperson Code",
                                             "Shortcut Dimension 1 Code", "Document Date");
                SalesHeaderRec.SetRange("Document Type", SalesHeaderRec."Document Type"::"Credit Memo");
                SalesHeaderRec.SetRange("Sell-to Customer No.", "Bonus Recipient");
                SalesHeaderRec.SetRange("Posting Description", 'Bonusgutschrift');
                if not SalesHeaderRec.IsEmpty() then
                    Error(Text001Msg);
            end;
            #endregion OnValidate
        }
        field(12; "Bonus Scale Type"; Option)
        {
            Caption = 'Bonus Scale Type';
            OptionMembers = "Sales Qty.","Sales (LCY)";
            OptionCaption = 'Sales Qty.,Sales (LCY)';

            #region OnValidate
            trigger OnValidate()
            var
                BonusEntry: Record "lbtbn Bonus Entry";
                BonusContractLineRec: Record "lbtbn Bonus Contract Line";

            begin
                if "Bonus Scale Type" <> xRec."Bonus Scale Type" then
                    BonusEntry.SetRange(Contract, "No.");
                if not BonusEntry.IsEmpty() then
                    Error(Text005Msg);
                BonusContractLineRec.SetRange(Contract, "No.");

                if not BonusContractLineRec.IsEmpty() then
                    Error(Text004Msg);

                if "Bonus Scale Type" = "Bonus Scale Type"::"Sales (LCY)" then
                    if "Bonus Billing Type" <> "Bonus Billing Type"::"%" then
                        FieldError("Bonus Billing Type");
            end;
            #endregion OnValidate
        }
        field(13; "Bonus Recipient"; Code[20])
        {
            Caption = 'Bonus Recipient';
            TableRelation = Customer."No.";
        }
        field(16; "No. of Customers"; Integer)
        {
            Caption = 'No. of Customers';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("lbtbn Bonus Customer" where(Contract = field("No.")));
        }
        field(17; "Balance of Bonus"; Decimal)
        {
            Caption = 'Balance of Bonus';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("lbtbn Bonus Entry"."Posted Amount" where(Contract = field("No."), "Entry Type" = const(Bonus)));
        }
        field(18; "Balance of Reserve"; Decimal)
        {
            Caption = 'Balance of Reserve';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("lbtbn Bonus Entry"."Posted Amount" where(Contract = field("No."), "Entry Type" = const(Reserve)));
        }
        field(19; "Balance of Liquid Reserves"; Decimal)
        {
            Caption = 'Balance of Liquidation Reserve';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("lbtbn Bonus Entry"."Posted Amount" where(Contract = field("No."), "Entry Type" = const("Liquidation of Reserves")));
        }
        field(21; "No. of Attribute"; Integer)
        {
            Caption = 'No. of Attribute';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("lbtbn BonusContractAttribute" where(Contract = field("No.")));
        }
        field(22; "Reserve Item Charge"; Code[20])
        {
            Caption = 'Reserve Item Charge';
            TableRelation = "Item Charge"."No.";
        }
        field(23; "Accounting Item Charge"; Code[20])
        {
            Caption = 'Accounting Item Charge';
            TableRelation = "Item Charge"."No.";
        }
        field(24; "Pmt. Discount %"; Decimal)
        {
            Caption = 'Payment Discount %';
        }
        field(25; "Discount %"; Decimal)
        {
            Caption = 'Discount %';
        }
        field(5266500; "Process No."; Code[20])
        {
            Caption = 'Process No.';
            TableRelation = "lbt Process";
        }
        field(27; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(28; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
            Editable = false;
        }
        field(29; "Customer Reserve Cr.Memo"; Code[20])
        {
            Caption = 'Customer Reserve Cr.Memo';
            TableRelation = Customer;
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    #region OnInsert
    trigger OnInsert()
    var
        BonusSetup: Record "lbtbn Bonus Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        if "No." = '' then begin
            BonusSetup.Get();
            BonusSetup.TestField("Bonus Contract Nos.");
            NoSeriesManagement.InitSeries(BonusSetup."Bonus Contract Nos.", xRec."No. Series", 0D, "No.", "No. Series");
        end;
        SetProcessNo();
    end;
    #endregion OnInsert

    #region OnDelete
    trigger OnDelete()
    var
        BonusCustomer: Record "lbtbn Bonus Customer";
        BonusEntry: Record "lbtbn Bonus Entry";
        BonusContractAttribute: Record "lbtbn BonusContractAttribute";
        BonusContractLineRec: Record "lbtbn Bonus Contract Line";

    begin
        if "No." <> '' then begin
            BonusEntry.SetRange(Contract, "No.");
            if not BonusEntry.IsEmpty() then
                Error(Text002Msg, "No.");
            BonusContractLineRec.SetRange(Contract, "No.");
            if not BonusContractLineRec.IsEmpty() then
                BonusContractLineRec.DeleteAll();
            BonusContractAttribute.SetRange(Contract, "No.");
            if not BonusContractAttribute.IsEmpty() then
                BonusContractAttribute.DeleteAll();
            BonusCustomer.SetRange(Contract, "No.");
            if not BonusCustomer.IsEmpty() then
                BonusCustomer.DeleteAll();
        end;
    end;
    #endregion OnDelete

    #region SetProcessNo
    local procedure SetProcessNo()
    var
        Process: Record "lbt Process";
    begin
        "Process No." := "No.";
        if not Process.Get("Process No.") then begin
            Process.Init();
            Process."No." := "Process No.";
            Process.Insert(true);
        end;
    end;
    #endregion SetProcessNo

    #region AssistEdit
    procedure AssistEdit(xBonusContract: Record "lbtbn Bonus Contract"): Boolean
    var
        BonusContract: Record "lbtbn Bonus Contract";
        BonusSetup: Record "lbtbn Bonus Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        BonusContract := Rec;
        BonusSetup.Get();
        BonusSetup.TestField("Bonus Contract Nos.");
        if NoSeriesManagement.SelectSeries(BonusSetup."Bonus Contract Nos.", xBonusContract."No. Series", "No. Series") then begin
            NoSeriesManagement.SetSeries("No.");
            Rec := BonusContract;
            // SetProcessNo();
            exit(true);
        end;
    end;
    #endregion AssistEdit

    #region TestNoSeries
    local procedure TestNoSeries()
    var
        BonusSetup: Record "lbtbn Bonus Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeTestNoSeries(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        if "No." <> xRec."No." then begin
            BonusSetup.Get();
            NoSeriesManagement.TestManual(BonusSetup."Bonus Contract Nos.");
            "No. Series" := '';
        end;
    end;
    #endregion TestNoSeries

    #region GetAccountNo
    local procedure GetAccountNo(var Customer: Record Customer; var GLAccounts: List of [Code[20]])
    var
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        if CustomerPostingGroup.Get(Customer."Customer Posting Group") then
            if not GLAccounts.Contains(CustomerPostingGroup."lbtbn Reserve Account") then
                GLAccounts.Add(CustomerPostingGroup."lbtbn Reserve Account");
    end;
    #endregion GetAccountNo

    #region GetAccountNos
    local procedure GetAccountNos(var BonusCustomer: Record "lbtbn Bonus Customer"; var GLAccounts: List of [Code[20]])
    var
        Customer: Record Customer;
    begin
        if BonusCustomer."Customer No." <> '' then
            if Customer.Get(BonusCustomer."Customer No.") then
                GetAccountNo(Customer, GLAccounts);
        if BonusCustomer."Customer Group" <> '' then begin
            Customer.SetRange("lbtbn Customer Group", BonusCustomer."Customer Group");
            if Customer.FindSet() then
                repeat
                    GetAccountNo(Customer, GLAccounts);
                until Customer.Next() = 0;
        end;
    end;
    #endregion GetAccountNos

    #region Navigate
    procedure Navigate()
    var
        NavigatePage: Page Navigate;
    begin
        NavigatePage.SetProcessNo(Rec."Process No.");
        NavigatePage.Run();
    end;
    #endregion Navigate

    #region GetGLAccountFilter
    procedure GetGLAccountFilter(): Text
    begin
        exit(Join(GetGLAccounts(), '|'))
    end;
    #endregion GetGLAccountFilter

    #region GetGLAccounts
    local procedure GetGLAccounts() GLAccounts: List of [Code[20]]
    var
        BonusCustomer: Record "lbtbn Bonus Customer";
    begin
        BonusCustomer.SetRange(Contract, Rec."No.");
        if BonusCustomer.FindSet() then
            repeat
                GetAccountNos(BonusCustomer, GLAccounts);
            until BonusCustomer.Next() = 0;
    end;
    #endregion GetGLAccounts

    #region Join
    local procedure Join(GLAccounts: List of [Code[20]]; Seperator: Text) Result: Text
    var
        GLAccount: Code[20];
    begin
        foreach GLAccount in GLAccounts do
            Result += GLAccount + Seperator;
        Result := Result.TrimEnd(Seperator);
    end;
    #endregion Join

    procedure SetCustomerView(var Customer: Record Customer)
    var
        BonusCustomer: Record "lbtbn Bonus Customer";
    begin
        BonusCustomer.SetRange(Contract, Rec."No.");
        if BonusCustomer.FindSet() then
            repeat
                if BonusCustomer."Customer Group" <> '' then begin
                    Customer.SetRange("lbtbn Customer Group", BonusCustomer."Customer Group");
                    if Customer.FindSet() then
                        repeat
                            Customer.Mark(true);
                        until Customer.Next() = 0;
                end;
                if BonusCustomer."Customer No." <> '' then begin
                    Customer.Get(BonusCustomer."Customer No.");
                    Customer.Mark(true);
                end;
            until BonusCustomer.Next() = 0;
        Customer.SetRange("lbtbn Customer Group");
        Customer.MarkedOnly(true);
    end;


    var
        Text001Msg: Label 'You can not reset the date, while there are unposted bonus credit memos.',
        Comment = 'DEU="Sie können das Datum nicht zurücksetzen, solange es ungebuchte Bonusgutschriften für diesen Kunden gibt"';

        Text002Msg: Label 'For contract %1 bonus contract entries exists. The contract can not be deleted.',
        Comment = 'DEU="Zum Vertrag %1 sind Bonusposten im System vorhanden. Der Bonusvertrag kann nicht gelöscht werden."';
        Text004Msg: Label 'You must delete Bonus Contract Lines before you modify the contract',
        Comment = 'DEU="Sie müssen die Vertragszeilen löschen, bevor Sie die Bonusart ändern."';

        Text005Msg: Label 'There are already Bonus Contract Entries. You cannot modify the contract.',
        Comment = 'DEU="Es existieren bereits Bonusposten. Der Vertrag kann nicht geändert werden."';

    #region OnBeforeTestNoSeries
    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestNoSeries(BonusContract: Record "lbtbn Bonus Contract"; xBonusContract: Record "lbtbn Bonus Contract"; var IsHandled: Boolean)
    begin
    end;
    #endregion OnBeforeTestNoSeries
}