local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local TaskNode = Lplus.Extend(TabNode, "TaskNode")
local ECGUIMan = require("GUI.ECGUIMan")
local Vector = require("Types.Vector")
local TaskInterface = require("Main.task.TaskInterface")
local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
local GUIUtils = require("GUI.GUIUtils")
local TaskTargetByGraph = require("Main.task.TaskTargetByGraph")
local taskTargetByGraph = TaskTargetByGraph.Instance()
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local TaskModule = Lplus.ForwardDeclare("TaskModule")
local def = TaskNode.define
local instance
def.field("table")._acceptedTaskInfoList = nil
def.field("table")._acceptableTaskInfoList = nil
def.field("boolean")._tabAccepted = false
def.field("boolean")._tabAcceptable = false
def.field("number")._selectedAcceptedTaskIndex = 0
def.field("number")._selectedAcceptableTaskIndex = 0
def.field("number")._selectedTaskItemID = 0
def.field("number")._selectedTaskFilterID = 0
def.field("table")._selectedTask = nil
def.field("table")._selectedGraphCfg = nil
def.field("number")._refreshTimerID = 0
def.field("boolean").isshowing = false
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
  local TaskMain = require("Main.task.ui.TaskMain")
  instance = base.nodes[TaskMain.NodeIds.Task]
end
def.override().OnShow = function(self)
  if self._tabAccepted == false and self._tabAcceptable == false then
    local Tap_Now = self.m_base.m_panel:FindDirect("Img_Bg0/Tap_Now")
    local Tap_Others = self.m_base.m_panel:FindDirect("Img_Bg0/Tap_Others")
    Tap_Others:GetComponent("UIToggle"):set_isChecked(false)
    Tap_Now:GetComponent("UIToggle"):set_isChecked(true)
    Tap_Others:SetActive(false)
    self._tabAccepted = Tap_Now:GetComponent("UIToggle"):get_isChecked()
    self._tabAcceptable = Tap_Others:GetComponent("UIToggle"):get_isChecked()
  end
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_InfoChanged, TaskNode.OnTaskInfoChanged)
  local Tap_Now = self.m_base.m_panel:FindDirect("Img_Bg0/Tap_Now")
  local Tap_Others = self.m_base.m_panel:FindDirect("Img_Bg0/Tap_Others")
  Tap_Now:SetActive(false)
  Tap_Others:SetActive(false)
  Tap_Now:GetComponent("UIToggle"):set_isChecked(self._tabAccepted)
  Tap_Others:GetComponent("UIToggle"):set_isChecked(self._tabAcceptable)
  self:RefreshList()
  warn("--------TaskNode OnShow-------")
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_InfoChanged, TaskNode.OnTaskInfoChanged)
  self.isshowing = false
end
def.method("=>", "boolean").isOpen = function(self)
  return true
end
def.method("=>", "boolean").isNotify = function(self)
  return false
