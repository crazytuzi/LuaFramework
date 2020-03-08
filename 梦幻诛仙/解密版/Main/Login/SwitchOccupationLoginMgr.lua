local Lplus = require("Lplus")
local SwitchOccupationLoginMgr = Lplus.Class("SwitchOccupationLoginMgr")
local LoginUIMgr = require("Main.Login.LoginUIMgr")
local LoginModule = Lplus.ForwardDeclare("LoginModule")
local netData = require("netio.netdata")
local ECGame = Lplus.ForwardDeclare("ECGame")
local LoadingMgr = require("Main.Common.LoadingMgr")
local def = SwitchOccupationLoginMgr.define
local PreloadResType = {PROTOCOL = 1, PROTOCOL_FAKE = 2}
local instance
def.static("=>", SwitchOccupationLoginMgr).Instance = function()
  if instance == nil then
    instance = SwitchOccupationLoginMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_LOADING_FINISHED, SwitchOccupationLoginMgr.OnLoadingFinished)
end
def.method("number", "number").ReconnectAs = function(self, occupation, gender)
  require("Main.Login.InWorldLoginMgr").Instance():Reconnect({needLoading = false})
  self:StartLoading(occupation, gender)
end
local protTimerId
def.method("number", "number").StartLoading = function(self, occupation, gender)
  local loadingPanel = require("GUI.SwitchOccupationLoadingPanel").Instance()
  local imagePath = require("Main.MultiOccupation.MultiOccupationModule").Instance():GetOccupationLoadingImage(occupation, gender)
  loadingPanel:SetBackgroundImage(imagePath)
  LoadingMgr.Instance():StartLoadingEx(LoadingMgr.LoadingType.SwitchOccupation, {
    [PreloadResType.PROTOCOL] = 1,
    [PreloadResType.PROTOCOL_FAKE] = 80
  }, nil, nil, loadingPanel)
  local progress = 0
  local count = 0
  local function fakeProtoclUpdate(...)
    protTimerId = GameUtil.AddGlobalTimer(0.1, true, function()
      if protTimerId == nil then
        return
      end
      if LoadingMgr.Instance().loadingType ~= LoadingMgr.LoadingType.SwitchOccupation then
        protTimerId = nil
        return
      end
      progress = progress + 0.5
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
def.static("table", "table").OnLoadingFinished = function()
  if LoadingMgr.Instance().loadingType == LoadingMgr.LoadingType.SwitchOccupation then
    LoadingMgr.Instance():UpdateTaskProgress(PreloadResType.PROTOCOL, 1)
    LoadingMgr.Instance():UpdateTaskProgress(PreloadResType.PROTOCOL_FAKE, 1)
    protTimerId = nil
  end
end
return SwitchOccupationLoginMgr.Commit()
