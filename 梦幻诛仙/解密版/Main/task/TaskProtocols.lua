local Lplus = require("Lplus")
local TaskProtocols = Lplus.Class("TaskProtocols")
local def = TaskProtocols.define
local taskModule = gmodule.moduleMgr:GetModule(ModuleId.TASK)
local ProtocolsCache = require("Main.Common.ProtocolsCache")
local protocolsCache = ProtocolsCache.Instance()
local TaskInterface = require("Main.task.TaskInterface")
local taskInterface = TaskInterface.Instance()
local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
local TaskConClassType = require("consts.mzm.gsp.task.confbean.TaskConClassType")
def.static("table").OnSTaskInitData = function(p)
  local empty = true
  for k, v in pairs(p.taskDatas) do
    taskInterface:SetTaskInfo(v.taskId, v.graphId, v.state, v.conDatas)
    if v.unConDatas ~= nil then
      taskInterface:SetTaskUnConditionData(v.taskId, v.graphId, v.unConDatas)
    end
    empty = false
  end
  taskInterface:SetTaskRingMap(p.setGraphRing)
  if empty == false then
    taskInterface:_RefeshTaskRequirements()
    Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_InfoChanged, nil)
    Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_Item_Changed, nil)
  end
  taskInterface:RefreshTaskItemBag()
end
def.static("table").OnSUpdateTaskCon = function(p)
  if protocolsCache:CacheProtocol(TaskProtocols.OnSUpdateTaskCon, p) == true then
    return
  end
  taskInterface:SetTaskConditionData(p.taskId, p.graphId, p.conData)
  taskInterface:setTimeLimitGraphTask(p.graphId, p.taskId, {
    p.conData
  })
  taskInterface:_RefeshTaskRequirements()
  Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_InfoChanged, nil)
  local conditionData = p.conData
  local killNpcConCfg = TaskInterface.GetTaskConditionKillNpc(conditionData.conId)
  if killNpcConCfg and Int64.ToNumber(conditionData.param) > -1 then
    gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):ChangeNpcModel(killNpcConCfg.fixNPCId, conditionData.param, conditionData.subParam)
  end
  local TaskModule = require("Main.task.TaskModule")
  TaskModule._AutoTaskToDo(p.taskId, p.graphId)
  taskInterface:RefreshTaskItemBag()
end
def.static("table").OnSUpdateTaskState = function(p)
  if protocolsCache:CacheProtocol(TaskProtocols.OnSUpdateTaskState, p) == true then
    return
  end
  local oldState = taskInterface:GetTaskState(p.taskState.taskId, p.taskState.graphId)
  if p.taskState.state == TaskConsts.TASK_STATE_DELETE then
    taskInterface:RemoveTaskInfo(p.taskState.taskId, p.taskState.graphId)
  elseif p.taskState.state == TaskConsts.TASK_STATE_HANDUP then
    Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_FinishTask, {
      p.taskState.taskId,
      p.taskState.graphId
    })
    taskInterface:RemoveTaskInfo(p.taskState.taskId, p.taskState.graphId)
  elseif p.taskState.state == TaskConsts.TASK_STATE_GIVEUP then
    taskInterface:RemoveTaskInfo(p.taskState.taskId, p.taskState.graphId)
  else
    local taskInfo = taskInterface:GetTaskInfo(p.taskState.taskId, p.taskState.graphId)
    if taskInfo == nil then
      taskInterface:SetTaskInfo(p.taskState.taskId, p.taskState.graphId, p.taskState.state, nil)
      taskInfo = taskInterface:GetTaskInfo(p.taskState.taskId, p.taskState.graphId)
    else
      taskInfo.state = p.taskState.state
    end
    taskInfo.time = os.time()
    if p.taskState.state == TaskConsts.TASK_STATE_CAN_ACCEPT then
      taskInfo.conDatas = nil
    end
  end
  taskInterface:_RefeshTaskRequirements()
  taskInterface:RefreshTaskItemBag()
  Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_InfoChanged, {
    p.taskState.taskId,
    p.taskState.graphId
  })
  if (oldState < 0 or oldState == TaskConsts.TASK_STATE_ALREADY_ACCEPT) and p.taskState.state == TaskConsts.TASK_STATE_FINISH then
    Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_Finishable, {
      p.taskState.taskId,
      p.taskState.graphId
    })
    SafeLuckDog(function()
      local specifiedTaskId = 20000417
      return p.taskState.taskId == specifiedTaskId
    end)
  end
  if (oldState < 0 or oldState == TaskConsts.TASK_STATE_CAN_ACCEPT) and (p.taskState.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT or p.taskState.state == TaskConsts.TASK_STATE_FINISH) then
    Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_AcceptTask, {
      p.taskState.taskId,
      p.taskState.graphId
    })
  end
  if taskInterface._accpetTaskInfo and taskInterface._accpetTaskInfo[2] == p.taskState.graphId then
    taskInterface._accpetTaskInfo = nil
    taskInterface._resetTask[p.taskState.graphId] = nil
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.TASK_TRACE_ITEM_CLICK, {
      p.taskState.taskId,
      p.taskState.graphId
    })
    warn("----------go on taskInterface------")
  end
