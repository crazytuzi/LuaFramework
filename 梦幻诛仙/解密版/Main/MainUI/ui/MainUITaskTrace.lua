local Lplus = require("Lplus")
local ComponentBase = require("Main.MainUI.ui.MainUIComponentBase")
local MainUITaskTrace = Lplus.Extend(ComponentBase, "MainUITaskTrace")
local Vector = require("Types.Vector")
local def = MainUITaskTrace.define
local instance
local TaskInterface = require("Main.task.TaskInterface")
local taskInterface = TaskInterface.Instance()
local TaskTargetByGraph = require("Main.task.TaskTargetByGraph")
local taskTargetByGraph = TaskTargetByGraph.Instance()
local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
local TaskConClassType = require("consts.mzm.gsp.task.confbean.TaskConClassType")
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
local NPCInterface = require("Main.npc.NPCInterface")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
def.static("=>", MainUITaskTrace).Instance = function()
  if instance == nil then
    instance = MainUITaskTrace()
    instance:Init()
  end
  return instance
end
MainUITaskTrace._DELAY_REPOSITION_COUNT = 5
def.field("table")._params = nil
def.field("number")._timerRefreshCount = 0
def.field("number")._refreshTimerID = 0
def.field("number")._delayRepositionCount = 0
def.field("boolean")._needResize = false
def.field("table")._taskTraceGraphEnableInFight = nil
def.field("table")._taskTraceRoundLight = nil
def.field("userdata")._taskTraceTable = nil
def.field("userdata")._TaskTrace = nil
def.field("userdata")._scrollCom = nil
def.field("userdata")._listItem1 = nil
def.field("userdata")._Img_Task01 = nil
def.field("table")._listItems = nil
def.field("table")._listItemsChild = nil
def.const("string").TaskLightEffectName = "task_light_effect"
def.override().Init = function(self)
  self._params = {}
  self._taskTraceGraphEnableInFight = {}
  self._taskTraceGraphEnableInFight[constant.HuanHunMiShuConsts.HUANHUN_TASK_GRAPH_ID] = constant.HuanHunMiShuConsts.HUANHUN_TASK_GRAPH_ID
  self._listItems = {}
  self._listItemsChild = {}
end
def.override("=>", "boolean").CanShowInFight = function(self)
  return true
