local MODULE_NAME = (...)
local Lplus = require("Lplus")
local GangTeamProtocol = Lplus.Class(MODULE_NAME)
local def = GangTeamProtocol.define
def.static().Init = function()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SCreateGangTeamBrd", GangTeamProtocol.OnSCreateGangTeamBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SAddGangTeamApplicantBrd", GangTeamProtocol.OnSAddGangTeamApplicantBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SRemoveGangTeamApplicantBrd", GangTeamProtocol.OnSRemoveGangTeamApplicantBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncGangTeamApplicants", GangTeamProtocol.OnSSyncGangTeamApplicants)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SAddGangTeamMemberBrd", GangTeamProtocol.OnSAddGangTeamMemberBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SInviteGangTeamTrs", GangTeamProtocol.OnSInviteGangTeamTrs)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SLeaveGangTeamBrd", GangTeamProtocol.OnSLeaveGangTeamBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SKickGangTeamMemberBrd", GangTeamProtocol.OnSKickGangTeamMemberBrd)
end
def.static("table").OnSCreateGangTeamBrd = function(p)
  local gangTeam = p.team
  warn(string.format("---------------------------------------OnSCreateGangTeamBrd: id=%d, name=%s", gangTeam.teamid, gangTeam.name))
end
def.static("table").OnSAddGangTeamApplicantBrd = function(p)
  warn(string.format("---------------------------------------OnSAddGangTeamApplicantBrd"))
end
def.static("table").OnSRemoveGangTeamApplicantBrd = function(p)
  warn(string.format("---------------------------------------OnSRemoveGangTeamApplicantBrd"))
end
def.static("table").OnSSyncGangTeamApplicants = function(p)
  warn(string.format("---------------------------------------OnSSyncGangTeamApplicants"))
end
def.static("table").OnSAddGangTeamMemberBrd = function(p)
  warn(string.format("---------------------------------------OnSAddGangTeamMemberBrd"))
end
def.static("table").OnSInviteGangTeamTrs = function(p)
  warn(string.format("---------------------------------------OnSInviteGangTeamTrs"))
end
def.static("table").OnSLeaveGangTeamBrd = function(p)
  warn(string.format("---------------------------------------OnSLeaveGangTeamBrd"))
end
def.static("table").OnSKickGangTeamMemberBrd = function(p)
  warn(string.format("---------------------------------------OnSKickGangTeamMemberBrd"))
end
def.static("string").sendCreateGangTeamReq = function(teamName)
  local p = require("netio.protocol.mzm.gsp.gang.CCreateGangTeamReq").new(teamName)
  gmodule.network.sendProtocol(p)
end
def.static("userdata").sendJoinGangTeamReq = function(teamId)
  local p = require("netio.protocol.mzm.gsp.gang.CJoinGangTeamReq").new(teamId)
  gmodule.network.sendProtocol(p)
end
def.static().sendAutoJoinGangTeamReq = function()
  local p = require("netio.protocol.mzm.gsp.gang.CAutoJoinGangTeamReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "boolean").sendJoinGangTeamRep = function(roleId, agree)
  local CJoinGangTeamRep = require("netio.protocol.mzm.gsp.gang.CJoinGangTeamRep")
  if agree then
    gmodule.network.sendProtocol(CJoinGangTeamRep.new(roleId, CJoinGangTeamRep.REPLY_AGREE))
  else
    gmodule.network.sendProtocol(CJoinGangTeamRep.new(roleId, CJoinGangTeamRep.REPLY_REFUSE))
  end
end
def.static().sendInviteGangTeamReq = function()
  local p = require("netio.protocol.mzm.gsp.gang.CInviteGangTeamReq").new()
  gmodule.network.sendProtocol(p)
end
def.static().sendInviteGangTeamRep = function()
  local p = require("netio.protocol.mzm.gsp.gang.CInviteGangTeamRep").new()
  gmodule.network.sendProtocol(p)
end
def.static().sendLeaveGangTeamReq = function()
  local p = require("netio.protocol.mzm.gsp.gang.CLeaveGangTeamReq").new()
  gmodule.network.sendProtocol(p)
end
def.static().sendKickGangTeamMemberReq = function()
  local p = require("netio.protocol.mzm.gsp.gang.CKickGangTeamMemberReq").new()
  gmodule.network.sendProtocol(p)
end
return GangTeamProtocol.Commit()
