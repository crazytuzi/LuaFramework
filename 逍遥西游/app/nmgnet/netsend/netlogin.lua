local login = {}
function login.register(s_account, s_pwd)
  NetSend({s_account = s_account, s_pwd = s_pwd}, "login", "P1")
end
function login.login(s_account, s_pwd)
  NetSend({s_account = s_account, s_pwd = s_pwd}, "login", "P2")
end
function login.createHero(i_rtype, s_name, i_index, rn, ed)
  NetSend({
    i_rtype = i_rtype,
    s_name = s_name,
    i_udid = device.getOpenUDID(),
    i_i = i_index,
    rn = rn,
    ed = ed
  }, "login", "P3")
end
function login.EnterRole(i_roleid, i_syncType, s_deviceType)
  if g_MissionMgr then
    g_MissionMgr:clearAcceptedMission()
  end
  local reconnect
  if g_DataMgr:IsInGame() then
    reconnect = 1
  end
  NetSend({
    i_roleid = i_roleid,
    i_udid = device.getOpenUDID(),
    i_flag = reconnect,
    i_i = i_syncType,
    s_dt = s_deviceType,
    i_pg = channel.payGroupId
  }, "login", "P4")
end
function login.reqEnter(s_token, t_cb)
  local ver = GetVersionStr()
  if not channel.needUpdate then
    ver = "999.999.999"
  end
  NetSend({
    s_token = s_token,
    s_ver = ver,
    t_cb = t_cb
  }, "login", "P5")
end
function login.queryMoMoPlayerRoleInfo(s_gf, s_userid)
  NetSend({gf = s_gf, userid = s_userid}, "login", "P15")
end
function login.reqPayOrderId(cbinfo)
  print("[reqPayOrderId]netaccount.reqPayOrderId:", cbinfo)
  NetSend({cbinfo = cbinfo}, "login", "P16")
end
function login.queryMoMoPlayerInviteTimes(s_userid)
  NetSend({userid = s_userid}, "login", "P17")
end
function login.setMoMoPlayerInviteTimes(s_userid, cnt)
  NetSend({userid = s_userid, cnt = cnt}, "login", "P18")
end
return login
