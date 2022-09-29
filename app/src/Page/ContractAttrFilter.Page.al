page 5266056 "lbtbn Contract Attr. Filter"
{

    PageType = List;
    SourceTable = "lbtbn BonusContractAttribute";
    Caption = 'Bonus Contract Attribute Filter';
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                Caption = 'General';
                field("Attribute ID"; Rec."Attribute ID")
                {
                    ToolTip = 'Specifies which attributes the article has.';
                    ApplicationArea = All;
                }
                field("Attribute Name"; Rec."Attribute Name")
                {
                    ToolTip = 'Specifies the Name of the article.This field will be filled automatically, if a attribute ID is defined.';
                    ApplicationArea = All;
                }
                field("Attribute Type"; Rec."Attribute Type")
                {
                    ToolTip = 'Specifies the type of attribute value.This field will be filled automatically, if a attribute ID is defined.';
                    ApplicationArea = All;
                }
                field("Attribute Value ID"; Rec."Attribute Value ID")
                {
                    ToolTip = 'Specifies the item attribute value.';
                    ApplicationArea = All;
                }
                field("Attribute Value Name"; Rec."Attribute Value Name")
                {
                    ToolTip = 'Indicates which attribute is involved. This field will be filled automatically, if a attribute Value ID is defined.';
                    ApplicationArea = All;
                }

            }
        }
    }

}
