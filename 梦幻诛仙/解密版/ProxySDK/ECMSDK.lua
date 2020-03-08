local Lplus = require("Lplus")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local Network = require("netio.Network")
local UpdateNoticeModule = Lplus.ForwardDeclare("UpdateNoticeModule")
local DlgLogin = Lplus.ForwardDeclare("DlgLogin")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ECMSDK = Lplus.Class("ECMSDK")
local def = ECMSDK.define
def.field("boolean").m_IsLogin = false
def.field("boolean").m_IsGuest = false
def.field("boolean").m_IsGSDKInit = false
def.field("boolean").m_CanReconnect = false
def.field("boolean").m_MonthItemTip = false
def.field("table").m_PayQQVIPInfo = nil
def.field("number").m_Platform = 0
def.field("number").m_ShareType = 0
def.field("string").m_CombineAppID = "1"
def.field("table").m_MSDKInfo = function()
  return {}
end
def.field("table").m_MyInfo = function()
  return {}
end
def.field("table").m_NotifyInfo = function()
  return {}
end
def.field("table").m_CallBack = function()
  return {}
end
def.field("userdata").m_TssSDKGO = nil
def.field("boolean").m_IsReqPermission = false
def.const("table").LOGINPRIVILEGETYPE = {
  NON = 0,
  QQ = 1,
  WX = 2,
  YYB = 3
}
def.const("table").OFFERID = {Android = 1450006969, iOS = 1450007099}
def.const("table").APPID = {
  QQ = "1105218881",
  WX = "wx5450e72520b1f41e"
}
def.const("table").APPKEY = {
  QQ = "tnydta8t5nWjXquL",
  WX = "b1fae7d5268b9464926e289d4c364bd6"
}
def.const("table").AREAID = {QQ = 2, WX = 1}
def.const("table").ShareURL = {
  [1] = "http://gamecenter.qq.com",
  [2] = "http://gamecenter.qq.com/gamecenter/index/detail.html?appid=1105218881&pf=invite&plat=qq&from=%s&ADTAG=gameobj.msg_invite&originuin=%s",
  [3] = "http://game.weixin.qq.com/cgi-bin/h5/static/gamecenter/detail.html?appid=wx5450e72520b1f41e",
  [4] = "http://ossweb-img.qq.com/images/1213share.jpg",
  [5] = "http://imgcache.gtimg.cn/ACT/svip_act/act_img/v_xkhuang/201701/m1484126920_hyzhmz.jpg",
  [6] = "http://imgcache.qq.com/club/gamecenter/WebApi/giftbox/release/index/grap.html?actid=%s&_wv=1031&boxid=%s&appid=1105218881",
  [7] = "https://m.gamecenter.qq.com/directout/detail/1105218881?ver=0&uin=471897134&notShowPub=1&_wwv=4&indexShow=1&ADTAG=gameobj.msg_invite&appid=1105218881&logicId=0&asyncMode=3&pf=invite&originuin=%s&from=%s",
  [8] = "https://game.weixin.qq.com/cgi-bin/h5/static/gamecenter/detail.html?appid=wx5450e72520b1f41e",
  [9] = "http://ossweb-img.qq.com/images/mhzx_share_anniversary.png"
}
def.const("string").LogoURL = "http://ossweb-img.qq.com/images/chanpin/9/amosguo/mzLogo100.png"
def.const("string").LogoURL2 = "https://ossweb-img.qq.com/images/chanpin/9/amosguo/mzLogo100.png"
def.const("table").GAMETAG = {
  QQ = {
    "MSG_INVITE",
    "MSG_FRIEND_EXCEED",
    "MSG_HEART_SEND",
    "MSG_SHARE_FRIEND_PVP",
    "MSG_FRIEND_RECALL_HYZH"
  },
  WX = {
    "MSG_INVITE",
    "MSG_friend_exceed",
    "MSG_heart_send",
    "MSG_SHARE_MOMENT_HIGH_SCORE",
    "MSG_FRIEND_RECALL_HYZH",
    "MSG_SHARE_MOMENT_BEST_SCORE",
    "MSG_SHARE_MOMENT_CROWN",
    "MSG_SHARE_FRIEND_HIGH_SCORE",
    "MSG_SHARE_FRIEND_BEST_SCORE",
    "MSG_SHARE_FRIEND_CROWN"
  }
}
def.const("table").NOTICETYPE = {
  eMSG_NOTICETYPE_ALERT = 0,
  eMSG_NOTICETYPE_SCROLL = 1,
  eMSG_NOTICETYPE_ALL = 2
}
def.const("table").NOTICE_CONTENT_TYPE = {
  eMSG_CONTENTTYPE_TEXT = 0,
  eMSG_CONTENTTYPE_PICTURE = 1,
  eMSG_CONTENTTYPE_WEB = 2
}
def.const("table").SCREENDIR = {
  SENSOR = 0,
  PORTRAIT = 1,
  LANDSCAPE = 2
}
def.const("table").PAYTYPE = {NORMAL = 1, MONTH = 2}
def.const("string").BEFOR_LOGIN_ALERT_SCENE = "1"
def.const("string").LOGIN_ALERT_SCENE = "2"
def.const("string").BEFOR_LOGIN_SCROLL_SCENE = "509"
def.const("string").LOGIN_SCROLL_SCENE = "511"
def.const("number").HTTPS_SUPPORT_VERSION = 110
def.const("table").UrlInnerEncodeVersions = {"2.16.5i"}
def.const("table").eFlag = {Succ = 0, WebviewClosed = 6001}
function _G.onTssSdkSendData(data)
  local s = data.string
  local HeroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  if HeroProp == nil then
    warn("Attemp to Send Tss SDk Data, but client doesn't have RoleId", debug.traceback())
    return
  end
  local roleid = HeroProp.id
  local protoMgr = require("netio.ProtocolManager")
  local secure_data = __NetIO_StringToOctets(s)
  local protoObj = require("netio.protocol.gnet.TencentSecureInfo").new(roleid, secure_data)
  protoMgr.sendProtocol(protoObj)
end
function _G.GetChannelID()
  if MSDK and MSDK.getChannelId then
    return MSDK.getChannelId()
  end
  return "1"
end
function _G.GetRegisterChannelID()
  if MSDK and MSDK.getRegisterChannelId then
    return MSDK.getRegisterChannelId()
  end
  return "2"
end
local instance
def.static("=>", ECMSDK).Instance = function()
  if not instance then
    instance = ECMSDK()
  end
  return instance
end
local _MSDKInfoValid = function(sdkInfo)
  return sdkInfo.offerId ~= nil and sdkInfo.openId ~= nil and sdkInfo.sessionId ~= nil and sdkInfo.sessionType ~= nil and sdkInfo.pf ~= nil and sdkInfo.pfKey ~= nil
end
local function SaveMSDKInfo(openId, pf, pfKey, accessToken, payToken, sessionId, sessionType)
  if openId then
    instance.m_MSDKInfo.openId = openId
  end
  if pf then
    instance.m_MSDKInfo.pf = pf
  end
  if pfKey then
    instance.m_MSDKInfo.pfKey = pfKey
  end
  if accessToken then
    instance.m_MSDKInfo.accessToken = accessToken
  end
  if payToken then
    instance.m_MSDKInfo.payToken = payToken
  end
  if sessionId then
    instance.m_MSDKInfo.sessionId = sessionId
  end
  if sessionType then
    instance.m_MSDKInfo.sessionType = sessionType
  end
  if LoginPlatform == MSDK_LOGIN_PLATFORM.QQ then
    instance.m_MSDKInfo.appId = ECMSDK.APPID.QQ
    instance.m_MSDKInfo.appKey = ECMSDK.APPKEY.QQ
    instance.m_MSDKInfo.areaId = ECMSDK.AREAID.QQ
  elseif LoginPlatform == MSDK_LOGIN_PLATFORM.WX then
    instance.m_MSDKInfo.appId = ECMSDK.APPID.WX
    instance.m_MSDKInfo.appKey = ECMSDK.APPKEY.WX
    instance.m_MSDKInfo.areaId = ECMSDK.AREAID.WX
  elseif LoginPlatform == MSDK_LOGIN_PLATFORM.GUEST then
    instance.m_MSDKInfo.appId = ECMSDK.APPID.QQ
    instance.m_MSDKInfo.appKey = ECMSDK.APPKEY.QQ
    instance.m_MSDKInfo.areaId = ECMSDK.AREAID.QQ
    if openId:sub(1, 3) == "G_wx" then
      instance.m_MSDKInfo.appId = ECMSDK.APPID.WX
      instance.m_MSDKInfo.appKey = ECMSDK.APPKEY.WX
      instance.m_MSDKInfo.areaId = ECMSDK.AREAID.WX
    end
  end
  if platform == 1 then
    instance.m_MSDKInfo.offerId = ECMSDK.OFFERID.iOS
  elseif platform == 2 then
    instance.m_MSDKInfo.offerId = ECMSDK.OFFERID.Android
  end
