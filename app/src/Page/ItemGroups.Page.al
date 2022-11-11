page 5266066 "lbtbn Item Groups"
{

    PageType = List;
    SourceTable = "lbtbn Item Group";
    Caption = 'Item Bonus Groups';
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Used to uniquely identify the Item bonus group.';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Here you can type in the description of the Item bonus group.';
                    ApplicationArea = All;
                }
            }
        }
    }

}
