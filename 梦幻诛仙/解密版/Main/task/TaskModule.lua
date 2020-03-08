local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local TaskModule = Lplus.Extend(ModuleBase, "TaskModule")
require("Main.module.ModuleId")
local TaskInterface = require("Main.task.TaskInterface")
local taskInterface = TaskInterface.Instance()
local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
local TaskConClassType = require("consts.mzm.gsp.task.confbean.TaskConClassType")
local EffectLoadType = require("consts.mzm.gsp.util.confbean.EffectLoadType")
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
local NPCInterface = require("Main.npc.NPCInterface")
local npcInterface = NPCInterface.Instance()
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local GangUtility = require("Main.Gang.GangUtility")
local Space = require("consts.mzm.gsp.map.confbean.Space")
local FlyModule = require("Main.Fly.FlyModule")
local def = TaskModule.define
local instance
def.static("=>", TaskModule).Instance = function()
  if instance == nil then
    instance = TaskModule()
    instance.m_moduleId = ModuleId.TASK
  end
  return instance
end
TaskModule.ToDoFinishTalk_None = 0
TaskModule.ToDoFinishTalk_AceptTask = 1
TaskModule.ToDoFinishTalk_FinishiTask = 2
TaskModule.ToDoFinishTalk_FightTask = 3
TaskModule.ToDoFinishTalk_TargetTalk = 4
TaskModule.ToDoFinishTalk_Custom = 100
TaskModule.fn_ToDoFinishTalk = TaskModule.fn_ToDoFinishTalk or {}
def.field("table")._CurrentTalkTable = nil
def.field("number")._ToDoFinishTalk = 0
def.field("number")._FinishTalkTaskId = 0
def.field("number")._FinishTalkGraphId = 0
def.field("number")._talkIndex = 0
def.field("number")._talkType = 0
def.field("function")._talkCustomCallbackFn = nil
def.field("table")._talkCustomCallbackParam = nil
def.field("number")._EndFight_PathFind_TaskId = 0
def.field("number")._EndFight_PathFind_graphId = 0
def.field("number")._EndOpera_PathFind_TaskId = 0
def.field("number")._EndOpera_PathFind_graphId = 0
def.field("table")._HanInItemSelect_ItemList = nil
def.field("number")._HanInItemSelect_GraphID = 0
def.field("number")._HanInItemSelect_TaskID = 0
def.field("number")._LastFinishGraphID = 0
def.field("number")._LastFinishTaskID = 0
def.field("number")._LastFinishTime = 0
def.field("number")._taskGiveTargetTaskID = 0
def.field("number")._taskGiveTargetgraphID = 0
TaskModule.CIRCLE_TASK_BATTLE = 1
TaskModule.CIRCLE_TASK_RENXINGYIXIA = 2
TaskModule.CIRCLE_TASK_FACTION_HELP = 3
def.field("table")._npcServiceTable = nil
def.field("number")._Last_PathFind_TaskId = 0
def.field("number")._Last_PathFind_graphId = 0
def.field("boolean")._Cancel_Once_PathFind = false
def.field("number")._Cancel_Once_PathFind_graphID = 0
def.field("table")._circlePath = nil
def.field("number")._circlePathIndex = 0
def.field("number")._circlePathTaskID = 0
def.field("number")._circlePathGraphID = 0
def.field(CommonConfirmDlg)._taskFightConfirmDlg = nil
def.field("userdata")._InterruptSound = nil
def.field("boolean")._isGatheringItem = false
def.field("table")._gatherItems = nil
def.field("boolean")._isTaskFindPathing = false
def.field("number")._curShareId = 0
def.override().Init = function(self)
  local protocols = require("Main.task.TaskProtocols")
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.task.STaskInitData", protocols.OnSTaskInitData)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.task.SUpdateTaskCon", protocols.OnSUpdateTaskCon)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.task.SUpdateTaskState", protocols.OnSUpdateTaskState)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.task.STaskNormalResult", protocols.OnSTaskNormalResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.task.SSynTaskCurRing", protocols.OnSSynTaskCurRing)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.task.SRefreshTaskRes", protocols.OnSRefreshTaskRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.task.SCannotAcceptTask", protocols.OnSCannotAcceptTask)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingyunzhi.SQingYunZhi", protocols.OnSQingYunZhi)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.task.STaskTalk", protocols.OnSTaskTalk)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.task.SLeaderWaitMemberRep", protocols.OnSLeaderWaitMemberRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.task.SJoinFightReq", protocols.OnSJoinFightReq)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.task.SCancelInvite", protocols.OnSCancelInvite)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.task.SSynMemberJoinFightState", protocols.OnSSynMemberJoinFightState)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.task.SSynBanGraphInfo", protocols.OnSSynBanGraphInfo)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_QY_ZHI_CLICK, TaskModule.OnMainUIQYZhi)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SELECT_TASK, TaskModule.OnNPCTaskSelected)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, TaskModule.OnNPCService)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_AcceptTask, TaskModule.OnTaskAccepted)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_FinishTask, TaskModule.OnTaskFinished)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_Finishable, TaskModule.OnTaskFinishable)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_TaskFindPath, TaskModule.TaskFindPath)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_InfoChanged, TaskModule.OnTaskInfoChanged)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_ShowCaptainTaskTalk, TaskModule.OnShowCaptainTaskTalk)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_DramaStart, TaskModule.OnDramaStart)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_DramaOver, TaskModule.OnDramaOver)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_TalkHide, TaskModule.OnTaskTalkHide)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.TASK_TRACE_ITEM_CLICK, TaskModule.TaskTraceItemClick)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_FINDPATH_FINISHED, TaskModule.OnFindpathFinished)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_CLICKMAP_FINDPATH, TaskModule.OnClickMapFindpath)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_FINDPATH_CANCELED, TaskModule.OnFindpathCanceled)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.FIND_PATH_FAILED, TaskModule.OnFindPathFailed)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, TaskModule.OnLeaveFight)
  Event.RegisterEvent(ModuleId.GIVE, gmodule.notifyId.Give.Give_ItemSelect, TaskModule.OnGiveItemSelected)
  Event.RegisterEvent(ModuleId.GIVE, gmodule.notifyId.Give.Give_PetSelect, TaskModule.OnGivePetSelected)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_CHANGE_LEADER, TaskModule.OnNewTeamLeader)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_STATUS_CHANGED, TaskModule.OnMemberStatusChanged)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_LEAVE, TaskModule.OnMemberLeave)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_KICK_TEAM, TaskModule.OnMemberKick)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Task_Use, TaskModule.OnItemTaskUse)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, TaskModule.OnActivityReset)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.COLLECT_ITEM_DONE, TaskModule.OnGatherItemDone)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, TaskModule.OnActivityStart)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, TaskModule.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, TaskModule.OnEnterWorld)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.CourtyardLevelUp, TaskModule.OnCourtyardLevelUp)
  Event.RegisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.FinishSharing, TaskModule.OnRelationShipChain)
  self._CurrentTalkTable = self._CurrentTalkTable or {}
  self._ToDoFinishTalk = 0
  self._FinishTalkTaskId = 0
  self._FinishTalkGraphId = 0
  self._talkIndex = 0
  table.insert(TaskModule.fn_ToDoFinishTalk, TaskModule.ToDoFinishTalk_None, TaskModule.fn_ToDoFinishTalk_None)
  table.insert(TaskModule.fn_ToDoFinishTalk, TaskModule.ToDoFinishTalk_AceptTask, TaskModule.fn_ToDoFinishTalk_AceptTask)
  table.insert(TaskModule.fn_ToDoFinishTalk, TaskModule.ToDoFinishTalk_FinishiTask, TaskModule.fn_ToDoFinishTalk_FinishiTask)
  table.insert(TaskModule.fn_ToDoFinishTalk, TaskModule.ToDoFinishTalk_FightTask, TaskModule.fn_ToDoFinishTalk_FightTask)
  table.insert(TaskModule.fn_ToDoFinishTalk, TaskModule.ToDoFinishTalk_TargetTalk, TaskModule.fn_ToDoFinishTalk_TargetTalk)
  table.insert(TaskModule.fn_ToDoFinishTalk, TaskModule.ToDoFinishTalk_Custom, TaskModule.fn_ToDoFinishTalk_Custom)
  local NPCServiceConst = require("Main.npc.NPCServiceConst")
  self._npcServiceTable = {}
  self._npcServiceTable[NPCServiceConst.QueryZhenYaoTask] = TaskModule.OnNPCService_QueryZhenYaoTask
  ModuleBase.Init(self)
  require("Main.task.SurpriseTaskMgr").Instance():Init()
  local ItemUtils = require("Main.Item.ItemUtils")
end
def.static("table", "table").OnEnterWorld = function(p1, p2)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_TASK_USED_NPCLIB_CFG)
  if entries == nil then
    warn("!!!!!!!!!!!!NPCLIB cfg is nil")
    return
  end
  local list = {}
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local npcLibId = record:GetIntValue("npcLibId")
    if taskInterface._taskCustomNpcIdFn then
      local fn = taskInterface._taskCustomNpcIdFn[npcLibId]
      if fn == nil then
        table.insert(list, npcLibId)
      end
    else
      table.insert(list, npcLibId)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  if #list > 0 then
    local str = table.concat(list, ", ")
    error("!!!!!!!!no register taskNPCLibId:" .. str)
  end
