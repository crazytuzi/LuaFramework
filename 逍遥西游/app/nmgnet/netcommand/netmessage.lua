local netmessage = {}
function netmessage.privateMessage(param, ptc_main, ptc_sub)
  print("netmessage.privateMessage:", param, ptc_main, ptc_sub)
  local pid = param.i_pid
  local msg = CheckStringIsLegal(param.s_msg, true, REPLACECHAR_FOR_INVALIDMSG)
  local yy = param.yy
  local vip = param.vip
  g_MessageMgr:receivePrivateMessage(pid, pid, msg, yy, vip)
end
function netmessage.teamMessage(param, ptc_main, ptc_sub)
  print("netmessage.teamMessage:", param, ptc_main, ptc_sub)
  local pid = param.i_pid
  local msg = CheckStringIsLegal(param.s_msg, true, REPLACECHAR_FOR_INVALIDMSG)
  local yy = param.yy
  local vip = param.vip
  g_MessageMgr:receiveTeamMessage(pid, msg, yy, vip)
end
function netmessage.worldMessage(param, ptc_main, ptc_sub)
  print("netmessage.worldMessage:", param, ptc_main, ptc_sub)
  local pid = param.i_pid
  local pInfo = {}
  pInfo.rtype = param.i_typeid
  pInfo.name = CheckStringIsLegal(param.s_name, true, REPLACECHAR_FOR_INVALIDNAME)
  pInfo.zs = param.i_zs
  pInfo.level = param.i_level
  local msg = CheckStringIsLegal(param.s_msg, true, REPLACECHAR_FOR_INVALIDMSG)
  local yy = param.yy
  local vip = param.vip
  g_MessageMgr:receiveWorldMessage(pid, pInfo, msg, yy, vip)
end
function netmessage.worldMessageDisabled(param, ptc_main, ptc_sub)
  print("netmessage.worldMessageDisabled:", param, ptc_main, ptc_sub)
end
function netmessage.sysMessage(param, ptc_main, ptc_sub)
  print("netmessage.sysMessage:", param, ptc_main, ptc_sub)
  param.s_msg = CheckStringIsLegal(param.s_msg, true, REPLACECHAR_FOR_INVALIDMSG)
  g_MessageMgr:receiveSysMessage(param.s_msg)
end
function netmessage.bangpaiMessage(param, ptc_main, ptc_sub)
  print("netmessage.bangpaiMessage:", param, ptc_main, ptc_sub)
  if param.msgs ~= nil then
    for _, data in pairs(param.msgs) do
      data.msg = CheckStringIsLegal(data.msg, true, REPLACECHAR_FOR_INVALIDMSG)
      data.name = CheckStringIsLegal(data.name, true, REPLACECHAR_FOR_INVALIDNAME)
    end
  end
  g_MessageMgr:receiveBpMessage(param.msgs)
end
function netmessage.wolrdMessageRestTime(param, ptc_main, ptc_sub)
  print("netmessage.wolrdMessageRestTime:", param, ptc_main, ptc_sub)
  g_MessageMgr:OnWolrdMessageRestTime(param.i_cd)
end
function netmessage.bangpaiMessageRestTime(param, ptc_main, ptc_sub)
  print("netmessage.bangpaiMessageRestTime:", param, ptc_main, ptc_sub)
  g_MessageMgr:OnBangpaiMessageRestTime(param.i_cd)
end
function netmessage.KuaixunMessage(param, ptc_main, ptc_sub)
  print("netmessage.KuaixunMessage:", param, ptc_main, ptc_sub)
  if param.s_msg == nil then
  else
    param.s_msg = CheckStringIsLegal(param.s_msg, true, REPLACECHAR_FOR_INVALIDMSG)
    g_MessageMgr:receiveKuaixunMessage(param.s_msg)
  end
end
function netmessage.PersonXinxiMessage(param, ptc_main, ptc_sub)
  print("netmessage.PersonXinxiMessage:", param, ptc_main, ptc_sub)
  if param.s_msg == nil then
  else
    param.s_msg = CheckStringIsLegal(param.s_msg, true, REPLACECHAR_FOR_INVALIDMSG)
    g_MessageMgr:receivePersonXinxiMessage(param.s_msg)
  end
end
function netmessage.localLeaveWord(param, ptc_main, ptc_sub)
  param.msg = CheckStringIsLegal(param.msg, true, REPLACECHAR_FOR_INVALIDMSG)
  g_MessageMgr:getLocalLeaveWord(param.msg)
end
function netmessage.randomLeaveWord(param, ptc_main, ptc_sub)
  if param.lst ~= nil then
    for _, data in pairs(param.lst) do
      data.name = CheckStringIsLegal(data.name, true, REPLACECHAR_FOR_INVALIDNAME)
      data.msg = CheckStringIsLegal(data.msg, true, REPLACECHAR_FOR_INVALIDMSG)
    end
  end
  g_MessageMgr:getRandomLeaveWord(param.lst)
end
function netmessage.localMessage(param, ptc_main, ptc_sub)
  print("netmessage.localMessage:", param, ptc_main, ptc_sub)
  local pid = param.i_pid
  local pInfo = {}
  pInfo.rtype = param.i_typeid
  pInfo.name = CheckStringIsLegal(param.s_name, true, REPLACECHAR_FOR_INVALIDNAME)
  pInfo.zs = param.i_zs
  pInfo.level = param.i_level
  local msg = CheckStringIsLegal(param.s_msg, true, REPLACECHAR_FOR_INVALIDMSG)
  local yy = param.yy
  local vip = param.vip
  g_MessageMgr:receiveLocalMessage(pid, pInfo, msg, yy, vip)
end
function netmessage.localMessageRestTime(param, ptc_main, ptc_sub)
  print("netmessage.localMessageRestTime:", param, ptc_main, ptc_sub)
  g_MessageMgr:OnLocalMessageRestTime(param.i_cd)
end
function netmessage.localChannelSysMessage(param, ptc_main, ptc_sub)
  print("netmessage.localChannelSysMessage:", param, ptc_main, ptc_sub)
  param.s_msg = CheckStringIsLegal(param.s_msg, true, REPLACECHAR_FOR_INVALIDMSG)
  g_MessageMgr:receiveLocalChannelSysMessage(param.s_msg, param.npcId)
end
function netmessage.receiveLaBaMsg(param, ptc_main, ptc_sub)
  print(" netmessage.receiveLaBaMsg   ===>>>> 2222222222  ")
  local pid = param.i_pid
  local pInfo = {}
  pInfo.rtype = param.i_typeid
  pInfo.name = CheckStringIsLegal(param.s_name, true, REPLACECHAR_FOR_INVALIDNAME)
  pInfo.zs = param.i_zs
  pInfo.level = param.i_level
  local yy = param.yy
  local vip = param.vip
  local msg = CheckStringIsLegal(param.s_msg, true, REPLACECHAR_FOR_INVALIDMSG)
  msg = filterChatText_DFAFilter(msg)
  if g_LBMgr then
    g_LBMgr:addOneMsg(pid, pInfo, msg, yy, vip)
  end
end
function netmessage.reflushLaBaConfig(param, ptc_main, ptc_sub)
  param = param or {}
  dump(param, "111111 ")
  if g_LBMgr then
    g_LBMgr:flushLocalCD(param.i_cd)
  end
end
return netmessage
