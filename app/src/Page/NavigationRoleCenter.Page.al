page 5266068 "lbtbn Navigation Role Center"
{
    PageType = RoleCenter;
    ApplicationArea = All;

    actions
    {
        area(Sections)
        {
            group(Tasks)
            {
                Caption = 'Tasks';
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
            group(Entries)
            {
                Caption = 'Entries';
                action("Bonus Entries")
                {
                    Caption = 'Bonus Entries';
                    RunObject = page "lbtbn Bonus Entry";
                }
            }
            group(Reports)
            {
                Caption = 'Reports';
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
            group(Setup)
            {
                Caption = 'Setup';

                action("Bonus Setup")
                {
                    Caption = 'LeBit Bonus Setup';
                    RunObject = page "lbtbn Bonus Setup";
                }
                action("Bonus Contracts")
                {
                    Caption = 'Bonus Contracts';
                    RunObject = page "lbtbn Bonus Contracts";
                }
                action("Item Charges")
                {
                    Caption = 'Item Charges';
                    RunObject = page "Item Charges";
                }
                action("Item Groups")
                {
                    Caption = 'Item Groups';
                    RunObject = page "lbtbn Item Groups";
                }
                action("Customer Groups")
                {
                    Caption = 'Customer Groups';
                    RunObject = page "lbtbn Customer Groups";
                }
            }
        }
    }
}