end
def.override().OnReset = function(self)
  taskInterface:Reset()
  self._CurrentTalkTable = nil
  self._ToDoFinishTalk = 0
  self._FinishTalkTaskId = 0
  self._FinishTalkGraphId = 0
  self._talkIndex = 0
  self._talkType = 0
  self._EndFight_PathFind_TaskId = 0
  self._EndFight_PathFind_graphId = 0
  self._EndOpera_PathFind_TaskId = 0
  self._EndOpera_PathFind_graphId = 0
  self._HanInItemSelect_ItemList = nil
  self._HanInItemSelect_GraphID = 0
  self._HanInItemSelect_TaskID = 0
  self._LastFinishGraphID = 0
  self._LastFinishTaskID = 0
  self._LastFinishTime = 0
  self._taskGiveTargetTaskID = 0
  self._taskGiveTargetgraphID = 0
  self._Last_PathFind_TaskId = 0
  self._Last_PathFind_graphId = 0
  self._Cancel_Once_PathFind = false
  self._Cancel_Once_PathFind_graphID = 0
  self._circlePath = nil
  self._circlePathIndex = 0
  self._circlePathTaskID = 0
  self._circlePathGraphID = 0
  self._isGatheringItem = false
  self._gatherItems = nil
  self._isTaskFindPathing = false
  taskInterface._curTaskId = 0
  self._curShareId = 0
end
def.static("table", "table").OnNPCTaskSelected = function(p1, p2)
  local taskId = p1[1]
  local graphId = p1[2]
  local self = instance
  local NPCModuleInstance = gmodule.moduleMgr:GetModule(ModuleId.NPC)
  local TaskModuleInstance = TaskModule.Instance()
  local selectedTaskInfo = taskInterface:GetTaskInfo(taskId, graphId)
  if selectedTaskInfo == nil then
    warn("******************* OnNPCTaskSelected() selectedTaskInfo == nil")
    return
  end
  if selectedTaskInfo.state == TaskConsts.TASK_STATE_CAN_ACCEPT then
    local talkCfg = TaskInterface.GetTaskTalkCfg(taskId)
    local dlgs = talkCfg.dlgs[TaskConsts.ACCEPT_TASK_DIALOG]
    if dlgs ~= nil and table.maxn(dlgs.content) > 0 then
      self._talkType = TaskConsts.ACCEPT_TASK_DIALOG
      self:ShowNPCText(dlgs.content, TaskModule.ToDoFinishTalk_AceptTask, taskId, graphId, 1)
    else
      TaskModule.DoAceptTask(taskId, graphId)
    end
    return
  elseif selectedTaskInfo.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT then
    local taskCfg = TaskInterface.GetTaskCfg(taskId)
    if selectedTaskInfo.graphId == constant.CircleTaskConsts.Circle_TASK_GRAPHIC_ID and TaskModule.FillCircleTaskItem(taskCfg) == true then
      return
    end
    TaskModule.OnNPCAlreadyAcceptTaskSelected(taskCfg, graphId)
  elseif selectedTaskInfo.state == TaskConsts.TASK_STATE_FINISH then
    local talkCfg = TaskInterface.GetTaskTalkCfg(taskId)
    local dlgs = talkCfg.dlgs[TaskConsts.FINISH_TASK_DIALOG]
    if dlgs ~= nil then
      self._talkType = TaskConsts.FINISH_TASK_DIALOG
      self:ShowNPCText(dlgs.content, TaskModule.ToDoFinishTalk_FinishiTask, taskId, graphId, 1)
    else
      TaskModule.DoFinishTask(taskId, graphId)
    end
    return
  elseif selectedTaskInfo.state == TaskConsts.TASK_STATE_VISIABLE then
    local talkCfg = TaskInterface.GetTaskTalkCfg(taskId)
    local dlgs = talkCfg.dlgs[TaskConsts.CAN_NOT_ACCEPT_TASK_DIALOG]
    if dlgs ~= nil and table.maxn(dlgs.content) > 0 then
      self._talkType = TaskConsts.CAN_NOT_ACCEPT_TASK_DIALOG
      self:ShowNPCText(dlgs.content, TaskModule.ToDoFinishTalk_None, taskId, graphId, 1)
    end
    return
  end
end
def.static("table", "number").OnNPCAlreadyAcceptTaskSelected = function(taskCfg, graphId)
  local self = instance
  local taskId = taskCfg.taskID
  local npcID = npcInterface:GetLastInteractiveNPCID()
  local npcToTaskCfg = NPCInterface.GetNPCToTaskCfg(npcID)
  local talkCfg = TaskInterface.GetTaskTalkCfg(taskId)
  local conditionID = taskCfg.FindFinishConditionID(TaskConClassType.CON_KILL_NPC)
  if conditionID > 0 then
    local teamData = require("Main.Team.TeamData").Instance()
    if teamData:HasTeam() == true then
      local members = teamData:GetAllTeamMembers()
      local ST_NORMAL = require("netio.protocol.mzm.gsp.team.TeamMember").ST_NORMAL
      local memberCount = 0
      for k, v in pairs(members) do
        if v.status == ST_NORMAL then
          memberCount = memberCount + 1
        end
      end
      if taskCfg.battlePeopleNumUpper ~= 0 and memberCount > taskCfg.battlePeopleNumUpper then
        if taskCfg.battlePeopleNumUpper == 1 then
          Toast(string.format(textRes.NPC[15]))
        else
          Toast(string.format(textRes.NPC[19], taskCfg.battlePeopleNumUpper))
        end
        return
      end
      if taskCfg.battlePeopleNumLower ~= 0 and memberCount < taskCfg.battlePeopleNumLower then
        Toast(string.format(textRes.NPC[16], taskCfg.battlePeopleNumLower))
        return
      end
    elseif 1 < taskCfg.battlePeopleNumLower then
      Toast(string.format(textRes.NPC[16], taskCfg.battlePeopleNumLower))
      return
    end
    local dlgs = talkCfg.dlgs[TaskConsts.BEFORE_BATTLE_DIALOG]
    if dlgs ~= nil and 0 < table.maxn(dlgs.content) then
      self._talkType = TaskConsts.BEFORE_BATTLE_DIALOG
      self:ShowNPCText(dlgs.content, TaskModule.ToDoFinishTalk_TargetTalk, taskId, graphId, 1)
    else
      TaskModule.DoFinishTargetTalk(taskId, graphId)
    end
    print("** taskCfg.FindFinishConditionID(TaskConClassType.CON_KILL_NPC) > 0 return")
    return
  end
  conditionID = taskCfg.FindFinishConditionID(TaskConClassType.CON_NPC_DLG)
  if npcToTaskCfg then
    local targetTalk = npcToTaskCfg.targetTalkTaskIDs[taskId]
    if conditionID > 0 and targetTalk ~= nil then
      local contents = {}
      local content = {}
      content.npcid = npcID
      content.txt = targetTalk.dlgStr
      table.insert(contents, content)
      if #contents > 0 then
        self:ShowNPCText(contents, TaskModule.ToDoFinishTalk_TargetTalk, taskId, graphId, 1)
      else
        TaskModule.DoFinishTargetTalk(taskId, graphId)
      end
      print("** taskCfg.FindFinishConditionID(TaskConClassType.CON_NPC_DLG) > 0 return")
      return
    end
  end
  conditionID = taskCfg.FindFinishConditionID(TaskConClassType.CON_QUESTION)
  if conditionID > 0 then
    TaskModule.DoFinishTargetTalk(taskId, graphId)
    return
  end
  local dlgs = talkCfg.dlgs[TaskConsts.NOT_FINISH_DIALOG]
  if dlgs ~= nil and 0 < table.maxn(dlgs.content) then
    self._talkType = TaskConsts.NOT_FINISH_DIALOG
    self:ShowNPCText(dlgs.content, TaskModule.ToDoFinishTalk_None, taskId, graphId, 1)
  else
    local contents = {}
    local content = {}
    content.npcid = npcID
    content.txt = textRes.Task[27]
    table.insert(contents, content)
    self:ShowNPCText(contents, TaskModule.ToDoFinishTalk_None, taskId, graphId, 1)
  end
end
def.static("table", "table").OnNPCService = function(p1, p2)
  local serviceID = p1[1]
  local npcID = p1[2]
  local fn = instance._npcServiceTable[serviceID]
  if fn ~= nil then
    fn(serviceID, npcID)
  end
end
def.static("table", "table").OnFindpathFinished = function(p1, p2)
  local self = instance
  self._isTaskFindPathing = false
  self:ContinueCirclePath()
  local taskID = self._Last_PathFind_TaskId
  local graphID = self._Last_PathFind_graphId
  self._Last_PathFind_TaskId = 0
  self._Last_PathFind_graphId = 0
  if taskID ~= 0 and graphID ~= 0 and TaskModule._AutoTaskToDo(taskID, graphID) == true then
    return
  end
