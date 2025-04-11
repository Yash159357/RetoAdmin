import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:reto_admin/views/side_bar_screens/widgets/banner_list_widget.dart';

class UploadBannerScreen extends StatefulWidget {
  static const String id = '\UploadBannerScreen';

  const UploadBannerScreen({super.key});

  @override
  State<UploadBannerScreen> createState() => _UploadBannerScreenState();
}

class _UploadBannerScreenState extends State<UploadBannerScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  dynamic _image;
  String?
  fileName; // Keep this for internal use only, won't be stored in Firestore

  // Theme colors to match the order list widget
  final Color primaryThemeColor = const Color.fromARGB(255, 255, 246, 233);
  final Color accentThemeColor = const Color.fromARGB(210, 248, 186, 94);

  pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _image = result.files.first.bytes;
        fileName = result.files.first.name;
      });
    }
  }

  _uploadImageToStorage(dynamic image) async {
    // Generate a unique filename using timestamp to avoid conflicts
    String uniqueFileName =
        DateTime.now().millisecondsSinceEpoch.toString() + '_banner';

    Reference ref = _firebaseStorage
        .ref()
        .child('banners')
        .child(uniqueFileName);
    UploadTask uploadTask = ref.putData(image);

    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  uploadToFirestore() async {
    if (_image != null) {
      try {
        EasyLoading.show(status: 'Uploading...');
        String imageUrl = await _uploadImageToStorage(_image);

        // Generate a unique document ID for the banner
        String docId = DateTime.now().millisecondsSinceEpoch.toString();

        await _firestore
            .collection('banners')
            .doc(docId)
            .set({
              'image': imageUrl,
              'createdAt': FieldValue.serverTimestamp(),
              // Removed fileName field as it's not needed in Firestore
            })
            .whenComplete(() {
              EasyLoading.dismiss();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: accentThemeColor,
                  content: Text('Banner uploaded successfully!'),
                  duration: Duration(seconds: 2),
                ),
              );
              setState(() {
                _image = null;
                fileName = null;
              });
            });
      } catch (e) {
        EasyLoading.dismiss();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error uploading banner: ${e.toString()}'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orange,
          content: Text('Please select an image first'),
          duration: Duration(seconds: 2),
        ),
      );
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Screen Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Banners',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            Divider(color: Colors.grey.shade300, thickness: 1),

            // Banner Upload Section
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
                    'Upload New Banner',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Preview Container
                      Container(
                        height: 160,
                        width: 300,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: accentThemeColor),
                        ),
                        child:
                            _image != null
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    _image,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_outlined,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Select banner image',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                      ),

                      SizedBox(width: 24),

                      // Upload Controls
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (fileName != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                'Selected file: $fileName',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            ),

                          ElevatedButton(
                            onPressed: pickImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: accentThemeColor,
                              side: BorderSide(color: accentThemeColor),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.file_upload_outlined),
                                SizedBox(width: 8),
                                Text('Choose Image'),
                              ],
                            ),
                          ),

                          SizedBox(height: 16),

                          ElevatedButton(
                            onPressed: uploadToFirestore,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentThemeColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.save_outlined),
                                SizedBox(width: 8),
                                Text('Save Banner'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Banner List Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Banner Gallery',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Banner List Widget
                  BannerListWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
