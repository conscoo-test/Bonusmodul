page 5266059 "lbt Bonus Customers"
{
    
    PageType = List;
    SourceTable = "lbt Bonus Customers";
    Caption = 'Bonus Customers', comment = 'DEU="Bonus Debitoren"';
    UsageCategory = None;
    
    layout
    {
        area(content)
        {
            repeater(General)
            {
                
                field("lbt Customer";"lbt Customer")
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }
                field("lbt Ship-to Code";"lbt Ship-to Code")
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }
                field("lbt Customer Name";"lbt Customer Name")
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }
                field("lbt Ship-to Name";"lbt Ship-to Name")
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }
            }
        }
    }
    
}
