local Lplus = require("Lplus")
local ResourceUpdateMgr = Lplus.Class("ResourceUpdateMgr")
local ECGame = require("Main.ECGame")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local VersionKeyPolicy = import(".version_key_policy.VersionKeyPolicy")
local VersionKeyPolicyFactory = import(".version_key_policy.VersionKeyPolicyFactory")
local def = ResourceUpdateMgr.define
def.field("number").m_localVersion = 0
def.field("number").m_resourceVersion = 0
def.field("number").m_compatiableVersion = 0
def.field(VersionKeyPolicy).m_versionKeyPolicy = nil
local instance
def.static("=>", ResourceUpdateMgr).Instance = function()
  if instance == nil then
    instance = ResourceUpdateMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.m_localVersion = ECGame.Instance():getClientVersion()
  self.m_versionKeyPolicy = VersionKeyPolicyFactory.Create()
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, ResourceUpdateMgr.OnEnterWorld)
end
def.method("=>", "number").GetResourceVersionKey = function(self)
  return self.m_versionKeyPolicy:GetResourceVersionKey()
end
def.method("=>", "number").GetCompatiableVersionKey = function(self)
  local rvKey = self:GetResourceVersionKey()
  return bit.bor(rvKey, 16)
end
def.method("number", "number").SetResourceVersion = function(self, resourceVersion, compatiableVersion)
  self.m_resourceVersion = resourceVersion
  self.m_compatiableVersion = compatiableVersion
end
def.method("=>", "boolean").NeedForceUpdate = function(self)
  if GameUtil.IsEvaluation() and not IsEvaluationUpdate() then
    return false
  end
  return self.m_localVersion < self.m_compatiableVersion
end
def.method("=>", "boolean").NeedUpdate = function(self)
  if GameUtil.IsEvaluation() and not IsEvaluationUpdate() then
    return false
  end
  return self.m_localVersion < self.m_resourceVersion
end
def.method("=>", "boolean").CheckForceUpdate = function(self)
  if self:NeedForceUpdate() then
    gmodule.network.disConnect()
    Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.RESET_UI, nil)
    self:ShowForceUpdateDlg()
    return true
  end
  return false
end
def.method().ShowForceUpdateDlg = function(self)
  CommonConfirmDlg.ShowCerternConfirm(textRes.Common[52], textRes.Common[50], textRes.Common[54], function(i, tag)
    ECGame.Instance():Restart()
  end, nil)
end
def.method().ShowUpdateConfirm = function(self)
  CommonConfirmDlg.ShowConfirmCoundDown(textRes.Common[52], textRes.Common[53], textRes.Common[403], textRes.Common[404], 1, 15, function(i, tag)
    if i == 0 then
      gmodule.moduleMgr:GetModule(ModuleId.SYSTEM_SETTING):Restart()
    end
  end, {
    unique = ResourceUpdateMgr.ShowUpdateConfirm
  })
end
def.method().CheckToShowUpdateConfirm = function(self)
  if self:NeedUpdate() then
    if not _G.PlayerIsInFight() then
      self:ShowUpdateConfirm()
    else
      require("Main.Common.OutFightDo").Instance():Do(function()
        self:ShowUpdateConfirm()
      end, nil)
    end
  end
end
def.static("table", "table").OnEnterWorld = function(params)
  instance:CheckToShowUpdateConfirm()
end
return ResourceUpdateMgr.Commit()
