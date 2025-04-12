import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VendorListWidget extends StatefulWidget {
  const VendorListWidget({super.key});

  @override
  State<VendorListWidget> createState() => _VendorListWidgetState();
}

class _VendorListWidgetState extends State<VendorListWidget> {
  String searchQuery = '';
  String searchField = 'name';

  final Color primaryThemeColor = const Color.fromARGB(255, 255, 246, 233);
  final Color accentThemeColor = const Color.fromARGB(210, 248, 186, 94);

  Widget orderDisplayData(Widget widget, int? flex) {
    return Expanded(
      flex: flex!,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          decoration: BoxDecoration(
            color: primaryThemeColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Padding(padding: const EdgeInsets.all(8.0), child: widget),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> customersStream =
        FirebaseFirestore.instance.collection('vendors').snapshots();

    return Column(
      children: [
        // Search Bar Section
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: primaryThemeColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search vendor by name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: accentThemeColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: accentThemeColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: accentThemeColor, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),

        const SizedBox(height: 16),

        StreamBuilder<QuerySnapshot>(
          stream: customersStream,
          builder: (
            BuildContext context,
            AsyncSnapshot<QuerySnapshot> snapshot,
          ) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            List<QueryDocumentSnapshot> filteredDocs = snapshot.data!.docs;

            if (searchQuery.isNotEmpty) {
              filteredDocs =
                  filteredDocs.where((doc) {
                    if (!doc.data().toString().contains(searchField)) {
                      return false;
                    }

                    var fieldValue =
                        doc[searchField]?.toString().toLowerCase() ?? '';
                    return fieldValue.contains(searchQuery.toLowerCase());
                  }).toList();
            }

            if (filteredDocs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: const Text('No orders match your search criteria.'),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredDocs.length,
              itemBuilder: (context, index) {
                final customer = snapshot.data!.docs[index];
                final orderData = filteredDocs[index];

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // Customer ID Column
                      orderDisplayData(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Vender ID',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              orderData['uid'] ?? 'N/A',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        1,
                      ),

                      // Customer Name
                      orderDisplayData(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              orderData['name'] ?? 'N/A',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        1,
                      ),

                      // Address
                      orderDisplayData(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Address',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${orderData['locality']} ${orderData['city']} ${orderData['state']} ${orderData['pinCode']}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        3,
                      ),

                      // Email
                      orderDisplayData(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Email',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              orderData['email'] ?? 'N/A',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        2,
                      ),

                      // Number
                      orderDisplayData(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Number',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              orderData['number'] ?? 'N/A',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        1,
                      ),
                    ],
                  ),
                );
              },
            );

            // return ListView.builder(
            //   shrinkWrap: true,
            //   itemCount: snapshot.data!.docs.length,

            //   itemBuilder: (context, index) {
            //     final customer = snapshot.data!.docs[index];
            //     return Row(
            //       children: [
            //         VendorData(
            //           SizedBox(
            //             height: 50,
            //             width: 50,
            //             child: Icon(
            //               Icons.person_rounded,
            //               color: Colors.orange,
            //             ), //No Customer Image Upload Option so for now this Icon will be displayed.
            //           ),
            //           1,
            //         ),

            //         VendorData(Text(customer['name']), 1),

            //         VendorData(
            //           Text(
            //             '${customer['locality']} ${customer['city']} ${customer['state']} ${customer['pinCode']}',
            //           ),
            //           3,
            //         ),

            //         VendorData(Text(customer['email']), 2),

            //         VendorData(Text(customer['number']), 1),
            //       ],
            //     );
            //   },
            // );
          },
        ),
      ],
    );
  }
}
