#property copyright "Leoni"
#property version "1.00"
#property description "This indicator gets ticks from any symbol."

input long chart_id = 0;
input ushort custom_event_id = 0;

int OnCalculate(const int price_array_length, const int prev_calculated,
                const int start_index, const double& price[]) {
  double current_price = price[price_array_length - 1];
  if (prev_calculated == 0) {
    EventChartCustom(chart_id, 0, (long)_Period, current_price, _Symbol);
    return (price_array_length);
  }

  EventChartCustom(chart_id, (ushort)(custom_event_id + 1), (long)_Period,
                   current_price, _Symbol);

  return (price_array_length);
}
