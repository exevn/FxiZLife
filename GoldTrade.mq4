//+------------------------------------------------------------------+
//|                                                    GoldTrade.mq4 |
//|                                       Copyright 2022, iZFx.Trade |
//|                                               https://fx.iz.life |
//|     _ ____  ____                                                 |
//|    (_)_  / / __/_ __                                             |
//|   / / / /_/ _/ \ \ /                                             |
//|  /_/_/___/_/  /_\_\__    __   _ ___                              |
//|    / __/_ __  (_)_  /   / /  (_) _/__                            |
//|   / _/ \ \ / / / / /__ / /__/ / _/ -_)                           |
//|  /_/  /_\_(_)_/ /___(_)____/_/_/ \__/                            |
//+------------------------------------------------------------------+

#property copyright "Copyright 2022, iZFx.Trade"
#property link      "https://fx.iz.life"
#property version   "1.00"
#property description   "Trade Gold MT4 & MT5"
#property description   "Contact Support Telegram/Facebook: iZFx.Trade"
#property strict
#property show_inputs
//+------------------------------------------------------------------+
//| Expert initialization funct                                   |
//+------------------------------------------------------------------+
input int EAMagic    = 9999; //EA MAGIC
input string T1      = "Panel Setting"; //"=========================="
input int    PanelW  = 360; // Panel Width
input int    PanelH  = 350; // Panel High
input string T2      = "Trade Setting"; //"=========================="
input double LOT     = 0.01; // volume
input int    PipRange= 500;  // pip range
input string T3      = "Grib Setting"; //"=========================="
input int   MaxO     = 9; //Max Order Open
input double XLOT    = 3.0; // xLot
input int   STEP     = 500; // Step
input double TP      = 500; // TakeProfit
input bool  AutoClose= false;
input int    PL      = 5; //Profit Ratio %
input int    SL      = -10; //Stop trade %
input string T4      = "Indicator Setting"; //"=========================="

input string T5      = "Telegram Setting"; //"=========================="
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
double TPB, TPS;
double TPBO, TPSO;
int OT;
double VolP;
int   TypeP;
double ProfitBuy,ProfitSell;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double profit  = AccountInfoDouble(ACCOUNT_PROFIT);
   double pl = (profit/balance)*100;
   OT   = OrdersTotal();
   OpenPending();
//---
   Comment(Symbol()+"\n\n TREND: "+TREND(5)+"(M5) "+TREND(15)+"(M15) "+TREND(30)+"(M30) "+TREND(60)+"(H1) "+
           "\n\n Max Open: "+ MaxO+
           "\n\n Order Open: "+ OT+
           "\n\n Volume: "+ LOT+
           "\n\n XVolume: "+ XLOT+
           "\n\n Range: "+ PipRange+
           "\n\n Step: "+ STEP+
           "\n\n TakeProfit: "+ TP+
           "\n\n Type Last: "+ STYPE(TypeP)+
           "\n\n Volume Last: "+ VolP+
           "\n\n TP: "+PL+ "% = " +DoubleToString(PL*balance/100,0)+"$"+
           "\n\n SL: "+SL+ "% = "+DoubleToString(SL*balance/100,0)+"$"+
           "\n\n Float Profit = "+ profit+
           "\n\n Profit BUY = "+ ProfitBuy+
           "\n\n Profit SELL = "+ ProfitSell);
//-- Check Open More

//-- Check Close
   if(Bid >= ProfitBuy || Ask <= ProfitSell)
      CheckClose();
//Close with Profit

   if(AutoClose && (pl >= PL || pl <= SL))
      CheckClose();