end
def.static("table", "table").OnClickMapFindpath = function(p1, p2)
  taskInterface._curTaskId = 0
  instance:ClearTaskFindPath()
end
def.static("table", "table").OnFindPathFailed = function(p1, p2)
  taskInterface._curTaskId = 0
  instance:ClearTaskFindPath()
end
def.static("table", "table").OnFindpathCanceled = function(p1, p2)
  taskInterface._curTaskId = 0
  instance:ClearTaskFindPath()
end
def.method().ClearTaskFindPath = function(self)
  if self._circlePathTaskID ~= 0 and self._circlePathGraphID ~= 0 then
    require("Main.Hero.ui.XunluTip").HideXunluo()
  end
  gmodule.moduleMgr:GetModule(ModuleId.HERO).isTaskCircle = false
  self._circlePath = nil
  self._circlePathIndex = 0
  self._circlePathTaskID = 0
  self._circlePathGraphID = 0
  self._Last_PathFind_TaskId = 0
  self._Last_PathFind_graphId = 0
  self._isTaskFindPathing = false
end
def.static("table", "=>", "boolean").FillCircleTaskItem = function(taskCfg)
  local conditionID = taskCfg.FindFinishConditionID(TaskConClassType.CON_KILL_NPC)
  local battle = conditionID > 0
  local conditionID = taskCfg.FindFinishConditionID(TaskConClassType.CON_BAG)
  local bagCon = conditionID > 0
  if battle == false and bagCon == false then
    return false
  end
  local npcID = npcInterface:GetLastInteractiveNPCID()
  local npcCfg = NPCInterface.GetNPCCfg(npcID)
  local infos = taskInterface:GetTaskInfos()
  local dlg = require("Main.npc.ui.NPCDlg").Instance()
  dlg._Param = {}
  dlg:_ClearItems()
  local graphCfg = TaskInterface.GetTaskGraphCfg(constant.CircleTaskConsts.Circle_TASK_GRAPHIC_ID)
  local taskInfo = {}
  taskInfo.param = TaskModule.CIRCLE_TASK_BATTLE
  taskInfo.taskId = taskCfg.taskID
  taskInfo.graphId = constant.CircleTaskConsts.Circle_TASK_GRAPHIC_ID
  taskInfo.itemType = NPCInterface.NPC_TYPE_CUSTOM
  if battle == true then
    taskInfo.dispText = textRes.Task[174]
  else
    taskInfo.dispText = taskCfg.taskName
  end
  taskInfo.itemParam = nil
  dlg:AddItem(taskCfg.taskName, taskInfo, battle)
  local taskInfo = {}
  taskInfo.param = TaskModule.CIRCLE_TASK_RENXINGYIXIA
  taskInfo.taskId = taskCfg.taskID
  taskInfo.graphId = constant.CircleTaskConsts.Circle_TASK_GRAPHIC_ID
  taskInfo.itemType = NPCInterface.NPC_TYPE_CUSTOM
  taskInfo.dispText = taskCfg.taskName
  taskInfo.itemParam = nil
  dlg:AddItem(textRes.Task[170], taskInfo, false)
  if battle == true then
    local taskInfo = {}
    taskInfo.param = TaskModule.CIRCLE_TASK_FACTION_HELP
    taskInfo.taskId = taskCfg.taskID
    taskInfo.graphId = constant.CircleTaskConsts.Circle_TASK_GRAPHIC_ID
    taskInfo.itemType = NPCInterface.NPC_TYPE_CUSTOM
    taskInfo.dispText = taskCfg.taskName
    taskInfo.itemParam = nil
    dlg:AddItem(textRes.Task[171], taskInfo, false)
  end
  dlg:SetCustomCallback(TaskModule.OnCircleTask)
  if dlg:IsShow() == false and dlg:SetNpcID(npcID, false) == true then
    dlg:ShowDlg()
    local ECSoundMan = require("Sound.ECSoundMan")
    ECSoundMan.Instance():Play2DInterruptSoundByID(npcCfg.defaultAudioId)
  else
  end
  return true
end
def.static("table").OnCircleTask = function(param)
  local dlg = require("Main.npc.ui.NPCDlg").Instance()
  dlg:HideDlg()
  if param.param == TaskModule.CIRCLE_TASK_BATTLE then
    local taskCfg = TaskInterface.GetTaskCfg(param.taskId)
    TaskModule.OnNPCAlreadyAcceptTaskSelected(taskCfg, param.graphId)
  elseif param.param == TaskModule.CIRCLE_TASK_RENXINGYIXIA then
    TaskModule.OnDoRenXingYiXia()
  elseif param.param == TaskModule.CIRCLE_TASK_FACTION_HELP then
    local gangModule = gmodule.moduleMgr:GetModule(ModuleId.GANG)
    local bHaveGang = gangModule:HasGang()
    if bHaveGang == false then
      Toast(textRes.activity[212])
      return
    end
    local teamData = require("Main.Team.TeamData").Instance()
    local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
    local myRoleID = heroModule:GetMyRoleId()
    local res = teamData:HasTeam() == false or teamData:IsCaptain(myRoleID) == false
    if res == true then
      Toast(textRes.Task[175])
      return
    end
    local p = require("netio.protocol.mzm.gsp.activity.CCircleTaskCallGangHelp").new()
    gmodule.network.sendProtocol(p)
  end
end
def.static().OnDoRenXingYiXia = function()
  local FightMgr = require("Main.Fight.FightMgr")
  if PlayerIsInFight() then
    Toast(string.format(textRes.Task[35]))
    return
  end
  local count = activityInterface:GetRexXingCount()
  local cfg = ActivityInterface.GetRexXingNeed(count + 1)
  local ItemModule = gmodule.moduleMgr:GetModule(ModuleId.ITEM)
  local yuanBaoAmount = ItemModule:GetAllYuanBao()
  if yuanBaoAmount:lt(cfg.needYuanBao) then
    Toast(string.format(textRes.Task[173], cfg.needYuanBao))
    return
  end
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(textRes.activity[85], string.format(textRes.Task[172], cfg.needYuanBao), TaskModule.OnDoRenXingYiXiaConfirm, {})
end
def.static("number", "table").OnDoRenXingYiXiaConfirm = function(id, tag)
  if id == 1 then
    local FightMgr = require("Main.Fight.FightMgr")
    if PlayerIsInFight() then
      Toast(string.format(textRes.Task[35]))
      return
    end
    local CRenXingYiXiaReq = require("netio.protocol.mzm.gsp.activity.CRenXingYiXiaReq").new()
    gmodule.network.sendProtocol(CRenXingYiXiaReq)
  end
end
def.static("table", "table").OnGiveItemSelected = function(p1, p2)
  local bagID = p1[1]
  local key = p1[2]
  local taskID = instance._taskGiveTargetTaskID
  local graphID = instance._taskGiveTargetgraphID
  instance._taskGiveTargetTaskID = 0
  instance._taskGiveTargetgraphID = 0
  local GiveoutItemBean = require("netio.protocol.mzm.gsp.task.GiveoutItemBean")
  local kb = GiveoutItemBean.new(key, 1)
  local keys = {}
  table.insert(keys, kb)
  local ItemModule = require("Main.Item.ItemModule")
  local itemKey, item = ItemModule.Instance():GetItemByUUID(key, ItemModule.BAG)
  if item == nil then
    return
  end
  local ItemUtils = require("Main.Item.ItemUtils")
  local itemBase = ItemUtils.GetItemBase(item.id)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if itemBase and itemBase.itemType == ItemType.EQUIP then
    local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
    local strenLevel = item.extraMap[ItemXStoreType.STRENGTH_LEVEL]
    local maxLv = constant.TaskConsts.HAND_UP_ITEM__QILING_LV_MAX
    if strenLevel and strenLevel > maxLv then
      Toast(string.format(textRes.Task[243], maxLv))
      return
    end
  end
  TaskModule._DoFinishTaskReq(taskID, graphID, nil, keys)
end
def.static("table", "table").OnGivePetSelected = function(p1, p2)
  local petID = p1[1]
  local taskID = instance._taskGiveTargetTaskID
  local graphID = instance._taskGiveTargetgraphID
  instance._taskGiveTargetTaskID = 0
  instance._taskGiveTargetgraphID = 0
  local ids = {}
  table.insert(ids, petID)
  TaskModule._DoFinishTaskReq(taskID, graphID, ids, nil)