end
local function SaveMSDKInfoEx(media_tag_name, messageExt, extInfo)
  instance.m_MSDKInfo.mediaTagName = media_tag_name
  instance.m_MSDKInfo.messageExt = messageExt
  instance.m_MSDKInfo.extInfo = extInfo
end
local function GetMSDKInfoEX()
  return instance.m_MSDKInfo.mediaTagName, instance.m_MSDKInfo.messageExt, instance.m_MSDKInfo.extInfo
end
local function GetPayToken()
  local sdkInfo = instance.m_MSDKInfo
  return sdkInfo.payToken == "" and sdkInfo.accessToken or sdkInfo.payToken
end
local function ConfirmLogin(sender, retval)
  if retval == MsgBox.MsgBoxRetT.MBRT_OK then
    ECMSDK.SwitchUser(true)
  elseif retval == MsgBox.MsgBoxRetT.MBRT_CANCEL then
    ECMSDK.SwitchUser(false)
  end
end
local ClearReconnectTimes = function()
  local UserDataTable = UserData.Instance()
  local ReConnectTimes = UserDataTable:GetSystemCfg("ReConnectTimes") - 1
  if ReConnectTimes < 0 then
    ReConnectTimes = 0
  end
  UserDataTable:SetSystemCfg("ReConnectTimes", ReConnectTimes)
  UserData.Instance():SaveDataToFile()
end
def.method("number", "string", "string", "string", "string", "string").OnLoginSuccess = function(self, wakeup_platform, openId, pf, pfKey, accessToken, payToken)
  warn("Lua!!~~~~~~~~~~~~~\228\191\174\230\148\185\231\153\187\229\189\149\230\136\144\229\138\159 openid: ", openId, "\229\136\134\229\137\178 pf :", pf, "\229\136\134\229\137\178pfKey : ", pfKey, "\229\136\134\229\137\178 ACToken : ", accessToken, "\229\136\134\229\137\178 payToken : ", payToken)
  warn("accessToken:    ", accessToken, "paytoken :   ", paytoken)
  local game = ECGame.Instance()
  if game:GetGameState() == _G.GameState.GameWorld then
    warn("In Game World")
    return
  end
  if wakeup_platform == 0 then
    _G.LoginPlatform = MSDK.platform()
  else
    _G.LoginPlatform = wakeup_platform
  end
  if LoginPlatform == MSDK_LOGIN_PLATFORM.QQ then
    SaveMSDKInfo(openId, pf, pfKey, accessToken, payToken, "openid", "kp_actoken")
    local loginflag = _G.platform == 1 and "ios_qq" or "android_qq"
    local token = accessToken .. "$" .. payToken .. "$" .. pf .. "$" .. pfKey .. "$" .. loginflag
    game:SetUserName(openId .. "$" .. "qq", token, "", 0)
    self.m_CombineAppID = loginflag
  elseif LoginPlatform == MSDK_LOGIN_PLATFORM.WX then
    SaveMSDKInfo(openId, pf, pfKey, accessToken, payToken, "hy_gameid", "wc_actoken")
    local loginflag = _G.platform == 1 and "ios_wechat" or "android_wechat"
    local token = accessToken .. "$" .. pf .. "$" .. pfKey .. "$" .. loginflag
    game:SetUserName(openId .. "$" .. "wechat", token, "", 0)
    self.m_CombineAppID = loginflag
  elseif LoginPlatform == MSDK_LOGIN_PLATFORM.GUEST then
    SaveMSDKInfo(openId, pf, pfKey, accessToken, payToken, "hy_gameid", "st_dummy")
    local flag = "qq"
    local token = accessToken .. "$" .. accessToken .. "$" .. pf .. "$" .. pfKey .. "$" .. "G_"
    self.m_Platform = MSDK_LOGIN_PLATFORM.QQ
    if openId:sub(1, 3) == "G_wx" then
      flag = "wechat"
      token = accessToken .. "$" .. pf .. "$" .. pfKey .. "$" .. "G_"
      self.m_Platform = MSDK_LOGIN_PLATFORM.WX
    end
    token = token .. (_G.platform == 1 and "ios_" or "android_") .. flag
    game:SetUserName(openId .. "$" .. flag, token, "", 0)
    self.m_IsGuest = true
    self.m_CombineAppID = "G_" .. (_G.platform == 1 and "ios_" or "android_") .. flag
  elseif not LoginPlatform then
    Debug.LogError("There is no LoginPlatform    ")
  else
    Debug.LogError("Other LoginPlatform ................. " .. LoginPlatform)
  end
  ECMSDK.SetGSDKEvent(4, true, "success")
  ECMSDK.QueryMyInfo()
  ECMSDK.RegisterXG()
  local ECQQEC = require("ProxySDK.ECQQEC")
  ECQQEC.SetUserAccount()
  ECQQEC.UpdateUserAccount()
  ECMSDK.AuroraSdkOnLogin()
  DlgLogin.Instance():DestroyPanel()
  Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_SUCCESS, nil)
  self.m_IsLogin = true
  if self.m_IsReqPermission then
    self.m_IsReqPermission = false
    Toast(textRes.Login[66])
  end
end
def.method("number", "string", "string").OnLoginError = function(self, flag, desc, loginRet)
  local game = ECGame.Instance()
  self.m_CanReconnect = false
  warn("OnLoginError Flag:", flag, "|", game.m_inGameLogic, "~~~", desc)
  if flag == MSDK_LOGIN_ERROR_CODE.Local_Invalid then
    game:EnterLoginLogic()
  elseif flag == MSDK_LOGIN_ERROR_CODE.Net_Work_Err then
    CommonConfirmDlg.ShowConfirmCoundDown(textRes.Common[300], textRes.Common[301], "", "", 0, 0, function(selection, tag)
    end, nil)
  elseif flag == MSDK_LOGIN_ERROR_CODE.Not_Support_Api then
    CommonConfirmDlg.ShowConfirmCoundDown(textRes.Common[300], textRes.Common[302], "", "", 0, 0, function(selection, tag)
    end, nil)
  elseif flag == MSDK_LOGIN_ERROR_CODE.WX_NotSupportApi then
    CommonConfirmDlg.ShowConfirmCoundDown(textRes.Common[300], textRes.Common[303], "", "", 0, 0, function(selection, tag)
    end, nil)
  elseif flag == MSDK_LOGIN_ERROR_CODE.WX_AccessTokenExpired then
    ECMSDK.RefreshWXToken()
  elseif flag == MSDK_LOGIN_ERROR_CODE.QQ_UserCancel or flag == MSDK_LOGIN_ERROR_CODE.WX_UserCancel then
    Toast(textRes.Common[304])
    self.m_CanReconnect = true
  elseif flag == MSDK_LOGIN_ERROR_CODE.Need_Realname_Auth then
  end
  self.m_IsLogin = false
  ECMSDK.SetGSDKEvent(4, false, desc)
  Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_ERROR, {
    flag,
    desc,
    loginRet
  })
end
def.method("number", "string").OnRefreshWXToken = function(self, succ, wxAccessToken)
  local game = ECGame.Instance()
  warn("OnRefreshWXToken Flag:", succ, "|", wxAccessToken)
  if succ then
    if wxAccessToken == "" then
      local tokens = MSDK.getTokens()
      wxAccessToken = tokens[3]
    end
    SaveMSDKInfo(nil, nil, nil, wxAccessToken, wxAccessToken, nil, nil)
    local Octets = require("netio.Octets")
    local LoginUtility = require("Main.Login.LoginUtility")
    local reqData = {}
    reqData.appid = self.m_MSDKInfo.appId
    reqData.openkey = self.m_MSDKInfo.accessToken
    reqData.paytoken = self.m_MSDKInfo.paytoken or ""
    reqData.pf = self.m_MSDKInfo.pf
    reqData.pfkey = self.m_MSDKInfo.pfkey
    LoginUtility.DataToAuany(4, 2, reqData, 0, Octets.raw())
  end
