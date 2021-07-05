tableextension 5266062 "lbt Bonus Item Charge Assign." extends "Item Charge Assignment (Sales)" //5809
{
    procedure CreateSeparateLines(var SalesLineRecPar: Record "Sales Line")
    var
        "ItemChAss(Sales)Rec": Record "Item Charge Assignment (Sales)";
        "ItemChAss(Sales)Rec2": Record "Item Charge Assignment (Sales)";
        "TempItemChAss(Sales)Rec": Record "Item Charge Assignment (Sales)";
        "SalesLineRec": Record "Sales Line";
        "ReturnLineRec": Record "Return Receipt Line";
        "SalesLineDimRec": Record "Sales Line";
        "ShiplLineRec": Record "Sales Shipment Line";

        DimMgt: Codeunit "DimensionManagement";

        LineSpacing: Integer;
        NextLineNo: Integer;
        DimSetID: Integer;

    begin
        "ItemChAss(Sales)Rec".RESET();
        "ItemChAss(Sales)Rec".SETRANGE("Document Type", SalesLineRecPar."Document Type");
        "ItemChAss(Sales)Rec".SETRANGE("Document No.", SalesLineRecPar."Document No.");
        "ItemChAss(Sales)Rec".SETRANGE("Document Line No.", SalesLineRecPar."Line No.");
        "ItemChAss(Sales)Rec".SETFILTER("Qty. to Assign", '<>%1', 0);

        SalesLineRec.RESET();
        SalesLineRec.SETRANGE("Document Type", SalesLineRecPar."Document Type");
        SalesLineRec.SETRANGE("Document No.", SalesLineRecPar."Document No.");
        SalesLineRec := SalesLineRecPar;
        IF SalesLineRec.FIND('>') THEN BEGIN
            LineSpacing :=
              (SalesLineRec."Line No." - SalesLineRecPar."Line No.") DIV
              (1 + "ItemChAss(Sales)Rec".COUNT());
            IF LineSpacing = 0 THEN
                ERROR(Text001Msg);
        END ELSE
            LineSpacing := 10000;
        "TempItemChAss(Sales)Rec".DELETEALL();
        IF "ItemChAss(Sales)Rec".FINDSET() THEN
            REPEAT
                "TempItemChAss(Sales)Rec" := "ItemChAss(Sales)Rec";
                "TempItemChAss(Sales)Rec".INSERT();
            UNTIL "ItemChAss(Sales)Rec".NEXT() = 0;
        "ItemChAss(Sales)Rec".DELETEALL();

        NextLineNo := SalesLineRecPar."Line No.";/// + LineSpacing;

        IF "TempItemChAss(Sales)Rec".FINDFIRST() THEN
            REPEAT
                DimSetID := 0;
                CASE "TempItemChAss(Sales)Rec"."Applies-to Doc. Type" OF
                    "TempItemChAss(Sales)Rec"."Applies-to Doc. Type"::Shipment:

                        IF ShiplLineRec.GET("TempItemChAss(Sales)Rec"."Applies-to Doc. No.", "TempItemChAss(Sales)Rec"."Applies-to Doc. Line No.") THEN
                            DimSetID := ShiplLineRec."Dimension Set ID";

                    "TempItemChAss(Sales)Rec"."Applies-to Doc. Type"::"Return Receipt":

                        IF ReturnLineRec.GET("TempItemChAss(Sales)Rec"."Applies-to Doc. No.", "TempItemChAss(Sales)Rec"."Applies-to Doc. Line No.") THEN
                            DimSetID := ReturnLineRec."Dimension Set ID";

                    "TempItemChAss(Sales)Rec"."Applies-to Doc. Type"::Quote:

                        IF SalesLineDimRec.GET(SalesLineDimRec."Document Type"::Quote, "TempItemChAss(Sales)Rec"."Applies-to Doc. No.", "TempItemChAss(Sales)Rec"."Applies-to Doc. Line No.") THEN
                            DimSetID := SalesLineDimRec."Dimension Set ID";

                    "TempItemChAss(Sales)Rec"."Applies-to Doc. Type"::Order:

                        IF SalesLineDimRec.GET(SalesLineDimRec."Document Type"::Order, "TempItemChAss(Sales)Rec"."Applies-to Doc. No.", "TempItemChAss(Sales)Rec"."Applies-to Doc. Line No.") THEN
                            DimSetID := SalesLineDimRec."Dimension Set ID";

                    "TempItemChAss(Sales)Rec"."Applies-to Doc. Type"::Invoice:

                        IF SalesLineDimRec.GET(SalesLineDimRec."Document Type"::Invoice, "TempItemChAss(Sales)Rec"."Applies-to Doc. No.", "TempItemChAss(Sales)Rec"."Applies-to Doc. Line No.") THEN
                            DimSetID := SalesLineDimRec."Dimension Set ID";

                    "TempItemChAss(Sales)Rec"."Applies-to Doc. Type"::"Credit Memo":

                        IF SalesLineDimRec.GET(SalesLineDimRec."Document Type"::"Credit Memo", "TempItemChAss(Sales)Rec"."Applies-to Doc. No.", "TempItemChAss(Sales)Rec"."Applies-to Doc. Line No.") THEN
                            DimSetID := SalesLineDimRec."Dimension Set ID";

                    "TempItemChAss(Sales)Rec"."Applies-to Doc. Type"::"Blanket Order":

                        IF SalesLineDimRec.GET(SalesLineDimRec."Document Type"::"Blanket Order", "TempItemChAss(Sales)Rec"."Applies-to Doc. No.", "TempItemChAss(Sales)Rec"."Applies-to Doc. Line No.") THEN
                            DimSetID := SalesLineDimRec."Dimension Set ID";

                    "TempItemChAss(Sales)Rec"."Applies-to Doc. Type"::"Return Order":

                        IF SalesLineDimRec.GET(SalesLineDimRec."Document Type"::"Return Order", "TempItemChAss(Sales)Rec"."Applies-to Doc. No.", "TempItemChAss(Sales)Rec"."Applies-to Doc. Line No.") THEN
                            DimSetID := SalesLineDimRec."Dimension Set ID";

                END;
                SalesLineRec := SalesLineRecPar;
                SalesLineRec."Document Type" := SalesLineRecPar."Document Type";
                SalesLineRec."Document No." := SalesLineRecPar."Document No.";

                SalesLineRec."Line No." := NextLineNo;
                NextLineNo := NextLineNo + LineSpacing;
                SalesLineRec.VALIDATE(Quantity, "TempItemChAss(Sales)Rec"."Qty. to Assign");
                SalesLineRec.VALIDATE(Amount, "TempItemChAss(Sales)Rec"."Amount to Assign");

                //TODO: muss noch umgestellt werden!!!!
                //  SalesLineRec."Process No." := "TempItemChAss(Sales)Rec"."Process No.";
                //  SalesLineRec."Billing Code" := "TempItemChAss(Sales)Rec"."Billing Code";
                //  SalesLineRec."Billing Entry No." := "TempItemChAss(Sales)Rec"."Billing Entry No.";
                SalesLineRec."Dimension Set ID" := DimSetID;
                DimMgt.UpdateGlobalDimFromDimSetID(SalesLineRec."Dimension Set ID", SalesLineRec."Shortcut Dimension 1 Code", SalesLineRec."Shortcut Dimension 2 Code");

                IF NOT SalesLineRec.INSERT(TRUE) THEN
                    SalesLineRec.MODIFY(TRUE);

                // neue Zuweisung anlegen
                "ItemChAss(Sales)Rec2" := "TempItemChAss(Sales)Rec";
                "ItemChAss(Sales)Rec2"."Document Type" := SalesLineRec."Document Type";
                "ItemChAss(Sales)Rec2"."Document No." := SalesLineRec."Document No.";
                "ItemChAss(Sales)Rec2"."Document Line No." := SalesLineRec."Line No.";
                "ItemChAss(Sales)Rec2".INSERT();
            UNTIL "TempItemChAss(Sales)Rec".NEXT() = 0;
    END;



    var
        Text001Msg: Label 'You cannot assign item charges to the %1 because it has been invoiced. Instead you can get the posted document line and then assign the item charge to that line.'
                  , Comment = 'DEU="Sie können keine Artikel Zu-/Abschläge für die %1 zuweisen, da sie bereits fakturiert wurde. Stattdessen können Sie die gebuchte Belegzeile holen und den Artikel Zu-/Abschlag dieser Zeile zuweisen."';

}