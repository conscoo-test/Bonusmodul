table 5266057 "lbt Bonus Group"
{
   Caption = 'Bonus Group', comment = 'DEU="Bonusgruppe"';
   DataClassification = CustomerContent;
   
   fields
   {
      field(1;"lbt Code"; Code [20])
      {
         Caption = 'Code', comment = 'DEU="Code"';
         DataClassification = CustomerContent;
      }
      field(2; "lbt Description"; Text [100])
      {
         Caption = 'Description', comment = 'DEU="Beschreibung"';
         DataClassification = CustomerContent;
      }
      


   }
   
   keys
   {
      key(PK; "lbt Code")
      {
         Clustered = true;
      }
   }
   
}