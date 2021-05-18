
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tourist_guide/controller/auth_controller.dart';
import 'package:tourist_guide/data/firebase_auth.dart';
import 'package:tourist_guide/data/repository.dart';
import 'package:tourist_guide/models/user.dart';
import 'package:tourist_guide/utils/user_util.dart';

class EditProfileController extends GetxController{

  Rx<bool> isFormValid = false.obs;
  Rx<bool> isUploading = false.obs;
  late TextEditingController nameController ;
  late TextEditingController languagesController;
  late TextEditingController phoneController;
  late TextEditingController pwController;
  late TextEditingController confirmPwController;
  late AuthenticationController _authenticationController;
  late ImagePicker picker;
  var _pickedFile = PickedFile("path").obs;

  get pickedFile => _pickedFile;
  Rx<String> emptyFieldError = "".obs;
  Rx<String> invalidEmailError = "".obs;
  var imageSelectionText = "Select a picture".obs;
  late Repository _repository;
  late User currentUser;
  var userName = ''.obs;


  @override
  void onInit() {
    currentUser = Get.find<AuthenticationController>().user.value;
    userName.value = currentUser.name;
    picker = ImagePicker();
    languagesController = TextEditingController(text: UserUtil.formatLanguagesList(currentUser.langs));
    nameController = TextEditingController(text : currentUser.name);
    nameController.addListener(() {
      print("AddListener called");
      userName.value = nameController.text.trim();});
    phoneController = TextEditingController(text : currentUser.phone);
    pwController = TextEditingController();
    confirmPwController = TextEditingController();
    _authenticationController = Get.find<AuthenticationController>();
    _repository =Repository.instance();
    super.onInit();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    clear();
  }

  void clear(){
    languagesController.clear();
    nameController.clear();
    phoneController.clear();
    confirmPwController.clear();
    pwController.clear();
  }


  Future uploadImageToFirebase(File _imageFile, String fileName) async {
    return await _repository.uploadImageToFirebase(fileName, _imageFile);

  }
  void updateUser(String imageUrl) async{
    //User user = User(key,

    User user = User(currentUser.userId,nameController.text.trim(),
        currentUser.email,phoneController.text.trim(),
        languagesController.text.split(','),imageUrl);
    _authenticationController.user.value = user;
    try {
      await _repository.updateUser(user);
      //Future.delayed(Duration(milliseconds: 2000),()=>isUploading.value = false);
      isUploading.value = false;
      Get.back();
    }
    catch(e){
    }
  }
  void onSavePressed() async{
    if (validate()) {
      String url = currentUser.imageUrl;
      isUploading.value = true;
      if(_pickedFile.value.path != "path") {
        var splitted = _pickedFile.value.path.split('/');
        String fileName = splitted[splitted.length - 1];
            url = await uploadImageToFirebase(File(_pickedFile.value.path), fileName);
      }
      updateUser(url);
    }else{
      Get.snackbar("Validation error", "forms are not valid");
    }

  }

  bool checkEmptyField(String value){
    if(value.isEmpty){
      return true;
    }
    return false;
  }
  void pickImage() async{
    _pickedFile.value = (await ImagePicker().getImage(
      source: ImageSource.gallery ,
    ))!;

  }


  bool validate(){
    bool isValid = true;
    emptyFieldError.value = "";
    if(checkEmptyField(languagesController.text.trim()) || checkEmptyField(nameController
        .text.trim())||checkEmptyField(nameController.text.trim()) || checkEmptyField(phoneController.text.trim())){
      print("invalidity while checking for empty fields");
      isFormValid.value = false;
      isValid = false;
      emptyFieldError.value = "Please, enter a valid input";
    }

    if(isValid == true){
      isFormValid.value = true;
    }
    return isValid;
  }
}