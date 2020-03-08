local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local CommonProtection = Lplus.Class(CUR_CLASS_NAME)
local TeamData = require("Main.Team.TeamData")
local def = CommonProtection.define
def.method().TakeProtections = function(self)
  require("Main.Buff.BUffUIMgr").QuerySupplementNutrition()
  self:TakeProtection()
end
def.virtual().TakeProtection = function(self)
end
def.method("=>", "boolean").HasTeam = function(self)
  return TeamData.Instance():HasTeam()
end
def.method("=>", "boolean").IsHeroACaptain = function(self)
  return TeamData.Instance():MeIsCaptain()
end
def.method().LeaveTeamTemporarily = function(self)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CTempLeaveReq").new())
end
return CommonProtection.Commit()
