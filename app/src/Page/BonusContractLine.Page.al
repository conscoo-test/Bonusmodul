page 5266054 "lbt Bonus Contract Line"
{
    Caption = 'Bonus Contract Line', comment = 'DEU="Bonusstaffeln"';
    PageType = ListPart;
    SourceTable = "lbt Bonus Contract Line";
    AutoSplitKey = true;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                Caption = 'General', comment = 'DEU="Allgemein"';
                field("Bonus Scale Type"; Rec."Bonus Scale Type")
                {
                    ToolTip = 'Indicates whether the rebate calculation is based on sales or turnover.', comment = 'DEU="Gibt an, ob die Bonusberechnung auf Grundlage des Absatzes oder des Umsatzes erfolgt."';
                    ApplicationArea = All;
                }
                field("Item Unit of Measure"; Rec."Item Unit of Measure")
                {
                    ToolTip = 'Specifies the unit of the article.', comment = 'DEU="Gibt an, welche Einheit der Artikel hat."';
                    ApplicationArea = All;
                }
                field("From Quantity"; Rec."From Quantity")
                {
                    ToolTip = 'For each contract, you define a staggering of the bonus amount depending on the sales volume or the sales quantity.', comment = 'DEU="Je Vertrag wird eine Staffelung des Bonusbetrags in Abhängigkeit des Umsatzes oder der Absatzmenge hinterlegt."';
                    ApplicationArea = All;
                }
                field(Value; Rec."Value")
                {
                    ToolTip = 'The value of the scale is used for bonus calculation depending on the value unit of the contract.', comment = 'DEU="Der Wert der Staffel wird in Abhängigkeit von der Werteinheit des Vertrages für die Bonusberechnung verwendet."';
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if BonusContractRec.Get(Rec."Contract") then
            Rec."Bonus Scale Type" := BonusContractRec."Bonus Scale Type"
    end;

    var
        BonusContractRec: Record "lbt Bonus Contract";
}