end
def.method("number", "string", "number", "number", "number", "number", "string").OnPayCallback = function(self, retcode, msg, realSaveNum, payChannel, payState, provideState, extendInfo)
  warn("OnPayCallback", retcode, "\233\154\148", msg, "\233\154\148", realSaveNum, "\233\154\148", payChannel, "\233\154\148", payState, "\233\154\148", provideState, "\233\154\148", extendInfo)
  if retcode == MSDK_PAY_CODE.PAY_SUCCESS then
    ECMSDK.GetMarketInfo()
    local cb = self.m_CallBack.Pay
    if cb then
      cb()
    end
    if self.m_PayQQVIPInfo then
      local RelationShipChainMgr = require("Main.RelationShipChain.RelationShipChainMgr")
      RelationShipChainMgr.ReportQQVipPayInfo({
        vip_flag = self.m_PayQQVIPInfo.vip_flag,
        is_new = self.m_PayQQVIPInfo.is_new
      })
      self.m_PayQQVIPInfo = nil
    end
  end
  local PayModule = require("Main.Pay.PayModule")
  local payData = PayModule.Instance():GetPayTLogData()
  if payData then
    local params = {}
    local status = retcode == MSDK_PAY_CODE.PAY_SUCCESS and 1 or 2
    if payData.payParams.amount then
      params = {
        payData.payParams.amount,
        status
      }
    else
      params = {status}
    end
    ECMSDK.SendTLogToServer(payData.payType, params)
    PayModule:Instance():SetPayTLogData(_G.TLOGTYPE.NON, {})
  end
end
def.method("string", "table").OnNoticeInfo = function(self, scene, info)
  for k, v in pairs(info) do
    warn(k, "\230\160\135\233\162\152\239\188\154", v.msg_title)
    warn("ID\239\188\154", v.msg_id)
    warn("URL\239\188\154", v.msg_url)
    warn("OpenID\239\188\154", v.open_id)
    warn("msg_type\239\188\154", v.msg_type)
  end
  local title = info[1] and info[1].msg_title or "nodata"
  local content = info[1] and info[1].msg_content or "nodata"
  warn("\229\133\172\229\145\138\229\155\158\232\176\131", scene, title)
  self.m_NotifyInfo[scene] = info
  local cb = self.m_CallBack["NoticeCB" .. scene]
  if cb then
    cb(scene, info)
  end
end
def.method("table").OnRelationNotify = function(self, relationRet)
  warn("OnRelationNotify: ", relationRet.flag)
  if relationRet.flag == 0 then
    warn("Desc and ExtInfo: ", relationRet.desc, relationRet.extendInfo)
    if 0 < #relationRet.persons then
      self.m_MyInfo = relationRet.persons[1]
      warn("Save MyInfo", self.m_MyInfo.nickName)
    end
  end
end
def.method("table", "function").ShowNotice = function(self, info, onClose)
  local notices = {}
  for i, v in ipairs(info) do
    local notice = {}
    notice.title = v.msg_title
    notice.content = v.msg_content
    notice.url = v.msg_url
    table.insert(notices, notice)
  end
  UpdateNoticeModule.Instance():ShowNotice(notices, onClose)
end
def.method("table").ShowScrollNotice = function(self, info)
  local notices = {}
  for i, v in ipairs(info) do
    local notice = {}
    notice.title = v.msg_title
    notice.content = v.msg_content
    table.insert(notices, notice)
  end
  UpdateNoticeModule.Instance():ShowScrollNotice(notices)
end
local function SwitchAccount(platform)
  ECMSDK.UserLogOut()
  local SystemSettingModule = require("Main.SystemSetting.SystemSettingModule")
  SystemSettingModule.Instance():SwitchAccount()
  if platform ~= MSDK_LOGIN_PLATFORM.NON then
    GameUtil.AddGlobalTimer(1, true, function()
      ECMSDK.Login(platform)
    end)
  end
end
def.method("number", "string", "string", "string", "table").DifferentAccoutAction = function(self, wakeup_platform, openId, pf, pfKey, tokens)
  local game = ECGame.Instance()
  local desc = textRes.Common[306]
  if wakeup_platform == MSDK_LOGIN_PLATFORM.WX then
    desc = textRes.Common[315]
  end
  local dlg = CommonConfirmDlg.ShowConfirmCoundDown(textRes.Common[300], desc, "", "", 0, 0, function(selection, tag)
    warn(selection, "DifferentAccoutAction~~~~~~~", _G.GameState, "  ", MSDK.platform())
    if selection == 1 then
      do
        local info1, info2, info3 = GetMSDKInfoEX()
        ECMSDK.SwitchUser(true)
        SwitchAccount(MSDK_LOGIN_PLATFORM.WX)
        GameUtil.AddGlobalTimer(0.1, true, function()
          SaveMSDKInfoEx(info1, info2, info3)
        end)
      end
    elseif selection == 0 then
      ECMSDK.SwitchUser(false)
      if MSDK.platform() == 1 then
        self:OnLoginSuccess(0, openId, pf, pfKey, tokens[3], "")
      elseif MSDK.platform() == 2 then
        self:OnLoginSuccess(0, openId, pf, pfKey, tokens[1], tokens[2])
      end
    end
  end, {m_level = -1})
  dlg:SetDepth(GUIDEPTH.TOPMOST2)
end
def.method("number", "number", "string", "string", "string", "string", "string", "string", "table").OnWakeup = function(self, flag, platform, media_tag_name, open_id, desc, lang, country, messageExt, extInfo)
  warn(("OnWakeup : %d, %d, %s, %s, %s, %s, %s, %s"):format(MSDK.platform(), flag, platform, media_tag_name, open_id, desc, lang, country, messageExt))
  if messageExt == "WX_GameCenter" then
    SaveMSDKInfoEx(media_tag_name, messageExt, extInfo)
    local ret, _, desc, platform, openId, _, user_id, pf, pfKey = MSDK.getLoginRecord()
    local tokens = MSDK.getTokens()
    warn("WX Game Center Loging", flag, "  ", platform, "  ", open_id)
    if flag == MSDK_LOGIN_ERROR_CODE.Succ then
      self:OnLoginSuccess(platform, open_id, pf, pfKey, tokens[3], "")
      return
    elseif flag == MSDK_LOGIN_ERROR_CODE.Need_Login then
      ECMSDK.Login(MSDK_LOGIN_PLATFORM.WX)
      return
    elseif flag == MSDK_LOGIN_ERROR_CODE.Need_Select_Accout then
      self:DifferentAccoutAction(platform, openId, pf, pfKey, tokens)
      return
    end
  end
  if flag == MSDK_LOGIN_ERROR_CODE.Succ or flag == MSDK_LOGIN_ERROR_CODE.AccountRefresh then
    local ret, flag, desc, platform, openId, _, user_id, pf, pfKey = MSDK.getLoginRecord()
    local tokens = MSDK.getTokens()
    if platform == MSDK_LOGIN_PLATFORM.QQ then
      self:OnLoginSuccess(platform, open_id, pf, pfKey, tokens[1], tokens[2])
    elseif platform == MSDK_LOGIN_PLATFORM.WX then
      self:OnLoginSuccess(platform, open_id, pf, pfKey, tokens[3], "")
    elseif platform == MSDK_LOGIN_PLATFORM.GUEST then
      self:OnLoginSuccess(platform, open_id, pf, pfKey, tokens[6], "")
    end
    SaveMSDKInfoEx(media_tag_name, messageExt, extInfo)
  elseif flag == MSDK_LOGIN_ERROR_CODE.Need_Select_Accout then
    SaveMSDKInfoEx(media_tag_name, messageExt, extInfo)
    local game = ECGame.Instance()
    local desc = textRes.Common[306]
    if platform == MSDK_LOGIN_PLATFORM.WX then
      desc = textRes.Common[315]
    end
    local dlg = CommonConfirmDlg.ShowConfirmCoundDown(textRes.Common[300], desc, "", "", 0, 0, function(selection, tag)
      if selection == 1 then
        do
          local info1, info2, info3 = GetMSDKInfoEX()
          SwitchAccount(platform)
          GameUtil.AddGlobalTimer(0.1, true, function()
            SaveMSDKInfoEx(info1, info2, info3)
          end)
        end
      elseif selection == 0 then
        ECMSDK.SwitchUser(false)
        SaveMSDKInfoEx("", "", nil)
      end
    end, {m_level = -1})
    dlg:SetDepth(GUIDEPTH.TOPMOST2)
  elseif flag == MSDK_LOGIN_ERROR_CODE.UrlLogin then
    SaveMSDKInfoEx(media_tag_name, messageExt, extInfo)
    return
  else
    self:OnLoginError(flag, desc, {})
  end