end
def.override().OnCreate = function(self)
  self._taskTraceRoundLight = {}
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_InfoChanged, MainUITaskTrace.OnTaskInfoChanged)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_RingChanged, MainUITaskTrace.OnTaskRingChanged)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_UnAcceptCondChged, MainUITaskTrace.OnTaskUnAcceptCondChged)
  Event.RegisterEvent(ModuleId.DUNGEON, gmodule.notifyId.Dungeon.ENTER_SOLO_DUNGEON, MainUITaskTrace.OnEnterDungeon)
  Event.RegisterEvent(ModuleId.DUNGEON, gmodule.notifyId.Dungeon.LEAVE_SOLO_DUNGEON, MainUITaskTrace.OnLeaveDungeon)
  Event.RegisterEvent(ModuleId.DUNGEON, gmodule.notifyId.Dungeon.ENTER_TEAM_DUNGEON, MainUITaskTrace.OnEnterDungeon)
  Event.RegisterEvent(ModuleId.DUNGEON, gmodule.notifyId.Dungeon.LEAVE_TEAM_DUNGEON, MainUITaskTrace.OnLeaveDungeon)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, MainUITaskTrace.OnHeroLevelUp)
  Event.RegisterEvent(ModuleId.GUIDE, gmodule.notifyId.Guide.Apply_TaskTrace_Light, MainUITaskTrace.OnApplyTaskTraceLight)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_New_Surprise_Task_Change, MainUITaskTrace.OnNewSurpriseTaskChange)
  local TaskTrace = self.m_panel:FindDirect("Pnl_TaskTeam/TaskTeamMenu/Group_Open/Task")
  self._TaskTrace = TaskTrace
  self._scrollCom = TaskTrace:FindDirect("Scroll View_Task"):GetComponent("UIScrollView")
  self._taskTraceTable = TaskTrace:FindDirect("Scroll View_Task/Table")
  self._taskTraceTable:GetComponent("UITable").RecursiveCalcBounds = false
  local listItem1 = TaskTrace:FindDirect("Scroll View_Task/Table/Img_Task01")
  listItem1:set_name("Task_Img_01")
  listItem1:SetActive(false)
  self._listItem1 = listItem1
  local Img_BgPrize = listItem1:FindDirect("Img_BgPrize")
  Img_BgPrize:set_name("Img_BgPrize_01")
  local Group_LabelName = listItem1:FindDirect("Group_LabelName")
  local Task_LabelName = Group_LabelName:FindDirect("Label_TaskName")
  Task_LabelName:set_name("Task_LabelName")
  listItem1:FindDirect("Label_TaskDescribe"):set_name("Task_LabelDescribe")
  Group_LabelName:FindDirect("Img_TaskFight"):set_name("Task_ImgFight")
  Group_LabelName:FindDirect("Img_TaskFinish"):set_name("Task_ImgFinish")
  self._Img_Task01 = self.m_panel:FindDirect("Pnl_TaskTeam/TaskTeamMenu/Group_Open/Tab_Task/Img_Task01")
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_InfoChanged, MainUITaskTrace.OnTaskInfoChanged)
  Event.UnregisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_RingChanged, MainUITaskTrace.OnTaskRingChanged)
  Event.UnregisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_UnAcceptCondChged, MainUITaskTrace.OnTaskUnAcceptCondChged)
  Event.UnregisterEvent(ModuleId.DUNGEON, gmodule.notifyId.Dungeon.ENTER_SOLO_DUNGEON, MainUITaskTrace.OnEnterDungeon)
  Event.UnregisterEvent(ModuleId.DUNGEON, gmodule.notifyId.Dungeon.LEAVE_SOLO_DUNGEON, MainUITaskTrace.OnLeaveDungeon)
  Event.UnregisterEvent(ModuleId.DUNGEON, gmodule.notifyId.Dungeon.ENTER_TEAM_DUNGEON, MainUITaskTrace.OnEnterDungeon)
  Event.UnregisterEvent(ModuleId.DUNGEON, gmodule.notifyId.Dungeon.LEAVE_TEAM_DUNGEON, MainUITaskTrace.OnLeaveDungeon)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, MainUITaskTrace.OnHeroLevelUp)
  Event.UnregisterEvent(ModuleId.GUIDE, gmodule.notifyId.Guide.Apply_TaskTrace_Light, MainUITaskTrace.OnApplyTaskTraceLight)
  Event.UnregisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_New_Surprise_Task_Change, MainUITaskTrace.OnNewSurpriseTaskChange)
  self._delayRepositionCount = 0
  self._listItems = {}
  self._listItemsChild = {}
  Timer:RemoveIrregularTimeListener(self.OnDelayReposition)
end
def.override().OnShow = function(self)
  self:UpdateUI()
end
def.override().OnHide = function(self)
end
def.method().UpdateUI = function(self)
  self:RefreshTaskTrace()