//-- END
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   if(id==CHARTEVENT_KEYDOWN && lparam=='1')
      CheckOpen("BUY");
   if(id==CHARTEVENT_KEYDOWN && lparam=='2')
      CheckOpen("SELL");
   if(id==CHARTEVENT_KEYDOWN && lparam=='3')
      CheckOpen("BUY");
   if(id==CHARTEVENT_KEYDOWN && lparam=='4')
      CheckOpen("SELL");
   if(id==CHARTEVENT_KEYDOWN && lparam=='5')
      CheckClose(5);
   if(id==CHARTEVENT_KEYDOWN && lparam=='0')
      CheckClose();
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckOpen(string type)
  {

   string symbol= Symbol();
   double Price;
   double PriceAsk = SymbolInfoDouble(symbol,SYMBOL_ASK);
   double PriceBid = SymbolInfoDouble(symbol,SYMBOL_BID);
   ProfitBuy=0;
   ProfitSell=0;
   ENUM_ORDER_TYPE Order_Type;
   if(type == "SELL")
      Order_Type = ORDER_TYPE_SELL;
   if(type == "BUY")
      Order_Type = ORDER_TYPE_BUY;
   if(type == "BUYSTOP")
      Order_Type = ORDER_TYPE_BUY_STOP;
   if(type == "BUYLIMIT")
      Order_Type = ORDER_TYPE_BUY_LIMIT;
   if(type == "SELLSTOP")
      Order_Type = ORDER_TYPE_SELL_STOP;
   if(type == "SELLLIMIT")
      Order_Type = ORDER_TYPE_SELL_LIMIT;
   if(Order_Type == ORDER_TYPE_SELL)
     {
      Price = PriceBid;
      ProfitSell = Price - TP*Point();
      ProfitBuy = Price + (PipRange + TP)*Point();
      OrderSend(symbol,Order_Type,LOT,Price,3,0,ProfitSell,"SELL 1",EAMagic,0,clrBlue);
      OrderSend(symbol,ORDER_TYPE_BUY_STOP,LOT*XLOT,Price+PipRange*Point,3,0,ProfitBuy,"BUY STOP 1",EAMagic,0,clrYellow);
     }
   if(Order_Type == ORDER_TYPE_BUY)
     {
      Price = PriceAsk;
      ProfitBuy = Price + TP*Point();
      ProfitSell = Price - (PipRange + TP)*Point();
      OrderSend(symbol,Order_Type,LOT,Price,3,0,ProfitBuy,"BUY 1",EAMagic,0,clrBlue);
      OrderSend(symbol,ORDER_TYPE_SELL_STOP,LOT*XLOT,Price-PipRange*Point,3,0,ProfitSell,"SELL STOP 1",EAMagic,0,clrYellow);

     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckClose(int A = 0)
  {
   int OT = OrdersTotal();
   string sym = Symbol();
   double PositionTP;
   ulong ticket;

//Delete All Order
   if(OT != 0 && (A == 5 || A == 0))
     {
      for(int i = OT -1 ; i>=0 ; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)//Select Order
           {
            if(A == 5 && OrderMagicNumber() == EAMagic)
               OrderDelete(OrderTicket());
            if(A == 3 && OrderMagicNumber() == EAMagic)
              {
               OrderClose(OrderTicket(),OrderLots(),Ask,0,Red);
               OrderClose(OrderTicket(),OrderLots(),Bid,0,Blue);
               OrderDelete(OrderTicket());
              }
            ProfitBuy =0;
            ProfitSell=0;
           }
        }
      Comment("Delete All Order");
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenPending()
  {
   if(OT != 0)
     {
      double OpenP;
      for(int i = 0 ; i < OT ; i++)
        {
         if(OrderMagicNumber() != EAMagic)
            continue;
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)//Select Order
           {
            TypeP   = OrderType();
            VolP    = OrderLots();
            OpenP   = OrderOpenPrice();
           }
        }
      if(TypeP <= 1)
        {
         if(TypeP == 0)
            OrderSend(NULL,5,NormalizeDouble(VolP*XLOT,2),OpenP-PipRange*Point,3,0,ProfitSell,"SELL STOP 2",EAMagic,0,clrYellow);
         if(TypeP == 1)
            OrderSend(NULL,3,NormalizeDouble(VolP*XLOT,2),OpenP+PipRange*Point,3,0,ProfitBuy,"BUY STOP 2",EAMagic,0,clrYellow);
        }
     }
   else
     {
      TypeP = 6;
      VolP  = 0;
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string STYPE(int type)
  {
   if(type == 0)
      return "BUY";
   if(type == 1)
      return "SELL";
   if(type == 2)
      return "BUY LIMIT";
   if(type == 3)
      return "BUY STOP";
   if(type == 4)
      return "SELL LIMIT";
   if(type == 5)
      return "SELL STOP";
   else
      return "NULL";
  }
//+------------------------------------------------------------------+
string TREND(int TF=0)
  {
   double cci_01=iCCI(Symbol(),TF,14,PRICE_CLOSE,0);
   double cci_02=iCCI(Symbol(),TF,14,PRICE_CLOSE,1);
   if(cci_01>cci_02)
      return "UP";
   if(cci_01<cci_02)
      return "DOWN";
   return "NULL";
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CCI(int TF=0, int bar=0)
  {
   return NormalizeDouble(iCCI(Symbol(),TF,14,PRICE_CLOSE,bar),0);
  }
//+------------------------------------------------------------------+
