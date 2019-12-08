#include <mql4_migration.mqh>

#property copyright "Leoni"
#property description "It generates the new bar and/or new tick events for a chart"
#property indicator_chart_window

input long chart_id;
input ushort custom_event_id;

MqlDateTime time, prev_time;

int OnCalculate(const int price_array_length,
                const int prev_calculated,
                const datetime &_time[],
                const double &open[],
                const double &price[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {

  MqlTick tick;
  SymbolInfoTick(_Symbol, tick);
  if ((tick.flags & 8) == 8 || (tick.flags & 16) == 16 || (tick.flags & 32)==32 || (tick.flags & 64) == 64) {
      Print(tick.last);
      string event_data = StringFormat("%s|%s|%.3f|%.3f|%.3f|%d|%d", _Symbol, IntegerToString(tick.time_msc), tick.bid, tick.ask, tick.last, tick.volume, tick.flags);
      EventChartCustom(chart_id, custom_event_id, (long)CHARTEVENT_TICK, 0.0, event_data);
  }
  
  //TimeCurrent(time);
  //if (prev_calculated == 0) {
 /*
    EventCustom(CHARTEVENT_INIT, last_tick);
    prev_time = time;
    return (price_array_length);
  }
  EventCustom(CHARTEVENT_TICK, last_tick);
  
  */
  return (price_array_length);
}

void EventCustom(ENUM_CHART_TIMEFRAME_EVENTS event, MqlTick &tick) {
  // symbol, time, bid, ask, last, volume, flags
  string event_data = StringFormat("%s|%s|%.3f|%.3f|%.3f|%d|%d", _Symbol, IntegerToString(tick.time_msc), tick.bid, tick.ask, tick.last, tick.volume, tick.flags);
  EventChartCustom(chart_id, custom_event_id, (long)event, 0.0, event_data);
  return;
}