end
def.override("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("-------TaskNode onClick:", id)
  local fnClick = {}
  fnClick.Tap_Now = TaskNode.OnTapClick
  fnClick.Tap_Others = TaskNode.OnTapClick
  fnClick.Btn_Deliver = TaskNode.OnBtnDeliverClick
  fnClick.Btn_GiveUp = TaskNode.OnBtnGiveUpClick
  fnClick.Btn_Get = TaskNode.OnBtnGetClick
  fnClick.Btn_RenXing = TaskNode.OnBtnRenXingClick
  local fn = fnClick[id]
  if fn ~= nil then
    fn(self)
  else
    local strs = string.split(id, "_")
    if strs[1] == "Task" and (strs[2] == "BgZhu" or strs[2] == "BgZhi" or strs[2] == "BgOther") then
      print("strs[3] = ", strs[3])
      local idx = tonumber(strs[3])
      if idx ~= nil then
        self:_SetSelected(idx)
      end
    elseif strs[1] == "Img" and strs[2] == "BgIcon" then
      local idx = tonumber(strs[3])
      if idx ~= nil then
        self:_ShowAwardTip(idx)
      end
    end
  end
end
def.static(TaskNode).OnTapClick = function(self)
  local Tap_Now = self.m_base.m_panel:FindDirect("Img_Bg0/Tap_Now")
  local Tap_Others = self.m_base.m_panel:FindDirect("Img_Bg0/Tap_Others")
  local tabAccepted = true
  local tabAcceptable = false
  if self._tabAccepted ~= tabAccepted or self._tabAcceptable ~= tabAcceptable then
    self._tabAccepted = tabAccepted
    self._tabAcceptable = tabAcceptable
    self:_FillList()
  end
end
def.static(TaskNode).OnBtnDeliverClick = function(self)
  if PlayerIsInFight() then
    Toast(string.format(textRes.Task[35]))
    do
      local self = instance
      local Img_Bg0 = self.m_base.m_panel:FindDirect("Img_Bg0")
      Img_Bg0:FindDirect("Btn_Deliver"):GetComponent("UIButton"):set_isEnabled(false)
      GameUtil.AddGlobalTimer(0.3, true, function()
        if self.m_base:IsShow() == true then
          self:_SetButtonEnable()
        end
      end)
      return
    end
  end
  local index = self._selectedAcceptedTaskIndex
  local taskInfo = self._acceptedTaskInfoList[index]
  if taskInfo == nil then
    return
  end
  if taskInfo.state == TaskConsts.TASK_STATE_VISIABLE then
    Toast(string.format(textRes.Task[37]))
    return
  end
  self.m_base:HideDlg()
  local taskID = taskInfo.cfg.taskID
  local graphID = taskInfo.graphId
  local taskDeliveryByGraph = require("Main.task.TaskDeliveryByGraph").Instance()
  local result = taskDeliveryByGraph:DeliveryByGraph(taskID, graphID)
  if result == true then
    Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_TaskFindPath, {taskID, graphID})
  end
end
def.static(TaskNode).OnBtnGiveUpClick = function(self)
  if PlayerIsInFight() then
    Toast(string.format(textRes.Task[35]))
    do
      local self = instance
      local Img_Bg0 = self.m_base.m_panel:FindDirect("Img_Bg0")
      Img_Bg0:FindDirect("Btn_GiveUp"):GetComponent("UIButton"):set_isEnabled(false)
      GameUtil.AddGlobalTimer(0.3, true, function()
        if self.m_base:IsShow() == true then
          self:_SetButtonEnable()
        end
      end)
      return
    end
  end
  local index = self._selectedAcceptedTaskIndex
  local taskInfo = self._acceptedTaskInfoList[index]
  if taskInfo == nil then
    return
  end
  local tag = {}
  tag.taskID = taskInfo.cfg.taskID
  tag.graphID = taskInfo.graphId
  local graphCfg = TaskInterface.GetTaskGraphCfg(tag.graphID)
  if graphCfg.canGiveUpTask ~= true then
    Toast(string.format(textRes.Task[36]))
    return
  end
  local giveupText = textRes.Task[20]
  if taskInfo.cfg.giveUpTip ~= nil and string.len(taskInfo.cfg.giveUpTip) ~= 0 then
    giveupText = taskInfo.cfg.giveUpTip
  elseif graphCfg.giveUpTaskConfirmTip ~= nil and string.len(graphCfg.giveUpTaskConfirmTip) ~= 0 then
    giveupText = graphCfg.giveUpTaskConfirmTip
  end
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(textRes.Task[15], giveupText, TaskNode.OnGiveUpConfirm, tag)
end
def.static("number", "table").OnGiveUpConfirm = function(id, tag)
  if id == 1 then
    if PlayerIsInFight() then
      Toast(string.format(textRes.Task[35]))
      return
    end
    local taskID = tag.taskID
    local graphID = tag.graphID
    require("Main.task.TaskGiveupOperationByGraph").Instance():GiveUpTask(taskID, graphID)
  end
end
def.static(TaskNode).OnBtnGetClick = function(self)
  if PlayerIsInFight() then
    Toast(string.format(textRes.Task[35]))
    do
      local self = instance
      local Img_Bg0 = self.m_base.m_panel:FindDirect("Img_Bg0")
      Img_Bg0:FindDirect("Btn_Get"):GetComponent("UIButton"):set_isEnabled(false)
      GameUtil.AddGlobalTimer(0.3, true, function()
        if self.m_base:IsShow() == true then
          self:_SetButtonEnable()
        end
      end)
      return
    end
  end
  local index = self._selectedAcceptableTaskIndex
  local taskInfo = self._acceptableTaskInfoList[index]
  if taskInfo == nil then
    return
  end
  local npcID = taskInfo.cfg.GetGiveTaskNPC()
  if npcID ~= nil and npcID ~= 0 then
    Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_GotoNPC, {
      npcID = npcID,
      useFlySword = taskInfo.cfg.useFlySword
    })
    self.m_base:HideDlg()
  end
