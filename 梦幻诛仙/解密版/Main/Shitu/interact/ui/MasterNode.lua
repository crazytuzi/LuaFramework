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
local MasterNode = Lplus.Extend(TabNode, "MasterNode")
local def = MasterNode.define
local instance
def.static("=>", MasterNode).Instance = function()
  if instance == nil then
    instance = MasterNode()
  end
  return instance
end
def.field("boolean")._bInited = false
def.const("number").MAX_PRENTICE_COUNT = 3
def.const("number").MAX_ACTIVE_AWARD_COUNT = 3
def.const("number").DEFAULT_SELECT_IDX = 1
def.field("number")._selectIndex = 0
def.field("table")._uiObjs = nil
def.field("table")._model = nil
def.field("table")._activeAwardInfo = nil
def.field("table")._activeAwardCfgs = nil
def.override().OnShow = function(self)
  self:InitUI()
  self:_HandleEventListeners(true)
  self._selectIndex = MasterNode.DEFAULT_SELECT_IDX
  self:_UpdateUI()
end
def.method().InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.NoneStudent = self.m_node:FindDirect("NoneStudent")
  self._uiObjs.Label_NoStudent = self._uiObjs.NoneStudent:FindDirect("Img_Talk/Label")
  self._uiObjs.HaveStudent = self.m_node:FindDirect("HaveStudent")
  self._uiObjs.Group_Prentice = self._uiObjs.HaveStudent:FindDirect("Tab")
  self._uiObjs.List_Prentice = self._uiObjs.Group_Prentice:FindDirect("List")
  self._uiObjs.uiListPrentice = self._uiObjs.List_Prentice:GetComponent("UIList")
  self._uiObjs.Group_Model = self._uiObjs.HaveStudent:FindDirect("Img_PlayerInfor")
  self._uiObjs.PrenticeModel = self._uiObjs.Group_Model:FindDirect("Model_Student")
  self._uiObjs.uiModel = self._uiObjs.PrenticeModel:GetComponent("UIModel")
  self._uiObjs.Img_Sex = self._uiObjs.Group_Model:FindDirect("Img_Sex")
  self._uiObjs.Img_Class = self._uiObjs.Group_Model:FindDirect("Img_Class")
  self._uiObjs.Label_Level = self._uiObjs.Group_Model:FindDirect("Label_Level")
  self._uiObjs.Label_Name = self._uiObjs.Group_Model:FindDirect("Label_Name")
  self._uiObjs.Group_Active = self._uiObjs.HaveStudent:FindDirect("Image_HuoYue")
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
  self._uiObjs.Group_Task = self._uiObjs.HaveStudent:FindDirect("Img_Task")
  self._uiObjs.NoneTask = self._uiObjs.Group_Task:FindDirect("NoneTask")
  self._uiObjs.Label_NoneTask = self._uiObjs.NoneTask:FindDirect("Img_Talk/Label")
  self._uiObjs.HaveTask = self._uiObjs.Group_Task:FindDirect("HaveTask")
  self._uiObjs.Btn_Publish = self._uiObjs.HaveTask:FindDirect("Btn_Publish")
  self._uiObjs.Label_Assign = self._uiObjs.Btn_Publish:FindDirect("Label")
  self._uiObjs.Btn_Refresh = self._uiObjs.HaveTask:FindDirect("Btn_Refresh")
  self._uiObjs.Label_Refresh = self._uiObjs.Btn_Refresh:FindDirect("Label")
  self._uiObjs.List_Task = self._uiObjs.HaveTask:FindDirect("Img_TaskBg/List")
  self._uiObjs.uiListTask = self._uiObjs.List_Task:GetComponent("UIList")
  self._uiObjs.Label_Tips = self._uiObjs.HaveTask:FindDirect("Label_Tips")
  self._bInited = true
