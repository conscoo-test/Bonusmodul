report 5266053 "lbtbn Bonus Protocol"
{
    // *---------------------------------*
    // |  Lebit Software & Consult GmbH  |
    // |  Rotherstrasse 22, 10245 Berlin |
    // |                                 |
    // |  LBIS Version >> LBIS9.01 <<    |
    // *---------------------------------*
    // 
    // 
    // Nr.  Datum  KZ  Beschreibung
    // ======================================================================================
    DefaultLayout = RDLC;
    RDLCLayout = 'src/Report/BonusProtocol.rdlc';

    Caption = 'Bonus Protocol';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("Bonus Contract Entry"; "lbtbn Bonus Entry")
        {
            DataItemTableView = sorting(Contract, Customer, "Ship-to Code", "Entry Type", "Entry Date", Reversed) where("Entry Type" = const(Bonus));
            RequestFilterFields = Contract, Customer, "Ship-to Code", "Entry Date";
            column(ReportForNavId_5077978; 5077978)
            {
            }
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
            column(CurrReport_PAGENO; CurrReport.PageNo)
            {
            }
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(COMPANYNAME; COMPANYNAME)
            {
            }
            column(LBText001________GETFILTER_Date_; Text001 + '  ' + GetFilter("Entry Date"))
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
            column(Bonus_Contract_Entry_Customer_Control1117000049; Customer)
            {
            }
            column(Bonus_Contract_Entry__Amount_calculated__Control1117000050; "Calculated Amount")
            {
            }
            column(Bonus_Contract_Entry__Pmt__Discount_Amount__Control1117000051; "Pmt. Discount Amount")
            {
            }
            column(Bonus_Contract_Entry__Base_Amount__Control1117000052; "Base Amount")
            {
            }
            column(Bonus_Contract_Entry__Discount_Amount__Control1117000053; "Discount Amount")
            {
            }
            column(Bonus_Contract_Entry_Quantity_Control1117000054; "Sales Quantity")
            {
            }
            column(Bonus_Contract_Entry__From_Document_No___Control1117000055; "From Document No.")
            {
            }
            column(Bonus_Contract_Entry__Ship_to_Code__Control1117000056; "Ship-to Code")
            {
            }
            column(Bonus_Contract_Entry__Amount_calculated__Control1117000057; "Calculated Amount")
            {
            }
            column(Bonus_Contract_Entry__Pmt__Discount_Amount__Control1117000058; "Pmt. Discount Amount")
            {
            }
            column(Bonus_Contract_Entry__Discount_Amount__Control1117000059; "Discount Amount")
            {
            }
            column(Bonus_Contract_Entry__Base_Amount__Control1117000060; "Base Amount")
            {
            }
            column(Bonus_Contract_Entry_Quantity_Control1117000061; "Sales Quantity")
            {
            }
            column(Bonus_Contract_Entry__From_Document_No___Control1117000062; "From Document No.")
            {
            }
            column(Bonus_Contract_Entry__Ship_to_Code__Control1117000063; "Ship-to Code")
            {
            }
            column(Bonus_Contract_Entry__Amount_calculated__Control1117000064; "Calculated Amount")
            {
            }
            column(Bonus_Contract_Entry__Pmt__Discount_Amount__Control1117000065; "Pmt. Discount Amount")
            {
            }
            column(Bonus_Contract_Entry__Discount_Amount__Control1117000066; "Discount Amount")
            {
            }
            column(Bonus_Contract_Entry__Base_Amount__Control1117000067; "Base Amount")
            {
            }
            column(Bonus_Contract_Entry_Quantity_Control1117000068; "Sales Quantity")
            {
            }
            column(Bonus_Contract_Entry__From_Document_No___Control1117000069; "From Document No.")
            {
            }
            column(Bonus_Contract_Entry__Ship_to_Code__Control1117000018; "Ship-to Code")
            {
            }
            column(Bonus_Contract_Entry__Base_Amount__Control1117000032; "Base Amount")
            {
            }
            column(Bonus_Contract_Entry__Discount_Amount__Control1117000037; "Discount Amount")
            {
            }
            column(Bonus_Contract_Entry__Pmt__Discount_Amount__Control1117000038; "Pmt. Discount Amount")
            {
            }
            column(Bonus_Contract_Entry__Amount_calculated__Control1117000039; "Calculated Amount")
            {
            }
            column(Bonus_Contract_Entry_Quantity_Control1117000004; "Sales Quantity")
            {
            }
            column(Bonus_Contract_Entry_Customer_Control1117000020; Customer)
            {
            }
            column(Bonus_Contract_Entry__Base_Amount__Control1117000034; "Base Amount")
            {
            }
            column(Bonus_Contract_Entry__Discount_Amount__Control1117000040; "Discount Amount")
            {
            }
            column(Bonus_Contract_Entry__Pmt__Discount_Amount__Control1117000041; "Pmt. Discount Amount")
            {
            }
            column(Bonus_Contract_Entry__Amount_calculated__Control1117000042; "Calculated Amount")
            {
            }
            column(Bonus_Contract_Entry_Quantity_Control1117000073; "Sales Quantity")
            {
            }
            column(Bonus_Contract_Entry_Contract_Control1117000028; Contract)
            {
            }
            column(Bonus_Contract_Entry__Base_Amount__Control1117000035; "Base Amount")
            {
            }
            column(Bonus_Contract_Entry__Discount_Amount__Control1117000043; "Discount Amount")
            {
            }
            column(Bonus_Contract_Entry__Pmt__Discount_Amount__Control1117000044; "Pmt. Discount Amount")
            {
            }
            column(Bonus_Contract_Entry__Amount_calculated__Control1117000045; "Calculated Amount")
            {
            }
            column(Bonus_Contract_Entry_Quantity_Control1117000075; "Sales Quantity")
            {
            }
            column(Bonus_Contract_Entry__Base_Amount__Control1117000036; "Base Amount")
            {
            }
            column(Bonus_Contract_Entry__Discount_Amount__Control1117000046; "Discount Amount")
            {
            }
            column(Bonus_Contract_Entry__Pmt__Discount_Amount__Control1117000047; "Pmt. Discount Amount")
            {
            }
            column(Bonus_Contract_Entry__Amount_calculated__Control1117000048; "Calculated Amount")
            {
            }
            column(Bonus_Contract_Entry_Quantity_Control1117000076; "Sales Quantity")
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Bonus_AmountCaption; Bonus_AmountCaptionLbl)
            {
            }
            column(Base_AmountCaption; Base_AmountCaptionLbl)
            {
            }
            column(Base_Qty_Caption; Base_Qty_CaptionLbl)
            {
            }
            column(Bonus_ProtocolCaption; Bonus_ProtocolCaptionLbl)
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
            column(Bonus_Contract_Entry_Entry_No_; "Entry No.")
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
        Text001: Label 'Date Filter :';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Bonus_AmountCaptionLbl: Label 'Bonus Amount';
        Base_AmountCaptionLbl: Label 'Base Amount';
        Base_Qty_CaptionLbl: Label 'Base Qty.';
        Bonus_ProtocolCaptionLbl: Label 'Bonus Protocol';
        Contract_No_CaptionLbl: Label 'Contract No.';
        Invoice_No_CaptionLbl: Label 'Invoice No.';
        Customer_No_CaptionLbl: Label 'Customer No.';
        Ship_to_CodeCaptionLbl: Label 'Ship-to Code';
        Discount_AmountCaptionLbl: Label 'Discount Amount';
        Cash_DiscountCaptionLbl: Label 'Cash Discount';
        Sum_for_Shipping_AddressCaptionLbl: Label 'Sum for Shipping Address';
        Sum_for_CustomerCaptionLbl: Label 'Sum for Customer';
        Sum_for_ContractCaptionLbl: Label 'Sum for Contract';
        Total_AmountCaptionLbl: Label 'Total Amount';
}

