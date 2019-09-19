page 5266054 "lbt Bonus Contract Line"
{
    Caption = 'Bonus Contract Line', comment = 'DEU="Bonusstaffeln"';
    PageType = CardPart;
    SourceTable = "lbt Bonus Contract Line";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                Caption = 'General', comment = 'DEU="Allgemein"';
                
                /* 
                field("lbt Contract"; "lbt Contract")
                {
                    ApplicationArea = All;
                }
                field("lbt Line No."; "lbt Line No.")
                {
                    ApplicationArea = All;
                } */
                field("lbt Bonus Scale Type"; "lbt Bonus Scale Type")
                {
                    ToolTip = 'Indicates whether the rebate calculation is based on sales or turnover.', comment = 'DEU="Gibt an, ob die Bonusberechnung auf Grundlage des Absatzes oder des Umsatzes erfolgt."';
                    ApplicationArea = All;
                }
                field("lbt Item Unit of Measure"; "lbt Item Unit of Measure")
                {
                    ToolTip = 'Specifies the unit of the article.', comment = 'DEU="Gibt an, welche Einheit der Artikel hat."';
                    ApplicationArea = All;
                    Visible= UoMVsbl;
                }
                field("lbt From Quantity"; "lbt From Quantity")
                {
                    ToolTip = 'For each contract, you define a staggering of the bonus amount depending on the sales volume or the sales quantity.', comment = 'DEU="Je Vertrag wird eine Staffelung des Bonusbetrags in Abhängigkeit des Umsatzes oder der Absatzmenge hinterlegt."';
                    ApplicationArea = All;

                }

                field("lbt Value"; "lbt Value")
                {
                    ToolTip = 'The value of the scale is used for bonus calculation depending on the value unit of the contract.', comment = 'DEU="Der Wert der Staffel wird in Abhängigkeit von der Werteinheit des Vertrages für die Bonusberechnung verwendet."';
                    ApplicationArea = All;
                }


            }
        }
    }


    trigger OnNewRecord(BelowxRec: Boolean)

    begin
        IF BonusContractRec.GET("lbt Contract") THEN
            "lbt Bonus Scale Type" := BonusContractRec."lbt Bonus Scale Type"
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        IF "lbt Bonus Scale Type" = "lbt Bonus Scale Type"::"Sales Qty." THEN
            IF "lbt Item Unit of Measure" = '' THEN
                EXIT(FALSE);
    end;

    trigger OnAfterGetCurrRecord()

    begin
        UoMVsbl := ("lbt Bonus Scale Type" = "lbt Bonus Scale Type"::"Sales Qty.");
    end;

    local procedure PageUpdate(VAR ContractNo: Code[20])

    var
        BonusContractLRec: Record "lbt Bonus Contract Line";
    begin
        IF BonusContractLRec.GET(ContractNo) THEN
            UoMVsbl := (BonusContractLRec."lbt Bonus Scale Type" = BonusContractLRec."lbt Bonus Scale Type"::"Sales Qty.");
        CurrPage.UPDATE();
    end;

    var
        BonusContractRec: Record "lbt Bonus Contract";
        UoMVsbl: Boolean;

}
