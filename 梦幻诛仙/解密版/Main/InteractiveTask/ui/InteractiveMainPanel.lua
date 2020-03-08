local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local InteractiveMainPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local InteractiveMainViewModel = require("Main.InteractiveTask.ui.InteractiveMainViewModel")
local InteractiveTaskModule = Lplus.ForwardDeclare("InteractiveTaskModule")
local def = InteractiveMainPanel.define
def.const("string").IMG_FINISH = "Img_Finish"
def.field("table").m_UIGOs = nil
def.field("table").m_viewModel = nil
def.field("table").m_tasks = nil
def.field("number").m_endTime = 0
local instance
def.static("=>", InteractiveMainPanel).Instance = function()
  if instance == nil then
    instance = InteractiveMainPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:UpdateUI()
  else
    self:SetModal(true)
    self:CreatePanel(RESPATH.PREFAB_CHILDREN_PREPARE_FOR_CHILDREN_BORN, 1)
  end
end
def.override().OnCreate = function(self)
  self.m_viewModel = InteractiveMainViewModel.Instance()
  if self.m_viewModel:IsInvalid() then
    self:DestroyPanel()
    return
  end
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.INTERACTIVE_TASK, gmodule.notifyId.InteractiveTask.TASK_STAUS_CHANGED, InteractiveMainPanel.OnTaskStatusChanged)
  Event.RegisterEvent(ModuleId.INTERACTIVE_TASK, gmodule.notifyId.InteractiveTask.LEAVE_TASK_MAP, InteractiveMainPanel.OnLeaveTaskMap)
  Event.RegisterEvent(ModuleId.INTERACTIVE_TASK, gmodule.notifyId.InteractiveTask.ALL_TASKS_FINISHED, InteractiveMainPanel.OnAllTaskFinished)
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self.m_panel:SetActive(true)
end
def.override().OnDestroy = function(self)
  self.m_UIGOs = nil
  self.m_viewModel = nil
  self.m_tasks = nil
  self.m_endTime = 0
  Event.UnregisterEvent(ModuleId.INTERACTIVE_TASK, gmodule.notifyId.InteractiveTask.TASK_STAUS_CHANGED, InteractiveMainPanel.OnTaskStatusChanged)
  Event.UnregisterEvent(ModuleId.INTERACTIVE_TASK, gmodule.notifyId.InteractiveTask.LEAVE_TASK_MAP, InteractiveMainPanel.OnLeaveTaskMap)
  Event.UnregisterEvent(ModuleId.INTERACTIVE_TASK, gmodule.notifyId.InteractiveTask.ALL_TASKS_FINISHED, InteractiveMainPanel.OnAllTaskFinished)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:OnClosePanel()
  elseif id == "Btn_GiveUp" then
    self:OnGiveGpBtnClick()
  elseif string.find(id, "Btn_Activity") then
    local index = tonumber(string.sub(id, #"Btn_Activity" + 1, -1))
    if index then
      self:OnClickTaskItem(index)
    end
  end
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.m_UIGOs.Label_Time = self.m_UIGOs.Img_Bg0:FindDirect("Label_Time")
  self.m_UIGOs["Scroll View_Item"] = self.m_UIGOs.Img_Bg0:FindDirect("Scroll View_Item")
  self.m_UIGOs.Grid_Bg = self.m_UIGOs["Scroll View_Item"]:FindDirect("Grid_Bg")
  self.m_UIGOs.Label_Title = self.m_UIGOs.Img_Bg0:FindDirect("Img_Title/Label_Title")
  self.m_UIGOs.Btn_GiveUp = self.m_UIGOs.Img_Bg0:FindDirect("Btn_GiveUp")
  self.m_UIGOs.Label_GiveUp = self.m_UIGOs.Img_Bg0:FindDirect("Btn_GiveUp/Label")
end
def.method().UpdateUI = function(self)
  local title = self.m_viewModel:GetTypeName()
  self:SetTitile(title)
  self:UpdateTaskPipeline()
  self.m_endTime = self.m_viewModel:GetTypeEndTime()
  self:UpdateCountDown()
  self:UpdateBtns()
end
def.method().UpdateTaskPipeline = function(self)
  self.m_tasks = self.m_viewModel and self.m_viewModel:GetAllTasks() or {}
  self:SetTaskPipeline(self.m_tasks)
end
def.method("table").SetTaskPipeline = function(self, tasks)
  GUIUtils.ResizeGrid(self.m_UIGOs.Grid_Bg, #tasks, "Btn_Activity")
  for i, v in ipairs(tasks) do
    local itemGO = self.m_UIGOs.Grid_Bg:GetChild(i)
    local task = tasks[i]
    self:SetTaskState(itemGO, task)
  end
end
def.method("userdata", "table").SetTaskState = function(self, itemGO, task)
  local Label_Activity = itemGO:FindDirect("Label_Activity")
  local Img_GP = itemGO:FindDirect("Img_GP")
  local Group_State = itemGO:FindDirect("Group_State")
  local Label_State = Group_State:FindDirect("Label_State")
  local Img_State = Group_State:FindDirect("Img_State")
  GUIUtils.SetText(Label_Activity, task.name)
  if task.state == "finished" then
    GUIUtils.SetActive(Label_State, false)
    GUIUtils.SetActive(Img_State, true)
    GUIUtils.SetSprite(Img_State, InteractiveMainPanel.IMG_FINISH, true)
  elseif task.state == "accepted" then
    GUIUtils.SetActive(Label_State, true)
    GUIUtils.SetActive(Img_State, false)
  else
    GUIUtils.SetActive(Label_State, false)
    GUIUtils.SetActive(Img_State, false)
  end
  GUIUtils.SetTexture(Img_GP, task.iconId)
end
def.method("string").SetTitile = function(self, title)
  GUIUtils.SetText(self.m_UIGOs.Label_Title, title)
end
def.method().OnClosePanel = function(self)
  self:DestroyPanel()
end
def.method().OnGiveGpBtnClick = function(self)
  if self:IsAllTasksFinished() then
    InteractiveTaskModule.Instance():AbortWorkedTask()
  else
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    local typeName = self.m_viewModel:GetTypeName()
    local content = string.format(textRes.InteractiveTask[9], typeName)
    CommonConfirmDlg.ShowConfirm("", content, function(s)
      if s == 1 then
        InteractiveTaskModule.Instance():AbortWorkedTask()
      end
    end, nil)
  end
end
def.method("number").OnClickTaskItem = function(self, index)
  local taskData = self.m_tasks[index]
  if taskData == nil then
    return
  end
  if taskData.state == "finished" then
    Toast(textRes.InteractiveTask[4])
    return
  end
  if taskData.state == "accepted" then
    Toast(textRes.InteractiveTask[5])
    return
  end
  local acceptedGraphId = self:GetAcceptedTaskGraphId(taskData.typeId)
  if acceptedGraphId ~= 0 then
    Toast(textRes.InteractiveTask[6])
    return
  end
  if not InteractiveTaskModule.Instance():IsTaskAcceptable(taskData.typeId, taskData.graphId) then
    Toast(textRes.InteractiveTask[7])
    return
  end
  InteractiveTaskModule.Instance():InviteStartTask(taskData.typeId, taskData.graphId)
  Toast(textRes.InteractiveTask[8])
end
def.method("number", "=>", "number").GetAcceptedTaskGraphId = function(self, typeId)
  return InteractiveTaskModule.Instance():GetAcceptedTaskGraphId(typeId)
end
def.method().UpdateCountDown = function(self)
  if self.m_panel == nil then
    return
  end
  local curTime = _G.GetServerTime()
  local leftTime = self.m_endTime - curTime
  if leftTime < 0 then
    leftTime = 0
  end
  local text = _G.SeondsToTimeText(leftTime)
  text = string.format(textRes.InteractiveTask[10], text)
  GUIUtils.SetText(self.m_UIGOs.Label_Time, text)
  GameUtil.AddGlobalTimer(1, true, function(...)
    self:UpdateCountDown()
  end)
end
def.method("=>", "boolean").IsAllTasksFinished = function(self)
  local typeId = self.m_viewModel:GetTypeId()
  return InteractiveTaskModule.Instance():IsAllTasksFinished(typeId)
end
def.method().UpdateBtns = function(self)
  if self:IsAllTasksFinished() then
    GUIUtils.SetActive(self.m_UIGOs.Btn_GiveUp, true)
    GUIUtils.SetText(self.m_UIGOs.Label_GiveUp, textRes.InteractiveTask[13])
  else
    GUIUtils.SetActive(self.m_UIGOs.Btn_GiveUp, false)
  end
end
def.static("table", "table").OnTaskStatusChanged = function(...)
  instance:UpdateTaskPipeline()
end
def.static("table", "table").OnLeaveTaskMap = function(...)
  instance:DestroyPanel()
end
def.static("table", "table").OnAllTaskFinished = function(...)
  instance:UpdateBtns()
end
return InteractiveMainPanel.Commit()
