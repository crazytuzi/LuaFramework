local Lplus = require("Lplus")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ECProxySDK = Lplus.Class("ECProxySDK")
local def = ECProxySDK.define
def.field("boolean").m_IsLogin = false
def.field("boolean").m_IsGuest = true
def.field("string").m_ProxySDKName = ""
def.field("userdata").m_ProxySDK = nil
local PROXYSDK_INDEX = {
  KuaiYong = 1,
  PP = 2,
  TB = 3
}
local instance
def.static("=>", ECProxySDK).Instance = function()
  if not instance then
    instance = ECProxySDK()
  end
  return instance
end
def.method("=>", "boolean").IsLogin = function(self)
  return self.m_IsLogin
end
def.method("=>", "boolean").IsGuest = function(self)
  return self.m_IsGuest
end
def.method("=>", "string").GetProxySDKName = function(self)
  return self.m_ProxySDKName
end
def.method("string").OnQuickLogin = function(self, tokenKey)
  self.m_IsGuest = true
  self.m_IsLogin = true
  local game = ECGame.Instance()
  warn(self.m_ProxySDKName, "Lua\229\191\171\233\128\159\231\153\187\229\189\149\230\136\144\229\138\159", tokenKey)
  game:SetUserName("$" .. self.m_ProxySDKName, tokenKey, "", 0)
  Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_SUCCESS, nil)
end
def.method("table").OnLogin = function(self, paramTable)
  self.m_IsGuest = false
  self.m_IsLogin = true
  local game = ECGame.Instance()
  warn(self.m_ProxySDKName, "Lua\228\191\174\230\148\185\231\153\187\229\189\149\230\136\144\229\138\159 userName", paramTable["1"], "token", paramTable["2"])
  game:SetUserName(paramTable["1"], paramTable["2"], "", 0)
  Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_SUCCESS, nil)
end
def.method("number", "string", "number").OnLoginError = function(self, type, info, errCode)
  warn("Lua \231\153\187\229\189\149\229\164\177\232\180\165", type, info, errCode)
  FlashTipMan.FlashTip(StringTable.Get(15085))
end
def.method("string").OnUserLogOut = function(self, guid)
  self.m_IsLogin = false
  local logout = require("C2S.logout")
  local cmd = logout.new()
  cmd.type = 0
  cmd.offline_practice_tid = 0
  ECGame.Instance().m_Network:SendGameData(cmd)
  print(cmd.type, "Lua\233\128\128\229\135\186\231\153\187\229\189\149\227\128\130\227\128\130.", guid)
end
def.method().OnCancelUpdate = function(self)
  print("Lua\229\143\150\230\182\136\230\155\180\230\150\176")
end
def.method("number").OnClosePay = function(self, pageCode)
  print("Lua\229\133\179\233\151\173\233\161\181\233\157\162", pageCode)
  local game = ECGame.Instance()
  if pageCode == 1 then
    self.m_IsLogin = false
  elseif pageCode == 2 then
    self.m_IsLogin = false
  elseif pageCode == 3 then
    self.m_IsLogin = false
  elseif pageCode == 4 then
  end
end
def.method("number").OnAlipay = function(self, result)
  print("Lua\230\148\175\228\187\152\229\174\157\230\148\175\228\187\152\229\155\158\232\176\131", result)
end
def.method("number").OnUPPayPlugin = function(self, result)
  print("Lua\233\147\182\232\129\148\230\148\175\228\187\152\229\155\158\232\176\131", result)
end
def.method("number").OnPlaceTheOrderSucc = function(self, stats)
  warn("Lua \228\184\139\229\141\149\229\155\158\232\176\131", stats)
end
def.method("number", "string").OnPaymentSucc = function(self, stats, info)
  warn("Lua \230\148\175\228\187\152\229\155\158\232\176\131 ", stats, info)
  FlashTipMan.FlashTip("\230\148\175\228\187\152\229\155\158\232\176\131")
end
def.method("number").OnDeliverySucc = function(self, stats)
  warn("Lua \229\143\145\232\180\167\229\155\158\232\176\131", stats)
end
def.method("=>", "string").GetUserInfo = function(self)
  warn("lua get user info function")
  local roleid = ECGame.Instance().m_HostPlayer.ID
  local info = ECGame.Instance().m_HostPlayer.InfoData
  if roleid and info.Name and info.Lv then
    local userInfo = string.format("{\"roleid\":\"%s\",\"rolename\":\"%s\",\"rolelv\":\"%d\"}", LuaUInt64.ToString(roleid), info.Name, info.Lv)
    return userInfo
  else
    return "{\"roleid\":\"-1\",\"rolename\":\"\",\"rolelv\":\"0\"}"
  end
