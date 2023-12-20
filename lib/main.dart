import 'package:demo/paymentCard.dart';
import 'package:demo/paymentFawry.dart';
import 'package:demo/profile.dart';
import 'package:demo/rides.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'SignUp.dart';
import 'home.dart';
import 'Orders.dart';
import 'payment.dart';
import 'mydatabase.dart';
import 'loadingScreen.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Simulate some initialization tasks
  Future<void> _initialize() async {
    // Add your initialization tasks here
    await Future.delayed(Duration(seconds: 5)); // Simulating a delay of 2 seconds
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFF2B2B2C),
        hintColor: Colors.black,
        fontFamily: 'Roboto',
      ),
      home: FutureBuilder(
        future: _initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Initialization is complete, navigate to LoginPage
            return LoginPage();
          } else {
            // Initialization is in progress, show a splash screen
            return SplashScreen(); // You need to create a SplashScreen widget
          }
        },
      ),
      routes: {
        '/Home'                 : (context)   => HomePage(),
        '/orders'               : (context)   => OrdersPage(),
        '/payment'              : (context)   => Payment(),
        '/SignUp'               : (context)   => SignUp(),
        '/rides'                : (context)   => rides(),
        '/paymentCard'          : (context)   => paymentCard(),
        '/paymentFawry'         : (context)   => paymentFawry(),
        '/profile'              : (context)   => Profile(),
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LoadingScreen(); // Use your loading screen widget
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}



class _LoginPageState extends State<LoginPage> {
  mydatabaseclass mydb = mydatabaseclass();
  List<Map> mylist = [];
  Future Reading_Database() async {
    List<Map> response = await mydb.reading('''SELECT * FROM 'TABLE1' ''');
    mylist = [];
    mylist.addAll(response);
    setState(() {});
  }

  @override
  void initState() {
    Reading_Database();
    super.initState();
    mydb.checking();
  }

  String username = '';
  String email = '';
  String password = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> loginUser(BuildContext context, String email, String password) async {
    try {
      if (!email.endsWith('@eng.asu.edu.eg')) {

        return _showErrorDialog(context, 'Error: Email must have \nthe domain \n(@eng.asu.edu.eg)');
      }
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Navigate to the home page or perform any other actions after successful login
      Navigator.pushReplacementNamed(context, "/Home", arguments: email);
      print('User logged in: ${userCredential.user!.uid}');
    } catch (e) {
      String removeStringInsideBrackets(String input)
      {
        RegExp regex = RegExp(r'\[.*?\]');
        return input.replaceAll(regex, '');}
      // Handle sign-up errors
      String errorMessage = e.toString();
      String filteredMessage = removeStringInsideBrackets(errorMessage);
      _showErrorDialog(context,filteredMessage);

    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF000000),
        title: Center(
          child: Text(
            'Welcome to Rideshare',
            style:
              TextStyle(
                color: Color(0xFFFFbbaeee),
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
          ),
        ),
       // centerTitle: true,


      backgroundColor: Color(0xFFbbaeee),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.black,
                  fontSize: 20,
                  ),
                  prefixIcon: Icon(Icons.email_rounded, color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 2.0,
                    ),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 2.0,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.black,
                  fontSize: 20),
                  prefixIcon: Icon(Icons.lock_rounded, color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 2.0,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                obscureText: true,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  loginUser(context, email, password);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  onPrimary: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/SignUp');
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  'Don\'t have an account? Sign up here',
                  style: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0), // Set the border radius
          side: BorderSide(color: Colors.black, width: 3),
          // Set the border color
        ),
        backgroundColor: Color(0xF7bbaeee),
        title: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(
            child: Text(
              message,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xFFFF0000),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Center(
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFFFF0000),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

