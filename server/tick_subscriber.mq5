#include <mql4_migration.mqh>
#include <zmq_api.mqh>

#property copyright "Leoni"
#property description "It generates the new bar and/or new tick events for a chart"
#property indicator_chart_window

input ushort port;

extern string ZEROMQ_PROTOCOL = "tcp";
extern string HOSTNAME = "*";

const uchar max_symbol_name_size = 6;

Context context("tick_subscriber");
ZMQ_api zmq(context);
MqlTick tick;
uchar event_data[60] = {0};

int OnInit(void) {
    zmq.setup_pub_server(ZEROMQ_PROTOCOL, HOSTNAME, port);
    return(INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double& price[]) {
  SymbolInfoTick(_Symbol, tick);
  StringToCharArray(
      StringFormat("%d|%.2f|%.2f|%.2f|%d|%d|",
                   tick.time_msc,
                   tick.bid,
                   tick.ask,
                   tick.last,
                   tick.volume,
                   tick.flags),
      event_data, 0);

  zmq.publish(event_data);
  return 0;
}
