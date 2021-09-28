local login = {}
function login.register(param, ptc_main, ptc_sub)
  print("register:", param, ptc_main, ptc_sub)
  g_DataMgr:RegisterResult(param.i_rs == 1, param.s_info)
end
function login.logincheck(param, ptc_main, ptc_sub)
  print("logincheck:", param, ptc_main, ptc_sub)
  local result = param.i_rs
  g_DataMgr:LoginResult(result)
end
function login.roleinfo(param, ptc_main, ptc_sub)
  print("login.roleinfo:", param, ptc_main, ptc_sub)
  local i_num = param.i_num
  local t_roles = param.t_roles
  g_DataMgr:getRoleInfoFromSvr(i_num, t_roles)
end
function login.addRole(param, ptc_main, ptc_sub)
  print("login.addRole:", param, ptc_main, ptc_sub)
  param.s_name = CheckStringIsLegal(param.s_name, true, REPLACECHAR_FOR_INVALIDNAME)
  g_DataMgr:addRole(param.i_roleid, param.i_rtype, param.s_name, true)
  g_ChannelMgr:CreateRoleSucceed(param.i_roleid, param.i_rtype, param.s_name)
end
function login.StartGame(param, ptc_main, ptc_sub)
  print("login.StartGame:", param, ptc_main, ptc_sub)
  local mapId = param.i_map
  local posType, pos
  if param.t_loc then
    posType = MapPosType_PixelPos
    pos = param.t_loc
  else
    posType = MapPosType_EditorGrid
    pos = param.t_initloc
  end
  g_DataMgr:GameLoginFinish(mapId, pos, posType)
end
function login.sendFinished(param, ptc_main, ptc_sub)
  BangPaiLogFlag = true
  g_DataMgr:getAllRolesInfoFinishedWhenLogin()
  if g_BpMgr:localPlayerHasBangPai() then
    g_BpMgr:send_getTodayBpPaoShangTimes()
  end
  g_ChannelMgr:enterGame()
end
function login.loginReplaced(param, ptc_main, ptc_sub)
  print("login.loginReplaced:", param, ptc_main, ptc_sub)
  g_NetConnectMgr:loginReplaced()
end
function login.enterResult(param, ptc_main, ptc_sub)
  print("login.enterResult:", param, ptc_main, ptc_sub)
  local t, msg, title
  if param then
    t = param.i_rs
    msg = param.s_msg
    title = param.s_title
  end
  local loginAccount = param.s_at or ""
  g_DataMgr:setServerLoginAccount(loginAccount)
  g_NetConnectMgr:loginResult(t, msg, title)
  if g_ChannelMgr and g_ChannelMgr.momoDCLoginByPro then
    g_ChannelMgr:momoDCLoginByPro(loginAccount)
  end
end
function login.enterRoleResult(param, ptc_main, ptc_sub)
  print("login.enterRoleResult:", param, ptc_main, ptc_sub)
  local closeNetFlag = false
  if param.i_r == nil then
    ShowNotifyTips("登录出错")
    closeNetFlag = true
  elseif param.i_r == 1 then
    print("正常登录~~,直接无视")
  elseif param.i_r == 2 then
    ShowNotifyTips("角色ID错误，登录失败")
    closeNetFlag = true
  elseif param.i_r == 3 then
    local serName = g_DataMgr:getLoginServerName()
    local num = param.i_n
    local time = param.i_t
    ShowPaiDuiView(time, num, serName)
    if LoginGame.Ins then
      LoginGame.Ins:HideWaitingView()
    end
  elseif param.i_r == 6 then
    local msg = param.s_msg
    if msg == nil or type(msg) ~= "string" then
      msg = "登录过程发生了异常，请重新登录"
    end
    device.showAlert("登录失败", msg, {"确定"}, function()
      if g_DataMgr then
        g_DataMgr:returnToLoginView()
      end
    end)
    closeNetFlag = true
  end
  if closeNetFlag then
    g_NetConnectMgr:CloseConnect()
    if LoginGame.Ins then
      LoginGame.Ins:HideWaitingView()
    end
  end
end
function login.nameCheckResult(param, ptc_main, ptc_sub)
  local seed = param.seed
  if seed ~= nil and type(seed) == "number" then
    print("======>>>>服务器返回随机种子:", seed)
    math.randomseed(seed)
  end
end
function login.reflushGame(param, ptc_main, ptc_sub)
  print("login.reflushGame:", param, ptc_main, ptc_sub)
  print("======>> 强制重启游戏，回到登录界面!")
  g_DataMgr:returnToLoginView()
end
function login.netErrorMsg(param, ptc_main, ptc_sub)
  print("login.netErrorMsg:", param, ptc_main, ptc_sub)
  local msg = param.s_msg or "检查到您有可能使用了辅助工具导致数据异常"
  g_NetConnectMgr:onGameError(msg)
end
function login.momoPlayerRoleInfo(param, ptc_main, ptc_sub)
  print("login.momoPlayerRoleInfo:", param, ptc_main, ptc_sub)
  if param and g_FriendsDlg then
    if param.t_l ~= nil then
      for _, data in pairs(param.t_l) do
        data.name = CheckStringIsLegal(data.name, true, REPLACECHAR_FOR_INVALIDNAME)
      end
    end
    g_FriendsDlg:setMoMoPlayerRoleInfo(param.userid, param.t_l)
  end
end
function login.getPayOrderId(param, ptc_main, ptc_sub)
  print("[reqPayOrderId]login.getPayOrderId:", param, ptc_main, ptc_sub)
  local cbid
  if param then
    cbid = param.cbid
  end
  g_ChannelMgr:reqPayOrderIdResult(cbid)
end
function login.getMoMoPlayerInviteTimes(param, ptc_main, ptc_sub)
  print("[reqPayOrderId]login.getMoMoPlayerInviteTimes:", param, ptc_main, ptc_sub)
  if param then
    if param.cnt ~= nil and param.cnt >= 1 then
      ShowNotifyTips("今天已邀请过该陌陌好友")
    elseif param.userid then
      g_ChannelMgr:shareToUser(param.userid, function(isSucceed)
        if isSucceed then
          ShowNotifyTips("您已向陌陌好友发出了邀请")
          netsend.login.setMoMoPlayerInviteTimes(param.userid, 1)
        end
      end, "[缘定星辰]我邀请你一起来玩游戏，来试试。")
    end
  end
end
function login.createRoleFailed(param, ptc_main, ptc_sub)
  if g_NetConnectMgr then
    g_NetConnectMgr:deleteLoadingLayer()
  end
end
function login.sendStart(param, ptc_main, ptc_sub)
  local lastUDID = param.i_udid or 0
  print("login.sendStart:", lastUDID, device.getOpenUDID())
  g_DataMgr:getAllRolesInfoStartWhenLogin(lastUDID)
end
function login.paySuccess(param, ptc_main, ptc_sub)
  print(" login.PaySuccess:", param, ptc_main, ptc_sub)
  if g_ChannelMgr then
    g_ChannelMgr:channelPaySuccess(param)
  end
end
return login
