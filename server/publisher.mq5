#property copyright "Leoni"
#property version "1.00"
#include <mql4_migration.mqh>
#include <zmq_api.mqh>
#define PROJECT_NAME "SymbolPublisher"

extern string ZEROMQ_PROTOCOL = "tcp";
extern string HOSTNAME = "*";
extern int PUB_PORT = 5556;

datetime lastOnTimerExecution;
int timer_period_ms = 200;

Context context(PROJECT_NAME);
ZMQ_api zmq(&context);

int OnInit() {
  EventSetMillisecondTimer(timer_period_ms);
  zmq.setup_pub_server(ZEROMQ_PROTOCOL, HOSTNAME, PUB_PORT);
  if (MQLInfoInteger(MQL_TESTER)) {
    lastOnTimerExecution = TimeCurrent();
  }
  return (INIT_SUCCEEDED);
}

void subscribe_to(string symbol, long timeframe_minutes) {
  static uint indicator_id = 0;
  if (StringLen(symbol) >= 1) {
    if (iCustom(symbol, PERIOD_M1, "tick_subscriber", ChartID(), indicator_id++) == INVALID_HANDLE) {
      Print("Error on subscribing");
    }
  }
}

void find_symbols_in_folder(string symbols_folder = SYMBOLS_FOLDER) {
  string file_name;
  long search_handle =
      FileFindFirst(symbols_folder + "/*", file_name, FILE_COMMON);
  if (search_handle != INVALID_HANDLE) {
    do {
      ResetLastError();
      int file_handle =
          FileOpen(symbols_folder + "//" + file_name,
                   FILE_READ | FILE_BIN | FILE_ANSI | FILE_COMMON);
      long timeframe_minutes =
          StringToInteger(FileReadString(file_handle, TIMEFRAME_SIZE));
      Print("Got the file: ", file_name);
      FileClose(file_handle);
      subscribe_to(file_name, timeframe_minutes);
    } while (FileFindNext(search_handle, file_name));
    FileFindClose(search_handle);
    FolderClean(symbols_folder, FILE_COMMON);
  }
}

void OnDeinit(const int reason) { EventKillTimer(); }

void OnTimer() { find_symbols_in_folder(); }

void OnChartEvent(const int event_id, const long &evt_flag, const double &_,
                  const string &data) {
  string separated_data[];
  int data_len = StringSplit(data, '|', separated_data);
  if (event_id >= CHARTEVENT_CUSTOM) {
    if (data_len == 4) {
      string pub_msg = StringFormat(
          "{\"symbol\":\"%s\", \"time\":\"%s\",\"bid_price\":\"%s\", "
          "\"ask_price\":\"%s\"}",
          separated_data[0], separated_data[1], separated_data[2],
          separated_data[3]);

      Print(TimeToString(TimeCurrent(), TIME_SECONDS),
            " -> id=", event_id - CHARTEVENT_CUSTOM, ":  ", evt_flag,
            " bid_price=", separated_data[2], " ask_price=", separated_data[3]);
      zmq.publish(pub_msg);
    }
  }
}

void OnTick() {
  if (MQLInfoInteger(MQL_TESTER) &&
      TimeCurrent() > lastOnTimerExecution + timer_period_ms) {
    OnTimer();
    lastOnTimerExecution = TimeCurrent();
  }
}
