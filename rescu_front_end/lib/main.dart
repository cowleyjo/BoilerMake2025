import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  bool isShelter = false; // Tracks if the user is a shelter

  List<String> names = ['Buddy', 'Max', 'Bella', 'Charlie', 'Luna', 'Rocky', 'Milo', 'Daisy'];
  var current = "Bella";

  final random = Random();
  var favorites = <String>[];

  void login(String username, String password) {
    if (username.isNotEmpty && password.isNotEmpty) {
      isAuthenticated = true;
      notifyListeners();
    }
  }

  void createAccount(String username, String password) {
    if (username.isNotEmpty && password.isNotEmpty) {
      isAuthenticated = true;
      print("New Account! Yippee");
      notifyListeners();
    }
  }

  void getNext() {
    current = names[random.nextInt(names.length)]; // Pick a random name
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    getNext();
    notifyListeners();
  }

  void toggleRole(String userType) {
    //isShelter = !isShelter;
    if (userType == 'Adopter') {
      isShelter = false;
    } else if (userType == 'Shelter') {
      isShelter = true;
    }
    print("Is shelter $isShelter");
    notifyListeners();
  }
}

//Wraps the app and prevents access without a login
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.isAuthenticated) {
      if (appState.isShelter) {
        return ShelterScreen();
      } else {
        return MyHomePage();
      }
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
  String userType = 'Adopter'; //Default Selection

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            Text(
              'RescU',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 20),

            // Dropdown menu
            DropdownButtonFormField<String>(
              value: userType,
              decoration: const InputDecoration(labelText: 'User Type'),
              items: ['Adopter', 'Shelter']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  userType = value!;
                  context.read<MyAppState>().toggleRole(userType);
                  print("User Type $userType");
                });
              },
            ),

            // Username Field
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            
            // Password Field
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                //Create Account Button
                ElevatedButton(
                  onPressed: (){
                    context.read<MyAppState>().createAccount(
                      _usernameController.text, 
                      _passwordController.text
                      );
                }, 
                child: Text('Create Account')),
                SizedBox(width: 50),
                //Login Button
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

class GeneratorPage extends StatefulWidget {
  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _radiusController = TextEditingController();

  String? _petResult; // Stores the pet data
  String? _errorMessage; // For any error messages, if needed
  String? prevAddress; // Stores the previous address entered by the user

