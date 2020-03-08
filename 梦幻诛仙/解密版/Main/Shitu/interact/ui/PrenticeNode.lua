local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TabNode = require("GUI.TabNode")
local GUIUtils = require("GUI.GUIUtils")
local GUIFxMan = require("Fx.GUIFxMan")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ShituData = require("Main.Shitu.ShituData")
local InteractData = require("Main.Shitu.interact.data.InteractData")
local TaskInterface = require("Main.task.TaskInterface")
local ShiTuTask = require("netio.protocol.mzm.gsp.shitu.ShiTuTask")
local InteractUtils = require("Main.Shitu.interact.InteractUtils")
local InteractProtocols = require("Main.Shitu.interact.InteractProtocols")
local InteractMgr = require("Main.Shitu.interact.InteractMgr")
local PrenticeNode = Lplus.Extend(TabNode, "PrenticeNode")
local def = PrenticeNode.define
local instance
def.static("=>", PrenticeNode).Instance = function()
  if instance == nil then
    instance = PrenticeNode()
  end
  return instance
end
def.field("boolean")._bInited = false
def.field("table")._uiObjs = nil
def.field("table")._model = nil
def.field("number")._taskSelectIdx = 0
def.field("table")._activeAwardInfo = nil
def.field("table")._activeAwardCfgs = nil
def.override().OnShow = function(self)
  self:InitUI()
  self:_HandleEventListeners(true)
  self:_UpdateUI()
end
def.method().InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.NoneMaster = self.m_node:FindDirect("NoneTeather")
  self._uiObjs.Label_NoMaster = self._uiObjs.NoneMaster:FindDirect("Img_Talk/Label")
  self._uiObjs.HaveMaster = self.m_node:FindDirect("HaveTeather")
  self._uiObjs.Group_Model = self._uiObjs.HaveMaster:FindDirect("Img_PlayerInfor")
  self._uiObjs.PrenticeModel = self._uiObjs.Group_Model:FindDirect("Model_Student")
  self._uiObjs.uiModel = self._uiObjs.PrenticeModel:GetComponent("UIModel")
  self._uiObjs.Img_Sex = self._uiObjs.Group_Model:FindDirect("Img_Sex")
  self._uiObjs.Img_Class = self._uiObjs.Group_Model:FindDirect("Img_Class")
  self._uiObjs.Label_Level = self._uiObjs.Group_Model:FindDirect("Label_Level")
  self._uiObjs.Label_Name = self._uiObjs.Group_Model:FindDirect("Label_Name")
  self._uiObjs.Group_Active = self._uiObjs.HaveMaster:FindDirect("Image_HuoYue")
  self._uiObjs.Group_Slider = self._uiObjs.Group_Active:FindDirect("Group_Slider")
  self._uiObjs.ActiveProgress = self._uiObjs.Group_Slider:FindDirect("Img_BgSlider")
  self._uiObjs.Group_Items = self._uiObjs.Group_Slider:FindDirect("Group_Items")
  self._uiObjs.Group_Values = self._uiObjs.Group_Slider:FindDirect("Group_Values")
  self._uiObjs.ActiveAwards = {}
  local InteractTaskPanel = require("Main.Shitu.interact.ui.InteractTaskPanel")
  for i = 1, InteractTaskPanel.MAX_ACTIVE_AWARD_COUNT do
    local listItem = {}
    listItem.awardItem = self._uiObjs.Group_Items:FindDirect("item_" .. i)
    listItem.activeValue = self._uiObjs.Group_Values:FindDirect("item_" .. i)
    table.insert(self._uiObjs.ActiveAwards, listItem)
  end
  self._uiObjs.Label_NoReward = self._uiObjs.Group_Active:FindDirect("Label_NoReward")
  self._uiObjs.Group_Task = self._uiObjs.HaveMaster:FindDirect("Img_Task")
  self._uiObjs.NoneTask = self._uiObjs.Group_Task:FindDirect("NoneTask")
  self._uiObjs.Label_NoneTask = self._uiObjs.NoneTask:FindDirect("Img_Talk/Label")
  self._uiObjs.Btn_Urge = self._uiObjs.NoneTask:FindDirect("Btn_Remind")
  self._uiObjs.Label_Urge = self._uiObjs.Btn_Urge:FindDirect("Label")
  self._uiObjs.HaveTask = self._uiObjs.Group_Task:FindDirect("HaveTask")
  self._uiObjs.Btn_Accept = self._uiObjs.HaveTask:FindDirect("Btn_Publish")
  self._uiObjs.Label_Accept = self._uiObjs.Btn_Accept:FindDirect("Label")
  self._uiObjs.List_Task = self._uiObjs.HaveTask:FindDirect("Img_TaskBg/List")
  self._uiObjs.uiListTask = self._uiObjs.List_Task:GetComponent("UIList")
  self._uiObjs.Label_Tips = self._uiObjs.HaveTask:FindDirect("Label_Tips")
  self._bInited = true