end
def.method().OnPayNeedLogin = function(self)
  warn("OnPayNeedLogin")
  CommonConfirmDlg.ShowConfirmCoundDown(textRes.Common[300], textRes.Common[305], "", "", 0, 0, function(selection, tag)
    if selection == 1 then
      SwitchAccount(LoginPlatform)
    end
  end)
end
def.method("string").OnMarketJsonInfo = function(self, jsonResult)
  local cb = self.m_CallBack.GetMarketInfo
  if cb then
    cb(jsonResult)
  end
end
def.method("number", "number", "string", "string").OnShare = function(self, platform, flag, desc, extInfo)
  warn("OnShare", platform, flag, desc, extInfo, self.m_ShareType)
  if flag == 0 then
    Toast(textRes.RelationShipChain[35])
    local UseType = require("consts.mzm.gsp.giftaward.confbean.UseType")
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
  local ShareBtnPanel = require("Main.RelationShipChain.ui.ShareBtnPanel")
  ShareBtnPanel.Instance():Destroy()
  Event.DispatchEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.FinishSharing, {
    shareType = self.m_ShareType,
    flag = flag
  })
end
def.method("table").OnLocationNotify = function(self, relationRet)
  warn("OnLocationNotify  ", relationRet.flag, " ", relationRet.desc, " ", relationRet.extInfo, "Get Persons:---->", #relationRet.persons)
  if relationRet.flag == 0 then
    Event.DispatchEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.LBSNotify, {
      data = relationRet.persons
    })
  end
end
def.method("number").OnWebViewNotify = function(self, flag)
  warn("OnWebViewNotify flag = " .. flag)
  if flag == ECMSDK.eFlag.Succ then
    gmodule.moduleMgr:GetModule(ModuleId.SOUND):SetGlobalVolume(0.01)
  elseif flag == ECMSDK.eFlag.WebviewClosed then
    gmodule.moduleMgr:GetModule(ModuleId.SOUND):SetGlobalVolume(1)
  end
end
def.method("number", "string", "number", "number").OnLocationGot = function(self, flag, desc, longitude, latitude)
  warn("OnLocationGot ", flag, "  ", desc, "  ", longitude, "  ", latitude)
end
def.method("table").OnRealNameAuth = function(self, params)
  warn("OnRealNameAuth  ", params.platform, "  ", params.flag, "  ", params.errorCode, " ", params.desc)
end
def.method("table").OnQueryGroupInfo = function(self, groupRet)
  require("Main.Gang.GangGroup.GangGroupMgr").Instance():OnQueryGroupInfo(groupRet)
end
def.method("table").OnBindQQGroup = function(self, groupRet)
  require("Main.Gang.GangGroup.GangGroupMgr").Instance():OnBindQQGroup(groupRet)
end
def.method("table").OnUnbindQQGroup = function(self, groupRet)
  require("Main.Gang.GangGroup.GangGroupMgr").Instance():OnUnbindQQGroup(groupRet)
end
def.method("table").OnQueryQQGroupKey = function(self, groupRet)
  require("Main.Gang.GangGroup.GangGroupMgr").Instance():OnQueryQQGroupKey(groupRet)
end
def.method("table").OnCreateWXGroup = function(self, groupRet)
  require("Main.Gang.GangGroup.GangGroupMgr").Instance():OnCreateWXGroup(groupRet)
end
def.method("table").OnJoinWXGroup = function(self, groupRet)
  require("Main.Gang.GangGroup.GangGroupMgr").Instance():OnJoinWXGroup(groupRet)
end
def.method().InitMSDK = function(self)
  if TssSendData and TssSendData.TssSdkInit then
    TssSendData.TssSdkInit(2598)
  else
    Debug.LogWarning("Don't have the interface TssSendData.TssSdkInit")
  end
  local luaCallBackFunction = {
    onLoginSuccess = function(openId, pf, pfKey, accessToken, payToken)
      self:OnLoginSuccess(0, openId, pf, pfKey, accessToken, payToken, true)
    end,
    onLoginError = function(flag, desc, loginRet)
      self:OnLoginError(flag, desc, loginRet)
    end,
    onRefreshWXToken = function(succ, token)
      self:OnRefreshWXToken(succ, token)
    end,
    onPayCallback = function(retcode, msg, realSaveNum, payChannel, payState, provideState, extendInfo)
      self:OnPayCallback(retcode, msg, realSaveNum, payChannel, payState, provideState, extendInfo)
    end,
    onPayNeedLogin = function()
      self:OnPayNeedLogin()
    end,
    onNoticeInfo = function(scene, info)
      self:OnNoticeInfo(scene, info)
    end,
    onRelationNotify = function(relationRet)
      self:OnRelationNotify(relationRet)
    end,
    onYingXiaoJsonInfo = function(jsonResult)
      self:OnMarketJsonInfo(jsonResult)
    end,
    onShare = function(platform, flag, desc, extInfo)
      self:OnShare(platform, flag, desc, extInfo)
    end,
    onQueryGroupInfo = function(groupRet)
      self:OnQueryGroupInfo(groupRet)
    end,
    onBindQQGroup = function(groupRet)
      self:OnBindQQGroup(groupRet)
    end,
    onUnbindQQGroup = function(groupRet)
      self:OnUnbindQQGroup(groupRet)
    end,
    onQueryQQGroupKey = function(groupRet)
      self:OnQueryQQGroupKey(groupRet)
    end,
    onJoinWXGroup = function(groupRet)
      self:OnJoinWXGroup(groupRet)
    end,
    onCreateWXGroup = function(groupRet)
      self:OnCreateWXGroup(groupRet)
    end,
    onWakeup = function(flag, platform, media_tag_name, open_id, desc, lang, country, messageExt, extInfo)
      self:OnWakeup(flag, platform, media_tag_name, open_id, desc, lang, country, messageExt, extInfo)
    end,
    onRealNameAuth = function(params)
      self:OnRealNameAuth(params)
    end,
    onLocationNotify = function(relationRet)
      self:OnLocationNotify(relationRet)
    end,
    onLocationGot = function(flag, desc, longitude, latitude)
      self:OnLocationGot(flag, desc, longitude, latitude)
    end,
    onWebViewNotify = function(flag)
      self:OnWebViewNotify(flag)
    end
  }
  MSDK.init(luaCallBackFunction)
  gmodule.network.registerProtocol("netio.protocol.gnet.TencentSecureInfo_Re", ECMSDK.OnPrtcTssData)
  warn("\229\136\157\229\167\139\229\140\150MSDK")
end
def.static("string", "table").SendTLogToServer = function(name, params)
  if not instance then
    return
  end
  if IsCrossingServer() then
    return
  end
  if name == "NON" then
    return
  end
  local json = require("Utility.json")
  local jsonString = json.encode(params)
  name = name .. "Client"
  local Octets = require("netio.Octets")
  local p = require("netio.protocol.mzm.gsp.CReportTlog").new(Octets.rawFromString(name), Octets.rawFromString(jsonString))
  gmodule.network.sendProtocol(p)
end
def.static("string", "function").FetchNoticeInfo = function(scene, cb)
  if MSDK and MSDK.fetchNoticeInfo then
    MSDK.fetchNoticeInfo(scene)
  end
  if instance then
    instance.m_CallBack["NoticeCB" .. scene] = cb
  end
end
def.static("number").Login = function(type)
  if MSDK and MSDK.login then
    instance.m_IsReqPermission = true
    MSDK.login(type)
  end
