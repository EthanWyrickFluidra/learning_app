

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:http/http.dart' as http;
import '../objectbox.g.dart';
import 'logbox.dart';




enum LogLevel {
  finest,
  finer,
  fine,
  debug,
  info,
  warning,
  error,
  fatal,
}

/// [Logs] is used to display various information in the application
class Logs{ 
  static Logger create(String loggerName) {
    return Logger(loggerName);
  }

  static void init(String appName,bool isDebug, Box<LogBox> logBox){
    bool isDebug = kDebugMode;
    Logger.root.level = Level.ALL; // defaults to Level.INFO
    Logger.root.onRecord.listen((record) {
      if (kDebugMode) {
        switch (record.level) {
          case Level.FINEST:
            formatAndPrint(
              app: appName,
              isDebug: isDebug,
              level: LogLevel.finest,
              timeStamp: record.time,
              loggerName: record.loggerName,
              message: record.message,
            );
            final newLog = LogBox();
            {newLog.app = appName;
              newLog.isDebug = isDebug;
              newLog.level = LogLevel.finest.name;
              newLog.timeStamp = record.time;
              newLog.loggerName =record.loggerName;
              newLog.message = record.message;
            }
            logBox.put(newLog);
            break;
          case Level.FINER:
            formatAndPrint(
              app: appName,
              isDebug: isDebug,
              level: LogLevel.finer,
              timeStamp: record.time,
              loggerName: record.loggerName,
              message: record.message,
            );
            final newLog = LogBox();
            {newLog.app = appName;
              newLog.isDebug = isDebug;
              newLog.level = LogLevel.finer.name;
              newLog.timeStamp = record.time;
              newLog.loggerName =record.loggerName;
              newLog.message = record.message;
            }
            logBox.put(newLog);
            break;
          case Level.FINE:
            formatAndPrint(
              app: appName,
              isDebug: isDebug,
              level: LogLevel.fine,
              timeStamp: record.time,
              loggerName: record.loggerName,
              message: record.message,
            );
            final newLog = LogBox();
            {newLog.app = appName;
              newLog.isDebug = isDebug;
              newLog.level = LogLevel.fine.name;
              newLog.timeStamp = record.time;
              newLog.loggerName =record.loggerName;
              newLog.message = record.message;
            }
            logBox.put(newLog);
            break;
          case Level.CONFIG:
            formatAndPrint(
              app: appName,
              isDebug: isDebug,
              level: LogLevel.debug,
              timeStamp: record.time,
              loggerName: record.loggerName,
              message: record.message,
            );

            final newLog = LogBox();
            {newLog.app = appName;
              newLog.isDebug = isDebug;
              newLog.level = LogLevel.debug.name;
              newLog.timeStamp = record.time;
              newLog.loggerName =record.loggerName;
              newLog.message = record.message;
            }
            logBox.put(newLog);
            break;
          case Level.INFO:
            formatAndPrint(
              app: appName,
              isDebug: isDebug,
              level: LogLevel.info,
              timeStamp: record.time,
              loggerName: record.loggerName,
              message: record.message,

            );

            final newLog = LogBox();
            {newLog.app = appName;
              newLog.isDebug = isDebug;
              newLog.level = LogLevel.info.name;
              newLog.timeStamp = record.time;
              newLog.loggerName =record.loggerName;
              newLog.message = record.message;
            }
            logBox.put(newLog);
            break;
          case Level.WARNING:
            formatAndPrint(
              app: appName,
              isDebug: isDebug,
              level: LogLevel.warning,
              timeStamp: record.time,
              loggerName: record.loggerName,
              message: record.message,
            );

            final newLog = LogBox();
            {newLog.app = appName;
              newLog.isDebug = isDebug;
              newLog.level = LogLevel.warning.name;
              newLog.timeStamp = record.time;
              newLog.loggerName =record.loggerName;
              newLog.message = record.message;
            }
            logBox.put(newLog);
            break;
          case Level.SEVERE:
            formatAndPrint(
              app: appName,
              isDebug: isDebug,
              level: LogLevel.error,
              timeStamp: record.time,
              loggerName: record.loggerName,
              message: record.message,
            );

            final newLog = LogBox();
            {newLog.app = appName;
              newLog.isDebug = isDebug;
              newLog.level = LogLevel.error.name;
              newLog.timeStamp = record.time;
              newLog.loggerName =record.loggerName;
              newLog.message = record.message;
            }
            logBox.put(newLog);
            break;
          case Level.SHOUT:
            formatAndPrint(
              app: appName,
              isDebug: isDebug,
              level: LogLevel.fatal,
              timeStamp: record.time,
              loggerName: record.loggerName,
              message: record.message,
            );

            final newLog = LogBox();
            {newLog.app = appName;
              newLog.isDebug = isDebug;
              newLog.level = LogLevel.fatal.name;
              newLog.timeStamp = record.time;
              newLog.loggerName =record.loggerName;
              newLog.message = record.message;
            }
            logBox.put(newLog);
            break;
          default:
            print('${record.level.name}: ${record.time}: ${record.message}');
        }
      }
    });
  }

