codeunit 5266055 "lbtbn CheckAttributes Meth"
{
    var
        Memo: Dictionary of [Code[20], Dictionary of [Code[20], Boolean]];

    /// <summary>
    /// Checks if the item is valid for Bonus for this Contract. The results are saved, so subsequent calls with the same parameters
    /// are more efficient. To take advantage of this use the same instance of the codeunit for each call. For example make it a 
    /// global variable in your report.
    /// </summary>
    /// <param name="BonusContractNo">Code[20].</param>
    /// <param name="ItemNo">Code[20].</param>
    /// <returns>Return variable Result of type Boolean.</returns>
    internal procedure CheckAttributes(BonusContractNo: Code[20]; ItemNo: Code[20]) Result: Boolean
    var
        IsHandled: Boolean;
    begin
        OnBeforeCheckAttributes(BonusContractNo, ItemNo, Result, IsHandled);
        if not IsHandled then
            Result := CheckAttributesWithMemoization(BonusContractNo, ItemNo);

        OnAfterCheckAttributes(BonusContractNo, ItemNo, Result);
    end;

    local procedure CheckAttributesWithMemoization(BonusContractNo: Code[20]; ItemNo: Code[20]) Result: Boolean;
    var
        InnerDict: Dictionary of [Code[20], Boolean];
    begin
        if Memo.ContainsKey(BonusContractNo) then
            if Memo.Get(BonusContractNo).ContainsKey(ItemNo) then
                exit(Memo.Get(BonusContractNo).Get(ItemNo));

        Result := DoCheckAttributes(BonusContractNo, ItemNo);

        if not Memo.Get(BonusContractNo, InnerDict) then
            Memo.Add(BonusContractNo, InnerDict);

        InnerDict.Add(ItemNo, Result);
    end;

    local procedure DoCheckAttributes(BonusContractNo: Code[20]; ItemNo: Code[20]): Boolean;
    var
        ItemAttributeValue: Record "Item Attribute Value";
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
        BonusContractAttribute: Record "lbtbn BonusContractAttribute";
    begin
        BonusContractAttribute.SetRange(Contract, BonusContractNo);
        repeat
            if ItemAttributeValueMapping.Get(Database::Item, ItemNo, BonusContractAttribute."Attribute ID") then begin
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
            end;
        #region commented code
        //     if PostParaDocLineRec.FindFirst then begin

        //         case BonusContractAttribute."Attribute Type" of
        //             BonusContractAttribute."Attribute Type"::Text:
        //                 begin
        //                     PostParaDocLineRec.SetFilter("Parameter Domain", BonusContractAttribute."Parameter Filter");

        //                     if PostParaDocLineRec.ISEMPTY then
        //                         Continue := false;
        //                 end;
        //             BonusContractAttribute."Attribute Type"::Decimal:
        //                 begin
        //                     if BonusContractAttribute."Parameter Filter" <> '' then begin
        //                         if StrPos(BonusContractAttribute."Parameter Filter", '<>') = 1 then
        //                             PostParaDocLineRec.SetFilter("Decimal from", BonusContractAttribute."Parameter Filter")
        //                         else begin
        //                             if StrPos(BonusContractAttribute."Parameter Filter", '..') = 1 then
        //                                 PostParaDocLineRec.SetFilter("Decimal from", '..' + ForMAT(BonusContractAttribute."Decimal to"))
        //                             else
        //                                 PostParaDocLineRec.SetFilter("Decimal to", ForMAT(BonusContractAttribute."Decimal from") + '..');
        //                         end;
        //                     end else begin
        //                         if (BonusContractAttribute."Decimal from" <> 0) and (BonusContractAttribute."Decimal to" <> 0) then begin
        //                             PostParaDocLineRec.SetFilter("Decimal from", ForMAT(BonusContractAttribute."Decimal from") + '..' +
        //                                                                         ForMAT(BonusContractAttribute."Decimal to"));
        //                             PostParaDocLineRec.SetFilter("Decimal to", ForMAT(BonusContractAttribute."Decimal from") + '..' +
        //                                                                       ForMAT(BonusContractAttribute."Decimal to"));
        //                         end;
        //                         if (BonusContractAttribute."Decimal from" <> 0) and (BonusContractAttribute."Decimal to" = 0) then
        //                             PostParaDocLineRec.SetFilter("Decimal from", ForMAT(BonusContractAttribute."Decimal from") + '..');

        //                         if (BonusContractAttribute."Decimal from" < 0) and (BonusContractAttribute."Decimal to" = 0) then begin
        //                             PostParaDocLineRec.SetFilter("Decimal from", ForMAT(BonusContractAttribute."Decimal from") + '..' +
        //                                                                         ForMAT(BonusContractAttribute."Decimal to"));
        //                             PostParaDocLineRec.SetFilter("Decimal to", ForMAT(BonusContractAttribute."Decimal from") + '..' +
        //                                                                       ForMAT(BonusContractAttribute."Decimal to"));
        //                         end;

        //                         if (BonusContractAttribute."Decimal from" = 0) and (BonusContractAttribute."Decimal to" <> 0) then
        //                             PostParaDocLineRec.SetFilter("Decimal to", ForMAT(BonusContractAttribute."Decimal from") + '..' +
        //                                                                       ForMAT(BonusContractAttribute."Decimal to"));

        //                         if (BonusContractAttribute."Decimal from" = 0) and (BonusContractAttribute."Decimal to" < 0) then
        //                             PostParaDocLineRec.SetFilter("Decimal to", '..' + ForMAT(BonusContractAttribute."Decimal to"));
        //                     end;
        //                     ///LBIS01
        //                     //if not PostParaDocLineRec.FindSet then
        //                     if PostParaDocLineRec.ISEMPTY then
        //                         ///LBIS01-
        //                         Continue := false;
        //                 end;
        //         end;
        //     end else
        //         Continue := false;
        #endregion commented code
        until (BonusContractAttribute.Next() = 0);
        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckAttributes(var BonusContractNo: Code[20]; ItemNo: Code[20]; var Result: Boolean; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckAttributes(var BonusContractNo: Code[20]; ItemNo: Code[20]; var Result: Boolean)
    begin
    end;
}