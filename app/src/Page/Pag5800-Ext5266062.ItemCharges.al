pageextension 5266062 "lbt Item Charges" extends "Item Charges" //5800
{
   layout
   {
      addlast(Control1)
      {

         
          field("lbt Bonus consider";"lbt Bonus consider")
          {
              ToolTip = 'Indicate which surcharges and discounts are relevant for bonus.', comment = 'DEU="Kennzeichnen, welche ZU-/ABSCHLÄGE Bonusrelevant sind."';
              ApplicationArea = All;
          }
      }
      
   }
   
   actions
   {
   }
}