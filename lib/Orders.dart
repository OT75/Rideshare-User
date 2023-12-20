import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart';
class OrdersPage extends StatefulWidget {
  // Add this constructor to receive the selected ride data
  const OrdersPage({Key? key, this.selectedRide}) : super(key: key);

  // Property to hold the selected ride data
  final Map<String, dynamic>? selectedRide;

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<Map<String, dynamic>> selectedOrders = [];

  @override
  void initState() {
    super.initState();
    // Add the selected ride to the list of selected orders if available
    if (widget.selectedRide != null) {
      selectedOrders.add({
        'Source': widget.selectedRide!['Source'],
        'Destination': widget.selectedRide!['Destination'],
        'Driver_Email': widget.selectedRide!['Driver_Email'],
        'Time': widget.selectedRide!['Time'],
        'Number of Seats': widget.selectedRide!['Number of Seats'],
        'Price': widget.selectedRide!['Price'],
        'Status': 'Pending', // Added status field with 'Pending'
      });

    }

    // Fetch orders from Firestore for the current user
    fetchUserOrders();

  }

  void fetchUserOrders() async {
    // Get the current user ID
    String? userID = FirebaseAuth.instance.currentUser?.uid;
    // Check if the user is signed in
    if (userID != null) {
      // Query Firestore to get orders for the current user
      FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('orders')
          .get()
          .then((querySnapshot) async {
        // Clear the existing orders in selectedOrders
        selectedOrders.clear();

        // Iterate through the documents and add orders to the selectedOrders list
        for (QueryDocumentSnapshot doc in querySnapshot.docs) {
          Map<String, dynamic> orderData = doc.data() as Map<String, dynamic>;
          String rideID = orderData['ride_id']; // Get the ride_id from the order

          // Check if the order's ride_id matches any request's driver_id
          if (await isRideRequested(rideID)) {
            // Update the status of the order to 'approved' or 'cancelled'
            String? requestStatus = await getRequestStatus(rideID);
            String orderStatus = (requestStatus == 'approved') ? 'approved' : 'cancelled';

            // Add the order with the updated status to selectedOrders
            selectedOrders.add({
              ...orderData,
              'Status': orderStatus,
            });
          } else {
            // If the ride is not requested, add the order as is
            selectedOrders.add({
              ...orderData,
              'Status': 'Pending',
            });
          }
        }

        // Refresh the UI to reflect changes
        setState(() {});
      });
    }
  }

  Future<bool> isRideRequested(String driverID) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('ride_requests')
          .where('driver_id', isEqualTo: driverID)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if ride is requested: $e');
      return false;
    }
  }

// Function to get the status of a requested ride
  Future<String?> getRequestStatus(String rideID) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('ride_requests')
          .where('ride_id', isEqualTo: rideID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['status'];
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting request status: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF000000),
        title: Center(
          child: Text(
            'My Orders',
            style: TextStyle(
              color: Color(0xFFbbaeee),
            ),
          ),
        ),
      ),
      backgroundColor: Color(0xFFbbaeee),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Selected Orders',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(
                thickness: 2.0,
                color: Colors.black,
              ),
              // Display selected orders using ListView.builder
              Expanded(
                child: ListView.builder(
                  itemCount: selectedOrders.length,
                  itemBuilder: (context, index) {
                    return buildOrderCard(selectedOrders[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOrderCard(Map<String, dynamic> order) {
    String driverEmail = (order['Driver_Email'] ?? '').replaceAll('@driver.com', '');
    int x = 0xFF808080;
    if (order['status'] == 'Approved')
      {
        x = 0xFF00FF00;
      }
    else if (order['status'] == 'Cancelled')
    {
      x = 0xFFFF0000;
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Source: ${order['Source']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22.0,
                ),
              ),
              Text(
                'Destination: ${order['Destination']}',
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
                'Time: ${order['Time']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Colors.red,
                ),
              ),
              Text(
                'Number of Seats: ${order['Number of Seats']}',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Color(0xFF0000FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Price: ${order['Price']}',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Color(0xFF00FF00),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                 "________________________________________" + "\n" +
                     'Status: ${order['status']}', // Displaying status
                style: TextStyle(
                  fontSize: 18.0,
                  color: Color(x), // You can customize the color
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}