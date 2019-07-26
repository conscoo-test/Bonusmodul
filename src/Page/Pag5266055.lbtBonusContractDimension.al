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

                field("lbt Dimension Code"; "lbt Dimension Code")
                {
                    ApplicationArea = All;
                }
                field("lbt Dimension Value"; "lbt Dimension Value")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
