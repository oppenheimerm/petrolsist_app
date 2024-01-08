import 'package:flutter/material.dart';
import 'package:petrolsist_app/models/user.dart';
import 'package:petrolsist_app/service/local_storage.dart';
import 'package:petrolsist_app/viewmodels/user_vm.dart';

import '../app_constants.dart';


class EditProfileViewModel with ChangeNotifier{
  UserViewModel? userViewModel = UserViewModel();

  bool _editSettingLoading = false;
  // Getter Methods
  bool get editSettingsLoading => _editSettingLoading;

  UserModel? get getUser => LocalStorageService.getUserFromDisk();

  //String get getProfilePicture => LocalStorageService().getUSerFromDisk()

  String? getUserPhotoUrl(){
    var usr = LocalStorageService.getUserFromDisk();
    if(usr != null ){
      var img =  (usr.photo.isNotEmpty)? usr.photo : "";
      if(img.isNotEmpty){
        debugPrint("User photo url: ${"${AppConsts.baseUrl}${AppConsts.memberFolderPostfix}/$img"}");
        return "${AppConsts.baseUrl}${AppConsts.memberFolderPostfix}/$img";
      }else{
        return null;
      }
    }else{
      return null;
    }
  }



  // Setter Methods
  void setEditLoading(bool newBool) {
    _editSettingLoading = newBool;
    notifyListeners();
  }



}