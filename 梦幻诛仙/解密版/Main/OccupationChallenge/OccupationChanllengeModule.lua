local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local OccupationChanllengeModule = Lplus.Extend(ModuleBase, "OccupationChanllengeModule")
require("Main.module.ModuleId")
local def = OccupationChanllengeModule.define
local instance
def.static("=>", OccupationChanllengeModule).Instance = function()
  if instance == nil then
    instance = OccupationChanllengeModule()
    instance.m_moduleId = ModuleId.OCCUPATIONCHANLLENGE
  end
  return instance
end
def.override().Init = function(self)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, OccupationChanllengeModule.OnActivityTodo)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, OccupationChanllengeModule.OnNPCService)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SIsContinueScoChallenge", OccupationChanllengeModule.OnSIsContinueScoChallenge)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SScoChallengeAward", OccupationChanllengeModule.OnSScoChallengeAward)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SCannotAttendRes", OccupationChanllengeModule.OnSCannotAttendRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SScoActivityStartRes", OccupationChanllengeModule.OnSChallengeActivityStart)
  ModuleBase.Init(self)
end
def.static("table", "table").OnActivityTodo = function(params, context)
  if constant.SchoolChallengeCfgConsts.ACTIVITYID == params[1] then
    OccupationChanllengeModule.GoToFindNpc()
  end
end
def.static("number", "table").SIsContinueScoChallengeCallback = function(i, tag)
  if i == 1 then
    OccupationChanllengeModule.GoToFindNpc()
  end
end
def.static("table").OnSChallengeActivityStart = function(p)
end
def.static("table").OnSIsContinueScoChallenge = function(p)
  local protocolsCache = require("Main.Common.ProtocolsCache").Instance()
  if protocolsCache:CacheProtocol(OccupationChanllengeModule.OnSIsContinueScoChallenge, p) == true then
    return
  end
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirmCoundDown(textRes.activity[145], textRes.activity[142], textRes.Login[105], textRes.Login[106], 1, 30, OccupationChanllengeModule.SIsContinueScoChallengeCallback, nil)
end
def.static("table").OnSScoChallengeAward = function(p)
  local str = string.format(textRes.activity[143], textRes.activity.OccupationChanllengeTimes[p.circle])
  local awardInfo = p.awardBean
  local personAward = {}
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  table.insert(personAward, {
    PersonalHelper.Type.ColorText,
    str,
    "ffff00"
  })
  if awardInfo.yuanbao and awardInfo.yuanbao:gt(0) then
    table.insert(personAward, {
      PersonalHelper.Type.Yuanbao,
      awardInfo.yuanbao
    })
  end
  if 0 < awardInfo.roleExp then
    table.insert(personAward, {
      PersonalHelper.Type.RoleExp,
      awardInfo.roleExp
    })
  end
  if awardInfo.gold and awardInfo.gold:gt(0) then
    table.insert(personAward, {
      PersonalHelper.Type.Gold,
      awardInfo.gold
    })
  end
  if awardInfo.silver and awardInfo.silver:gt(0) then
    table.insert(personAward, {
      PersonalHelper.Type.Silver,
      awardInfo.silver
    })
  end
  if #personAward > 1 then
    PersonalHelper.CommonTableMsg(personAward)
  end
  if awardInfo.itemMap and next(awardInfo.itemMap) then
    PersonalHelper.CommonMsg(PersonalHelper.Type.ColorText, str, "ffff00", PersonalHelper.Type.ColorText, textRes.Common[150], "ffff00", PersonalHelper.Type.ItemMap, awardInfo.itemMap)
  end
  if awardInfo.petExpMap and next(awardInfo.petExpMap) then
    PersonalHelper.CommonMsg(PersonalHelper.Type.ColorText, str, "ffff00", PersonalHelper.Type.ColorText, textRes.Common[151], "ffff00", PersonalHelper.Type.PetExpMap, awardInfo.petExpMap)
  end
end
def.static().GoToFindNpc = function()
  local npcId = constant.SchoolChallengeCfgConsts.NPC_ID
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {npcId})
end
def.static("table", "table").OnNPCService = function(params, context)
  local NPCServiceConst = require("Main.npc.NPCServiceConst")
  if NPCServiceConst.OccupationChanllenge == params[1] then
    OccupationChanllengeModule.JoinChanllenge()
  end
end
def.static("table").OnSCannotAttendRes = function(p)
  local roleId = p.roleid
  local TeamData = require("Main.Team.TeamData")
  local memberInfo = TeamData.Instance():GetTeamMember(roleId)
  Toast(string.format(textRes.activity[144], memberInfo.name))
end
def.static().JoinChanllenge = function()
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local activityId = constant.SchoolChallengeCfgConsts.ACTIVITYID
  local succeed = ActivityInterface.CheckActivityConditionFinishCount(activityId)
  if succeed == false then
    Toast(textRes.activity[140])
    return
  end
  if ActivityInterface.CheckActivityConditionLevel(activityId, true) == false then
    return
  end
  if ActivityInterface.CheckActivityConditionTeamMemberCount(activityId, true) == false then
    return
  end
  local graphId = constant.SchoolChallengeCfgConsts.GRAPH_ID
  local TaskInterface = require("Main.task.TaskInterface")
  local taskInterface = TaskInterface.Instance()
  if taskInterface:HasTaskByGraphID(graphId, true, true, true) == true then
    local taskId = taskInterface:GetTaskIdByGraphId(graphId)
    Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_TaskFindPath, {taskId, graphId})
    return
  end
  local join = require("netio.protocol.mzm.gsp.activity.CJoinScoChallengeReq").new()
  gmodule.network.sendProtocol(join)
end
OccupationChanllengeModule.Commit()
return OccupationChanllengeModule
