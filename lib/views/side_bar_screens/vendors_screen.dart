

import 'package:flutter/material.dart';
import 'package:reto_admin/views/side_bar_screens/widgets/vendor_list_widget.dart';

class VendorsScreen extends StatelessWidget {

  static const String id = '\vendors-screen';

  const VendorsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    //Reuseable Header. We will be using this Header multiple times.
    Widget rowHeader(int flex, String text) {
      return Expanded(
          flex: flex,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade700),
              color: const Color(0xFF3C55EF),
            ),

            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  // fontWeight: FontWeight.bold,
                ),
              ),
            ),

          )
      );
    }

    return Scaffold(
      body: Padding(padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.topLeft,
              child: const Text('Manage Vendors',
                style: TextStyle(
                  // color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15,),

            //Row Header
            Row(
              children: [
                rowHeader(1, 'Image'),
                rowHeader(1, 'Full Name'),
                rowHeader(3, 'Address'),
                rowHeader(2, 'Email'),
                rowHeader(1, 'Phone Number'),
              ],
            ),

            const VendorListWidget(),

          ],
        ),
      ),
    );
  }
}
