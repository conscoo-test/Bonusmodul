codeunit 5266061 "lbtbn Sales Invoice Line" implements "lbtbn I"
{
    procedure GetDescription(): Text;
    var
        InvoiceLbl: Label 'Invoice ';
    begin
        exit(' ' + InvoiceLbl + SalesInvoiceLine."Document No.");
    end;

    procedure GetDimensionSetId(): Integer
    begin
        exit(SalesInvoiceLine."Dimension Set ID");
    end;

    procedure SetLine(SalesInvoiceLine2: Record "Sales Invoice Line")
    begin
        SalesInvoiceLine := SalesInvoiceLine2;
        SalesInvoiceHeader.Get(SalesInvoiceLine."Document No.")
    end;

    procedure GetAmount(): Decimal
    begin
        exit(SalesInvoiceLine.Amount);
    end;

    procedure ValueEntrySetRangeDocumentType(var ValueEntry: Record "Value Entry")
    begin
        ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Invoice");
        ValueEntry.SetRange("Document No.", SalesInvoiceLine."Document No.");
        ValueEntry.SetRange("Document Line No.", SalesInvoiceLine."Line No.");
    end;

    procedure GetShipmentDocType() DocumentType: Enum "Item Ledger Document Type";
    begin
        exit(DocumentType::"Sales Shipment");
    end;

    procedure GetAppliesToDocType() DocumentType: Enum "Sales Applies-to Document Type";
    begin
        exit(DocumentType::Shipment);
    end;

    procedure GetSourceDoc(var SourceDocType: Enum "lbtbn Document Type"; var SourceDocNo: Code[20]; var SourceDocLineNo: Integer)
    begin
        SourceDocType := SourceDocType::"Sales Invoice";
        SourceDocNo := SalesInvoiceLine."Document No.";
        SourceDocLineNo := SalesInvoiceLine."Line No.";
    end;

    procedure DocumentNo(): Code[20]
    begin
        exit(SalesInvoiceLine."Document No.");
    end;

    procedure Quantity(): Decimal
    begin
        exit(SalesInvoiceLine.Quantity);
    end;

    procedure Sign(): Decimal;
    begin
        exit(1);
    end;

    procedure CustNo(): Code[20]
    begin
        exit(SalesInvoiceHeader."Sell-to Customer No.");
    end;

    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";

}