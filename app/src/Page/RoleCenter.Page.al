page 5266067 "lbtbn Role Center"
{
    PageType = RoleCenter;
    Caption = 'LeBit Bonus';
    ApplicationArea = All;

    actions
    {
        area(Processing)
        {
            action(Reserves)
            {
                Caption = 'Bonus Reserves';
                RunObject = report "lbtbn Bonus Reserves";
            }
            action("Run")
            {
                Caption = 'Bonus Run';
                RunObject = report "lbtbn Bonus Run";
            }
        }
        area(Reporting)
        {
            action(Reservation)
            {
                Caption = 'Bonus Reservation';
                RunObject = report "lbtbn Bonus Reservation";
            }
            action(Protocol)
            {
                Caption = 'Bonus Protocol';
                RunObject = report "lbtbn Bonus Protocol";
            }
        }
    }

}
