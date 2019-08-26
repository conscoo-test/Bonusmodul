codeunit 5266052 "lbt Bonus Mgt."
{
   trigger OnRun()
   begin
      
   end;
   
   procedure SetAssignmentDoc(AssignmentDocTypeP :Option " ","Sales Shipment","Sales Return Receipt";
                              AssignmentDocNoP : Code[20];
                              AssignmentDocLineNoP : Integer)
   begin
      //TODO Funktion "SetAssignmentDoc" muss noch umgesetzt werden
   end;

procedure SetSourceDoc(SourceDocTypeP : Integer;SourceDocNoP : Code[20];SourceDocLineNoP : Integer)
begin
   //TODO Funktion "SetSourceDoc" muss noch umgesetzt werden
end;
procedure SetBonusDoc(BonusDocTypeP : Integer;BonusDocNoP : Code[20];BonusDocLineNoP : Integer)
begin
   //TODO Funktion "SetBonusDoc" muss noch umgesetzt werden
end;

procedure CreateBonusContractEntry (VAR ContractRec : Record "lbt Bonus Contract";
                                    VAR BonusCustRec : Record "lbt Bonus Customers";
                                    EntryType : Option "Bonus","Rückstellung","Rückstellungsauflösung";
                                    VAR EntryDate : Date;
                                    BonusRule : Integer;
                                    Qty : Decimal;
                                    Amt : Decimal;
                                    AmtIncVAT : Decimal;
                                    DocAmt: Decimal;
                                    DiscAmt: Decimal;
                                    PmtDiscAmt: Decimal
):Integer
begin
   //TODO Funktion "CreateBonusContractEntry" muss noch umgesetzt werden
end;
}