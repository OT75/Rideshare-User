import 'package:flutter/material.dart';

class paymentCard extends StatefulWidget {
  const paymentCard({Key? key}) : super(key: key);

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<paymentCard> {
  String cardNumber = '';
  String cardHolderName = '';
  String expirationDate = '';
  String cvv = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF000000),
        title: Center(
          child: Text(
            'Card Payment',
            style: TextStyle(
              color: Color(0xFFbbaeee),
            ),
          ),
        ),
      ),
      backgroundColor: Color(0xFFbbaeee),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Credit Card Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: Colors.black,
                  width: 2.0,
                ),
              ),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(10),
                ),
                onChanged: (value) {
                  setState(() {
                    cardNumber = value;
                  });
                },
              ),
            ),
            SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: Colors.black,
                  width: 2.0,
                ),
              ),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Card Holder Name',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(10),
                ),
                onChanged: (value) {
                  setState(() {
                    cardHolderName = value;
                  });
                },
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: Colors.black,
                        width: 2.0,
                      ),
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Expiration Date',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(10),
                      ),
                      onChanged: (value) {
                        setState(() {
                          expirationDate = value;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: Colors.black,
                        width: 2.0,
                      ),
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(10),
                      ),
                      onChanged: (value) {
                        setState(() {
                          cvv = value;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Perform payment processing logic (dummy in this case)
                _performPayment();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.black, // Background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0), // Border radius
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Make Payment",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Text color
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _performPayment() {
    // Dummy payment processing logic
    // You can add your payment processing logic here
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
          title: Center(
            child: Text(
              'Payment Successful!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Color(0xFF0FFF50),
              ),
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              'Thank you for your Payment',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Center(
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