end
def.override("string").OnClick = function(self, id)
  local strs = string.split(id, "_")
  local idx = tonumber(strs[3])
  if strs[1] == "Img" and strs[2] == "BgPrize" and idx ~= nil then
    self:_ShowTaskAwardTip(idx)
  end
  if strs[1] ~= "Task" or idx == nil then
    return
  end
  local param = self._params[idx]
  if param == nil then
    return
  end
  local taskID = param.taskId
  local graphID = param.graphId
  if PlayerIsInFight() and self._taskTraceGraphEnableInFight[graphID] == nil then
    Toast(textRes.Task[30])
    return
  end
  local info = taskInterface:GetTaskInfo(taskID, graphID)
  if info == nil then
    return
  end
  if info.state == TaskConsts.TASK_STATE_VISIABLE then
    if info.unConDataIDs ~= nil then
      local taskCfg = TaskInterface.GetTaskCfg(taskID)
      for idx, uncondID in pairs(info.unConDataIDs) do
        for i, v in pairs(taskCfg.acceptConIds) do
          if uncondID == v.id and v.classType == TaskConClassType.CON_LEVEL then
            local cond = TaskInterface.GetTaskConditionLevel(v.id)
            local FuncType = require("consts.mzm.gsp.guide.confbean.FunType")
            local GuideModule = require("Main.Guide.GuideModule")
            local res = GuideModule.Instance():CheckFunction(FuncType.ACTIVITY)
            if res == true then
              Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_ACTIVITY_CLICK, nil)
            else
              Toast(string.format(textRes.Task[161], cond.minLevel))
            end
            return
          end
        end
      end
    end
    return
  end
  local oldValue = taskInterface._taskLightRoundGraphIDs[graphID]
  if oldValue ~= nil then
    taskInterface._taskLightRoundGraphIDs[graphID] = nil
    self:RefreshLightRound()
  end
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.TASK_TRACE_ITEM_CLICK, {taskID, graphID})
end
local tableTaskTypeSortKey = {}
tableTaskTypeSortKey[TaskConsts.TASK_TYPE_ACTIVITY] = "2"
tableTaskTypeSortKey[TaskConsts.TASK_TYPE_DAILY] = "2"
tableTaskTypeSortKey[TaskConsts.TASK_TYPE_BRANCH] = "2"
tableTaskTypeSortKey[TaskConsts.TASK_TYPE_INSTANCE] = "2"
tableTaskTypeSortKey[TaskConsts.TASK_TYPE_TRIAL] = "2"
tableTaskTypeSortKey[TaskConsts.TASK_TYPE_MASTER] = "2"
tableTaskTypeSortKey[TaskConsts.TASK_TYPE_MENPAITIAOZHAN] = "2"
tableTaskTypeSortKey[TaskConsts.TASK_TYPE_NULL] = "2"
tableTaskTypeSortKey[TaskConsts.TASK_TYPE_NORMAL] = "2"
tableTaskTypeSortKey[TaskConsts.TASK_TYPE_ZHIYIN] = "1"
tableTaskTypeSortKey[TaskConsts.TASK_TYPE_FESTIVAL] = "2"
tableTaskTypeSortKey[TaskConsts.TASK_TYPE_FEISHENG] = "4"
tableTaskTypeSortKey[TaskConsts.TASK_TYPE_SURPRISE] = "2"
local tableTaskStateSortKey = {}
tableTaskStateSortKey[TaskConsts.TASK_STATE_VISIABLE] = "6"
tableTaskStateSortKey[TaskConsts.TASK_STATE_FINISH] = "6"
tableTaskStateSortKey[TaskConsts.TASK_STATE_ALREADY_ACCEPT] = "6"
tableTaskStateSortKey[TaskConsts.TASK_STATE_FAIL] = "4"
tableTaskStateSortKey[TaskConsts.TASK_STATE_CAN_ACCEPT] = "0"
tableTaskStateSortKey[TaskConsts.TASK_STATE_DELETE] = "0"
tableTaskStateSortKey[TaskConsts.TASK_STATE_UN_VISIABLE] = "0"
local late_timer_id = 0
def.method().RefreshTaskTrace = function(self)
  if late_timer_id ~= 0 then
    return
  end
  late_timer_id = GameUtil.AddGlobalLateTimer(0, true, function()
    late_timer_id = 0
    self:RefreshTaskTraceInner()
  end)
