local MODULE_NAME = (...)
local Lplus = require("Lplus")
local RealNameAuthMgr = Lplus.Class(MODULE_NAME)
local def = RealNameAuthMgr.define
local LuaUserDataIO = require("Main.Common.LuaUserDataIO")
local ECMSDK = require("ProxySDK.ECMSDK")
local GRCUtility = require("Utility.GRCUtility")
def.const("string").STORE_FILE_PATTERN = "RealNameAuth/user_%s.lua"
def.const("number").FIRST_REG_INFO_CACHE_TIME = 300
def.field("table").m_firstRegInfoCache = nil
local instance
def.static("=>", RealNameAuthMgr).Instance = function()
  if instance == nil then
    instance = RealNameAuthMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.RE_LOGIN, RealNameAuthMgr.OnReLogin)
end
def.method("=>", "boolean").IsEnabled = function(self)
  local sdktype = ClientCfg.GetSDKType()
  if sdktype == ClientCfg.SDKTYPE.MSDK then
    if _G.GetDirVersionService("get_first_reg") == nil and _G.GetDirVersionService("https_get_first_reg") == nil then
      warn("get_first_reg and https_get_first_reg url not configured!")
      return false
    end
    return true
  else
    return false
  end
end
def.method("=>", "string").GetUserId = function(self)
  local sdktype = ClientCfg.GetSDKType()
  if sdktype == ClientCfg.SDKTYPE.MSDK then
    local msdkInfo = ECMSDK.GetMSDKInfo()
    return msdkInfo and msdkInfo.openId or ""
  else
    return ""
  end
end
def.method("function").AsyncGetFirstRegInfo = function(self, callback)
  if not self:IsEnabled() then
    _G.SafeCallback(callback, nil)
    return
  end
  local useRsa = true
  if _G.platform == _G.Platform.ios or _G.CUR_CODE_VERSION < _G.RSA_CODE_VERSION then
    useRsa = false
  end
  local getUrlServiceName
  if useRsa then
    getUrlServiceName = "get_first_reg"
  else
    getUrlServiceName = "https_get_first_reg"
  end
  local url = _G.GetDirVersionService(getUrlServiceName)
  if url == nil then
    warn(string.format("[error] AsyncGetFirstRegInfo: %s url return nil", getUrlServiceName))
    _G.SafeCallback(callback, nil)
    return
  end
  url = _G.NormalizeHttpURL(url)
  local params = self:GetFirstRegReqParams(useRsa)
  if params == nil then
    _G.SafeCallback(callback, nil)
    return
  end
  for k, v in pairs(params) do
    if type(v) == "string" then
      params[k] = v:urlencode()
    end
  end
  local postData = _G.AttachParams2URL("", params)
  postData = postData:sub(2, -1)
  print(string.format("AsyncGetFirstRegInfo: httpPost url:%s, postData:%s", url, postData))
  GameUtil.httpPost(url, 0, postData, function(success, url, postId, bytes)
    if not success then
      warn("[error] AsyncGetFirstRegInfo: http post failed")
      _G.SafeCallback(callback, nil)
      return
    end
    local json = require("Utility.json")
    local strRes = bytes:get_string()
    local res = json.decode(strRes)
    print(string.format("AsyncGetFirstRegInfo res:%s", strRes))
    _G.SafeCallback(callback, res)
  end)
end
def.method("boolean", "=>", "table").GetFirstRegReqParams = function(self, useRsa)
  local params = {}
  local sdktype = ClientCfg.GetSDKType()
  if sdktype == ClientCfg.SDKTYPE.MSDK then
    local msdkInfo = ECMSDK.GetMSDKInfo()
    if msdkInfo == nil then
      warn("[error] GetFirstRegReqParams: msdkInfo is nil!")
      return nil
    end
    params.appid = msdkInfo.appId
    params.openid = msdkInfo.openId
    if LoginPlatform == MSDK_LOGIN_PLATFORM.QQ then
      params.channel = "qq"
    elseif LoginPlatform == MSDK_LOGIN_PLATFORM.WX then
      params.channel = "wechat"
    end
    local encode, accessToken
    if useRsa then
      params.encode = "rsa"
      params.accessToken = GRCUtility.RSAEncryptToBase64(msdkInfo.accessToken)
    else
      params.encode = "plain"
      params.accessToken = msdkInfo.accessToken
    end
  end
  return params
end
def.method("function").CheckFirstRegInfo = function(self, onFinished)
  if not self:IsEnabled() then
    _G.SafeCallback(onFinished, nil)
    return
  end
  self:AsyncGetFirstRegInfo(function(res)
    local info
    if res then
      if res.ret == 0 and res.data.ret == 0 then
        local data = res.data
        info = {}
        info.needPop = data.need_pop == "1"
        info.hasAuthorized = data.realname_flag == "1"
        info.realname_flag = data.realname_flag
        info.mobile_flag = data.mobile_flag
        info.timestamp = os.time()
        self.m_firstRegInfoCache = info
        if info.hasAuthorized then
          self:SaveAuthInfo({hasAuthorized = true})
        end
      elseif res.ret ~= 0 then
        warn(string.format("RealNameAuthMgr.CheckFirstRegInfo ret=%s, msg=%s", res.ret, tostring(res.msg)))
      else
        warn(string.format("RealNameAuthMgr.CheckFirstRegInfo data.ret=%s, data.msg=%s", res.data.ret, tostring(res.data.msg)))
      end
    end
    _G.SafeCallback(onFinished, info)
  end)
end
def.method("function").PopAuthMessage = function(self, onFinished)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  local title = textRes.Common[1101]
  local desc = textRes.Common[1102]
  CommonConfirmDlg.ShowCerternConfirm(title, desc, "", function()
    _G.SafeCallback(onFinished)
  end, {m_level = 0})
end
def.method("table").SaveAuthInfo = function(self, authInfo)
  local userId = self:GetUserId()
  local filePath = RealNameAuthMgr.STORE_FILE_PATTERN:format(userId)
  LuaUserDataIO.WriteUserData(filePath, "RealNameAuthInfo", authInfo)
end
def.method("=>", "boolean").HasAuthorizeHistory = function(self)
  local userId = self:GetUserId()
  local filePath = RealNameAuthMgr.STORE_FILE_PATTERN:format(userId)
  if not LuaUserDataIO.IsUserDataExist(filePath) then
    return false
  end
  local userData = LuaUserDataIO.ReadUserData(filePath)
  if userData == nil then
    return false
  end
  return userData.hasAuthorized == true
end
def.method("function").CheckAuthStatus = function(self, callback)
  if self:HasAuthorizeHistory() then
    _G.SafeCallback(callback, true)
    return
  end
  local infoCache = self.m_firstRegInfoCache
  if infoCache then
    local curTimestamp = os.time()
    if math.abs(curTimestamp - infoCache.timestamp) > RealNameAuthMgr.FIRST_REG_INFO_CACHE_TIME then
      self.m_firstRegInfoCache = nil
    else
      _G.SafeCallback(callback, infoCache.hasAuthorized)
      return
    end
  end
  self:CheckFirstRegInfo(function(info)
    if info then
      _G.SafeCallback(callback, info.hasAuthorized)
    else
      _G.SafeCallback(callback, nil)
    end
  end)
end
def.method().Clear = function(self)
  self.m_firstRegInfoCache = nil
end
def.static("table", "table").OnReLogin = function(params, context)
  instance:Clear()
end
return RealNameAuthMgr.Commit()
