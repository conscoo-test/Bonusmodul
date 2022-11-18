table 5266060 "lbtbn Bonus Item"
{
    Caption = 'Bonus Item';
    DataClassification = CustomerContent;
    DrillDownPageId = "lbtbn Bonus Items";
    LookupPageId = "lbtbn Bonus Items";

    fields
    {
        field(1; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "lbtbn Bonus Contract";
        }
        field(2; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(4; "Item Filter"; Blob)
        {
            Caption = 'Item Filter';
        }
        field(5; Description; Text[50])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(PK; "Contract No.", "Entry No.")
        {
            Clustered = true;
        }
    }

    procedure GetItemFilter() FilterText: Text
    var
        ins: InStream;
    begin
        if not Rec."Item Filter".HasValue then
            exit;
        CalcFields(Rec."Item Filter");
        Rec."Item Filter".CreateInStream(ins);
        ins.ReadText(FilterText);
    end;

    procedure AssistEdit()
    var
        Item: Record Item;
        FilterPage: FilterPageBuilder;
        FilterText: Text;
    begin
        FilterPage.AddTable(Item.TableCaption(), Database::Item);
        FilterPage.AddFieldNo(Item.TableCaption, Item.FieldNo("No."));
        FilterPage.AddFieldNo(Item.TableCaption, Item.FieldNo("lbtbn Item Group"));
        FilterText := GetItemFilter();
        if FilterText <> '' then
            FilterPage.SetView(Item.TableCaption, FilterText);
        if FilterPage.RunModal() then
            SetItemFilter(FilterPage.GetView(Item.TableCaption));
    end;

    procedure SetItemFilter(FilterText: Text)
    var
        outs: OutStream;
    begin
        Clear(Rec."Item Filter");
        Rec."Item Filter".CreateOutStream(outs);
        outs.WriteText(FilterText);
        Rec.Modify()
    end;

    procedure CheckAttributes(ItemNo: Code[20]): Boolean;
    var
        ItemAttributeValue: Record "Item Attribute Value";
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
        BonusContractAttribute: Record "lbtbn BonusContractAttribute";
    begin
        BonusContractAttribute.SetRange(Contract, Rec."Contract No.");
        BonusContractAttribute.SetRange("Bonus Item Entry No.", Rec."Entry No.");
        if BonusContractAttribute.FindSet() then
            repeat
                if not ItemAttributeValueMapping.Get(Database::Item, ItemNo, BonusContractAttribute."Attribute ID") then
                    exit(false);
                ItemAttributeValue.Get(ItemAttributeValueMapping."Item Attribute ID", ItemAttributeValueMapping."Item Attribute Value ID");
                // case BonusContractAttribute."Attribute Type" of
                //     BonusContractAttribute."Attribute Type"::Decimal:
                //         ;
                //     BonusContractAttribute."Attribute Type"::Integer:
                //         ;
                //     BonusContractAttribute."Attribute Type"::Text:

                //         ;
                //     BonusContractAttribute."Attribute Type"::Option:
                if ItemAttributeValue.ID <> BonusContractAttribute."Attribute Value ID" then
                    exit(false);
            // end;
            until BonusContractAttribute.Next() = 0;
        exit(true);
    end;

}