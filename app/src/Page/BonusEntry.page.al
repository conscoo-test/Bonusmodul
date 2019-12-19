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
                field("Entry No."; "Entry No.")
                {
                    ToolTip = 'This field identifies the bonus item with a unique, sequential number.', comment = 'DEU="Dieses Feld identifiziert den Bonusposten mit einer einmaligen, fortlaufenden Nr."';
                    ApplicationArea = All;
                }
                field(Contract; "Contract")
                {
                    ToolTip = 'This field is filled with the contract number of the bonus agreement.', comment = 'DEU="Dieses Feld wird mit der Vertragsnummerder Bonusvereinbarung gefüllt."';
                    ApplicationArea = All;
                }
                field("Process No."; "Process No.")
                {
                    //TODO: Tooltip
                    ApplicationArea = All;
                }
                field("Bonus Contract Line"; "Bonus Contract Line")
                {
                    ToolTip = 'The bonus contract line of the respective contract is written to the bonus items.', comment = 'DEU="Es wird die Bonusvertragszeile des jeweiligen Vertrages in die Bonusposten geschrieben."';
                    ApplicationArea = All;
                }
                field("Entry Type"; "Entry Type")
                {
                    ToolTip = 'This field defines the type of item using the following options:reserverelease, reservebonus, items', comment = 'DEU="Dieses Feld definiert die Art des Postens anhand folgender Optionen:Rückstellung, Rückstellungsauflösung, Bonusposten"';
                    ApplicationArea = All;
                }
                field(Customer; "Customer")
                {
                    ToolTip = 'This field is filled with the customer from the bonus contract.', comment = 'DEU="Dieses Feld wird mit dem Debitor aus dem Bonusvertrag gefüllt."';
                    ApplicationArea = All;
                }
                field("Ship-to Code"; "Ship-to Code")
                {
                    ToolTip = 'This field is filled with the delivery contact from the bonus contract.', comment = 'DEU="Dieses Feld wird mit dem Lieferkontakt aus dem Bonusvertrag gefüllt."';
                    ApplicationArea = All;
                }
                field("Entry Date"; "Entry Date")
                {
                    ToolTip = 'This date field refers to the posting date of the respective G/L items.', comment = 'DEU="Dieses Datumsfeld bezieht sich auf das Buchungsdatum der jeweiligen Sachposten."';
                    ApplicationArea = All;
                }
                field("Sales Quantity"; "Sales Quantity")
                {
                    ToolTip = 'The quantity of the individual document line of the settlement credit memo is entered here.', comment = 'DEU="Hier wird die Menge der einzelnen Belegzeile der Abrechnungsgutschrift eingetragen."';
                    ApplicationArea = All;
                }

                field("Base Amount"; "Base Amount")
                {
                    ToolTip = 'The base amount of the source document is entered in this field.', comment = 'DEU="In diesem Feld wird der Basisbetrag des Quellbeleges erfasst."';
                    ApplicationArea = All;
                }
                field("Calculated Amount"; "Calculated Amount")
                {
                    ToolTip = 'This field displays the amount based on the calculated reserves and bonus runs. Since value changes can be made in the reserve ledger sheet or bonus credit memo after the reserve or bonus has been created, the calculated amount does not have to be identical to the actual posted amount.', comment = 'DEU="Dieses Feld zeigt den Betrag auf Basis der berechneten Rückstellungen und Bonusläufe an. Da nach der Erstellung der Rückstellung bzw. Bonus im Rückstellungsbuchblatt bzw. Bonusgutschrift wertmäßige Änderungen vorgenommen werden können, muss der errechnete Betrag nicht gleich identisch sein mit dem wirklich gebuchten Betrag."';
                    ApplicationArea = All;
                }
                field("calc. Amount incl. VAT"; "calc. Amount incl. VAT")
                {
                    ToolTip = 'In this field, the calculated amount including VAT is entered if the invoice recipient is liable for VAT on the basis of his master data facility.', comment = 'DEU="In diesem Feld wird der errechnete Betrag inkl. der MwSt.erfasst, wenn der Rechnungsempfänger anhand seiner Stammdateneinrichtung MwSt.-pflichtig ist."';
                    ApplicationArea = All;
                }
                field("Posted Amount"; "Posted Amount")
                {
                    ToolTip = 'This field is not filled with a value until the corresponding bonus credit memo or reserve ledger sheet has been posted.', comment = 'deu="Dieses Feld wird erst mit einem Wert gefüllt, wenn die zugehörige Bonusgutschrift bzw. das Rückstellungsbuchblatt verbucht wurde."';
                    ApplicationArea = All;
                }
                field("Discount Amount"; "Discount Amount")
                {
                    ToolTip = 'This field contains the calculated discount.', comment = 'DEU="Dieses Feld beinhaltet den berechneten Rabatt."';
                    ApplicationArea = All;
                }
                field("Pmt. Discount Amount"; "Pmt. Discount Amount")
                {
                    ToolTip = 'This field contains the calculated cash discount.', comment = 'DEU="Dieses Feld beinhaltet den berechneten Skonto."';
                    ApplicationArea = All;
                }
                field("From Document Type"; "From Document Type")
                {
                    ToolTip = 'If it is a bonus item with the item type "Bonus", the document type "Sales credit memo" is stored in this field.', comment = 'DEU="Handelt es sich um ein Bonusposten mit der Postenart "Bonus" wird in diesem Feld „Verkaufsgutschrift“ als Belegart hinterlegt."';
                    ApplicationArea = All;
                }

                field("From Document No."; "From Document No.")
                {
                    ToolTip = 'If it is a bonus item with the item type Bonus, the document number of the bonus credit memo is entered in this field.', comment = 'DEU="Handelt es sich um ein Bonusposten mit der Postenart "Bonus" wird in diesem Feld die Belegnr. der Bonusgutschrift erfasst."';
                    ApplicationArea = All;
                }
                field("From Document Line"; "From Document Line")
                {
                    ToolTip = 'You can use the Document line field to identify the credit line in which this bonus item is located in the bonus credit memo.', comment = 'DEU="Mit Hilfe des Feldes Belegzeile kann identifiziert werden, in welcher Gutschriftzeile sich dieser Bonusposten in der Bonusgutschrift befindet."';
                    ApplicationArea = All;
                }

                field("Bonus Document Type"; "Bonus Document Type")
                {
                    ToolTip = 'If it is a bonus item with the item type "Bonus", the document type "Sales credit memo" is stored in this field. ', comment = 'DEU="Handelt es sich um ein Bonusposten mit der Postenart "Bonus" wird in diesem Feld „Verkaufsgutschrift“ als Bonus Dokumentenart hinterlegt. "';
                    ApplicationArea = All;
                }

                field("Bonus Document No."; "Bonus Document No.")
                {
                    ToolTip = 'If it is a bonus item with the item type Bonus, the bonus document number is entered in this field.', comment = 'DEU="Handelt es sich um ein Bonusposten mit der Postenart "Bonus" wird in diesem Feld die Bonusbelegnummer der Bonusgutschrift erfasst."';
                    ApplicationArea = All;
                }
                field("Bonus Document Line"; "Bonus Document Line")
                {
                    ToolTip = 'You can use the bonus document lines field to identify the credit line in which this bonus item is located in the bonus credit memo.', comment = 'DEU="Mit Hilfe des Feldes Bonus Dokumentenzeile kann identifiziert werden, in welcher Gutschriftzeile sich dieser Bonusposten in der Bonusgutschrift befindet."';
                    ApplicationArea = All;
                }
                field("Assignment Document Type"; "Assignment Document Type")
                {
                    ToolTip = 'The assignment document type is stored in this field.', comment = 'DEU="In diesem Feld wird die Zuordnungsbelegart hinterlegt."';
                    ApplicationArea = All;
                }
                field("Assignment Document No."; "Assignment Document No.")
                {
                    ToolTip = 'If the bonus item has the item type Bonus, the assignment document number of the bonus credit memo is entered in this field.', comment = 'DEU="Handelt es sich um ein Bonusposten mit der Postenart ‚Bonus‘ wird in diesem Feld die Zuordnungsbelegnummer der Bonusgutschrift erfasst."';
                    ApplicationArea = All;
                }
                field("Assignment Doc. Line No."; "Assignment Doc. Line No.")
                {
                    ToolTip = 'You can use the Assignment document line number field to identify in which credit memo line this rebate item is located in the rebate credit memo.', comment = 'DEU="Mit Hilfe des Feldes Zuordnungsbelegzeilennummer kann identifiziert werden, in welcher Gutschriftzeile sich dieser Bonusposten in der Bonusgutschrift befindet."';
                    ApplicationArea = All;
                }
                field("General Ledger Entry No."; "General Ledger Entry No.")
                {
                    ToolTip = 'Used to identify posted G/L items as bonus or reserve. ', comment = 'DEU="Dient zur Identifizierung der gebuchten Sachposten als Bonus bzw.Rückstellung."';
                    ApplicationArea = All;
                }
                field("Invoice Customer No."; "Invoice Customer No.")
                {
                    ToolTip = 'This field is filled with the invoice recipient of the bonus agreement.  An alternative customer can also be defined as the bill-to party.', comment = 'DEU="Dieses Feld wird mit dem Rechnungsempfänger der Bonusvereinbarung gefüllt.  Als Rechnungsempfänger kann auch ein abweichender Debitor hinterlegt werden."';
                    ApplicationArea = All;
                }











            }
        }
    }

}
