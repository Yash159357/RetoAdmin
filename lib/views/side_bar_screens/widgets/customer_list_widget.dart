import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:reto_admin/views/side_bar_screens/inner_screens/customer_detail_dialog.dart';

class CustomerListWidget extends StatefulWidget {
  final String searchQuery;
  
  const CustomerListWidget({
    super.key, 
    this.searchQuery = '',
  });

  @override
  State<CustomerListWidget> createState() => _CustomerListWidgetState();
}

class _CustomerListWidgetState extends State<CustomerListWidget> {
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

  void _deleteCustomer(String customerId) async {
    try {
      // Show confirmation dialog
      bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: primaryThemeColor,
          title: const Text('Delete Customer'),
          content: const Text('Are you sure you want to delete this customer?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: accentThemeColor),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentThemeColor,
              ),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await FirebaseFirestore.instance
            .collection('customers')
            .doc(customerId)
            .delete();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Customer deleted successfully'),
            backgroundColor: accentThemeColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting customer: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _viewCustomerDetails(BuildContext context, Map<String, dynamic> customerData) {
    showDialog(
      context: context,
      builder: (context) => CustomerDetailDialog(customerData: customerData),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> customersStream =
        FirebaseFirestore.instance.collection('customers').snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: customersStream,
      builder: (
        BuildContext context,
        AsyncSnapshot<QuerySnapshot> snapshot,
      ) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<QueryDocumentSnapshot> filteredDocs = snapshot.data!.docs;

        if (widget.searchQuery.isNotEmpty) {
          filteredDocs = filteredDocs.where((doc) {
            if (!doc.data().toString().contains(searchField)) {
              return false;
            }

            var fieldValue =
                doc[searchField]?.toString().toLowerCase() ?? '';
            return fieldValue.contains(widget.searchQuery.toLowerCase());
          }).toList();
        }

        if (filteredDocs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: const Text('No customers match your search criteria.'),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final customerData = filteredDocs[index].data() as Map<String, dynamic>;
            final customerId = filteredDocs[index].id;
            
            // Add the document ID to the customer data if not already there
            if (customerData['uid'] == null) {
              customerData['uid'] = customerId;
            }

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
                          'Customer ID',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          customerData['uid'] ?? 'N/A',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
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
                          customerData['name'] ?? 'N/A',
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
                          '${customerData['locality'] ?? ''} ${customerData['city'] ?? ''} ${customerData['state'] ?? ''} ${customerData['pinCode'] ?? ''}',
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
                          customerData['email'] ?? 'N/A',
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
                          customerData['number'] ?? 'N/A',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    1,
                  ),

                  // Action Buttons
                  Container(
                    width: 100,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // View Button
                        IconButton(
                          icon: Icon(Icons.visibility, color: accentThemeColor),
                          onPressed: () => _viewCustomerDetails(context, customerData),
                          tooltip: 'View Customer',
                        ),
                        // Delete Button
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteCustomer(customerId),
                          tooltip: 'Delete Customer',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}