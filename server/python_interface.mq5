#include <python.mqh>

int OnInit() {
   LoadScript("C:\\Users\\leoni\\projects\\trade\\Metatrader5-integration-with-zmq\\client\\tests\\", "direct_call.py");
   return(INIT_SUCCEEDED);
}
