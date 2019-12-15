#property copyright "Leoni"
#property version "1.00"
#include <mql4_migration.mqh>
#include <zmq_api.mqh>
#define PROJECT_NAME "SymbolPublisher"

extern int PORT_OFFSET = 5555;

datetime lastOnTimerExecution;
int timer_period_ms = 1000;

int OnInit() {
  EventSetMillisecondTimer(timer_period_ms);
  if (MQLInfoInteger(MQL_TESTER)) {
    lastOnTimerExecution = TimeCurrent();
  }
  return (INIT_SUCCEEDED);
}

void subscribe_to(string symbol, long timeframe_minutes) {
  static uint indicator_id = 1;
  if (StringLen(symbol) >= 1) {
    if (iCustom(symbol, PERIOD_M1, "tick_subscriber", ChartID(), PORT_OFFSET + indicator_id++) == INVALID_HANDLE) {
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

void OnTick() {
  if (MQLInfoInteger(MQL_TESTER) &&
      TimeCurrent() > lastOnTimerExecution + timer_period_ms) {
    OnTimer();
    lastOnTimerExecution = TimeCurrent();
  }
}
