local Lplus = require("Lplus")
local FreeFlowMgr = Lplus.Class("FreeFlowMgr")
local ECMSDK = require("ProxySDK.ECMSDK")
local Json = require("Utility.json")
local DeviceUtility = require("Utility.DeviceUtility")
local def = FreeFlowMgr.define
def.const("table").FreeType = {None = 0, Free = 1}
def.const("table").CCType = {
  CUCC = 0,
  CTC = 1,
  CMCC = 2
}
def.const("string").H5_URL = "https://chong.qq.com/mobile/special_traffic_mhzx.shtml"
def.const("table").OutUidType = {WECHAT = 1, QQ = 2}
def.const("string").CHANNEL = "1229_MengZhuApp"
def.const("string").SECRET_KEY = "lvbdkgjAa0dlAkaga5plfkj3na0L7kKmlafd"
local CONNECT_TIMEOUT_SEC = 15
local CONNECT_MAX_FAIL_TIMES = 2
local CONTINUOUS_FAILUER_DURATION = 60
def.field("table").m_freeFlowInfo = nil
def.field("boolean").m_reqing = false
def.field("table").m_failures = nil
local instance
def.static("=>", FreeFlowMgr).Instance = function()
  if instance == nil then
    instance = FreeFlowMgr()
  end
  return instance
end
def.method().Init = function(self)
end
def.method("=>", "boolean").IsOpen = function(self)
  if ClientCfg.GetSDKType() ~= ClientCfg.SDKTYPE.MSDK then
    printInfo(string.format("FreeFlowMgr: sdkType(%d) ~= ClientCfg.SDKTYPE.MSDK", ClientCfg.GetSDKType()))
    return false
  end
  if LoginPlatform == MSDK_LOGIN_PLATFORM.WX or LoginPlatform == MSDK_LOGIN_PLATFORM.QQ then
    return true
  else
    printInfo(string.format("FreeFlowMgr: LoginPlatform(%d) not qq or wechat", LoginPlatform))
    return false
  end
end
def.method("=>", "boolean").IsFeatureOpen = function(self)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local isOpen = _G.IsFeatureOpen(Feature.TYPE_FREE_FLOW)
  return isOpen
end
def.method("=>", "boolean").IsDebugOpen = function(self)
  return false
end
def.method().OpenSpecialTrafficURL = function(self)
  local url = self:GetSpecialTrafficURL()
  ECMSDK.OpenURL(url, ECMSDK.SCREENDIR.PORTRAIT)
end
def.method("=>", "string").GetSpecialTrafficURL = function(self)
  if ClientCfg.GetSDKType() ~= ClientCfg.SDKTYPE.MSDK then
    error("msdk excepted")
  end
  local msdkInfo = ECMSDK.GetMSDKInfo()
  local url = FreeFlowMgr.H5_URL
  local outUidType, accessToken
  if LoginPlatform == MSDK_LOGIN_PLATFORM.WX then
    outUidType = FreeFlowMgr.OutUidType.WECHAT
    accessToken = ""
  else
    outUidType = FreeFlowMgr.OutUidType.QQ
    accessToken = msdkInfo.accessToken
  end
  local timestamp = os.time()
  local outUid = msdkInfo.openId
  local secret_key = FreeFlowMgr.SECRET_KEY
  local channel = FreeFlowMgr.CHANNEL
  local strTable = {
    outUid,
    outUidType,
    timestamp,
    channel,
    secret_key
  }
  local token = GameUtil.md5(table.concat(strTable))
  token = string.lower(token)
  local params = {
    OutUid = outUid,
    OutUidType = outUidType,
    Token = token,
    Timestamp = timestamp,
    Channel = channel,
    AccessToken = accessToken
  }
  return _G.AttachParams2URL(url, params)
end
def.method("function").RequestFreeFlowInfo = function(self, callback)
  if self:IsInfoExpire() then
    self.m_freeFlowInfo = nil
    self:GetFreeFlowInfoAsync(function(freeFlowInfo)
      self.m_freeFlowInfo = self:ConvertFreeFlowInfo(freeFlowInfo)
      _G.SafeCallback(callback, self.m_freeFlowInfo)
    end)
  else
    _G.SafeCallback(callback, self.m_freeFlowInfo)
  end