end
def.method()._UpdateUI = function(self)
  if ShituData.Instance():GetNowApprenticeCount() > 0 then
    GUIUtils.SetActive(self._uiObjs.HaveStudent, true)
    GUIUtils.SetActive(self._uiObjs.NoneStudent, false)
    self:UpdatePrenticeList()
    self:SelectPrenticeByIndex(self._selectIndex)
  else
    GUIUtils.SetActive(self._uiObjs.HaveStudent, false)
    GUIUtils.SetActive(self._uiObjs.NoneStudent, true)
    GUIUtils.SetText(self._uiObjs.Label_NoStudent, textRes.Shitu.Interact.TASK_ASSIGN_NO_PRENTICE)
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
  self:ClearPrenticeList()
  self._selectIndex = 0
  self:DestoryModel()
  self:ClearTask()
  self._activeAwardInfo = nil
  self._activeAwardCfgs = nil
  self._uiObjs = nil
end
def.method().UpdatePrenticeList = function(self)
  self:ClearPrenticeList()
  self._uiObjs.uiListPrentice.itemCount = MasterNode.MAX_PRENTICE_COUNT
  self._uiObjs.uiListPrentice:Resize()
  self._uiObjs.uiListPrentice:Reposition()
  for i = 1, MasterNode.MAX_PRENTICE_COUNT do
    self:FillApprenticeInfo(i)
  end
end
def.method("number").FillApprenticeInfo = function(self, idx)
  local listItem = self._uiObjs.uiListPrentice.children[idx]
  if nil == listItem then
    warn("[ERROR][MasterNode:FillApprenticeInfo] listItem nil at index:", idx)
    return
  end
  local Img_HaveStudent = listItem:FindDirect("Img_HaveStudent")
  local Img_NoneStudent = listItem:FindDirect("Img_NoneStudent")
  local prenticeInfo = ShituData.Instance():GetApprenticeByIdx(idx)
  if prenticeInfo then
    GUIUtils.SetActive(Img_HaveStudent, true)
    GUIUtils.SetActive(Img_NoneStudent, false)
    local roleInfo = InteractData.Instance():GetPrenticeRoleInfo(prenticeInfo.roleId)
    if roleInfo then
      local Texture_Head = Img_HaveStudent:FindDirect("Texture_Head")
      _G.SetAvatarIcon(Texture_Head, roleInfo.avatarId)
      _G.SetAvatarFrameIcon(Img_HaveStudent, roleInfo.avatarFrameId)
      local Img_RedPoi = Img_HaveStudent:FindDirect("Img_RedPoi")
      local taskData = InteractData.Instance():GetMasterTaskInfo(prenticeInfo.roleId)
      GUIUtils.SetActive(Img_RedPoi, taskData and taskData:NeedReddot() or false)
    else
      warn("[ERROR][MasterNode:FillApprenticeInfo] roleInfo nil for roleid:", Int64.tostring(prenticeInfo.roleId))
    end
  else
    GUIUtils.SetActive(Img_HaveStudent, false)
    GUIUtils.SetActive(Img_NoneStudent, true)
  end
end
def.method("number").SelectPrenticeByIndex = function(self, index)
  if index > ShituData.Instance():GetNowApprenticeCount() then
    index = ShituData.Instance():GetNowApprenticeCount()
  end
  self._selectIndex = index
  local prenticeInfo = ShituData.Instance():GetApprenticeByIdx(index)
  if prenticeInfo then
    local listItem = self._uiObjs.uiListPrentice.children[index]
    local Img_HaveStudent = listItem and listItem:FindDirect("Img_HaveStudent")
    GUIUtils.Toggle(Img_HaveStudent, true)
    self:UpdateModel(prenticeInfo.roleId)
    self:UpdateTask(prenticeInfo.roleId)
    self:UpdateActive(prenticeInfo.roleId)
  else
    GUIUtils.SetActive(self._uiObjs.Group_Task, false)
    GUIUtils.SetActive(self._uiObjs.Group_Active, false)
    GUIUtils.SetActive(self._uiObjs.Group_Model, false)
  end
end
def.method().ClearPrenticeList = function(self)
  if self._uiObjs and self._uiObjs.uiListPrentice then
    self._uiObjs.uiListPrentice.itemCount = 0
    self._uiObjs.uiListPrentice:Resize()
    self._uiObjs.uiListPrentice:Reposition()
  end
end
def.method("userdata").UpdateModel = function(self, roleId)
  self:DestoryModel()
  local roleInfo = InteractData.Instance():GetPrenticeRoleInfo(roleId)
  if roleInfo then
    GUIUtils.SetActive(self._uiObjs.Group_Model, true)
    self._model = InteractUtils.ShowRoleInfo(self._uiObjs, roleInfo)
  else
    GUIUtils.SetActive(self._uiObjs.Group_Model, false)
  end