end
def.static("=>").OnAceptRingTaskConfirm = function()
end
def.static("table", "table").OnTaskAccepted = function(p1, p2)
  local taskId = p1[1]
  local graphId = p1[2]
  instance._LastFinishGraphID = 0
  instance._LastFinishTaskID = 0
  instance._LastFinishTime = 0
  local taskCfg = TaskInterface.GetTaskCfg(taskId)
  instance:CloseTaskTalk(taskId, graphId)
  if 0 < taskCfg.giveTaskGoods then
    require("Main.Common.FunctionQueue").Instance():Push(function()
      taskInterface:RefreshTaskItemBag()
    end)
  end
  local TaskOperClassType = require("consts.mzm.gsp.task.confbean.TaskOperClassType")
  for k, v in pairs(taskCfg.acceptOperIds) do
    if v.classType == TaskOperClassType.Oper_PlayOpera then
      local Operate = TaskInterface.GetTaskPlayOperaOperate(v.id)
      local OperaCfg = TaskInterface.GetOperaCfg(Operate.operaID)
      if OperaCfg ~= nil then
        local function OnLoaded(path)
          taskInterface._playingOpera = path
        end
        local CG = require("CG.CG")
        CGPlay = true
        Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_DramaStart, {path})
        CG.Instance():Play(OperaCfg.path, OperaCfg.path, OnLoaded)
      end
    elseif v.classType == TaskOperClassType.Oper_PlayEffect then
      local Operate = TaskInterface.GetTaskOperPlayEffectOperate(v.id)
      local ecFxMan = require("Fx.ECFxMan").Instance()
      for k2, v2 in pairs(Operate.effectIds) do
        local effectCfg = GetEffectRes(v2)
        if effectCfg then
          require("Fx.GUIFxMan").Instance():Play(effectCfg.path, "taskAcceptEffect", 0, 0, Operate.playTime / 1000, false)
        else
          TaskModule.PlaySpecialEffectCfg(v2)
        end
      end
    elseif v.classType == TaskOperClassType.Oper_GoToPosition then
    end
  end
  if taskCfg.acceptAutoFindPath == true then
    taskInterface._curTaskId = taskId
    TaskModule.TaskFindPath({taskId, graphId}, nil)
  end
  if graphId == constant.ZhenYaoActivityCfgConsts.ZhenYao_GRAPH_ID then
    local single = constant.ZhenYaoActivityCfgConsts.ZhenYao_MAX_AWARD_COUNT - activityInterface._singleCount
    local DoublePointData = require("Main.OnHook.DoublePointData")
    local frozenPoolPointNum = DoublePointData.Instance():GetFrozenPoolPointNum()
    local double = math.floor(frozenPoolPointNum / constant.ZhenYaoActivityCfgConsts.ZhenYao_FIGHT_DEC_DOUBLE_POINT)
  end
end
def.static("table", "table").OnTaskFinished = function(p1, p2)
  local taskID = p1[1]
  local graphID = p1[2]
  local self = instance
  if instance._gatherItems then
    instance._gatherItems[taskID] = nil
  end
  self:CloseTaskTalk(taskID, graphID)
  local taskCfg = TaskInterface.GetTaskCfg(taskID)
  if taskCfg.giveTaskGoods > 0 then
    taskInterface:RefreshTaskItemBag()
  end
  local TaskOperClassType = require("consts.mzm.gsp.task.confbean.TaskOperClassType")
  for k, v in pairs(taskCfg.finishOperIds) do
    if v.classType == TaskOperClassType.Oper_PlayOpera then
      local Operate = TaskInterface.GetTaskPlayOperaOperate(v.id)
      local OperaCfg = TaskInterface.GetOperaCfg(Operate.operaID)
      local function OnLoaded(path)
        taskInterface._playingOpera = path
      end
      local CG = require("CG.CG")
      CGPlay = true
      CG.Instance():Play(OperaCfg.path, OperaCfg.path, OnLoaded)
      Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_DramaStart, {path})
    elseif v.classType == TaskOperClassType.Oper_PlayEffect then
      local playEffectCfg = TaskInterface.GetTaskOperPlayEffectOperate(v.id)
      local effectCfg = GetEffectRes(playEffectCfg.effectIds[1])
      if effectCfg then
        do
          local fx = require("Fx.GUIFxMan").Instance():Play(effectCfg.path, "taskfinshEffect", 0, 0, -1, false)
          GameUtil.AddGlobalTimer(playEffectCfg.playTime / 1000, true, function()
            Object.Destroy(fx)
          end)
        end
      end
    elseif v.classType == TaskOperClassType.Oper_GoToPosition then
    end
  end
  require("Fx.GUIFxMan").Instance():Play(RESPATH.TASK_FINISHED_EFFECT, "taskfinsh", 0, 0, -1, false)
  local ECSoundMan = require("Sound.ECSoundMan")
  ECSoundMan.Instance():Play2DSoundByID(720060009)
end
def.static("number").TaskOperGotoPosition = function(id)
  local posCfg = TaskInterface.GetTaskOperGotoPosition(id)
  if posCfg then
    do
      local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
      local teamData = require("Main.Team.TeamData").Instance()
      local hasAirCraft = FlyModule.Instance():HasAirCraft()
      if teamData:HasTeam() == true then
        local myid = heroModule:GetMyRoleId()
        if teamData:IsCaptain(myid) then
          if hasAirCraft then
            local function callback()
              heroModule:FlyDown()
            end
            heroModule:MoveToPos(posCfg.mapID, posCfg.positionX, posCfg.positionY, Space.SKY, 0, MoveType.FLY, callback)
          else
            heroModule:MoveToPos(posCfg.mapID, posCfg.positionX, posCfg.positionY, 0, 0, MoveType.AUTO, nil)
          end
        end
      elseif hasAirCraft then
        local function callback()
          heroModule:FlyDown()
        end
        heroModule:MoveToPos(posCfg.mapID, posCfg.positionX, posCfg.positionY, Space.SKY, 0, MoveType.FLY, callback)
      else
        heroModule:MoveToPos(posCfg.mapID, posCfg.positionX, posCfg.positionY, 0, 0, MoveType.AUTO, nil)
      end
    end
  end
end
def.static("table", "table").OnTaskFinishable = function(p1, p2)
  local taskId = p1[1]
  local graphId = p1[2]
  local self = instance
  instance:CloseTaskTalk(taskId, graphId)
  if taskId == self._circlePathTaskID and graphId == self._circlePathGraphID then
    local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
    self:ClearTaskFindPath()
    heroModule:Stop()
  end
  local taskCfg = TaskInterface.GetTaskCfg(taskId)
  if taskCfg == nil then
    return
  end
  local conditionID = taskCfg.FindFinishConditionID(TaskConClassType.CON_TO_PLACE)
  if conditionID > 0 then
    local condCfg = TaskInterface.GetTaskConditionArrive(conditionID)
    if condCfg.tipDialog ~= nil and condCfg.tipDialog ~= "" then
      Toast(condCfg.tipDialog)
    end
  end
  if taskCfg.finishAutoFindPath == true then
    if taskInterface._curTaskId == 0 and not self._isTaskFindPathing or taskInterface._curTaskId == taskId then
      TaskModule.TaskFindPath({taskId, graphId}, nil)
      self._isTaskFindPathing = true
      GameUtil.AddGlobalTimer(2, true, function()
        taskInterface._curTaskId = 0
        self._isTaskFindPathing = false
      end)
    else
      warn("!!!!!!!!!!!!!!!!!!!###### findPath fail:", taskInterface._curTaskId, taskId, self._isTaskFindPathing)
    end
  end
end
def.static("table", "table").OnNewTeamLeader = function(p1, p2)
  local newTeamLeaderId = p1[1]
  local self = instance
  self:CloseTaskTalk(self._FinishTalkTaskId, self._FinishTalkGraphId)
end
def.static("table", "table").OnMemberStatusChanged = function(p1, p2)
  local member = p1[1]
  local status = p1[2]
  local self = instance
  if member ~= nil and member:eq(gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()) and status ~= require("netio.protocol.mzm.gsp.team.TeamMember").ST_TMP_NORMAL then
    self:CloseTaskTalk(self._FinishTalkTaskId, self._FinishTalkGraphId)
  end
end
def.static("table", "table").OnMemberLeave = function(p1, p2)
  local member = p1[1]
  local self = instance
  if member == nil or member:eq(gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()) then
    self:CloseTaskTalk(self._FinishTalkTaskId, self._FinishTalkGraphId)
  end
end
def.static("table", "table").OnMemberKick = function(p1, p2)
  local self = instance
  self:CloseTaskTalk(self._FinishTalkTaskId, self._FinishTalkGraphId)
end
def.static("table", "table").OnItemTaskUse = function(context, p2)
  local taskID = context.taskId
  local graphID = context.graphId
  if taskID ~= 0 and graphID ~= 0 then
    local taskInfo = taskInterface:GetTaskInfo(taskID, graphID)
    if taskInfo ~= nil and taskInfo.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT then
      local taskCfg = TaskInterface.GetTaskCfg(taskID)
      local taskGoodsCfg
      if 0 < taskCfg.giveTaskGoods then
        taskGoodsCfg = TaskInterface.GetTaskGoodsCfg(taskCfg.giveTaskGoods)
      end
      if taskGoodsCfg ~= nil and taskGoodsCfg.canuse == true then
        local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
        local myRole = heroModule.myRole
        if myRole == nil then
          return
        end
        local heroPos = heroModule.myRole:GetPos()
        local myx = heroPos.x
        local myy = heroPos.y
        if taskGoodsCfg.mapid ~= 0 and taskGoodsCfg.posx ~= 0 and taskGoodsCfg.posy ~= 0 then
          local dx = (taskGoodsCfg.posx - myx) * (taskGoodsCfg.posx - myx)
          local dy = (taskGoodsCfg.posy - myy) * (taskGoodsCfg.posy - myy)
          local d = dx + dy
          local MapModule = gmodule.moduleMgr:GetModule(ModuleId.MAP)
          local mapID = MapModule:GetMapId()
          if mapID ~= taskGoodsCfg.mapid or d > 32768 then
            Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_TaskFindPath, {taskID, graphID})
          else
            TaskModule.OnUseTaskItem(taskID, graphID, taskGoodsCfg)
          end
        else
          TaskModule.OnUseTaskItem(taskID, graphID, taskGoodsCfg)
        end
      end
    end
  end
