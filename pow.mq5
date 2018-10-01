#include <Zmq/Zmq.mqh>
#include <mql4_migration.mqh>

extern string PROJECT_NAME = "ZeroMQ_server";
extern string ZEROMQ_PROTOCOL = "tcp";
extern string HOSTNAME = "*";
extern int REP_PORT = 5555;
extern int PUSH_PORT = 5556;
extern int MILLISECOND_TIMER = 1;  // 1 millisecond

extern string t0 = "--- Trading Parameters ---";
extern int MaximumOrders = 1;
extern double MaximumLotSize = 0.01;

Context context(PROJECT_NAME);
Socket rep_socket(context, ZMQ_REP);
Socket push_socket(context, ZMQ_PUSH);

uchar data[];
ZmqMsg request;

int OnInit() {
    EventSetMillisecondTimer(MILLISECOND_TIMER);
    Print("[REP] Binding REP Server:" + (string)REP_PORT + "..");   
    Print("[PUSH] Binding PUSH Server:" + (string)PUSH_PORT + "..");
    rep_socket.bind(StringFormat("%s://%s:%d", ZEROMQ_PROTOCOL, HOSTNAME, REP_PORT));
    push_socket.bind(StringFormat("%s://%s:%d", ZEROMQ_PROTOCOL, HOSTNAME, PUSH_PORT));
    rep_socket.setLinger(1000); // timeout for each push/rep
    rep_socket.setSendHighWaterMark(5); // length of state retention .
    return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
    Print("[REP] Unbinding Server:" + (string)REP_PORT + "..");
    rep_socket.unbind(StringFormat("%s://%s:%d", ZEROMQ_PROTOCOL, HOSTNAME, REP_PORT));
    Print("[PUSH] Unbinding Server:" + (string)PUSH_PORT + "..");
    push_socket.unbind(StringFormat("%s://%s:%d", ZEROMQ_PROTOCOL, HOSTNAME, PUSH_PORT));
}

void OnTimer() {
    rep_socket.recv(request, true);
    ZmqMsg reply = on_incomming_message(request);
    rep_socket.send(reply);
}

ZmqMsg on_incomming_message(ZmqMsg &_request) {
    ZmqMsg reply;
    string components[];
   
if(_request.size() > 0) {
   
	// Get data from request   
	ArrayResize(data, (int)_request.size());
	_request.getData(data);
	string dataStr = CharArrayToString(data);
	
	// Process data
	ParseZmqMessage(dataStr, components);
	
	// Interpret data
	InterpretZmqMessage(&push_socket, components);
	
	// Construct response
	ZmqMsg ret(StringFormat("[SERVER] Processing: %s", dataStr));
	reply = ret;
	
   }
   else {
	// NO DATA RECEIVED
   }
   
   return(reply);
}

