#include <mql4_migration.mqh>

#property copyright "Leoni"
#property description "It generates the new bar and/or new tick events for a chart"
#property indicator_chart_window

input long chart_id;
input ushort custom_event_id;
input ENUM_CHART_TIMEFRAME_EVENTS flag_event = CHARTEVENT_NO;

MqlDateTime time, prev_time;

int OnCalculate(const int price_array_length, const int prev_calculated,
                const int begin, const double& price[]) {
  double current_price = price[price_array_length - 1];

  TimeCurrent(time);
  if (prev_calculated == 0) {
    EventCustom(CHARTEVENT_INIT, current_price);
    prev_time = time;
    return (price_array_length);
  }

  //--- new tick
  if ((flag_event & CHARTEVENT_TICK) != 0)
    EventCustom(CHARTEVENT_TICK, current_price);

  //--- check change time
  if (time.min == prev_time.min && time.hour == prev_time.hour &&
      time.day == prev_time.day && time.mon == prev_time.mon)
    return (price_array_length);

  if ((flag_event & CHARTEVENT_NEWBAR_M1) != 0)
    EventCustom(CHARTEVENT_NEWBAR_M1, current_price);
  if (time.min % 2 == 0 && (flag_event & CHARTEVENT_NEWBAR_M2) != 0)
    EventCustom(CHARTEVENT_NEWBAR_M2, current_price);
  if (time.min % 3 == 0 && (flag_event & CHARTEVENT_NEWBAR_M3) != 0)
    EventCustom(CHARTEVENT_NEWBAR_M3, current_price);
  if (time.min % 4 == 0 && (flag_event & CHARTEVENT_NEWBAR_M4) != 0)
    EventCustom(CHARTEVENT_NEWBAR_M4, current_price);
  if (time.min % 5 == 0 && (flag_event & CHARTEVENT_NEWBAR_M5) != 0)
    EventCustom(CHARTEVENT_NEWBAR_M5, current_price);
  if (time.min % 6 == 0 && (flag_event & CHARTEVENT_NEWBAR_M6) != 0)
    EventCustom(CHARTEVENT_NEWBAR_M6, current_price);
  if (time.min % 10 == 0 && (flag_event & CHARTEVENT_NEWBAR_M10) != 0)
    EventCustom(CHARTEVENT_NEWBAR_M10, current_price);
  if (time.min % 12 == 0 && (flag_event & CHARTEVENT_NEWBAR_M12) != 0)
    EventCustom(CHARTEVENT_NEWBAR_M12, current_price);
  if (time.min % 15 == 0 && (flag_event & CHARTEVENT_NEWBAR_M15) != 0)
    EventCustom(CHARTEVENT_NEWBAR_M15, current_price);
  if (time.min % 20 == 0 && (flag_event & CHARTEVENT_NEWBAR_M20) != 0)
    EventCustom(CHARTEVENT_NEWBAR_M20, current_price);
  if (time.min % 30 == 0 && (flag_event & CHARTEVENT_NEWBAR_M30) != 0)
    EventCustom(CHARTEVENT_NEWBAR_M30, current_price);
  if (time.min != 0) {
    prev_time = time;
    return (price_array_length);
  }
  if ((flag_event & CHARTEVENT_NEWBAR_H1) != 0)
    EventCustom(CHARTEVENT_NEWBAR_H1, current_price);
  if (time.hour % 2 == 0 && (flag_event & CHARTEVENT_NEWBAR_H2) != 0)
    EventCustom(CHARTEVENT_NEWBAR_H2, current_price);
  if (time.hour % 3 == 0 && (flag_event & CHARTEVENT_NEWBAR_H3) != 0)
    EventCustom(CHARTEVENT_NEWBAR_H3, current_price);
  if (time.hour % 4 == 0 && (flag_event & CHARTEVENT_NEWBAR_H4) != 0)
    EventCustom(CHARTEVENT_NEWBAR_H4, current_price);
  if (time.hour % 6 == 0 && (flag_event & CHARTEVENT_NEWBAR_H6) != 0)
    EventCustom(CHARTEVENT_NEWBAR_H6, current_price);
  if (time.hour % 8 == 0 && (flag_event & CHARTEVENT_NEWBAR_H8) != 0)
    EventCustom(CHARTEVENT_NEWBAR_H8, current_price);
  if (time.hour % 12 == 0 && (flag_event & CHARTEVENT_NEWBAR_H12) != 0)
    EventCustom(CHARTEVENT_NEWBAR_H12, current_price);
  if (time.hour != 0) {
    prev_time = time;
    return (price_array_length);
  }
  //--- new day
  if ((flag_event & CHARTEVENT_NEWBAR_D1) != 0)
    EventCustom(CHARTEVENT_NEWBAR_D1, current_price);
  //--- new week
  if (time.day_of_week == 1 && (flag_event & CHARTEVENT_NEWBAR_W1) != 0)
    EventCustom(CHARTEVENT_NEWBAR_W1, current_price);
  //--- new month
  if (time.day == 1 && (flag_event & CHARTEVENT_NEWBAR_MN1) != 0)
    EventCustom(CHARTEVENT_NEWBAR_MN1, current_price);
  prev_time = time;
  //--- return value of prev_calculated for next call
  return (price_array_length);
}
//+------------------------------------------------------------------+

void EventCustom(ENUM_CHART_TIMEFRAME_EVENTS event, double price) {
  EventChartCustom(chart_id, custom_event_id, (long)event, price, _Symbol);
  return;
}