end
def.static("number", "number", "table").OnUseTaskItem = function(taskID, graphID, taskGoodsCfg)
  local TaskGoodsUseEffect = require("consts.mzm.gsp.item.confbean.TaskGoodsUseEffect")
  if taskGoodsCfg.useEffectType == TaskGoodsUseEffect.DISPLAY_WORDS then
    instance._isGatheringItem = true
    local CollectSliderPanel = require("GUI.CollectSliderPanel")
    CollectSliderPanel.ShowCollectSliderPanel(taskGoodsCfg.displayWords, 3, function()
      instance._isGatheringItem = false
    end, function(tag)
      if taskGoodsCfg.specialEffect ~= 0 then
        local effRes = GetEffectRes(taskGoodsCfg.specialEffect)
        require("Fx.GUIFxMan").Instance():Play(effRes.path, "usetaskitem", 0, 0, -1, false)
      end
      local p = require("netio.protocol.mzm.gsp.task.CAfterUseTaskItem").new(tag.taskID, tag.graphID, tag.itemID)
      gmodule.network.sendProtocol(p)
      instance._isGatheringItem = false
    end, {
      taskID = taskID,
      graphID = graphID,
      itemID = taskGoodsCfg.id
    })
  elseif taskGoodsCfg.useEffectType == TaskGoodsUseEffect.SPECIAL_EFFECT then
    if taskGoodsCfg.specialEffect ~= 0 then
      local effRes = GetEffectRes(taskGoodsCfg.specialEffect)
      require("Fx.GUIFxMan").Instance():Play(effRes.path, "usetaskitem", 0, 0, -1, false)
    end
    local p = require("netio.protocol.mzm.gsp.task.CAfterUseTaskItem").new(taskID, graphID, taskGoodsCfg.id)
    gmodule.network.sendProtocol(p)
  end
end
def.static("table", "table").OnDramaStart = function(p1, p2)
  require("Main.task.ui.TaskDrama").Instance():ShowDlg()
end
def.static("number", "number").DoAceptTask = function(taskID, graphID)
  local tag = {}
  tag.taskID = taskID
  tag.graphID = graphID
  TaskModule.OnAceptTaskConfirm(1, tag)
end
def.static("number", "table").OnAceptTaskConfirm = function(id, tag)
  if id == 1 then
    local taskID = tag.taskID
    local graphID = tag.graphID
    require("Main.task.TaskAceptOperationByGraph").Instance():AceptTask(taskID, graphID)
    if taskInterface._resetTask[graphID] then
      taskInterface._resetTask[graphID] = nil
    end
  end
end
def.static("number", "number").DoFinishTask = function(taskID, graphID)
  local taskCfg = TaskInterface.GetTaskCfg(taskID)
  local taskInfo = taskInterface:GetTaskInfo(taskID, graphID)
  local conditionID = -1
  conditionID = taskCfg.FindFinishConditionID(TaskConClassType.CON_BAG)
  if conditionID > 0 then
    local condCfg = TaskInterface.GetTaskConditionBag(conditionID)
    local ItemUtils = require("Main.Item.ItemUtils")
    local bagID = require("netio.protocol.mzm.gsp.item.BagInfo").BAG
    for k, opera in pairs(taskCfg.finishOperIds) do
      local operateCfg = TaskInterface.GetTaskGiveItemOperate(opera.id)
      if operateCfg ~= nil then
        local takeItemBase = ItemUtils.GetItemBase(operateCfg.cfgId)
        if takeItemBase == nil then
          instance._taskGiveTargetTaskID = taskID
          instance._taskGiveTargetgraphID = graphID
          Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_GiveItem, {
            operateCfg.cfgId,
            operateCfg.cfgCount
          })
          return
        end
      end
    end
    local itemData = require("Main.Item.ItemData").Instance()
    local count = 0
    local UUIDs = {}
    UUIDs, count = itemData:GetItemUUIDsByItemId(bagID, condCfg.takeCfgId, condCfg.takeCfgCount, nil)
    TaskModule._DoFinishTaskReq(taskID, graphID, nil, UUIDs)
    return
  end
  conditionID = taskCfg.FindFinishConditionID(TaskConClassType.CON_PET)
  if conditionID > 0 then
    local condCfg = TaskInterface.GetTaskConditionPet(conditionID)
    for k, opera in pairs(taskCfg.finishOperIds) do
      local operateCfg = TaskInterface.GetTaskGivePetOperate(opera.id)
      if operateCfg ~= nil then
        instance._taskGiveTargetTaskID = taskID
        instance._taskGiveTargetgraphID = graphID
        Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_GivePet, {
          operateCfg.takePet
        })
        return
      end
    end
  end
  TaskModule._DoFinishTaskReq(taskID, graphID, nil, nil)
end
def.static("number", "number", "table", "table")._DoFinishTaskReq = function(taskID, graphID, GivePet, GiveItems)
  local self = instance
  local pFinish = require("netio.protocol.mzm.gsp.task.CFinishTaskReq").new(taskID, graphID, GivePet, GiveItems)
  gmodule.network.sendProtocol(pFinish)
  self._LastFinishGraphID = graphID
  self._LastFinishTaskID = taskID
  self._LastFinishTime = os.time()
end
def.static("table", "table").OnLeaveFight = function()
  local self = instance
  self:ContinueCirclePath()
  local ProtocolsCache = require("Main.Common.ProtocolsCache")
  ProtocolsCache.Instance():ReleaseCachedProtocols()
  warn("OnLeaveFight")
end
def.static("table", "table").TaskTraceItemClick = function(p1, p2)
  local taskID = p1[1]
  local graphID = p1[2]
  local self = instance
  if _G.CheckCrossServerAndToast() then
    return
  end
  if taskInterface:isBanTaskGraphId(graphID) then
    Toast(textRes.Task[401])
    return
  end
  if TaskModule.CheckActivityOnTaskTraceQuit() then
    return
  end
  local taskDeliveryByGraph = require("Main.task.TaskDeliveryByGraph").Instance()
  local result = taskDeliveryByGraph:DeliveryByGraph(taskID, graphID)
  if result == true then
    if PlayerIsInFight() == true then
      warn("********************\229\156\168\230\136\152\230\150\151\228\184\173\229\143\145\232\181\183\228\187\187\229\138\161\229\175\187\232\183\175\239\188\140\229\188\138\230\142\137\239\188\129")
      return
    end
    local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
    local teamData = require("Main.Team.TeamData").Instance()
    local myRoleID = heroModule:GetMyRoleId()
    local ret = teamData:HasTeam() == true and teamData:IsCaptain(myRoleID) == false
    if ret == true then
      local ST_NORMAL = require("netio.protocol.mzm.gsp.team.TeamMember").ST_NORMAL
      local isNormal = teamData:GetMemberStatus(myRoleID) == ST_NORMAL
      if isNormal == true then
        Toast(textRes.NPC[22])
        Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_MOVE_IN_TEAM_FOLLOW, nil)
        return
      end
    end
    local taskInfo = taskInterface:GetTaskInfo(taskID, graphID)
    if taskInterface._resetTask[graphID] and taskInfo.state == TaskConsts.TASK_STATE_CAN_ACCEPT then
      local info = {taskID, graphID}
      taskInterface._accpetTaskInfo = info
      local pAccept = require("netio.protocol.mzm.gsp.task.CAcceptTaskReq").new(taskID, graphID)
      gmodule.network.sendProtocol(pAccept)
      warn("--------resetTask send AcceptTask")
      return
    end
    local taskCfg = TaskInterface.GetTaskCfg(taskID)
    if taskInfo.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT then
      local conditionID = taskCfg.FindFinishConditionID(TaskConClassType.CON_SHARE)
      if conditionID > 0 then
        if sdktype == ClientCfg.SDKTYPE.MSDK then
          local sharePengYouCfg = TaskInterface.GetTaskConSharePengYouQuan(conditionID)
          local shareId = sharePengYouCfg.shareId
          local shareCfg = TaskInterface.GetTaskShareCfg(shareId)
          require("Main.Common.CommonSharePanel").Instance():ShowPanel(shareCfg.shareType, shareCfg.picURL)
          warn("-----------------Share param:", shareCfg.picURL, shareCfg.shareType)
          self._curShareId = shareId
          return
        elseif sdktype == ClientCfg.SDKTYPE.UNISDK then
          local ECUniSDK = require("ProxySDK.ECUniSDK")
          if ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.LOONG) then
            ECUniSDK.Instance():Share({
              title = textRes.RelationShipChain[101],
              desc = textRes.RelationShipChain[104]
            })
          end
        end
      end
    end
    taskInterface._curTaskId = taskID
    TaskModule.TaskFindPath({taskID, graphID}, nil)
  end