// Interpret Zmq Message and perform actions
void InterpretZmqMessage(Socket &pSocket, string& compArray[]) {

   Print("ZMQ: Interpreting Message..");
   
   // Message Structures:
   
   // 1) Trading
   // TRADE|ACTION|TYPE|SYMBOL|PRICE|SL|TP|COMMENT|TICKET
   // e.g. TRADE|OPEN|1|EURUSD|0|50|50|R-to-MetaTrader4|12345678
   
   // The 12345678 at the end is the ticket ID, for MODIFY and CLOSE.
   
   // 2) Data Requests
   
   // 2.1) RATES|SYMBOL   -> Returns Current Bid/Ask
   
   // 2.2) DATA|SYMBOL|TIMEFRAME|START_DATETIME|END_DATETIME
   
   // NOTE: datetime has format: D'2015.01.01 00:00'
   
   /*
	compArray[0] = TRADE or RATES
	If RATES -> compArray[1] = Symbol
	
	If TRADE ->
	   compArray[0] = TRADE
	   compArray[1] = ACTION (e.g. OPEN, MODIFY, CLOSE)
	   compArray[2] = TYPE (e.g. OP_BUY, OP_SELL, etc - only used when ACTION=OPEN)
	   
	   // ORDER TYPES: 
	   // https://docs.mql4.com/constants/tradingconstants/orderproperties
	   
	   // OP_BUY = 0
	   // OP_SELL = 1
	   // OP_BUYLIMIT = 2
	   // OP_SELLLIMIT = 3
	   // OP_BUYSTOP = 4
	   // OP_SELLSTOP = 5
	   
	   compArray[3] = Symbol (e.g. EURUSD, etc.)
	   compArray[4] = Open/Close Price (ignored if ACTION = MODIFY)
	   compArray[5] = SL
	   compArray[6] = TP
	   compArray[7] = Trade Comment
   */
   
   int switch_action = 0;
   
   if(compArray[0] == "TRADE" && compArray[1] == "OPEN")
	switch_action = 1;
   if(compArray[0] == "RATES")
	switch_action = 2;
   if(compArray[0] == "TRADE" && compArray[1] == "CLOSE")
	switch_action = 3;
   if(compArray[0] == "DATA")
	switch_action = 4;
   
   string ret = "";
   int ticket = -1;
   bool ans = false;
   double price_array[];
   ArraySetAsSeries(price_array, true);
   
   int price_count = 0;
   
   switch(switch_action) 
   {
	case 1: 
	   InformPullClient(pSocket, "OPEN TRADE Instruction Received");
	   // IMPLEMENT OPEN TRADE LOGIC HERE
	   break;
	case 2: 
	   ret = "N/A"; 
	   if(ArraySize(compArray) > 1) 
		ret = GetBidAsk(compArray[1]); 
		
	   InformPullClient(pSocket, ret); 
	   break;
	case 3:
	   InformPullClient(pSocket, "CLOSE TRADE Instruction Received");
	   
	   // IMPLEMENT CLOSE TRADE LOGIC HERE
	   
	   ret = StringFormat("Trade Closed (Ticket: %d)", ticket);
	   InformPullClient(pSocket, ret);
	   
	   break;
	
	case 4:
	   InformPullClient(pSocket, "HISTORICAL DATA Instruction Received");
	   
	   // Format: DATA|SYMBOL|TIMEFRAME|START_DATETIME|END_DATETIME
	   /* price_count = CopyClose((string)compArray[1], 
					   StringToInteger(compArray[2]),
					   StringToInteger(compArray[3]),  
					   StringToInteger(compArray[4]), 
					   price_array); */
	   price_count = CopyClose(compArray[1], 
					   1,
					   0,  
					   0, 
					   price_array);                        
	   
	   if (price_count > 0) {
		
		ret = "";
		
		// Construct string of price|price|price|.. etc and send to PULL client.
		for(int i = 0; i < price_count; i++ ) {
		   
		   if(i == 0)
			ret = compArray[1] + "|" + DoubleToString(price_array[i], 5);
		   else if(i > 0) {
			ret = ret + "|" + DoubleToString(price_array[i], 5);
		   }   
		}
		
		Print("Sending: " + ret);
		
		// Send data to PULL client.
		InformPullClient(pSocket, StringFormat("%s", ret));
		// ret = "";
	   }
		
	   break;
	   
	default: 
	   break;
   }
}

// Parse Zmq Message
void ParseZmqMessage(string& message, string& retArray[]) {
   
   Print("Parsing: " + message);
   
   string sep = "|";
   ushort u_sep = StringGetCharacter(sep,0);
   
   int splits = StringSplit(message, u_sep, retArray);
   
   for(int i = 0; i < splits; i++) {
	Print((string)i + ") " + retArray[i]);
   }
}

//+------------------------------------------------------------------+
// Generate string for Bid/Ask by symbol
string GetBidAsk(string symbol) {
   
   double bid = get_market_info(symbol, MODE_BID);
   double ask = get_market_info(symbol, MODE_ASK);
   
   return(StringFormat("%f|%f", bid, ask));
}

// Inform Client
void InformPullClient(Socket& _pushSocket, string message) {

   ZmqMsg pushReply(StringFormat("%s", message));
   // push_socket.send(pushReply,true,false);
   
   _pushSocket.send(pushReply,true); // NON-BLOCKING
   // push_socket.send(pushReply,false); // BLOCKING
   
}
