local Lplus = require("Lplus")
local ECUniSDk = require("ProxySDK.ECUniSDK")
local ECGame = Lplus.ForwardDeclare("ECGame")
local EFunSDK = Lplus.Extend(ECUniSDk, "EFunSDK")
local def = EFunSDK.define
def.const("table").INVITETYPE = {
  "efun_invite_fb",
  "efun_invite_vk",
  "efun_invite_kakao"
}
def.const("table").SHARETYPE = {
  FB = "EFUN_SHARE_FACEBOOK",
  TW = "EFUN_SHARE_TWITTER",
  KK = "EFUN_SHARE_KAKAO",
  VK = "EFUN_SHARE_VK",
  GG = "EFUN_SHARE_GOOGLE",
  WX = "EFUN_SHARE_WECHAT",
  BA = "EFUN_SHARE_BAHA",
  SK = "EFUN_SHARE_SKYPE"
}
def.field("table").m_UniSDKInfo = function()
  return {}
end
def.field("table").m_FBInfo = function()
  return {}
end
def.field("boolean").m_IsBindPhone = false
def.field("number").m_ShareType = 0
def.field("string").m_InvitableFBFriendIdString = ""
def.method("=>", "boolean").IsFBLogin = function(self)
  return self.m_FBInfo.Flag == "0"
end
def.method("number").SetShareType = function(self, shareType)
  self.m_ShareType = shareType
end
def.method("=>", "boolean").IsBindPhone = function(self)
  return self.m_IsBindPhone
end
def.method("table").ParseInvitableFBFriendIds = function(self, data)
  local ids = ""
  for _, v in pairs(data) do
    ids = ids .. v.id .. ","
  end
  self.m_InvitableFBFriendIdString = ids:sub(1, -2)
end
def.override("table", "table").onOtherAction = function(self, actionName, param)
  if actionName == "onInvitation" then
    self:onInvitation(param)
  elseif actionName == "onGetUserProfile" then
    self:onGetUserProfile(param)
  elseif actionName == "onRelateEfunAccountToThirdAccount" then
    self:onRelateEfunAccountToThirdAccount(param)
  elseif actionName == "onGetinviteFriends" then
    self:onGetinviteFriends(param)
  elseif actionName == "onFetchPlayingFriends" then
    self:onFetchPlayingFriends(param)
  elseif actionName == "onInviteFriends" then
    self:onInviteFriends(param)
  elseif actionName == "onCheckBindPhoneState" then
    self:onCheckBindPhoneState(param)
  elseif actionName == "onBindPhone" then
    self:onBindPhone(param)
  elseif actionName == "submitUserInfo" then
    self:onSubmitUserInfo(param)
  elseif actionName == "onUserCenter" then
    self:onUserCenter(param)
  elseif actionName == "onAdsWall" then
    self:onAdsWall(param)
  elseif actionName == "onShowNote" then
    self:onShowNote(param)
  else
    warn(actionName, " : ", pretty(param))
  end
end
def.override().onInit = function(self)
  ECUniSDk.onInit(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, function()
    self:ShowPlatform({})
  end)
end
def.override("table").onLogin = function(self, paramTable)
  ECUniSDk.onLogin(self, paramTable)
  self.m_UniSDKInfo.userId = paramTable.userId
  self:GetUserProfile({})
  self:CheckBindPhoneState({})
end
def.override("table").onLogout = function(self, paramTable)
  ECUniSDk.onLogout(self, "table")
  self.m_FBInfo = {}
end
def.method("table").ShowPlatform = function(self, paramTable)
  warn("EFunSDK, ShowPlatform")
  local heroProp = require("Main.Hero.Interface"):GetBasicHeroProp()
  local roleId = tostring(heroProp.id)
  local roleName = tostring(heroProp.name)
  local roleLevel = tostring(heroProp.level)
  local serverCode = tostring(require("netio.Network").m_zoneid)
  local param = {}
  param.serverCode = serverCode
  param.roleLevel = roleLevel
  param.roleName = roleName
  param.roleId = roleId
  param.remark = ""
  UniSDK.action("showPlatform", param)
