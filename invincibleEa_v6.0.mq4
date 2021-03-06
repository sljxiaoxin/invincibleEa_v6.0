//+------------------------------------------------------------------+
//|1、stoch3条线都30以下不开sell单。 buy同理    ok
//|2、如果sell，ma fast小于slow或slower才能开单。buy同理。  ok                                                
//|3、向前倒10个柱子，stoch slower最大值，最小值，平均值如果都落40-60，则不开单  
//4、开单后，stoch slower反向10-15？止损？                                           
//+------------------------------------------------------------------+
#property copyright "xiaoxin003"
#property link      "yangjx009@139.com"
#property version   "6.0"
#property strict

#include "CStrategy.mqh";
 
extern int       SmOne_MagicNumber  = 20190211;    
extern double    SmOne_Lots         = 0.1;
extern int       SmOne_intTP        = 6;
extern int       SmOne_intSL        = 30;
      

CStrategy* oCStrategy;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---
   Print("begin");
   if(oCStrategy == NULL){
      oCStrategy = new CStrategy(SmOne_MagicNumber);
   }
   oCStrategy.Init(SmOne_Lots,SmOne_intTP,SmOne_intSL);
   
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Print("deinit");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

void OnTick()
{
   oCStrategy.Tick();
   subPrintDetails();
}


void subPrintDetails()
{
   //
   string sComment   = "";
   string sp         = "----------------------------------------\n";
   string NL         = "\n";

   sComment = sp;
   sComment = sComment + "Trend = " + oCStrategy.getTrend() + NL; 
   sComment = sComment + sp;
   sComment = sComment + "Ask-Bid = " +(Ask-Bid) + NL; 
   sComment = sComment + sp;
   //sComment = sComment + "Lots=" + DoubleToStr(Lots,2) + NL;
   Comment(sComment);
}


