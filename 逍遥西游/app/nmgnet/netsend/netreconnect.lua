local netreconnect = {}
function netreconnect.heartbeatToSvr(n)
  local i_t
  if g_DataMgr and g_DataMgr.m_LocalTime ~= nil and g_DataMgr.m_LocalTime ~= 0 then
    i_t = math.floor(g_DataMgr:getServerTime())
  end
  NetSend({n = n, i_t = i_t}, S2C_ReConnect, "P1")
end
function netreconnect.pingToSvrOnEnterBackground()
  local ver = GetVersionStr()
  if not channel.needUpdate then
    ver = "999.999.999"
  end
  NetSend({ver = ver}, S2C_ReConnect, "P2")
end
return netreconnect
