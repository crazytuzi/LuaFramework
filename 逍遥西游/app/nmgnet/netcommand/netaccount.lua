local netaccount = {}
function netaccount.registerNmgResult(param, ptc_main, ptc_sub)
  print("netaccount.registerNmgResult:", param, ptc_main, ptc_sub)
  if param then
    g_DataMgr:RegisterDataServerResult(param.i_rs, param.s_info)
  end
end
function netaccount.loginResult(param, ptc_main, ptc_sub)
  print("netaccount.loginResult:", param, ptc_main, ptc_sub)
  if param then
    g_DataMgr:LoginResultByDataServer(param.i_type, param.i_rs, param.s_msg, param.s_token, param.t_cb)
  end
end
function netaccount.serverList(param, ptc_main, ptc_sub)
  print("netaccount.serverList:", param, ptc_main, ptc_sub)
  if param then
    dump(param, "param")
    g_DataMgr:HadGetServerList(param.t_l)
  end
end
function netaccount.serverRoles(param, ptc_main, ptc_sub)
  print("netaccount.serverRoles:", param, ptc_main, ptc_sub)
  if param then
    g_DataMgr:HadGetServerRoles(param.t_l)
  end
end
function netaccount.loginNotice(param, ptc_main, ptc_sub)
  print("netaccount.loginNotice:", param, ptc_main, ptc_sub)
  if param then
    print("收到登录公告内容:", param.i_i, param.title, param.s_t)
    if LoginGame.Ins then
      LoginGame.Ins:ShowLoginNotice(param.i_i, param.title, param.s_t)
    end
    _saveLoginNoticeCache(param.i_i, param.title, param.s_t)
  end
end
return netaccount
