page 5266055 "lbtbn Bonus Contract Dimension"
{
    Caption = 'Bonus Contract Dimensions';
    PageType = List;
    SourceTable = "lbtbn Bonus Contract Dimension";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                Caption = 'General';
                field("Dimension Code"; Rec."Dimension Code")
                {
                    ToolTip = 'You can define default dimensions for the provision for each contract.';
                    ApplicationArea = All;
                }
                field("Dimension Value"; Rec."Dimension Value")
                {
                    ToolTip = 'Here you can define the departments or the Value of the dimensions.';
                    ApplicationArea = All;
                }
            }
        }
    }

}
