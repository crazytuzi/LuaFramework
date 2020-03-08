local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BiYiLianZhiMainPanel = Lplus.Extend(ECPanelBase, "BiYiLianZhiMainPanel")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local Vector = require("Types.Vector")
local BiYiLianZhiUtils = require("Main.BiYiLianZhi.BiYiLianZhiUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemTips = require("Main.Item.ui.ItemTips")
local GUIUtils = require("GUI.GUIUtils")
local BiYiLianZhiData = require("Main.BiYiLianZhi.BiYiLianZhiData")
local def = BiYiLianZhiMainPanel.define
local instance
def.field("table")._tasks = nil
def.field("userdata")._taskList = nil
def.field("table")._taskMenu = nil
def.field("table")._taskData = nil
def.field("number")._currentSelectTaskIdx = 1
def.field("userdata")._currentTaskDescribe = nil
def.field("userdata")._btnAcceptTask = nil
def.field("table")._taskPosMap = nil
def.field("table")._awardIconMap = nil
def.field("userdata")._specialAwardIcon = nil
def.field("boolean")._isAllTaskComplete = false
def.static("=>", BiYiLianZhiMainPanel).Instance = function()
  if instance == nil then
    instance = BiYiLianZhiMainPanel()
    instance._taskMenu = {}
    instance._taskData = {}
    instance._taskPosMap = {}
    instance._awardIconMap = {}
  end
  return instance
end
def.method("table").ShowPlayPanel = function(self, tasks)
  if self:IsShow() then
    return
  end
  self._tasks = tasks
  self:CreatePanel(RESPATH.PREFAB_BIYIQIFEI_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:RefreshCurrentTask()
  self:ChooseNextUncompleteTask()
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, BiYiLianZhiMainPanel.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, BiYiLianZhiMainPanel.OnLeaveFight)
  if _G.PlayerIsInFight() then
    self:Show(false)
  end
end
def.method().InitUI = function(self)
  self._taskList = self.m_panel:FindDirect("Img_Bg0/TabScrollView/Tab_List")
  self._currentTaskDescribe = self.m_panel:FindDirect("Img_Bg0/Group_TaskI/Label_Discribe"):GetComponent("UILabel")
  self._btnAcceptTask = self.m_panel:FindDirect("Img_Bg0/Btn_Have")
  local awardGroud = self.m_panel:FindDirect("Img_Bg0/Group_TaskPrize/Group_Prize")
  local awardIcon1 = awardGroud:FindDirect("Img_BgIcon_1/Texture_Icon_1")
  local awardIcon2 = awardGroud:FindDirect("Img_BgIcon_2/Texture_Icon_2")
  local specialAwardIcon = self.m_panel:FindDirect("Img_Bg0/Img_BgSpecial/Img_BgIcon/Texture_Icon")
  local awardIconList = {
    awardIcon1,
    awardIcon2,
    specialAwardIcon
  }
  local awardItemIdList = {
    constant.CoupleDailyActivityConst.AWARD_ITEM_ID_1,
    constant.CoupleDailyActivityConst.AWARD_ITEM_ID_2,
    constant.CoupleDailyActivityConst.AWARD_ITEM_ID_3
  }
  for i = 1, #awardIconList do
    local uiTexture = awardIconList[i]:GetComponent("UITexture")
    local takeItemBase = ItemUtils.GetItemBase(awardItemIdList[i])
    if takeItemBase ~= nil then
      GUIUtils.FillIcon(uiTexture, takeItemBase.icon)
    end
    local awardItem = awardIconList[i].parent
    awardItem:set_name("Img_BgIcon_" .. awardItemIdList[i])
    self._awardIconMap[awardItemIdList[i]] = awardItem
  end
  self._specialAwardIcon = specialAwardIcon.parent
end
def.method().RefreshCurrentTask = function(self)
  local taskTab = self._taskList:GetComponent("UIGrid")
  local taskCountInTab = taskTab:GetChildListCount()
  local totalTaskCount = #self._tasks
  for i = 1, totalTaskCount do
    local taskId = self._tasks[i].id
    local status = self._tasks[i].status
    local taskData = BiYiLianZhiUtils.GetTaskDataById(taskId)
    self._taskData[i] = taskData
    local task = self._taskList:FindDirect(string.format("Task%d", i))
    self._taskMenu[i] = task
    local taskName = task:FindDirect("Label"):GetComponent("UILabel")
    taskName:set_text(taskData.taskName)
    task:FindDirect("Img_Finished"):SetActive(false)
    if status == true then
      task:FindDirect("Img_Finished"):SetActive(true)
    else
      task:FindDirect("Img_Finished"):SetActive(false)
    end
    self._taskPosMap[taskId] = i
  end
end
def.method().ChooseNextUncompleteTask = function(self)
  for i = 1, #self._tasks do
    if self._tasks[i].status == false then
      self:ChooseTask(i)
      return
    end
  end
  self:CompleteAllTasks()
end
def.method().CompleteAllTasks = function(self)
  self._btnAcceptTask:SetActive(false)
  self._isAllTaskComplete = true
  if not BiYiLianZhiData.Instance():IsReceivedAward() then
    GUIUtils.SetLightEffect(self._specialAwardIcon, GUIUtils.Light.Square)
  end
  self:ChooseTask(1)
end
def.method("number").ChooseTask = function(self, idx)
  self:SetTaskMenuSelected(self._currentSelectTaskIdx, false)
  self:SetTaskMenuSelected(idx, true)
  self._currentSelectTaskIdx = idx
  self:ShowCurrentTaskDetails()
end
def.method("number", "boolean").SetTaskMenuSelected = function(self, idx, isSelect)
  local taskMenu = self._taskMenu[idx]
  local toggle = taskMenu:GetComponent("UIToggle")
  toggle:set_value(isSelect)
end
def.method().ShowCurrentTaskDetails = function(self)
  local taskData = self._taskData[self._currentSelectTaskIdx]
  self._currentTaskDescribe:set_text(taskData.taskDesc)
  if BiYiLianZhiUtils.IsCoupleActivitySponsor() then
    self._btnAcceptTask:SetActive(not self._tasks[self._currentSelectTaskIdx].status)
  else
    self._btnAcceptTask:SetActive(false)
  end
end
def.method("=>", "boolean").IsExistPanel = function(self)
  return self.m_panel ~= nil and not self.m_panel.isnil
end
def.method("table").UpdateTask = function(self, tasks)
  self._tasks = tasks
  self:RefreshCurrentTask()
  self:ChooseNextUncompleteTask()
end
def.method().AccceptTask = function(self)
  if not BiYiLianZhiUtils.IsCanDoCoupleActivity() then
    Toast(textRes.BiYiLianZhi[1])
    return
  end
  if not BiYiLianZhiUtils.IsCoupleActivitySponsor() then
    Toast(textRes.BiYiLianZhi[12])
    return
  end
  local req = require("netio.protocol.mzm.gsp.coupledaily.CTakeCoupleDailyTask").new(self._currentSelectTaskIdx)
  gmodule.network.sendProtocol(req)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:Close()
  elseif id == "Btn_Have" then
    self:AccceptTask()
  elseif string.sub(id, 1, 11) == "Img_BgIcon_" then
    local itemId = tonumber(string.sub(id, 12))
    if id == self._specialAwardIcon.name and self._isAllTaskComplete and not BiYiLianZhiData.Instance():IsReceivedAward() then
      self:GetCoupleDailyAward()
    else
      self:ShowAwardTips(itemId)
    end
  end
end
def.method().GetCoupleDailyAward = function()
  if not BiYiLianZhiUtils.IsCoupleActivitySponsor() then
    Toast(textRes.BiYiLianZhi[12])
    return
  end
  local req = require("netio.protocol.mzm.gsp.coupledaily.CGetCoupleDailyAward").new()
  gmodule.network.sendProtocol(req)
end
def.method().OnReceiveAward = function(self)
  local light = self._specialAwardIcon:FindDirect("lighteffect")
  if light then
    self._specialAwardIcon:FindDirect("lighteffect"):Destroy()
  end
  BiYiLianZhiData.Instance():SetReceivedAward(true)
end
def.method("number").ShowAwardTips = function(self, itemId)
  local awardItem = self._awardIconMap[itemId]
  local position = awardItem:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = awardItem:GetComponent("UISprite")
  ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x - sprite:get_width() * 0.5, screenPos.y + sprite:get_height() * 0.5, sprite:get_width(), 1, 0, false)
