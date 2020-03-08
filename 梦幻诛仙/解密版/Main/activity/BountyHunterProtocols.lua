local Lplus = require("Lplus")
local BountyHunterProtocols = Lplus.Class("BountyHunterProtocols")
local def = BountyHunterProtocols.define
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
local BTaskInfo = require("netio.protocol.mzm.gsp.bounty.BTaskInfo")
def.static("table").OnSSynBountyInfo = function(p)
  activityInterface._bountyCount = p.bountyCount
  activityInterface._bountyTaskInfos = p.taskInfos
  local bountyHunter = require("Main.activity.ui.BountyHunter").Instance()
  local bountyHunterShow = bountyHunter:IsShow()
  if bountyHunterShow == true then
    bountyHunter:Fill()
    bountyHunter.canRefresh = true
  end
end
def.static("table").OnSSynBTaskStatus = function(p)
  local protocolsCache = require("Main.Common.ProtocolsCache").Instance()
  if protocolsCache:CacheProtocol(BountyHunterProtocols.OnSSynBTaskStatus, p) == true then
    return
  end
  local oldBountyCount = activityInterface._bountyCount
  activityInterface._bountyCount = p.bountyCount
  activityInterface._bountyTaskInfos = activityInterface._bountyTaskInfos or {}
  local graphInfo = activityInterface._bountyTaskInfos[p.graphId]
  if graphInfo == nil then
    graphInfo = {}
    activityInterface._bountyTaskInfos[p.graphId] = graphInfo
  end
  graphInfo.taskId = p.taskId
  local oldTaskState = graphInfo.taskState
  graphInfo.taskState = p.taskState
  if p.taskState == BTaskInfo.GIVE_UP or p.taskState == BTaskInfo.FINISHED then
    local taskModule = gmodule.moduleMgr:GetModule(ModuleId.TASK)
    if taskModule._Last_PathFind_TaskId == p.taskId and taskModule._Last_PathFind_graphId == p.graphId or taskModule._Last_PathFind_TaskId == 0 and taskModule._Last_PathFind_graphId == 0 then
      taskModule:ClearTaskFindPath()
      local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
      if heroModule.myRole ~= nil then
        Debug.LogWarning("OnSSynBTaskStatus: stop hero")
        heroModule.myRole:Stop()
      end
      local NPCInterface = require("Main.npc.NPCInterface")
      local npcInterface = NPCInterface.Instance()
      npcInterface:SetTargetNPCID(0)
    end
  end
  local bountyHunter = require("Main.activity.ui.BountyHunter").Instance()
  if oldBountyCount ~= activityInterface._bountyCount and activityInterface._bountyCount < constant.BountyConsts.BOUNTYHUNTER_DAY_UPPER_LIMIT then
    bountyHunter:HideDlg()
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
      constant.BountyConsts.BOUNTYHUNTER_NPC_ID
    })
    return
  end
  if oldTaskState == BTaskInfo.UN_ACCEPTED and graphInfo.taskState == BTaskInfo.ALREADY_ACCEPTED then
    bountyHunter:HideDlg()
    return
  end
  if bountyHunterShow == true then
    local bountyHunterShow = bountyHunter:IsShow()
    if bountyHunterShow == true then
      bountyHunter:Fill()
    end
  end
end
def.static("number", "table").OnBountyContinueConfirm = function(id, tag)
  if id == 1 then
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
      constant.BountyConsts.BOUNTYHUNTER_NPC_ID
    })
  end
end
def.static("table").OnSBountyNormalResult = function(p)
end
def.static("table").OnSResetBountyCount = function(p)
  activityInterface._bountyCount = 0
end
BountyHunterProtocols.Commit()
return BountyHunterProtocols
