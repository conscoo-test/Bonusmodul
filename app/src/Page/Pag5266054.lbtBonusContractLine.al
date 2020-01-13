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
                field(Contract; "Contract")
                {
                    ApplicationArea = All;
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                } */
                field("Bonus Scale Type"; "Bonus Scale Type")
                {
                    ToolTip = 'Indicates whether the rebate calculation is based on sales or turnover.', comment = 'DEU="Gibt an, ob die Bonusberechnung auf Grundlage des Absatzes oder des Umsatzes erfolgt."';
                    ApplicationArea = All;
                }
                field("Item Unit of Measure"; "Item Unit of Measure")
                {
                    ToolTip = 'Specifies the unit of the article.', comment = 'DEU="Gibt an, welche Einheit der Artikel hat."';
                    ApplicationArea = All;
                    Visible = UoMVsbl;
                }
                field("From Quantity"; "From Quantity")
                {
                    ToolTip = 'For each contract, you define a staggering of the bonus amount depending on the sales volume or the sales quantity.', comment = 'DEU="Je Vertrag wird eine Staffelung des Bonusbetrags in Abhängigkeit des Umsatzes oder der Absatzmenge hinterlegt."';
                    ApplicationArea = All;

                }

                field(Value; "Value")
                {
                    ToolTip = 'The value of the scale is used for bonus calculation depending on the value unit of the contract.', comment = 'DEU="Der Wert der Staffel wird in Abhängigkeit von der Werteinheit des Vertrages für die Bonusberechnung verwendet."';
                    ApplicationArea = All;
                }


            }
        }
    }


    trigger OnNewRecord(BelowxRec: Boolean)

    begin
        IF BonusContractRec.GET("Contract") THEN
            "Bonus Scale Type" := BonusContractRec."Bonus Scale Type"
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        IF "Bonus Scale Type" = "Bonus Scale Type"::"Sales Qty." THEN
            IF "Item Unit of Measure" = '' THEN
                EXIT(FALSE);
    end;

    trigger OnAfterGetCurrRecord()

    begin
        UoMVsbl := ("Bonus Scale Type" = "Bonus Scale Type"::"Sales Qty.");
    end;

    local procedure PageUpdate(VAR ContractNo: Code[20])

    var
        BonusContractLRec: Record "lbt Bonus Contract Line";
    begin
        IF BonusContractLRec.GET(ContractNo) THEN
            UoMVsbl := (BonusContractLRec."Bonus Scale Type" = BonusContractLRec."Bonus Scale Type"::"Sales Qty.");
        CurrPage.UPDATE();
    end;

    var
        BonusContractRec: Record "lbt Bonus Contract";
        UoMVsbl: Boolean;

}