end
def.static("number").QRCodeLogin = function(type)
  if MSDK and MSDK.qrCodeLogin then
    instance.m_IsReqPermission = true
    MSDK.qrCodeLogin(type)
  end
end
def.static().UserLogOut = function()
  ECMSDK.AuroraSdkOnLogout()
  if MSDK and MSDK.logout then
    MSDK.logout()
  end
  ECMSDK.ClearData()
  instance.m_IsLogin = false
  instance.m_IsReqPermission = false
end
def.static("=>", "string").GetRegisterChannelID = function()
  if MSDK and MSDK.getRegisterChannelId then
    return MSDK.getRegisterChannelId()
  end
end
def.static("number", "=>", "boolean").IsPlatformInstalled = function(platform)
  if not MSDK or not MSDK.isPlatformInstalled then
    return false
  end
  return MSDK.isPlatformInstalled(platform)
end
def.static().QueryMyInfo = function()
  if LoginPlatform == MSDK_LOGIN_PLATFORM.QQ then
    warn("Query QQMyInfo", MSDK.queryQQMyInfo)
    if MSDK and MSDK.queryQQMyInfo then
      MSDK.queryQQMyInfo()
    end
  elseif LoginPlatform == MSDK_LOGIN_PLATFORM.WX then
    warn("Query WXMyInfo", MSDK.queryWXMyInfo)
    if MSDK and MSDK.queryWXMyInfo then
      MSDK.queryWXMyInfo()
    end
  end
end
def.static("boolean").RegisterXGInner = function(flag)
  if MSDK and MSDK.registerXG then
    MSDK.registerXG(flag)
  end
end
def.static().RegesiterXGAccount = function()
  if MSDK and MSDK.registerXGAccount then
    local openid = instance.m_MSDKInfo.openId
    openid = openid or " "
    MSDK.registerXGAccount(openid)
  end
end
def.static().RegisterXG = function()
  local function RegisterXG(flag)
    if platform == 2 then
      ECMSDK.RegisterXGInner(flag)
      ECMSDK.RegesiterXGAccount()
    elseif platform == 1 then
      ECMSDK.RegesiterXGAccount()
      ECMSDK.RegisterXGInner(flag)
    end
  end
  RegisterXG(true)
end
def.static("=>", "string").GetChannelID = function()
  return _G.GetChannelID()
end
def.static().RefreshWXToken = function()
  if MSDK and MSDK.refreshWXToken then
    MSDK.refreshWXToken()
  end
end
def.static("boolean").SwitchUser = function(flag)
  if MSDK and MSDK.switchUser then
    instance.m_IsReqPermission = false
    MSDK.switchUser(flag)
  end
end
def.static("string", "=>", "string").GetEncodeUrl = function(url)
  if MSDK and MSDK.getEncodeUrl then
    return MSDK.getEncodeUrl(url)
  end
  return ""
end
def.static("=>", "string").GetVersion = function()
  if MSDK and MSDK.getVersion then
    return MSDK.getVersion()
  end
  return ""
end
def.static("string", "=>", "boolean").RegisterMidas = function(env)
  if not env then
    return false
  end
  local flag = true
  if MSDK and MSDK.registerPay then
    local extra = {}
    local sdkInfo = instance.m_MSDKInfo
    if not _MSDKInfoValid(sdkInfo) then
      return false
    end
    local payToken = GetPayToken()
    if not payToken then
      return false
    end
    extra.kAppExtra = tostring(Network.m_zoneid)
    if not extra.kAppExtra then
      return false
    end
    if env == "test" then
      extra.logEnable = "true"
    end
    flag = MSDK.registerPay(sdkInfo.offerId, sdkInfo.openId, payToken, sdkInfo.sessionId, sdkInfo.sessionType, sdkInfo.pf, sdkInfo.pfKey, env, extra)
  else
    warn("MSDK.registerPay \228\184\141\229\173\152\229\156\168", env, "  ", type(env))
  end
  return flag
end
def.static("table", "function").Pay = function(payParams, payCallBack)
  local HeroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  local sdkInfo = instance.m_MSDKInfo
  local payToken = GetPayToken()
  if not sdkInfo.appId or not sdkInfo.openId then
    Debug.LogWarning("The appid or openid of MSDK is Empty")
    return
  end
  local pf = ECMSDK.GetPf()
  if pf == "" then
    return
  end
  local zoneId = Network.m_zoneid
  warn("ECMSDK-Pay zoneId:", zoneId, " ", Network.m_zoneid)
  if platform == 1 then
    if MSDK and MSDK.pay then
      MSDK.pay(sdkInfo.offerId, sdkInfo.openId, payToken, sdkInfo.sessionId, sdkInfo.sessionType, tostring(zoneId), pf, sdkInfo.pfKey, payParams.durtime, payParams.productID, payParams.payType ~= ECMSDK.PAYTYPE.MONTH)
    end
  elseif platform == 2 then
    if payParams.payType == ECMSDK.PAYTYPE.MONTH then
      if MSDK and MSDK.launchSubscribe then
        MSDK.launchSubscribe(sdkInfo.offerId, sdkInfo.openId, payToken, sdkInfo.sessionId, sdkInfo.sessionType, tostring(zoneId), pf, sdkInfo.pfKey, payParams.serviceCode, payParams.serviceName, payParams.productID, "", payParams.autoPay, payParams.saveValue, false, 0, true, true)
      end
    elseif MSDK and MSDK.launchPay then
      MSDK.launchPay(sdkInfo.offerId, sdkInfo.openId, payToken, sdkInfo.sessionId, sdkInfo.sessionType, tostring(zoneId), pf, sdkInfo.pfKey, "common", payParams.saveValue, false, 0, textRes.Common[40], true, true)
    end
  end
  instance.m_CallBack.Pay = payCallBack
end
def.static("=>", "string").GetPayToken = function()
  return GetPayToken() or ""
end
def.static("=>", "string").GetPf = function()
  local sdkInfo = instance.m_MSDKInfo
  if not sdkInfo.appId or not sdkInfo.openId then
    warn("GetPf: The appid or openid of MSDK is Empty")
    return ""
  end
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  if heroProp == nil then
    warn("GetPf: HeroProp is Empty")
    return ""
  end
  local pf = ("%s-%s*%d*%s*%d*%s*%d*%s"):format(sdkInfo.pf, sdkInfo.appId, platform == 1 and 0 or 1, sdkInfo.openId, heroProp.level, GetChannelID(), Network.m_zoneid, heroProp.id:tostring())
  return pf
end
def.static().TssSdkSetUserInfoEx = function()
  if LoginPlatform == MSDK_LOGIN_PLATFORM.GUEST then
    return
  end
  if TssSendData and TssSendData.TssSdkSetUserInfoEx then
    local info = ECMSDK.GetMSDKInfo()
    if info and info.openId and info.appId then
      local HeroProp = require("Main.Hero.Interface").GetBasicHeroProp()
      TssSendData.TssSdkSetUserInfoEx(LoginPlatform == MSDK_LOGIN_PLATFORM.WX and 2 or 1, info.openId, info.appId, 1, HeroProp.id:tostring())
    else
      Debug.LogWarning("Fail to send TssData ,because lack msdk info")
    end
  else
    Debug.LogWarning("Don't have the interface TssSendData.TssSdkSetUserInfoEx")
  end
end
def.static("boolean").TssSdkSetGameStatus = function(pauseStatus)
  if TssSendData and TssSendData.TssSdkSetGameStatus then
    TssSendData.TssSdkSetGameStatus(pauseStatus and 2 or 1)
  else
    Debug.LogWarning("Don't have the interface TssSendData.TssSdkSetGameStatus")
  end
end
def.static().TssSendData = function()
  if not instance.m_TssSDKGO then
    instance.m_TssSDKGO = GameObject.GameObject("TssSDK")
    instance.m_TssSDKGO:AddComponent("TssSendData")
  else
    warn("\233\135\141\230\150\176\230\191\128\230\180\187\229\174\137\229\133\168SDKGO", instance.m_TssSDKGO.activeSelf)
    instance.m_TssSDKGO:SetActive(true)
  end
