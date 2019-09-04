page 5266055 "lbt Bonus Contract Dimension"
{
    Caption = 'Bonus Contract Dimensions', comment = 'DEU="Bonusvertrag Dimensionen"';
    PageType = List;
    SourceTable = "lbt Bonus Contract Dimensions";
    UsageCategory=None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                Caption = 'General', comment = 'DEU="Allgemein"';
                field("lbt Dimension Code"; "lbt Dimension Code")
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }
                field("lbt Dimension Value"; "lbt Dimension Value")
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }
            }
        }
    }

}
