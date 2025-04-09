

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderListWidget extends StatelessWidget {
  const OrderListWidget({super.key});

  Widget orderDisplayData(Widget widget, int? flex) {
    return Expanded(
        flex: flex!,

        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.grey,
            ),

            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: widget,
            ),

          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {

    final Stream<QuerySnapshot> _ordersStream = FirebaseFirestore.instance.collection('orders').snapshots();
    
    return StreamBuilder<QuerySnapshot>(
      stream: _ordersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        }

        return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.size,
            
            itemBuilder: (context, index) {
              
              final orderData = snapshot.data!.docs[index];
              
              return Row(
                children: [
                  orderDisplayData(SizedBox(
                    width: 50,
                    height: 50,
                    
                    child: Image.network(orderData['productImage'],), //Displaying Product Image
                  ), 
                      1),  //This flex number must be equal to what we have mentioned in the Reuseable Row Header in 'order_screen' page.

                  orderDisplayData(Text(orderData['productName']), 1), //Displaying Product Name

                  orderDisplayData(Text(orderData['name']), 2), //Displaying Customer Name

                  orderDisplayData(Text('${orderData['locality']} ${orderData['city']} ${orderData['state']} ${orderData['pinCode']}'), 3), //Displaying Customer Address


                  //Mark Deliver Button
                  orderDisplayData(ElevatedButton(

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),

                    onPressed: () async{
                      await FirebaseFirestore.instance.collection('orders').doc(orderData['orderId']).update({
                        'delivered' : true,
                        'processing' : false,
                        'deliveredCount' : FieldValue.increment(1), //Incrementing Delivered Count
                      });
                    },

                    child: orderData['delivered'] == true ? const Text('Delivered') : const Text('Mark Delivered',), //If the order has been delivered change the text to 'Delivered' or else 'Mark Delivered'
                    ),
                      1),


                  //Cancel Button
                  orderDisplayData(ElevatedButton(

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),

                    onPressed: () async{
                      await FirebaseFirestore.instance.collection('orders').doc(orderData['orderId']).update({
                        'delivered' : false,
                        'processing' : false,
                      });
                    },

                    // child: Text('Cancel',),
                    child: orderData['delivered'] == false && orderData['processing'] == false  ? const Text('Cancelled') : const Text('Mark Cancel',),
                  ),
                      1),

                ],
              );
            }
        );
      },
    );
  }
}