end
def.method()._UpdateUI = function(self)
  if ShituData.Instance():HasMaster() then
    GUIUtils.SetActive(self._uiObjs.HaveMaster, true)
    GUIUtils.SetActive(self._uiObjs.NoneMaster, false)
    self:UpdateModel()
    self:UpdateTask()
    self:UpdateActive()
  else
    GUIUtils.SetActive(self._uiObjs.HaveMaster, false)
    GUIUtils.SetActive(self._uiObjs.NoneMaster, true)
    GUIUtils.SetText(self._uiObjs.Label_NoMaster, textRes.Shitu.Interact.TASK_FETCH_NO_MASTER)
  end
end
def.override().OnHide = function(self)
  if self._bInited then
    self:_HandleEventListeners(false)
    self:Reset()
    self._bInited = false
  end
end
def.method().Reset = function(self)
  if self._uiObjs == nil or self._uiObjs.isnil then
    return
  end
  self:DestoryModel()
  self:ClearTask()
  self._taskSelectIdx = 0
  self._activeAwardInfo = nil
  self._activeAwardCfgs = nil
  self._uiObjs = nil
end
def.method().UpdateModel = function(self)
  self:DestoryModel()
  local roleInfo = InteractData.Instance():GetMasterRoleInfo()
  if roleInfo then
    GUIUtils.SetActive(self._uiObjs.Group_Model, true)
    self._model = InteractUtils.ShowRoleInfo(self._uiObjs, roleInfo)
  else
    GUIUtils.SetActive(self._uiObjs.Group_Model, false)
  end
end
def.method().DestoryModel = function(self)
  if self._model then
    self._model:Destroy()
    self._model = nil
  end
