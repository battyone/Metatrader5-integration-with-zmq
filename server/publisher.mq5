#property copyright "Leoni"
#property version "1.00"
#include <mql4_migration.mqh>
#include <zmq_api.mqh>

datetime lastOnTimerExecution;
long timer_period_ms = 1000;

int OnInit() {
  EventSetTimer(timer_period_ms);

  if (MQLInfoInteger(MQL_TESTER)) {
    OnTimer();
    lastOnTimerExecution = TimeCurrent();
  }
  return (INIT_SUCCEEDED);
}

void subscribe_to(string symbol, long timeframe_events) {
  static uint indicator_id = 0;
  if (StringLen(symbol) >= 1) {
    if (iCustom(symbol, PERIOD_M1, "tick_subscriber", ChartID(), indicator_id++,
                timeframe_events) == INVALID_HANDLE) {
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
      long time_frame =
          StringToInteger(FileReadString(file_handle, TIMEFRAME_SIZE));
      FileClose(file_handle);
      subscribe_to(file_name, time_frame);
    } while (FileFindNext(search_handle, file_name));
    FileFindClose(search_handle);
    FolderClean(symbols_folder, FILE_COMMON);
  }
}

void OnDeinit(const int reason) { EventKillTimer(); }

void OnTimer() {
  if (MQLInfoInteger(MQL_TESTER)) {
    find_symbols_in_folder();
    Print("I am here!!");
  }
}

void OnChartEvent(const int event_id, const long &evt_flag, const double &price,
                  const string &symbol) {
  if (event_id >= CHARTEVENT_CUSTOM) {
    string pub_msg = StringFormat("{\"time\":%s,\"price\":%s}",
                                  TimeToString(TimeCurrent(), TIME_SECONDS),
                                  DoubleToString(price));

    Print(TimeToString(TimeCurrent(), TIME_SECONDS),
          " -> id=", event_id - CHARTEVENT_CUSTOM, ":  ", evt_flag,
          " price=", price);
  }
}

void OnTick() {
  if (MQLInfoInteger(MQL_TESTER) && TimeCurrent() > lastOnTimerExecution + timer_period) {
    OnTimer();
    lastOnTimerExecution = TimeCurrent();
  }
}
