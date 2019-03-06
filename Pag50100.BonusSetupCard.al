page 50100 "lbt Bonus Setup Card"
{

    PageType = Card;
    SourceTable = "lbt Bonus Setup";
    Caption = 'lbt Bonus Setup Card';

    layout
    {
        area(content)
        {
            group("lbt General")
            {
                Caption = 'General', comment = 'dEU="Allgmein"';
                field("lbt Primary Key"; "lbt Primary Key")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
