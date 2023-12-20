import 'package:demo/profile.dart';
import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool timeConstraint = true;

  @override
  Widget build(BuildContext context) {
    String? userEmail = ModalRoute.of(context)!.settings.arguments as String?;
    print("email is : " + userEmail! );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF000000),
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(50.0),
                child: Text(
                  'Rideshare Home',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFFFFbbaeee),
                  ),
                ),
              ),
              Spacer(), // Add Spacer to push the following elements to the right
              CircleAvatar(
                backgroundColor: Colors.white, // White background
                radius: 20,
                child: IconButton(
                  icon: Icon(Icons.person, color: Colors.black), // Black icon
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Profile(userEmail: userEmail),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Color(0xFFbbaeee),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              FractionallySizedBox(
                widthFactor: 1.0,
                child: ElevatedButton(
                  onPressed: () {
                    // Add the desired action for the "Rides" button.
                    Navigator.pushNamed(context, '/rides', arguments: timeConstraint);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 20),
                  ),
                  child: Text(
                    'Rides',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 20),
              FractionallySizedBox(
                widthFactor: 1.0,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/orders');
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 20),
                  ),
                  child: Text(
                    'My Orders',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Time Constraint',
                    style: TextStyle(fontSize: 30,
                    fontWeight: FontWeight.bold),

                  ),
                  Switch(
                    value: timeConstraint,
                    onChanged: (value) {
                      setState(() {
                        timeConstraint = value;
                      });
                    },
                  ),
                ],
              ),],

          ),
        ),
      ),
    );
  }
}
