page 5266058 "lbt Bonus Group"
{
    PageType = List;
    SourceTable = "lbt Bonus Group";
    Caption = 'Bonus Group', comment = 'DEU="Bonusgruppe"';
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Here you can group bonus contracts by code.', comment = 'DEU="Hier können Sie Bonusverträge nach Codes gruppieren."';
                    ApplicationArea = All;
                }
                field(Description; Rec."Description")
                {
                    ToolTip = 'Here you can enter a description of the group.', comment = 'DEU="Hier können Sie eine Beschreibung der Gruppe hinterlegen."';
                    ApplicationArea = All;
                }
            }
        }
    }

}
