page 5266057 "lbtbn Bonus Entry"
{
    Caption = 'Bonus Entry';
    Editable = false;
    PageType = List;
    SourceTable = "lbtbn Bonus Entry";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'This field identifies the bonus item with a unique, sequential number.';
                }
                field(Contract; Rec.Contract)
                {
                    ApplicationArea = All;
                    ToolTip = 'This field is filled with the contract number of the bonus agreement.';
                }
                field("Process No."; Rec."Process No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the process no.';
                }
                field("Bonus Contract Line"; Rec."Bonus Contract Line")
                {
                    ApplicationArea = All;
                    ToolTip = 'The bonus contract line of the respective contract is written to the bonus items.';
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'This field defines the type of item using the following options:reserverelease, reservebonus, items';
                }
                field(Customer; Rec.Customer)
                {
                    ApplicationArea = All;
                    ToolTip = 'This field is filled with the customer from the bonus contract.';
                }
                field("Ship-to Code"; Rec."Ship-to Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'This field is filled with the delivery contact from the bonus contract.';
                }
                field("Entry Date"; Rec."Entry Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'This date field refers to the posting date of the respective G/L items.';
                }
                field("Sales Quantity"; Rec."Sales Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'The quantity of the individual document line of the settlement credit memo is entered here.';
                }
                field("Base Amount"; Rec."Base Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'The base amount of the source document is entered in this field.';
                }
                field("Calculated Amount"; Rec."Calculated Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'This field displays the amount based on the calculated reserves and bonus runs. Since value changes can be made in the reserve ledger sheet or bonus credit memo after the reserve or bonus has been created, the calculated amount does not have to be identical to the actual posted amount.';
                }
                field("calc. Amount incl. VAT"; Rec."calc. Amount incl. VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'In this field, the calculated amount including VAT is entered if the invoice recipient is liable for VAT on the basis of his master data facility.';
                }
                field("Posted Amount"; Rec."Posted Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'This field is not filled with a value until the corresponding bonus credit memo or reserve ledger sheet has been posted.';
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'This field contains the calculated discount.';
                }
                field("Pmt. Discount Amount"; Rec."Pmt. Discount Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'This field contains the calculated cash discount.';
                }
                field("From Document Type"; Rec."From Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'If it is a bonus item with the item type "Bonus", the document type "Sales credit memo" is stored in this field.';
                }
                field("From Document No."; Rec."From Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'If it is a bonus item with the item type Bonus, the document number of the bonus credit memo is entered in this field.';

                    trigger OnDrillDown()
                    begin
                        Rec.OpenSourceDocument();
                    end;
                }
                field("From Document Line"; Rec."From Document Line")
                {
                    ApplicationArea = All;
                    ToolTip = 'You can use the Document line field to identify the credit line in which this bonus item is located in the bonus credit memo.';
                }
                field("Bonus Document Type"; Rec."Bonus Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'If it is a bonus item with the item type "Bonus", the document type "Sales credit memo" is stored in this field. ';
                }
                field("Bonus Document No."; Rec."Bonus Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'If it is a bonus item with the item type Bonus, the bonus document number is entered in this field.';
                }
                field("Bonus Document Line"; Rec."Bonus Document Line")
                {
                    ApplicationArea = All;
                    ToolTip = 'You can use the bonus document lines field to identify the credit line in which this bonus item is located in the bonus credit memo.';
                }
                field("Assignment Document Type"; Rec."Assignment Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'The assignment document type is stored in this field.';
                }
                field("Assignment Document No."; Rec."Assignment Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'If the bonus item has the item type Bonus, the assignment document number of the bonus credit memo is entered in this field.';
                }
                field("Assignment Doc. Line No."; Rec."Assignment Doc. Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'You can use the Assignment document line number field to identify in which credit memo line this rebate item is located in the rebate credit memo.';
                }
                field("General Ledger Entry No."; Rec."General Ledger Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Used to identify posted G/L items as bonus or reserve. ';
                }
                field("Invoice Customer No."; Rec."Invoice Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'This field is filled with the invoice recipient of the bonus agreement.  An alternative customer can also be defined as the bill-to party.';
                }
                field(Reversed; Rec.Reversed)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reversed field.';
                }
                field("Reversed by Entry No."; Rec."Reversed by Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reversed by Entry No. field.';
                }
                field("Bonus Document Deleted"; Rec."Bonus Document Deleted")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bonus Document Deleted field.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action("Source Document")
            {
                ApplicationArea = All;
                Caption = 'Source Document';
                Image = Document;

                trigger OnAction()
                begin
                    Rec.OpenSourceDocument();
                end;
            }
        }
    }
}
