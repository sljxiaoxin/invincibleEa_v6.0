//+------------------------------------------------------------------+
//|                                                   |
//|                                 Copyright 2015    |
//|                                              yangjx009@139.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018."
#property link      "http://www.yjx.com"

#include "inc\CTrade.mqh";
#include "inc\CMa.mqh";
#include "inc\CStoch.mqh";
#include "inc\CTicket.mqh";
#include "inc\CPriceAction.mqh";
//#include "inc\CStochCross.mqh";
#include "inc\CSignal.mqh";

class CStrategy
{  
   private:
   
     datetime CheckTimeM1;
     datetime CheckTimeM5; 
     double   Lots;
     int      Tp;
     int      Sl;
     
     CTrade* oCTrade;
     CMa* oCMa_M5_fast;    //M5 for trend
     CMa* oCMa_M5_slow;
     CMa* oCMa_M1_fast;    //M1  for signal
     CMa* oCMa_M1_slow;
     CStoch* oCStoch_fast;
     CStoch* oCStoch_mid;
     CStoch* oCStoch_slow;
     CTicket* oCTicket;
     CSignal* oCSignal;
     //CPriceAction* oCPriceAction;
     
     string mTrend;          //main trend up down none
     //bool mIsOpen;         //if current signal has open order
     string mSignalType;   //buy sell none;
     //int mSignalPass;   //from signal income pass K number
     
     bool mIsReadyBuy;
     double mThresholdBuy; //阈值
     bool mIsReadySell;
     double mThresholdSell;
     
     
    
     void Update();
     void GetTrend();
     void OnTrendChange(); //trend change callback
     
     
     
     
   public:
      
      CStrategy(int Magic){
         oCTrade        = new CTrade(Magic);
         oCMa_M1_fast   = new CMa(PERIOD_M1,10);
         oCMa_M1_slow   = new CMa(PERIOD_M1,30);
         oCMa_M5_fast   = new CMa(PERIOD_M5,10);
         oCMa_M5_slow   = new CMa(PERIOD_M5,30);
         
         oCStoch_fast   = new CStoch(PERIOD_M1,7);
         oCStoch_mid    = new CStoch(PERIOD_M1,14);
         oCStoch_slow = new CStoch(PERIOD_M1,100);
         oCTicket     = new CTicket(oCTrade);
         oCSignal = new CSignal(oCMa_M1_fast, oCStoch_fast, oCStoch_mid, oCStoch_slow);
         
         //mIsOpen     = false;
         this.mTrend      = "none";
         this.mSignalType = "none";
         //mSignalPass = -1;
         
         this.mIsReadyBuy = false;
         this.mIsReadySell = false;
         
      };
      
      void Init(double _lots, int _tp, int _sl);
      void Tick();
      void Entry();
      void Exit();
      void CheckOpen();
      string getTrend();
      
      bool isAllowBuy();
      bool isAllowSell();
      
};

void CStrategy::Init(double _lots, int _tp, int _sl)
{
   Lots = _lots;
   Tp = _tp;
   Sl = _sl;
}

void CStrategy::Tick(void)
{  
    
    //every M1 do
    if(CheckTimeM1 != iTime(NULL,PERIOD_M1,0)){
         CheckTimeM1 = iTime(NULL,PERIOD_M1,0);
         this.Update();
         this.Exit();
         this.Entry();
    }
    //every M5 do
    if(CheckTimeM5 != iTime(NULL,PERIOD_M5,0)){
         CheckTimeM5 = iTime(NULL,PERIOD_M5,0);
         //GET new trend
         this.GetTrend();
    }
    
    CheckOpen();
}

void CStrategy::Update()
{
   oCMa_M1_fast.Fill();
   oCMa_M1_slow.Fill();
   oCMa_M5_fast.Fill();
   oCMa_M5_slow.Fill();
   
   oCStoch_fast.Fill();
   oCStoch_mid.Fill();
   oCStoch_slow.Fill();
   oCTicket.Update();
}

string CStrategy::getTrend()
{
   return this.mTrend;
}

void CStrategy::GetTrend()
{
   if(oCMa_M5_fast.data[2]< oCMa_M5_slow.data[2] && oCMa_M5_fast.data[1]> oCMa_M5_slow.data[1]){
      if(Close[1]>= Open[1] && Close[1]>=oCMa_M5_fast.data[1])
      {
         this.mTrend = "up";
         this.OnTrendChange();
      }
   }
   if(oCMa_M5_fast.data[2]> oCMa_M5_slow.data[2] && oCMa_M5_fast.data[1]< oCMa_M5_slow.data[1]){
      if(Close[1]<= Open[1] && Close[1]<=oCMa_M5_fast.data[1])
      {
         this.mTrend = "down";
         this.OnTrendChange();
      }
   }
   if(this.mTrend == "up" && oCMa_M5_fast.data[1]< oCMa_M5_slow.data[1]){
      if(Close[1]<=oCMa_M5_fast.data[1])
      {
         this.mTrend = "down";
         this.OnTrendChange();
      }
   }
   if(this.mTrend == "down" && oCMa_M5_fast.data[1]> oCMa_M5_slow.data[1]){
      if(Close[1]>=oCMa_M5_fast.data[1])
      {
         this.mTrend = "up";
         this.OnTrendChange();
      }
   }
}


