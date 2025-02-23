import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // To parse JSON responses

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StartScreen(),
    );
  }
}

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome to the App")),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text("Login"),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateAccountScreen()),
              );
            },
            child: Text("Create Account"),
          ),
        ],
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _userType = 'Adopter';  // Default user type
  String? _errorMessage;

  // Login function to communicate with the back-end
  Future<void> loginUser(String username, String password, String type) async {
    final String backendUrl = 'http://127.0.0.1:5000/check-user';

    // Sending GET request with parameters
    final response = await http.get(
      Uri.parse('$backendUrl?username=$username&password=$password&type=$type'),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data['found'] == "true") {
        // Handle successful login
        print('User found!');
        // Navigate to the appropriate screen (Adopter or Shelter)
        if (_userType == 'Adopter') {
          Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdopterScreen()));
        } else {
          Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ShelterScreen()));
        }
      } else {
        // Handle invalid login
        setState(() {
          _errorMessage = 'User not found';
        });
      }
    } else {
      print('Failed to connect to the server');
      setState(() {
        _errorMessage = 'Failed to connect to the server';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),
            DropdownButton<String>(
              value: _userType,
              onChanged: (String? newValue) {
                setState(() {
                  _userType = newValue!;
                });
              },
              items: <String>['Adopter', 'Shelter']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: () {
                String username = _usernameController.text;
                String password = _passwordController.text;

                // Call the login function
                loginUser(username, password, _userType);
              },
              child: Text("Login"),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CreateAccountScreen extends StatefulWidget {
  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();  // New controller for email
  final _locationController = TextEditingController();

  // Define the user type dropdown
  String? _userType = 'Adopter';  // Default to Adopter

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();  // Dispose email controller
    _locationController.dispose();
    super.dispose();
  }

  // Handle creating the user (this could be expanded to make a DB insert)
  Future<void> _createAccount() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    String location = _locationController.text;
    String contact = _emailController.text;

    if (username.isNotEmpty && password.isNotEmpty && location.isNotEmpty) {
      final String backendUrl = 'http://127.0.0.1:5000/make-user';

      try {
        // Send POST request with data in the body
        final response = await http.post(
          Uri.parse(backendUrl),
          body: {
            'username': username,
            'password': password,
            'type': _userType ?? 'Adopter',  // Default to Adopter if no type selected
            'location': location,
            'contact': contact,
          },
        );

        if (response.statusCode == 200) {
          // If the request was successful, navigate to the respective screen
          if (_userType == 'Adopter') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdopterScreen()),
            );
          } else if (_userType == 'Shelter') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ShelterScreen()),
            );
          }
        } else {
          // If the request failed, show an error
          print("Failed to create account: ${response.body}");
        }
      } catch (e) {
        // Handle any exceptions
        print("Error: $e");
      }
    } else {
      print("Please enter all fields.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Username field
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            // Password field
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            // Email field (new input)
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            // Location field
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            // User Type dropdown menu
            DropdownButton<String>(
              value: _userType,
              onChanged: (String? newValue) {
                setState(() {
                  _userType = newValue;
                });
              },
              items: <String>['Adopter', 'Shelter']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createAccount,
              child: Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}



// Adopter Screen
class AdopterScreen extends StatefulWidget {
  @override
  _AdopterScreenState createState() => _AdopterScreenState();
}

class _AdopterScreenState extends State<AdopterScreen> with SingleTickerProviderStateMixin {
  // Controller for the tabs
  late TabController _tabController;

  // Parameters for the first tab
  double _radius = 10.0;  // Default radius value
  String? _selectedAnimalType; // Default value for dropdown

  final List<String> animalTypes = ['Dog', 'Cat', 'Rabbit', 'Bird', 'Other'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Three tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Placeholder screen for the second tab
  Widget placeholderScreen() {
    return Center(
      child: Text('Placeholder for now.'),
    );
  }

  // Inbox screen with placeholder content
  Widget inboxScreen() {
    return Center(
      child: Text('Your inbox is empty for now.'),
    );
  }

  // Parameters screen with radius slider and dropdown for animal type
  Widget parametersScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Slider for radius
          Row(
            children: [
              Text("Radius: ${_radius.toStringAsFixed(1)} miles"),
              Spacer(),
              Text('1 mile'),
              Slider(
                value: _radius,
                min: 1.0,
                max: 100.0,
                divisions: 99,
                onChanged: (double value) {
                  setState(() {
                    _radius = value;
                  });
                },
              ),
              Text('100 miles'),
            ],
          ),

          // Dropdown for animal type
          DropdownButton<String>(
            value: _selectedAnimalType,
            hint: Text('Select Animal Type'),
            onChanged: (String? newValue) {
              setState(() {
                _selectedAnimalType = newValue;
              });
            },
            items: animalTypes.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),

          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Logic to handle parameters
              print('Radius: ${_radius.toStringAsFixed(1)} miles');
              print('Animal Type: $_selectedAnimalType');
            },
            child: Text('Apply Filters'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adopter Screen'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Set Parameters'),
            Tab(text: 'Placeholder'),
            Tab(text: 'Inbox'), // New tab for Inbox
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          parametersScreen(),
          placeholderScreen(), // Second tab with placeholder content
          inboxScreen(), // New Inbox tab with placeholder content
        ],
      ),
    );
  }
}

