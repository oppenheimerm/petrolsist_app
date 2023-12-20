
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum MapStyleTheme{
  night,
  silver
}

class Helpers{
  static const String themesUrl = "assets/themes";

  static String _getMapStyleTheme(MapStyleTheme request){
    var requestType =  request.name;
    switch(requestType){
      case 'night':
        return "$themesUrl/night_style.json";
      case 'silver':
        return "$themesUrl/silver.json";
      default:
        throw const FormatException('Invalid MapStyleTheme!');
    }
  }

  //  https://docs.flutter.dev/ui/assets/assets-and-images#:~:text=Each%20Flutter%20app%20has%20a,%3Aflutter%2Fservices.dart%20.
  //  https://api.flutter.dev/flutter/widgets/DefaultAssetBundle/of.html
  static Future<String?> getThemeFile(MapStyleTheme mapStyleTheme) async{

    String? stringError;
    var source = _getMapStyleTheme(mapStyleTheme);
    if(source.isEmpty)
      {
        return stringError;
      }else{
        try{
          return await rootBundle.loadString(source);
        }
        catch(err){
          return stringError;
        }
    }

  }


}