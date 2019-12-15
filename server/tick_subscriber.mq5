#include <mql4_migration.mqh>
#include <zmq_api.mqh>

#property copyright "Leoni"
#property description "It generates the new bar and/or new tick events for a chart"
#property indicator_chart_window

input long chart_id;
input ushort port;

extern string ZEROMQ_PROTOCOL = "tcp";
extern string HOSTNAME = "*";

const uchar max_symbol_name_size = 6;

Context context("tick_subscriber");
ZMQ_api zmq(context);
MqlTick tick;
uchar event_data[40] = {0};

int OnInit(void) {
    zmq.setup_pub_server(ZEROMQ_PROTOCOL, HOSTNAME, port);
    StringToCharArray(_Symbol, event_data, 0, max_symbol_name_size); // I have 6 bytes
    
    return(INIT_SUCCEEDED);
}


int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double& price[]) {
  SymbolInfoTick(_Symbol, tick);
  Print(tick.last);
  string event_data = StringFormat("%s|%s|%.2f|%.2f|%.2f|%d|%d", _Symbol, IntegerToString(tick.time_msc), tick.bid, tick.ask, tick.last, tick.volume, tick.flags);
  
  zmq.publish(event_data);
  // EventChartCustom(chart_id, custom_event_id, (long)CHARTEVENT_TICK, 0.0, event_data);
  
  /*if ((tick.flags & 8) == 8 || (tick.flags & 16) == 16 || (tick.flags & 32)==32 || (tick.flags & 64) == 64) {
      Print(tick.last);
      string event_data = StringFormat("%s|%s|%.3f|%.3f|%.3f|%d|%d", _Symbol, IntegerToString(tick.time_msc), tick.bid, tick.ask, tick.last, tick.volume, tick.flags);
      EventChartCustom(chart_id, custom_event_id, (long)CHARTEVENT_TICK, 0.0, event_data);
  }*/
  
  
  return 0;
}
