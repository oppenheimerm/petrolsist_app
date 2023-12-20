import 'package:connectivity_plus/connectivity_plus.dart';

abstract class PSAppNetworkService {
  Future<bool>psGetNetworkStatus();
}


class PSNetworkService implements PSAppNetworkService {


  @override
  Future<bool>psGetNetworkStatus() async
  {
    var connectionResult = await Connectivity().checkConnectivity();
    if(connectionResult != ConnectivityResult.mobile && connectionResult != ConnectivityResult.wifi) {
      return false;
    }else {
      return true;
    }
  }
}