end
def.method().DestoryModel = function(self)
  if self._uiObjs and self._uiObjs.uiModel then
    self._uiObjs.uiModel.modelGameObject = nil
  end
  if self._model then
    self._model:Destroy()
    self._model = nil
  end
end
def.method("userdata").UpdateTask = function(self, roleId)
  self:ClearTask()
  local masterTaskInfo = InteractData.Instance():GetMasterTaskInfo(roleId)
  if masterTaskInfo then
    local ShiTuTaskInfo = require("netio.protocol.mzm.gsp.shitu.ShiTuTaskInfo")
    local taskState = masterTaskInfo:GetAssignState()
    warn("[MasterNode:UpdateTask] prentice taskState:", taskState)
    if taskState == ShiTuTaskInfo.RECEIVE_MAX_LEVEL then
      GUIUtils.SetActive(self._uiObjs.NoneTask, true)
      GUIUtils.SetActive(self._uiObjs.HaveTask, false)
      local toastStr = string.format(textRes.Shitu.Interact.TASK_FETCH_MAX_LEVEL, constant.CShiTuTaskConsts.RECEIVE_MAX_LEVEL)
      GUIUtils.SetText(self._uiObjs.Label_NoneTask, toastStr)
    elseif taskState == ShiTuTaskInfo.RECEIVE_MAX_TIMES then
      GUIUtils.SetActive(self._uiObjs.NoneTask, true)
      GUIUtils.SetActive(self._uiObjs.HaveTask, false)
      local toastStr = string.format(textRes.Shitu.Interact.TASK_FETCH_FULL, constant.CShiTuTaskConsts.RECEIVE_MAX_TIMES)
      GUIUtils.SetText(self._uiObjs.Label_NoneTask, toastStr)
    elseif taskState == ShiTuTaskInfo.LEAVE_MASTER_TODAY then
      GUIUtils.SetActive(self._uiObjs.NoneTask, true)
      GUIUtils.SetActive(self._uiObjs.HaveTask, false)
      GUIUtils.SetText(self._uiObjs.Label_NoneTask, textRes.Shitu.Interact.TASK_ASSIGN_FAIL_ASSIGNED)
    elseif taskState == ShiTuTaskInfo.CHU_SHI then
      GUIUtils.SetActive(self._uiObjs.NoneTask, true)
      GUIUtils.SetActive(self._uiObjs.HaveTask, false)
      GUIUtils.SetText(self._uiObjs.Label_NoneTask, textRes.Shitu.Interact.TASK_ASSIGN_FAIL_CHUSHI)
    elseif taskState == ShiTuTaskInfo.MAX_PUBLISH_TIMES then
      GUIUtils.SetActive(self._uiObjs.NoneTask, true)
      GUIUtils.SetActive(self._uiObjs.HaveTask, false)
      local toastStr = string.format(textRes.Shitu.Interact.TASK_ASSIGN_FAIL_MAX, constant.CShiTuTaskConsts.DAILY_MAX_PUBLISH_TIMES)
      GUIUtils.SetText(self._uiObjs.Label_NoneTask, toastStr)
    else
      GUIUtils.SetActive(self._uiObjs.NoneTask, false)
      GUIUtils.SetActive(self._uiObjs.HaveTask, true)
      local taskInfos = masterTaskInfo:GetTaskInfos()
      InteractUtils.ShowTaskList(self._uiObjs, taskInfos, taskState ~= ShiTuTaskInfo.NO_PUBLISHED, MasterNode.SetStatusBtn)
      local totalTaskStr = string.format(textRes.Shitu.Interact.TASK_TOTAL_COUNT, masterTaskInfo:GetTotalFinishCount(), constant.CShiTuTaskConsts.RECEIVE_MAX_TIMES)
      GUIUtils.SetText(self._uiObjs.Label_Tips, totalTaskStr)
      if taskState == ShiTuTaskInfo.NO_PUBLISHED then
        GUIUtils.EnableButton(self._uiObjs.Btn_Publish, true)
        GUIUtils.SetText(self._uiObjs.Label_Assign, textRes.Shitu.Interact.TASK_ASSIGN_NOT_ASSIGNED)
        GUIUtils.SetActive(self._uiObjs.Btn_Refresh, true)
        local leftRefreshCount = math.max(constant.CShiTuTaskConsts.DAILY_MAX_REFRESH_TIMES - masterTaskInfo:GetRefreshCount())
        local refreshTaskStr = string.format(textRes.Shitu.Interact.TASK_RFRESH_COUNT, leftRefreshCount, constant.CShiTuTaskConsts.DAILY_MAX_REFRESH_TIMES)
        GUIUtils.SetText(self._uiObjs.Label_Refresh, refreshTaskStr)
      else
        GUIUtils.EnableButton(self._uiObjs.Btn_Publish, false)
        GUIUtils.SetText(self._uiObjs.Label_Assign, textRes.Shitu.Interact.TASK_ASSIGN_ASSIGNED)
        GUIUtils.SetActive(self._uiObjs.Btn_Refresh, false)
      end
    end
  else
    warn("[ERROR][MasterNode:UpdateTask] masterTaskInfo nil for prentice:", Int64.tostring(roleId))
    GUIUtils.SetActive(self._uiObjs.NoneTask, true)
    GUIUtils.SetActive(self._uiObjs.HaveTask, false)
    GUIUtils.SetText(self._uiObjs.Label_NoneTask, textRes.Shitu.Interact.TASK_ASSIGN_FAIL_NO_INFO)
  end
