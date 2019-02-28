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

     if(oCMa_M1_fast.data[1]<=oCMa_M1_fast.data[2]){
         return "none";
     }
     Print("oStochFast.data=>",oStochFast.data[2]," ，",oStochFast.data[1]);
     Print("oStochMid.data=>",oStochMid.data[2]," ，",oStochMid.data[1]);
     Print("oStochSlow.data=>",oStochSlow.data[2]," ，",oStochSlow.data[1]);
     if(oStochFast.data[1] > oStochFast.data[2] && oStochMid.data[1] > oStochMid.data[2]){
         if(oStochSlow.data[1] > oStochSlow.data[2] || oStochSlow.data[1]>79){
            if(oStochFast.data[1] > oStochMid.data[1]){
               return "buy";
            }
         }
     }
     if(oStochFast.data[1]>79 && oStochSlow.data[1] >79 && oStochFast.data[1] > oStochFast.data[2]){
         return "buy";
     }
     return "none";
}

string CSignal::CheckSellSignal()
{
     if(oCMa_M1_fast.data[1]>=oCMa_M1_fast.data[2]){
         return "none";
     }
     if(oStochFast.data[1] < oStochFast.data[2] && oStochMid.data[1] < oStochMid.data[2]){
         if(oStochSlow.data[1] < oStochSlow.data[2] || oStochSlow.data[1]<21){
            if(oStochFast.data[1] < oStochMid.data[1]){
               return "sell";
            }
         }
     }
     if(oStochFast.data[1]<21 && oStochSlow.data[1] <21 && oStochFast.data[1] < oStochFast.data[2]){
         return "sell";
     }
     return "none";
}