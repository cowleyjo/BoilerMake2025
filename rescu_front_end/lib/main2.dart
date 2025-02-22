<<<<<<< HEAD
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
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String _userType = 'Adopter'; // Default value

  // Function to send the POST request to create the user

Future<void> _createAccount() async {
  String username = _usernameController.text;
  String password = _passwordController.text;
  String location = _locationController.text;

  if (username.isNotEmpty && password.isNotEmpty && location.isNotEmpty) {
    final String backendUrl = 'http://127.0.0.1:5000/make-user';

    try {
      // Send POST request with data in the body
      final response = await http.post(
        Uri.parse(backendUrl),
        body: {
          'username': username,
          'password': password,
          'type': _userType,
          'location': location,
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
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: "Location"),
            ),
            SizedBox(height: 20),
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createAccount,
              child: Text("Create Account"),
            ),
          ],
        ),
      ),
    );
  }
}



// Adopter Screen
class AdopterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Adopter Screen")),
      body: Center(child: Text("Welcome Adopter")),
    );
  }
}

// Shelter Screen
class ShelterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Shelter Screen")),
      body: Center(child: Text("Welcome Shelter")),
    );
  }
}
=======
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
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String _userType = 'Adopter'; // Default value

  // Function to send the POST request to create the user

Future<void> _createAccount() async {
  String username = _usernameController.text;
  String password = _passwordController.text;
  String location = _locationController.text;

  if (username.isNotEmpty && password.isNotEmpty && location.isNotEmpty) {
    final String backendUrl = 'http://127.0.0.1:5000/make-user';

    try {
      // Send POST request with data in the body
      final response = await http.post(
        Uri.parse(backendUrl),
        body: {
          'username': username,
          'password': password,
          'type': _userType,
          'location': location,
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
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: "Location"),
            ),
            SizedBox(height: 20),
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createAccount,
              child: Text("Create Account"),
            ),
          ],
        ),
      ),
    );
  }
}



// Adopter Screen
class AdopterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Adopter Screen")),
      body: Center(child: Text("Welcome Adopter")),
    );
  }
}

// Shelter Screen
class ShelterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Shelter Screen")),
      body: Center(child: Text("Welcome Shelter")),
    );
  }
}
>>>>>>> 01281ac7a7adb0b21f1b5a7583e8440ebfceebb8
