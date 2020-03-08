local MODULE_NAME = (...)
local Lplus = require("Lplus")
local GangTeamMgr = Lplus.Class(MODULE_NAME)
local Cls = GangTeamMgr
local def = Cls.define
local instance
local GangTeamData = require("Main.Gang.GangTeam.data.GangTeamData")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local txtConst = textRes.Gang.GangTeam
def.field("table")._gangTeamData = nil
def.const("number").MAX_MEMBER_COUNT = 5
def.const("string").HYPERLINK_PREFIX = "gangteam"
def.static("=>", Cls).Instance = function()
  if instance == nil then
    instance = Cls()
    instance._gangTeamData = GangTeamData.Instance()
  end
  return instance
end
def.method().Init = function(self)
  require("Main.Gang.GangTeam.GangTeamProtocol").Init()
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_InfoChanged, Cls.OnGangInfoChg)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, Cls.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemeberQuited, Cls.OnGangMemberQuit)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.ApplicantsListChg, Cls.OnApplicantsChg)
end
def.static("table", "table").OnGangInfoChg = function(p, c)
  if p == nil or p.gangInfo == nil then
    return
  end
  local gangTeams = p.gangInfo.teams
  instance._gangTeamData:SetTeamsData(gangTeams)
end
def.static("table", "table").OnLeaveWorld = function(p, c)
  instance._gangTeamData = GangTeamData.Instance()
  instance._gangTeamData:Reset()
end
def.static("table", "table").OnGangMemberQuit = function(p, c)
  local roleId = p[1]
  instance._gangTeamData:RmvApplyee(roleId)
end
def.static("table", "table").OnApplicantsChg = function(p, c)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.GangTeamRedDotChg, nil)
end
def.static("=>", "boolean").IsFeatureOpen = function(self)
  local bFeatureOpen = FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_GANG_TEAM)
  return bFeatureOpen
end
def.static("=>", "boolean").IsShowRedDot = function(self)
  local applicantList = GangTeamMgr.GetData():GetApplyList()
  local bShowRed = #applicantList > 0
  return bShowRed
end
def.static("=>", "table").GetData = function()
  return instance._gangTeamData
end
def.static("=>", "table").GetProtocol = function()
  return require("Main.Gang.GangTeam.GangTeamProtocol")
end
def.static("table", "table").formateGangMemberInfo = function(roleInfo, gangMemInfo)
  if roleInfo == nil or gangMemInfo == nil then
    return
  end
  roleInfo.name = gangMemInfo.name
  roleInfo.level = gangMemInfo.level
  roleInfo.occupationId = gangMemInfo.occupationId
  roleInfo.gender = gangMemInfo.gender
  roleInfo.teamMemberNum = gangMemInfo.teamMenberNum or 0
  if gangMemInfo.offlineTime == -1 then
    roleInfo.onlineStatus = 1
  else
    roleInfo.onlineStatus = 0
  end
  roleInfo.roleId = gangMemInfo.roleId
  roleInfo.avatarId = gangMemInfo.avatarId
  roleInfo.avatarFrameId = gangMemInfo.avatar_frame
  local gangData = require("Main.Gang.GangModule").Instance().data
  roleInfo.gangId = gangData:GetGangId()
  roleInfo.gangName = gangData:GetGangName()
end
def.static("string", "string", "userdata", "number").SendGangAnno = function(roleName, teamName, teamid, msgType)
  local ChatModule = require("Main.Chat.ChatModule")
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local text = ("{" .. Cls.HYPERLINK_PREFIX .. ":,%s,%s,%s,%d,%s}"):format(teamid:tostring(), teamName, roleName, msgType, txtConst[71])
  ChatModule.Instance():SendChannelMsg(text, ChatMsgData.Channel.FACTION, false)
end
def.method("table", "=>", "string").GetInfoPack = function(self, team)
end
def.static("userdata", "=>", "table").GetGangRoleInfo = function(roleId)
  return require("Main.Gang.GangModule").Instance().data:GetMemberInfoByRoleId(roleId)
end
def.static("=>", "table").GetGangMemberList = function()
  return require("Main.Gang.GangModule").Instance().data:GetMemberList()
end
def.static("string").OnBtnGangTeamLink = function(str)
  local strs = string.split(str, "_")
  local teamid = Int64.new(strs[2])
  local myTeam = instance._gangTeamData:GetMyTeam()
  if myTeam ~= nil then
    Toast(txtConst[22])
  else
    Cls.GetProtocol().sendJoinGangTeamReq(teamid)
  end
end
return Cls.Commit()
