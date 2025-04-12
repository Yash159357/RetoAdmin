import 'package:flutter/material.dart';
import 'package:reto_admin/views/side_bar_screens/widgets/vendor_list_widget.dart';

class VendorsScreen extends StatelessWidget {
  static const String id = '\vendors-screen';

  const VendorsScreen({super.key});

  final Color primaryThemeColor = const Color.fromARGB(255, 255, 246, 233);
  final Color accentThemeColor = const Color.fromARGB(210, 248, 186, 94);

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
                      'Manage Vendors',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              //Row Header
              Row(
                children: [
                  rowHeader(1, 'Vendor ID'),
                  rowHeader(1, 'Name'),
                  rowHeader(3, 'Address'),
                  rowHeader(2, 'Email'),
                  rowHeader(1, 'Phone Number'),
                ],
              ),

              const VendorListWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
