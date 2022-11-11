page 5266065 "lbtbn Bonus Items"
{
    PageType = List;
    SourceTable = "lbtbn Bonus Item";
    Caption = 'Bonus Items';

    layout
    {
        area(Content)
        {
            repeater(Repeater)
            {
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Item Filter"; SetItemFilterTxt)
                {
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        Rec.AssistEdit();
                        SetCount();
                    end;
                }
                field("Attribute Filter"; SetAttributeFilterTxt)
                {
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnDrillDown()
                    var
                        BonusContractAttribute: Record "lbtbn BonusContractAttribute";
                        PageManagement: Codeunit "Page Management";
                    begin
                        BonusContractAttribute.SetRange(Contract, Rec."Contract No.");
                        BonusContractAttribute.SetRange("Bonus Item Entry No.", Rec."Entry No.");
                        PageManagement.PageRunModal(BonusContractAttribute);
                        SetCount();
                    end;
                }
                field(ItemCount; ItemCount)
                {
                    Caption = 'Item Count';
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnDrillDown()
                    var
                        Item: Record Item;
                        PageManagement: Codeunit "Page Management";
                    begin
                        SetItemView(Item);
                        Item."No." := '';
                        PageManagement.PageRun(Item);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetCount();
    end;

    local procedure SetCount()
    var
        Item: Record Item;
    begin
        SetItemView(Item);
        ItemCount := Item.Count();
    end;

    local procedure SetItemView(var Item: Record Item)
    begin
        Item.SetView(Rec.GetItemFilter());
        if Item.FindSet() then
            repeat
                if Rec.CheckAttributes(Item."No.") then
                    Item.Mark(true);
            until Item.Next() = 0;
        Item.MarkedOnly(true);
        if Item.FindFirst() then;
    end;

    var
        ItemCount: Integer;
        SetItemFilterTxt: Label 'Set Item Filter';
        SetAttributeFilterTxt: Label 'Set Attribute Filter';
}