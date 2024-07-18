import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/physics.dart';

import 'dart:async';
import 'dart:convert';

import 'objectbox.g.dart';
import 'logs.dart';
import 'logbox.dart';

class ObjectBox {
  /// The Store of this app.
  late final Store store;
  ObjectBox._create(this.store);

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    // Future<Store> openStore() {...} is defined in the generated objectbox.g.dart
    final store = await openStore(directory: p.join(docsDir.path, "obx-example"));
    return ObjectBox._create(store);
  }
}

late ObjectBox storeObject;
final logBox = storeObject.store.box<LogBox>();
var jsons = <String>{};
final log = Logs.create("ActivityLogger");
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  storeObject = await ObjectBox.create();
  const Duration logSendRate = Duration(minutes: 3,seconds:0);
  Timer.periodic(logSendRate, (timer){handleTimer();});
  Logs.init("Learning_app",true,logBox);
  runApp(MyApp());
}

void handleTimer(){
  if(logBox.count()!=0){
      log.info("Timed Log Send Initiated");
  }
  Logs.printSavedLogs(logBox);
  Logs.sendSavedLogs(logBox);
  Logs.clearSavedLogs(logBox);
  return;
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Ethan Demo App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 248, 175, 5)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var prev = WordPair.random();
  void getNext() {
    prev = current;
    current = WordPair.random();
    notifyListeners();
  }
  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
      log.fine('Favorite Removed');
    } else {
      favorites.add(current);
      log.fine('Favorite Added');
    }
    notifyListeners();
  }

  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    Widget page;
    
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        log.info('Generator Page Entered');
      case 1:
        page = FavoritesPage();
        log.info('Favorites Page Entered');
      case 2:
        page = PhysicsPage();
        log.info('Physics Page Entered');
      case 3:
        page = LogPage();
        log.info('Log Page Entered');
      default:
        String trace = StackTrace.current.toString();
        log.shout('Landed on undefined page');
        log.shout('Stacktrace: $trace');
        throw UnimplementedError('no widget for $selectedIndex');
        
      }
    
    return LayoutBuilder(
      builder: (context,constraints) {
        return Scaffold(
          
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  elevation: 60,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.rocket_launch),
                      label: Text('Physics'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.list),
                      label: Text('Logs'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.warning_amber),
                      label: Text('Error Button'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    var pair2 = appState.prev;
    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          BigCard(pair: pair2),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                  log.finer('Next Word Generated');
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favs = appState.favorites;
    if (favs.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: IconButton(
              icon: Icon(Icons.delete),
              onPressed: (){
                appState.removeFavorite(pair);
                log.fine('Favorite Removed');
              },
            ),
            title: Text(pair.asLowerCase),
          ),
        ],
      );
  }
}

class LogPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loglist = logBox.getAll();
    if (loglist.isEmpty) {
      return Center(
        child: Text('No logs'),
      );
    }
    Padding(padding: EdgeInsets.all(20),);
    return ListView(
      children: [
        Row(
          children: [
            ElevatedButton(
                    onPressed: () {
                      // noteBox.removeAll();
                      Logs.clearSavedLogs(logBox);
                    },
                    child: Icon(Icons.recycling),
                  ),
            ElevatedButton(
                    onPressed: () {
                      // print("Json Array:");
                      // print(jsonEncode(loglist));
                      // print("   :Array End");
                      Logs.printSavedLogs(logBox);
                    },
                    child: Icon(Icons.print),
                  ),
            ElevatedButton(
                    onPressed: () {
                      // Uri endpoint = Uri.parse('https://qx8xc9xtcl.execute-api.us-west-2.amazonaws.com/default/LogHandlerTest');
                      // http.post(endpoint,
                      // headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8',},
                      // body: jsonEncode(loglist));
                      Logs.sendSavedLogs(logBox);
                    },
                    child: Icon(Icons.mail),
                  ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${logBox.count()} logs:'),
        ),
        for (var lognote in loglist)
          ListTile(
            leading: Icon(Icons.info),
            //title: Text('${lognote.name}:${lognote.date}:${lognote.message}'),
            title: Text(jsonEncode(lognote)),
          ),
        ],
      );
  }
}

class PhysicsPage extends StatelessWidget {
  const PhysicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const DraggableCard(
        child: FlutterLogo(
          size: 100,
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      elevation: 10.0,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Text("${pair.first} ${pair.second}",style:style),
      ),
    );
  }
}

class DraggableCard extends StatefulWidget {
  const DraggableCard({required this.child, super.key});

  final Widget child;

  @override
  State<DraggableCard> createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _animation;
  Alignment _dragAlignment = Alignment.center;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _controller.addListener(() {
      setState(() {
      _dragAlignment = _animation.value;
      });
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    
  }

  void _runAnimation(Offset pixelsPerSecond,Size size) {
    _animation = _controller.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: Alignment.center,
      ),
    );
    final unitsPerSecondX = pixelsPerSecond.dx / size.width;
    final unitsPerSecondY = pixelsPerSecond.dy / size.height;
    final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final unitVelocity = unitsPerSecond.distance;

    const spring = SpringDescription(
      mass: 20,
      stiffness: 0.5,
      damping: 2,
    );

    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);

    _controller.animateWith(simulation);
  }


  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    
    return GestureDetector(
      onPanDown: (details) {
        _controller.stop();
        log.fine('Physics Object Grabbed');
      },
      onPanUpdate: (details) {
        setState(() {
          _dragAlignment += Alignment(
            details.delta.dx / (size.width / 3),
            details.delta.dy / (size.height / 3),
         );
       });
     },
      onPanEnd: (details) {
        _runAnimation(details.velocity.pixelsPerSecond,size);
        double oldX = size.width/2;
        double oldY = size.height/2;
        String vel = details.velocity.toString();
        String detail = details.toString();
        log.fine(Logs.groupMessages(['Physics Object Released',
        'Screen Center:($oldX, $oldY)',
        'Velocity:<$vel>',
        'Details:$detail']));
      },
      child: Align(
      alignment: _dragAlignment,
      child: Card(
        child: widget.child,
      ),
      ),
    );
  }
}
