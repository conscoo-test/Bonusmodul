page 5266055 "lbt Bonus Contract Dimension"
{
    Caption = 'Bonus Contract Dimensions', comment = 'DEU="Bonusvertrag Dimensionen"';
    PageType = List;
    SourceTable = "lbt Bonus Contract Dimensions";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                Caption = 'General', comment = 'DEU="Allgemein"';
                field("lbt Dimension Code"; "lbt Dimension Code")
                {
                    ToolTip = 'You can define default dimensions for the provision for each contract.', comment = 'DEU=" Je Vertrag können Vorgabedimensionen für die Rückstellung hinterlegt werden. "';
                    ApplicationArea = All;
                }
                field("lbt Dimension Value"; "lbt Dimension Value")
                {
                    ToolTip = 'Here you can define the departments or the Value of the dimensions.', comment = 'DEU="Hier können Sie den Wert der Dimension oder Abteilung angeben."';
                    ApplicationArea = All;
                }
            }
        }
    }

}