end
def.method().RefreshTaskTraceInner = function(self)
  if self:IsShow() == false then
    return
  end
  self._timerRefreshCount = 0
  local infos = taskInterface:GetTaskInfos()
  self:ClearLightRound()
  self._params = {}
  self:_Clear()
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp ~= nil and heroProp.level <= constant.TaskConsts.MAIN_TASK_UP__MAX_LEVEL then
    tableTaskTypeSortKey[TaskConsts.TASK_TYPE_MAIN] = "3"
  else
    tableTaskTypeSortKey[TaskConsts.TASK_TYPE_MAIN] = "2"
  end
  local dungeonModule = gmodule.moduleMgr:GetModule(ModuleId.DUNGEON)
  local dungeonState = dungeonModule.State
  for taskId, graphIdValue in pairs(infos) do
    for graphId, info in pairs(graphIdValue) do
      if info.state == TaskConsts.TASK_STATE_FINISH or info.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT or taskInterface._resetTask[graphId] and info.state == TaskConsts.TASK_STATE_CAN_ACCEPT then
        local graphCfg = TaskInterface.GetTaskGraphCfg(graphId)
        while true do
          if dungeonState ~= 0 and graphCfg.taskType ~= TaskConsts.TASK_TYPE_INSTANCE then
          else
            local strTime = ""
            if info.time > 1400000000 then
              strTime = tostring(info.time)
            else
              strTime = "1400000000"
            end
            local taskInfo = {}
            taskInfo.state = info.state
            taskInfo.graphId = graphId
            taskInfo.taskId = taskId
            taskInfo.conDatas = info.conDatas
            local sskey = tableTaskStateSortKey[info.state] or "0"
            local tskey = tableTaskTypeSortKey[graphCfg.taskType] or "0"
            taskInfo.sortKey = tonumber(tskey .. sskey .. strTime)
            table.insert(self._params, taskInfo)
            do break end
            elseif info.state == TaskConsts.TASK_STATE_VISIABLE and info.unConDataIDs ~= nil then
              local graphCfg = TaskInterface.GetTaskGraphCfg(graphId)
              while true do
                if dungeonState ~= 0 and graphCfg.taskType ~= TaskConsts.TASK_TYPE_INSTANCE then
                  break
                end
                local strTime = ""
                if info.time > 1400000000 then
                  strTime = tostring(info.time)
                else
                  strTime = "1400000000"
                end
                local taskInfo = {}
                taskInfo.state = info.state
                taskInfo.graphId = graphId
                taskInfo.taskId = taskId
                taskInfo.conDatas = info.conDatas
                taskInfo.unConDataIDs = info.unConDataIDs
                local sskey = tableTaskStateSortKey[info.state] or "0"
                local tskey = tableTaskTypeSortKey[graphCfg.taskType] or "0"
                taskInfo.sortKey = tonumber(tskey .. sskey .. strTime)
                table.insert(self._params, taskInfo)
                break
              end
            end
          end
        end
    end
  end
  local sortFn = function(l, r)
    return l.sortKey > r.sortKey
  end
  table.sort(self._params, sortFn)
  local hasImportantTask = false
  for k, v in pairs(self._params) do
    local graphCfg = TaskInterface.GetTaskGraphCfg(v.graphId)
    if state == TaskConsts.TASK_STATE_CAN_ACCEPT and graphCfg.notShowInAcceptableList == false then
      hasImportantTask = true
    end
    self:FillaItem(k, v.taskId, v.graphId, v.state, v.conDatas, v.unConDataIDs)
  end
  local isTimeLimit = taskInterface:isOwnTimeLimitGraph()
  if (self._timerRefreshCount > 0 or isTimeLimit) and (0 >= self._refreshTimerID or isTimeLimit) then
    self._refreshTimerID = GameUtil.AddGlobalTimer(1, true, MainUITaskTrace.onRefreshTimer)
  end
  self._Img_Task01:SetActive(hasImportantTask)
  if not hasImportantTask then
    self:RefreshTaskRedPoint()
  end
  self:Resize()
  self._scrollCom:ResetPosition()
end
def.static().onRefreshTimer = function()
  local self = instance
  self._refreshTimerID = -1
  self._timerRefreshCount = 0
  if self:IsShow() == true then
    for k, v in pairs(self._params) do
      if taskTargetByGraph:HasCustomGraphicTaskTarget(v.graphId) == true or taskInterface:isTimeLimitGraphId(v.graphId) then
        self:FillaItem(k, v.taskId, v.graphId, v.state, v.conDatas, v.unConDataIDs)
      end
    end
    if self._needResize == true then
      self._needResize = false
      self:Resize()
    end
  end
  local isTimeLimit = taskInterface:isOwnTimeLimitGraph()
  if (self._timerRefreshCount > 0 or isTimeLimit) and (self._refreshTimerID <= 0 or isTimeLimit) then
    self._refreshTimerID = GameUtil.AddGlobalTimer(1, true, MainUITaskTrace.onRefreshTimer)
  end
end
def.method("number", "=>", "userdata").GetTaskTraceUIItem = function(self, graphID)
  if self:IsShow() == false then
    return nil
  end
  for k, v in pairs(self._params) do
    if v.graphId == graphID then
      local TheTable = self._taskTraceTable
      local listItem = TheTable:FindDirect(string.format("Task_Img_%02d", k))
      return listItem
    end
  end
  return nil
