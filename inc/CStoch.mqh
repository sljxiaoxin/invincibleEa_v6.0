//+------------------------------------------------------------------+
//|                                                   |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.yjx.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018."
#property link      "http://www.yjx.com"

class CStoch
{  
   private:
     int period;
     int tf;   //PERIOD_M1
     
   public:
      double data[50];
      
      CStoch(int _tf, int _period){
         period = _period;
         tf = _tf;
         Fill();
      };
      
      void Fill();
      bool IsUp();
      bool IsDown();
      double HighValue(int beginIndex, int counts); 
      double LowValue(int beginIndex, int counts);
      double Distance(int beginIndex, int counts);
      
      int HighIndex(int beginIndex, int counts); 
      int LowIndex(int beginIndex, int counts);
};

void CStoch::Fill()
{
   for(int i=0;i<50;i++){
      data[i] = iStochastic(NULL, tf, period, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
   }
}

bool CStoch::IsUp()
{
   if(data[1] > data[2] && data[2]>=data[3]){
      return true;
   }
   return false;
}

bool CStoch::IsDown()
{
   if(data[1] < data[2] && data[2]<=data[3]){
      return true;
   }
   return false;
}

double CStoch::HighValue(int beginIndex, int counts)
{
   double h = -1;
   int limit = beginIndex+counts;
   for(int i=beginIndex;i<limit;i++){ 
      if(data[i] > h){
         h = data[i];
      }
   }
   return h;
}

double CStoch::LowValue(int beginIndex, int counts)
{
   double l = 9999999;
   int limit = beginIndex+counts;
   for(int i=beginIndex;i<limit;i++){ 
      if(data[i] < l){
         l = data[i];
      }
   }
   return l;
}

double CStoch::Distance(int beginIndex, int counts)
{
   double h = this.HighValue(beginIndex, counts);
   double l = this.LowValue(beginIndex, counts);
   return h - l;
}

int CStoch::HighIndex(int beginIndex, int counts)
{
   double h = -1;
   int idx = beginIndex;
   int limit = beginIndex+counts;
   for(int i=beginIndex;i<limit;i++){ 
      if(data[i] > h){
         h = data[i];
         idx = i;
      }
   }
   return idx;
}

int CStoch::LowIndex(int beginIndex, int counts)
{
   double l = 9999999;
   int idx = beginIndex;
   int limit = beginIndex+counts;
   for(int i=beginIndex;i<limit;i++){ 
      if(data[i] < l){
         l = data[i];
         idx = i;
      }
   }
   return idx;
}