end
def.static(TaskNode).OnBgIconClick = function(self)
end
def.static(TaskNode).OnBtnRenXingClick = function(self)
  if PlayerIsInFight() then
    Toast(string.format(textRes.Task[35]))
    do
      local self = instance
      local Img_Bg0 = self.m_base.m_panel:FindDirect("Img_Bg0")
      Img_Bg0:FindDirect("Btn_RenXing"):GetComponent("UIButton"):set_isEnabled(false)
      GameUtil.AddGlobalTimer(0.3, true, function()
        if self.m_base:IsShow() == true then
          self:_SetButtonEnable()
        end
      end)
      return
    end
  end
  TaskModule.OnDoRenXingYiXia()
end
def.method().RefreshList = function(self)
  local infos = TaskInterface.Instance():GetTaskInfos()
  self._acceptedTaskInfoList = {}
  self._acceptableTaskInfoList = {}
  local tableTaskTypeSortKey = {}
  tableTaskTypeSortKey[TaskConsts.TASK_TYPE_MAIN] = "1"
  tableTaskTypeSortKey[TaskConsts.TASK_TYPE_BRANCH] = "2"
  tableTaskTypeSortKey[TaskConsts.TASK_TYPE_DAILY] = "3"
  tableTaskTypeSortKey[TaskConsts.TASK_TYPE_ACTIVITY] = "4"
  tableTaskTypeSortKey[TaskConsts.TASK_TYPE_TRIAL] = "4"
  tableTaskTypeSortKey[TaskConsts.TASK_TYPE_MASTER] = "4"
  tableTaskTypeSortKey[TaskConsts.TASK_TYPE_INSTANCE] = "5"
  tableTaskTypeSortKey[TaskConsts.TASK_TYPE_NORMAL] = "6"
  local tableTaskStateSortKey = {}
  tableTaskStateSortKey[TaskConsts.TASK_STATE_FINISH] = "1"
  tableTaskStateSortKey[TaskConsts.TASK_STATE_CAN_ACCEPT] = "2"
  tableTaskStateSortKey[TaskConsts.TASK_STATE_ALREADY_ACCEPT] = "3"
  tableTaskStateSortKey[TaskConsts.TASK_STATE_FAIL] = "4"
  tableTaskStateSortKey[TaskConsts.TASK_STATE_VISIABLE] = "5"
  tableTaskStateSortKey[TaskConsts.TASK_STATE_DELETE] = "6"
  tableTaskStateSortKey[TaskConsts.TASK_STATE_UN_VISIABLE] = "6"
  local hasImportantTask = false
  for taskId, graphIdValue in pairs(infos) do
    local taskCfg = TaskInterface.GetTaskCfg(taskId)
    for graphId, info in pairs(graphIdValue) do
      local graphCfg = TaskInterface.GetTaskGraphCfg(graphId)
      if info.state == TaskConsts.TASK_STATE_CAN_ACCEPT and graphCfg.notShowInAcceptableList == false then
        local taskInfo = {}
        taskInfo.state = info.state
        taskInfo.graphId = graphId
        taskInfo.cfg = taskCfg
        taskInfo.graphCfg = graphCfg
        taskInfo.conDatas = info.conDatas
        taskInfo.textIdx = 3
        local sskey = tableTaskStateSortKey[info.state] or "0"
        local tskey = tableTaskTypeSortKey[graphCfg.taskType] or "0"
        taskInfo.sortKey = tonumber(tskey .. sskey)
        table.insert(self._acceptableTaskInfoList, taskInfo)
        hasImportantTask = true
      end
      if info.state == TaskConsts.TASK_STATE_FINISH then
        local taskInfo = {}
        taskInfo.state = info.state
        taskInfo.graphId = graphId
        taskInfo.cfg = taskCfg
        taskInfo.graphCfg = graphCfg
        taskInfo.conDatas = info.conDatas
        taskInfo.textIdx = 2
        local sskey = tableTaskStateSortKey[info.state] or "0"
        local tskey = tableTaskTypeSortKey[graphCfg.taskType] or "0"
        taskInfo.sortKey = tonumber(tskey .. sskey)
        table.insert(self._acceptedTaskInfoList, taskInfo)
      end
      if info.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT then
        local taskInfo = {}
        taskInfo.state = info.state
        taskInfo.graphId = graphId
        taskInfo.cfg = taskCfg
        taskInfo.graphCfg = graphCfg
        taskInfo.conDatas = info.conDatas
        taskInfo.textIdx = 6
        local sskey = tableTaskStateSortKey[info.state] or "0"
        local tskey = tableTaskTypeSortKey[graphCfg.taskType] or "0"
        taskInfo.sortKey = tonumber(tskey .. sskey)
        table.insert(self._acceptedTaskInfoList, taskInfo)
      end
      if info.state == TaskConsts.TASK_STATE_VISIABLE then
        local taskInfo = {}
        taskInfo.state = info.state
        taskInfo.graphId = graphId
        taskInfo.cfg = taskCfg
        taskInfo.graphCfg = graphCfg
        taskInfo.conDatas = info.conDatas
        taskInfo.unConDataIDs = info.unConDataIDs
        taskInfo.textIdx = 7
        local sskey = tableTaskStateSortKey[info.state] or "0"
        local tskey = tableTaskTypeSortKey[graphCfg.taskType] or "0"
        taskInfo.sortKey = tonumber(tskey .. sskey)
        table.insert(self._acceptedTaskInfoList, taskInfo)
      end
    end
  end
  local sortFn = function(l, r)
    return l.sortKey < r.sortKey
  end
  local Tap_Others = self.m_base.m_panel:FindDirect("Img_Bg0/Tap_Others")
  local Img_Red = Tap_Others:FindDirect("Img_Red")
  Img_Red:SetActive(hasImportantTask)
  table.sort(self._acceptableTaskInfoList, sortFn)
  table.sort(self._acceptedTaskInfoList, sortFn)
  self:_FillList()