end
def.static("number", "userdata", "boolean").SetStatusBtn = function(taskState, groupBtn, bAssigned)
  local NOT_ASSIGN_STATE = -1
  if not bAssigned then
    taskState = NOT_ASSIGN_STATE
  end
  local status2Btn = {}
  status2Btn[NOT_ASSIGN_STATE] = groupBtn:FindDirect("Btn_NotPublish")
  status2Btn[ShiTuTask.UN_ACCEPTED] = groupBtn:FindDirect("Btn_NotAcieve")
  status2Btn[ShiTuTask.ALREADY_ACCEPTED] = groupBtn:FindDirect("Btn_NotAcieve")
  status2Btn[ShiTuTask.GIVE_UP] = groupBtn:FindDirect("Btn_NotAcieve")
  status2Btn[ShiTuTask.FINISHED] = groupBtn:FindDirect("Btn_Get")
  status2Btn[ShiTuTask.MASTER_REWARDED] = groupBtn:FindDirect("Btn_Got")
  status2Btn[ShiTuTask.GIVE_UP] = groupBtn:FindDirect("Btn_Abandon")
  for status, btn in pairs(status2Btn) do
    GUIUtils.SetActive(btn, false)
  end
  GUIUtils.SetActive(status2Btn[taskState], true)
end
def.method().ClearTask = function(self)
  self._uiObjs.uiListTask.itemCount = 0
  self._uiObjs.uiListTask:Resize()
  self._uiObjs.uiListTask:Reposition()
end
def.method("userdata").UpdateActive = function(self, roleId)
  if not InteractMgr.Instance():IsFeatrueActiveOpen(false) then
    GUIUtils.SetActive(self._uiObjs.Group_Slider, false)
    GUIUtils.SetActive(self._uiObjs.Label_NoReward, false)
    return
  end
  self._activeAwardInfo = InteractData.Instance():GetActiveAwardInfo(roleId)
  self._activeAwardCfgs = InteractUtils.ShowActiveInfo(self._activeAwardInfo, self._uiObjs)
