page 5266064 "lbtbn Customer Groups"
{

    PageType = List;
    SourceTable = "lbtbn Customer Group";
    Caption = 'Customer Bonus Groups', Comment = 'DEU="Debitorenbonusgruppen"';
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
                    ToolTip = 'Used to uniquely identify the customer bonus group.', comment = 'DEU="Dient zur eindeutigen Identifikation der Debitorenbonusgruppe."';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Here you can type in the description of the customer bonus group.', comment = 'DEU="Hier kann die Bezeichnung der Debitorenbonusgruppe stehen."';
                    ApplicationArea = All;
                }
            }
        }
    }

}
