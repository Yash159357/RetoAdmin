import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class CouponScreen extends StatefulWidget {
  static const String id = '\CouponScreen';

  const CouponScreen({super.key});

  @override
  State<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _couponNameController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  // Theme colors to match existing screens
  final Color primaryThemeColor = const Color.fromARGB(255, 255, 246, 233);
  final Color accentThemeColor = const Color.fromARGB(210, 248, 186, 94);

  @override
  void dispose() {
    _couponNameController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _saveCoupon() async {
    if (_formKey.currentState!.validate()) {
      try {
        EasyLoading.show(status: 'Saving...');
        
        // Generate a unique document ID for the coupon
        String docId = DateTime.now().millisecondsSinceEpoch.toString();
        
        // Parse discount value to double
        double discount = double.parse(_discountController.text);
        
        await _firestore
            .collection('coupons')
            .doc(docId)
            .set({
              'couponName': _couponNameController.text,
              'discount': discount,
              'createdAt': FieldValue.serverTimestamp(),
            })
            .whenComplete(() {
              EasyLoading.dismiss();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: accentThemeColor,
                  content: Text('Coupon added successfully!'),
                  duration: Duration(seconds: 2),
                ),
              );
              // Clear form fields
              _couponNameController.clear();
              _discountController.clear();
            });
      } catch (e) {
        EasyLoading.dismiss();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error adding coupon: ${e.toString()}'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _deleteCoupon(String couponId) async {
    try {
      // Show confirmation dialog
      bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: primaryThemeColor,
          title: const Text('Delete Coupon'),
          content: const Text('Are you sure you want to delete this coupon?'),
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
        EasyLoading.show(status: 'Deleting...');
        await _firestore.collection('coupons').doc(couponId).delete();
        EasyLoading.dismiss();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Coupon deleted successfully'),
            backgroundColor: accentThemeColor,
          ),
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting coupon: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildCouponList() {
    final Stream<QuerySnapshot> couponsStream =
        FirebaseFirestore.instance.collection('coupons').orderBy('createdAt', descending: true).snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: couponsStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            child: Text(
              'No coupons available.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final couponData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final couponId = snapshot.data!.docs[index].id;

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // Coupon ID
                  _dataColumn(
                    'Coupon ID',
                    couponId.substring(0, 8) + '...',
                    1,
                  ),

                  // Coupon Name
                  _dataColumn(
                    'Coupon Name',
                    couponData['couponName'] ?? 'N/A',
                    2,
                  ),

                  // Discount
                  _dataColumn(
                    'Discount',
                    '${couponData['discount'].toString()}%',
                    1,
                  ),

                  // Created At
                  _dataColumn(
                    'Created',
                    couponData['createdAt'] != null
                        ? _formatTimestamp(couponData['createdAt'])
                        : 'N/A',
                    2,
                  ),

                  // Delete Button
                  Container(
                    width: 70,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: IconButton(
                      icon: Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _deleteCoupon(couponId),
                      tooltip: 'Delete Coupon',
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

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  Widget _dataColumn(String label, String value, int flex) {
    return Expanded(
      flex: flex,
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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coupon Screen Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Coupons',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            Divider(color: Colors.grey.shade300, thickness: 1),

            // Coupon Creation Section
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                color: primaryThemeColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create New Coupon',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Coupon Name Field
                  TextFormField(
                    controller: _couponNameController,
                    decoration: InputDecoration(
                      labelText: 'Coupon Name',
                      hintText: 'e.g. WELCOME20',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: accentThemeColor, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a coupon name';
                      }
                      return null;
                    },
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Discount Field
                  TextFormField(
                    controller: _discountController,
                    decoration: InputDecoration(
                      labelText: 'Discount (%)',
                      hintText: 'e.g. 20',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: accentThemeColor, width: 2),
                      ),
                      suffixText: '%',
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a discount value';
                      }
                      try {
                        double discount = double.parse(value);
                        if (discount <= 0 || discount > 100) {
                          return 'Discount must be between 0 and 100';
                        }
                      } catch (e) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Save Button
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveCoupon,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentThemeColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_circle_outline),
                          SizedBox(width: 8),
                          Text('Create Coupon'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Coupon List Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Coupons',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Coupon List
                  _buildCouponList(),
                ],
              ),
            ),
            
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}