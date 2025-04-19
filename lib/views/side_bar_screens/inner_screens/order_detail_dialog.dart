import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailDialog extends StatelessWidget {
  final DocumentSnapshot orderData;
  
  const OrderDetailDialog({
    super.key,
    required this.orderData,
  });

  // Theme colors
  final Color primaryThemeColor = const Color.fromARGB(255, 255, 246, 233);
  final Color accentThemeColor = const Color.fromARGB(210, 248, 186, 94);

  String _getCurrentStatus(DocumentSnapshot orderData) {
    if (orderData['delivered'] == true) {
      return 'Delivered';
    } else if (orderData['processing'] == true) {
      return 'Processing';
    } else if (orderData['delivered'] == false &&
        orderData['processing'] == false) {
      return 'Placed';
    } else {
      return 'Canceled';
    }
  }

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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStatus = _getCurrentStatus(orderData);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryThemeColor,
        title: const Text(
          'Order Details',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Close button instead of edit
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order header with order ID
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryThemeColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order ID: ${orderData['orderId'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(currentStatus),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            currentStatus,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Product Details Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Product Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Product image and details side by side
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                orderData['productImage'] ?? '',
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 120,
                                  width: 120,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.image_not_supported, size: 40),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Product Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    orderData['productName'] ?? 'N/A',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Price: ₹${orderData['price'] ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Quantity: ${orderData['quantity'] ?? '1'}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (orderData['size'] != null && orderData['size'] != '')
                                    Text(
                                      'Size: ${orderData['size']}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Product ID: ${orderData['productId'] ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Customer Information
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Customer Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow('Name', orderData['name'] ?? 'N/A'),
                        _buildDetailRow('Email', orderData['email'] ?? 'N/A'),
                        _buildDetailRow('Phone', orderData['number'] ?? 'N/A'),
                        _buildDetailRow('Customer ID', orderData['customerId'] ?? 'N/A'),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Shipping Information
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Shipping Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow('Locality', orderData['locality'] ?? 'N/A'),
                        _buildDetailRow('City', orderData['city'] ?? 'N/A'),
                        _buildDetailRow('State', orderData['state'] ?? 'N/A'),
                        _buildDetailRow('Pin Code', orderData['pinCode'] ?? 'N/A'),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Order Status Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  color: primaryThemeColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Status',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Text(
                              'Current Status:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 16),
                            DropdownButton<String>(
                              value: currentStatus,
                              icon: const Icon(Icons.arrow_drop_down),
                              elevation: 16,
                              style: TextStyle(
                                color: _getStatusColor(currentStatus),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              underline: Container(
                                height: 2,
                                color: _getStatusColor(currentStatus),
                              ),
                              onChanged: (String? newValue) {
                                if (newValue != null && newValue != currentStatus) {
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
                                }
                              },
                              items: <String>[
                                'Placed',
                                'Processing',
                                'Delivered',
                                'Canceled',
                              ].map<DropdownMenuItem<String>>((String value) {
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
                        
                        // Add more order details
                        // const SizedBox(height: 16),
                        // _buildDetailRow('Order Date', orderData['orderDate']?.toString() ?? 'N/A'),
                        // if (orderData['deliveredCount'] != null)
                        //   _buildDetailRow('Delivered Count', orderData['deliveredCount'].toString()),
                        // if (orderData['vendorId'] != null)
                        //   _buildDetailRow('Vendor ID', orderData['vendorId']),
                        // if (orderData['category'] != null)
                        //   _buildDetailRow('Category', orderData['category']),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}