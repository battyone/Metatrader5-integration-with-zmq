#ifndef YDROL_JSON_MQH
#define YDROL_JSON_MQH
#include <hash.mqh>
enum ENUM_JSON_TYPE { JSON_NULL, JSON_OBJECT , JSON_ARRAY, JSON_NUMBER, JSON_STRING , JSON_BOOL };

class JSONString ;


class JSONValue : public HashValue {
    private:
    ENUM_JSON_TYPE _type;

    public:
        JSONValue() {}
        ~JSONValue() {}
        ENUM_JSON_TYPE getType() { return _type; }
        void setType(ENUM_JSON_TYPE t) { _type = t; }


        bool isString() { return _type == JSON_STRING; }
        bool isNull() { return _type == JSON_NULL; }
        bool isObject() { return _type == JSON_OBJECT; }
        bool isArray() { return _type == JSON_ARRAY; }
        bool isNumber() { return _type == JSON_NUMBER; }
        bool isBool() { return _type == JSON_BOOL; }

        virtual string toString() {
            return "";
        }


        string getString()
        {
            return ((JSONString *)GetPointer(this)).getString();
        }
        double getDouble()
        {
            return ((JSONNumber *)GetPointer(this)).getDouble();
        }
        long getLong()
        {
            return ((JSONNumber *)GetPointer(this)).getLong();
        }
        int getInt()
        {
            return ((JSONNumber *)GetPointer(this)).getInt();
        }
        bool getBool()
        {
            return ((JSONBool *)GetPointer(this)).getBool();
        }



        static bool getString(JSONValue *val,string &out)
        {
            if (val != NULL && val.isString()) {
                out = val.getString();
                return true;
            }
            return false;
        }
        static bool getBool(JSONValue *val,bool &out)
        {
            if (val != NULL && val.isBool()) {
                out = val.getBool();
                return true;
            }
            return false;
        }
        static bool getDouble(JSONValue *val,double &out)
        {
            if (val != NULL && val.isNumber()) {
                out = val.getDouble();
                return true;
            }
            return false;
        }
        static bool getLong(JSONValue *val,long &out)
        {
            if (val != NULL && val.isNumber()) {
                out = val.getLong();
                return true;
            }
            return false;
        }
        static bool getInt(JSONValue *val,int &out)
        {
            if (val != NULL && val.isNumber()) {
                out = val.getInt();
                return true;
            }
            return false;
        }
};



class JSONString : public JSONValue {
    private:
        string _string;
    public:
        JSONString(string s) {
            setString(s);
            setType(JSON_STRING);
        }
        JSONString() {
            setType(JSON_STRING);
        }
        string getString() { return _string; }
        void setString(string v) { _string = v; }
        string toString() {
            string destination;
            StringConcatenate(destination, "\"",_string,"\"");
            return destination;
        }
};




class JSONBool : public JSONValue {
    private:
        bool _bool;
    public:
        JSONBool(bool b) {
            setBool(b);
            setType(JSON_BOOL);
        }
        JSONBool() {
            setType(JSON_BOOL);
        }
        bool getBool() { return _bool; }
        void setBool(bool v) { _bool = v; }
        string toString() { return (string)_bool; }

};




class JSONNumber : public JSONValue {
    private:
        long _long;
        double _dbl;
    public:
        JSONNumber(long l) {
            _long = l;
            _dbl = 0;
        }
        JSONNumber(double d) {
            _long = 0;
            _dbl = d;
        }
        long getLong() {
            if (_dbl != 0) {
                return (long)_dbl;
            } else {
                return _long;
            }
        }
        int getInt() {
            if (_dbl != 0) {
                return (int)_dbl;
            } else {
                return (int)_long;
            }
        }
        double getDouble()
        {
            if (_long != 0) {
                return (double)_long;
            } else {
                return _dbl;
            }
        }
        string toString() {

            if (_long != 0) {
                return (string)_long;
            } else {
                return (string)_dbl;
            }
        }
};



class JSONNull : public JSONValue {
    public:
    JSONNull()
    {
        setType(JSON_NULL);
    }
    ~JSONNull() {}
    string toString()
    {
        return "null";
    }
};


class JSONArray ;

class JSONObject : public JSONValue {
    private:
    Hash *_hash;
    public:
        JSONObject() {
            setType(JSON_OBJECT);
        }
        ~JSONObject() {
            if (_hash != NULL) delete _hash;
        }


