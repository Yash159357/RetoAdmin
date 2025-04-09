

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomerListWidget extends StatelessWidget {
  const CustomerListWidget({super.key});

  @override
  Widget build(BuildContext context) {

    final Stream<QuerySnapshot> customersStream = FirebaseFirestore.instance.collection('customers').snapshots();

    Widget CustomerData(Widget widget, int? flex) {
      return Expanded(
          flex: flex!,

          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              // color: Colors.grey,
            ),

            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: widget,
            ),

          )
      );
    }


    return StreamBuilder<QuerySnapshot>(
      stream: customersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.docs.length,
            
            itemBuilder: (context, index) {
              final customer = snapshot.data!.docs[index];
              return Row(
                children: [

                CustomerData(
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: Icon(Icons.person_rounded,color: Colors.orange,), //No Customer Image Upload Option so for now this Icon will be displayed.
                  ),
                  1),

                  CustomerData(Text(customer['name']), 1),

                  CustomerData(Text('${customer['locality']} ${customer['city']} ${customer['state']} ${customer['pinCode']}'), 3),

                  CustomerData(Text(customer['email']), 2),

                  CustomerData(Text(customer['number']), 1),


                ],
              );
            }
        );
      },
    );
  }
}
