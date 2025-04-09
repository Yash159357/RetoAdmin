//Copied this entire section from 'category_list_widget' page and did the required changes

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


//This will retrieve our banners present in our Firebase and display them in our Admin Panel.


class BannerListWidget extends StatelessWidget {
  const BannerListWidget({super.key});

  @override
  Widget build(BuildContext context) {


    //Got this entire section from 'One-Time Read' doc in FlutterFire Website and then edited as per our needs.
    final Stream<QuerySnapshot> _bannerStream = FirebaseFirestore.instance.collection('banners').snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: _bannerStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(),);
        }

        //We already used this in our Main App when we were displaying Categories.
        return GridView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.docs.length, //Number of categories stored in our Firebase
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6, //This refers to the number of items we will display in a row.
                mainAxisSpacing: 8, crossAxisSpacing: 8),
            itemBuilder: (context, index) {
              final categoryData = snapshot.data!.docs[index]; //Using this variable we will access our category details in our Firebase.
              return Column(
                children: [

                  Image.network(
                    categoryData['image'], //Fetching and Displaying our Category Image from our Firebase.
                    height: 100, //Mentioning the height and width of every category image that we will display in our Admin Panel from our Firebase
                    width: 100,
                  ),


                ],
              );

            });
      },
    );




  }
}
