import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VendorDetailDialog extends StatefulWidget {
  final Map<String, dynamic> vendorData;

  const VendorDetailDialog({
    super.key,
    required this.vendorData,
  });

  @override
  _VendorDetailDialogState createState() => _VendorDetailDialogState();
}

class _VendorDetailDialogState extends State<VendorDetailDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  String? _storeImageUrl;
  PlatformFile? _selectedImageFile;
  bool _isUploading = false;
  
  // Controllers for all text fields
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _localityController;
  late TextEditingController _stateController;
  late TextEditingController _pinCodeController;
  late TextEditingController _uidController;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with vendor data
    _nameController = TextEditingController(text: widget.vendorData['name'] ?? '');
    _emailController = TextEditingController(text: widget.vendorData['email'] ?? '');
    _phoneController = TextEditingController(text: widget.vendorData['number'] ?? '');
    _cityController = TextEditingController(text: widget.vendorData['city'] ?? '');
    _localityController = TextEditingController(text: widget.vendorData['locality'] ?? '');
    _stateController = TextEditingController(text: widget.vendorData['state'] ?? '');
    _pinCodeController = TextEditingController(text: widget.vendorData['pinCode'] ?? '');
    _uidController = TextEditingController(text: widget.vendorData['uid'] ?? '');
    
    // Initialize store image URL if available
    _storeImageUrl = widget.vendorData['storeImage'];
  }

  @override
  void dispose() {
    // Dispose controllers
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _localityController.dispose();
    _stateController.dispose();
    _pinCodeController.dispose();
    _uidController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (!_isEditing) return;
    
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _selectedImageFile = result.files.first;
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImageFile == null) return _storeImageUrl;
    
    setState(() {
      _isUploading = true;
    });
    
    try {
      // Create a reference to the storage location
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('vendor_stores')
          .child('${_uidController.text}_store');
      
      // For web platform
      final uploadTask = storageRef.putData(
        _selectedImageFile!.bytes!,
        SettableMetadata(contentType: 'image/${_selectedImageFile!.extension}'),
      );
      
      // Wait for the upload to complete
      await uploadTask;
      
      // Get the download URL
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
      return null;
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _saveVendorData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    try {
      // Start by uploading the image if selected
      String? imageUrl = await _uploadImage();
      
      // Prepare vendor data
      Map<String, dynamic> vendorData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'number': _phoneController.text,
        'city': _cityController.text,
        'locality': _localityController.text,
        'state': _stateController.text,
        'pinCode': _pinCodeController.text,
      };
      
      // Add store image URL if available
      if (imageUrl != null) {
        vendorData['storeImage'] = imageUrl;
      }
      
      // Update vendor document in Firestore
      await FirebaseFirestore.instance
          .collection('vendors')
          .doc(_uidController.text)
          .update(vendorData);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vendor information updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Close the dialog
      Navigator.of(context).pop();
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating vendor: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryThemeColor = const Color.fromARGB(255, 255, 246, 233);
    final Color accentThemeColor = const Color.fromARGB(210, 248, 186, 94);
    
    // Get screen size to calculate 5% of height
    final screenHeight = MediaQuery.of(context).size.height;
    final additionalHeight = screenHeight * 0.05;

    return Dialog(
      backgroundColor: primaryThemeColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600, 
          maxHeight: 700 + additionalHeight, // Increased height by 5% of screen height
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dialog Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Vendor Details',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: accentThemeColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(thickness: 2),
              
              // Vendor Details Form
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Store Image
                        Center(
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: accentThemeColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: _isUploading
                                      ? const Center(child: CircularProgressIndicator())
                                      : _selectedImageFile != null
                                          ? ClipOval(
                                              child: Image.memory(
                                                _selectedImageFile!.bytes!,
                                                fit: BoxFit.cover,
                                                width: 120,
                                                height: 120,
                                              ),
                                            )
                                          : _storeImageUrl != null && _storeImageUrl!.isNotEmpty
                                              ? ClipOval(
                                                  child: Image.network(
                                                    _storeImageUrl!,
                                                    fit: BoxFit.cover,
                                                    width: 120,
                                                    height: 120,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return const Icon(
                                                        Icons.storefront,
                                                        size: 60,
                                                        color: Colors.grey,
                                                      );
                                                    },
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.storefront,
                                                  size: 60,
                                                  color: Colors.grey,
                                                ),
                                ),
                                if (_isEditing)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: accentThemeColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Vendor ID - Read-only
                        TextFormField(
                          controller: _uidController,
                          decoration: InputDecoration(
                            labelText: 'Vendor ID',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          readOnly: true, // Always read-only
                        ),
                        const SizedBox(height: 16),
                        
                        // Name
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          readOnly: !_isEditing,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter vendor name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Email
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          readOnly: !_isEditing,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter email';
                            }
                            if (!value.contains('@') || !value.contains('.')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Phone Number
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          readOnly: !_isEditing,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Address Fields
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _localityController,
                                decoration: InputDecoration(
                                  labelText: 'Locality',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                readOnly: !_isEditing,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _cityController,
                                decoration: InputDecoration(
                                  labelText: 'City',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                readOnly: !_isEditing,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _stateController,
                                decoration: InputDecoration(
                                  labelText: 'State',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                readOnly: !_isEditing,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _pinCodeController,
                                decoration: InputDecoration(
                                  labelText: 'Pin Code',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                readOnly: !_isEditing,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              const Divider(thickness: 1),
              
              // Bottom Action Buttons - Centered
              Center(
                child: !_isEditing
                    ? ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentThemeColor,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text(
                          'Edit',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center, // Center the buttons
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                _selectedImageFile = null;
                                
                                // Reset controllers to original values
                                _nameController.text = widget.vendorData['name'] ?? '';
                                _emailController.text = widget.vendorData['email'] ?? '';
                                _phoneController.text = widget.vendorData['number'] ?? '';
                                _cityController.text = widget.vendorData['city'] ?? '';
                                _localityController.text = widget.vendorData['locality'] ?? '';
                                _stateController.text = widget.vendorData['state'] ?? '';
                                _pinCodeController.text = widget.vendorData['pinCode'] ?? '';
                              });
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _saveVendorData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentThemeColor,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: const Text(
                              'Save Changes',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}