end
def.override("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Infor" then
    self:OnBtn_Help(id)
  elseif id == "Img_HaveStudent" then
    self:OnBtn_SelectPrentice(clickObj)
  elseif id == "Img_NoneStudent" then
    self:OnBtn_AddPrentice(id)
  elseif id == "Btn_Publish" then
    self:OnBtn_Publish(id)
  elseif id == "Btn_Refresh" then
    self:OnBtn_Refresh(id)
  elseif id == "Btn_Get" then
    self:OnBtn_TaskAward(clickObj)
  elseif string.find(id, "Texture_item_") then
    self:OnBtn_ActiveAward(clickObj)
  end
end
def.method("string").OnBtn_Help = function(self, id)
  GUIUtils.ShowHoverTip(constant.CShiTuTaskConsts.TIP_ID_MASTER, 0, 0)
end
def.method("userdata").OnBtn_SelectPrentice = function(self, clickObj)
  local parent = clickObj and clickObj.parent
  if parent then
    local togglePrefix = "item_"
    local id = parent.name
    local index = tonumber(string.sub(id, string.len(togglePrefix) + 1))
    self:SelectPrenticeByIndex(index)
  end
end
def.method("string").OnBtn_AddPrentice = function(self, id)
  local PersonalInfoInterface = require("Main.PersonalInfo.PersonalInfoInterface")
  local PersonalInfoPanel = require("Main.PersonalInfo.ui.PersonalInfoPanel")
  local SocialPlatformMgr = require("Main.PersonalInfo.mgr.SocialPlatformMgr")
  SocialPlatformMgr.Instance():SetOpenAdvertType(constant.CShiTuTaskConsts.SHOUTU_TAB_ID)
  PersonalInfoPanel.Instance():SetStartTabNodeId(PersonalInfoPanel.NodeId.SOCIAL_PLATFORM)
  PersonalInfoInterface.Instance():CheckPersonalInfo(GetMyRoleID(), "")
end
def.method("string").OnBtn_Publish = function(self, id)
  local prenticeInfo = ShituData.Instance():GetApprenticeByIdx(self._selectIndex)
  if prenticeInfo then
    require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Shitu.Interact.TASK_ASSIGN_CONFRIM_TITLE, textRes.Shitu.Interact.TASK_ASSIGN_CONFRIM_CONTENT, function(id, tag)
      if id == 1 then
        InteractProtocols.SendCPublishShiTuTaskReq(prenticeInfo.roleId)
      end
    end, nil)
  else
    warn("[ERROR][MasterNode:OnBtn_Publish] prenticeInfo nil for self._selectIndex:", self._selectIndex)
  end
end
def.method("string").OnBtn_Refresh = function(self, id)
  local prenticeInfo = ShituData.Instance():GetApprenticeByIdx(self._selectIndex)
  if prenticeInfo then
    local masterTaskInfo = InteractData.Instance():GetMasterTaskInfo(prenticeInfo.roleId)
    if masterTaskInfo then
      if masterTaskInfo:GetRefreshCount() >= constant.CShiTuTaskConsts.DAILY_MAX_REFRESH_TIMES then
        Toast(textRes.Shitu.Interact.TASK_REFRESH_FAIL_NO_COUNT)
      else
        InteractProtocols.SendCRefreshShiTuTaskReq(prenticeInfo.roleId)
      end
    else
      warn("[ERROR][MasterNode:OnBtn_Refresh] masterTaskInfo nil for roleId:", Int64.tostring(prenticeInfo.roleId))
    end
  else
    warn("[ERROR][MasterNode:OnBtn_Refresh] prenticeInfo nil for self._selectIndex:", self._selectIndex)
  end
end
def.method("userdata").OnBtn_TaskAward = function(self, clickObj)
  local parent = clickObj and clickObj.parent
  parent = parent and parent.parent
  if parent then
    local togglePrefix = "item_"
    local id = parent.name
    local index = tonumber(string.sub(id, string.len(togglePrefix) + 1))
    local prenticeInfo = ShituData.Instance():GetApprenticeByIdx(self._selectIndex)
    if prenticeInfo then
      local masterTaskInfo = InteractData.Instance():GetMasterTaskInfo(prenticeInfo.roleId)
      if masterTaskInfo then
        local taskInfos = masterTaskInfo:GetTaskInfos()
        local taskInfo = taskInfos and taskInfos[index] or nil
        if taskInfo then
          InteractProtocols.SendCReceiveMasterTaskRewardReq(prenticeInfo.roleId, taskInfo.graphId, taskInfo.taskId)
        else
          warn("[ERROR][MasterNode:OnBtn_TaskAward] taskInfo nil for index:", index)
        end
      else
        warn("[ERROR][MasterNode:OnBtn_TaskAward] masterTaskInfo nil for roleId:", Int64.tostring(prenticeInfo.roleId))
      end
    else
      warn("[ERROR][MasterNode:OnBtn_TaskAward] prenticeInfo nil for self._selectIndex:", self._selectIndex)
    end
  end
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
    warn("[ERROR][MasterNode:OnBtn_ActiveAward] awardCfg nil at index:", index)
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
    eventFunc(ModuleId.SHITU, gmodule.notifyId.Shitu.SHITU_ROLE_INFO_CHANGE, MasterNode.OnRoleInfoChange)
    eventFunc(ModuleId.SHITU, gmodule.notifyId.Shitu.MASTER_TASK_INFO_CHANGE, MasterNode.OnTaskInfoChange)
    eventFunc(ModuleId.SHITU, gmodule.notifyId.Shitu.SHITU_ACTIVE_INFO_CHANGE, MasterNode.OnActiveInfoChange)
    eventFunc(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, MasterNode.OnHeroLevelUp)
    eventFunc(ModuleId.SHITU, gmodule.notifyId.Shitu.SHITU_RELATION_ADD_REMOVE, MasterNode.OnShituRelationChange)
  end