end
def.method().UpdateTask = function(self)
  self:ClearTask()
  local masterTaskInfo = InteractData.Instance():GetMasterTaskInfo(_G.GetMyRoleID())
  if masterTaskInfo then
    local ShiTuTaskInfo = require("netio.protocol.mzm.gsp.shitu.ShiTuTaskInfo")
    local taskState = masterTaskInfo:GetAssignState()
    warn("[PrenticeNode:UpdateTask] prentice taskState:", taskState)
    if taskState == ShiTuTaskInfo.RECEIVE_MAX_LEVEL then
      GUIUtils.SetActive(self._uiObjs.NoneTask, true)
      GUIUtils.SetActive(self._uiObjs.HaveTask, false)
      GUIUtils.SetActive(self._uiObjs.Btn_Urge, false)
      local labelStr = string.format(textRes.Shitu.Interact.TASK_FETCH_MAX_LEVEL, constant.CShiTuTaskConsts.RECEIVE_MAX_LEVEL)
      GUIUtils.SetText(self._uiObjs.Label_NoneTask, labelStr)
    elseif taskState == ShiTuTaskInfo.RECEIVE_MAX_TIMES then
      GUIUtils.SetActive(self._uiObjs.NoneTask, true)
      GUIUtils.SetActive(self._uiObjs.HaveTask, false)
      GUIUtils.SetActive(self._uiObjs.Btn_Urge, false)
      local labelStr = string.format(textRes.Shitu.Interact.TASK_FETCH_FULL, constant.CShiTuTaskConsts.RECEIVE_MAX_TIMES)
      GUIUtils.SetText(self._uiObjs.Label_NoneTask, labelStr)
    elseif taskState == ShiTuTaskInfo.LEAVE_MASTER_TODAY then
      GUIUtils.SetActive(self._uiObjs.NoneTask, true)
      GUIUtils.SetActive(self._uiObjs.HaveTask, false)
      GUIUtils.SetActive(self._uiObjs.Btn_Urge, false)
      GUIUtils.SetText(self._uiObjs.Label_NoneTask, textRes.Shitu.Interact.TASK_FETCH_FAIL_FETCHED)
    elseif taskState == ShiTuTaskInfo.CHU_SHI then
      GUIUtils.SetActive(self._uiObjs.NoneTask, true)
      GUIUtils.SetActive(self._uiObjs.HaveTask, false)
      GUIUtils.SetActive(self._uiObjs.Btn_Urge, false)
      GUIUtils.SetText(self._uiObjs.Label_NoneTask, textRes.Shitu.Interact.TASK_FETCH_FAIL_CHUSHI)
    elseif taskState == ShiTuTaskInfo.MAX_PUBLISH_TIMES then
      GUIUtils.SetActive(self._uiObjs.NoneTask, true)
      GUIUtils.SetActive(self._uiObjs.HaveTask, false)
      GUIUtils.SetActive(self._uiObjs.Btn_Urge, false)
      GUIUtils.SetText(self._uiObjs.Label_NoneTask, textRes.Shitu.Interact.TASK_FETCH_FAIL_ASSIGN_MAX)
    elseif taskState == ShiTuTaskInfo.YES_PUBLISHED or taskState == ShiTuTaskInfo.APPRENTICE_RECEIVED then
      GUIUtils.SetActive(self._uiObjs.NoneTask, false)
      GUIUtils.SetActive(self._uiObjs.HaveTask, true)
      GUIUtils.SetActive(self._uiObjs.Btn_Urge, false)
      local taskInfos = masterTaskInfo:GetTaskInfos()
      InteractUtils.ShowTaskList(self._uiObjs, taskInfos, true, PrenticeNode.SetStatusBtn)
      self:SelectTaskByIdx(self:GetDefaultSelectIdx())
      local totalTaskStr = string.format(textRes.Shitu.Interact.TASK_TOTAL_COUNT, masterTaskInfo:GetTotalFinishCount(), constant.CShiTuTaskConsts.RECEIVE_MAX_TIMES)
      GUIUtils.SetText(self._uiObjs.Label_Tips, totalTaskStr)
    else
      GUIUtils.SetActive(self._uiObjs.NoneTask, true)
      GUIUtils.SetActive(self._uiObjs.HaveTask, false)
      GUIUtils.SetActive(self._uiObjs.Btn_Urge, true)
      GUIUtils.SetText(self._uiObjs.Label_NoneTask, textRes.Shitu.Interact.TASK_FETCH_NO_TASK)
    end
  else
    GUIUtils.SetActive(self._uiObjs.NoneTask, true)
    GUIUtils.SetActive(self._uiObjs.HaveTask, false)
    GUIUtils.SetActive(self._uiObjs.Btn_Urge, false)
    GUIUtils.SetText(self._uiObjs.Label_NoneTask, textRes.Shitu.Interact.TASK_FETCH_NO_DATA)
  end
end
def.static("number", "userdata", "boolean").SetStatusBtn = function(taskState, groupBtn, bAssigned)
  local status2Btn = {}
  status2Btn[ShiTuTask.UN_ACCEPTED] = groupBtn:FindDirect("Btn_NotAccpet")
  status2Btn[ShiTuTask.ALREADY_ACCEPTED] = groupBtn:FindDirect("Btn_NotAchieve")
  status2Btn[ShiTuTask.GIVE_UP] = groupBtn:FindDirect("Btn_Abandon")
  status2Btn[ShiTuTask.FINISHED] = groupBtn:FindDirect("Btn_Achieved")
  status2Btn[ShiTuTask.MASTER_REWARDED] = groupBtn:FindDirect("Btn_Achieved")
  for status, btn in pairs(status2Btn) do
    GUIUtils.SetActive(btn, false)
  end
  GUIUtils.SetActive(status2Btn[taskState], true)
end
def.method("number").SelectTaskByIdx = function(self, idx)
  self._taskSelectIdx = idx
  local listItem = self._uiObjs.uiListTask.children[idx]
  if listItem then
    GUIUtils.Toggle(listItem, true)
  else
    warn("[ERROR][PrenticeNode:SelectTaskByIdx] listItem nil at index:", idx)
  end
  local masterTaskInfo = InteractData.Instance():GetMasterTaskInfo(_G.GetMyRoleID())
  if masterTaskInfo then
    local ShiTuTaskInfo = require("netio.protocol.mzm.gsp.shitu.ShiTuTaskInfo")
    local taskInfo = masterTaskInfo:GetTaskInfoByIdx(idx)
    if taskInfo then
      GUIUtils.SetActive(self._uiObjs.Btn_Accept, true)
      local taskState = taskInfo.taskState
      if taskState ~= ShiTuTask.UN_ACCEPTED then
        GUIUtils.EnableButton(self._uiObjs.Btn_Accept, false)
        GUIUtils.SetText(self._uiObjs.Label_Accept, textRes.Shitu.Interact.TASK_FETCH_FETCHED)
      else
        GUIUtils.EnableButton(self._uiObjs.Btn_Accept, true)
        GUIUtils.SetText(self._uiObjs.Label_Accept, textRes.Shitu.Interact.TASK_FETCH_NOT_FETCHED)
      end
    else
      GUIUtils.SetActive(self._uiObjs.Btn_Accept, false)
    end
  else
    warn("[ERROR][PrenticeNode:SelectTaskByIdx] masterTaskInfo nil.")
  end
