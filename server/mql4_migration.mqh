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

#define EMPTY -1

double get_market_info(string symbol, int type) {
   switch(type) {
		case MODE_LOW:
			return(SymbolInfoDouble(symbol, SYMBOL_LASTLOW));

		case MODE_HIGH:
			return(SymbolInfoDouble(symbol, SYMBOL_LASTHIGH));

		case MODE_TIME:
			return((double)SymbolInfoInteger(symbol, SYMBOL_TIME));

		case MODE_BID: {
			MqlTick last_tick;
			SymbolInfoTick(symbol, last_tick);
			double Bid = last_tick.bid;
			return(Bid);
		}

		case MODE_ASK: {
			MqlTick last_tick;
			SymbolInfoTick(symbol, last_tick);
			double Ask = last_tick.ask;
			return(Ask);
		}

		case MODE_POINT:
			return(SymbolInfoDouble(symbol, SYMBOL_POINT));

		case MODE_DIGITS:
			return((double)SymbolInfoInteger(symbol, SYMBOL_DIGITS));

		case MODE_SPREAD:
			return((double)SymbolInfoInteger(symbol, SYMBOL_SPREAD));

		case MODE_STOPLEVEL:
			return((double)SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL));

		case MODE_LOTSIZE:
			return(SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE));

		case MODE_TICKVALUE:
			return(SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE));

		case MODE_TICKSIZE:
			return(SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE));

		case MODE_SWAPLONG:
			return(SymbolInfoDouble(symbol, SYMBOL_SWAP_LONG));

		case MODE_SWAPSHORT:
			return(SymbolInfoDouble(symbol, SYMBOL_SWAP_SHORT));

		case MODE_STARTING:
			return(0);

		case MODE_EXPIRATION:
			return(0);

		case MODE_TRADEALLOWED:
			return(0);

		case MODE_MINLOT:
			return(SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN));

		case MODE_LOTSTEP:
			return(SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP));

		case MODE_MAXLOT:
			return(SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX));

		case MODE_SWAPTYPE:
			return((double)SymbolInfoInteger(symbol, SYMBOL_SWAP_MODE));

		case MODE_PROFITCALCMODE:
			return((double)SymbolInfoInteger(symbol, SYMBOL_TRADE_CALC_MODE));

		case MODE_MARGINCALCMODE:
			return(0);

		case MODE_MARGININIT:
			return(0);

		case MODE_MARGINMAINTENANCE:
			return(0);

		case MODE_MARGINHEDGED:
			return(0);

		case MODE_MARGINREQUIRED:
			return(0);

		case MODE_FREEZELEVEL:
			return((double)SymbolInfoInteger(symbol, SYMBOL_TRADE_FREEZE_LEVEL));
		default: return(0);
	}
	return(0);
}