end
def.method("=>", "boolean").IsInfoExpire = function(self)
  if self.m_freeFlowInfo == nil then
    return true
  end
  local curTime = os.time()
  local expireTime = self.m_freeFlowInfo.expire
  if curTime >= expireTime then
    return true
  end
  return false
end
def.method("=>", "boolean").IsFreeForCurUser = function(self)
  if self.m_freeFlowInfo == nil then
    return false
  end
  return self.m_freeFlowInfo.isFree == FreeFlowMgr.FreeType.Free
end
def.method("function").GetFreeFlowInfoAsync = function(self, callback)
  local debug_open = self:IsDebugOpen()
  local url, appid, openid, channel
  if debug_open then
    url = "http://jira.oa.zulong.com"
    appid = "a"
    openid = "o"
    channel = "c"
  else
    url = _G.GetDirVersionService("get_free_flow_info")
    if url == nil then
      warn("get_free_flow_info service not found in version.xml!")
      _G.SafeCallback(callback, nil)
      return
    end
    if ClientCfg.GetSDKType() ~= ClientCfg.SDKTYPE.MSDK then
      warn("only msdk support free flow!")
      _G.SafeCallback(callback, nil)
      return
    end
    local msdkInfo = ECMSDK.GetMSDKInfo()
    if msdkInfo == nil then
      warn("msdkInfo is nil!")
      _G.SafeCallback(callback, nil)
      return
    end
    appid = msdkInfo.appId
    openid = msdkInfo.openId
    loginPlatform = LoginPlatform
    if loginPlatform == MSDK_LOGIN_PLATFORM.QQ then
      channel = "qq"
    elseif loginPlatform == MSDK_LOGIN_PLATFORM.WX then
      channel = "wechat"
    end
    if channel == nil then
      warn("channel not valid!", debug.traceback())
      _G.SafeCallback(callback, nil)
      return
    end
  end
  local param = {
    appid = appid,
    openid = openid,
    channel = channel
  }
  self:GetFreeFlowInfoInner(url, param, function(resParam, bytes)
    if bytes == nil then
      if not self:IsDebugOpen() then
        warn(string.format("http post(%s) failed!", url))
        _G.SafeCallback(callback, nil)
        return
      else
        warn("[FreeFlow]: enter debug mode")
      end
    end
    local res
    if self:IsDebugOpen() then
      res = {
        ret = 0,
        data = {
          ret = 0,
          freeFlowInfo = {
            isFree = 1,
            ltList = "10.236.100.25:19097;",
            ccType = 0,
            expire = os.time() + 1000000
          }
        }
      }
    else
      res = Json.decode(bytes:get_string())
    end
    if res.ret ~= 0 then
      print("res.ret ~= 0!", res.ret)
      print(res.msg)
      _G.SafeCallback(callback, nil)
      return
    end
    if 0 > res.data.ret then
      print("res.data.ret ~= 0!", res.data.ret)
      print(res.data.msg)
      _G.SafeCallback(callback, nil)
      return
    end
    _G.SafeCallback(callback, res.data.freeFlowInfo)
  end)
end
def.method("string", "table", "function").GetFreeFlowInfoInner = function(self, url, param, callback)
  local isTimeout = false
  local isFinish = false
  GameUtil.AddGlobalTimer(CONNECT_TIMEOUT_SEC, true, function(...)
    if isFinish then
      return
    end
    print("GetFreeFlowInfoInner: timeout")
    isTimeout = true
    callback(param, nil)
  end)
  url = _G.NormalizeHttpURL(url)
  local postData = ("appid=%s&openid=%s&channel=%s"):format(param.appid, param.openid, param.channel)
  GameUtil.httpPost(url, 0, postData, function(success, url, postId, bytes)
    if isTimeout then
      return
    end
    isFinish = true
    if not success then
      callback(param, nil)
    else
      callback(param, bytes)
    end
  end)