end
def.static("table").OnSTaskNormalResult = function(p)
  local fnTable = {}
  fnTable[p.ACCEPT_TASK_REP_SETLIMIT] = function(args)
    Toast(textRes.Task[150])
  end
  fnTable[p.CAN_NOT_BATTLE_MIN_NUM] = function(args)
    local msg = string.format(textRes.Task[151], args[1])
    Toast(msg)
  end
  fnTable[p.ALL_HAVE_TASK_CAN_BATTLE] = function(args)
    Toast(textRes.Task[152])
  end
  fnTable[p.SING_TASK_CANNOT_IN_TEAM] = function(args)
    Toast(textRes.Task[153])
  end
  fnTable[p.CAN_NOT_BATTLE_MIN_LEVEL] = function(args)
    Toast(string.format(textRes.Task[154], args[1]))
  end
  fnTable[p.TASK_AWARD_BANED] = function(args)
    Toast(textRes.Task[155])
  end
  local fn = fnTable[p.result]
  if fn ~= nil then
    fn(p.args)
  else
    warn("OnSTaskNormalResult(result=" .. p.result .. ")")
  end
end
def.static("table").OnSSynTaskCurRing = function(p)
  if protocolsCache:CacheProtocol(TaskProtocols.OnSSynTaskCurRing, p) == true then
    return
  end
  taskInterface:SetTaskRing(p.graphId, p.curRing)
  Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_RingChanged, {
    p.graphId,
    p.curRing
  })
  if p.reason == p.FINISH_TASK then
    Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_FinishRingChanged, {
      p.graphId,
      p.curRing
    })
  end
end
def.static("table").OnSRefreshTaskRes = function(p)
  if protocolsCache:CacheProtocol(TaskProtocols.OnSRefreshTaskRes, p) == true then
    return
  end
  local empty = true
  for k, v in pairs(p.taskStates) do
    empty = false
    local oldState = taskInterface:GetTaskState(v.taskId, v.graphId)
    if v.state == TaskConsts.TASK_STATE_DELETE then
      taskInterface:RemoveTaskInfo(v.taskId, v.graphId)
    else
      local taskInfo = taskInterface:GetTaskInfo(v.taskId, v.graphId)
      if taskInfo == nil then
        taskInterface:SetTaskInfo(v.taskId, v.graphId, v.state, nil)
        taskInfo = taskInterface:GetTaskInfo(v.taskId, v.graphId)
      else
        taskInfo.state = v.state
      end
      if v.state == TaskConsts.TASK_STATE_CAN_ACCEPT then
        taskInfo.conDatas = nil
      end
    end
    if (oldState < 0 or oldState == TaskConsts.TASK_STATE_CAN_ACCEPT) and (v.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT or v.state == TaskConsts.TASK_STATE_FINISH) then
      Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_AcceptTask, {
        v.taskId,
        v.graphId
      })
    end
  end
  if empty == false then
    Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_OnRefreshLibTryDoNPC, {
      p.npcId
    })
  end
end
def.static("table").OnSQingYunZhi = function(p)
  if protocolsCache:CacheProtocol(TaskProtocols.OnSQingYunZhi, p) == true then
    return
  end
  taskInterface:SetQingyunHistoryInfo(p.chapterNum, p.nodeNum)
  Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_QinyunHistoryChanged, {
    p.chapterNum,
    p.nodeNum
  })
