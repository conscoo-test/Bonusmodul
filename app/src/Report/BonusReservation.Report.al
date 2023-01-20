report 5266054 "lbtbn Bonus Reservation"
{
    // *---------------------------------*
    // |  Lebit Software & Consult GmbH  |
    // |  Rotherstrasse 22, 10245 Berlin |
    // |                                 |
    // |  LBIS Version >> LBIS10.03 <<   |
    // *---------------------------------*
    // 
    // 
    // Nr.  Datum  KZ  Beschreibung
    // ======================================================================================
    DefaultLayout = RDLC;
    RDLCLayout = 'src/Report/BonusReservation.rdlc';

    Caption = 'Bonus Reservation';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("Bonus Contract Entry"; "lbtbn Bonus Entry")
        {
            DataItemTableView = sorting(Contract, Customer, "Ship-to Code", "Entry Type", "Entry Date", Reversed) where("Entry Type" = const(Reserve), Reversed = const(false), "Bonus Document Deleted" = const(false));
            RequestFilterFields = Contract, Customer, "Ship-to Code", "Entry Date";
            column(PrintBody_4; PrintBody[4])
            {
            }
            column(PrintBody_3; PrintBody[3])
            {
            }
            column(PrintBody_2; PrintBody[2])
            {
            }
            column(PrintBody_1; PrintBody[1])
            {
            }
            column(UserId; UserId())
            {
            }
            column(COMPANYNAME; CompanyName())
            {
            }
            column(LBText001______GETFILTER_Date_; Text001 + ' ' + GetFilter("Entry Date"))
            {
            }
            column(Bonus_Contract_Entry_Quantity; "Sales Quantity")
            {
            }
            column(Bonus_Contract_Entry__Base_Amount_; "Base Amount")
            {
            }
            column(Bonus_Contract_Entry__Amount_calculated_; "Calculated Amount")
            {
            }
            column(Bonus_Contract_Entry__Pmt__Discount_Amount_; "Pmt. Discount Amount")
            {
            }
            column(Bonus_Contract_Entry__Discount_Amount_; "Discount Amount")
            {
            }
            column(Bonus_Contract_Entry__From_Document_No__; "From Document No.")
            {
            }
            column(Bonus_Contract_Entry_Contract; Contract)
            {
            }
            column(Bonus_Contract_Entry_Customer; Customer)
            {
            }
            column(Bonus_Contract_Entry__Ship_to_Code_; "Ship-to Code")
            {
            }
            column(ContractRec__Reserve_Amount_; ContractRec."Reserve Value")
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Result_AmountCaption; Result_AmountCaptionLbl)
            {
            }
            column(Reservation_AmountCaption; Reservation_AmountCaptionLbl)
            {
            }
            column(Base_AmountCaption; Base_AmountCaptionLbl)
            {
            }
            column(Base_Qty_Caption; Base_Qty_CaptionLbl)
            {
            }
            column(Bonus_reservationsCaption; Bonus_reservationsCaptionLbl)
            {
            }
            column(Contract_No_Caption; Contract_No_CaptionLbl)
            {
            }
            column(Invoice_No_Caption; Invoice_No_CaptionLbl)
            {
            }
            column(Customer_No_Caption; Customer_No_CaptionLbl)
            {
            }
            column(Ship_to_CodeCaption; Ship_to_CodeCaptionLbl)
            {
            }
            column(Discount_AmountCaption; Discount_AmountCaptionLbl)
            {
            }
            column(Cash_DiscountCaption; Cash_DiscountCaptionLbl)
            {
            }
            column(Sum_for_Shipping_AddressCaption; Sum_for_Shipping_AddressCaptionLbl)
            {
            }
            column(Sum_for_CustomerCaption; Sum_for_CustomerCaptionLbl)
            {
            }
            column(Sum_for_ContractCaption; Sum_for_ContractCaptionLbl)
            {
            }
            column(Total_AmountCaption; Total_AmountCaptionLbl)
            {
            }
            trigger OnAfterGetRecord()
            begin
                Clear(PrintBody);
                if GrupValue[1] <> Contract then
                    PrintBody[1] := true
                else
                    if GrupValue[2] <> Customer then
                        PrintBody[2] := true
                    else
                        if GrupValue[3] <> "Ship-to Code" then
                            PrintBody[3] := true
                        else
                            PrintBody[4] := true;
                GrupValue[1] := Contract;
                GrupValue[2] := Customer;
                GrupValue[3] := "Ship-to Code";

                Clear(ContractRec);
                if ContractRec.Get("Bonus Contract Entry".Contract) then;
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        ContractRec: Record "lbtbn Bonus Contract";
        GrupValue: array[3] of Code[20];
        PrintBody: array[4] of Boolean;
        Text001: Label 'Date Filter:';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Result_AmountCaptionLbl: Label 'Amount';
        Reservation_AmountCaptionLbl: Label 'Reservation Amount';
        Base_AmountCaptionLbl: Label 'Base Amount';
        Base_Qty_CaptionLbl: Label 'Base Qty.';
        Bonus_reservationsCaptionLbl: Label 'Bonus reservations';
        Contract_No_CaptionLbl: Label 'Contract No.';
        Invoice_No_CaptionLbl: Label 'Document No.';
        Customer_No_CaptionLbl: Label 'Customer No.';
        Ship_to_CodeCaptionLbl: Label 'Ship-to Code';
        Discount_AmountCaptionLbl: Label 'Discount Amount';
        Cash_DiscountCaptionLbl: Label 'Cash Discount';
        Sum_for_Shipping_AddressCaptionLbl: Label 'Sum for Shipping Address';
        Sum_for_CustomerCaptionLbl: Label 'Sum for Customer';
        Sum_for_ContractCaptionLbl: Label 'Sum for Contract';
        Total_AmountCaptionLbl: Label 'Total Amount';
}