        string getString(string key)
        {
            return getValue(key).getString();
        }
        bool getBool(string key)
        {
            return getValue(key).getBool();
        }
        double getDouble(string key)
        {
            return getValue(key).getDouble();
        }
        long getLong(string key)
        {
            return getValue(key).getLong();
        }
        int getInt(string key)
        {
            return getValue(key).getInt();
        }

        string operator[] (string s) {
            return getValue(s).getString();
        }

        bool getString(string key,string &out)
        {
            return getString(getValue(key),out);
        }
        bool getBool(string key,bool &out)
        {
            return getBool(getValue(key),out);
        }
        bool getDouble(string key,double &out)
        {
            return getDouble(getValue(key),out);
        }
        bool getLong(string key,long &out)
        {
            return getLong(getValue(key),out);
        }
        bool getInt(string key,int &out)
        {
            return getInt(getValue(key),out);
        }



        JSONArray *getArray(string key)
        {
            return getValue(key);
        }
        JSONObject *getObject(string key)
        {
            return getValue(key);
        }


        JSONValue *getValue(string key)
        {
            if (_hash == NULL) {
                return NULL;
            }
            return (JSONValue*)_hash.hGet(key);
        }


        void put(string key,JSONValue *v)
        {
            if (_hash == NULL) _hash = new Hash();
            _hash.hPut(key,v);
        }
        string toString() {
           string s = "{";
           if (_hash != NULL) {
               HashLoop *l;
               int n=0;

               for(l = new HashLoop(_hash) ; l.hasNext() ; l.next() ) {
                   JSONValue *v = (JSONValue *)(l.val());
                   StringConcatenate(s, s,(++n==1?"":","),
                           "\"",l.key(),"\" : ",v.toString());
               }
               delete l;
           }
           s = s + "}";
           return s;
        }


        Hash *getHash() {
            return _hash;
        }
};

class JSONArray : public JSONValue {
    private:
        int _size;
        JSONValue *_array[];
    public:
        JSONArray() {
            setType(JSON_ARRAY);
        }
        ~JSONArray() {

            for(int i = ArrayRange(_array,0)-1 ; i >= 0 ; i-- ) {
                delete _array[i];
            }
        }



        string getString(int index)
        {
            return getValue(index).getString();
        }
        bool getBool(int index)
        {
            return getValue(index).getBool();
        }
        double getDouble(int index)
        {
            return getValue(index).getDouble();
        }
        long getLong(int index)
        {
            return getValue(index).getLong();
        }
        int getInt(int index)
        {
            return getValue(index).getInt();
        }


        bool getString(int index,string &out)
        {
            return getString(getValue(index),out);
        }
        bool getBool(int index,bool &out)
        {
            return getBool(getValue(index),out);
        }
        bool getDouble(int index,double &out)
        {
            return getDouble(getValue(index),out);
        }
        bool getLong(int index,long &out)
        {
            return getLong(getValue(index),out);
        }
        bool getInt(int index,int &out)
        {
            return getInt(getValue(index),out);
        }




        JSONArray *getArray(int index)
        {
            return getValue(index);
        }
        JSONObject *getObject(int index)
        {
            return getValue(index);
        }


        JSONValue *getValue(int index)
        {
            return _array[index];
        }


        bool put(int index,JSONValue *v)
        {
            if (index >= _size) {
                int oldSize = _size;
                int newSize = ArrayResize(_array,index+1,30);
                if (newSize <= index) return false;
                _size = newSize;


                for(int i = oldSize ; i< newSize ; i++ ) _array[i] = NULL;
            }

            if (_array[index] != NULL) delete _array[index];


            _array[index] = v;

            return true;
        }

        string toString() {
           string s = "[";
           if (_size > 0) {
               StringConcatenate(s, s,_array[0].toString());
               for(int i = 1 ; i< _size ; i++ ) {
                  StringConcatenate(s, s,",",_array[i].toString());
               }
           }
           s = s + "]";
           return s;
        }

        int size() {
            return _size;
        }
};




class JSONParser {
    private:
        int _pos;
        ushort _in[];
        int _len;
        string _instr;
        int _errCode;
        string _errMsg;

        void setError(int code=1, string msg="unknown error") {
            _errCode |= code;
            if (_errMsg == "") {
                _errMsg = "JSONParser::Error "+msg;
            } else {
                StringConcatenate(_errMsg, _errMsg,"\n",msg);
            }
        }

