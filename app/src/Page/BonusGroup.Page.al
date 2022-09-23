page 5266058 "lbt Bonus Group"
{
    PageType = List;
    SourceTable = "lbt Bonus Group";
    Caption = 'Bonus Group';
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Here you can group bonus contracts by code.';
                    ApplicationArea = All;
                }
                field(Description; Rec."Description")
                {
                    ToolTip = 'Here you can enter a description of the group.';
                    ApplicationArea = All;
                }
            }
        }
    }

}