end
def.method("number", "number", "number", "number", "table", "table").FillaItem = function(self, index, taskId, graphId, state, conDatas, unConDataIDs)
  local taskCfg = TaskInterface.GetTaskCfg(taskId)
  local graphCfg = TaskInterface.GetTaskGraphCfg(graphId)
  if taskCfg == nil then
    print("taskCfg == nil taskId = ", taskId)
  end
  if graphCfg == nil then
    print("graphCfg == nil graphId = ", graphId)
  end
  local awardKey = "key_" .. tostring(graphId) .. tostring(taskId)
  local awardShowCfg
  local record = DynamicData.GetRecord(CFG_PATH.DATA_TASK_AWARD_SHOW_CFG, awardKey)
  if record ~= nil then
    awardShowCfg = {}
    awardShowCfg.isShow = record:GetCharValue("isVisiable") ~= 0
    if awardShowCfg.isShow == true then
      awardShowCfg.awardKey = record:GetStringValue("awardKey")
      awardShowCfg.graphId = record:GetIntValue("graphId")
      awardShowCfg.taskId = record:GetIntValue("taskId")
      awardShowCfg.itemIDs = {}
      local rec2 = record:GetStructValue("awardItemIdsStruct")
      local count = rec2:GetVectorSize("awardItemIds")
      for i = 1, count do
        local rec3 = rec2:GetVectorValueByIdx("awardItemIds", i - 1)
        local itemID = rec3:GetIntValue("itemId")
        if itemID > 0 then
          table.insert(awardShowCfg.itemIDs, itemID)
        end
      end
    end
  end
  local dispName = taskCfg.taskName
  local dispTarget = taskCfg.taskTarget
  local team = false
  local battle = false
  local finish = false
  dispName = TaskInterface.WarpTaskTypeStrForTaskTrace(graphCfg.taskType, dispName)
  local TaskString = require("Main.task.TaskString")
  local taskString = TaskString.Instance()
  taskString:SetTargetTaskState(state)
  if state == TaskConsts.TASK_STATE_FINISH then
    finish = taskCfg.isShowFinish
    if taskCfg.taskFinishTarget ~= nil and taskCfg.taskFinishTarget ~= "" then
      taskString:SetTargetTaskCfg(taskCfg)
      taskString:SetConditionData(conDatas)
      dispTarget = string.gsub(taskCfg.taskFinishTarget, "%$%((.-)%)%$", TaskString.DoReplace)
    else
      local npcCfg = NPCInterface.GetNPCCfg(taskCfg.GetFinishTaskNPC())
      if npcCfg ~= nil then
        dispTarget = string.format(textRes.Task[11], npcCfg.npcName)
      end
    end
  elseif state == TaskConsts.TASK_STATE_VISIABLE and unConDataIDs ~= nil then
    dispTarget = ""
    for idx, uncondID in pairs(unConDataIDs) do
      for i, v in pairs(taskCfg.acceptConIds) do
        if uncondID == v.id and v.classType == TaskConClassType.CON_LEVEL then
          local cond = TaskInterface.GetTaskConditionLevel(v.id)
          dispTarget = dispTarget .. string.format(textRes.Task[160], cond.minLevel)
        end
      end
    end
  else
    taskString:SetTargetTaskCfg(taskCfg)
    taskString:SetConditionData(conDatas)
    if taskCfg.taskTarget ~= nil and taskCfg.taskTarget ~= "" then
      dispTarget = string.gsub(taskCfg.taskTarget, "%$%((.-)%)%$", TaskString.DoReplace)
    else
      dispTarget = taskString:GeneratTaskFinishTarget(taskCfg, ";")
    end
    local conditionID = taskCfg.FindFinishConditionID(TaskConClassType.CON_KILL_NPC)
    battle = conditionID > 0
  end
  if taskTargetByGraph:HasCustomGraphicTaskTarget(graphId) then
    local needResize = false
    dispTarget, needResize = taskTargetByGraph:GetTaskGraphicTaskTarget(taskId, graphId, dispTarget)
    self._needResize = self._needResize or needResize
    self._timerRefreshCount = self._timerRefreshCount + 1
  end
  local taskGraphCfg = TaskInterface.GetTaskGraphCfg(graphId)
  if taskGraphCfg ~= nil then
    local ringNum = taskInterface:GetTaskRing(graphId)
    if taskGraphCfg.hideSchedule == false and ringNum >= 0 then
      dispName = dispName .. " (" .. tostring(ringNum + 1) .. "/" .. tostring(taskGraphCfg.ringCount) .. ")"
    end
  end
  if awardShowCfg ~= nil and awardShowCfg.isShow == true and awardShowCfg.itemIDs[1] ~= nil then
    self:AddItem(dispName, dispTarget, index, awardShowCfg.itemIDs[1], team, battle, finish)
  else
    self:AddItem(dispName, dispTarget, index, 0, team, battle, finish)
  end