end
def.method()._FillList = function(self)
  if self.m_base.m_panel == nil or self.m_base.m_panel.isnil then
    return
  end
  self:_Clear()
  local bIsChecked = self.m_base.m_panel:FindDirect("Img_Bg0/Tap_Now"):GetComponent("UIToggle"):get_isChecked()
  if bIsChecked then
    self:_FillAccepted()
  else
    self:_FillAcceptable()
  end
end
def.method()._FillAccepted = function(self)
  if self.m_base.m_panel == nil or self.m_base.m_panel.isnil then
    return
  end
  local TaskConClassType = require("consts.mzm.gsp.task.confbean.TaskConClassType")
  local selectedIdx = 1
  for idx, taskInfo in pairs(self._acceptedTaskInfoList) do
    local dispName = taskInfo.cfg.taskName
    if taskInfo.state == TaskConsts.TASK_STATE_VISIABLE and taskInfo.unConDataIDs ~= nil then
      for idx, uncondID in pairs(taskInfo.unConDataIDs) do
        for i, v in pairs(taskInfo.cfg.acceptConIds) do
          if uncondID == v.id and v.classType == TaskConClassType.CON_LEVEL then
            local cond = TaskInterface.GetTaskConditionLevel(v.id)
            dispName = dispName .. "\n" .. string.format(textRes.Task[160], cond.minLevel)
          end
        end
      end
    end
    self:_Additem(idx, dispName, taskInfo.graphCfg.taskType, taskInfo.state, taskInfo.graphCfg.isImportant)
  end
  if selectedIdx ~= 0 then
    self:_SetSelected(selectedIdx)
  end
end
def.method()._FillAcceptable = function(self)
  if self.m_base.m_panel == nil or self.m_base.m_panel.isnil then
    return
  end
  local selectedIdx = 1
  for idx, taskInfo in pairs(self._acceptableTaskInfoList) do
    self:_Additem(idx, taskInfo.cfg.taskName, taskInfo.graphCfg.taskType, taskInfo.state, taskInfo.graphCfg.isImportant)
  end
  if selectedIdx ~= 0 then
    self:_SetSelected(selectedIdx)
  end
