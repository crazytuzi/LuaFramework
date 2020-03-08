local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local CommonProtection = import(".CommonProtection")
local ActivityProtection = Lplus.Extend(CommonProtection, CUR_CLASS_NAME)
local def = ActivityProtection.define
def.override().TakeProtection = function(self)
  if self:IsHeroACaptain() then
    self:StopAction()
  elseif self:HasTeam() then
    self:LeaveTeamTemporarily()
  end
end
def.virtual().StopAction = function(self)
  warn("no specified activity to stop")
end
def.method("number").StopDoingTaskPathFind = function(self, graphId)
  local taskModule = gmodule.moduleMgr:GetModule(ModuleId.TASK)
  taskModule:StopDoingTaskPathFind(graphId)
end
return ActivityProtection.Commit()