end
def.static("=>", "boolean").CheckActivityOnTaskTraceQuit = function(p1, p2)
  local myRole = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if myRole:IsInState(RoleState.TXHW) then
    require("Main.PK.PKModule").Instance():Quit()
  elseif myRole:IsInState(RoleState.SXZB) then
    require("Main.PVP.LeaderBattleModule").Instance():Quit()
  elseif myRole:IsInState(RoleState.GANGBATTLE) then
    require("GUI.CommonConfirmDlg").ShowConfirm("", textRes.PVP[14], function(i, tag)
      if i == 1 then
        gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.competition.CLeaveCompetitionMapReq").new())
      end
    end, nil)
  else
    return false
  end
  return true
end
def.static("table", "table").TaskFindPath = function(p1, p2)
  local taskID = p1[1]
  local graphID = p1[2]
  local self = instance
  if (self._Cancel_Once_PathFind_graphID <= 0 or self._Cancel_Once_PathFind_graphID == graphID) and self._Cancel_Once_PathFind == true then
    self._Cancel_Once_PathFind = false
    return
  end
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  if heroModule.myRole == nil or heroModule.myRole:IsInState(RoleState.UNTRANPORTABLE) then
    return
  end
  local pubMgr = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  if pubMgr:IsInWedding() then
    Toast(textRes.Hero[55])
    return
  end
  if pubMgr:IsInWeddingParade() then
    Toast(textRes.Hero[61])
    return
  end
  local FightMgr = require("Main.Fight.FightMgr")
  if PlayerIsInFight() == true then
    self._EndFight_PathFind_TaskId = taskID
    self._EndFight_PathFind_graphId = graphID
    return
  end
  if CGPlay == true then
    self._EndOpera_PathFind_TaskId = taskID
    self._EndOpera_PathFind_graphId = graphID
    return
  end
  if pubMgr:IsInFollowState(heroModule.roleId) then
    return
  end
  npcInterface:SetTargetNPCID(0)
  self:ClearTaskFindPath()
  local taskInfo = taskInterface:GetTaskInfo(taskID, graphID)
  local taskCfg = TaskInterface.GetTaskCfg(taskID)
  self._Last_PathFind_TaskId = taskID
  self._Last_PathFind_graphId = graphID
  local targetNPCID = taskCfg.GetFinishTaskNPC()
  if taskInfo.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT then
    if taskCfg.pathFinds ~= nil and taskCfg.pathFinds[1] ~= nil then
      local pathFind = taskCfg.pathFinds[1]
      targetNPCID = 0
      local moveType = MoveType.AUTO
      if 1 < #taskCfg.pathFinds then
        self._circlePath = taskCfg.pathFinds
        self._circlePathIndex = 1
        self._circlePathTaskID = taskID
        self._circlePathGraphID = graphID
        moveType = MoveType.RUN
      end
      local myRole = heroModule.myRole
      if myRole == nil then
        return
      end
      local heroPos = heroModule.myRole:GetPos()
      local myx = heroPos.x
      local myy = heroPos.y
      local dx = (pathFind.x - myx) * (pathFind.x - myx)
      local dy = (pathFind.y - myy) * (pathFind.y - myy)
      local d = dx + dy
      local MapModule = gmodule.moduleMgr:GetModule(ModuleId.MAP)
      local mapID = MapModule:GetMapId()
      if mapID ~= pathFind.mapID or d > 32768 then
        if 1 < #taskCfg.pathFinds then
          heroModule.needShowAutoEffect = false
          if heroModule.myRole:IsInState(RoleState.HUG) then
            Toast(textRes.Hero[54])
          elseif heroModule.myRole:IsInState(RoleState.BEHUG) then
            Toast(textRes.Hero[52])
          else
            heroModule:MoveToPos(pathFind.mapID, pathFind.x, pathFind.y, 0, 0, MoveType.RUN, nil)
            require("Main.Hero.ui.XunluTip").ShowXunluo()
            heroModule.isTaskCircle = true
          end
        else
          heroModule.needShowAutoEffect = true
          if pathFind.mapID == GangUtility.GetGangConsts("GANG_MAP") then
            local GangBattleMgr = require("Main.Gang.GangBattleMgr")
            GangBattleMgr.Instance():GotoGangMapPos(pathFind.x, pathFind.y)
          else
            heroModule:MoveTo(pathFind.mapID, pathFind.x, pathFind.y, 0, 0, moveType, nil)
          end
        end
      else
        TaskModule.OnFindpathFinished({myx, myy}, nil)
      end
    else
      while true do
        if 0 < taskCfg.giveTaskGoods then
          local taskGoodsCfg = TaskInterface.GetTaskGoodsCfg(taskCfg.giveTaskGoods)
          local myRole = heroModule.myRole
          if myRole == nil then
            return
          end
          local heroPos = heroModule.myRole:GetPos()
          local myx = heroPos.x
          local myy = heroPos.y
          if taskGoodsCfg.mapid ~= 0 and taskGoodsCfg.posx ~= 0 and taskGoodsCfg.posy ~= 0 then
            local dx = (taskGoodsCfg.posx - myx) * (taskGoodsCfg.posx - myx)
            local dy = (taskGoodsCfg.posy - myy) * (taskGoodsCfg.posy - myy)
            local d = dx + dy
            local MapModule = gmodule.moduleMgr:GetModule(ModuleId.MAP)
            local mapID = MapModule:GetMapId()
            if mapID ~= taskGoodsCfg.mapid or d > 32768 then
              heroModule.needShowAutoEffect = true
              if heroModule:IsPatroling() == true then
                heroModule:StopPatroling()
              end
              heroModule:MoveTo(taskGoodsCfg.mapid, taskGoodsCfg.posx, taskGoodsCfg.posy, 0, 0, MoveType.AUTO, nil)
            else
              TaskModule.OnFindpathFinished({myx, myy}, nil)
            end
          else
            TaskModule.OnFindpathFinished({myx, myy}, nil)
          end
          targetNPCID = 0
          break
        end
        if taskCfg.pathNpcId ~= 0 then
          targetNPCID = taskCfg.pathNpcId
          break
        end
        local conditionID = -1
        conditionID = taskCfg.FindFinishConditionID(TaskConClassType.CON_NPC_DLG)
        if conditionID > 0 then
          local condCfg = TaskInterface.GetTaskConditionNPCDialog(conditionID)
          targetNPCID = condCfg.NpcID
          break
        end
        conditionID = taskCfg.FindFinishConditionID(TaskConClassType.CON_KILL_NPC)
        if conditionID > 0 then
          local condCfg = TaskInterface.GetTaskConditionKillNpc(conditionID)
          targetNPCID = condCfg.fixNPCId
          break
        end
        break
      end
      if taskCfg.noSeekPath == true and targetNPCID > 0 then
        taskInterface:SetTaskPathFindParam(taskID, graphID)
        Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_ImmediateDoNPC, {targetNPCID, targetGraphID = graphID})
        return
      end
      if taskCfg.serviceId ~= 0 then
        local serviceTypeNotify = {}
        serviceTypeNotify[NPCInterface.NPC_TYPE_NORMAL] = gmodule.notifyId.NPC.NPC_SERVICE
        serviceTypeNotify[NPCInterface.NPC_TYPE_TRADE] = gmodule.notifyId.NPC.NPC_TRADE
        serviceTypeNotify[NPCInterface.NPC_TYPE_TRANSFER] = gmodule.notifyId.NPC.NPC_TRANSFER
        serviceTypeNotify[NPCInterface.NPC_TYPE_STALL] = gmodule.notifyId.NPC.NPC_STALL
        local serviceCfg = NPCInterface.GetNpcServiceCfg(taskCfg.serviceId)
        local notify = serviceTypeNotify[serviceCfg.serviceType]
        if notify ~= nil then
          Event.DispatchEvent(ModuleId.NPC, notify, {
            taskCfg.serviceId,
            targetNPCID
          })
          return
        end
      end
    end
  end
  if targetNPCID > 0 then
    taskInterface:SetTaskPathFindParam(taskID, graphID)
    Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_GotoNPC, {
      npcID = targetNPCID,
      useFlySword = taskCfg.useFlySword,
      targetTaskID = taskID,
      targetGraphID = graphID
    })
  end
end
def.static("table", "table").OnTaskInfoChanged = function(p1, p2)
  if p1 ~= nil then
    local taskID = p1[1]
    local graphID = p1[2]
    if taskID ~= nil and graphID ~= nil then
      instance:CloseTaskTalk(taskID, graphID)
    end
  end
end
def.static("table", "table").OnShowCaptainTaskTalk = function(p1, p2)
  local self = instance
  local taskId = p1[1]
  local graphId = p1[2]
  local talkType = p1[3]
  local talkIndex = p1[4]
  if talkIndex > 0 then
    local talkCfg = TaskInterface.GetTaskTalkCfg(taskId)
    local dlgs = talkCfg.dlgs[talkType]
    if dlgs ~= nil and 0 < table.maxn(dlgs.content) then
      self._talkType = talkType
      if talkIndex == 1 or self._FinishTalkTaskId == taskId and self._FinishTalkGraphId == graphId and talkIndex > self._talkIndex then
        self:ShowNPCText(dlgs.content, TaskModule.ToDoFinishTalk_None, taskId, graphId, talkIndex)
      end
    end
  else
    self:CloseTaskTalk(taskId, graphId)
  end
