page 5266057 "lbt Bonus Entry"
{

    PageType = List;
    SourceTable = "lbt Bonus Entry";
    Caption = 'Bonus Entry', comment = 'DEU="Bonusposten"';
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("lbt Entry No."; "lbt Entry No.")
                {
                    ApplicationArea = All;
                }
                field("lbt Contract"; "lbt Contract")
                {
                    ApplicationArea = All;
                }
                field("lbt Bonus Contract Line"; "lbt Bonus Contract Line")
                {
                    ApplicationArea = All;
                }
                field("lbt Entry Type"; "lbt Entry Type")
                {
                    ApplicationArea = All;
                }
                field("lbt Date"; "lbt Date")
                {
                    ApplicationArea = All;
                }
                field("lbt Amount"; "lbt Amount")
                {
                    ApplicationArea = All;
                }

                



            }
        }
    }

}
