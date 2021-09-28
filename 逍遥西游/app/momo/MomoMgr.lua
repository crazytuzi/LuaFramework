local MomoMgr = class("MomoMgr")
function MomoMgr:ctor()
  self.msg_func = {
    [1] = self.msg_login_succeed,
    [2] = self.msg_login_failed,
    [3] = self.msg_logout_succeed,
    [10] = self.msg_login_view_closed,
    [4] = self.msg_token_invalid,
    [5] = self.msg_user_bind_phone,
    [13] = self.msg_get_friend_failed,
    [14] = self.msg_get_friend_succeed
  }
  self.m_userID = nil
  self.m_token = nil
  self.m_userType = nil
  self.m_UserInfo = nil
  local uId = getMomoUserId()
  print("uId = ", uId)
  if uId then
    self.m_userID = uId
  end
  self.m_Friends = nil
end
function MomoMgr:getAccountInfo()
  return self.m_userID, self.m_token, self.m_userType
end
function MomoMgr:setUserIDToNil()
  self.m_userID = nil
  setMomoUserId(self.m_userID)
end
function MomoMgr:MessageCallBack(data, isSucceed)
  if data == nil then
    printLog("ERROR", "回调参数出错")
    return
  end
  local typ = data.type
  local param = data.param
  dump(data, "data")
  print(string.format([[

-------------------------------------
 MomoMgr:MessageCallBack:%s,%s
]], tostring(typ), tostring(param)))
  typ = tonumber(typ)
  local func = self.msg_func[typ]
  if func then
    func(self, param, typ)
  end
end
function MomoMgr:msg_login_succeed(param, typ)
  print([[

	----------->> msg_login_succeed ]])
  dump(param, "param")
  local userInfo = param.user or {}
  self.m_userID = userInfo.userID
  self.m_userType = userInfo.userType
  self.m_token = param.token
  self.m_UserInfo = userInfo
  dump(userInfo, "userInfo")
  dump(self.m_userID, "self.m_userID")
  if self.m_userID then
    setMomoUserId(self.m_userID)
  end
  SendMessage(MsgID_Momo_LoginSucceed)
end
function MomoMgr:msg_login_failed(param, typ)
  print([[

	----------->> msg_login_failed ]])
  self:setUserIDToNil()
  SendMessage(MsgID_Momo_LoginFailed, param.errorCode, param.errorMsg)
end
function MomoMgr:msg_logout_succeed(param, typ)
  print([[

	----------->> msg_logout_succeed ]])
  self:setUserIDToNil()
  SendMessage(MsgID_Momo_LogoutSucceed)
end
function MomoMgr:msg_login_view_closed(param, typ)
  print([[

	----------->> msg_login_view_closed ]])
  SendMessage(MsgID_Momo_LoginViewClosed)
end
function MomoMgr:msg_token_invalid(param, typ)
  print([[

	----------->> msg_token_invalid ]])
  self:setUserIDToNil()
  SendMessage(MsgID_Momo_TokenInvalid)
end
function MomoMgr:msg_user_bind_phone(param, typ)
  print([[

	----------->> msg_user_bind_phone ]])
  self.m_userType = MDKUserTypeQuickLoginBound
  SendMessage(MsgID_Momo_BindPhone)
end
function MomoMgr:msg_get_friend_failed(param, typ)
  print([[

	----------->> msg_get_friend_failed ]])
end
function MomoMgr:msg_get_friend_succeed(param, typ)
  print([[

	----------->> msg_get_friend_succeed ]])
  dump(param, "param")
  self.m_Friends = param
end
function MomoMgr:getCacheAuthInfo()
  return nil
end
function MomoMgr:setAutoAuthInfo(token, userType)
  self.m_userType = userType
  self.m_token = token
end
function MomoMgr:login()
end
function MomoMgr:logout()
  return MomoInter.logoutMomo()
end
function MomoMgr:setGameServer(gameServer)
  return MomoInter.setGameServer(gameServer)
end
function MomoMgr:setShowMomoLogo(isShow, showPlace)
  return MomoInter.setShowMomoLogo(isShow, showPlace)
end
function MomoMgr:showPersonalCenter()
  return MomoInter.showPersonalCenter()
end
function MomoMgr:getPersonalInfo(userID)
  if userID == nil then
    MomoInter.getLocalPersonalInfo()
  else
    MomoInter.getOtherPersonalInfo(userID)
  end
end
function MomoMgr:launchToUserProfile(userID)
  return MomoInter.launchToUserProfile(userID)
end
function MomoMgr:getFriendList()
  return MomoInter.getFriendList()
end
function MomoMgr:showFAQView()
  return MomoInter.showFAQView()
end
function MomoMgr:launchToTieba()
  return MomoInter.launchToTieba()
end
function MomoMgr:Clear()
end
g_MomoMgr = MomoMgr.new()
gamereset.registerResetFunc(function()
  g_MomoMgr = MomoMgr.new()
end)