end
def.static("table", "table").OnRoleInfoChange = function(params, context)
  warn("[MasterNode:OnRoleInfoChange] update role list and model info.")
  local self = instance
  self:UpdatePrenticeList()
  local listItem = self._uiObjs.uiListPrentice.children[self._selectIndex]
  if listItem then
    local Img_HaveStudent = listItem and listItem:FindDirect("Img_HaveStudent")
    GUIUtils.Toggle(Img_HaveStudent, true)
  else
    warn("[ERROR][MasterNode:OnRoleInfoChange] listItem nil for self._selectIndex:", self._selectIndex)
  end
  local prenticeInfo = ShituData.Instance():GetApprenticeByIdx(self._selectIndex)
  if prenticeInfo then
    self:UpdateModel(prenticeInfo.roleId)
  else
    warn("[ERROR][MasterNode:OnRoleInfoChange] prenticeInfo nil for self._selectIndex:", self._selectIndex)
  end
end
def.static("table", "table").OnTaskInfoChange = function(params, context)
  warn("[MasterNode:OnTaskInfoChange] update reddot and task info.")
  local self = instance
  self:UpdatePrenticeList()
  local listItem = self._uiObjs.uiListPrentice.children[self._selectIndex]
  if listItem then
    local Img_HaveStudent = listItem and listItem:FindDirect("Img_HaveStudent")
    GUIUtils.Toggle(Img_HaveStudent, true)
  else
    warn("[ERROR][MasterNode:OnTaskInfoChange] listItem nil for self._selectIndex:", self._selectIndex)
  end
  local prenticeInfo = ShituData.Instance():GetApprenticeByIdx(self._selectIndex)
  if prenticeInfo then
    self:UpdateTask(prenticeInfo.roleId)
  else
    warn("[ERROR][MasterNode:OnTaskInfoChange] prenticeInfo nil for self._selectIndex:", self._selectIndex)
  end
end
def.static("table", "table").OnActiveInfoChange = function(params, context)
  warn("[MasterNode:OnActiveInfoChange] UpdateActive.")
  local self = instance
  local prenticeInfo = ShituData.Instance():GetApprenticeByIdx(self._selectIndex)
  if prenticeInfo then
    self:UpdateActive(prenticeInfo.roleId)
  else
    warn("[ERROR][MasterNode:OnActiveInfoChange] prenticeInfo nil for self._selectIndex:", self._selectIndex)
  end
end
def.static("table", "table").OnHeroLevelUp = function(params, context)
  warn("[MasterNode:OnHeroLevelUp] UpdateActive.")
  local self = instance
  local prenticeInfo = ShituData.Instance():GetApprenticeByIdx(self._selectIndex)
  if prenticeInfo then
    self:UpdateActive(prenticeInfo.roleId)
  else
    warn("[ERROR][MasterNode:OnHeroLevelUp] prenticeInfo nil for self._selectIndex:", self._selectIndex)
  end
end
def.static("table", "table").OnShituRelationChange = function(params, context)
  warn("[MasterNode:OnShituRelationChange] _UpdateUI.")
  local self = instance
  self:_UpdateUI()
end
return MasterNode.Commit()
