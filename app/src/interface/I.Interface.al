interface "lbtbn I"
{
    procedure GetDescription(): Text;
    procedure GetDimensionSetId(): Integer;
    procedure GetAmount(): Decimal;
    procedure ValueEntrySetRangeDocumentType(var ValueEntry: Record "Value Entry");
    procedure GetShipmentDocType() DocumentType: Enum "Item Ledger Document Type";
    procedure GetAppliesToDocType() DocumentType: Enum "Sales Applies-to Document Type";
    procedure GetSourceDoc(var SourceDocType: Enum "lbtbn Document Type"; var SourceDocNo: Code[20]; var SourceDocLineNo: Integer);
    procedure DocumentNo(): Code[20];
    procedure Quantity(): Decimal;
    procedure Sign(): Decimal;
    procedure CustNo(): Code[20];
}