end
def.static("table").OnPrtcTssData = function(p)
  if TssSendData and TssSendData.OnPrtc_TssData then
    local data = __NetIO_OctetsToString(p.secure_data)
    local oct = Octets.Octets()
    TssSendData.OnPrtc_TssData(oct:replace(data))
  else
    Debug.LogWarning("Don't have the interface TssSendData.OnPrtc_TssData")
  end
end
def.static("boolean").InitGSDK = function(debug)
  if GSDKWrapper and GSDKWrapper.Init and not instance.m_IsGSDKInit then
    local appid = ECMSDK.APPID.QQ
    if LoginPlatform == MSDK_LOGIN_PLATFORM.WX then
      appid = ECMSDK.APPID.WX
    end
    GSDKWrapper.Init(appid, debug, debug and 0 or 1)
    instance.m_IsGSDKInit = true
  else
    Debug.LogWarning("Don't have the interface GSDKWrapper.Init")
  end
end
def.static().GSDKSetUserName = function()
  if GSDKWrapper and GSDKWrapper.SetUserName then
    local openId = instance.m_MSDKInfo.openId
    if openId then
      GSDKWrapper.SetUserName(LoginPlatform, openId)
    else
      Debug.LogWarning("Don't have openid")
    end
  end
end
def.static("boolean").GSDKBackAndFront = function(pauseStatus)
  if not instance.m_IsGSDKInit then
    return
  end
  if pauseStatus then
    GSDKWrapper.End()
  else
    ECMSDK.GSDKStart(0)
  end
end
def.static("number").GSDKStart = function(map)
  local loginModule = require("Main.Login.LoginModule").Instance()
  if loginModule:IsInWorld() or loginModule:IsLoadingWorld() then
    local serverIp = loginModule.serverIp
    local serverPort = loginModule.serverPort
    if serverIp == "" or serverPort == "" then
      warn("GSDK:ServerAddress is not ready")
      return
    end
    local zoneId = require("netio.Network").m_zoneid
    if zoneId <= 0 then
      warn("GSDK:ZoneId is not ready")
      return
    end
    local mapId = map > 0 and map or require("Main.Map.MapModule").Instance().currentMapId
    if mapId <= 0 then
      warn("GSDK:MapId is not ready")
      return
    end
    local mapIdStr = tostring(mapId)
    local serverAddress = serverIp .. ":" .. serverPort
    GSDKWrapper.Start(zoneId, mapIdStr, serverAddress)
    warn("GSDKWrapper.Start(", zoneId, mapIdStr, serverAddress, ")")
  else
    warn("GSDK.Start not in world")
  end
end
def.static().GSDKEnd = function()
  GSDKWrapper.End()
  warn("GSDKWrapper.End()")
end
def.static("number", "boolean", "string").SetGSDKEvent = function(tag, status, msg)
  if GSDKWrapper and GSDKWrapper.SetEvent then
    GSDKWrapper.SetEvent(tag, status, msg)
  end
end
def.static("number", "string", "string").SendToFriend = function(scene, title, desc)
  local imgUrl = ECMSDK.LogoURL
  if LoginPlatform == MSDK_LOGIN_PLATFORM.QQ then
    if not ECMSDK.IsPlatformInstalled(_G.MSDK_LOGIN_PLATFORM.QQ) then
      Toast(textRes.Common[310])
      return
    end
    if scene == 3 then
      scene = 1
    end
    local from = "androidqq"
    if _G.platform == 1 then
      from = "iphoneqq"
    end
    local url = ECMSDK.ShareURL[2]:format(from, instance.m_MSDKInfo.openId)
    if ECMSDK.IsHttpsSupported() and _G.platform == 1 then
      url = ECMSDK.ShareURL[7]:format(instance.m_MSDKInfo.openId, from)
      imgUrl = ECMSDK.LogoURL2
    end
    warn(imgUrl, "   SendToFriend QQ......................", url)
    if MSDK and MSDK.sendToQQ then
      MSDK.sendToQQ(scene, title, desc, url, imgUrl)
    end
  elseif LoginPlatform == MSDK_LOGIN_PLATFORM.WX then
    if not ECMSDK.IsPlatformInstalled(_G.MSDK_LOGIN_PLATFORM.WX) then
      Toast(textRes.Common[311])
      return
    end
    if scene ~= 3 then
      local url = ECMSDK.ShareURL[3]
      if ECMSDK.IsHttpsSupported() and _G.platform == 1 then
        url = ECMSDK.ShareURL[8]
        imgUrl = ECMSDK.LogoURL2
      end
      warn(imgUrl, "   SendToFriend WX......................", url)
      if MSDK and MSDK.sendToWXWithUrl then
        MSDK.sendToWXWithUrl(scene, title, desc, url, "MSG_SHARE_FRIEND_HIGH_SCORE", imgUrl, "")
      end
    else
      if ECMSDK.IsHttpsSupported() and _G.platform == 1 then
        imgUrl = ECMSDK.LogoURL2
      end
      if MSDK and MSDK.sendToWX then
        MSDK.sendToWX(title, desc, "MSG_INVITE", imgUrl, "")
      end
    end
  end
end
def.static("number", "string").SendToFriendWithPhotoPath = function(scene, filePath)
  if _G.LoginPlatform == MSDK_LOGIN_PLATFORM.QQ then
    warn("ECMSDK  QQ  SendToFriendWithPhoto:", scene, filePath)
    if MSDK and MSDK.sendToQQWithPhoto then
      MSDK.sendToQQWithPhoto(scene, filePath)
    end
  elseif _G.LoginPlatform == MSDK_LOGIN_PLATFORM.WX then
    warn("ECMSDK  WX  SendToFriendWithPhoto!!!!!!!!!!!!:", scene, filePath)
    if MSDK and MSDK.sendToWeixinWithPhoto then
      MSDK.sendToWeixinWithPhoto(scene, "MSG_INVITE", filePath, "MessageExt", "WECHAT_SNS_JUMP_APP")
    end
  end
end
def.static("number", "string").SendToFriendWithPhoto = function(scene, url)
  local md5 = GameUtil.md5(url)
  local filePath = Application.temporaryCachePath .. "/" .. md5
  if FileExists(filePath) then
    ECMSDK.SendToFriendWithPhotoPath(scene, filePath)
  else
    url = _G.NormalizeHttpURL(url)
    GameUtil.downLoadUrl(url, filePath, function(ret, url, filePath, bytes)
      if not ret then
        warn("Fail to downLoad img from URL", url)
      else
        ECMSDK.SendToFriendWithPhotoPath(scene, filePath)
      end
    end)
  end
end
def.static("string", "string", "string").AddGameFriendToQQ = function(openid, desc, message)
  if LoginPlatform ~= MSDK_LOGIN_PLATFORM.QQ then
    return
  end
  if not ECMSDK.IsPlatformInstalled(_G.MSDK_LOGIN_PLATFORM.QQ) then
    Toast(textRes.Common[310])
    return
  end
  if MSDK and MSDK.addGameFriendToQQ then
    MSDK.addGameFriendToQQ(openid, desc, message)
  end
end
def.static("=>", "boolean").IsAddGameFriendToQQAvailable = function()
  if LoginPlatform ~= MSDK_LOGIN_PLATFORM.QQ then
    return false
  end
  if GameUtil.IsEvaluation() then
    return false
  end
  local DeviceUtility = require("Utility.DeviceUtility")
  if DeviceUtility.IsIPad() then
    return false
  end
  return true
end
def.static("number", "string", "string", "string", "string", "number", "string").SendToGameFriend = function(act, friendOpenId, title, summary, previewText, gameTagType, imageURL)
  local ext = ""
  if LoginPlatform == MSDK_LOGIN_PLATFORM.QQ then
    local from = "androidqq"
    if _G.platform == 1 then
      from = "iphoneqq"
    end
    local targetUrl = ("http://gamecenter.qq.com/gamecenter/index/detail.html?appid=1105218881&pf=invite&plat=qq&from=%s&ADTAG=gameobj.msg_heart&originuin=%s"):format(from, instance.m_MSDKInfo.openId)
    local imgUrl = imageURL == "" and ECMSDK.LogoURL or imageURL
    local gameTag = ECMSDK.GAMETAG.QQ[gameTagType]
    if MSDK and MSDK.sendToQQGameFriend then
      MSDK.sendToQQGameFriend(act, friendOpenId, title, summary, targetUrl, imgUrl, previewText, gameTag, ext)
    end
    warn(("ECMSDK  QQ  SendToGameFriend: %d, %s, %s, %s, %s, %s, %s, %s, %s"):format(act, friendOpenId, title, summary, targetUrl, imgUrl, previewText, gameTag, ext))
  elseif LoginPlatform == MSDK_LOGIN_PLATFORM.WX then
    local gameTag = ECMSDK.GAMETAG.WX[gameTagType]
    warn(("ECMSDK11  WX  SendToGameFriend: %s, %s, %s, %s"):format(friendOpenId, title, summary, gameTag))
    if MSDK and MSDK.sendToWXGameFriend then
      MSDK.sendToWXGameFriend(friendOpenId, title, summary, "", "", gameTag, "", ext)
    end
  end