    public:
        int getErrorCode()
        {
            return _errCode;
        }
        string getErrorMessage()
        {
            return _errMsg;
        }
        JSONValue *parse(string s)
        {
            int inLen;
            JSONValue *ret = NULL;
            StringTrimLeft(s);
            StringTrimRight(s);

            _instr = s;
            _len = StringToShortArray(_instr,_in);
            _pos = 0;
            _errCode = 0;
            _errMsg = "";
            inLen = StringLen(_instr);
            if (_len != inLen + 1 /* nul */ ) {
                StringConcatenate(_errMsg, "unable to create array ",inLen," got ",_len);
                setError(1, _errMsg);
            } else {
                _len --;
                ret = parseValue();
                if (_errCode != 0) {
                    StringConcatenate(_errMsg, _errMsg," at ",_pos," [",StringSubstr(_instr,_pos,10),"...]");
                }
            }
            return ret;
        }

        JSONObject *parseObject()
        {
            JSONObject *o = new JSONObject();
            skipSpace();
            if (expect('{')) {
                    while (_errCode == 0) {
                        skipSpace();
                        if (_in[_pos] != '"') break;


                        string key = parseString();

                        if (_errCode != 0 || key == NULL) break;

                        skipSpace();

                        if (!expect(':')) break;


                        JSONValue *v = parseValue();
                        if (_errCode != 0 ) break;

                        o.put(key,v);

                        skipSpace();

                        if (!expectOptional(',')) break;
                    }
                    if (!expect('}')) {
                        setError(2,"expected \" or } ");
                    }
            }
            if (_errCode != 0) {
                delete o;
                o = NULL;
            }
            return o;
        }

        bool isDigit(ushort c) {
            return (c >= '0' && c <= '9' ) || c == '+'  || c == '-'  ;
        }

        bool isDoubleDigit(ushort c) {
            return (c >= '0' && c <= '9' ) || c == '+'  || c == '-'  || c == '.'  || c == 'e'  || c == 'E' ;
        }

        void skipSpace() {
            while (_in[_pos] == ' ' || _in[_pos] == '\t' || _in[_pos]=='\r' || _in[_pos] == '\n' ) {
                if (_pos >= _len ) break;
                _pos++;
            }
        }

        bool expect(ushort c)
        {
            bool ret = false;
            if (c == _in[_pos]) {
                _pos++;
                ret = true;
            } else {
                StringConcatenate(_errMsg, "expected ", ShortToString(c),"(",c,")", " got ",ShortToString(_in[_pos]),"(",_in[_pos],")");
                setError(1, _errMsg);
            }
            return ret;
        }

        bool expectOptional(ushort c)
        {
            bool ret=false;
            if (c == _in[_pos]) {
                _pos++;
                ret = true;
            }
            return ret;
        }

        string parseString()
        {
            string ret = "";
            if(expect('"')) {
                while(true) {
                    int end=_pos;
                    while(end < _len && _in[end] != '"' && _in[end] != '\\' ) {
                        end++;
                    }

                    if (end >= _len) {
                        setError(2,"missing quote: end"+(string)end+":len"+(string)_len+":"+ShortToString(_in[_pos])+":"+StringSubstr(_instr,_pos,10)+"...");
                        break;
                    }


                    if (_in[end] == '\\') {

                        ret = ret + StringSubstr(_instr,_pos,end-_pos);
                        end++;
                        if (end >= _len) {
                          setError(4,"parse error after escape");
                        } else {
                            ushort c = 0;
                            switch(_in[end]) {
                                case '"':
                                case '\\':
                                case '/':
                                    c = _in[end];
                                    break;
                                case 'b': c = 8; break;
                                case 'f': c = 12; break;
                                case 'n': c = '\n'; break;
                                case 'r': c = '\r'; break;
                                case 't': c = '\t'; break;
                                default:
                                          setError(3,"unknown escape");
                            }
                            if (c == 0) break;
                            ret = ret + ShortToString(c);
                            _pos = end+1;
                        }
                    } else if (_in[end] == '"') {

                        ret = ret + StringSubstr(_instr,_pos,end-_pos);
                        _pos = end+1;
                        break;
                    }
                }
            }
            if (_errCode != 0) {
                ret = NULL;
            }
            return ret;
        }

