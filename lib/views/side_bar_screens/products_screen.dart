import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'dart:typed_data';

class ProductsScreen extends StatefulWidget {
  static const String id = '\products-screen';

  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Theme colors
  final Color primaryThemeColor = const Color.fromARGB(255, 255, 246, 233);
  final Color accentThemeColor = const Color.fromARGB(210, 248, 186, 94);

  bool _isLoading = false;

  final List<String> _categoryList = [];

  // we will be uploading the values stored in these variables to the cloud firestore
  final List<String> _sizeList = [];
  String? selectedCategory;
  bool isLoading = false;
  String? productName;
  double? productPrice;
  int? discount;
  int? quantity;
  String? description;
  bool isPopular = false;
  bool isRecommended = false;

  bool _isEntered = false;

  final List<Uint8List> _images = [];
  final List<String> _imagesUrls = [];

  @override
  void initState() {
    _getCategories();
    super.initState();
  }

  chooseImage() async {
    final pickedImages = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );

    if (pickedImages != null) {
      setState(() {
        for (var file in pickedImages.files) {
          _images.add(file.bytes!);
        }
      });
    }
  }

  _getCategories() {
    return _firestore.collection('categories').get().then((
      QuerySnapshot querySnapshot,
    ) {
      for (var doc in querySnapshot.docs) {
        setState(() {
          _categoryList.add(doc['categoryName']);
        });
      }
    });
  }

  // Upload product image to storage
  uploadImageToStorage() async {
    for (var img in _images) {
      Reference ref = _firebaseStorage
          .ref()
          .child('productImages')
          .child(Uuid().v4());
      await ref.putData(img).whenComplete(() async {
        await ref.getDownloadURL().then((value) {
          setState(() {
            _imagesUrls.add(value);
          });
        });
      });
    }
  }

  // Function to upload products to cloud
  uploadData() async {
    setState(() {
      _isLoading = true;
    });
    await uploadImageToStorage();
    if (_imagesUrls.isNotEmpty) {
      final productId = Uuid().v4();
      await _firestore
          .collection('products')
          .doc(productId)
          .set({
            'productId': productId,
            'productName': productName,
            'productPrice': productPrice,
            'productSize': _sizeList[0],
            'category': selectedCategory,
            'description': description,
            'discount': discount,
            'quantity': quantity,
            'productImage': _imagesUrls,
            'isPopular': isPopular,
            'isRecommended': isRecommended,
            'isSoldOut': false,
            'rating': 0,
            'totalReviews': 0,
            'lastUpdated': FieldValue.serverTimestamp(),
          })
          .whenComplete(() {
            setState(() {
              _isLoading = false;
              _formKey.currentState!.reset();
              _productNameController.clear();
              _imagesUrls.clear();
              _images.clear();
              _sizeList.clear();
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Product uploaded successfully'),
                backgroundColor: Colors.green,
              ),
            );
          });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add at least one image'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
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
                      'Add New Product',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: accentThemeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add_shopping_cart, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Products',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Product Form
              Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(20),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name Field
                      TextFormField(
                        controller: _productNameController,
                        onChanged: (value) {
                          productName = value;
                        },
                        maxLength: 16, // Limit to 16 characters
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter product name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Product Name',
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(
                            Icons.shopping_bag_outlined,
                            color: accentThemeColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Price & Category Row
                      Row(
                        children: [
                          // Price Field
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  productPrice = double.parse(value);
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter price';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid price';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'Price(in rupees)',
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(Icons.attach_money, color: accentThemeColor),
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Category Dropdown
                          Expanded(
                            child: DropdownButtonFormField(
                              validator: (value) {
                                if (value == null) {
                                  return 'Select category';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'Category',
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(
                                  Icons.category,
                                  color: accentThemeColor,
                                ),
                              ),
                              items:
                                  _categoryList.map((value) {
                                    return DropdownMenuItem(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedCategory = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Discount & Quantity Row
                      Row(
                        children: [
                          // Discount Field
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  discount = int.parse(value);
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter discount %';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Invalid discount';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'Discount %',
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(
                                  Icons.discount,
                                  color: accentThemeColor,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Quantity Field
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  quantity = int.parse(value);
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter quantity';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Invalid quantity';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'Quantity',
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(
                                  Icons.inventory,
                                  color: accentThemeColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Popular/Recommended Dropdown
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Product Status',
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.star, color: accentThemeColor),
                        ),
                        items: const [
                          DropdownMenuItem<String>(
                            value: 'None',
                            child: Text('None'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Popular',
                            child: Text('Popular'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Recommended',
                            child: Text('Recommended'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            if (value == 'Popular') {
                              isPopular = true;
                              isRecommended = false;
                            } else if (value == 'Recommended') {
                              isRecommended = true;
                              isPopular = false;
                            } else {
                              isPopular = false;
                              isRecommended = false;
                            }
                          });
                        },
                        value:
                            isPopular
                                ? 'Popular'
                                : (isRecommended ? 'Recommended' : 'None'),
                      ),

                      const SizedBox(height: 16),

                      // Description Field
                      TextFormField(
                        onChanged: (value) {
                          description = value;
                        },
                        maxLines: 4,
                        maxLength: 800,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter product description';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(
                            Icons.description,
                            color: accentThemeColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Size Input Section
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Product Sizes',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _sizeController,
                                    onChanged: (value) {
                                      setState(() {
                                        _isEntered = value.isNotEmpty;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Add Size (e.g. S, M, L)',
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.straighten,
                                        color: accentThemeColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                _isEntered
                                    ? ElevatedButton(
                                      onPressed: () {
                                        if (_sizeController.text.isNotEmpty) {
                                          setState(() {
                                            _sizeList.add(_sizeController.text);
                                            _sizeController.clear();
                                            _isEntered = false;
                                          });
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: accentThemeColor,
                                        foregroundColor: Colors.black87,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 16,
                                        ),
                                      ),
                                      child: Text('Add Size'),
                                    )
                                    : SizedBox.shrink(),
                              ],
                            ),

                            SizedBox(height: 10),

                            // Size Tags Display
                            _sizeList.isNotEmpty
                                ? Container(
                                  height: 50,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _sizeList.length,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            _sizeList.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(right: 8),
                                          decoration: BoxDecoration(
                                            color: accentThemeColor,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                _sizeList[index],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              SizedBox(width: 6),
                                              Icon(
                                                Icons.close,
                                                size: 16,
                                                color: Colors.black87,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                                : Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  child: Text(
                                    'No sizes added yet',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Image Upload Section
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Product Images',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 16),

                            // Image Preview Grid
                            _images.isEmpty
                                ? InkWell(
                                  onTap: () {
                                    chooseImage();
                                  },
                                  child: Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: accentThemeColor.withOpacity(
                                          0.5,
                                        ),
                                        width: 1,
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.cloud_upload,
                                            size: 50,
                                            color: accentThemeColor,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Upload Product Images',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Click to browse files',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount:
                                          _images.length +
                                          1, // +1 for add button
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            mainAxisSpacing: 10,
                                            crossAxisSpacing: 10,
                                            childAspectRatio: 1.0,
                                          ),
                                      itemBuilder: (context, index) {
                                        return index == 0
                                            ? InkWell(
                                              onTap: () {
                                                chooseImage();
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: accentThemeColor
                                                        .withOpacity(0.5),
                                                    width: 1,
                                                    style: BorderStyle.solid,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.add_photo_alternate,
                                                    size: 30,
                                                    color: accentThemeColor,
                                                  ),
                                                ),
                                              ),
                                            )
                                            : Stack(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    image: DecorationImage(
                                                      image: MemoryImage(
                                                        _images[index - 1],
                                                      ),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 5,
                                                  right: 5,
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        _images.removeAt(
                                                          index - 1,
                                                        );
                                                      });
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.all(
                                                        4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.red,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons.close,
                                                        size: 14,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                      },
                                    ),
                                    if (_images.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        child: Text(
                                          '${_images.length} image(s) selected',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              _isLoading
                                  ? null
                                  : () {
                                    if (_formKey.currentState!.validate()) {
                                      if (_images.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Please add at least one product image',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      if (_sizeList.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Please add at least one size',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      uploadData();
                                    }
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentThemeColor,
                            foregroundColor: Colors.black87,
                            disabledBackgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child:
                              _isLoading
                                  ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.cloud_upload),
                                      SizedBox(width: 10),
                                      Text(
                                        'Upload Product',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
