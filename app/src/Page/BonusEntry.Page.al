page 5266057 "lbtbn Bonus Entry"
{
    PageType = List;
    SourceTable = "lbtbn Bonus Entry";
    Caption = 'Bonus Entry';
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'This field identifies the bonus item with a unique, sequential number.';
                    ApplicationArea = All;
                }
                field(Contract; Rec."Contract")
                {
                    ToolTip = 'This field is filled with the contract number of the bonus agreement.';
                    ApplicationArea = All;
                }
                field("Process No."; Rec."Process No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the process no.';
                }
                field("Bonus Contract Line"; Rec."Bonus Contract Line")
                {
                    ToolTip = 'The bonus contract line of the respective contract is written to the bonus items.';
                    ApplicationArea = All;
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ToolTip = 'This field defines the type of item using the following options:reserverelease, reservebonus, items';
                    ApplicationArea = All;
                }
                field(Customer; Rec."Customer")
                {
                    ToolTip = 'This field is filled with the customer from the bonus contract.';
                    ApplicationArea = All;
                }
                field("Ship-to Code"; Rec."Ship-to Code")
                {
                    ToolTip = 'This field is filled with the delivery contact from the bonus contract.';
                    ApplicationArea = All;
                }
                field("Entry Date"; Rec."Entry Date")
                {
                    ToolTip = 'This date field refers to the posting date of the respective G/L items.';
                    ApplicationArea = All;
                }
                field("Sales Quantity"; Rec."Sales Quantity")
                {
                    ToolTip = 'The quantity of the individual document line of the settlement credit memo is entered here.';
                    ApplicationArea = All;
                }
                field("Base Amount"; Rec."Base Amount")
                {
                    ToolTip = 'The base amount of the source document is entered in this field.';
                    ApplicationArea = All;
                }
                field("Calculated Amount"; Rec."Calculated Amount")
                {
                    ToolTip = 'This field displays the amount based on the calculated reserves and bonus runs. Since value changes can be made in the reserve ledger sheet or bonus credit memo after the reserve or bonus has been created, the calculated amount does not have to be identical to the actual posted amount.';
                    ApplicationArea = All;
                }
                field("calc. Amount incl. VAT"; Rec."calc. Amount incl. VAT")
                {
                    ToolTip = 'In this field, the calculated amount including VAT is entered if the invoice recipient is liable for VAT on the basis of his master data facility.';
                    ApplicationArea = All;
                }
                field("Posted Amount"; Rec."Posted Amount")
                {
                    ToolTip = 'This field is not filled with a value until the corresponding bonus credit memo or reserve ledger sheet has been posted.';
                    ApplicationArea = All;
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ToolTip = 'This field contains the calculated discount.';
                    ApplicationArea = All;
                }
                field("Pmt. Discount Amount"; Rec."Pmt. Discount Amount")
                {
                    ToolTip = 'This field contains the calculated cash discount.';
                    ApplicationArea = All;
                }
                field("From Document Type"; Rec."From Document Type")
                {
                    ToolTip = 'If it is a bonus item with the item type "Bonus", the document type "Sales credit memo" is stored in this field.';
                    ApplicationArea = All;
                }
                field("From Document No."; Rec."From Document No.")
                {
                    ToolTip = 'If it is a bonus item with the item type Bonus, the document number of the bonus credit memo is entered in this field.';
                    ApplicationArea = All;
                }
                field("From Document Line"; Rec."From Document Line")
                {
                    ToolTip = 'You can use the Document line field to identify the credit line in which this bonus item is located in the bonus credit memo.';
                    ApplicationArea = All;
                }
                field("Bonus Document Type"; Rec."Bonus Document Type")
                {
                    ToolTip = 'If it is a bonus item with the item type "Bonus", the document type "Sales credit memo" is stored in this field. ';
                    ApplicationArea = All;
                }
                field("Bonus Document No."; Rec."Bonus Document No.")
                {
                    ToolTip = 'If it is a bonus item with the item type Bonus, the bonus document number is entered in this field.';
                    ApplicationArea = All;
                }
                field("Bonus Document Line"; Rec."Bonus Document Line")
                {
                    ToolTip = 'You can use the bonus document lines field to identify the credit line in which this bonus item is located in the bonus credit memo.';
                    ApplicationArea = All;
                }
                field("Assignment Document Type"; Rec."Assignment Document Type")
                {
                    ToolTip = 'The assignment document type is stored in this field.';
                    ApplicationArea = All;
                }
                field("Assignment Document No."; Rec."Assignment Document No.")
                {
                    ToolTip = 'If the bonus item has the item type Bonus, the assignment document number of the bonus credit memo is entered in this field.';
                    ApplicationArea = All;
                }
                field("Assignment Doc. Line No."; Rec."Assignment Doc. Line No.")
                {
                    ToolTip = 'You can use the Assignment document line number field to identify in which credit memo line this rebate item is located in the rebate credit memo.';
                    ApplicationArea = All;
                }
                field("General Ledger Entry No."; Rec."General Ledger Entry No.")
                {
                    ToolTip = 'Used to identify posted G/L items as bonus or reserve. ';
                    ApplicationArea = All;
                }
                field("Invoice Customer No."; Rec."Invoice Customer No.")
                {
                    ToolTip = 'This field is filled with the invoice recipient of the bonus agreement.  An alternative customer can also be defined as the bill-to party.';
                    ApplicationArea = All;
                }
            }
        }
    }
}