end
def.method("userdata", "number", "=>", "userdata").get_listItem = function(self, TheTable, index)
  local listItem = self._listItems[index]
  if not listItem then
    listItem = TheTable:FindDirect(string.format("Task_Img_%02d", index))
    if listItem then
      self._listItems[index] = listItem
    end
  end
  return listItem
end
def.method("string", "string", "number", "number", "boolean", "boolean", "boolean").AddItem = function(self, taskName, taskDesc, index, awardItem, team, battle, finish)
  local TheTable = self._taskTraceTable
  local listItem1 = self._listItem1
  local listItem = self:get_listItem(TheTable, index)
  local parent = TheTable
  if listItem ~= nil then
    listItem:SetActive(true)
  else
    local newListItem = Object.Instantiate(listItem1)
    self.m_container.m_msgHandler:Touch(newListItem)
    listItem = newListItem
    local Img_BgPrize = listItem:FindDirect("Img_BgPrize_01")
    Img_BgPrize:set_name(string.format("Img_BgPrize_%02d", index))
    listItem:set_name(string.format("Task_Img_%02d", index))
    listItem.parent = parent
    listItem:set_localScale(Vector.Vector3.one)
    listItem:set_localPosition(Vector.Vector3.zero)
    self._listItems[index] = listItem
  end
  local listItemChild = self._listItemsChild[index]
  if not listItemChild then
    listItemChild = {}
    self._listItemsChild[index] = listItemChild
  end
  local Group_LabelName, LabelTaskName, LabelTaskNameComp
  Group_LabelName = listItemChild.Group_LabelName
  LabelTaskName = listItemChild.LabelTaskName
  LabelTaskNameComp = listItemChild.LabelTaskNameComp
  if not Group_LabelName or not LabelTaskName or not LabelTaskNameComp then
    Group_LabelName = listItem:FindDirect("Group_LabelName")
    listItemChild.Group_LabelName = Group_LabelName
    LabelTaskName = Group_LabelName:FindDirect("Task_LabelName")
    listItemChild.LabelTaskName = LabelTaskName
    LabelTaskNameComp = LabelTaskName:GetComponent("UILabel")
    listItemChild.LabelTaskNameComp = LabelTaskNameComp
  end
  LabelTaskNameComp:set_text(taskName)
  LabelTaskName:SetActive(true)
  local LabelTaskDescribeComp = listItemChild.LabelTaskDescribeComp
  if not LabelTaskDescribeComp then
    local LabelTaskDescribe = listItem:FindDirect("Task_LabelDescribe")
    LabelTaskDescribeComp = LabelTaskDescribe:GetComponent("UILabel")
    listItemChild.LabelTaskDescribeComp = LabelTaskDescribeComp
  end
  LabelTaskDescribeComp:set_text(taskDesc)
  local ImgTaskFight = listItemChild.ImgTaskFight
  if not ImgTaskFight then
    ImgTaskFight = Group_LabelName:FindDirect("Task_ImgFight")
    listItemChild.ImgTaskFight = ImgTaskFight
  end
  ImgTaskFight:SetActive(finish ~= true and battle)
  local ImgTaskFinish = listItemChild.ImgTaskFinish
  if not ImgTaskFinish then
    ImgTaskFinish = Group_LabelName:FindDirect("Task_ImgFinish")
    listItemChild.ImgTaskFinish = ImgTaskFinish
  end
  ImgTaskFinish:SetActive(finish)
  local Img_BgPrize = listItemChild.Img_BgPrize
  if not Img_BgPrize then
    Img_BgPrize = listItem:FindDirect(string.format("Img_BgPrize_%02d", index))
    listItemChild.Img_BgPrize = Img_BgPrize
  end
  if awardItem > 0 then
    Img_BgPrize:SetActive(true)
    local itembase = ItemUtils.GetItemBase(awardItem)
    if itembase ~= nil then
      local uiTexture = listItemChild.uiTexture
      if not uiTexture then
        local Texture_Prize = Img_BgPrize:FindDirect("Texture_Prize")
        uiTexture = Texture_Prize:GetComponent("UITexture")
        listItemChild.uiTexture = uiTexture
      end
      GUIUtils.FillIcon(uiTexture, itembase.icon)
    else
      Img_BgPrize:SetActive(false)
    end
  else
    Img_BgPrize:SetActive(false)
  end
