import 'dart:ffi';

import 'package:english_words/english_words.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ChangeNotifierProvider(
        create: (context) => MyAppState(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Namer App",
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF7289da)),
          ),
          home: MyHomePage(),
        ),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favotires = <WordPair>[];
  void toggleFavorite() {
    if (favotires.contains(current)) {
      favotires.remove(current);
    } else {
      favotires.add(current);
    }
    notifyListeners();
  }

  void deleteWord(WordPair word) {
    favotires.remove(word);
    notifyListeners();
  }
  String checkIfListIsFull(){
    return favotires.length == 9 ? "Your favotire List is Full" : " Your Have ${favotires.length} Words";
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndexVar = 0;

  @override
  Widget build(BuildContext context) {
    Widget page = GeneratorPage();

    switch (selectedIndexVar) {
      case 0:
        page = GeneratorPage();
        print(page);
      case 1:
        page = FavoritesPage();
        print(page);
      default:
        throw UnimplementedError("No Widget For ${selectedIndexVar}");
    }
    return Scaffold(
        body: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SafeArea(
            minimum: const EdgeInsets.all(0),
            child: NavigationRail(
              extended: false,
              destinations: [
                NavigationRailDestination(
                    icon: Icon(Icons.home), label: Text("Home")),
                NavigationRailDestination(
                    icon: Icon(Icons.favorite), label: Text("Favorites")),
              ],
              selectedIndex: selectedIndexVar,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndexVar = value;
                });
              },
            )),
        // Text("Hello")
        Expanded(
            child: Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: page,
        ))
      ],
    ));
  }
}

class FavoritesPage extends StatefulWidget {
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Column(
      children: [
        SizedBox(
          height: 70,
        ),
        Text(
          "Your Favorites Random English Words",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        Column(
          children: [
            if (appState.favotires.isEmpty) ...[
              Card(
                child: ListTile(
                  title: Center(child: Text("The List Is Empty")),
                ),
              ),
            ] else ...[
              ListView(
                shrinkWrap: true,
                children: [
                  for (final word in appState.favotires) ...[
                    Card(
                        child: InkWell(
                      onTap: () => {laucheURL(word.asPascalCase)},
                      child: ListTile(
                        title: Text(word.asPascalCase),
                        trailing: InkWell(
                          onTap: () => {appState.deleteWord(word)},
                          child: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    )),
                  ]
                ],
              )
            ],
            Text(
              " Tap The Word To Open It With Google",
              style: TextStyle(fontSize: 12),
            ),
          ],
        )
      ],
    );
  }
}

laucheURL(String query) async {
  final Uri url = Uri.parse("https://www.google.com/search?q=$query meaning");
  if (!await launchUrl(url)) {
    throw Exception("Could not lauche $url");
  }
}

class GeneratorPage extends StatefulWidget {
 
  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage>
    with TickerProviderStateMixin {
  static const clickAnimationDurationMillis = 150;
  double _scaleTransformValue = 1;
  late final AnimationController BigBoxanimationController;
 
  @override
  void initState() {
    super.initState();
 
    BigBoxanimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: clickAnimationDurationMillis),
      lowerBound: 0.0,
      upperBound: 0.2,
    )..addListener(() {
        setState(() {
          _scaleTransformValue = 1 + BigBoxanimationController.value;
 
        });
 
      });
    
  }
  @override
  void dispose(){
 
    BigBoxanimationController.dispose();
    super.dispose();
  }
  void scaleBigCardSize(){
    BigBoxanimationController.forward();
 
  }
  void _restoreBigCardSize(){
    Future.delayed(
      const Duration(
        milliseconds: clickAnimationDurationMillis),
        (){
          BigBoxanimationController.reverse();
        }
      );
  }
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    IconData icon = appState.favotires.contains(pair)? Icons.favorite: Icons.favorite_border;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Your Daily Word is",
            style: TextStyle(fontSize: 23),
          ),
          Transform.scale(
            scale: _scaleTransformValue,
            child:  BigCard(pair: pair),
          ),
          SizedBox(
            height: 10,
          ),
          Text(appState.checkIfListIsFull() ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: 1,
                child:ElevatedButton.icon(
                    onPressed: () {
                      if(appState.checkIfListIsFull() == "Your favotire List is Full")
                      { 

                      }else{
                        appState.toggleFavorite();
                      }
 
                    },
                    icon: Icon(icon),
                    label: Text("Like"),
                  ) 
              )
              ,
              SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: ()  {
 
                  appState.getNext();
                  scaleBigCardSize();
                  _restoreBigCardSize();
                },
                icon: Icon(Icons.navigate_next),
                label: Text("Next"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF7289da),
                  foregroundColor: Colors.white,
                ),
              ),      
            ],
          )
        ],
      ),
    );
  }
}

class BigCard extends StatefulWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  State<BigCard> createState() => _BigCardState();
}

class _BigCardState extends State<BigCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          widget.pair.asLowerCase,
          style: style,
        ),
      ),
    );
  }
}
