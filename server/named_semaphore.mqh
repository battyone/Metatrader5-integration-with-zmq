string global_var_prefix = "zmq_mql_server";
string GLOBAL_COTEXT_EVENTS = "flag";
string GLOBAL_COTEXT_SYMBOL = "data";


string global_param_name(string param_name) {
  return global_var_prefix + "_" + param_name;
}

bool param_exists(string param_name) {
  return GlobalVariableCheck(global_param_name(param_name));
}

void set_param(string param_name, double param_value = 0) {
  string var_name = global_param_name(param_name);
  GlobalVariableTemp(var_name);
  GlobalVariableSet(var_name, param_value);
}

double get_param(string param_name) {
  return GlobalVariableGet(global_param_name(param_name));
}

double del_param(string param_name) {
  return GlobalVariableDel(global_param_name(param_name));
}