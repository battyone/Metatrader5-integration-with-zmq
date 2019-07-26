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
  double current_bid_price = get_market_info(_Symbol, MODE_BID);
  double current_ask_price = get_market_info(_Symbol, MODE_ASK);
  TimeCurrent(time);
  if (prev_calculated == 0) {
    EventCustom(CHARTEVENT_INIT, current_bid_price, current_ask_price, time);
    prev_time = time;
    return (price_array_length);
  }
  EventCustom(CHARTEVENT_TICK, current_bid_price, current_ask_price, time);
  return (price_array_length);
}

void EventCustom(ENUM_CHART_TIMEFRAME_EVENTS event, double bid_price, double ask_price, MqlDateTime& _time) {
  string event_data = StringFormat("%s|%s|%.8f|%.8f", _Symbol, TimeToString(StructToTime(_time)), bid_price, ask_price);
  EventChartCustom(chart_id, custom_event_id, (long)event, 0.0, event_data);
  return;
}
