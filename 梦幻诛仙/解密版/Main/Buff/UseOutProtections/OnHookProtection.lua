local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local CommonProtection = import(".CommonProtection")
local OnHookProtecttion = Lplus.Extend(CommonProtection, CUR_CLASS_NAME)
local def = OnHookProtecttion.define
def.override().TakeProtection = function(self)
  if self:HasTeam() and not self:IsHeroACaptain() then
    self:LeaveTeamTemporarily()
  end
  self:StopOnHook()
end
def.method().StopOnHook = function(self)
  Debug.LogWarning("Stop OnHook, because of BaoShiDu not enough")
  gmodule.moduleMgr:GetModule(ModuleId.HERO):StopPatroling()
end
return OnHookProtecttion.Commit()