end
def.method("table").SubmitUserInfo = function(self, paramTable)
  print("Lua submitUserInfo ... ...:", paramTable.infoType, " | ", paramTable.roleId, " | ", paramTable.roleName, " | ", paramTable.roleLv, " | ", paramTable.zoneId, " | ", paramTable.serverName)
  local param = {}
  param.infoType = paramTable.infoType or ""
  param.roleId = paramTable.roleId or ""
  param.roleName = paramTable.roleName or ""
  param.lv = paramTable.roleLv or ""
  param.zoneId = paramTable.zoneId or ""
  param.zoneName = paramTable.serverName or ""
  UniSDK.action("submitUserInfo", param)
end
def.method("table").onSubmitUserInfo = function(self, paramTable)
  print("OnSubmitUserInfo ... ...")
end
def.method("table").UserCenter = function(self, paramTable)
  print("Lua UserCenter ... ...:", paramTable.roleId, " | ", paramTable.roleName, " | ", paramTable.roleLv, " | ", paramTable.userId, " | ", paramTable.zoneId, " | ", paramTable.serverName)
  local param = {}
  param.userId = paramTable.userId or ""
  param.roleId = paramTable.roleId or ""
  param.level = paramTable.roleLv or ""
  param.roleName = paramTable.roleName or ""
  param.serverId = paramTable.zoneId or ""
  param.serverName = paramTable.serverName or ""
  UniSDK.action("userCenter", param)
end
def.method("table").onUserCenter = function(self, paramTable)
  self.m_IsLogin = false
  local SystemSettingModule = require("Main.SystemSetting.SystemSettingModule")
  SystemSettingModule.Instance():SwitchAccount()
end
def.method("table").AdsWall = function(self, paramTable)
  UniSDK.action("adsWall", {})
end
def.method("table").onAdsWall = function(self, paramTable)
end
def.method("table").ShowNote = function(self, paramTable)
  UniSDK.action("showNote", {})
end
def.method("table").onShowNote = function(self, paramTable)
  self:Login({})
end
def.method("table").Invitation = function(self, paramTable)
  local hp = ECGame.Instance().m_HostPlayer
  if hp == nil then
    return
  end
  local roleId = LuaUInt64.ToString(hp.ID)
  local roleName = hp.InfoData.Name
  local serverId = ECGame.Instance().m_ZoneID
  local userId = self.m_UniSDKInfo.userId
  local param = {}
  param.type = EFunSDK.INVITETYPE[1]
  param.userId = userId
  param.roleId = roleId
  param.serverId = serverId
  param.roleName = roleName
  param.icon = "180.png"
  UniSDK.action("invitation", param)
end
def.method("table").onInvitation = function(self, paramTable)
end
def.override("table").Share = function(self, paramTable)
  local param = {}
  local shareLinkURL = "https://fantasy.efuntw.com"
  local picture = "https://image-download.vsplay.com/2017-03-15/1489556456384_image.jpg"
  local localPic = paramTable.localPic or ""
  local name = paramTable.name or textRes.RelationShipChain[64]
  local caption = paramTable.caption or textRes.RelationShipChain[65]
  local shareDesc = paramTable.shareDesc or textRes.RelationShipChain[66]
  local shareType = paramTable.type or EFunSDK.SHARETYPE.FB
  param.link = shareLinkURL
  param.picture = picture
  param.localPic = localPic
  param.name = name
  param.caption = caption
  param.description = shareDesc
  param.shareType = shareType
  warn("EFunSDK share  ", localPic)
  UniSDK.action("share", param)
end
def.override("table").onShare = function(self, paramTable)
  warn("EFunSDK OnShare", paramTable.flag, paramTable.msg)
  if paramTable.flag == "0" then
    local UseType = require("consts.mzm.gsp.giftaward.confbean.UseType")
    Debug.LogWarning("ECMSDK OnShare  ShareType: " .. self.m_ShareType)
    if self.m_ShareType == UseType.SHARE_AWARD then
      local GiftAwardMgr = require("Main.Award.mgr.GiftAwardMgr")
      GiftAwardMgr.Instance():DrawAward(UseType.SHARE_AWARD)
      self.m_ShareType = 0
      GameUtil.AddGlobalTimer(1, true, function()
        Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_InfoChanged, {
          require("Main.RelationShipChain.RelationShipChainMgr").SHAREACTIVIEID
        })
      end)
    end
  end