void CStrategy::OnTrendChange()
{
   oCTicket.Close();
}


void CStrategy::Exit()
{
   
}

void CStrategy::CheckOpen()
{
   if(this.mIsReadyBuy){
      if(Ask <= this.mThresholdBuy)
      {
         this.mIsReadyBuy = false;
          oCTicket.Buy(Lots, Tp, Sl, "mtf2");
      }
   }
   if(this.mIsReadySell){
      if(Bid >= this.mThresholdSell)
      {
         this.mIsReadySell = false;
         oCTicket.Sell(Lots, Tp, Sl, "mtf2");
      }
   }
}

void CStrategy::Entry()
{
   this.mIsReadyBuy = false;
   this.mIsReadySell = false;
   if(!oCTicket.isCanOpenOrder()){
      return ;
   }
   this.mSignalType = oCSignal.GetSignal(this.mTrend);
   Print("this.mSignalType=",this.mSignalType);
   if(this.mSignalType == "none"){
      return ;
   }
   Print("Ask - Bid = ",Ask - Bid);
   Print("3*oCTrade.GetPip() = ",3*oCTrade.GetPip());
   if(Ask - Bid <2.5*oCTrade.GetPip() ){
      Print("-----in 1-----");
      if(this.mSignalType == "buy" && oCMa_M1_fast.data[1]>oCMa_M1_fast.data[2]){// && Ask>oCMa_M5_slow.data[1]){
         if(oCStoch_fast.data[1] < oCStoch_fast.data[2] || oCStoch_fast.data[1]>82)
         {
            return ;
         }
         /*
         if(oCStoch_fast.data[1] > 70 && oCStoch_mid.data[1]> 70 && oCStoch_slow.data[1]> 70){
            return ;
         }
         */
         ///*
         if(!this.isAllowBuy()){
            return ;
         }
         //*/
         if(oCStoch_fast.data[1] >=oCStoch_mid.data[1] || oCStoch_fast.data[1] >=oCStoch_slow.data[1])
         {
            this.mIsReadyBuy = true;
            if(Close[1] >= oCMa_M1_fast.data[1]){
               this.mThresholdBuy = oCMa_M1_fast.data[1] + (Close[1]-oCMa_M1_fast.data[1])/2;  //距离的一半
            }else{
               this.mThresholdBuy = oCMa_M1_fast.data[1];
            }
            Print("-----in 2-----");
            if(Ask-oCMa_M1_fast.data[1]<2.5*oCTrade.GetPip()){
               Print("-----in 3-----");
               this.mIsReadyBuy = false;
               oCTicket.Buy(Lots, Tp, Sl, "mtf1");
            }
         }
      }
      
      if(this.mSignalType == "sell" && oCMa_M1_fast.data[1]<oCMa_M1_fast.data[2]){// && Bid<oCMa_M5_slow.data[1]){
         if(oCStoch_fast.data[1] > oCStoch_fast.data[2] || oCStoch_fast.data[1]<18)
         {
            return ;
         }
         /*
         if(oCStoch_fast.data[1] < 30 && oCStoch_mid.data[1]< 30 && oCStoch_slow.data[1]< 30){
            return ;
         }
         */
        // /*
         if(!this.isAllowSell()){
            return ;
         }
        // */
         if(oCStoch_fast.data[1] <=oCStoch_mid.data[1] || oCStoch_fast.data[1] <=oCStoch_slow.data[1])
         {
            this.mIsReadySell = true;
            if(Close[1] <= oCMa_M1_fast.data[1]){
               this.mThresholdSell = oCMa_M1_fast.data[1] - (oCMa_M1_fast.data[1] - Close[1])/2;  //距离的一半
            }else{
               this.mThresholdSell = oCMa_M1_fast.data[1];
            }
            Print("-----in 4-----");
            if(oCMa_M1_fast.data[1] -Bid <2.5*oCTrade.GetPip()){
               Print("-----in 5-----");
               this.mIsReadySell = false;
               oCTicket.Sell(Lots, Tp, Sl, "mtf");
            }
         }
      }
   }
   
}

bool CStrategy::isAllowBuy()
{
   bool isCrossOk = false;
   for(int i=1;i<=10;i++){
      if(oCStoch_fast.data[i] < oCStoch_slow.data[i] && oCStoch_fast.data[i+1] > oCStoch_slow.data[i+1]){
         return false;
      }
      if(oCStoch_fast.data[i] > oCStoch_slow.data[i] && oCStoch_fast.data[i+1] < oCStoch_slow.data[i+1]){
         isCrossOk = true;
      }
   }
   return isCrossOk;
}
bool CStrategy::isAllowSell()
{
   bool isCrossOk = false;
   for(int i=1;i<=10;i++){
      if(oCStoch_fast.data[i] > oCStoch_slow.data[i] && oCStoch_fast.data[i+1] < oCStoch_slow.data[i+1]){
         return false;
      }
      if(oCStoch_fast.data[i] < oCStoch_slow.data[i] && oCStoch_fast.data[i+1] > oCStoch_slow.data[i+1]){
         isCrossOk = true;
      }
   }
   return isCrossOk;
}