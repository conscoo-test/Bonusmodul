tableextension 5266062 "lbt Bonus Item Charge Assign." extends "Item Charge Assignment (Sales)" //5809
{
    procedure "lbt CreateSeparateLines"(var SalesLineRecPar: Record "Sales Line")
    var
        ItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)";
        ItemChargeAssignmentSales2: Record "Item Charge Assignment (Sales)";
        TempItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)" temporary;
        SalesLineRec: Record "Sales Line";
        ReturnReceiptLine: Record "Return Receipt Line";
        SalesLineDimRec: Record "Sales Line";
        SalesShipmentLine: Record "Sales Shipment Line";

        DimensionManagement: Codeunit DimensionManagement;

        LineSpacing: Integer;
        NextLineNo: Integer;
        DimSetID: Integer;

    begin
        ItemChargeAssignmentSales.Reset();
        ItemChargeAssignmentSales.SetRange("Document Type", SalesLineRecPar."Document Type");
        ItemChargeAssignmentSales.SetRange("Document No.", SalesLineRecPar."Document No.");
        ItemChargeAssignmentSales.SetRange("Document Line No.", SalesLineRecPar."Line No.");
        ItemChargeAssignmentSales.SetFilter("Qty. to Assign", '<>%1', 0);

        SalesLineRec.Reset();
        SalesLineRec.SetRange("Document Type", SalesLineRecPar."Document Type");
        SalesLineRec.SetRange("Document No.", SalesLineRecPar."Document No.");
        SalesLineRec := SalesLineRecPar;
        if SalesLineRec.Find('>') then begin
            LineSpacing :=
              (SalesLineRec."Line No." - SalesLineRecPar."Line No.") div
              (1 + ItemChargeAssignmentSales.Count());
            if LineSpacing = 0 then
                Error(Text001Msg);
        end else
            LineSpacing := 10000;
        TempItemChargeAssignmentSales.DeleteAll();
        if ItemChargeAssignmentSales.FindSet() then
            repeat
                TempItemChargeAssignmentSales := ItemChargeAssignmentSales;
                TempItemChargeAssignmentSales.Insert();
            until ItemChargeAssignmentSales.Next() = 0;
        ItemChargeAssignmentSales.DeleteAll();

        NextLineNo := SalesLineRecPar."Line No.";/// + LineSpacing;

        if TempItemChargeAssignmentSales.FindSet() then
            repeat
                DimSetID := 0;
                case TempItemChargeAssignmentSales."Applies-to Doc. Type" of
                    TempItemChargeAssignmentSales."Applies-to Doc. Type"::Shipment:

                        if SalesShipmentLine.Get(TempItemChargeAssignmentSales."Applies-to Doc. No.", TempItemChargeAssignmentSales."Applies-to Doc. Line No.") then
                            DimSetID := SalesShipmentLine."Dimension Set ID";

                    TempItemChargeAssignmentSales."Applies-to Doc. Type"::"Return Receipt":

                        if ReturnReceiptLine.Get(TempItemChargeAssignmentSales."Applies-to Doc. No.", TempItemChargeAssignmentSales."Applies-to Doc. Line No.") then
                            DimSetID := ReturnReceiptLine."Dimension Set ID";

                    TempItemChargeAssignmentSales."Applies-to Doc. Type"::Quote:

                        if SalesLineDimRec.Get(SalesLineDimRec."Document Type"::Quote, TempItemChargeAssignmentSales."Applies-to Doc. No.", TempItemChargeAssignmentSales."Applies-to Doc. Line No.") then
                            DimSetID := SalesLineDimRec."Dimension Set ID";

                    TempItemChargeAssignmentSales."Applies-to Doc. Type"::Order:

                        if SalesLineDimRec.Get(SalesLineDimRec."Document Type"::Order, TempItemChargeAssignmentSales."Applies-to Doc. No.", TempItemChargeAssignmentSales."Applies-to Doc. Line No.") then
                            DimSetID := SalesLineDimRec."Dimension Set ID";

                    TempItemChargeAssignmentSales."Applies-to Doc. Type"::Invoice:

                        if SalesLineDimRec.Get(SalesLineDimRec."Document Type"::Invoice, TempItemChargeAssignmentSales."Applies-to Doc. No.", TempItemChargeAssignmentSales."Applies-to Doc. Line No.") then
                            DimSetID := SalesLineDimRec."Dimension Set ID";

                    TempItemChargeAssignmentSales."Applies-to Doc. Type"::"Credit Memo":

                        if SalesLineDimRec.Get(SalesLineDimRec."Document Type"::"Credit Memo", TempItemChargeAssignmentSales."Applies-to Doc. No.", TempItemChargeAssignmentSales."Applies-to Doc. Line No.") then
                            DimSetID := SalesLineDimRec."Dimension Set ID";

                    TempItemChargeAssignmentSales."Applies-to Doc. Type"::"Blanket Order":

                        if SalesLineDimRec.Get(SalesLineDimRec."Document Type"::"Blanket Order", TempItemChargeAssignmentSales."Applies-to Doc. No.", TempItemChargeAssignmentSales."Applies-to Doc. Line No.") then
                            DimSetID := SalesLineDimRec."Dimension Set ID";

                    TempItemChargeAssignmentSales."Applies-to Doc. Type"::"Return Order":

                        if SalesLineDimRec.Get(SalesLineDimRec."Document Type"::"Return Order", TempItemChargeAssignmentSales."Applies-to Doc. No.", TempItemChargeAssignmentSales."Applies-to Doc. Line No.") then
                            DimSetID := SalesLineDimRec."Dimension Set ID";

                end;
                SalesLineRec := SalesLineRecPar;
                SalesLineRec."Document Type" := SalesLineRecPar."Document Type";
                SalesLineRec."Document No." := SalesLineRecPar."Document No.";

                SalesLineRec."Line No." := NextLineNo;
                NextLineNo := NextLineNo + LineSpacing;
                SalesLineRec.Validate(Quantity, TempItemChargeAssignmentSales."Qty. to Assign");
                SalesLineRec.Validate(Amount, TempItemChargeAssignmentSales."Amount to Assign");

                //TODO: muss noch umgestellt werden!!!!
                //  SalesLineRec."Process No." := "TempItemChAss(Sales)Rec"."Process No.";
                //  SalesLineRec."Billing Code" := "TempItemChAss(Sales)Rec"."Billing Code";
                //  SalesLineRec."Billing Entry No." := "TempItemChAss(Sales)Rec"."Billing Entry No.";
                SalesLineRec."Dimension Set ID" := DimSetID;
                DimensionManagement.UpdateGlobalDimFromDimSetID(SalesLineRec."Dimension Set ID", SalesLineRec."Shortcut Dimension 1 Code", SalesLineRec."Shortcut Dimension 2 Code");

                if not SalesLineRec.Insert(true) then
                    SalesLineRec.Modify(true);

                // neue Zuweisung anlegen
                ItemChargeAssignmentSales2 := TempItemChargeAssignmentSales;
                ItemChargeAssignmentSales2."Document Type" := SalesLineRec."Document Type";
                ItemChargeAssignmentSales2."Document No." := SalesLineRec."Document No.";
                ItemChargeAssignmentSales2."Document Line No." := SalesLineRec."Line No.";
                ItemChargeAssignmentSales2.Insert();
            until TempItemChargeAssignmentSales.Next() = 0;
    end;



    var
        Text001Msg: Label 'You cannot assign item charges to the %1 because it has been invoiced. Instead you can get the posted document line and then assign the item charge to that line.'
                  , Comment = 'DEU="Sie können keine Artikel Zu-/Abschläge für die %1 zuweisen, da sie bereits fakturiert wurde. Stattdessen können Sie die gebuchte Belegzeile holen und den Artikel Zu-/Abschlag dieser Zeile zuweisen."';

}