end
def.static("table").OnSTaskTalk = function(p)
  if _G.CGPlay == true then
    local CG = require("CG.CG")
    local path = TaskInterface.Instance()._playingOpera
    CG.Instance():Stop(path)
  end
  if PlayerIsInFight() == true then
    p.talkIndex = -1
  end
  local ST_NORMAL = require("netio.protocol.mzm.gsp.team.TeamMember").ST_NORMAL
  local teamData = require("Main.Team.TeamData").Instance()
  if teamData:HasTeam() == false or teamData:GetStatus() ~= ST_NORMAL then
    p.talkIndex = -1
  end
  Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_ShowCaptainTaskTalk, {
    p.taskId,
    p.graphId,
    p.talkType,
    p.talkIndex
  })
end
def.static("table").OnSCannotAcceptTask = function(p)
  taskInterface:SetTaskUnConditionData(p.taskId, p.graphId, p.conIds)
  Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_UnAcceptCondChged, nil)
end
def.static("table").OnSLeaderWaitMemberRep = function(p)
  local taskFightAsk = require("Main.task.ui.TaskFightAsk").Instance()
  taskFightAsk:ShowDlg()
end
def.static("table").OnSJoinFightReq = function(p)
  local taskCfg = TaskInterface.GetTaskCfg(p.taskId)
  local taskModule = gmodule.moduleMgr:GetModule(ModuleId.TASK)
  if taskModule._taskFightConfirmDlg ~= nil then
    taskModule._taskFightConfirmDlg:DestroyPanel()
    taskModule._taskFightConfirmDlg = nil
  end
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  taskModule._taskFightConfirmDlg = CommonConfirmDlg.ShowConfirmCoundDown(textRes.Task[15], string.format(textRes.Task[201], taskCfg.taskName), textRes.Login[105], textRes.Login[106], 0, constant.TaskConsts.TaskFightWaitTime, TaskProtocols.OnJoinFightConfirm, {
    sessionId = p.sessionId
  })
end
def.static("number", "table").OnJoinFightConfirm = function(id, tag)
  if id == 1 then
    local p = require("netio.protocol.mzm.gsp.task.CJoinFightRep").new(tag.sessionId, TaskConsts.JOIN_FIGHT_REP__YES)
    gmodule.network.sendProtocol(p)
  else
    local p = require("netio.protocol.mzm.gsp.task.CJoinFightRep").new(tag.sessionId, TaskConsts.JOIN_FIGHT_REP__NO)
    gmodule.network.sendProtocol(p)
  end
end
def.static("table").OnSCancelInvite = function(p)
  local taskFightAsk = require("Main.task.ui.TaskFightAsk").Instance()
  taskFightAsk:HideDlg()
  if taskModule._taskFightConfirmDlg ~= nil then
    taskModule._taskFightConfirmDlg:DestroyPanel()
    taskModule._taskFightConfirmDlg = nil
  end
  Toast(string.format(textRes.Task[204], p.roleName))
end
def.static("table").OnSSynMemberJoinFightState = function(p)
  local taskFightAsk = require("Main.task.ui.TaskFightAsk").Instance()
  if taskFightAsk:IsShow() == true then
    taskFightAsk:SetRoleRepones(p.roleId, p.repResult)
    taskFightAsk:Fill()
  end
  if p.repResult == TaskConsts.JOIN_FIGHT_REP__YES then
    Toast(string.format(textRes.Task[202], p.roleName))
  elseif p.repResult == TaskConsts.JOIN_FIGHT_REP__NO then
    local taskFightAsk = require("Main.task.ui.TaskFightAsk").Instance()
    taskFightAsk:HideDlg()
    if taskModule._taskFightConfirmDlg ~= nil then
      taskModule._taskFightConfirmDlg:DestroyPanel()
      taskModule._taskFightConfirmDlg = nil
    end
    Toast(string.format(textRes.Task[203], p.roleName))
  end
end
def.static("table").OnSSynBanGraphInfo = function(p)
  taskInterface._allBanGraphIds = p.allBanGraphIds
end
TaskProtocols.Commit()
return TaskProtocols
