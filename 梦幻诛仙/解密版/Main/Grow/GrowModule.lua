local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local GrowModule = Lplus.Extend(ModuleBase, "GrowModule")
require("Main.module.ModuleId")
local GrowUtils = require("Main.Grow.GrowUtils")
local def = GrowModule.define
local GrowAchievementMgr = import(".GrowAchievementMgr")
local mgrList = {
  import(".GrowUIMgr", CUR_CLASS_NAME),
  import(".DailyGoalMgr", CUR_CLASS_NAME),
  GrowAchievementMgr
}
def.field("boolean").m_hasNotice = false
local instance
def.static("=>", GrowModule).Instance = function()
  if nil == instance then
    instance = GrowModule()
    instance.m_moduleId = ModuleId.GROW
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  for i, mgr in ipairs(mgrList) do
    mgr.Instance():Init()
  end
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grow.SSynLevelGuideInfo", GrowAchievementMgr.OnSSynLevelGuideInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grow.SSynLevelGuideSchedule", GrowAchievementMgr.OnSSynLevelGuideSchedule)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grow.SSynFunctionOpenInfo", GrowAchievementMgr.OnSSynFunctionOpenInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.grow.SSynFunctionOpenSchedule", GrowAchievementMgr.OnSSynFunctionOpenSchedule)
end
def.override().OnReset = function(self)
  self.m_hasNotice = false
  for i, mgr in ipairs(mgrList) do
    mgr.Instance():OnReset()
  end
end
def.method("=>", "boolean").HasNotice = function(self)
  return self.m_hasNotice
end
def.method().CheckNotice = function(self)
  local isNowHasNotice = self:_HasNotice()
  if isNowHasNotice == self.m_hasNotice then
    return
  end
  self.m_hasNotice = isNowHasNotice
  Event.DispatchEvent(ModuleId.GROW, gmodule.notifyId.Grow.GROW_NOTICE_CHANGE, {
    self.m_hasNotice
  })
end
def.method("=>", "boolean")._HasNotice = function(self)
  local GrowAchievementMgr = import(".GrowAchievementMgr", CUR_CLASS_NAME)
  if GrowAchievementMgr.Instance():HasAwardToDraw() then
    return true
  end
  return false
end
return GrowModule.Commit()