end
def.method("string", "boolean").onToggle = function(self, id, active)
  if active == true and string.sub(id, 1, 4) == "Task" then
    local idx = tonumber(string.sub(id, 5))
    if idx ~= nil then
      self:ChooseTask(idx)
    end
  end
end
def.method().Close = function(self)
  if BiYiLianZhiUtils.IsCoupleActivitySponsor() then
    local req = require("netio.protocol.mzm.gsp.coupledaily.CCloseCoupleDailyPanel").new()
    gmodule.network.sendProtocol(req)
  end
  self:DestroyPanel()
end
def.override("boolean").OnShow = function(self, s)
  if s and _G.PlayerIsInFight() then
    self:Show(false)
  end
end
def.static("table", "table").OnEnterFight = function(param, tbl)
  instance:Show(false)
end
def.static("table", "table").OnLeaveFight = function(param, tbl)
  instance:Show(true)
end
def.override().OnDestroy = function(self)
  self._tasks = nil
  self._taskList = nil
  self._taskMenu = {}
  self._taskData = {}
  self._taskPosMap = {}
  self._currentSelectTaskIdx = 1
  self._currentTaskDescribe = nil
  self._awardIconMap = {}
  self._specialAwardIcon = nil
  self._isAllTaskComplete = false
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, BiYiLianZhiMainPanel.OnEnterFight)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, BiYiLianZhiMainPanel.OnLeaveFight)
end
BiYiLianZhiMainPanel.Commit()
return BiYiLianZhiMainPanel
