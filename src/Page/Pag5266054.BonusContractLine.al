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
                field("lbt Contract"; "lbt Contract")
                {
                    ApplicationArea = All;
                }
                field("lbt Line No."; "lbt Line No.")
                {

                    ApplicationArea = All;


                }
                field("lbt Bonus Scale Type";"lbt Bonus Scale Type")
                {
                    ApplicationArea = All;
                }
                field("lbt Item Unit of Measure"; "lbt Item Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field("lbt From Quantity"; "lbt From Quantity")
                {
                    ApplicationArea = All;
                }

                field("lbt Value"; "lbt Value")
                {
                    ApplicationArea = All;
                }


            }
        }
    }

}
