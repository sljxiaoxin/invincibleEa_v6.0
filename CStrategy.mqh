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
     bool mIsOpen;         //if current signal has open order
     string mSignalType;   //buy sell none;
     int mSignalPass;   //from signal income pass K number
     
     
    
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
         
         mIsOpen     = false;
         mTrend      = "none";
         mSignalType = "none";
         mSignalPass = -1;
         
      };
      
      void Init(double _lots, int _tp, int _sl);
      void Tick();
      void Entry();
      void Exit();
      
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
}

void CStrategy::Update()
{
   oCMa_M1_fast.Fill();
   oCMa_M1_slow.Fill();
   oCMa_M5_fast.Fill();
   oCMa_M5_slow.Fill();
   
   oCStoch_fast.Fill();
   oCStoch_slow.Fill();
   oCTicket.Update();
   
   if(this.mSignalType != "none"){
      this.mSignalPass++;
   }
}

void CStrategy::GetTrend()
{
   if(oCMa_M5_fast.data[2]< oCMa_M5_slow.data[2] && oCMa_M5_fast.data[1]> oCMa_M5_slow.data[1]){
      this.mTrend = "up";
      this.OnTrendChange();
   }
   if(oCMa_M5_fast.data[2]> oCMa_M5_slow.data[2] && oCMa_M5_fast.data[1]< oCMa_M5_slow.data[1]){
      this.mTrend = "down";
      this.OnTrendChange();
   }
}


void CStrategy::OnTrendChange()
{
   
}


void CStrategy::Exit()
{
   
}


void CStrategy::Entry()
{
   if(!oCTicket.isCanOpenOrder()){
      return ;
   }
   this.mSignalType = oCSignal.GetSignal(this.mTrend);
   if(this.mSignalType == "none"){
      return ;
   }
   
   if(Ask - Bid <2*oCTrade.GetPip() ){
      if(this.mSignalType == "buy" && Ask>oCMa_M5_slow.data[1]){
         if(Ask-oCMa_M1_fast.data[1]<2.5*oCTrade.GetPip()){
            oCTicket.Buy(Lots, Tp, Sl, "mtfMaStoch");
         }
      }
      
      if(this.mSignalType == "sell" && Bid<oCMa_M5_slow.data[1]){
         
      }
   }
   
}