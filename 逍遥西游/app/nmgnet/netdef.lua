LOGIN_SUCCEED = 1
LOGIN_ACCOUNTNOTEXIST = 2
LOGIN_PWDERROR = 3
LOGIN_ServieFixing = 4
LOGIN_Other = 5
NetStatus_DisConn = 0
NetStatus_WIFI = 1
NetStatus_3G = 2
NetStatusConvert = {
  [kCCNetworkStatusNotReachable] = NetStatus_DisConn,
  [kCCNetworkStatusReachableViaWiFi] = NetStatus_WIFI,
  [kCCNetworkStatusReachableViaWWAN] = NetStatus_3G
}
