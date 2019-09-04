page 5266056 "lbt BonusContrAttributeFilter"
{
    
    PageType = List;
    SourceTable = "lbt BonusContractAttribute";
    Caption = 'Bonus Contract Attribute Filter', comment = 'DEU="Bonusvertrag Attribute Filter"';
    UsageCategory = None;
    
    layout
    {
        area(content)
        {
            repeater(General)
            {
                Caption = 'General', comment = 'DEU="Allgemein"';
                field("lbt Attribute ID";"lbt Attribute ID")
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }
                field("lbt Attribute Name";"lbt Attribute Name")
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }
                field("lbt Attribute Type";"lbt Attribute Type")
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }
                field("lbt Attribute Value ID";"lbt Attribute Value ID")
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }
                field("lbt Attribute Value Name";"lbt Attribute Value Name")
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }

            }
        }
    }
    
}