// Shelter Screen
class ShelterScreen extends StatefulWidget {
  @override
  _ShelterScreenState createState() => _ShelterScreenState();
}

class _ShelterScreenState extends State<ShelterScreen> with SingleTickerProviderStateMixin {
  // Controller for the tabs
  late TabController _tabController;

  // Variables for pet input fields
  final _petNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _sexController = TextEditingController();
  final _sizeController = TextEditingController();
  final _typeController = TextEditingController();
  final _shelterController = TextEditingController();
  final _picController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Two tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    _petNameController.dispose();
    _ageController.dispose();
    _sexController.dispose();
    _sizeController.dispose();
    _typeController.dispose();
    _shelterController.dispose();
    _picController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Placeholder screen for connected users tab
  Widget connectedUsersScreen() {
    return Center(
      child: Text('List of users who have connected to animals will appear here.'),
    );
  }

  // Add Pet screen with form fields
  Widget addPetScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Pet Name Input
          TextField(
            controller: _petNameController,
            decoration: InputDecoration(labelText: 'Pet Name'),
          ),
          // Age Input
          TextField(
            controller: _ageController,
            decoration: InputDecoration(labelText: 'Age'),
            keyboardType: TextInputType.number,
          ),
          // Sex Input
          TextField(
            controller: _sexController,
            decoration: InputDecoration(labelText: 'Sex'),
          ),
          // Size Input
          TextField(
            controller: _sizeController,
            decoration: InputDecoration(labelText: 'Size'),
          ),
          // Type Input
          TextField(
            controller: _typeController,
            decoration: InputDecoration(labelText: 'Type'),
          ),
          // Shelter Input
          TextField(
            controller: _shelterController,
            decoration: InputDecoration(labelText: 'Shelter'),
          ),
          // Picture URL Input
          TextField(
            controller: _picController,
            decoration: InputDecoration(labelText: 'Picture URL'),
          ),
          // Description Input
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
            maxLines: 4,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Logic to handle adding pet
              print('Pet Name: ${_petNameController.text}');
              print('Age: ${_ageController.text}');
              print('Sex: ${_sexController.text}');
              print('Size: ${_sizeController.text}');
              print('Type: ${_typeController.text}');
              print('Shelter: ${_shelterController.text}');
              print('Pic URL: ${_picController.text}');
              print('Description: ${_descriptionController.text}');
              // You can add code here to save the pet info, etc.
            },
            child: Text('Add Pet'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shelter Screen'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Add Pet'),
            Tab(text: 'Connected Users'), // New tab for connected users
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          addPetScreen(),
          connectedUsersScreen(), // Connected Users tab
        ],
      ),
    );
  }
}