end
def.method()._Clear = function(self)
  local TheTable = self._taskTraceTable
  local count = TheTable:get_childCount()
  for i = 1, count do
    local listItem = self:get_listItem(TheTable, i)
    if listItem then
      listItem:SetActive(false)
    end
  end
end
def.method().ClearLightRound = function(self)
  if self._params == nil then
    return
  end
  local TaskTrace = self._TaskTrace
  local active = TaskTrace:get_activeInHierarchy()
  local TheTable = self._taskTraceTable
  local graphID = 20000020
  local count = TheTable:get_childCount()
  local effectName = MainUITaskTrace.TaskLightEffectName
  for i = 1, count do
    local listItem = self:get_listItem(TheTable, i)
    local info = self._params[i]
    GUIUtils.SetLightEffect(listItem, GUIUtils.Light.None)
    if not _G.IsNil(listItem) then
      local effectObj = listItem:FindDirect(effectName)
      if not _G.IsNil(effectObj) then
        Object.Destroy(effectObj)
      end
    end
  end
  self._taskTraceRoundLight = {}
end
def.method().RefreshLightRound = function(self)
  if self._params == nil then
    return
  end
  local graphIDs = {}
  for k, v in pairs(taskInterface._taskLightRoundGraphIDs) do
    graphIDs[v] = v
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp.level <= 10 then
    graphIDs[20000020] = 20000020
  end
  local TaskTrace = self._TaskTrace
  local active = TaskTrace:get_activeInHierarchy()
  local TheTable = self._taskTraceTable
  local count = TheTable:get_childCount()
  for i = 1, count do
    local listItem = TheTable:FindDirect(string.format("Task_Img_%02d", i))
    local info = self._params[i]
    local effectId = 0
    if info and info.graphId then
      effectId = taskInterface:getTaskLightRoundEffectId(info.graphId)
    end
    local effectName = MainUITaskTrace.TaskLightEffectName
    if active == true and info ~= nil and graphIDs[info.graphId] ~= nil then
      if self._taskTraceRoundLight[info.graphId] ~= true then
        local effectObj = listItem:FindDirect(effectName)
        if effectId and effectId > 0 then
          local effres = _G.GetEffectRes(effectId)
          if effres then
            if effectObj == nil then
              local widget = listItem:GetComponent("UIWidget")
              local w = widget:get_width()
              local h = widget:get_height()
              local xScale = w / 64
              local yScale = h / 64
              require("Fx.GUIFxMan").Instance():PlayAsChildLayerWithCallback(listItem, effres.path, effectName, 0, 0, xScale, yScale, -1, false, function()
              end)
            end
          else
            warn("!!!!!! taskLightRound effectCfg is Nil:", effectId)
          end
        else
          local effectObj = listItem:FindDirect(effectName)
          if not _G.IsNil(effectObj) then
            Object.Destroy(effectObj)
          end
          GUIUtils.SetLightEffect(listItem, GUIUtils.Light.Square)
        end
        self._taskTraceRoundLight[info.graphId] = true
      end
    else
      local effectObj = listItem:FindDirect(effectName)
      if not _G.IsNil(effectObj) then
        Object.Destroy(effectObj)
      end
      GUIUtils.SetLightEffect(listItem, GUIUtils.Light.None)
      if info ~= nil and info.graphId ~= nil then
        self._taskTraceRoundLight[info.graphId] = nil
      end
    end
  end
end
def.static("table", "table").OnTaskInfoChanged = function(p1, p2)
  instance:RefreshTaskTrace()
end
def.static("table", "table").OnEnterDungeon = function(p1, p2)
  instance:RefreshTaskTrace()
end
def.static("table", "table").OnLeaveDungeon = function(p1, p2)
  instance:RefreshTaskTrace()