end
def.static("table", "table").OnDramaOver = function(p1, p2)
  local self = instance
  local taskID = self._EndOpera_PathFind_TaskId
  local graphID = self._EndOpera_PathFind_graphId
  if self._EndOpera_PathFind_TaskId ~= 0 and self._EndOpera_PathFind_graphId ~= 0 then
    self._EndOpera_PathFind_TaskId = 0
    self._EndOpera_PathFind_graphId = 0
    TaskModule.TaskFindPath({taskID, graphID}, nil)
  end
  local ProtocolsCache = require("Main.Common.ProtocolsCache")
  ProtocolsCache.Instance():ReleaseCachedProtocols()
  warn("OnDramaOver")
end
def.static("table", "table").OnTaskTalkHide = function(p1, p2)
  local self = instance
  if self._InterruptSound ~= nil then
    self._InterruptSound:Stop(0)
    self._InterruptSound = nil
  end
end
def.static("table", "table").OnMainUIQYZhi = function(p1, p2)
  require("Main.task.ui.QingYunHistory").Instance():ShowDlg()
end
def.static(TaskModule).fn_ToDoFinishTalk_None = function(self)
  local npcTalk = require("Main.task.ui.TaskTalk").Instance()
  npcTalk:FadeOut()
end
def.static(TaskModule).fn_ToDoFinishTalk_AceptTask = function(self)
  TaskModule.fn_ToDoFinishTalk_None(self)
  if self._FinishTalkTaskId ~= 0 and self._FinishTalkGraphId ~= 0 then
    TaskModule.DoAceptTask(self._FinishTalkTaskId, self._FinishTalkGraphId)
  end
end
def.static(TaskModule).fn_ToDoFinishTalk_FinishiTask = function(self)
  TaskModule.fn_ToDoFinishTalk_None(self)
  if self._FinishTalkTaskId ~= 0 and self._FinishTalkGraphId ~= 0 then
    TaskModule.DoFinishTask(self._FinishTalkTaskId, self._FinishTalkGraphId)
  end
end
def.static(TaskModule).fn_ToDoFinishTalk_FightTask = function(self)
  if self._FinishTalkTaskId ~= 0 and self._FinishTalkGraphId ~= 0 then
    TaskModule.DoFinishTargetTalk(self._FinishTalkTaskId, self._FinishTalkGraphId)
  end
  self:CloseTaskTalk(self._FinishTalkTaskId, self._FinishTalkGraphId)
end
def.static(TaskModule).fn_ToDoFinishTalk_TargetTalk = function(self)
  TaskModule.fn_ToDoFinishTalk_None(self)
  if self._FinishTalkTaskId ~= 0 and self._FinishTalkGraphId ~= 0 then
    TaskModule.DoFinishTargetTalk(self._FinishTalkTaskId, self._FinishTalkGraphId)
  end
end
def.static(TaskModule).fn_ToDoFinishTalk_Custom = function(self)
  TaskModule.fn_ToDoFinishTalk_None(self)
  if self._talkCustomCallbackFn ~= nil then
    self._talkCustomCallbackFn(self._talkCustomCallbackParam)
    self._talkCustomCallbackFn = nil
    self._talkCustomCallbackParam = nil
  end
end
def.method().ContinueCirclePath = function(self)
  if self._circlePath ~= nil and #self._circlePath > 1 then
    self._circlePathIndex = self._circlePathIndex + 1
    if self._circlePathIndex > #self._circlePath then
      self._circlePathIndex = 1
    end
    local nextPt = self._circlePath[self._circlePathIndex]
    local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
    heroModule.needShowAutoEffect = false
    heroModule:MoveToPos(nextPt.mapID, nextPt.x, nextPt.y, 0, 0, MoveType.RUN, nil)
    require("Main.Hero.ui.XunluTip").ShowXunluo()
    heroModule.isTaskCircle = true
  end
end
def.method("table", "number", "number", "number", "number").ShowNPCText = function(self, talks, todo, taskId, graphId, talkIndex)
  self._talkIndex = talkIndex - 1
  self._CurrentTalkTable = talks
  self._ToDoFinishTalk = todo
  self._FinishTalkTaskId = taskId
  self._FinishTalkGraphId = graphId
  self:ShowNextNPCText()
end
def.method("table", "table", "function").ShowTaskTalkCustom = function(self, talks, param, fnCallback)
  self._talkCustomCallbackFn = fnCallback
  self._talkCustomCallbackParam = param
  self:ShowNPCText(talks, TaskModule.ToDoFinishTalk_Custom, 0, 0, 1)
end
def.method().ShowNextNPCText = function(self)
  self._talkIndex = self._talkIndex + 1
  local talk = self._CurrentTalkTable[self._talkIndex]
  local IamCaptain = false
  local teamData = require("Main.Team.TeamData").Instance()
  if teamData:HasTeam() == true then
    local myid = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
    IamCaptain = teamData:IsCaptain(myid)
  end
  local taskID = self._FinishTalkTaskId
  local graphID = self._FinishTalkGraphId
  local npcTalk = require("Main.task.ui.TaskTalk").Instance()
  if talk == nil then
    local fn = TaskModule.fn_ToDoFinishTalk[self._ToDoFinishTalk]
    if fn ~= nil then
      fn(self)
    else
      npcTalk:HideDlg()
    end
    if IamCaptain == true and taskID ~= 0 and graphID ~= 0 then
      self:SendCaptainTalk(taskID, graphID, self._talkType, -1)
    end
    return
  end
  if IamCaptain == true and taskID ~= 0 and graphID ~= 0 then
    self:SendCaptainTalk(taskID, graphID, self._talkType, self._talkIndex)
  end
  npcTalk:SetNPCID(talk.npcid)
  if taskID ~= 0 and graphID ~= 0 then
    local taskCfg = TaskInterface.GetTaskCfg(taskID)
    local taskInfo = taskInterface:GetTaskInfo(taskID, graphID)
    local TaskString = require("Main.task.TaskString")
    local taskString = TaskString.Instance()
    taskString:SetTargetTaskCfg(taskCfg)
    if taskInfo ~= nil then
      taskString:SetConditionData(taskInfo.conDatas)
    end
    local str = string.gsub(talk.txt, "%$%((.-)%)%$", TaskString.DoReplace)
    npcTalk:SetText(str)
  else
    npcTalk:SetText(talk.txt)
  end
  local voiceID = talk.voiceID or 0
  if voiceID ~= 0 then
    voiceID = TaskInterface.FindTaskVoiceID(voiceID, talk.npcid)
  end
  if self._InterruptSound ~= nil then
    self._InterruptSound:Stop(0)
    self._InterruptSound = nil
  end
  if voiceID ~= 0 then
    local ECSoundMan = require("Sound.ECSoundMan")
    self._InterruptSound = ECSoundMan.Instance():Play2DInterruptSoundByID(voiceID)
  end
  npcTalk:ShowDlg()
end
def.method("number", "number").CloseTaskTalk = function(self, taskID, graphID)
  if taskID == self._FinishTalkTaskId and graphID == self._FinishTalkGraphId and taskID ~= 0 and taskID ~= 0 then
    local npcTalk = require("Main.task.ui.TaskTalk").Instance()
    if npcTalk:IsShow() == true then
      npcTalk:FadeOut()
    end
    self._FinishTalkTaskId = 0
    self._FinishTalkGraphId = 0
    self._talkIndex = 0
  else
    local npcTalk = require("Main.task.ui.TaskTalk").Instance()
    if npcTalk:IsShow() == true then
      npcTalk:HideDlg()
    end
  end
end
def.method("number", "number", "number", "number").SendCaptainTalk = function(self, taskID, graphID, talkType, talkIndex)
  local p = require("netio.protocol.mzm.gsp.task.CTaskTalk").new(taskID, graphID, talkType, talkIndex)
  gmodule.network.sendProtocol(p)
end
def.method("number").StopDoingTaskPathFind = function(self, graphID)
  self._Cancel_Once_PathFind_graphID = graphID
  self._Cancel_Once_PathFind = true
  if graphID <= 0 then
    local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
    if heroModule.myRole:IsInState(RoleState.RUN) then
      heroModule.myRole:Stop()
      self._Cancel_Once_PathFind = false
    end
  end
end
def.static("number", "number").DoFinishTargetTalk = function(taskID, graphID)
  local NPCInterfaceInstance = require("Main.npc.NPCInterface").Instance()
  local npcid = NPCInterfaceInstance:GetLastInteractiveNPCID()
  local p = require("netio.protocol.mzm.gsp.npc.CFinishDlgReq").new(npcid, taskID)
  gmodule.network.sendProtocol(p)
