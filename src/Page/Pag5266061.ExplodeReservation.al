page 5266061 "lbt Explode Reservation"
{
    Caption = 'Explode Reservation', comment = 'DEU="Rückstellungen auflösen"';
    UsageCategory=None;
    PageType = Worksheet;
    SourceTable = "G/L Entry";
    
    layout
    {
        area(content)
        {
            field("lbt Posting Date"; "Posting Date")
            {
                ToolTip = 'This date field refers to the posting date of the respective reserve items.', comment = 'DEU="Dieses Datumsfeld bezieht sich auf das Buchungsdatum der jeweiligen Rückstellungen."';
                ApplicationArea = All;

            }
            repeater(General)
            {
                field("Entry No.";"Entry No.")
                {
                    ToolTip = 'If the bonus items are posted with the item type Reserves and Reserve reversal, this field is linked to the serial number of the corresponding G/L item.', comment = 'DEU="Werden die Bonusposten mit der Postenart ‚Rückstellung‘ und ‚Rückstellungsauflösung‘ gebucht, wird dieses Feld mit der Lfd.Nr. des zugehörigen Sachpostens verknüpft."';
                    ApplicationArea = All; 
                }
                field("G/L Account No.";"G/L Account No.")
                {
                    ToolTip = 'Here you can select the corresponding G/L account.', comment = 'DEU="Hier kann man das zugehörige Sachkonto auswählen."';
                    ApplicationArea = All;
                }
                field("Posting Date";"Posting Date")
                {
                    ToolTip = 'This date field refers to the posting date of the respective reserve.', comment = 'DEU="Dieses Datumsfeld bezieht sich auf das Buchungsdatum der jeweiligen Rückstellung."';
                    ApplicationArea = All;
                }
                field("Document Type";"Document Type")
                {
                    ToolTip = 'Here you can select the document type.', comment = 'DEU="Hier kann man wählen, um welche Belegart es sich handelt."';
                    ApplicationArea = All;
                }
                field("Document No.";"Document No.")
                {
                    ToolTip = 'Here you can select the document number that refers to the document date.', comment = 'deu="Hier kann man die Belegnummer wählen, welche sich auf das Belegdatum bezieht."';
                    ApplicationArea = All;
                }
                field(Description;Description)
                {
                    ToolTip = 'Here you can enter a description of the reserve.', comment = 'DEU="Hier kann man eine Beschreibung der Rückstellung erfassen."';
                    ApplicationArea = All;
                }
                field("Bal. Account No.";"Bal. Account No.")
                {
                    ToolTip = 'Here you can select the corresponding offset account.', comment = 'DEU="Hier kann man das zugehörige Gegenkonto auswählen."';
                    ApplicationArea = All;
                }
                field(Amount;Amount)
                {
                    ToolTip = 'Indicates the amount of the reserve.', comment = 'DEU="Gibt den Betrag der Rückstellung an."';
                    ApplicationArea = All;
                }
                field("Source Code";"Source Code")
                {
                    ToolTip = 'Here you can select the origin code.', comment = 'DEU="Hier kann man den Herkunftscode auswählen."';
                    ApplicationArea = All;
                }
            }
        }
    }
    
}
