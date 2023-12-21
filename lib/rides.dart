import 'package:flutter/material.dart';
import 'database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'dart:core';
import 'package:intl/intl.dart';



class rides extends StatefulWidget {
  const rides({Key? key}) : super(key: key);

  @override
  State<rides> createState() => _ridesState();
}

class _ridesState extends State<rides> {
  late Future<List<Map<String, dynamic>>> data = getData();
  List<Map<String, dynamic>> ridesData = [];
  List<Map<String, dynamic>> filteredRidesData = [];


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF000000),
        title: Center(
          child: Text(
            'Rides Page',
            style: TextStyle(
              color: Color(0xFFbbaeee),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () {
              showSortDialog();
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearchBar();
            },
          ),
        ],
      ),
      backgroundColor: Color(0xFFbbaeee),
      body: Center(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: data,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              ridesData = snapshot.data!;
              return buildRidesList();
            }
          },
        ),
      ),
    );
  }

  Widget buildRidesList() {
    bool timeConstraint = ModalRoute.of(context)!.settings.arguments as bool;
    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: filteredRidesData.isNotEmpty ? filteredRidesData.length : ridesData.length,
      itemBuilder: (context, index) {
        final ride = filteredRidesData.isNotEmpty ? filteredRidesData[index] : ridesData[index];
        String driverEmail = (ride['Driver_Email'] ?? '').replaceAll('@driver.com', '');
        return Card(
          margin: EdgeInsets.all(10.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: Colors.black, width: 2.0),
          ),
          color: Color(0xFFFFFFFF),
          child: ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Source: ${ride['Source']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22.0,
                  ),
                ),
                Text(
                  'Destination: ${ride['Destination']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22.0,
                  ),
                ),
                Text(
                  'Driver: ${driverEmail}',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFff8900),
                  ),
                ),
                Text(
                  'Time: ${ride['Date']} ' + ': ${ride['Time']}' ,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    color: Colors.red,
                  ),
                ),
                Text(
                  'Number of Seats: ${ride['Number of Seats']}',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Color(0xFF0000FF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Price: ${ride['Price']}',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Color(0xFF00FF00),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.shopping_cart_rounded, size: 50, color: Color(0xFF000000),),
              onPressed: ()  async {
                if (timeConstraint)
                {
                  // Get the current time
                  DateTime currentTime = DateTime.now();
                  try {
                    // Parse date and time separately
                    DateTime rideDate = DateTime.parse(ride['Date']);
                    DateTime rideTime = DateFormat('h:mm a').parse(ride['Time']);
                    // Combine date and time
                    DateTime rideDateTime = DateTime(rideDate.year, rideDate.month, rideDate.day, rideTime.hour, rideTime.minute);
                    print('Parsed Ride DateTime: $rideDateTime');

                    DateTime startTimeConstraint;
                    DateTime endTimeConstraint;

                    if (ride['Time'] == "7:30 AM") {
                      startTimeConstraint = DateTime(rideDateTime.year, rideDateTime.month, rideDateTime.day - 1);
                      endTimeConstraint = DateTime(rideDateTime.year, rideDateTime.month, rideDateTime.day - 1, 22, 0);

                    }
                    else if (ride['Time'] == "5:30 PM") {
                      startTimeConstraint = DateTime(rideDateTime.year, rideDateTime.month, rideDateTime.day);
                      endTimeConstraint = DateTime(rideDateTime.year, rideDateTime.month, rideDateTime.day, 13,0);
                    }
                    else {
                      // Handle other cases if needed
                      return _showErrorDialog(context, "Exit Code -1");
                    }

                    // Check if the current time is within the specified constraints
                    if (currentTime.isAfter(startTimeConstraint) && currentTime.isBefore(endTimeConstraint)) {

                      String? userID = FirebaseAuth.instance.currentUser?.uid;
                      String? userEmail = FirebaseAuth.instance.currentUser?.email;

                      print('Selected Ride: $ride');
                      print('User ID: $userID');

                      // Save selected order to Firestore
                      if (userID != null) {
                        // Generate a unique ride_id using uuid
                        String rideID = Uuid().v4();

                        // Check if the generated ride_id is unique in the 'ride_requests' collection
                        bool isRideIDUnique = await isUniqueID('ride_requests', rideID);

                        if (!isRideIDUnique) {
                          // If not unique, generate a new ride_id until a unique one is found
                          while (!isRideIDUnique) {
                            rideID = Uuid().v4();
                            isRideIDUnique = await isUniqueID('ride_requests', rideID);
                          }
                        }

                        // Add a document to the 'ride_requests' collection with the unique ride_id
                        await FirebaseFirestore.instance.collection('ride_requests')
                            .doc(rideID)
                            .set({
                          'user_id': userID,
                          'user_email': userEmail,
                          'status': 'pending',
                          'driver_id': ride['Driver_ID'],
                          'Source': ride['Source'],
                          'Destination': ride['Destination'],
                          'ride_id': rideID,
                          'RideIDForRides': ride['RideIDForRides'],
                          'Time' : ride['Time'],

                        });

                        // Add a document to the 'users' collection with the same unique ride_id
                        await FirebaseFirestore.instance.collection('users')
                            .doc(userID)
                            .collection('orders')
                            .add({
                          'Source': ride['Source'],
                          'Destination': ride['Destination'],
                          'Driver_Email': ride['Driver_Email'],
                          'Time': ride['Time'],
                          'Number of Seats': ride['Number of Seats'],
                          'Price': ride['Price'],
                          'Driver_ID': ride['Driver_ID'],
                          'ride_id': rideID, // Use the same ride_id
                          'User_ID': userID,
                          'status': 'Pending',
                        });
                      }
                      _showSuccessDialog(context, "A Request is Sent to the Driver");
                      setState(() {
                        ridesData.removeAt(index);
                      });

                    } else {
                      // Display a message to the user indicating that the ride cannot be selected
                      _showErrorDialog(context, "You can only send a request during the specified time.");
                    }
                  } catch (e) {
                    print('Error parsing ride date and time: $e');
                    return;
                  }
                }
                if(!timeConstraint)
                {
                  String? userID = FirebaseAuth.instance.currentUser?.uid;
                  String? userEmail = FirebaseAuth.instance.currentUser?.email;

                  print('Selected Ride: $ride');
                  print('User ID: $userID');

                  // Save selected order to Firestore
                  if (userID != null) {
                    // Generate a unique ride_id using uuid
                    String rideID = Uuid().v4();

                    // Check if the generated ride_id is unique in the 'ride_requests' collection
                    bool isRideIDUnique = await isUniqueID('ride_requests', rideID);

                    if (!isRideIDUnique) {
                      // If not unique, generate a new ride_id until a unique one is found
                      while (!isRideIDUnique) {
                        rideID = Uuid().v4();
                        isRideIDUnique = await isUniqueID('ride_requests', rideID);
                      }
                    }

                    // Add a document to the 'ride_requests' collection with the unique ride_id
                    await FirebaseFirestore.instance.collection('ride_requests').doc(rideID).set({
                      'user_id': userID,
                      'user_email': userEmail,
                      'status': 'pending',
                      'driver_id' : ride['Driver_ID'],
                      'Source' : ride['Source'],
                      'Destination' : ride['Destination'],
                      'ride_id': rideID,
                      'RideIDForRides' : ride['RideIDForRides'],
                      'Time' :  ride['Time'],
                    });

                    // Add a document to the 'users' collection with the same unique ride_id
                    await FirebaseFirestore.instance.collection('users').doc(userID).collection('orders').add({
                      'Source': ride['Source'],
                      'Destination': ride['Destination'],
                      'Driver_Email': ride['Driver_Email'],
                      'Time': ride['Time'],
                      'Number of Seats': ride['Number of Seats'],
                      'Price': ride['Price'],
                      'Driver_ID': ride['Driver_ID'],
                      'ride_id': rideID, // Use the same ride_id
                      'User_ID': userID,
                      'status' : 'Pending',
                    });
                  }
                  _showSuccessDialog(context, "A Request is Sent to the Driver");
                  // Remove the selected ride from the list
                  setState(() {
                    ridesData.removeAt(index);
                  });
                }
              },

            ),
            onTap: () async {

              if (timeConstraint)
              {
              // Get the current time
              DateTime currentTime = DateTime.now();
              try {
                // Parse date and time separately
                DateTime rideDate = DateTime.parse(ride['Date']);
                DateTime rideTime = DateFormat('h:mm a').parse(ride['Time']);
                // Combine date and time
                DateTime rideDateTime = DateTime(rideDate.year, rideDate.month, rideDate.day, rideTime.hour, rideTime.minute);
                print('Parsed Ride DateTime: $rideDateTime');

                DateTime startTimeConstraint;
                DateTime endTimeConstraint;

                if (ride['Time'] == "7:30 AM") {
                  startTimeConstraint = DateTime(rideDateTime.year, rideDateTime.month, rideDateTime.day - 1);
                  endTimeConstraint = DateTime(rideDateTime.year, rideDateTime.month, rideDateTime.day - 1, 22, 0);

                }
                else if (ride['Time'] == "5:30 PM") {
                  startTimeConstraint = DateTime(rideDateTime.year, rideDateTime.month, rideDateTime.day);
                  endTimeConstraint = DateTime(rideDateTime.year, rideDateTime.month, rideDateTime.day, 13,0);
                }
                else {
                  // Handle other cases if needed
                  return _showErrorDialog(context, "Exit Code -1");
                }

                // Check if the current time is within the specified constraints
                if (currentTime.isAfter(startTimeConstraint) && currentTime.isBefore(endTimeConstraint)) {

              String? userID = FirebaseAuth.instance.currentUser?.uid;
              String? userEmail = FirebaseAuth.instance.currentUser?.email;

              print('Selected Ride: $ride');
              print('User ID: $userID');

              // Save selected order to Firestore
              if (userID != null) {
                // Generate a unique ride_id using uuid
                String rideID = Uuid().v4();

                // Check if the generated ride_id is unique in the 'ride_requests' collection
                bool isRideIDUnique = await isUniqueID('ride_requests', rideID);

                if (!isRideIDUnique) {
                  // If not unique, generate a new ride_id until a unique one is found
                  while (!isRideIDUnique) {
                    rideID = Uuid().v4();
                    isRideIDUnique = await isUniqueID('ride_requests', rideID);
                  }
                }

                // Add a document to the 'ride_requests' collection with the unique ride_id
                await FirebaseFirestore.instance.collection('ride_requests')
                    .doc(rideID)
                    .set({
                  'user_id': userID,
                  'user_email': userEmail,
                  'status': 'pending',
                  'driver_id': ride['Driver_ID'],
                  'Source': ride['Source'],
                  'Destination': ride['Destination'],
                  'ride_id': rideID,
                  'RideIDForRides': ride['RideIDForRides'],
                  'Time' :  ride['Time'],

                });

                // Add a document to the 'users' collection with the same unique ride_id
                await FirebaseFirestore.instance.collection('users')
                    .doc(userID)
                    .collection('orders')
                    .add({
                  'Source': ride['Source'],
                  'Destination': ride['Destination'],
                  'Driver_Email': ride['Driver_Email'],
                  'Time': ride['Time'],
                  'Number of Seats': ride['Number of Seats'],
                  'Price': ride['Price'],
                  'Driver_ID': ride['Driver_ID'],
                  'ride_id': rideID, // Use the same ride_id
                  'User_ID': userID,
                  'status': 'Pending',
                });
              }
                  _showSuccessDialog(context, "A Request is Sent to the Driver");
                  setState(() {
                    ridesData.removeAt(index);
                  });

                } else {
                  // Display a message to the user indicating that the ride cannot be selected
                  _showErrorDialog(context, "You can only send a request during the specified time.");
                }
              } catch (e) {
                print('Error parsing ride date and time: $e');
                return;
              }
              }
              if(!timeConstraint)
                {
                String? userID = FirebaseAuth.instance.currentUser?.uid;
                String? userEmail = FirebaseAuth.instance.currentUser?.email;

                print('Selected Ride: $ride');
                print('User ID: $userID');

                // Save selected order to Firestore
                if (userID != null) {
                // Generate a unique ride_id using uuid
                String rideID = Uuid().v4();

                // Check if the generated ride_id is unique in the 'ride_requests' collection
                bool isRideIDUnique = await isUniqueID('ride_requests', rideID);

                if (!isRideIDUnique) {
                // If not unique, generate a new ride_id until a unique one is found
                while (!isRideIDUnique) {
                rideID = Uuid().v4();
                isRideIDUnique = await isUniqueID('ride_requests', rideID);
                }
                }

                // Add a document to the 'ride_requests' collection with the unique ride_id
                await FirebaseFirestore.instance.collection('ride_requests').doc(rideID).set({
                'user_id': userID,
                'user_email': userEmail,
                'status': 'pending',
                'driver_id' : ride['Driver_ID'],
                'Source' : ride['Source'],
                'Destination' : ride['Destination'],
                'ride_id': rideID,
                'RideIDForRides' : ride['RideIDForRides'],
                  'Time' : ride['Time'],

                });

                // Add a document to the 'users' collection with the same unique ride_id
                await FirebaseFirestore.instance.collection('users').doc(userID).collection('orders').add({
                'Source': ride['Source'],
                'Destination': ride['Destination'],
                'Driver_Email': ride['Driver_Email'],
                'Time': ride['Time'],
                'Number of Seats': ride['Number of Seats'],
                'Price': ride['Price'],
                'Driver_ID': ride['Driver_ID'],
                'ride_id': rideID, // Use the same ride_id
                'User_ID': userID,
                'status' : 'Pending',
                });
                }
                _showSuccessDialog(context, "A Request is Sent to the Driver");
                // Remove the selected ride from the list
                setState(() {
                ridesData.removeAt(index);
                });
                }
            },

          ),
        );
      },
    );
  }


  void showSortDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(color: Colors.black, width: 3),
          ),
          backgroundColor: Color(0xF7bbaeee),
          title: Text(
            'Sort By',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF000000),
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  title: Text(
                    'Price',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF90EE90),
                    ),
                  ),
                  onTap: () {
                    sortRidesBy('Price');
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: Text(
                    'Number of Seats',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF0000FF),
                    ),
                  ),
                  onTap: () {
                    sortRidesBy('Number of Seats');
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void sortRidesBy(String sortBy) {
    setState(() {
      ridesData.sort((a, b) {
        if (sortBy == 'Price') {
          return a['Price'].compareTo(b['Price']);
        } else if (sortBy == 'Number of Seats') {
          return a['Number of Seats'].compareTo(b['Number of Seats']);
        }
        return 0;
      });
    });
  }

  void showSearchBar() async {
    final result = await showSearch(
      context: context,
      delegate: CustomSearchDelegate(ridesData),
    );
    if (result != null) {
      setState(() {
        filteredRidesData = result;
      });
    }
  }
}