end
def.static().GetLocationInfo = function()
  if MSDK and MSDK.getLocationInfo then
    MSDK.getLocationInfo()
  end
end
def.static().GetNearbyPersonInfo = function()
  if MSDK and MSDK.getNearbyPersonInfo then
    MSDK.getNearbyPersonInfo()
  end
end
def.static("string", "string").BindQQGroup = function(factionID, factionName)
  if MSDK and MSDK.bindQQGroup then
    local sig = instance.m_MSDKInfo.openId .. "_" .. instance.m_MSDKInfo.appId .. "_" .. instance.m_MSDKInfo.appKey .. "_" .. factionID .. "_" .. Network.m_zoneid
    local md5 = GameUtil.md5(sig)
    warn("***Group Test--->ECMSDK.bindQQGroup", factionID, factionName, Network.m_zoneid, sig, md5)
    MSDK.bindQQGroup(factionID, factionName, Network.m_zoneid, md5)
  end
end
def.static("string", "string").UnBindQQGroup = function(groupOpenID, factionID)
  if MSDK and MSDK.unbindQQGroup then
    warn("***Group Test--->ECMSDK.UnBindQQGroup", groupOpenID, factionID)
    MSDK.unbindQQGroup(groupOpenID, factionID)
  end
end
def.static("string").JoinQQGroup = function(qqGroupKey)
  if MSDK and MSDK.joinQQGroup then
    warn("***Group Test--->ECMSDK.JoinQQGroup", qqGroupKey)
    MSDK.joinQQGroup(qqGroupKey)
  end
end
def.static("string").QueryQQGroupInfo = function(factionID)
  if MSDK and MSDK.queryQQGroupInfo then
    warn("***Group Test--->ECMSDK.queryQQGroupInfo", factionID, Network.m_zoneid)
    MSDK.queryQQGroupInfo(factionID, tostring(Network.m_zoneid))
  end
end
def.static("string").QueryQQGroupKey = function(groupopenid)
  if MSDK and MSDK.queryQQGroupKey then
    MSDK.queryQQGroupKey(groupopenid)
  end
end
def.static("string", "string", "string").CreateWXGroup = function(factionID, chatRoomName, chatRoomNickName)
  if MSDK and MSDK.createWXGroup then
    warn("***Group Test--->ECMSDK.createWXGroup", factionID, chatRoomName, chatRoomNickName)
    MSDK.createWXGroup(factionID, chatRoomName, chatRoomNickName)
  end
end
def.static("string", "string").JoinWXGroup = function(factionID, chatRoomNickName)
  if MSDK and MSDK.joinWXGroup then
    warn("***Group Test--->ECMSDK.JoinWXGroup", factionID, chatRoomNickName)
    MSDK.joinWXGroup(factionID, chatRoomNickName)
  end
end
def.static("string", "string").QueryWXGroupInfo = function(factionID, openIdList)
  if MSDK and MSDK.queryWXGroupInfo then
    warn("***Group Test--->ECMSDK.queryWXGroupInfo", factionID, openIdList)
    MSDK.queryWXGroupInfo(factionID, openIdList)
  end
end
def.static("number", "string", "string", "string", "string", "string", "string", "string").SendToWXGroup = function(subType, factionID, title, description, messageExt, mediaTagName, imgUrl, msdkExtInfo)
  if MSDK and MSDK.sendToWXGroup then
    local msgType = 1
    warn("***Group Test--->ECMSDK.sendToWXGroup", msgType, subType, factionID, title, description, messageExt, mediaTagName, ECMSDK.LogoURL, msdkExtInfo)
    MSDK.sendToWXGroup(msgType, subType, factionID, title, description, messageExt, mediaTagName, ECMSDK.LogoURL, msdkExtInfo)
  end
end
def.static("string").SetTag = function(tag)
  if MSDK and MSDK.setTag then
    MSDK.setTag(tag)
  end
end
def.static("string").DelTag = function(tag)
  if MSDK and MSDK.delTag then
    MSDK.delTag(tag)
  end
end
def.static("string", "string", "boolean").ReportEvent = function(eventName, processid, isRealTime)
  if MSDK and MSDK.reportEvent then
    local diviceID = MSDK.getDeviceId()
    local dtEventTime = os.date("%Y-%m-%d %X")
    MSDK.reportEvent(eventName, "DiviceId", diviceID, "dtEventTime", dtEventTime, "processid", processid, isRealTime)
  end
end
def.static("function").SetMarketInfoCallback = function(callback)
  instance.m_CallBack.GetMarketInfo = callback
end
def.static().GetMarketInfo = function()
  if MSDK and MSDK.launchYingXiao then
    local payToken = GetPayToken()
    if not payToken then
      return
    end
    if not _MSDKInfoValid(instance.m_MSDKInfo) then
      return
    end
    MSDK.launchYingXiao(instance.m_MSDKInfo.offerId, instance.m_MSDKInfo.openId, payToken, instance.m_MSDKInfo.sessionId, instance.m_MSDKInfo.sessionType, tostring(Network.m_zoneid), instance.m_MSDKInfo.pf, instance.m_MSDKInfo.pfKey, "mp")
  end
end
def.static("number").PayQQRight = function(payType)
  if MSDK and MSDK.launchMonth then
    local HeroProp = require("Main.Hero.Interface").GetBasicHeroProp()
    local roleid = HeroProp.id
    local payToken = GetPayToken()
    if not payToken then
      return
    end
    local serviceCode = ""
    local serviceName = ""
    local remark = "aid=mvip.yx.inside.mhzx_1105218881"
    local serviceType = 1
    local resId = 2
    local reserv = "goods_zoneid=" .. tostring(Network.m_zoneid) .. "_" .. Int64.tostring(roleid)
    instance.m_PayQQVIPInfo = {}
    if payType == 2 then
      serviceCode = "CJCLUBT"
      serviceName = "/" .. textRes.Common[309]
      serviceType = 1
      resId = 3
      instance.m_PayQQVIPInfo.vip_flag = 16
      instance.m_PayQQVIPInfo.is_new = 0
    elseif payType == 3 then
      serviceCode = "CJCLUBT"
      serviceName = textRes.Common[308]
      serviceType = 1
      resId = 3
      instance.m_PayQQVIPInfo.vip_flag = 16
      instance.m_PayQQVIPInfo.is_new = 1
    else
      serviceCode = "LTMCLUB"
      serviceName = "/" .. textRes.Common[307]
      serviceType = 1
      resId = 2
      instance.m_PayQQVIPInfo.vip_flag = 1
      instance.m_PayQQVIPInfo.is_new = payType ~= 4 and 1 or 0
    end
    if not _MSDKInfoValid(instance.m_MSDKInfo) then
      return
    end
    warn("offerId: ", instance.m_MSDKInfo.offerId, " openId: ", instance.m_MSDKInfo.openId, " payToken: ", payToken, " sessionId: ", instance.m_MSDKInfo.sessionId, " sessionType: ", instance.m_MSDKInfo.sessionType, " zoneId:", tostring(Network.m_zoneid), " pf: ", instance.m_MSDKInfo.pf, " pfKey: ", instance.m_MSDKInfo.pfKey, "remark ", remark, " serviceCode: ", serviceCode, " serviceType: ", serviceType, "reserv : ", reserv, "VIPInfo--------------------------", instance.m_PayQQVIPInfo.vip_flag, instance.m_PayQQVIPInfo.is_new)
    MSDK.launchMonth(instance.m_MSDKInfo.offerId, instance.m_MSDKInfo.openId, payToken, instance.m_MSDKInfo.sessionId, instance.m_MSDKInfo.sessionType, tostring(Network.m_zoneid), instance.m_MSDKInfo.pf, instance.m_MSDKInfo.pfKey, serviceCode, serviceName, remark, serviceType, false, "", false, resId, reserv)
  end
