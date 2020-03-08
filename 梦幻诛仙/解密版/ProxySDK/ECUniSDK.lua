local Lplus = require("Lplus")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ECUniSDK = Lplus.Class("ECUniSDK")
local def = ECUniSDK.define
def.const("table").CHANNELTYPE = {
  EFUNTW = "efuntw",
  EFUNHK = "efunhk",
  LOONG = "LoongSDK"
}
def.field("boolean").m_IsLogin = false
def.field("string").m_token = ""
def.field("table").m_CallBack = function()
  return {}
end
def.field("string").m_channelType = ""
local instance
local inited = false
local function onInit(actionName, param)
  if not inited and instance then
    instance:onInit()
    inited = true
  end
end
local function onAction(actionName, param)
  warn("callback action name: ", actionName, param, instance)
  if instance then
    if actionName == "onInit" then
      onInit()
    elseif actionName == "onLogin" then
      instance:onLogin(param)
    elseif actionName == "onPay" then
      instance:onPay(param)
    elseif actionName == "onLogout" then
      instance:onLogout(param)
    elseif actionName == "onShare" then
      instance:onShare()
    else
      instance:onOtherAction(actionName, param)
    end
  end
end
def.static().Create = function()
  if instance then
    return
  end
  UniSDK.init({onAction = onAction})
  local channeltype = UniSDK.action("getChannelType", {})
  warn("action getChannelType", channeltype)
  if channeltype == ECUniSDK.CHANNELTYPE.EFUNTW or channeltype == ECUniSDK.CHANNELTYPE.EFUNHK then
    local sdk = require("ProxySDK.EFunSDK")
    instance = sdk()
  elseif channeltype == ECUniSDK.CHANNELTYPE.LOONG then
    local sdk = require("ProxySDK.ZLSDKAbroad")
    instance = sdk()
  else
    instance = ECUniSDK()
  end
  onInit()
end
def.static("=>", ECUniSDK).Instance = function()
  if instance then
    return instance
  else
    ECUniSDK.Create()
    return instance
  end
end
def.virtual().onInit = function(self)
end
def.method("string", "=>", "boolean").SDKIS = function(self, channelType)
  return self:GetChannelType() == channelType
end
def.virtual("=>", "boolean").IsLogin = function(self)
  return self.m_IsLogin
end
def.virtual("=>", "string").GetToken = function(self)
  return self.m_token
end
def.virtual("=>", "string").GetUniAppId = function(self)
  local appid = UniSDK.action("getAppId", {})
  return appid
end
def.virtual("=>", "string").GetChannelType = function(self)
  if self.m_channelType ~= "" then
    return self.m_channelType
  end
  local channeltype = UniSDK.action("getChannelType", {})
  self.m_channelType = channeltype
  return self.m_channelType
end
def.virtual("table").onOtherAction = function(self, param)
end
def.virtual().Init = function(self)
end
def.virtual("table").Login = function(self, paramTable)
  UniSDK.action("login", paramTable)
  TraceHelper.trace("LuaCallSDK")
end
def.virtual("table").onLogin = function(self, paramTable)
  TraceHelper.trace("OnloginCallBack")
  local userId = paramTable.userId
  local token = paramTable.token
  if not token then
    warn("Login Fail")
    return
  end
  TraceHelper.trace("LoginSuccess")
  local game = ECGame.Instance()
  if game:GetGameState() == _G.GameState.GameWorld then
    warn("In Game World")
    return
  end
  game:SetUserName(userId, token, "", 0)
  self.m_IsLogin = true
  self.m_token = paramTable.token
  Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_SUCCESS, nil)
end
def.virtual("table").Logout = function(self, paramTable)
  UniSDK.action("logout", {})
end
def.virtual("table").onLogout = function(self, paramTable)
  self.m_IsLogin = false
end
def.virtual("table").Pay = function(self, paramTable, payCallBack)
  local param = {}
  param.userId = paramTable.userId or ""
  param.roleId = paramTable.roleId or ""
  param.level = paramTable.roleLv or ""
  param.roleName = paramTable.roleName or ""
  param.serverId = paramTable.zoneId or ""
  param.serverName = paramTable.serverName or ""
  param.productId = paramTable.productId or ""
  param.price = paramTable.price or "0"
  param.orderId = paramTable.remark or ""
  param.callBackUrl = paramTable.callBackUrl or ""
  param.gankType = paramTable.gankType or ""
  param.dpsType = self.m_coinInfo and self.m_coinInfo.info or "2"
  param.ext = string.format("{\"NotifyUrl\":\"%s\"}", paramTable.callBackUrl)
  self.m_CallBack.Pay = payCallBack
  warn("UniPay param:", pretty(param))
  UniSDK.action("pay", param)
end
def.virtual("table").onPay = function(self, paramTable)
  local payCallBack = self.m_CallBack.Pay
  if payCallBack then
    payCallBack(paramTable)
  end
end
def.virtual("table").Share = function(self, paramTable)
end
def.virtual("table").onShare = function(self, paramTable)
end
ECUniSDK.Commit()
return ECUniSDK