end
local pretty = function(obj)
  local uniqueTables = {}
  local ptostring = function(obj)
    local success, value = pcall(function()
      return tostring(obj)
    end)
    return success and value or "[unknow]"
  end
  local function prettyInner(obj, tname, iskey)
    if iskey then
      return ptostring(obj)
    elseif type(obj) == "table" then
      if uniqueTables[obj] == nil then
        tname = tname or "$"
        uniqueTables[obj] = tname
        local str = "{"
        for k, v in pairs(obj) do
          if obj ~= v then
            local pair = prettyInner(k, k, true) .. "=" .. prettyInner(v, tname .. "." .. ptostring(k))
            str = str .. (str == "{" and pair or ", " .. pair)
          end
        end
        return str .. "}"
      else
        return uniqueTables[obj]
      end
    elseif type(obj) == "string" then
      return string.format("%q", obj)
    else
      return ptostring(obj)
    end
  end
  return prettyInner(obj)
end
def.method("table", "=>", "table").ConvertFreeFlowInfo = function(self, freeFlowInfo)
  print("ConvertFreeFlowInfo\n", pretty(freeFlowInfo))
  if freeFlowInfo == nil then
    return nil
  end
  local convertedInfo = {}
  convertedInfo.isFree = freeFlowInfo.isFree == FreeFlowMgr.FreeType.Free
  convertedInfo.ccType = freeFlowInfo.ccType
  convertedInfo.expire = tonumber(freeFlowInfo.expire)
  local get_sockaddres = function(address_port_list_str)
    if address_port_list_str == nil or address_port_list_str == "" then
      return {}
    end
    local address_port_strs = address_port_list_str:split(";")
    local sockaddrs = {}
    for i, v in ipairs(address_port_strs) do
      local address_port = v:split(":")
      local address, port = unpack(address_port)
      if port then
        local sockaddr = {address = address, port = port}
        sockaddrs[#sockaddrs + 1] = sockaddr
      end
    end
    return sockaddrs
  end
  local ccName = DeviceUtility.GetNetworkProviderName()
  local deviceCCType = FreeFlowMgr.CCType[ccName]
  local ipList
  if convertedInfo.isFree and (deviceCCType == nil or deviceCCType == freeFlowInfo.ccType) then
    if freeFlowInfo.ccType == FreeFlowMgr.CCType.CUCC then
      ipList = freeFlowInfo.ltList
    elseif freeFlowInfo.ccType == FreeFlowMgr.CCType.CTC then
      ipList = freeFlowInfo.dxList
    elseif freeFlowInfo.ccType == FreeFlowMgr.CCType.CMCC then
      ipList = freeFlowInfo.ydList
    end
  end
  print(string.format("ccName=%s deviceCCType=%s freeFlowInfo.ccType=%d", ccName, tostring(deviceCCType), freeFlowInfo.ccType))
  convertedInfo.sockaddrs = get_sockaddres(ipList)
  return convertedInfo
end
def.method().RecordFreeFlowFailure = function(self)
  local timestamp = os.time()
  self.m_failures = self.m_failures or {}
  local failure = {timestamp = timestamp}
  table.insert(self.m_failures, failure)
  if #self.m_failures > CONNECT_MAX_FAIL_TIMES then
    table.remove(self.m_failures, 1)
  end
end
def.method("=>", "boolean").IsFrequentlyFail = function(self)
  if self.m_failures == nil then
    return false
  end
  if #self.m_failures < CONNECT_MAX_FAIL_TIMES then
    return false
  end
  local oldestTime = self.m_failures[1].timestamp
  local curTime = os.time()
  local interval = curTime - oldestTime
  if interval > CONTINUOUS_FAILUER_DURATION then
    return false
  end
  return true
end
def.method().ResetFailures = function(self)
  self.m_failures = nil
end
def.method().Clear = function(self)
  self.m_freeFlowInfo = nil
  self.m_reqing = false
end
return FreeFlowMgr.Commit()
