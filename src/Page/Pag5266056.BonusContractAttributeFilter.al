page 5266056 "lbt BonusContrAttributeFilter"
{
    
    PageType = List;
    SourceTable = "lbt BonusContractAttribute";
    Caption = 'Bonus Contract Attribute Filter', comment = 'DEU="Bonusvertrag Attribute Filter"';
    UsageCategory = None;
    
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("lbt Contract";"lbt Contract")
                {
                    ApplicationArea = All;
                }
                field("lbt Attribute Name";"lbt Attribute Name")
                {
                    ApplicationArea = All;
                }
                field("lbt Attribute Type";"lbt Attribute Type")
                {
                    ApplicationArea = All;
                }
                field("lbt Attribute Value";"lbt Attribute Value")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    
}
