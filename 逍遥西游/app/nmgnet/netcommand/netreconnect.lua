local netreconnect = {}
function netreconnect.heartbeatToClient(param, ptc_main, ptc_sub)
  if g_NetConnectMgr then
    local n = param.n
    g_NetConnectMgr:getHeartbeatFromSvr(n)
  end
end
function netreconnect.pingToClientOnEnterBackground(param, ptc_main, ptc_sub)
  local time = param.i_time
  if g_NetConnectMgr then
    g_NetConnectMgr:getPingFromSvr(time)
  end
end
return netreconnect