class CustomSearchDelegate extends SearchDelegate<List<Map<String, dynamic>>> {
  final List<Map<String, dynamic>> data;

  CustomSearchDelegate(this.data);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      primaryColor: Color(0xFFbbaeee),
      scaffoldBackgroundColor: Color(0xFFbbaeee),
      textTheme: TextTheme(
        headline6: TextStyle(
          color: Color(0xFF000000),
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFFbbaeee), // Set the background color of the search bar
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white), // Color of the hint text
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFbbaeee)), // Color of the focused border
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white), // Color of the enabled border
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          showResults(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pushNamed(context, "/rides");
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildSearchResults();
  }

  Widget buildSearchResults() {
    final filteredData = data.where((ride) {
      final source = ride['Source'].toString().toLowerCase();
      final destination = ride['Destination'].toString().toLowerCase();
      final queryLower = query.toLowerCase();
      return source.contains(queryLower) || destination.contains(queryLower);
    }).toList();

    return ListView.builder(
      itemCount: filteredData.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            'Source: ${filteredData[index]['Source']}, Destination: ${filteredData[index]['Destination']}',
          ),
          onTap: () {
            close(context, filteredData);
          },
        );
      },
    );
  }
}

// Function to check if the generated ID is unique in a specific collection
Future<bool> isUniqueID(String collection, String id) async {
  try {
    // Query Firestore to check if the ID exists in the specified collection
    var snapshot = await FirebaseFirestore.instance.collection(collection).doc(id).get();

    // Return true if the document doesn't exist (ID is unique)
    return !snapshot.exists;
  } catch (e) {
    // Handle errors
    print('Error checking unique ID: $e');
    return false;
  }
}

void _showSuccessDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(color: Colors.black, width: 3),
        ),
        backgroundColor: Color(0xF7bbaeee),
        title: Center(
          child: Text(
            '$message',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF0FFF50),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Close the dialog
              Navigator.pushReplacementNamed(context, '/payment');
            },
            child: Center(
              child: Text(
                'OK',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF0FFF50),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
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
