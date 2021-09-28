local g_CurProtocolIndex = 0
local g_maxProtocolIndex = 9999
function getProtocalIndexAndIncrease()
  g_CurProtocolIndex = g_CurProtocolIndex % g_maxProtocolIndex + 1
  return g_CurProtocolIndex
end
function getNetworkStatus()
  local status = CCNetwork:getInternetConnectionStatus()
  return NetStatusConvert[status] or NetStatus_DisConn
end
function NetConn(connResultListerner, ip, port)
  return netconn:connect(connResultListerner, ip, port)
end
function NetSend(param, protocol, sub_pro)
  local data = json.encode({
    p = protocol,
    s = sub_pro,
    a = param,
    n = getProtocalIndexAndIncrease()
  })
  print(string.format("[PROTOCOL]Send:p=%s,s=%s", tostring(protocol), tostring(sub_pro)))
  print("[NetSend]data=:", data)
  if data ~= nil then
    return netconn:send(data)
  else
    printLog("ERROR", "NetSend data == nil.")
    dump(param, "param")
    dump(protocol, "protocol")
    dump(sub_pro, "sub_pro")
    print([[


]])
  end
end
function NetSendExt(packList)
  local data = json.encode(packList)
  print(string.format("[PROTOCOL]SendExt:p=%s", tostring(packList[1])))
  print("[NetSendExt]data=:", data)
  if data ~= nil then
    return netconn:send(data)
  else
    printLog("ERROR", "NetSendExt data == nil.")
    dump(param, "param")
    dump(protocol, "protocol")
    dump(sub_pro, "sub_pro")
    print([[


]])
  end
end
