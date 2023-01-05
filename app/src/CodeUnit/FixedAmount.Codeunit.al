codeunit 5266063 "lbtbn Fixed Amount" implements "lbtbn I"
{
    procedure GetDescription(): Text;
    var
        FixedAmountLbl: Label 'Bonus Fixed Amount';
    begin
        exit(' ' + FixedAmountLbl);
    end;

    procedure GetDimensionSetId(): Integer
    begin
        exit(0);
    end;

    procedure GetAmount(): Decimal
    begin
        exit(0);
    end;

    procedure DocTypeMatches(DocumentType: Enum "Item Ledger Document Type"): Boolean
    begin
        exit(false);
    end;

    procedure GetShipmentDocType() DocumentType: Enum "Item Ledger Document Type";
    begin
    end;

    procedure GetAppliesToDocType() DocumentType: Enum "Sales Applies-to Document Type";
    begin
    end;

    procedure ValueEntrySetRangeDocumentType(var ValueEntry: Record "Value Entry")
    begin
    end;

    procedure GetSourceDoc(var SourceDocType: Enum "lbtbn Document Type"; var SourceDocNo: Code[20]; var SourceDocLineNo: Integer)
    begin
    end;

    procedure DocumentNo(): Code[20]
    begin
    end;

    procedure Quantity(): Decimal
    begin
    end;

    procedure Sign(): Decimal;
    begin

    end;

    procedure CustNo(): Code[20]
    begin
        exit(CustomerNo);
    end;

    procedure SetCustomerNo(CustomerNo2: Code[20])
    begin
        CustomerNo := CustomerNo2;
    end;

    var
        CustomerNo: Code[20];
}