end
def.method("table").GetUserProfile = function(self, paramTable)
  local width = "300"
  local height = "300"
  local param = {}
  param.width = width
  param.height = height
  UniSDK.action("getUserProfile", param)
end
def.method("table").onGetUserProfile = function(self, paramTable)
  warn("EFunSDK OnGetUserProfile :", paramTable.Flag, paramTable.Msg, paramTable.FBuid, paramTable.FBiconUrl, "~~~", paramTable.LoginType)
  self.m_FBInfo = paramTable
end
def.method("table").RelateEfunAccountToThirdAccount = function(self, paramTable)
  local userId = require("Main.ECGame").Instance().m_UserName
  local param = {}
  param.userId = userId
  UniSDK.action("relateEfunAccountToThirdAccount", param)
end
def.method("table").onRelateEfunAccountToThirdAccount = function(self, paramTable)
  warn("EFunSDK OnRelateEfunAccountToThirdAccount :", paramTable.Flag)
end
def.method("table").GetinviteFriends = function(self, paramTable)
  UniSDK.action("getinviteFriends", param)
end
def.method("table").onGetinviteFriends = function(self, paramTable)
  warn("EFunSDK onGetinviteFriends :", paramTable.Flag)
  if paramTable.Flag == "0" then
    local json = require("Utility.json")
    self:ParseInvitableFBFriendIds(json.decode(paramTable.data))
  end
end
def.method("table").FetchPlayingFriends = function(self, paramTable)
  UniSDK.action("fetchPlayingFriends", param)
end
def.method("table").onFetchPlayingFriends = function(self, paramTable)
  warn("EFunSDK OnFetchPlayingFriends :", paramTable.Flag)
  if paramTable.Flag == "0" then
    local json = require("Utility.json")
    local data = json.decode(paramTable.data)
    Event.DispatchEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.FetchFBFriends, {info = data})
  end
end
def.method("table").InviteFriends = function(self, paramTable)
  local heroProp = require("Main.Hero.Interface"):GetBasicHeroProp()
  local roleId = tostring(heroProp.id)
  local roleName = heroProp.name
  local level = tostring(heroProp.level)
  local serverCode = tostring(require("netio.Network").m_zoneid)
  local param = {}
  param.friendIds = paramTable.friendIds or self.m_InvitableFBFriendIdString
  param.userId = self.m_UniSDKInfo.userId
  param.roleId = roleId
  param.roleName = roleName
  param.serverCode = serverCode
  param.roleLevel = level
  warn("EFunSDK InviteFriends ~~~~~~~~~~~~~~~~~~~~", self.m_UniSDKInfo.userId, " ", roleId, "  ", roleName, " ", serverCode, " ", level)
  UniSDK.action("invitation", param)
end
def.method("table").onInviteFriends = function(self, paramTable)
  warn("EFunSDK onInviteFriends :", paramTable.Flag)
  if paramTable.Flag == 0 then
    warn("onInviteFriends", paramTable.InviteList)
  end
end
def.method("table").TrackUserData = function(self, paramTable)
end
def.method("table").TrackServerData = function(self, paramTable)
end
def.method("table").CheckBindPhoneState = function(self, paramTable)
  warn("EFunSDK CheckBindPhoneState")
  local param = {}
  UniSDK.action("checkBindPhoneState", param)
end
def.method("table").onCheckBindPhoneState = function(self, paramTable)
  warn("EFunSDK OnCheckBindPhoneState", paramTable.state)
  self.m_IsBindPhone = paramTable.state ~= "NOT_BIND"
end
def.method("table").BindPhone = function(self, paramTable)
  warn("EFunSDK bindPhone")
  local param = {}
  UniSDK.action("bindPhone", param)
end
def.method("table").onBindPhone = function(self, paramTable)
  warn("EFunSDK OnBindPhone", paramTable.Flag)
  self.m_IsBindPhone = paramTable.Flag == "0"
  if paramTable.Flag == "0" then
    Toast(textRes.RelationShipChain[70])
  end
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.AWARD.EFUN_BIND_PHONE_AWARD, nil)
end
def.method("table").CustomerService = function(self, paramTable)
  warn("EFunSDK customerService")
  UniSDK.action("customerService", param)
end
EFunSDK.Commit()
return EFunSDK