end
def.method("=>", "string").GetZoneInfo = function(self)
  warn("lua get Zone info function")
  local zoneId = ECGame.Instance().m_ZoneID
  local zoneName = "zoneName"
  if zoneId and zoneName then
    local svrInfo = string.format("{\"zoneid\":\"%d\",\"zonename\":\"%s\"}", zoneId, zoneName)
    return svrInfo
  else
    return "{\"zoneid\":\"-1\",\"zonename\":\"\"}"
  end
end
def.method().InitProxySDK = function(self)
  local luaCallBackFunction = {
    OnQuickLogin = function(tokenKey)
      self:OnQuickLogin(tokenKey)
    end,
    OnLogin = function(paramTable)
      self:OnLogin(paramTable)
    end,
    OnLoginError = function(type, info, errCode)
      self:OnLoginError(type, info, errCode)
    end,
    OnUserLogOut = function(guid)
      self:OnUserLogOut(guid)
    end,
    OnCancelUpdate = function()
      self:OnCancelUpdate()
    end,
    OnClosePage = function(pageCode)
      self:OnClosePay(pageCode)
    end,
    OnAlipay = function(result)
      self:OnAlipay(result)
    end,
    OnUPPayPlugin = function(result)
      self:OnUPPayPlugin(result)
    end,
    OnPlaceTheOrderSucc = function(stats)
      self:OnPlaceTheOrderSucc(stats)
    end,
    OnPaymentSucc = function(stats, info)
      self:OnPaymentSucc(stats, info)
    end,
    OnDeliverySucc = function(stats)
      self:OnDeliverySucc(stats)
    end,
    GetUserInfo = function()
      return self:GetUserInfo()
    end,
    GetZoneInfo = function()
      return self:GetZoneInfo()
    end
  }
  self.m_ProxySDK, self.m_ProxySDKName = proxySDK.Init(luaCallBackFunction)
  warn("\229\136\157\229\167\139\229\140\150\230\184\160\233\129\147SDK", self.m_ProxySDKName)
end
def.method().ShowUserCenter = function(self)
  if self.m_ProxySDK then
    proxySDK.ShowUserCenter(self.m_ProxySDK)
  else
    warn("sdk\228\184\141\229\173\152\229\156\168")
  end
end
def.method().SetUpUser = function(self)
  if self.m_ProxySDK then
    proxySDK.SetUpUser(self.m_ProxySDK)
  else
    warn("sdk\228\184\141\229\173\152\229\156\168")
  end
end
def.method().UserBackToLog = function(self)
  if self.m_ProxySDK then
    proxySDK.UserBackToLog(self.m_ProxySDK)
  else
    warn("sdk\228\184\141\229\173\152\229\156\168")
  end
end
def.method().UserLogOut = function(self)
  if self.m_ProxySDK then
    proxySDK.UserLogOut(self.m_ProxySDK)
  else
    warn("sdk\228\184\141\229\173\152\229\156\168")
  end
end
def.method("string", "string", "number", "string").ShowPayWith = function(self, dealseq, fee, gamesvr, subjectName)
  if self.m_ProxySDK then
    warn("Lua\229\135\134\229\164\135\230\148\175\228\187\152")
    proxySDK.ShowPayWith(self.m_ProxySDK, dealseq, fee, tostring(gamesvr), subjectName)
  else
    warn("sdk\228\184\141\229\173\152\229\156\168")
  end
end
def.method("string", "number", "string", "string", "string").Payment = function(self, productID, fee, orderID, callbackURL, extInfo)
  if self.m_ProxySDK then
    local zoneID = ECGame.Instance().m_ZoneID
    warn(zoneID, "Lua Payment--------------", productID, fee, orderID, callbackURL, extInfo)
    proxySDK.PaymentForProducts(self.m_ProxySDK, productID, fee, orderID, zoneID, callbackURL, extInfo)
  else
    warn("sdk\228\184\141\229\173\152\229\156\168")
  end
end
def.method().CleanProxySDK = function(self)
  if self.m_ProxySDK then
    warn("Lua\230\184\133\231\144\134ProxySDK")
    proxySDK.CleanProxySDK(self.m_ProxySDK)
    self.m_ProxySDK = nil
  else
    warn("CleanProxySDK,sdk\228\184\141\229\173\152\229\156\168")
  end
end
ECProxySDK.Commit()
return ECProxySDK
