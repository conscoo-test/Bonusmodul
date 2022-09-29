page 5266054 "lbtbn Bonus Contract Line"
{
    Caption = 'Bonus Contract Line';
    PageType = ListPart;
    SourceTable = "lbtbn Bonus Contract Line";
    AutoSplitKey = true;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                Caption = 'General';
                field("Bonus Scale Type"; Rec."Bonus Scale Type")
                {
                    ToolTip = 'Indicates whether the rebate calculation is based on sales or turnover.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Item Unit of Measure"; Rec."Item Unit of Measure")
                {
                    ToolTip = 'Specifies the unit of the article.';
                    ApplicationArea = All;
                }
                field("From Quantity"; Rec."From Quantity")
                {
                    ToolTip = 'For each contract, you define a staggering of the bonus amount depending on the sales volume or the sales quantity.';
                    ApplicationArea = All;
                }
                field(Value; Rec."Value")
                {
                    ToolTip = 'The value of the scale is used for bonus calculation depending on the value unit of the contract.';
                    ApplicationArea = All;
                }
            }
        }
    }
}
