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
      CStoch* oStochFast; //7
      CStoch* oStochMid;  //14
      CStoch* oStochSlow; //100
      
      int mLockNum;      //stoch100 from overSell to big than 20 lock sell，from overBuy to lower than 80 lock buy
      bool mIsLocked;    //lock status
      string mLockType;  //buy(can not buy) or sell(can not sell)
      int mLockPassNum;  //after lock pass num
      
      
      
     
   public:
      
      
      CSignal(CStoch* _oStochFast, CStoch* _oStochMid, CStoch* _oStochSlow){
         this.mLockNum = 50;
         oStochFast = _oStochFast;
         oStochFast = _oStochMid;
         oStochSlow = _oStochSlow;
      };
      
      void Tick();
      
      string GetEntrySignal();
      string GetExitSignal();
      void LockDeal();
      void Lock(string t);
      void UnLock();
      
      bool CheckBuyInlock();
      bool CheckSellInlock();
};

void CSignal::Tick()
{
   this.LockDeal();
}

void CSignal::LockDeal()
{
   if(this.mIsLocked){
      this.mLockPassNum += 1;
      if(this.mLockPassNum >= this.mLockNum){
         this.UnLock();
      }
      if(this.mLockType == "buy"){
         if(oStochSlow.data[1] < 20){
            this.UnLock();
         }
      }
      if(this.mLockType == "sell"){
         if(oStochSlow.data[1] > 80){
            this.UnLock();
         }
      }
   }else{
      if(oStochSlow.data[2] < 20 && oStochSlow.data[2] > 20){
         this.Lock("sell");
      }
      if(oStochSlow.data[2] > 80 && oStochSlow.data[2] < 80){
         this.Lock("buy");
      }
   }
}

void CSignal::Lock(string t)
{
   this.mIsLocked = true;
   this.mLockType = t;
   this.mLockPassNum = 0;
}

void CSignal::UnLock()
{
   this.mIsLocked = false;
   this.mLockType = "";
   this.mLockPassNum = 0;
}




//buy sell buyInlock sellInlock
string CSignal::GetEntrySignal()
{
   if(oStochFast.data[2]< 20 && oStochFast.data[1]> 20){
      return "up";  
   }
   if(oStochFast.data[2]> 80 && oStochFast.data[1]< 80){
      return "down";  
   }
   return "none";
}

string CSignal::GetExitSignal()
{
   //TODO
   return "none";
}



 bool CSignal::CheckBuyInlock()
 {
    if(this.mIsLocked && this.mLockType == "sell"){
       //when lock sell status, check Buy opportunity on stochFast not cross overSell area.
       if(oStochSlow.data[1] <= 55){
          if(oStochFast.data[1] > oStochFast.data[2] && oStochFast.data[3] > oStochFast.data[2]){
            if(oStochSlow.data[2] > 21 && oStochFast.data[2] > oStochSlow.data[2] && oStochFast.data[2] - oStochSlow.data[2] <7){
               for(int i = 2;i<10;i++){
                  if(oStochSlow.data[i+1] < oStochSlow.data[i]){
                     break;
                  }
               }
               if(oStochSlow.data[i] - oStochSlow.data[2] > 15){
                  return true;
               }
            }
          }
       }
    }
    return false;
 }
 
 bool CSignal::CheckSellInlock()
 {
    if(this.mIsLocked && this.mLockType == "buy"){
       
       if(oStochSlow.data[1] >= 45){
         if(oStochFast.data[1] < oStochFast.data[2] && oStochFast.data[3] < oStochFast.data[2]){
            if(oStochSlow.data[2] < 79 && oStochFast.data[2] < oStochSlow.data[2] && oStochSlow.data[2] - oStochFast.data[2] <7){
               for(int i = 2;i<10;i++){
                  if(oStochSlow.data[i+1] > oStochSlow.data[i]){
                     break;
                  }
               }
               if(oStochSlow.data[2] - oStochSlow.data[i] > 15){
                  return true;
               }
            }
          }
       }
    }
    return false;
 }