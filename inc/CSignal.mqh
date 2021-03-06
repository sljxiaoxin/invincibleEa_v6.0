//+------------------------------------------------------------------+
//|                                                   |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.yjx.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018."
#property link      "http://www.yjx.com"
#include "CStoch.mqh";

class CSignal
{  
   private:
      CMa* oCMa_M1_fast;
      
      CStoch* oStochFast; //7
      CStoch* oStochMid;  //14
      CStoch* oStochSlow; //100
      
      
      
   public:
      
      
      CSignal(CMa* _oCMa_M1_fast, CStoch* _oStochFast, CStoch* _oStochMid, CStoch* _oStochSlow){
         
         oCMa_M1_fast = _oCMa_M1_fast;
         
         oStochFast = _oStochFast;
         oStochMid  = _oStochMid;
         oStochSlow = _oStochSlow;
      };
      
      string GetSignal(string trend);      //trend is up / down
      string CheckBuySignal();
      string CheckSellSignal();
      
   private:
      
      bool CheckBuy();
      bool CheckSell();
};

// buy / sell / none
string CSignal::GetSignal(string trend)
{
   if(trend == "up"){
      return this.CheckBuySignal();
   }else if(trend == "down"){
      return this.CheckSellSignal();
   }
   return "none";
}
 
string CSignal::CheckBuySignal()
{
     Print("oStochFast.data=>",oStochFast.data[2]," ，",oStochFast.data[1]);
     //Print("oStochMid.data=>",oStochMid.data[2]," ，",oStochMid.data[1]);
     //Print("oStochSlow.data=>",oStochSlow.data[2]," ，",oStochSlow.data[1]);
     if(oStochFast.data[1] <21){// || oCMa_M1_fast.data[1]<oCMa_M1_fast.data[2]){
         return "none";
     }
     
     if(this.CheckBuy()){
         return "buy";
     }
     return "none";
}

string CSignal::CheckSellSignal()
{
     Print("oStochFast.data=>",oStochFast.data[2]," ，",oStochFast.data[1]);
     //Print("oStochMid.data=>",oStochMid.data[2]," ，",oStochMid.data[1]);
     //Print("oStochSlow.data=>",oStochSlow.data[2]," ，",oStochSlow.data[1]);
     if(oStochFast.data[1] >79){// || oCMa_M1_fast.data[1]>oCMa_M1_fast.data[2]){
         return "none";
     }
     if(this.CheckSell()){
         return "sell";
     }
     return "none";
}

bool CSignal::CheckBuy()
{
   Print("----------------CheckBuy----------------");
   //M5上升趋势，m1fast向上，并且从当前柱体往前倒数8个看是否有stochfast位于20以下，并且倒数第12个前是否有位于50以上
   for(int i=1;i<=12;i++){
       if(oStochFast.data[i]<21) return true;
   }
   return false;
   /*
   int idx = -1;
   for(int i=1;i<=16;i++){
      if(oStochFast.data[i]<21){
         idx = i;
         break;
      }
   }
   if(idx == -1)return false;
   for(int i=idx;i<=16;i++){
      if(oStochFast.data[i]>50){
         return true;
      }
   }
   return false;
   */
}

bool CSignal::CheckSell()
{
   Print("----------------CheckSell----------------");
   for(int i=1;i<=12;i++){
       if(oStochFast.data[i]>79) return true;
   }
   return false;
   /*
   int idx = -1;
   for(int i=1;i<=16;i++){
      if(oStochFast.data[i]>79){
         idx = i;
         break;
      }
   }
   if(idx == -1)return false;
   for(int i=idx;i<=16;i++){
      if(oStochFast.data[i]<50){
         return true;
      }
   }
   return false;
   */
   
}