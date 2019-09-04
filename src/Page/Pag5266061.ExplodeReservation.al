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
                ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                ApplicationArea = All;

            }
            repeater(General)
            {
                field("Entry No.";"Entry No.")
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }
                field("G/L Account No.";"G/L Account No.")
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }
                field("Posting Date";"Posting Date")
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }
                field("Document Type";"Document Type")
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }
                field("Document No.";"Document No.")
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }
                field(Description;Description)
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }
                field("Bal. Account No.";"Bal. Account No.")
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }
                field(Amount;Amount)
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }
                field("Source Code";"Source Code")
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }
            }
        }
    }
    
}
