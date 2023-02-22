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
        field(6; "Item Count"; Integer)
        {
            Caption = 'Item Count';
        }
    }

    keys
    {
        key(PK; "Contract No.", "Entry No.")
        {
            Clustered = true;
        }
    }

    procedure SetItemCount()
    var
        TempItem: Record Item temporary;
        BonusContract: Record "lbtbn Bonus Contract";
        dia: Dialog;
    begin
        if GuiAllowed then
            dia.Open('processing');
        Rec.GetItems(TempItem);
        Rec."Item Count" := TempItem.Count();
        Rec.Modify();
        BonusContract.Get(Rec."Contract No.");
        BonusContract.SetItemCount();
        if GuiAllowed then
            dia.Close();
    end;

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
            if SetItemFilter(FilterPage.GetView(Item.TableCaption)) then
                SetItemCount();

    end;

    procedure SetItemFilter(FilterText: Text) FilterChanged: Boolean
    var
        outs: OutStream;
        ins: InStream;
        xFilterText: Text;
    begin
        xRec.CalcFields("Item Filter");
        xRec."Item Filter".CreateInStream(ins);
        ins.ReadText(xFilterText);
        if xFilterText = FilterText then
            exit(false);
        Clear(Rec."Item Filter");
        Rec."Item Filter".CreateOutStream(outs);
        outs.WriteText(FilterText);
        Rec.Modify();
        exit(true);
    end;

    procedure GetItems(var TempItem: Record Item temporary)
    var
        BonusContractAttribute: Record "lbtbn BonusContractAttribute";
        Item: Record Item;
    begin
        Item.SetView(Rec.GetItemFilter());
        Item.LoadFields("No.");
        if Item.FindSet() then
            repeat
                TempItem := Item;
                TempItem.Insert();
            until Item.Next() = 0;
        BonusContractAttribute.SetRange(Contract, Rec."Contract No.");
        BonusContractAttribute.SetRange("Bonus Item Entry No.", Rec."Entry No.");
        if BonusContractAttribute.FindSet() then
            repeat
                if TempItem.FindSet() then
                    repeat
                        if not CheckAttribute(BonusContractAttribute, TempItem."No.") then
                            TempItem.Delete();
                    until TempItem.Next() = 0;
            until BonusContractAttribute.Next() = 0;
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

    local procedure CheckAttribute(var BonusContractAttribute: Record "lbtbn BonusContractAttribute"; ItemNo: Code[20]): Boolean
    var
        ItemAttributeValue: Record "Item Attribute Value";
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
    begin
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
        exit(true);
    end;

}