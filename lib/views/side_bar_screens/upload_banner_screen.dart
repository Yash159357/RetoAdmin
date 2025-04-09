//Copied this entire section from 'category_screen' page and did the required changes

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:reto_admin/views/side_bar_screens/widgets/banner_list_widget.dart';
import 'package:reto_admin/views/side_bar_screens/widgets/category_list_widget.dart';

class UploadBannerScreen extends StatefulWidget {

  static const String id = '\UploadBannerScreen';

  const UploadBannerScreen({super.key});

  @override
  State<UploadBannerScreen> createState() => _UploadBannerScreenState();
}

class _UploadBannerScreenState extends State<UploadBannerScreen> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); //Creating Form Key in order to check and validate our 'Type the Category Name' Form created down.

  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  dynamic _image; //We will store the picked up image in this variable

  String ? fileName; //In this variable we will store the file name of the image by which it is saved in our local system.



  //Creating a Function that will let us pick image from our local system and which will be send and saved in our Firebase.
  pickImage() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles( //Here '?' means it makes our variable 'result' nullable because it may happen that our user doesn't select any image and press 'Save' and in that case we will face an Error but with this we will avoid such situations.
      type: FileType.image, //With this we can pick up only Images. Extra Info: We can also pick up audio files with this 'FileType'.
      allowMultiple: false, //With this being 'false' we can't select multiple Images
    );

    if(result!=null) { //This means it is not empty and the user has successfully picked up an image.
      setState(() {
        _image = result.files.first.bytes;
        fileName = result.files.first.name;
      });
    }

  }


  //Creating a Function that will upload our Image in our Firebase Storage.
  _uploadImageToStorage(dynamic image) async{
    Reference ref = _firebaseStorage.ref().child('banners').child(fileName!); //Here what we are doing is we are creating a file named 'categories' in our Firebase Storage and also uploading the image with its 'fileName' which is the name of our File (Image) in our Local System.
    UploadTask uploadTask = ref.putData(image);

    TaskSnapshot snap = await uploadTask;  //Waiting till our uploading is done then storing that uploaded image details in Firebase Storage in 'snap'
    String downloadUrl = await snap.ref.getDownloadURL(); //Storing the Url of our uploaded image in Firebase Storage in 'downloadUrl' and we will use it to save this in our Firestore Database (recall how we did it manually at the beginning).
    return downloadUrl;
  }


  //Creating a Function to store the details (present in Firebase Storage) of the Image uploaded in Firebase Storage in our Cloud Firestore from where we will mainly retrieve.
  uploadToFirestore() async {
    if(_image!=null) {
      EasyLoading.show(); //Starting our Easy Loading
      String imageUrl = await _uploadImageToStorage(_image);
      await _firestore.collection('banners').doc(fileName).set({ //Creating the collections in Firestore like we did previously manually in the beginning
        'image': imageUrl,
      }).whenComplete((){ //It denotes that when our function has been completed
        EasyLoading.dismiss(); //Ending our Easy Loading
        _image = null; //Resetting so that we can upload new image
      });
    }else { //This part means that our image has been not picked
      EasyLoading.dismiss();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Form(

      key: _formKey,

      child: Column(

        children: [

          //Categories Screen Header
          Padding(
            padding: const EdgeInsets.all(8.0), //Giving padding in all directions.
            child: Container(
              alignment: Alignment.topLeft,

              //Categories Screen Header Text and Style
              child: Text('Banners',style: TextStyle(fontSize: 36,fontWeight: FontWeight.bold),),
            ),
          ),


          //Divider is a horizontal line
          Divider(
            color: Colors.grey,
          ),


          Row( //To place items horizontally
            children: [

              Column( //To place items vertically within the row

                children: [


                  //Category Image Upload Box
                  Container(
                    height: 140,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade500, //Color of the Category Image Upload Box
                      border: Border.all( //Giving Border to our Category Image Upload Box
                          color: Colors.grey.shade800 //Color of Border of the Category Image Upload Box
                      ),
                      borderRadius: BorderRadius.circular(10), //Making our Category Image Upload Box Circular
                    ),

                    child: Center(
                      child: _image!=null ? Image.memory(_image) : Text( //This means that if our image is selected then display that image in this box else display this Text mentioned just in the next line.
                        'Upload Image', //Text inside Category Image Upload Box
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),),),

                  ), //End of Category Image Upload Box


                  //Category Image Upload Button
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ElevatedButton(
                      onPressed: () {
                        pickImage(); //Calling 'pickImage()' function when we press this button.
                      },
                      child: Text('Upload Image', //Text shown in the Button
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),

                    ),
                  ), //End of Category Image Upload Button


                ],
              ),


              SizedBox(width: 30,), //Giving spacing horizontally as we are only mentioning 'width' and not 'height'.




              //Button to Save our Category Name and Image and upload them to our Firebase
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.white, //Background Color of our Button
                  ),
                  side: MaterialStateProperty.all(BorderSide(color: Colors.blue.shade900,),), //Border Color of our Button
                ),
                onPressed: () {
                  uploadToFirestore(); //Calling this function which will upload our Category Name and Image in our Firebase.
                } ,
                child: const Text('Save', //Button Text
                ),
              ),

            ],
          ),

          //Displaying our present Banners stored in our Firebase
          BannerListWidget(),

        ],
      ),
    );
  }
}
