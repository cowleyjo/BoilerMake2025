import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: AuthWrapper(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  
  bool isAuthenticated = false;

  var current = WordPair.random();
  var favorites = <WordPair>[];

  void login(String username, String password) {
    if (username.isNotEmpty && password.isNotEmpty) {
      isAuthenticated = true;
      notifyListeners();
    }
  }

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    current = WordPair.random();
    notifyListeners();
  }
}

//Wraps the app and prevents access without a login
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.isAuthenticated) {
      return MyHomePage();
    } else {
      return LoginPage();
    }
  }
}

// Simple login page
class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers for the username and password fields.
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Call login on the app state. This could be replaced by an API call.
                context.read<MyAppState>().login(
                      _usernameController.text,
                      _passwordController.text,
                    );
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritesPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: false,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text('Favorites'),
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
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

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
          SwipeableCard(
            pair: pair,
            onLike: () {
              appState.toggleFavorite();
            },
            onNext: () {
              appState.getNext();
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

// The Favorites page displays a list of favorited word pairs.
class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
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
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

// The Card that displays a word pair and can be swiped left or right.
class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    var style = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: pair.asPascalCase,
        ),
      ),
    );
  }
}

class SwipeableCard extends StatefulWidget {
  final WordPair pair;
  final VoidCallback onLike; // Action for a right swipe
  final VoidCallback onNext; // Action for a left swipe

  const SwipeableCard({
    Key? key,
    required this.pair,
    required this.onLike,
    required this.onNext,
  }) : super(key: key);

  @override
  _SwipeableCardState createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard> with SingleTickerProviderStateMixin {
  double _offsetX = 0;
  final double threshold = 100; // Customize this value as needed

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        // Accumulate the horizontal drag distance
        setState(() {
          _offsetX += details.delta.dx;
        });
      },
      onPanEnd: (details) {
        // Determine if the drag distance exceeds the threshold
        if (_offsetX < threshold) {
          widget.onLike();
        } else if (_offsetX > -threshold) {
          widget.onNext();
        }
        // Reset the offset with a smooth animation if desired
        setState(() {
          _offsetX = 0;
        });
      },
      child: Transform.translate(
        offset: Offset(_offsetX, 0),
        child: BigCard(pair: widget.pair),
      ),
    );
  }
}