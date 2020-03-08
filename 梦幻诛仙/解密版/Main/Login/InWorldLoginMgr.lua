local Lplus = require("Lplus")
local InWorldLoginMgr = Lplus.Class("InWorldLoginMgr")
local LoginUIMgr = require("Main.Login.LoginUIMgr")
local LoginModule = Lplus.ForwardDeclare("LoginModule")
local netData = require("netio.netdata")
local ECGame = Lplus.ForwardDeclare("ECGame")
local LoadingMgr = require("Main.Common.LoadingMgr")
local def = InWorldLoginMgr.define
local PreloadResType = {PROTOCOL = 1, PROTOCOL_FAKE = 2}
local instance
def.static("=>", InWorldLoginMgr).Instance = function()
  if instance == nil then
    instance = InWorldLoginMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_SERVER_SUCCESS, InWorldLoginMgr.OnLoginServerSuccess)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_LOADING_FINISHED, InWorldLoginMgr.OnLoadingFinished)
end
def.method("table", "=>", "boolean").Reconnect = function(self, params)
  local params = params or {}
  local loginModule = LoginModule.Instance()
  if loginModule:IsInWorld() then
    gmodule.network.disConnect()
    loginModule:LeaveWorld(LoginModule.LeaveWorldReason.RECONNECT)
    if params.needLoading then
      self:StartLoading()
    end
  end
  loginModule.loginTarget = LoginModule.LoginTarget.Role
  loginModule:LoginEx(nil)
  return true
end
local protTimerId
def.method().StartLoading = function(self)
  local prefab = GameUtil.SyncLoad(RESPATH.PREFAB_LODING_PANEL_RES)
  LoadingMgr.Instance():StartLoading(LoadingMgr.LoadingType.InWorld, {
    [PreloadResType.PROTOCOL] = 1,
    [PreloadResType.PROTOCOL_FAKE] = 80
  }, nil, nil)
  local progress = 0
  local count = 0
  local function fakeProtoclUpdate(...)
    protTimerId = GameUtil.AddGlobalTimer(0.1, true, function()
      if protTimerId == nil then
        return
      end
      if LoadingMgr.Instance().loadingType ~= LoadingMgr.LoadingType.InWorld then
        protTimerId = nil
        return
      end
      progress = progress + 0.2
      count = count + 1
      local val = math.log10(1 + progress)
      if val >= 1 then
        val = 1
      end
      LoadingMgr.Instance():UpdateTaskProgress(PreloadResType.PROTOCOL_FAKE, val)
      if val < 1 then
        fakeProtoclUpdate()
      else
        protTimerId = nil
      end
    end)
  end
  fakeProtoclUpdate()
end
def.method().Clear = function(self)
end
def.static("table", "table").OnLoginServerSuccess = function()
  if require("Main.Login.CrossServerLoginMgr").Instance():IsCrossingServer() then
    return
  end
  if LoginModule.Instance():IsInWorld() then
    LoginModule.Instance():ReLoginRole()
  end
end
def.static("table", "table").OnLoadingFinished = function()
  if LoadingMgr.Instance().loadingType == LoadingMgr.LoadingType.InWorld then
    LoadingMgr.Instance():UpdateTaskProgress(PreloadResType.PROTOCOL, 1)
    LoadingMgr.Instance():UpdateTaskProgress(PreloadResType.PROTOCOL_FAKE, 1)
    protTimerId = nil
  end
end
return InWorldLoginMgr.Commit()