end
def.method("=>", "number").GetDefaultSelectIdx = function(self)
  local result = 0
  local masterTaskInfo = InteractData.Instance():GetMasterTaskInfo(_G.GetMyRoleID())
  local taskInfos = masterTaskInfo and masterTaskInfo:GetTaskInfos()
  if taskInfos and #taskInfos > 0 then
    for idx, info in ipairs(taskInfos) do
      if info.taskState == ShiTuTask.ALREADY_ACCEPTED then
        result = idx
        break
      elseif info.taskState == ShiTuTask.UN_ACCEPTED and result <= 0 then
        result = idx
      end
    end
    if result <= 0 then
      result = 1
    end
  end
  return result
end
def.method().ClearTask = function(self)
  self._uiObjs.uiListTask.itemCount = 0
  self._uiObjs.uiListTask:Resize()
  self._uiObjs.uiListTask:Reposition()
end
def.method().UpdateActive = function(self)
  if not InteractMgr.Instance():IsFeatrueActiveOpen(false) then
    GUIUtils.SetActive(self._uiObjs.Group_Slider, false)
    GUIUtils.SetActive(self._uiObjs.Label_NoReward, false)
    return
  end
  self._activeAwardInfo = InteractData.Instance():GetActiveAwardInfo(_G.GetMyRoleID())
  self._activeAwardCfgs = InteractUtils.ShowActiveInfo(self._activeAwardInfo, self._uiObjs)
end
def.override("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Infor" then
    self:OnBtn_Help(id)
  elseif id == "Btn_Remind" then
    self:OnBtn_Remind(id)
  elseif id == "Btn_Publish" then
    self:OnBtn_Accept(id)
  elseif string.find(id, "Texture_item_") then
    self:OnBtn_ActiveAward(clickObj)
  elseif string.find(id, "item_") then
    self:OnBtn_Task(id)
  elseif id == "Btn_NotAchieve" then
    self:OnBtn_DoTask(clickObj)
  end
end
def.method("string").OnBtn_Help = function(self, id)
  GUIUtils.ShowHoverTip(constant.CShiTuTaskConsts.TIP_ID_APPRENTICE, 0, 0)
end
def.method("string").OnBtn_Remind = function(self, id)
  local lastRemindTime = InteractData.Instance():GetLastRemindTime()
  local curTime = _G.GetServerTime()
  if curTime - lastRemindTime > constant.CShiTuTaskConsts.SUPERVISE_CD then
    local roleInfo = InteractData.Instance():GetMasterRoleInfo()
    if roleInfo then
      InteractData.Instance():SetLastRemindTime(curTime)
      InteractProtocols.SendPrivateMsg(roleInfo, textRes.Shitu.Interact.TASK_ASSIGN_REMIND)
      Toast(textRes.Shitu.Interact.TASK_ASSIGN_REMIND_SUCCESS)
    else
      warn("[ERROR][PrenticeNode:OnBtn_Remind] InteractData.Instance():GetMasterRoleInfo() nil.")
    end
  else
    Toast(textRes.Shitu.Interact.TASK_ASSIGN_REMIND_FAIL)
  end
end
def.method("string").OnBtn_Accept = function(self, id)
  local masterTaskInfo = InteractData.Instance():GetMasterTaskInfo(_G.GetMyRoleID())
  local taskInfos = masterTaskInfo and masterTaskInfo:GetTaskInfos()
  if taskInfos and #taskInfos > 0 then
    for idx, info in ipairs(taskInfos) do
      if idx ~= self._taskSelectIdx and info.taskState == ShiTuTask.ALREADY_ACCEPTED then
        Toast(textRes.Shitu.Interact.TASK_FETCH_FAIL_UNFINISHED)
        return
      end
    end
    local taskInfo = taskInfos[self._taskSelectIdx]
    if taskInfo then
      InteractProtocols.SendCReceiveShiTuTaskReq(taskInfo.graphId, taskInfo.taskId)
    else
      warn("[ERROR][PrenticeNode:OnBtn_Accept] taskInfo nil at index:", self._taskSelectIdx)
    end
  else
    warn("[ERROR][PrenticeNode:OnBtn_Accept] taskInfos nil or #taskInfos<=0.")
  end
end
def.method("string").OnBtn_Task = function(self, id)
  local togglePrefix = "item_"
  local index = tonumber(string.sub(id, string.len(togglePrefix) + 1))
  self:SelectTaskByIdx(index)
end
def.method("userdata").OnBtn_ActiveAward = function(self, clickObj)
  local togglePrefix = "Texture_item_"
  local id = clickObj.name
  local index = tonumber(string.sub(id, string.len(togglePrefix) + 1))
  local awardCfg = self._activeAwardCfgs and self._activeAwardCfgs[index]
  if awardCfg then
    if self._activeAwardInfo and self._activeAwardInfo:CanFetchAward(awardCfg.award_index) then
      InteractProtocols.SendCReceiveShiTuActiveRewardReq(self._activeAwardInfo:GetRoleId(), awardCfg.award_index)
    else
      ItemTipsMgr.Instance():ShowBasicTipsWithGO(awardCfg.award_item_id, clickObj, 0, false)
    end
  else
    warn("[ERROR][PrenticeNode:OnBtn_ActiveAward] awardCfg nil at index:", index)
  end
end
def.method("userdata").OnBtn_DoTask = function(self, clickObj)
  local listItem = clickObj and clickObj.parent
  listItem = listItem.parent
  if listItem then
    local togglePrefix = "item_"
    local id = listItem.name
    local idx = tonumber(string.sub(id, string.len(togglePrefix) + 1))
    local masterTaskInfo = InteractData.Instance():GetMasterTaskInfo(_G.GetMyRoleID())
    local taskInfo = masterTaskInfo and masterTaskInfo:GetTaskInfoByIdx(idx)
    if taskInfo and taskInfo.taskState == ShiTuTask.ALREADY_ACCEPTED then
      Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.TASK_TRACE_ITEM_CLICK, {
        taskInfo.taskId,
        taskInfo.graphId
      })
      local InteractTaskPanel = require("Main.Shitu.interact.ui.InteractTaskPanel")
      if InteractTaskPanel.Instance():IsShow() then
        InteractTaskPanel.Instance():DestroyPanel()
      end
      local SocialDlg = require("Main.friend.ui.SocialDlg")
      if SocialDlg.Instance():IsShow() then
        SocialDlg.Instance():DestroyPanel()
      end
    end
  end
