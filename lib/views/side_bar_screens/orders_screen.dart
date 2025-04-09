

import 'package:flutter/material.dart';
import 'package:reto_admin/views/side_bar_screens/widgets/order_list_widget.dart';

class OrdersScreen extends StatelessWidget {

  static const String id = 'orders-screen';

  const OrdersScreen({super.key});

  //Reuseable Header. We will be using this Header multiple times.
  Widget rowHeader(int flex, String text) {
    return Expanded(
        flex: flex,
        child: Container(
        decoration: BoxDecoration(
        color: Color(0xFF3C55EF),
        border: Border.all(
          color: Colors.white,
        ),
      ),


      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              alignment: Alignment.topLeft,
              child: Text('Manage Orders',
                style: const TextStyle(
                  // color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          Row(
            children: [
              rowHeader(1, 'Image'), //Using our Reuseable Header
              rowHeader(1, 'Product Name'),
              rowHeader(2, 'Customer Name'), //Number denotes how much space we want to allocate in the Header
              rowHeader(3, 'Address'),
              rowHeader(1, 'Action'),
              rowHeader(1, 'Reject'),
            ],
          ),

          OrderListWidget(), //Calling 'OrderListWidget' to show all our orders

        ],
      ),
    );
  }
}
