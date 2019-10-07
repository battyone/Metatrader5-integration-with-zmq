rm C:\Users\leoni\AppData\Roaming\MetaQuotes\Terminal\FB9A56D617EDDDFE29EE54EBEFFE96C1\MQL5\Experts\zmq_server.mq5
mklink /H C:\Users\leoni\AppData\Roaming\MetaQuotes\Terminal\FB9A56D617EDDDFE29EE54EBEFFE96C1\MQL5\Experts\zmq_server.mq5 zmq_server.mq5

rm C:\Users\leoni\AppData\Roaming\MetaQuotes\Terminal\FB9A56D617EDDDFE29EE54EBEFFE96C1\MQL5\Experts\publisher.mq5
mklink /H C:\Users\leoni\AppData\Roaming\MetaQuotes\Terminal\FB9A56D617EDDDFE29EE54EBEFFE96C1\MQL5\Experts\publisher.mq5 publisher.mq5

rm C:\Users\leoni\AppData\Roaming\MetaQuotes\Terminal\FB9A56D617EDDDFE29EE54EBEFFE96C1\MQL5\Include\hash.mqh
mklink /H C:\Users\leoni\AppData\Roaming\MetaQuotes\Terminal\FB9A56D617EDDDFE29EE54EBEFFE96C1\MQL5\Include\hash.mqh hash.mqh

rm C:\Users\leoni\AppData\Roaming\MetaQuotes\Terminal\FB9A56D617EDDDFE29EE54EBEFFE96C1\MQL5\Include\json.mqh
mklink /H C:\Users\leoni\AppData\Roaming\MetaQuotes\Terminal\FB9A56D617EDDDFE29EE54EBEFFE96C1\MQL5\Include\json.mqh json.mqh

rm C:\Users\leoni\AppData\Roaming\MetaQuotes\Terminal\FB9A56D617EDDDFE29EE54EBEFFE96C1\MQL5\Include\mql4_migration.mqh
mklink /H C:\Users\leoni\AppData\Roaming\MetaQuotes\Terminal\FB9A56D617EDDDFE29EE54EBEFFE96C1\MQL5\Include\mql4_migration.mqh mql4_migration.mqh

rm C:\Users\leoni\AppData\Roaming\MetaQuotes\Terminal\FB9A56D617EDDDFE29EE54EBEFFE96C1\MQL5\Include\operations.mqh
mklink /H C:\Users\leoni\AppData\Roaming\MetaQuotes\Terminal\FB9A56D617EDDDFE29EE54EBEFFE96C1\MQL5\Include\operations.mqh operations.mqh

rm C:\Users\leoni\AppData\Roaming\MetaQuotes\Terminal\FB9A56D617EDDDFE29EE54EBEFFE96C1\MQL5\Include\zmq_api.mqh
mklink /H C:\Users\leoni\AppData\Roaming\MetaQuotes\Terminal\FB9A56D617EDDDFE29EE54EBEFFE96C1\MQL5\Include\zmq_api.mqh zmq_api.mqh

rm C:\Users\leoni\AppData\Roaming\MetaQuotes\Terminal\FB9A56D617EDDDFE29EE54EBEFFE96C1\MQL5\Indicators\tick_subscriber.mq5
mklink /H C:\Users\leoni\AppData\Roaming\MetaQuotes\Terminal\FB9A56D617EDDDFE29EE54EBEFFE96C1\MQL5\Indicators\tick_subscriber.mq5 tick_subscriber.mq5

rm -rf C:\Users\leoni\AppData\Roaming\MetaQuotes\Terminal\FB9A56D617EDDDFE29EE54EBEFFE96C1\MQL5\Include\Zmq
cp -r ..\mql-zmq\Include\Zmq C:\Users\leoni\AppData\Roaming\MetaQuotes\Terminal\FB9A56D617EDDDFE29EE54EBEFFE96C1\MQL5\Include\

cp -r ..\mql-zmq\Include\Mql C:\Users\leoni\AppData\Roaming\MetaQuotes\Terminal\FB9A56D617EDDDFE29EE54EBEFFE96C1\MQL5\Include\

cp ..\mql-zmq\Library\MT5\libzmq.dll C:\Users\leoni\AppData\Roaming\MetaQuotes\Terminal\FB9A56D617EDDDFE29EE54EBEFFE96C1\MQL5\Libraries\libzmq.dll
cp ..\mql-zmq\Library\MT5\libsodium.dll C:\Users\leoni\AppData\Roaming\MetaQuotes\Terminal\FB9A56D617EDDDFE29EE54EBEFFE96C1\MQL5\Libraries\libsodium.dll