end
def.static("table", "table").OnTaskRingChanged = function(p1, p2)
  local self = instance
  local graphId = p1[1]
  local curRing = p1[2]
  local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
  for k, v in pairs(self._params) do
    if v.graphId == graphId then
      local taskCfg = TaskInterface.GetTaskCfg(v.taskId)
      local graphCfg = TaskInterface.GetTaskGraphCfg(v.graphId)
      local dispName = taskCfg.taskName
      local index = k
      dispName = TaskInterface.WarpTaskTypeStrForTaskTrace(graphCfg.taskType, dispName)
      local taskGraphCfg = TaskInterface.GetTaskGraphCfg(v.graphId)
      if taskGraphCfg ~= nil then
        local ringNum = taskInterface:GetTaskRing(v.graphId)
        if taskGraphCfg.hideSchedule == false and ringNum >= 0 then
          dispName = dispName .. " (" .. tostring(ringNum + 1) .. "/" .. tostring(taskGraphCfg.ringCount) .. ")"
        end
      end
      local TheTable = self._taskTraceTable
      local listItem = TheTable:FindDirect(string.format("Task_Img_%02d", index))
      if listItem ~= nil then
        local Group_LabelName = listItem:FindDirect("Group_LabelName")
        local LabelTaskName = Group_LabelName:FindDirect("Task_LabelName")
        LabelTaskName:GetComponent("UILabel"):set_text(dispName)
        TheTable:GetComponent("UITable"):Reposition()
      end
    end
  end
  self:Resize()
end
def.static("table", "table").OnTaskUnAcceptCondChged = function(p1, p2)
  instance:RefreshTaskTrace()
end
def.static("table", "table").OnHeroLevelUp = function(p1, p2)
  local self = instance
  self:ClearLightRound()
  self:RefreshLightRound()
end
def.static("table", "table").OnApplyTaskTraceLight = function(p1, p2)
  local self = instance
  if p1 ~= nil and p1[1] ~= nil then
    local theGraphID = p1[1]
    taskInterface._taskLightRoundGraphIDs[theGraphID] = theGraphID
    self:RefreshLightRound()
  end
end
def.static("table", "table").OnNewSurpriseTaskChange = function(p1, p2)
  if instance and not _G.IsNil(instance.m_panel) then
    instance:RefreshTaskRedPoint()
  end
end
def.method().Resize = function(self)
  if self._delayRepositionCount > 0 then
    self._delayRepositionCount = MainUITaskTrace._DELAY_REPOSITION_COUNT
  elseif self._delayRepositionCount <= 0 then
    Timer:RegisterIrregularTimeListener(self.OnDelayReposition, self)
    self._delayRepositionCount = MainUITaskTrace._DELAY_REPOSITION_COUNT
  end
end
def.method("number").OnDelayReposition = function(self, dt)
  if self:IsShow() == false then
    self._delayRepositionCount = 0
    Timer:RemoveIrregularTimeListener(self.OnDelayReposition)
    return
  end
  local TheTable = self._taskTraceTable
  for k, v in pairs(self._params) do
    local listItem = TheTable:FindDirect(string.format("Task_Img_%02d", k))
    if listItem ~= nil then
    end
  end
  local theTable = TheTable:GetComponent("UITable")
  theTable:Reposition()
  self._delayRepositionCount = self._delayRepositionCount - 1
  if self._delayRepositionCount <= 0 then
    Timer:RemoveIrregularTimeListener(self.OnDelayReposition)
    self:RefreshLightRound()
  end
end
def.method("number")._ShowTaskAwardTip = function(self, idx)
  local param = self._params[idx]
  if param == nil then
    return
  end
  local taskID = param.taskId
  local graphID = param.graphId
  local Table = self._taskTraceTable
  local listItem1 = Table:FindDirect(string.format("Task_Img_%02d", idx))
  local Img_BgPrize = listItem1:FindDirect(string.format("Img_BgPrize_%02d", idx))
  local position = Img_BgPrize:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = Img_BgPrize:GetComponent("UISprite")
  local awardShowCfg = TaskInterface.GetTaskAwardCfg(graphID, taskID)
  local itemID = 0
  if awardShowCfg ~= nil and awardShowCfg.itemIDs[1] ~= nil then
    itemID = awardShowCfg.itemIDs[1]
  end
  ItemTipsMgr.Instance():ShowBasicTips(itemID, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, false)
end
def.method("userdata").MakeTaskItemShow = function(self, item)
  self._scrollCom:DragToMakeVisible(item.transform, 128)
end
def.method().RefreshTaskRedPoint = function(self)
  local SurpriseTaskMgr = require("Main.task.SurpriseTaskMgr")
  local surpriseRed = SurpriseTaskMgr.Instance():isOwnNewSurpriseGraph()
  if surpriseRed then
    self._Img_Task01:SetActive(true)
    return
  end
  self._Img_Task01:SetActive(false)
end
MainUITaskTrace.Commit()
return MainUITaskTrace