end
def.static().QQXinYueVIP = function()
  local game_id = 80
  local openid = instance.m_MSDKInfo.openId
  local accesskey = instance.m_MSDKInfo.accessToken
  local appid = instance.m_MSDKInfo.appId
  local loginType = 1
  if LoginPlatform == MSDK_LOGIN_PLATFORM.WX then
    loginType = 2
  end
  local opencode = GameUtil.Base64Encode(openid .. "," .. accesskey .. "," .. appid .. "," .. loginType)
  local partition_id = Network.m_zoneid
  local HeroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  local roleid = HeroProp.id
  ECMSDK.OpenURL(textRes.Common.xinyue_vip:format(game_id, opencode, partition_id, roleid:tostring()))
end
def.static("string", "varlist").OpenURL = function(url, screenDir)
  if MSDK and MSDK.openUrl then
    url = ECMSDK.NormalizeURL(url)
    if screenDir then
      MSDK.openUrl(url, screenDir)
    else
      MSDK.openUrl(url)
    end
  else
    warn("No openUrl API")
  end
end
def.static("string", "=>", "string").NormalizeURL = function(url)
  if ECMSDK.IsHttpsSupported() then
    url = _G.NormalizeHttpURL(url)
  end
  if ECMSDK.IsUrlInnerEncodeVersion() then
    url = url:urldecode()
  end
  return url
end
def.static("=>", "boolean").IsUrlInnerEncodeVersion = function()
  local msdkVersion = ECMSDK.GetVersion()
  local isInnerEncode = false
  for i, version in ipairs(ECMSDK.UrlInnerEncodeVersions) do
    if msdkVersion:find(version) == 1 then
      isInnerEncode = true
      break
    end
  end
  return isInnerEncode
end
def.static("number", "number", "number", "string", "string").RealNameAuth = function(provinceID, identityType, identityNum, name, city)
  if MSDK and MSDK.realNameAuth then
    warn("RealNameAuth", provinceID, "  ", identityType, "   ", identityNum, " ", name, "    ", city)
    MSDK.realNameAuth(provinceID, identityType, identityNum, name, city)
  end
end
def.static("string").SetClipBoard = function(copyString)
  if MSDK and MSDK.setClipboard then
    MSDK.setClipboard(copyString)
  end
end
def.static().AuroraSdkOnLogin = function()
  if MSDK and MSDK.auroraSdkOnLogin then
    MSDK.auroraSdkOnLogin()
  end
end
def.static().AuroraSdkOnLogout = function()
  if MSDK and MSDK.auroraSdkOnLogout then
    MSDK.auroraSdkOnLogout()
  end
end
def.static("number", "number", "number").AuroraSdkStart = function(x, y, size)
  if MSDK and MSDK.auroraSdkStart then
    MSDK.auroraSdkStart(x, y, size)
  end
end
def.static().AuroraSdkStop = function()
  if MSDK and MSDK.auroraSdkStop then
    MSDK.auroraSdkStop()
  end
end
def.static().ClearData = function()
  if instance then
    instance.m_MSDKInfo = {}
    instance.m_MyInfo = {}
    instance.m_NotifyInfo = {}
  end
end
def.static("=>", "string").GetCombineAppID = function()
  if not instance then
    return "1"
  end
  return instance.m_CombineAppID
end
def.static("=>", "table").GetMSDKInfo = function()
  if not instance then
    return nil
  end
  return instance.m_MSDKInfo
end
def.static("=>", "table").GetNotifyInfo = function()
  if not instance then
    return nil
  end
  return instance.m_NotifyInfo
end
def.static("=>", "table").GetMyInfo = function()
  if not instance then
    return nil
  end
  return instance.m_MyInfo
end
def.static("=>", "boolean").IsLogin = function()
  if not instance then
    return false
  end
  return instance.m_IsLogin
end
def.static("=>", "boolean").IsGuest = function()
  if not instance then
    return false
  end
  return instance.m_IsGuest
end
def.static("string", "=>", "boolean").IsMySelf = function(openid)
  local id = instance.m_MSDKInfo.openid
  return openid == id
end
def.static("number").SetShareType = function(shareType)
  if not instance then
    return
  end
  instance.m_ShareType = shareType
end
def.static("=>", "number").PayPlatform = function()
  if _G.LoginPlatform == MSDK_LOGIN_PLATFORM.GUEST then
    return instance.m_Platform
  end
  return _G.LoginPlatform
end
def.static("=>", "boolean").IsFromWXGameCenter = function()
  if not instance then
    return false
  end
  if _G.LoginPlatform == MSDK_LOGIN_PLATFORM.WX or _G.LoginPlatform == MSDK_LOGIN_PLATFORM.WX_GAMECENTER then
    local mediaTagName = instance.m_MSDKInfo.mediaTagName
    warn("IsFromWXGameCenter2", "mediaTagName", mediaTagName)
    if mediaTagName == "wgWXGameRecommend" then
      return true
    end
    if not instance.m_MSDKInfo.extInfo then
      return false
    end
    for _, v in pairs(instance.m_MSDKInfo.extInfo) do
      warn("IsFromWXGameCenter:", v)
      if v == "WX_GameCenter" or v == "wgWXGameRecommend" then
        return true
      end
    end
  end
  return false
end
def.static("=>", "boolean").IsWXGameCenter = function()
  if not instance then
    return false
  end
  local friendData = require("Main.RelationShipChain.RelationShipChainMgr").GetFriendData()
  local openId = ECMSDK.GetMSDKInfo().openId
  local myInfo = friendData[openId]
  if not myInfo then
    return false
  end
  return myInfo.login_privilege == ECMSDK.LOGINPRIVILEGETYPE.WX
end
def.static("=>", "boolean").IsQQGameCenter = function()
  if not instance then
    return false
  end
  if not instance.m_MSDKInfo.extInfo then
    return false
  end
  for _, v in pairs(instance.m_MSDKInfo.extInfo) do
    warn("--IsQQGameCenter:", v)
    if v == "sq_gamecenter" then
      return true
    end
  end
  return false
end
def.static("=>", "boolean").IsFromYYB = function()
  if not instance then
    return false
  end
  if not instance.m_MSDKInfo.extInfo then
    return false
  end
  local extInfo = instance.m_MSDKInfo.extInfo
  return extInfo.launchfrom == "myapp_flzx" and extInfo.platform == "qq_m"
end
def.static("=>", "number").GetLoginPrivilegeType = function()
  if ECMSDK.IsQQGameCenter() then
    return ECMSDK.LOGINPRIVILEGETYPE.QQ
  elseif ECMSDK.IsFromWXGameCenter() then
    return ECMSDK.LOGINPRIVILEGETYPE.WX
  elseif ECMSDK.IsFromYYB() then
    return ECMSDK.LOGINPRIVILEGETYPE.YYB
  end
  return ECMSDK.LOGINPRIVILEGETYPE.NON
end
def.static("=>", "number", "string", "string", "string", "string", "number").GetGameCompitionParam = function()
  if not instance or not instance.m_MSDKInfo then
    return 0, "", "", "", "", 0
  end
  local platform = 2
  if _G.LoginPlatform == MSDK_LOGIN_PLATFORM.QQ then
    platform = 0
  elseif _G.LoginPlatform == MSDK_LOGIN_PLATFORM.WX then
    platform = 1
  end
  local appid = instance.m_MSDKInfo.appId
  local openid = instance.m_MSDKInfo.openId
  local token = instance.m_MSDKInfo.accessToken
  local phoneNum = ""
  local expires = 0
  warn("qqec params:", platform, " ", appid, " ", openid, " ", token, " ", phoneNum, " ", expires)
  return platform, appid, openid, token, phoneNum, expires
end
def.static("=>", "boolean").IsHttpsSupported = function()
  local version = GameUtil.GetProgramCurrentVersionInfo()
  version = tonumber(version) or 0
  return version >= ECMSDK.HTTPS_SUPPORT_VERSION
end
ECMSDK.Commit()
return ECMSDK
