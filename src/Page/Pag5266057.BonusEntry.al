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
                    ToolTip = 'This field identifies the bonus item with a unique, sequential number.', comment = 'deu="Dieses Feld identifiziert den Bonusposten mit einer einmaligen, fortlaufenden Nr."';
                    ApplicationArea = All;
                }
                field("lbt Contract"; "lbt Contract")
                {
                    ToolTip = 'This field is filled with the contract number of the bonus agreement.', comment = 'deu="Dieses Feld wird mit der Vertragsnummerder Bonusvereinbarung gefüllt."';
                    ApplicationArea = All;
                }
                field("lbt Bonus Contract Line"; "lbt Bonus Contract Line")
                {
                    ToolTip = 'The bonus contract line of the respective contract is written to the bonus items.', comment = 'deu="Es wird die Bonusvertragszeile des jeweiligen Vertrages in die Bonusposten geschrieben."';
                    ApplicationArea = All;
                }
                field("lbt Entry Type"; "lbt Entry Type")
                {
                    ToolTip = 'This field defines the type of item using the following options:reserverelease, reservebonus, items', comment = 'deu="Dieses Feld definiert die Art des Postens anhand folgender Optionen:Rückstellung, Rückstellungsauflösung, Bonusposten"';
                    ApplicationArea = All;
                }
                field("lbt Customer"; "lbt Customer")
                {
                    ToolTip = 'This field is filled with the customer from the bonus contract.', comment = 'deu="Dieses Feld wird mit dem Debitor aus dem Bonusvertrag gefüllt"';
                    ApplicationArea = All;
                }
                field("lbt Ship-to Code"; "lbt Ship-to Code")
                {
                    ToolTip = 'This field is filled with the delivery contact from the bonus contract.', comment = 'deu="Dieses Feld wird mit dem Lieferkontakt aus dem Bonusvertrag gefüllt."';
                    ApplicationArea = All;
                }
                field("lbt Entry Date"; "lbt Entry Date")
                {
                    ToolTip = 'This date field refers to the posting date of the respective G/L items.', comment = 'deu="Dieses Datumsfeld bezieht sich auf das Buchungsdatum der jeweiligen Sachposten."';
                    ApplicationArea = All;
                }
                field("lbt Sales Quantity"; "lbt Sales Quantity")
                {
                    ToolTip = 'The quantity of the individual document line of the settlement credit memo is entered here.', comment = 'deu="Hier wird die Menge der einzelnen Belegzeile der Abrechnungsgutschrift eingetragen."';
                    ApplicationArea = All;
                }

                field("lbt Base Amount"; "lbt Base Amount")
                {
                    ToolTip = 'The base amount of the source document is entered in this field.', comment = 'deu="In diesem Feld wird der Basisbetrag des Quellbeleges erfasst."';
                    ApplicationArea = All;
                }
                field("lbt Calculated Amount"; "lbt Calculated Amount")
                {
                    ToolTip = 'This field displays the amount based on the calculated reserves and bonus runs. Since value changes can be made in the reserve ledger sheet or bonus credit memo after the reserve or bonus has been created, the calculated amount does not have to be identical to the actual posted amount.', comment = 'deu="Dieses Feld zeigt den Betrag auf Basis der berechneten Rückstellungen und Bonusläufe an. Da nach der Erstellung der Rückstellung bzw. Bonus im Rückstellungsbuchblatt bzw. Bonusgutschrift wertmäßige Änderungen vorgenommen werden können, muss der errechnete Betrag nicht gleich identisch sein mit dem wirklich gebuchten Betrag."';
                    ApplicationArea = All;
                }
                field("lbt calc. Amount incl. VAT"; "lbt calc. Amount incl. VAT")
                {
                    ToolTip = 'In this field, the calculated amount including VAT is entered if the invoice recipient is liable for VAT on the basis of his master data facility.', comment = 'deu="In diesem Feld wird der errechnete Betrag inkl. der MwSt.erfasst, wenn der Rechnungsempfänger anhand seiner Stammdateneinrichtung MwSt.-pflichtig ist."';
                    ApplicationArea = All;
                }
                field("lbt Posted Amount"; "lbt Posted Amount")
                {
                    ToolTip = 'This field is not filled with a value until the corresponding bonus credit memo or reserve ledger sheet has been posted.', comment = 'deu="Dieses Feld wird erst mit einem Wert gefüllt, wenn die zugehörige Bonusgutschrift bzw. das Rückstellungsbuchblatt verbucht wurde."';
                    ApplicationArea = All;
                }
                field("lbt Discount Amount"; "lbt Discount Amount")
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }
                field("lbt Pmt. Discount Amount"; "lbt Pmt. Discount Amount")
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }
                field("lbt From Document Type"; "lbt From Document Type")
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }

                field("lbt From Document No."; "lbt From Document No.")
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }
                field("lbt From Document Line"; "lbt From Document Line")
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }

                field("lbt Bonus Document Type"; "lbt Bonus Document Type")
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }

                field("lbt Bonus Document No."; "lbt Bonus Document No.")
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }
                field("lbt Bonus Document Line"; "lbt Bonus Document Line")
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }
                field("lbt Assignment Document Type";"lbt Assignment Document Type")
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }
                field("lbt Assignment Document No.";"lbt Assignment Document No.")
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }
                field("lbt Assignment Doc. Line No.";"lbt Assignment Doc. Line No.")
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }
                field("lbt General Ledger Entry No.";"lbt General Ledger Entry No.")
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }
                field("lbt Invoice Customer No.";"lbt Invoice Customer No.")
                {
                    ToolTip = 'EnglishText', comment = 'deu="YourLanguageText"';
                    ApplicationArea = All;
                }











            }
        }
    }

}
