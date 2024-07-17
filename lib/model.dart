import 'package:objectbox/objectbox.dart';
@Entity()
class Note {
  int id = 0;
  String? app = 'Prototype App';
  String? enviroment = 'DEV';
  String? name;
  String? message;
  DateTime? date;
  Map<String, dynamic> toJson() => 
  {
    'application' : app,
    'environment' : enviroment,
    'id': id,
    'level': name,
    
    'timestamp': date.toString(),
    'detail': message,
  };
  @override
  String toString() => "{application: $app,environment $enviroment,id: $id, level: $name, timestamp: $date, detail: $message}";


}
