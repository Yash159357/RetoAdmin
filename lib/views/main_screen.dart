import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:reto_admin/views/side_bar_screens/category_screen.dart';
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
  //This "_selectedScreen" will store and help us to navigate to other Side Bar Screens
  Widget _selectedScreen =
      CustomersScreen(); //By default it is set to VendorsScreen, i.e., when our Admin Panel will open first this side bar screen will appear.

  //Creating a function that will change our Screens on clicking that respective Side Bar Screen Button.
  screenSelector(item) {
    switch (item.route) {
      //Whichever particular Option we will click in Side Bar will be counted as Item here. Hence if our item.route matches with that id of that screen then we will display that screen.

      case CustomersScreen.id:
        setState(() {
          _selectedScreen = CustomersScreen();
        });

        break; //Giving break that if our id matches and display that page then we don't have to run the entire function and we will come out of the function

      case VendorsScreen.id:
        setState(() {
          _selectedScreen = VendorsScreen();
        });

        break;

      case OrdersScreen.id:
        setState(() {
          _selectedScreen = OrdersScreen();
        });

        break;

      case CategoryScreen.id:
        setState(() {
          _selectedScreen = CategoryScreen();
        });

        break;

      case UploadBannerScreen.id:
        setState(() {
          _selectedScreen = UploadBannerScreen();
        });

        break;

      case ProductsScreen.id:
        setState(() {
          _selectedScreen = ProductsScreen();
        });

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      //Creating the App Bar of our Admin Panel
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(
          210,
          248,
          186,
          94,
        ), //Color of our Admin Panel App Bar

        title: const Text("RetoRADIANCE"), //Title of our App Bar
      ),

      //Which Screen will show depends on '_selectedScreen' variable. Default Screen which will be showed after opening Admin Panel is done above at the beginning.
      body: _selectedScreen,

      //Creating the Side Bar of our Admin Panel
      sideBar: SideBar(
        //Items to show in our Side Bar
        items: const [
          //Customers Section in Side Bar
          AdminMenuItem(
            title: 'Customers',
            route:
                CustomersScreen
                    .id, //Passing the id which we mentioned on every Side Bar Screen for Navigation
            icon: CupertinoIcons.person_3_fill,
          ),

          //Vendor Section in Side Bar
          AdminMenuItem(
            title: 'Vendors',
            route:
                VendorsScreen
                    .id, //Passing the id which we mentioned on every Side Bar Screen for Navigation
            icon: CupertinoIcons.person,
          ),

          //Orders Section in Side Bar
          AdminMenuItem(
            title: 'Orders',
            route:
                OrdersScreen
                    .id, //Passing the id which we mentioned on every Side Bar Screen for Navigation
            icon: CupertinoIcons.cart_fill,
          ),

          //Categories Section in Side Bar
          AdminMenuItem(
            title: 'Categories',
            route:
                CategoryScreen
                    .id, //Passing the id which we mentioned on every Side Bar Screen for Navigation
            icon: Icons.category,
          ),

          //Banners Section in Side Bar
          AdminMenuItem(
            title: 'Upload Banners',
            route:
                UploadBannerScreen
                    .id, //Passing the id which we mentioned on every Side Bar Screen for Navigation
            icon: CupertinoIcons.plus,
          ),

          //Products Section in Side Bar
          AdminMenuItem(
            title: 'Upload Product',
            route:
                ProductsScreen
                    .id, //Passing the id which we mentioned on every Side Bar Screen for Navigation
            icon: CupertinoIcons.shopping_cart,
          ),
        ], //End of Items Section in Side Bar

        selectedRoute:
            CustomersScreen
                .id, //This will highlight the item in Side Bar that we made default at the top. When we change our Default Screen change this as well.

        onSelected: (item) {
          //This will store which item in Side Bar we clicked.
          screenSelector(item);
        },
      ),
    );
  }
}
