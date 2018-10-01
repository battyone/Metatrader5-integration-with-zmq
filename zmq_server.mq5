ENUM_TIMEFRAMES to_period(string time_frame) {
   switch (time_frame) {
      case 0: return(PERIOD_CURRENT);
      case "PERIOD_M1": return(PERIOD_M1);
      case "PERIOD_M5": return(PERIOD_M5);
      case "PERIOD_M15": return(PERIOD_M15);
      case "PERIOD_M30": return(PERIOD_M30);
      case "PERIOD_H1": return(PERIOD_H1);
      case "PERIOD_H4": return(PERIOD_H4);
      case "PERIOD_D1": return(PERIOD_D1);
      case "PERIOD_W1": return(PERIOD_W1);
      case "PERIOD_MN1": return(PERIOD_MN1);
      case "PERIOD_M2": return(PERIOD_M2);
      case "PERIOD_M3": return(PERIOD_M3);
      case "PERIOD_M4": return(PERIOD_M4);
      case "PERIOD_M6": return(PERIOD_M6);
      case "PERIOD_M10": return(PERIOD_M10);
      case "PERIOD_M12": return(PERIOD_M12);
      case "PERIOD_H1": return(PERIOD_H1);
      case "PERIOD_H2": return(PERIOD_H2);
      case "PERIOD_H3": return(PERIOD_H3);
      case "PERIOD_H4": return(PERIOD_H4);
      case "PERIOD_H6": return(PERIOD_H6);
      case "PERIOD_H8": return(PERIOD_H8);
      case "PERIOD_H12": return(PERIOD_H12);
      case "PERIOD_D1": return(PERIOD_D1);
      case "PERIOD_W1": return(PERIOD_W1);
      case "PERIOD_MN1": return(PERIOD_MN1);
      default: return(PERIOD_CURRENT);     
   }
}