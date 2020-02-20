import bal
from datetime import datetime
import pytz
tz = pytz.timezone('Brazil/East')
b = bal.create(bal.BrokerType.MQL5)
# year_month_day = [2019, 11, 11]
year_month_day = [2019, 11, 1]

from_datetime=datetime(*year_month_day, tzinfo=tz)

to_datetime=datetime(*year_month_day[:2], year_month_day[2] + 1, tzinfo=tz)
data = b.request_data("WINZ19", from_datetime, to_datetime)
