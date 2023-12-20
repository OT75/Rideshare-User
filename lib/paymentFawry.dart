import 'package:flutter/material.dart';

class paymentFawry extends StatefulWidget {
  const paymentFawry({Key? key}) : super(key: key);

  @override
  _PaymentFawryState createState() => _PaymentFawryState();
}

class _PaymentFawryState extends State<paymentFawry> {
  String code = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF000000),
        title: Center(
          child: Text(
            'Fawry Payment',
            style: TextStyle(
              color: Color(0xFFbbaeee),
            ),
          ),
        ),
      ),
      backgroundColor: Color(0xFFbbaeee),
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                      labelText: 'Enter Fawry Code',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(10),
                    ),
                    onChanged: (value) {
                      setState(() {
                        code = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _fawryPayment(context);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      "Submit Code",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


void _fawryPayment(BuildContext context) {
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
            'Code Submitted Successfuly!',
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