end
def.static("number", "number").OnNPCService_QueryZhenYaoTask = function(serviceID, npcID)
  local DoublePointData = require("Main.OnHook.DoublePointData")
  local doublePoint = DoublePointData.Instance():GetGetingPoolPointNum()
  local frozenPoint = DoublePointData.Instance():GetFrozenPoolPointNum()
  doublePoint = doublePoint + frozenPoint
  local contents = {}
  local content = {}
  content.npcid = npcID
  local allNum = activityInterface._singleCount + activityInterface._doubleCount
  local maxNum = constant.ZhenYaoActivityCfgConsts.ZhenYao_MAX_AWARD_COUNT
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
  if feature:CheckFeatureOpen(Feature.TYPE_ZHENYAO_FIFTY_AWARD) then
    maxNum = constant.ZhenYaoActivityCfgConsts.ZhenYao_MAX_AWARD_COUNT2
  end
  if allNum > maxNum then
    allNum = maxNum
  end
  content.txt = string.format(textRes.Task[240], allNum, maxNum - allNum, doublePoint, frozenPoint)
  table.insert(contents, content)
  local taskModule = gmodule.moduleMgr:GetModule(ModuleId.TASK)
  taskModule:ShowTaskTalkCustom(contents, nil, nil)
end
def.static("number").PlaySpecialEffectCfg = function(specialEffectID)
  local specialEffectCfg = TaskInterface.GetTaskSpecialEffectCfg(specialEffectID)
  local effRes = GetEffectRes(specialEffectCfg.effectId)
  if specialEffectCfg.loadType == EffectLoadType.NPC then
    local npcCfg = NPCInterface.GetNPCCfg(specialEffectCfg.npcId)
    require("Fx.ECFxMan").Instance():PlayEffectAt2DWorldPos(effRes.path, npcCfg.x, npcCfg.y)
  elseif specialEffectCfg.loadType == EffectLoadType.MAP_LOCATION then
    local x = specialEffectCfg.coordX
    local y = specialEffectCfg.coordY
    require("Fx.ECFxMan").Instance():PlayEffectAt2DWorldPos(effRes.path, x, y)
  elseif specialEffectCfg.loadType == EffectLoadType.FULL_SCREEN then
  end
end
def.static("number", "number", "=>", "boolean")._AutoTaskToDo = function(taskID, graphID)
  local taskInfo = taskInterface:GetTaskInfo(taskID, graphID)
  if taskInfo ~= nil and taskInfo.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT then
    local taskCfg = TaskInterface.GetTaskCfg(taskID)
    if taskCfg.giveTaskGoods > 0 then
      if instance and instance._isGatheringItem then
        Toast(textRes.Task[242])
      else
        local TaskEasyUseDlg = require("Main.Item.ui.TaskEasyUseDlg")
        local taskItem = {}
        taskItem.itemID = taskCfg.giveTaskGoods
        taskItem.count = 1
        taskItem.canBeUsed = true
        taskItem.param = {}
        taskItem.param.taskId = taskID
        taskItem.param.graphId = graphID
        TaskEasyUseDlg.ShowTaskEasyUse(taskItem)
      end
      return true
    end
    local pubroleModule = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
    for k, v in pairs(taskCfg.finishConIds) do
      if v.classType == TaskConClassType.CON_GATHER_ITEM then
        if instance._gatherItems == nil then
          instance._gatherItems = {}
        end
        local taskItems = instance._gatherItems[taskID]
        if taskItems then
          for _, item in pairs(taskItems) do
            if pubroleModule:GetMapItem(item.id) == nil then
              instance._gatherItems[taskID] = nil
            end
          end
        end
        if instance._gatherItems[taskID] == nil then
          taskItems = {}
          instance._gatherItems[taskID] = taskItems
          local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
          local heroPos = heroModule.myRole:GetPos()
          local myx = heroPos.x
          local myy = heroPos.y
          local nearlestInstanceID = 0
          local condition = TaskInterface.GetTaskConditionGatherItem(v.id)
          for instanceID, item in pairs(pubroleModule.itemMap) do
            if item:GetCfgId() == condition.gatherId then
              local itemPos = item:GetPos()
              local itemx = itemPos.x
              local itemy = itemPos.y
              local dx = (itemx - myx) * (itemx - myx)
              local dy = (itemy - myy) * (itemy - myy)
              local d = dx + dy
              table.insert(taskItems, {dist = d, id = instanceID})
            end
          end
          table.sort(taskItems, function(a, b)
            return a.dist < b.dist
          end)
        end
        TaskModule._AutoTaskDoGather(taskID)
        return true
      end
    end
  end
  return false
end
def.static("number")._AutoTaskDoGather = function(taskId)
  if instance._gatherItems == nil or instance._gatherItems[taskId] == nil then
    return
  end
  local target = instance._gatherItems[taskId][1]
  if target == nil then
    instance._gatherItems[taskId] = nil
    return
  end
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_ITEM, {
    target.id
  })
end
def.static("table", "table").OnGatherItemDone = function(p1, p2)
  local itemId = p1 and p1[1]
  if itemId == nil or instance._gatherItems == nil then
    return
  end
  for taskId, items in pairs(instance._gatherItems) do
    for _, v in pairs(items) do
      if v.id == itemId then
        gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):RemoveItem(itemId)
        table.remove(items, 1)
        if #items == 0 then
          instance._gatherItems[taskId] = nil
        end
        return
      end
    end
  end
end
def.static("table", "table").OnConvoyEnd = function(p1, p2)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ACTIVITY_CHuSongCfg, activityInterface._husongcfgid)
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.handupNPCid = record:GetIntValue("levelMax")
  cfg.handupNPCWord = record:GetIntValue("handupNPCWord")
  local contents = {}
  local content = {}
  content.npcid = cfg.handupNPCid
  content.txt = cfg.handupNPCWord
  table.insert(contents, content)
  self:ShowNPCText(contents, TaskModule.ToDoFinishTalk_Custom, 0, 0, 1)
end
def.static("table", "table").OnActivityReset = function(p1, p2)
  local activityId = p1[1]
  if activityId == constant.ShimenActivityCfgConsts.SHIMEN_ACTIVITY_ID then
    taskInterface:resetShimenTask()
  elseif activityId == constant.GangTaskConsts.ACTIVITYID then
    taskInterface:resetTaskCondition(constant.GangTaskConsts.TASK_GRAPH_ID, 0)
  elseif activityId == constant.BountyConsts.BOUNTYHUNTER_ACTIVITYID then
    taskInterface:resetTaskCondition(constant.BountyConsts.BOUNTYHUNTER_GUIDE_GRAPH_ID, 0)
  elseif activityId == constant.BaoTuActivityCfgConsts.BAOTU_ACTIVITY_ID then
    taskInterface:resetTaskCondition(constant.BaoTuActivityCfgConsts.BAOTU_GUIDE_GRAPH_ID, 0)
  elseif activityId == constant.HuanHunMiShuConsts.HUANHUN_ACTIVITYID then
    local graphId = constant.HuanHunMiShuConsts.HUANHUN_TASK_GRAPH_ID
    local taskId = taskInterface:GetTaskIdByGraphId(graphId)
    if taskId > 0 then
      taskInterface:RemoveTaskInfo(taskId, graphId)
      Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_InfoChanged, {taskId, graphId})
    end
  end
end
def.static("table", "table").OnActivityStart = function(p1, p2)
  local activityId = p1[1]
  local activeGraphCfg = TaskInterface.IsOwnLevelActiveGraphCfgByActivityId(activityId)
  if activeGraphCfg then
    local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
    local isOpen = feature:CheckFeatureOpen(activeGraphCfg.openId)
    local graphId = activeGraphCfg.graphId
    if isOpen and graphId > 0 then
      taskInterface:resetTaskCondition(graphId, 0)
    end
  end
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  local openId = p1.feature
  local activeGraphCfg = TaskInterface.IsOwnLevelActiveGraphCfgByOpenId(openId)
  if activeGraphCfg then
    local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
    local isOpen = feature:CheckFeatureOpen(openId)
    if isOpen then
      local activityId = activeGraphCfg.activityId
      if activityId == 0 or activityInterface:isAchieveActivityLevel(activityId) and activityInterface:isActivityOpend(activityId) then
        taskInterface:resetTaskCondition(activeGraphCfg.graphId, 0)
      end
    end
  end
end
def.static("table", "table").OnCourtyardLevelUp = function(p1, p2)
  require("Main.npc.NPCModule").RefeshNPCTaskStatus()
end
def.static("table", "table").OnRelationShipChain = function(p1, p2)
  local shareType = p1.shareType
  local flag = p1.flag
  warn("------------>>>>>>>task OnRelationShipChain shareType:", shareType, flag, instance._curShareId)
  local UseType = require("consts.mzm.gsp.giftaward.confbean.UseType")
  if shareType == UseType.TASK_SHARE_GAME and flag == 0 and instance._curShareId > 0 then
    local p = require("netio.protocol.mzm.gsp.task.CShareSuc").new(instance._curShareId, 1)
    gmodule.network.sendProtocol(p)
    warn("----->>>>>>>>>>taskShareFinish:", instance._curShareId)
    instance._curShareId = 0
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SetShareType(0)
  end
end
TaskModule.Commit()
return TaskModule