end
def.method()._Clear = function(self)
  local Grid_TaskList = self.m_base.m_panel:FindDirect("Img_Bg0/Img_BgTaskList/Scroll View_TaskList/Grid_TaskList")
  local count = Grid_TaskList:get_childCount()
  for i = 1, count do
    local Task_ImgBg = Grid_TaskList:FindDirect(string.format("Task_ImgBg_%02d", i))
    Task_ImgBg:SetActive(false)
  end
  local Img_BgTask = self.m_base.m_panel:FindDirect("Img_Bg0/Img_BgTask")
  Img_BgTask:FindDirect("Img_TitleDiscribe/Label_Discribe"):GetComponent("UILabel"):set_text("")
  Img_BgTask:FindDirect("Img_TitleTarget/Label_Target"):GetComponent("UILabel"):set_text("")
  local Img_Bg0 = self.m_base.m_panel:FindDirect("Img_Bg0")
  Img_Bg0:FindDirect("Btn_Deliver"):SetActive(false)
  Img_Bg0:FindDirect("Btn_GiveUp"):SetActive(false)
  Img_Bg0:FindDirect("Btn_Get"):SetActive(false)
  Img_Bg0:FindDirect("Btn_RenXing"):SetActive(false)
end
def.method("number", "string", "number", "number", "boolean")._Additem = function(self, index, taskName, taskType, taskState, isImportant)
  local Grid_TaskList = self.m_base.m_panel:FindDirect("Img_Bg0/Img_BgTaskList/Scroll View_TaskList/Grid_TaskList")
  local count = Grid_TaskList:get_childCount()
  local Task_ImgBg = Grid_TaskList:FindDirect(string.format("Task_ImgBg_%02d", index))
  if Task_ImgBg ~= nil then
    Task_ImgBg:SetActive(true)
  else
    local Task_ImgBg1 = Grid_TaskList:FindDirect(string.format("Task_ImgBg_01"))
    Task_ImgBg = Object.Instantiate(Task_ImgBg1)
    local grid = Grid_TaskList:GetComponent("UIGrid")
    grid:AddChild(Task_ImgBg.transform)
    Task_ImgBg:set_name(string.format("Task_ImgBg_%02d", index))
    Task_ImgBg.parent = Task_ImgBg1.parent
    Task_ImgBg:set_localScale(Vector.Vector3.one)
    Task_ImgBg:FindDirect("Task_BgZhu_01"):set_name(string.format("Task_BgZhu_%02d", index))
    grid:Reposition()
    self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
  end
  local dispName = taskName
  dispName = TaskInterface.WarpTaskTypeStr(taskType, dispName)
  Task_ImgBg:FindDirect("Label_Name"):GetComponent("UILabel"):set_text(dispName)
  local Task_BgZhu = Task_ImgBg:FindDirect(string.format("Task_BgZhu_%02d", index))
  Task_BgZhu:FindDirect("Img_SelectZhu/Label_Name"):GetComponent("UILabel"):set_text(dispName)
  local mainLine = taskType == TaskConsts.TASK_TYPE_MAIN
  local brach = taskType == TaskConsts.TASK_TYPE_BRANCH
  local other = mainLine == false and brach == false
  Task_ImgBg:FindDirect("Group_Sign"):SetActive(false)
end
def.method("number")._SetSelected = function(self, index)
  local Grid_TaskList = self.m_base.m_panel:FindDirect("Img_Bg0/Img_BgTaskList/Scroll View_TaskList/Grid_TaskList")
  local count = Grid_TaskList:get_childCount()
  for i = 1, count do
    local Task_ImgBg = Grid_TaskList:FindDirect(string.format("Task_ImgBg_%02d", i))
    local Task_BgZhu = Task_ImgBg:FindDirect(string.format("Task_BgZhu_%02d", i))
    Task_BgZhu:FindDirect("Img_SelectZhu"):SetActive(i == index)
  end
  self:_OnTaskSelected(index)
end
def.method("number")._OnTaskSelected = function(self, index)
  local bIsChecked = self.m_base.m_panel:FindDirect("Img_Bg0/Tap_Now"):GetComponent("UIToggle"):get_isChecked()
  if bIsChecked then
    if index >= 1 and index <= table.maxn(self._acceptedTaskInfoList) then
      self:_OnSelectedAcceptedTask(index)
    end
  elseif index >= 1 and index <= table.maxn(self._acceptableTaskInfoList) then
    self:_OnSelectedAcceptableTask(index)
  end