  // Function to get coordinates from the address
  Future<Map<String, double>?> getCoordinatesFromAddress(String address) async {
    final String apiKey = '459106e0e6454bf69a1afe468d23fed9';  // Replace with your OpenCage API key
    final String encodedAddress = Uri.encodeComponent(address);  // Encode the address
    final String url = 'https://api.opencagedata.com/geocode/v1/json?q=$encodedAddress&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      if (data['results'].isNotEmpty) {
        double latitude = data['results'][0]['geometry']['lat'];
        double longitude = data['results'][0]['geometry']['lng'];
        
        return {'latitude': latitude, 'longitude': longitude};
      } else {
        print("No results found for the address.");
        return null;
      }
    } else {
      print("Error fetching data: ${response.statusCode}");
      return null;
    }
  }

  // Function to fetch pet data from backend
  Future<void> _getPet() async {
    String address = _addressController.text;
    double radius = double.tryParse(_radiusController.text) ?? 10.0;

    if (address.isEmpty) {
      setState(() {
        _errorMessage = "Please enter an address.";
      });
      return;
    }

    var coordinates;
    // Check if the address has changed
    if (prevAddress != address) {
      // Get the coordinates from the address
      print("API Call");
      coordinates = await getCoordinatesFromAddress(address);
      prevAddress = address;  // Update the previous address to the current one
    }

    if (coordinates != null) {
      double latitude = coordinates['latitude']!;
      double longitude = coordinates['longitude']!;

      final String backendUrl = 'http://127.0.0.1:5000/get-pet';

      // Send coordinates along with radius to the backend
      final response = await http.get(
        Uri.parse('$backendUrl?longitude=$longitude&latitude=$latitude&radius=$radius'),
      );

      if (response.statusCode == 200) {
        var pet = jsonDecode(response.body);
        setState(() {
          _petResult = "Found Pet: ${pet['name']}, Age: ${pet['age']}";
          _errorMessage = null; // Clear any previous error messages
        });
      } else {
        setState(() {
          _petResult = "No pet found.";
          _errorMessage = null;
        });
      }
      print(response.statusCode);
    } else {
      setState(() {
        _errorMessage = "Unable to retrieve coordinates for the address.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var animal = appState.current;

    IconData icon;
    if (appState.favorites.contains(animal)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Scaffold(
      appBar: AppBar(title: Text("Find a Pet")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: "Enter your address"),
            ),
            TextField(
              controller: _radiusController,
              decoration: InputDecoration(labelText: "Enter search radius (km)"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getPet,
              child: Text("Find Pet"),
            ),
            SizedBox(height: 20),
            _petResult != null
                ? Text(_petResult!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                : Container(),
            _errorMessage != null
                ? Text(_errorMessage!, style: TextStyle(color: Colors.red, fontSize: 16))
                : Container(),
            SizedBox(height: 40),
            SwipeableCard(
              name: animal,
              onLike: () {
                appState.toggleFavorite();
              },
              onNext: () {
                appState.getNext();
              },
            ),
          ],
        ),
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
        for (var animal in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(animal),
          ),
      ],
    );
  }
}

// The Shelter Screen allows shelters to add animals
class ShelterScreen extends StatefulWidget {
  @override
  _ShelterScreenState createState() => _ShelterScreenState();
}

class _ShelterScreenState extends State<ShelterScreen> {
  final TextEditingController _nameController = TextEditingController();
  List<String> shelterAnimals = []; // List of animals added

  void addAnimal() {
    if (_nameController.text.isNotEmpty) {
      setState(() {
        shelterAnimals.add(_nameController.text);
      });
      _nameController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Shelter Animal Management")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Animal Name"),
            ),
          ),
          ElevatedButton(
            onPressed: addAnimal,
            child: Text("Add Animal"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: shelterAnimals.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(shelterAnimals[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// The Card that displays a word pair and can be swiped left or right.
class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.name,
  });

  final String name;

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
          name,
          style: style,
          semanticsLabel: name,
        ),
      ),
    );
  }
}

class SwipeableCard extends StatefulWidget {
  final String name;
  final VoidCallback onLike; // Action for a right swipe
  final VoidCallback onNext; // Action for a left swipe

  const SwipeableCard({
    Key? key,
    required this.name,
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
        child: BigCard(name: widget.name),
      ),
    );
  }
}

Future<Map<String, dynamic>?> getPet(String address, double radius) async {
  final String backendUrl = 'http://127.0.0.1:5000/get-pet'; // Change to your backend URL

  final response = await http.get(
    Uri.parse('$backendUrl?address=$address&radius=$radius'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body); // Convert JSON response to a Dart map
  } else {
    print('Error fetching pet: ${response.body}');
    return null;
  }
}

Future<Map<String, double>?> getCoordinatesFromAddress(String address) async {
  final String apiKey = '459106e0e6454bf69a1afe468d23fed9';
  final String url = 'https://api.opencagedata.com/geocode/v1/json?q=$address&key=$apiKey';

  final response = await http.get(Uri.parse(url));
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    
    if (data['results'].isNotEmpty) {
      double latitude = data['results'][0]['geometry']['lat'];
      double longitude = data['results'][0]['geometry']['lng'];

      print("latitude: $latitude, longitude: $longitude");
      return {'latitude': latitude, 'longitude': longitude};
    } else {
      print("No results found for the address.");
      return null;
    }
  } else {
    print("Error fetching data: ${response.statusCode}");
    return null;
  }
}