#property copyright "Leoni"

enum OPERATIONS {
  OP_BUY,
  OP_SELL,
  OP_BUYLIMIT,
  OP_SELLLIMIT,
  OP_BUYSTOP,
  OP_SELLSTOP,
};

enum MODE_ACTIONS {
  MODE_TRADES,
  MODE_HISTORY,
};

enum MODE_SELECTION {
  SELECT_BY_POS,
  SELECT_BY_TICKET,
};

enum CUSTOM_TYPES {
  DOUBLE_VALUE,
  FLOAT_VALUE,
  LONG_VALUE = INT_VALUE,
};

enum MODE_GRAPH {
  CHART_BAR,
  CHART_CANDLE,
};

enum MODE_DERIVATIVE {
  MODE_ASCEND,
  MODE_DESCEND,
};

enum MODES_INFO {
  MODE_TIME = 5,
  MODE_BID = 9,
  MODE_ASK,
  MODE_POINT,
  MODE_DIGITS,
  MODE_STOPLEVEL = 14,
  MODE_LOTSIZE,
  MODE_TICKVALUE,
  MODE_TICKSIZE,
  MODE_SWAPLONG,
  MODE_SWAPSHORT,
  MODE_STARTING,
  MODE_EXPIRATION,
  MODE_TRADEALLOWED,
  MODE_MINLOT,
  MODE_LOTSTEP,
  MODE_MAXLOT,
  MODE_SWAPTYPE,
  MODE_PROFITCALCMODE,
  MODE_MARGINCALCMODE,
  MODE_MARGININIT,
  MODE_MARGINMAINTENANCE,
  MODE_MARGINHEDGED,
  MODE_MARGINREQUIRED,
  MODE_FREEZELEVEL,
};

enum ENUM_CHART_TIMEFRAME_EVENTS {
  CHARTEVENT_INIT = 0,
  CHARTEVENT_NO = 0,
  CHARTEVENT_NEWBAR_M1 = 0x00000001,
  CHARTEVENT_NEWBAR_M2 = 0x00000002,
  CHARTEVENT_NEWBAR_M3 = 0x00000004,
  CHARTEVENT_NEWBAR_M4 = 0x00000008,

  CHARTEVENT_NEWBAR_M5 = 0x00000010,
  CHARTEVENT_NEWBAR_M6 = 0x00000020,
  CHARTEVENT_NEWBAR_M10 = 0x00000040,
  CHARTEVENT_NEWBAR_M12 = 0x00000080,

  CHARTEVENT_NEWBAR_M15 = 0x00000100,
  CHARTEVENT_NEWBAR_M20 = 0x00000200,
  CHARTEVENT_NEWBAR_M30 = 0x00000400,
  CHARTEVENT_NEWBAR_H1 = 0x00000800,

  CHARTEVENT_NEWBAR_H2 = 0x00001000,
  CHARTEVENT_NEWBAR_H3 = 0x00002000,
  CHARTEVENT_NEWBAR_H4 = 0x00004000,
  CHARTEVENT_NEWBAR_H6 = 0x00008000,

  CHARTEVENT_NEWBAR_H8 = 0x00010000,
  CHARTEVENT_NEWBAR_H12 = 0x00020000,
  CHARTEVENT_NEWBAR_D1 = 0x00040000,
  CHARTEVENT_NEWBAR_W1 = 0x00080000,

  CHARTEVENT_NEWBAR_MN1 = 0x00100000,
  CHARTEVENT_TICK = 0x00200000,

  CHARTEVENT_ALL = 0xFFFFFFFF,
};

#define EMPTY -1

double get_market_info(string symbol, int type) {
  switch (type) {
    case MODE_LOW:
      return (SymbolInfoDouble(symbol, SYMBOL_LASTLOW));

    case MODE_HIGH:
      return (SymbolInfoDouble(symbol, SYMBOL_LASTHIGH));

    case MODE_TIME:
      return ((double)SymbolInfoInteger(symbol, SYMBOL_TIME));

    case MODE_BID: {
      MqlTick last_tick;
      SymbolInfoTick(symbol, last_tick);
      double Bid = last_tick.bid;
      return (Bid);
    }

    case MODE_ASK: {
      MqlTick last_tick;
      SymbolInfoTick(symbol, last_tick);
      double Ask = last_tick.ask;
      return (Ask);
    }

    case MODE_POINT:
      return (SymbolInfoDouble(symbol, SYMBOL_POINT));

    case MODE_DIGITS:
      return ((double)SymbolInfoInteger(symbol, SYMBOL_DIGITS));

    case MODE_SPREAD:
      return ((double)SymbolInfoInteger(symbol, SYMBOL_SPREAD));

    case MODE_STOPLEVEL:
      return ((double)SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL));

    case MODE_LOTSIZE:
      return (SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE));

    case MODE_TICKVALUE:
      return (SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE));

    case MODE_TICKSIZE:
      return (SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE));

    case MODE_SWAPLONG:
      return (SymbolInfoDouble(symbol, SYMBOL_SWAP_LONG));

    case MODE_SWAPSHORT:
      return (SymbolInfoDouble(symbol, SYMBOL_SWAP_SHORT));

    case MODE_STARTING:
      return (0);

    case MODE_EXPIRATION:
      return (0);

    case MODE_TRADEALLOWED:
      return (0);

    case MODE_MINLOT:
      return (SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN));

    case MODE_LOTSTEP:
      return (SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP));

    case MODE_MAXLOT:
      return (SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX));

    case MODE_SWAPTYPE:
      return ((double)SymbolInfoInteger(symbol, SYMBOL_SWAP_MODE));

    case MODE_PROFITCALCMODE:
      return ((double)SymbolInfoInteger(symbol, SYMBOL_TRADE_CALC_MODE));

    case MODE_MARGINCALCMODE:
      return (0);

    case MODE_MARGININIT:
      return (0);

    case MODE_MARGINMAINTENANCE:
      return (0);

    case MODE_MARGINHEDGED:
      return (0);

    case MODE_MARGINREQUIRED:
      return (0);

    case MODE_FREEZELEVEL:
      return ((double)SymbolInfoInteger(symbol, SYMBOL_TRADE_FREEZE_LEVEL));
    default:
      return (0);
  }
  return (0);
}

ENUM_TIMEFRAMES minutes_to_timeframe(int minutes) {
  switch (minutes) {
    case 0:
      return (PERIOD_CURRENT);
    case 1:
      return (PERIOD_M1);
    case 2:
      return (PERIOD_M2);
    case 3:
      return (PERIOD_M3);
    case 4:
      return (PERIOD_M4);
    case 5:
      return (PERIOD_M5);
    case 6:
      return (PERIOD_M6);
    case 10:
      return (PERIOD_M10);
    case 12:
      return (PERIOD_M12);
    case 15:
      return (PERIOD_M15);
    case 30:
      return (PERIOD_M30);
    case 60:
      return (PERIOD_H1);
    case 120:
      return (PERIOD_H2);
    case 180:
      return (PERIOD_H3);
    case 240:
      return (PERIOD_H4);
    case 360:
      return (PERIOD_H6);
    case 480:
      return (PERIOD_H8);
    case 1440:
      return (PERIOD_D1);
    case 10080:
      return (PERIOD_W1);
    case 43200:
      return (PERIOD_MN1);
    default:
      return (PERIOD_CURRENT);
  }
}

#define SYMBOLS_FOLDER "Symbols"
#define TIMEFRAME_SIZE 8