end
def.method("number")._OnSelectedAcceptedTask = function(self, index)
  local taskInfo = self._acceptedTaskInfoList[index]
  self._selectedAcceptedTaskIndex = index
  self:_FillSelectedTask(taskInfo)
end
def.method("number")._OnSelectedAcceptableTask = function(self, index)
  local taskInfo = self._acceptableTaskInfoList[index]
  self._selectedAcceptableTaskIndex = index
  self:_FillSelectedTask(taskInfo)
end
def.method("table")._FillSelectedTask = function(self, taskInfo)
  local TaskConClassType = require("consts.mzm.gsp.task.confbean.TaskConClassType")
  self._selectedTask = taskInfo
  local dispTarget = taskInfo.cfg.taskTarget
  local taskInterface = TaskInterface.Instance()
  local TaskString = require("Main.task.TaskString")
  local taskString = TaskString.Instance()
  taskString:SetTargetTaskCfg(taskInfo.cfg)
  local dispDesc = string.gsub(taskInfo.cfg.taskDes, "%$%((.-)%)%$", TaskString.DoReplace)
  local Img_BgTask = self.m_base.m_panel:FindDirect("Img_Bg0/Img_BgTask")
  Img_BgTask:FindDirect("Img_TitleDiscribe/Label_Discribe"):GetComponent("UILabel"):set_text(dispDesc)
  taskString:SetConditionData(taskInfo.conDatas)
  taskString:SetTargetTaskState(taskInfo.state)
  if taskInfo.cfg.taskTarget ~= nil and taskInfo.cfg.taskTarget ~= "" then
    dispTarget = string.gsub(taskInfo.cfg.taskTarget, "%$%((.-)%)%$", TaskString.DoReplace)
  else
    dispTarget = taskString:GeneratTaskFinishTarget(taskInfo.cfg, ";")
  end
  if (taskInfo.state == TaskConsts.TASK_STATE_FINISH or taskInfo.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT) and taskTargetByGraph:HasCustomGraphicTaskTarget(taskInfo.graphId) then
    dispTarget = taskTargetByGraph:GetTaskGraphicTaskTarget(taskInfo.cfg.taskID, taskInfo.graphId, dispTarget)
  end
  Img_BgTask:FindDirect("Img_TitleTarget/Label_Target"):GetComponent("UILabel"):set_text(dispTarget)
  self._selectedGraphCfg = TaskInterface.GetTaskGraphCfg(taskInfo.graphId)
  local bIsChecked = self.m_base.m_panel:FindDirect("Img_Bg0/Tap_Now"):GetComponent("UIToggle"):get_isChecked()
  local Img_Bg0 = self.m_base.m_panel:FindDirect("Img_Bg0")
  if bIsChecked then
    Img_Bg0:FindDirect("Btn_Deliver"):SetActive(true)
    Img_Bg0:FindDirect("Btn_GiveUp"):SetActive(taskInfo.state ~= TaskConsts.TASK_STATE_VISIABLE)
    Img_Bg0:FindDirect("Btn_Get"):SetActive(false)
    Img_Bg0:FindDirect("Btn_RenXing"):SetActive(self._selectedGraphCfg.taskType == TaskConsts.TASK_TYPE_TRIAL)
  else
    Img_Bg0:FindDirect("Btn_Deliver"):SetActive(false)
    Img_Bg0:FindDirect("Btn_GiveUp"):SetActive(false)
    Img_Bg0:FindDirect("Btn_Get"):SetActive(true)
    Img_Bg0:FindDirect("Btn_RenXing"):SetActive(false)
  end
  local Group_Prize = Img_Bg0:FindDirect("Img_BgTask/Img_TitlePrize/Group_Prize")
  local awardShowCfg = TaskInterface.GetTaskAwardCfg(taskInfo.graphId, taskInfo.cfg.taskID)
  local itemNum = 0
  for i = 1, 5 do
    local Img_BgIcon = Group_Prize:FindDirect(string.format("Img_BgIcon_%d", i))
    local Texture_Icon = Img_BgIcon:FindDirect(string.format("Texture_Icon_%d", i))
    local uiTexture = Texture_Icon:GetComponent("UITexture")
    local itemID = 0
    if awardShowCfg ~= nil and awardShowCfg.itemIDs[i] ~= nil then
      itemID = awardShowCfg.itemIDs[i]
    end
    local takeItemBase = ItemUtils.GetItemBase2(itemID)
    if takeItemBase ~= nil then
      itemNum = itemNum + 1
      Img_BgIcon:SetActive(true)
      GUIUtils.FillIcon(uiTexture, takeItemBase.icon)
    else
      Img_BgIcon:SetActive(false)
    end
  end
  local Img_TitlePrize = Img_Bg0:FindDirect("Img_BgTask/Img_TitlePrize")
  Img_TitlePrize:SetActive(itemNum > 0)
