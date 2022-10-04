page 5266061 "lbtbn Explode Reservation"
{
    Caption = 'Explode Reservation';
    UsageCategory = None;
    PageType = Worksheet;
    SourceTable = "G/L Entry";

    layout
    {
        area(content)
        {
            field("lbtbn Posting Date"; Rec."Posting Date")
            {
                ToolTip = 'This date field refers to the posting date of the respective reserve items.';
                ApplicationArea = All;

            }
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'If the bonus items are posted with the item type Reserves and Reserve reversal, this field is linked to the serial number of the corresponding G/L item.';
                    ApplicationArea = All;
                }
                field("G/L Account No."; Rec."G/L Account No.")
                {
                    ToolTip = 'Here you can select the corresponding G/L account.';
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'This date field refers to the posting date of the respective reserve.';
                    ApplicationArea = All;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Here you can select the document type.';
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Here you can select the document number that refers to the document date.';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Here you can enter a description of the reserve.';
                    ApplicationArea = All;
                }
                field("Bal. Account No."; Rec."Bal. Account No.")
                {
                    ToolTip = 'Here you can select the corresponding offset account.';
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Indicates the amount of the reserve.';
                    ApplicationArea = All;
                }
                field("Source Code"; Rec."Source Code")
                {
                    ToolTip = 'Here you can select the origin code.';
                    ApplicationArea = All;
                }
            }
        }
    }

}
