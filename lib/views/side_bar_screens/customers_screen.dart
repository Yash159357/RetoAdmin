import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reto_admin/views/side_bar_screens/widgets/customer_list_widget.dart';

class CustomersScreen extends StatefulWidget {
  static const String id = '\customers-screen';

  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final Color primaryThemeColor = const Color.fromARGB(255, 255, 246, 233);
  final Color accentThemeColor = const Color.fromARGB(210, 248, 186, 94);
  String searchQuery = '';

  Widget rowHeader(int flex, String text) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: BoxDecoration(
          color: accentThemeColor,
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget summaryBox(String title, Stream<String> valueStream, IconData icon) {
    return Expanded(
      child: Container(
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: primaryThemeColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    icon,
                    color: accentThemeColor,
                    size: 28,
                  ),
                ],
              ),
              StreamBuilder<String>(
                stream: valueStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  
                  return Text(
                    snapshot.data ?? '0',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Stream that counts total customers
  Stream<String> get _customersCountStream {
    return FirebaseFirestore.instance.collection('customers').snapshots()
        .map((snapshot) => snapshot.size.toString());
  }

  // Stream that calculates total earnings from orders
  Stream<String> get _totalEarningsStream {
    return FirebaseFirestore.instance.collection('orders').snapshots()
        .asyncMap((snapshot) async {
          double totalEarnings = 0;
          for (var doc in snapshot.docs) {
            Map<String, dynamic> data = doc.data();
            if (data.containsKey('price') && data['price'] != null) {
              totalEarnings += (data['price'] is double) 
                  ? data['price'] 
                  : double.tryParse(data['price'].toString()) ?? 0;
            }
          }
          return '₹${totalEarnings.toStringAsFixed(2)}';
        });
  }

  // Stream that counts total orders
  Stream<String> get _ordersCountStream {
    return FirebaseFirestore.instance.collection('orders').snapshots()
        .map((snapshot) => snapshot.size.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: primaryThemeColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Manage Customers',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Summary Boxes
              Row(
                children: [
                  summaryBox('Total Customers', _customersCountStream, Icons.people),
                  summaryBox('Total Earnings', _totalEarningsStream, Icons.monetization_on),
                  summaryBox('Total Orders', _ordersCountStream, Icons.shopping_cart),
                ],
              ),

              const SizedBox(height: 24),

              // Search Bar Section - Now above column headers
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: primaryThemeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search customer by name',
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

              const SizedBox(height: 16),

              // Column Headers Section
              Row(
                children: [
                  rowHeader(1, 'Customer ID'),
                  rowHeader(1, 'Name'),
                  rowHeader(3, 'Address'),
                  rowHeader(2, 'Email'),
                  rowHeader(1, 'Phone Number'),
                ],
              ),

              const SizedBox(height: 16),

              // Customer List with search query passed
              CustomerListWidget(searchQuery: searchQuery),
            ],
          ),
        ),
      ),
    );
  }
}