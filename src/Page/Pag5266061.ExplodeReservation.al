page 5266061 "lbt Explode Reservation"
{
    Caption = 'Explode Reservation', comment = 'DEU="Rückstellungen auflösen"';
    UsageCategory=None;
    PageType = Worksheet;
    SourceTable = "G/L Entry";
    
    layout
    {
        area(content)
        {
            field("lbt Posting Date"; "Posting Date")
            {
                ApplicationArea = All;

            }
            repeater(General)
            {
                field("Entry No.";"Entry No.")
                {
                    ApplicationArea = All;
                }
                field("G/L Account No.";"G/L Account No.")
                {
                    ApplicationArea = All;
                }
                field("Posting Date";"Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Document Type";"Document Type")
                {
                    ApplicationArea = All;
                }
                field("Document No.";"Document No.")
                {
                    ApplicationArea = All;
                }
                field(Description;Description)
                {
                    ApplicationArea = All;
                }
                field("Bal. Account No.";"Bal. Account No.")
                {
                    ApplicationArea = All;
                }
                field(Amount;Amount)
                {
                    ApplicationArea = All;
                }
                field("Source Code";"Source Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    
}