        JSONValue *parseValue()
        {
            JSONValue *ret = NULL;
            skipSpace();

            if (_in[_pos] == '[')  {

                ret = (JSONValue*)parseArray();

            } else if (_in[_pos] == '{')  {

                ret = (JSONValue*)parseObject();

            } else if (_in[_pos] == '"')  {

                string s = parseString();
                ret = (JSONValue*)new JSONString(s);

            } else if (isDoubleDigit(_in[_pos])) {
                bool isDoubleOnly = false;
                long l=0;
                long sign;

                int i = _pos;

                if (_in[_pos] == '-') {
                    sign = -1;
                    _pos++;
                } else if (_in[_pos] == '+') {
                    sign = 1;
                    _pos++;
                } else {
                    sign = 1;
                }

                while(i < _len && isDigit(_in[i])) {
                    l = l * 10 + ( _in[i] - '0' );
                    i++;
                }
                if (isDoubleDigit(_in[i])) {

                    while(i < _len && isDoubleDigit(_in[i])) {
                        i++;
                    }
                    string s = StringSubstr(_instr,_pos,i-_pos);
                    double d = sign * StringToDouble(s);
                    ret = (JSONValue*)new JSONNumber(d);
                } else {
                    l = sign * l;
                    ret = (JSONValue*)new JSONNumber(l);
                }
                _pos = i;

            } else if (_in[_pos] == 't' && StringSubstr(_instr,_pos,4) == "true")  {

                ret = (JSONValue*)new JSONBool(true);
                _pos += 4;

            } else if (_in[_pos] == 'f' && StringSubstr(_instr,_pos,5) == "false")  {

                ret = (JSONValue*)new JSONBool(false);
                _pos += 5;

            } else if (_in[_pos] == 'n' && StringSubstr(_instr,_pos,4) == "null")  {

                ret = (JSONValue*)new JSONNull();
                _pos += 4;

            } else {

                setError(3,"error parsing value at position "+(string)_pos);

            }

            if (_errCode != 0 && ret != NULL ) {
                delete ret;
                ret = NULL;
            }
            return ret;
        }

        JSONArray *parseArray()
        {
            JSONArray *ret = new JSONArray();

            int index = 0;
            skipSpace();
            if (expect('[')) {
                while (_errCode == 0) {
                    skipSpace();


                    JSONValue *v = parseValue();
                    if (_errCode != 0) break;

                    if (!ret.put(index++,v)) {
                        setError(3,"memory error adding "+(string)index);
                        break;
                    }

                    skipSpace();

                    if (!expectOptional(',')) break;
                }
                if (!expect(']')) {
                    setError(2,"list: expected , or ] ");
                }
            }

            if (_errCode != 0 ) {
                delete ret;
                ret = NULL;
            }
            return ret;
        }
};

class JSONIterator {
    private:
        HashLoop * _l;

    public:

    JSONIterator(JSONObject *jo)
    {
        _l = new HashLoop(jo.getHash());
    }
    ~JSONIterator()
    {
        delete _l;
    }

    bool hasNext()
    {
        return _l.hasNext();
    }


    void next() {
        _l.next();
    }


    JSONValue *val()
    {
        return (JSONValue *) (_l.val());
    }


    string key()
    {
        return _l.key();
    }

};

void json_demo()
{
    string s = "{ \"firstName\": \"John\", \"lastName\": \"Smith\", \"age\": 25, \"address\": { \"streetAddress\": \"21 2nd Street\", \"city\": \"New York\", \"state\": \"NY\", \"postalCode\": \"10021\" }, \"phoneNumber\": [ { \"type\": \"home\", \"number\": \"212 555-1234\" }, { \"type\": \"fax\", \"number\": \"646 555-4567\" } ], \"gender\":{ \"type\":\"male\" }  }";
    JSONParser *parser = new JSONParser();
    JSONValue *jv = parser.parse(s);
    Print("json:");
    if (jv == NULL) {
        Print("error:"+(string)parser.getErrorCode()+parser.getErrorMessage());
    } else {
        Print("PARSED:"+jv.toString());
        if (jv.isObject()) {
            JSONObject *jo = jv;


            Print("firstName:" + jo.getString("firstName"));
            Print("city:" + jo.getObject("address").getString("city"));
            Print("phone:" + jo.getArray("phoneNumber").getObject(0).getString("number"));


            if (jo.getString("firstName",s) ) Print("firstName = "+s);


            JSONIterator *it = new JSONIterator(jo);
            for( ; it.hasNext() ; it.next()) {
                Print("loop:"+it.key()+" = "+it.val().toString());
            }
            delete it;
        }
        delete jv;
    }
    delete parser;
}



#endif
