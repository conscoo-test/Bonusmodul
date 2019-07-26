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
                field("lbt Code";"lbt Code")
                {
                    ApplicationArea = All;
                }
                field("lbt Description";"lbt Description")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    
}
