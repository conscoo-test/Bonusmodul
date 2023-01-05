codeunit 5266062 "lbtbn Sales Cr.Line" implements "lbtbn I"
{
    procedure GetDescription(): Text;
    var
        CrMemoLbl: Label 'Credit Memo ';
    begin
        exit(' ' + CrMemoLbl + SalesCrMemoLine."Document No.");
    end;

    procedure GetDimensionSetId(): Integer
    begin
        exit(SalesCrMemoLine."Dimension Set ID");
    end;

    procedure SetLine(SalesCrMemoLine2: Record "Sales Cr.Memo Line")
    begin
        SalesCrMemoLine := SalesCrMemoLine2;
        SalesCrMemoHeader.Get(SalesCrMemoLine."Document No.");
    end;

    procedure GetAmount(): Decimal
    begin
        exit(-SalesCrMemoLine.Amount);
    end;

    procedure DocumentNo(): Code[20]
    begin
        exit(SalesCrMemoLine."Document No.");
    end;

    procedure ValueEntrySetRangeDocumentType(var ValueEntry: Record "Value Entry")
    begin
        ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Credit Memo");
        ValueEntry.SetRange("Document No.", SalesCrMemoLine."Document No.");
        ValueEntry.SetRange("Document Line No.", SalesCrMemoLine."Line No.");
    end;

    procedure DocTypeMatches(DocumentType: Enum "Item Ledger Document Type"): Boolean
    begin
        exit(DocumentType = DocumentType::"Sales Return Receipt");
    end;

    procedure GetShipmentDocType() DocumentType: Enum "Item Ledger Document Type";
    begin
        exit(DocumentType::"Sales Return Receipt");
    end;

    procedure GetAppliesToDocType() DocumentType: Enum "Sales Applies-to Document Type";
    begin
        exit(DocumentType::"Return Receipt");
    end;

    procedure GetSourceDoc(var SourceDocType: Enum "lbtbn Document Type"; var SourceDocNo: Code[20]; var SourceDocLineNo: Integer)
    begin
        SourceDocType := SourceDocType::"Sales Credit Memo";
        SourceDocNo := SalesCrMemoLine."Document No.";
        SourceDocLineNo := SalesCrMemoLine."Line No.";
    end;

    procedure Quantity(): Decimal
    begin
        exit(SalesCrMemoLine.Quantity);
    end;

    procedure Sign(): Decimal
    begin
        exit(-1);
    end;

    procedure CustNo(): Code[20]
    begin
        exit(SalesCrMemoHeader."Sell-to Customer No.");
    end;

    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";

}