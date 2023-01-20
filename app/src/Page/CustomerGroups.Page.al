page 5266064 "lbtbn Customer Groups"
{

    PageType = List;
    SourceTable = "lbtbn Customer Group";
    Caption = 'Customer Bonus Groups';
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
                    ToolTip = 'Used to uniquely identify the customer bonus group.';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Here you can type in the description of the customer bonus group.';
                    ApplicationArea = All;
                }
            }
        }
    }

}
