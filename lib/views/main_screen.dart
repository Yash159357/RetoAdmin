import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reto_admin/views/side_bar_screens/category_screen.dart';
import 'package:reto_admin/views/side_bar_screens/coupon_screen.dart';
import 'package:reto_admin/views/side_bar_screens/customers_screen.dart';
import 'package:reto_admin/views/side_bar_screens/orders_screen.dart';
import 'package:reto_admin/views/side_bar_screens/products_screen.dart';
import 'package:reto_admin/views/side_bar_screens/upload_banner_screen.dart';
import 'package:reto_admin/views/side_bar_screens/vendors_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Widget _selectedScreen = CustomersScreen();
  String _selectedRoute = CustomersScreen.id;
  int? _hoveredIndex;

  // Menu items for our sidebar
  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'Customers',
      'route': CustomersScreen.id,
      'icon': CupertinoIcons.person_3_fill,
      'screen': CustomersScreen(),
      'badgeCount': 5, // Example badge count
    },
    {
      'title': 'Vendors',
      'route': VendorsScreen.id,
      'icon': CupertinoIcons.person,
      'screen': VendorsScreen(),
      'badgeCount': 2, // Example badge count
    },
    {
      'title': 'Orders',
      'route': OrdersScreen.id,
      'icon': CupertinoIcons.cart_fill,
      'screen': OrdersScreen(),
      'badgeCount': 12, // Example badge count
    },
    {
      'title': 'Categories',
      'route': CategoryScreen.id,
      'icon': Icons.category,
      'screen': CategoryScreen(),
    },
    {
      'title': 'Upload Banners',
      'route': UploadBannerScreen.id,
      'icon': CupertinoIcons.photo,
      'screen': UploadBannerScreen(),
    },
    {
      'title': 'Upload Product',
      'route': ProductsScreen.id,
      'icon': CupertinoIcons.cube_box_fill,
      'screen': ProductsScreen(),
    },
    {
      'title': 'Coupons',
      'route': CouponScreen.id,
      'icon': CupertinoIcons.ticket_fill,
      'screen': CouponScreen(),
      'badgeCount': 3, // Example badge count
    },
  ];

  void _selectMenuItem(String route) {
    setState(() {
      _selectedRoute = route;
      // Find the screen that matches the selected route
      for (var item in _menuItems) {
        if (item['route'] == route) {
          _selectedScreen = item['screen'];
          break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color accentThemeColor = const Color.fromARGB(210, 248, 186, 94);
    final Color backgroundColor = const Color.fromARGB(255, 255, 246, 233);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: accentThemeColor,
        title: const Text(
          "RetoRADIANCE",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications panel will be displayed here'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Admin profile will be displayed here'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Row(
        children: [
          // Enhanced sidebar
          Container(
            width: 250,
            color: backgroundColor,
            child: Column(
              children: [
                // Admin info section
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: Color.fromARGB(210, 248, 186, 94),
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Admin User',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Super Admin',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Menu section
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      final item = _menuItems[index];
                      final bool isSelected = _selectedRoute == item['route'];
                      final bool isHovered = _hoveredIndex == index;
                      
                      return Column(
                        children: [
                          MouseRegion(
                            onEnter: (_) => setState(() => _hoveredIndex = index),
                            onExit: (_) => setState(() => _hoveredIndex = null),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? accentThemeColor.withOpacity(0.2) 
                                    : isHovered
                                        ? Colors.grey.withOpacity(0.1)
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: isHovered || isSelected
                                    ? [
                                        BoxShadow(
                                          color: accentThemeColor.withOpacity(0.1),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : [],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                leading: Icon(
                                  item['icon'],
                                  color: isSelected || isHovered 
                                      ? accentThemeColor 
                                      : Colors.grey[700],
                                  size: 22,
                                ),
                                title: Text(
                                  item['title'],
                                  style: TextStyle(
                                    color: isSelected || isHovered 
                                        ? Colors.black 
                                        : Colors.grey[800],
                                    fontWeight: isSelected 
                                        ? FontWeight.bold 
                                        : FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                                trailing: item.containsKey('badgeCount')
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: accentThemeColor,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${item['badgeCount']}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : null,
                                onTap: () => _selectMenuItem(item['route']),
                              ),
                            ),
                          ),
                          // Add a separator if not the last item
                          if (index < _menuItems.length - 1)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Divider(
                                height: 1,
                                thickness: 0.5,
                                color: Colors.grey.withOpacity(0.2),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                
                // Footer section
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Logout function will be implemented here'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout,
                          color: Colors.grey[700],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Divider between sidebar and content
          Container(
            width: 1,
            color: Colors.grey.withOpacity(0.2),
          ),
          
          // Main content area
          Expanded(
            child: Container(
              color: Colors.grey.withOpacity(0.05),
              child: Stack(
                children: [
                  _selectedScreen,
                  // Optional: Add a floating action button for quick actions
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