end
def.method()._SetButtonEnable = function(self)
  local Img_Bg0 = self.m_base.m_panel:FindDirect("Img_Bg0")
  Img_Bg0:FindDirect("Btn_Deliver"):GetComponent("UIButton"):set_isEnabled(true)
  Img_Bg0:FindDirect("Btn_GiveUp"):GetComponent("UIButton"):set_isEnabled(true)
  Img_Bg0:FindDirect("Btn_Get"):GetComponent("UIButton"):set_isEnabled(true)
  Img_Bg0:FindDirect("Btn_RenXing"):GetComponent("UIButton"):set_isEnabled(true)
end
def.method("number")._ShowAwardTip = function(self, idx)
  if self._selectedTask == nil then
    return
  end
  local awardShowCfg = TaskInterface.GetTaskAwardCfg(self._selectedTask.graphId, self._selectedTask.cfg.taskID)
  local itemID = 0
  if awardShowCfg ~= nil and awardShowCfg.itemIDs[idx] ~= nil then
    itemID = awardShowCfg.itemIDs[idx]
  end
  local takeItemBase = ItemUtils.GetItemBase2(itemID)
  if takeItemBase ~= nil then
    local Group_Prize = self.m_base.m_panel:FindDirect("Img_Bg0/Img_BgTask/Img_TitlePrize/Group_Prize")
    local Img_BgIcon = Group_Prize:FindDirect(string.format("Img_BgIcon_%d", idx))
    local position = Img_BgIcon:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = Img_BgIcon:GetComponent("UISprite")
    ItemTipsMgr.Instance():ShowBasicTips(itemID, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, false)
  end
end
def.static().onRefreshTimer = function()
  local self = instance
  if self.m_base:IsShow() == true then
    local taskInfo = self._selectedTask
    self._refreshTimerID = -1
    if taskInfo.state == TaskConsts.TASK_STATE_FINISH or taskInfo.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT then
      self:_FillSelectedTask(taskInfo)
    end
  end
end
def.static("table", "table").OnTaskInfoChanged = function(p1, p2)
  if instance.m_base:IsShow() then
    instance:RefreshList()
  end
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  local self = instance
  local Img_Bg0 = self.m_base.m_panel:FindDirect("Img_Bg0")
  Img_Bg0:FindDirect("Btn_Deliver"):GetComponent("UIButton"):set_isEnabled(false)
  Img_Bg0:FindDirect("Btn_GiveUp"):GetComponent("UIButton"):set_isEnabled(false)
  Img_Bg0:FindDirect("Btn_Get"):GetComponent("UIButton"):set_isEnabled(false)
end
def.static("table", "table").OnLeaveFight = function(p1, p2)
  local self = instance
  if self._selectedTask ~= nil then
    local graphCfg = TaskInterface.GetTaskGraphCfg(instance._selectedTask.graphId)
    local Img_Bg0 = self.m_base.m_panel:FindDirect("Img_Bg0")
    Img_Bg0:FindDirect("Btn_Deliver"):GetComponent("UIButton"):set_isEnabled(true)
    Img_Bg0:FindDirect("Btn_GiveUp"):GetComponent("UIButton"):set_isEnabled(graphCfg.canGiveUpTask)
    Img_Bg0:FindDirect("Btn_Get"):GetComponent("UIButton"):set_isEnabled(true)
  end
end
return TaskNode.Commit()
