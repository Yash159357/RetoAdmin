import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:reto_admin/views/side_bar_screens/inner_screens/order_detail_dialog.dart';

class OrderListWidget extends StatefulWidget {
  const OrderListWidget({super.key});

  @override
  State<OrderListWidget> createState() => _OrderListWidgetState();
}

class _OrderListWidgetState extends State<OrderListWidget> {
  String searchQuery = '';
  String searchField = 'orderId';
  List<QueryDocumentSnapshot> filteredOrders = [];

  final Color primaryThemeColor = const Color.fromARGB(255, 255, 246, 233);
  final Color accentThemeColor = const Color.fromARGB(210, 248, 186, 94);

  final searchFields = ['orderId', 'customerId', 'productId', 'category'];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Processing':
        return Colors.amber;
      case 'Delivered':
        return Colors.green;
      case 'Canceled':
        return Colors.red;
      default: // Placed
        return Colors.blue;
    }
  }

  String _getCurrentStatus(DocumentSnapshot orderData) {
    if (orderData['delivered'] == true) {
      return 'Delivered';
    } else if (orderData['processing'] == true) {
      return 'Processing';
    } else if (orderData['delivered'] == false &&
        orderData['processing'] == false) {
      return 'Placed';
    } else {
      return 'Placed';
    }
  }

  Future<void> _deleteOrder(String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .delete();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _viewOrderDetails(DocumentSnapshot orderData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailDialog(orderData: orderData),
      ),
    );
  }

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
    final Stream<QuerySnapshot> _ordersStream =
        FirebaseFirestore.instance.collection('orders').snapshots();

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
                    hintText: 'Search orders...',
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
              DropdownButton<String>(
                value: searchField,
                items:
                    searchFields.map((String field) {
                      return DropdownMenuItem<String>(
                        value: field,
                        child: Text(field),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      searchField = newValue;
                    });
                  }
                },
                hint: const Text('Search by'),
                style: TextStyle(color: Colors.black87),
                dropdownColor: primaryThemeColor,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Orders List
        StreamBuilder<QuerySnapshot>(
          stream: _ordersStream,
          builder: (
            BuildContext context,
            AsyncSnapshot<QuerySnapshot> snapshot,
          ) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LinearProgressIndicator();
            }

            // Filter orders based on search
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
                final orderData = filteredDocs[index];
                final currentStatus = _getCurrentStatus(orderData);
                final orderId = orderData.id;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // Order ID Column
                      orderDisplayData(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Order ID',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              orderData['orderId'] ?? 'N/A',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        1,
                      ),

                      // Product Image
                      orderDisplayData(
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              orderData['productImage'] ?? '',
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    color: Colors.grey.shade300,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                    ),
                                  ),
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      accentThemeColor,
                                    ),
                                    strokeWidth: 2.0,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        1,
                      ),

                      // Product Name
                      orderDisplayData(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Product',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              orderData['productName'] ?? 'N/A',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
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
                              'Customer',
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
                              '${orderData['locality'] ?? ''} ${orderData['city'] ?? ''} ${orderData['state'] ?? ''} ${orderData['pinCode'] ?? ''}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        2,
                      ),

                      // Status Dropdown
                      orderDisplayData(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Status',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            DropdownButton<String>(
                              value: currentStatus,
                              icon: const Icon(Icons.arrow_drop_down),
                              elevation: 16,
                              style: TextStyle(
                                color: _getStatusColor(currentStatus),
                                fontWeight: FontWeight.bold,
                              ),
                              underline: Container(
                                height: 2,
                                color: _getStatusColor(currentStatus),
                              ),
                              onChanged: (String? newValue) async {
                                if (newValue != null &&
                                    newValue != currentStatus) {
                                  setState(() {
                                    if (newValue == 'Delivered') {
                                      orderData.reference.update({
                                        'delivered': true,
                                        'processing': false,
                                      });
                                    } else if (newValue == 'Processing') {
                                      orderData.reference.update({
                                        'processing': true,
                                        'delivered': false,
                                      });
                                    } else if (newValue == 'Placed') {
                                      orderData.reference.update({
                                        'processing': false,
                                        'delivered': false,
                                      });
                                    } else if (newValue == 'Canceled') {
                                      orderData.reference.update({
                                        'processing': false,
                                        'delivered': false,
                                      });
                                    }
                                  });
                                }
                              },
                              items:
                                  <String>[
                                    'Placed',
                                    'Processing',
                                    'Delivered',
                                    'Canceled',
                                  ].map<DropdownMenuItem<String>>((
                                    String value,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                          color: _getStatusColor(value),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ],
                        ),
                        1,
                      ),

                      // Action Buttons (View & Delete)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          children: [
                            // View Button - Added similar to customers screen
                            IconButton(
                              icon: Icon(
                                Icons.visibility, 
                                color: accentThemeColor,
                              ),
                              tooltip: 'View Order Details',
                              onPressed: () => _viewOrderDetails(orderData),
                            ),
                            
                            // Delete Button
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              tooltip: 'Delete Order',
                              onPressed: () {
                                // Show confirmation dialog before deleting
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: primaryThemeColor,
                                    title: const Text('Delete Order'),
                                    content: const Text(
                                      'Are you sure you want to delete this order? This action cannot be undone.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(color: Colors.grey.shade700),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _deleteOrder(orderId);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
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
        ),
      ],
    );
  }
}