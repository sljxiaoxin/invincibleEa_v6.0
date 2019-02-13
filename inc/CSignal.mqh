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
      static const int mMaxOverNum;
      
      CStoch* oStochFast; //7
      CStoch* oStochMid;  //14
      CStoch* oStochSlow; //100
      
      static const int mLockNum;      //stoch100 from overSell to big than 20 lock sell，from overBuy to lower than 80 lock buy
      bool mIsLocked;    //lock status
      string mLockType;  //buy(can not buy) or sell(can not sell)
      int mLockPassNum;  //after lock pass num
      
      int buySignalLowestIndex;  //buy信号时，价格（不是stoch）最低的那个index
      int sellSignalHighestIndex;
      
      
      
     
   public:
      
      
      CSignal(CStoch* _oStochFast, CStoch* _oStochMid, CStoch* _oStochSlow){
         oStochFast = _oStochFast;
         oStochMid  = _oStochMid;
         oStochSlow = _oStochSlow;
         
         buySignalLowestIndex = -1;
         sellSignalHighestIndex = -1;
      };
      
      void Update();
      
      string GetSignal();
      
      void LockDeal();
      void Lock(string t);
      void UnLock();
      
      bool CheckBuyInlock();
      bool CheckSellInlock();
      
      bool CheckBuySignal();
      bool CheckSellSignal();
      
      int GetBuySignalLowestIndex();   //buy信号时最低的那个index
      int GetSellSignalHighestIndex();
};
const int CSignal::mLockNum = 20; //slow从over穿出来，锁定多少根
const int CSignal::mMaxOverNum = 5;  //信号以最多多少根over区标准
const int CSignal::mMinHighLowDis = 50; //stoch fast 最小距离

void CSignal::Update()
{
   this.LockDeal();
}

void CSignal::LockDeal()
{
   if(this.mIsLocked){
      this.mLockPassNum += 1;
      if(this.mLockPassNum >=  this.mLockNum){
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
string CSignal::GetSignal()
{
   if(this.mIsLocked){
      //锁定期间
      bool lb = this.CheckBuyInlock();
      if(lb){
         return "buyInlock";
      }
      bool ls = this.CheckSellInlock();
      if(ls){
         return "sellInlock";
      }
   }else{
      //非锁定期间
      bool b = this.CheckBuySignal();
      if(b){
         return "buy";
      }else{
         bool s = this.CheckSellSignal();
         if(s){
            return "sell";
         }
      }
   }
   return "none";
}


//lock的情况下
 bool CSignal::CheckBuyInlock()
 {
    if(this.mIsLocked && this.mLockType == "sell"){
       //when lock sell status, check Buy opportunity on stochFast not cross overSell area.
       if(oStochSlow.data[1] <= 65){
          if(oStochFast.data[1] > oStochFast.data[2] && oStochFast.data[3] > oStochFast.data[2]){
            if(oStochSlow.data[2] > 21 && oStochFast.data[2] > oStochSlow.data[2] && oStochFast.data[2] - oStochSlow.data[2] <10){
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
       
       if(oStochSlow.data[1] >= 35){
         if(oStochFast.data[1] < oStochFast.data[2] && oStochFast.data[3] < oStochFast.data[2]){
            if(oStochSlow.data[2] < 79 && oStochFast.data[2] < oStochSlow.data[2] && oStochSlow.data[2] - oStochFast.data[2] <10){
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
 
bool CSignal::CheckBuySignal()
{
   //mMaxOverNum
   if(oStochFast.data[1] >20 && oStochFast.data[2]<20){
      if(oStochSlow.data[1] < 20 || oStochSlow.data[2]<20){
         return false;
      }
      if(oStochSlow.data[1] <oStochSlow.data[2]){
         return false;
      }
      if(oStochFast.data[1] > oStochMid.data[1] || oStochMid.data[1] > oStochMid.data[2]){
         if(oStochMid.data[1] <20 && oStochMid.data[1] < oStochMid.data[2]){
            return false;
         }
         int count = 0;
         int endIdx = 2;   //最后一个处于over区的index
         for(int i=2;i<20;i++){
            count += 1;
            if(oStochFast.data[i]>20){
               endIdx = i-1;
               break;
            }
         }
         if(count <= this.mMaxOverNum){
            //从多高掉下来的判断
            double h = oStochFast.HighValue(2, 10);
            double l = oStochFast.LowValue(2, 10);
            int lowIdx = oStochFast.LowIndex(2,10);
            if(lowIdx <= endIdx && h -l >this.mMinHighLowDis){
               double lowClose = 9999999;
               int lowCloseIndex = -1;
               for(i=2;i<=endIdx;i++){
                  if(Close[i] < lowClose){
                     lowClose = Close[i];
                     lowCloseIndex = i;
                  }
               }
               buySignalLowestIndex = lowCloseIndex;
               return true;
            }
         }
      }
      
   }
   return false;
}

bool CSignal::CheckSellSignal()
{
   if(oStochFast.data[1] <80 && oStochFast.data[2]>80){
      if(oStochSlow.data[1] >80 || oStochSlow.data[2]>80){
         return false;
      }
      if(oStochSlow.data[1] >oStochSlow.data[2]){
         return false;
      }
      if(oStochFast.data[1] < oStochMid.data[1] || oStochMid.data[1] < oStochMid.data[2]){
         if(oStochMid.data[1] >80 && oStochMid.data[1] > oStochMid.data[2]){
            return false;
         }
         int count = 0;
         int endIdx = 2;   //最后一个处于over区的index
         for(int i=2;i<20;i++){
            count += 1;
            if(oStochFast.data[i]<80){
               endIdx = i-1;
               break;
            }
         }
         if(count <= this.mMaxOverNum){
            //从多高掉下来的判断
            double h = oStochFast.HighValue(2, 10);
            double l = oStochFast.LowValue(2, 10);
            int highIdx = oStochFast.HighIndex(2,10);
            if(highIdx <= endIdx && h -l >this.mMinHighLowDis){
               double highClose = -1;
               int highCloseIndex = -1;
               for(i=2;i<=endIdx;i++){
                  if(Close[i] > highClose){
                     highClose = Close[i];
                     highCloseIndex = i;
                  }
               }
               sellSignalHighestIndex = highCloseIndex;
               return true;
            }
         }
      }
      
   }
   return false;
}

//buy信号时最低的那个index
int CSignal::GetBuySignalLowestIndex(){
   return buySignalLowestIndex;
}

//sell信号时最高的那个index
int CSignal::GetSellSignalHighestIndex(){
   return sellSignalHighestIndex;
}