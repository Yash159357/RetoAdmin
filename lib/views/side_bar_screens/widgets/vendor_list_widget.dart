import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:reto_admin/views/side_bar_screens/inner_screens/vendor_detail_dialog.dart';

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
  
  // Map to store vendor earnings
  Map<String, double> vendorEarnings = {};
  bool isLoadingEarnings = true;
  
  // Map to track password visibility state for each vendor
  Map<String, bool> passwordVisibility = {};

  @override
  void initState() {
    super.initState();
    _loadVendorEarnings();
  }

  Future<void> _loadVendorEarnings() async {
    setState(() {
      isLoadingEarnings = true;
    });

    try {
      // Get all orders from Firestore
      final QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .get();

      // Create a map to accumulate earnings per vendor
      final Map<String, double> earningsMap = {};

      // Process each order
      for (final doc in ordersSnapshot.docs) {
        final orderData = doc.data() as Map<String, dynamic>;
        final vendorId = orderData['vendorId'] as String?;
        final price = (orderData['price'] as num?)?.toDouble() ?? 0.0;

        if (vendorId != null && vendorId.isNotEmpty) {
          // Add to vendor's total earnings
          earningsMap[vendorId] = (earningsMap[vendorId] ?? 0.0) + price;
        }
      }

      // Update state with new earnings data
      setState(() {
        vendorEarnings = earningsMap;
        isLoadingEarnings = false;
      });
    } catch (e) {
      print('Error loading vendor earnings: $e');
      setState(() {
        isLoadingEarnings = false;
      });
      
      // Show error message if in debug mode
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error loading vendor earnings'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Toggle password visibility for a specific vendor
  void _togglePasswordVisibility(String vendorId) {
    setState(() {
      passwordVisibility[vendorId] = !(passwordVisibility[vendorId] ?? false);
    });
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

  void _deleteVendor(String vendorId) async {
    try {
      // Show confirmation dialog
      bool confirm = await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              backgroundColor: primaryThemeColor,
              title: const Text('Delete Vendor'),
              content: const Text(
                'Are you sure you want to delete this vendor?',
              ),
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
            .collection('vendors')
            .doc(vendorId)
            .delete();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Vendor deleted successfully'),
            backgroundColor: accentThemeColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting vendor: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _viewVendorDetails(
    BuildContext context,
    Map<String, dynamic> vendorData,
  ) {
    showDialog(
      context: context,
      builder: (context) => VendorDetailDialog(vendorData: vendorData),
    );
  }

  void _refreshEarnings() {
    _loadVendorEarnings();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Refreshing vendor earnings...'),
        backgroundColor: accentThemeColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> vendorsStream =
        FirebaseFirestore.instance.collection('vendors').snapshots();

    return Column(
      children: [
        // Search Bar Section with Refresh Button
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
              // Add refresh button
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: accentThemeColor,
                ),
                onPressed: _refreshEarnings,
                tooltip: 'Refresh Earnings',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        //Row Header
        Row(
          children: [
            rowHeader(1, 'Vendor ID'),
            rowHeader(1, 'Name'),
            rowHeader(3, 'Address'),
            rowHeader(2, 'Email'),
            rowHeader(1, 'Phone Number'),
            rowHeader(1, 'Password'),  // Added Password header
            rowHeader(1, 'Earnings'),
            rowHeader(1, 'Actions'),
          ],
        ),

        const SizedBox(height: 16),

        isLoadingEarnings
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            : StreamBuilder<QuerySnapshot>(
                stream: vendorsStream,
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
                      child: const Text('No vendors match your search criteria.'),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final vendorData =
                          filteredDocs[index].data() as Map<String, dynamic>;
                      final vendorId = filteredDocs[index].id;

                      // Get the vendor's earnings from our pre-loaded map
                      final earnings = vendorEarnings[vendorId] ?? 0.0;
                      
                      // Check if password is visible for this vendor
                      final isPasswordVisible = passwordVisibility[vendorId] ?? false;
                      
                      // Get the password from vendor data
                      final password = vendorData['password'] ?? '********';

                      // Add the document ID to the vendor data if not already there
                      if (vendorData['uid'] == null) {
                        vendorData['uid'] = vendorId;
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            // Vendor ID Column
                            orderDisplayData(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Vendor ID',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    vendorData['uid'] ?? 'N/A',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              1,
                            ),

                            // Vendor Name
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
                                    vendorData['name'] ?? 'N/A',
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
                                    '${vendorData['locality'] ?? ''} ${vendorData['city'] ?? ''} ${vendorData['state'] ?? ''} ${vendorData['pinCode'] ?? ''}',
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
                                    vendorData['email'] ?? 'N/A',
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
                                    vendorData['number'] ?? 'N/A',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              1,
                            ),
                            
                            // Password Field - NEW
                            orderDisplayData(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Password',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          isPasswordVisible ? password : '••••••••',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: isPasswordVisible ? null : 'monospace',
                                            letterSpacing: isPasswordVisible ? null : 1.0,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => _togglePasswordVisibility(vendorId),
                                        child: Icon(
                                          isPasswordVisible 
                                              ? Icons.visibility_off 
                                              : Icons.visibility,
                                          size: 18,
                                          color: accentThemeColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              1,
                            ),
                            
                            // Earnings
                            orderDisplayData(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Earnings',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    '₹${earnings.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green,
                                    ),
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
                                    icon: Icon(
                                      Icons.visibility,
                                      color: accentThemeColor,
                                    ),
                                    onPressed:
                                        () => _viewVendorDetails(context, vendorData),
                                    tooltip: 'View Vendor',
                                  ),
                                  // Delete Button
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.redAccent),
                                    onPressed: () => _deleteVendor(vendorId),
                                    tooltip: 'Delete Vendor',
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