end
def.method("boolean")._HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
    eventFunc(ModuleId.SHITU, gmodule.notifyId.Shitu.SHITU_ROLE_INFO_CHANGE, PrenticeNode.OnRoleInfoChange)
    eventFunc(ModuleId.SHITU, gmodule.notifyId.Shitu.MASTER_TASK_INFO_CHANGE, PrenticeNode.OnTaskInfoChange)
    eventFunc(ModuleId.SHITU, gmodule.notifyId.Shitu.SHITU_ACTIVE_INFO_CHANGE, PrenticeNode.OnActiveInfoChange)
    eventFunc(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, PrenticeNode.OnHeroLevelUp)
    eventFunc(ModuleId.SHITU, gmodule.notifyId.Shitu.SHITU_RELATION_ADD_REMOVE, PrenticeNode.OnShituRelationChange)
  end
end
def.static("table", "table").OnRoleInfoChange = function(params, context)
  warn("[PrenticeNode:OnRoleInfoChange] UpdateModel.")
  local self = instance
  self:UpdateModel()
end
def.static("table", "table").OnTaskInfoChange = function(params, context)
  warn("[PrenticeNode:OnTaskInfoChange] UpdateTask.")
  local self = instance
  self:UpdateTask()
end
def.static("table", "table").OnActiveInfoChange = function(params, context)
  warn("[PrenticeNode:OnActiveInfoChange] UpdateActive.")
  local self = instance
  self:UpdateActive()
end
def.static("table", "table").OnHeroLevelUp = function(params, context)
  warn("[PrenticeNode:OnHeroLevelUp] UpdateActive.")
  local self = instance
  self:UpdateActive()
end
def.static("table", "table").OnRoleActiveChange = function(params, context)
  warn("[PrenticeNode:OnRoleActiveChange] UpdateActive.")
  local self = instance
  self:UpdateActive()
end
def.static("table", "table").OnShituRelationChange = function(params, context)
  warn("[PrenticeNode:OnShituRelationChange] _UpdateUI.")
  local self = instance
  self:_UpdateUI()
end
return PrenticeNode.Commit()
