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
                Caption = 'General', comment = 'DEU="Allgemein"';
                field("lbt Attribute ID";"lbt Attribute ID")
                {
                    ToolTip = 'Specifies which attributes the article has.', comment = 'DEU="Gibt an, welche Attribute der Artikel besitzt."';
                    ApplicationArea = All;
                }
                field("lbt Attribute Name";"lbt Attribute Name")
                {
                    ToolTip = 'Specifies the Name of the article.This field will be filled automatically, if a attribute ID is defined.', comment = 'DEU="Gibt den Namen der Attribute an. Wird automatisch befüllt, sobald eine Attribute ID angegeben wird."';
                    ApplicationArea = All;
                }
                field("lbt Attribute Type";"lbt Attribute Type")
                {
                    ToolTip = 'Specifies the type of attribute value.This field will be filled automatically, if a attribute ID is defined.', comment = 'DEU="Gibt an, um welche Art von Attributwert es sich handelt.Wird automatisch befüllt, sobald eine Attribute ID angegeben wird."';
                    ApplicationArea = All;
                }
                field("lbt Attribute Value ID";"lbt Attribute Value ID")
                {
                    ToolTip = 'Specifies the item attribute value.', comment = 'DEU="Gibt den Artikelattributwert an."';
                    ApplicationArea = All;
                }
                field("lbt Attribute Value Name";"lbt Attribute Value Name")
                {
                    ToolTip = 'Indicates which attribute is involved. This field will be filled automatically, if a attribute Value ID is defined.', comment = 'DEU="Gibt an, um welches Attribut es sich handelt. Wird automatisch befüllt, sobald ein Attributwert angegeben wird."';
                    ApplicationArea = All;
                }

            }
        }
    }
    
}
