#ifndef OPERATIONS_MQH
#define OPERATIONS_MQH
#include <json.mqh>

class Operations {
    public:
        static int handle_trade_operations();
        static int handle_rate_operations();
        static int handle_data_operations();
};

int Operations::handle_trade_operations(void) {}
int Operations::handle_data_operations(void) {}
int Operations::handle_rate_operations() {}

#endif
