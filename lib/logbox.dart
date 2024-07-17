import 'package:objectbox/objectbox.dart';
@Entity()
class LogBox {
  @Id()
  int id = 0;

  String? app;
  bool? isDebug;
  String? loggerName;
  String? level;
  DateTime? timeStamp;
  String? message;
  
  Map<String, dynamic> toJson() => 
  {
    'application' : app,
    'Is Debug' : isDebug,
    'logger name' : loggerName,
    'id': id,
    'level': level?.toUpperCase(),
    'timestamp': timeStamp.toString(),
    'detail': message,
  };
  @override
  String toString() => "{Application: $app, Is Debug: $isDebug, Id: $id, Level: ${level?.toUpperCase()}, Timestamp: $timeStamp, Logger Name $loggerName, Detail: $message}";
}