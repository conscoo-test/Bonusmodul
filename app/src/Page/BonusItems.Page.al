page 5266065 "lbtbn Bonus Items"
{
    PageType = List;
    SourceTable = "lbtbn Bonus Item";
    Caption = 'Bonus Items';
    UsageCategory = None;

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
                    Caption = 'Item Filter';
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        Rec.AssistEdit();
                        Rec.SetItemCount();
                    end;
                }
                field("Attribute Filter"; SetAttributeFilterTxt)
                {
                    Caption = 'Attribute Filter';
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
                        Rec.SetItemCount();
                    end;
                }
                field(ItemCount; Rec."Item Count")
                {
                    Caption = 'Item Count';
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnDrillDown()
                    var
                        TempItem: Record Item temporary;
                        PageManagement: Codeunit "Page Management";
                        dia: Dialog;
                    begin
                        if GuiAllowed then
                            dia.Open('processing');
                        Rec.GetItems(TempItem);
                        TempItem."No." := ''; // Force PageManagement to open List
                        PageManagement.PageRun(TempItem);
                        if GuiAllowed then
                            dia.Close();
                    end;
                }
            }
        }
    }

    var
        SetItemFilterTxt: Label 'Set Item Filter';
        SetAttributeFilterTxt: Label 'Set Attribute Filter';
}