  static void formatAndPrint({
    required String app,
    required bool isDebug,
    required LogLevel level,
    required DateTime timeStamp,
    required String loggerName,
    required String message,
  }) {
    final Map<LogLevel, String> levelColors = {
      LogLevel.finest: LogColors.ansi(LogLevel.finest),
      LogLevel.finer: LogColors.ansi(LogLevel.finer),
      LogLevel.fine: LogColors.ansi(LogLevel.fine),
      LogLevel.debug: LogColors.ansi(LogLevel.debug),
      LogLevel.info: LogColors.ansi(LogLevel.info),
      LogLevel.warning: LogColors.ansi(LogLevel.warning),
      LogLevel.error: LogColors.ansi(LogLevel.error),
      LogLevel.fatal: LogColors.ansi(LogLevel.fatal),
    };
    final Map<LogLevel, String> levelEmojis = {
      LogLevel.finest: '',
      LogLevel.finer: '',
      LogLevel.fine: '',
      LogLevel.debug: '🐛',
      LogLevel.info: '💡',
      LogLevel.warning: '⚠️',
      LogLevel.error: '⛔',
      LogLevel.fatal: '👾',
    };
    
    if (kDebugMode) {
      
      String logOutput = '${level.name.toUpperCase()}: ${app}: Debug=${isDebug}: $timeStamp: $loggerName: $message';
      print('${levelColors[level]} ${levelEmojis[level]} $logOutput');
      
      // Uri endpoint = Uri.parse('https://5rwa2jvevy1no1qnvq4g.us-west-2.aoss.amazonaws.com');
      // http.post(endpoint,
      //     headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8',},
      //     body: logOutput);
     
      return;
    }
  }
  
  static String printSavedLogs(Box<LogBox> logBox){
    try{
      if(logBox.count()==0){
        print("Logs Empty");
        return "Logs.printSavedLogs:No Logs to Send";
      }
      final loglist = logBox.getAll();
      var printList = <Map<String,dynamic>>[];
      for(var log in loglist) {
        printList.add(log.toJson());
      }
      print(jsonEncode(printList));
    }catch(e){
      return "Logs.printSavedLogs:ERROR;${e.toString()}";
    }
    return "Logs.printSavedLogs:Successful Completion";
  }

  static String clearSavedLogs(Box<LogBox> logBox){
    try{
      if(logBox.count()==0){
        return "Logs.clearSavedLogs:No Logs to Send";
      }
      logBox.removeAll();
      
    }catch(e){
      return "Logs.clearSavedLogs:ERROR;${e.toString()}";
    }
    return "Logs.clearSavedLogs:Successful Completion";
  }

  static String sendSavedLogs(Box<LogBox> logBox){
    
    // TODO: implement encryption for log file sending
    try{
      if(logBox.count()==0){
        return "Logs.sendSavedLogs:No Logs to Send";
      }
      final loglist = logBox.getAll();
      var sendList = <Map<String,dynamic>>[];
      for(var log in loglist) {
        sendList.add(log.toJson());
      }
      Uri endpoint = Uri.parse('https://5rwa2jvevy1no1qnvq4g.us-west-2.aoss.amazonaws.com');
      http.post(endpoint,
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8',},
        body: jsonEncode(sendList));
    }catch(e){
      return "Logs.sendSavedLogs:ERROR;${e.toString()}";
    }
    return "Logs.sendSavedLogs:Successful Completion";
  }

  static String groupMessages(List<String> messageList){
    String collectedMessage = "";
    int count = 1;
    int msglength = messageList.length;
    if(messageList.isEmpty){
      return "";
    }
    for(String message in messageList){
      collectedMessage = '$collectedMessage$message';
      if(count != msglength){
        collectedMessage = '$collectedMessage|';
      }
      count +=1;
    }
    return collectedMessage;
  }
}

class LogColors {
  static const ansiEsc = '\x1B[';

  static String ansi(LogLevel level) {
    switch (level) {
      case LogLevel.fine:
        return '${ansiEsc}32m';
      case LogLevel.debug:
        return '${ansiEsc}37m';
      case LogLevel.info:
        return '${ansiEsc}36m';
      case LogLevel.warning:
        return '${ansiEsc}33m';
      case LogLevel.error:
        return '${ansiEsc}31m';
      case LogLevel.fatal:
        return '${ansiEsc}35m';
      default:
        return '${ansiEsc}0m';
    }
  }
}
