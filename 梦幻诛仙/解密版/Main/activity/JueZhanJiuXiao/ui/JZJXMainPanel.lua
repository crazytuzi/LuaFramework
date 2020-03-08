local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local JZJXMainPanel = Lplus.Extend(ECPanelBase, CUR_CLASS_NAME)
local def = JZJXMainPanel.define
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local JZJXMgr = import("..JZJXMgr")
local JZJXUIMgr = import("..JZJXUIMgr")
local JZJXUtils = import("..JZJXUtils")
local ViewType = {CountDown = 1, Activity = 2}
def.field("table").uiObjs = nil
def.field("number").viewType = 0
def.field("number").countDownTimerId = 0
def.field("table").m_viewData = nil
local instance
def.static("=>", JZJXMainPanel).Instance = function()
  if instance == nil then
    instance = JZJXMainPanel()
  end
  return instance
end
def.method().ShowCountDown = function(self)
  self.viewType = ViewType.CountDown
  self:ShowPanel()
end
def.method().ShowActivity = function(self)
  self.viewType = ViewType.Activity
  self:ShowPanel()
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:UpdateUI()
    return
  end
  self:SetDepth(GUIDEPTH.BOTTOM)
  self:CreatePanel(RESPATH.PREFAB_JZJX_MAIN_PANEL, 0)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_JZJX_SyncLayerMapData, JZJXMainPanel.OnSyncLayerMapData)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, JZJXMainPanel.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, JZJXMainPanel.OnLeaveFight)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_JZJX_SyncLayerMapData, JZJXMainPanel.OnSyncLayerMapData)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, JZJXMainPanel.OnEnterFight)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, JZJXMainPanel.OnLeaveFight)
  self:Clear()
  local CommonActivityPanel = require("GUI.CommonActivityPanel")
  CommonActivityPanel.Instance():HidePanel(CommonActivityPanel.ActivityType.JZJX)
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow then
    self:UpdateUI()
  end
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.countDown = self.m_panel:FindDirect("Label")
  self.uiObjs.countDownLabel = self.uiObjs.countDown:GetComponent("UILabel")
  self.uiObjs.Container = self.m_panel:FindDirect("Container")
  self.uiObjs.Img_Bg = self.uiObjs.Container:FindDirect("Img_Bg")
  self.uiObjs.Target_List = self.uiObjs.Img_Bg:FindDirect("Scroll View/Target_List")
  if _G.PlayerIsInFight() then
    self:Show(false)
  end
  local CommonActivityPanel = require("GUI.CommonActivityPanel")
  CommonActivityPanel.Instance():ShowActivityPanel(true, true, function(...)
    require("Main.Team.TeamUtils").JoinTeam()
  end, nil, function()
    self:QuitActivity()
  end, nil, false, CommonActivityPanel.ActivityType.JZJX)
end
def.method().Clear = function(self)
  self:ClearCountDown()
  self.uiObjs = nil
  self.m_viewData = nil
end
def.method().ClearCountDown = function(self)
  if self.countDownTimerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.countDownTimerId)
    self.countDownTimerId = 0
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  local parentObj = obj.transform.parent.gameObject
  if string.sub(parentObj.name, 1, #"item_") == "item_" then
    local index = tonumber(string.sub(parentObj.name, #"item_" + 1, -1))
    self:OnNPCItemClicked(index)
  else
    self:onClick(id)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Tips" then
    self:OnTipsButtonClicked()
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.PANELNAME, {
      self.m_panelName
    })
  elseif id == "Btn_Quit" then
    self:QuitActivity()
  end
end
def.method().UpdateUI = function(self)
  if not self:IsShow() then
    return
  end
  if self.viewType == ViewType.CountDown then
    self:ShowCountDownView()
  else
    self:ShowActivityView()
  end
end
def.method().ShowCountDownView = function(self)
  self.uiObjs.Img_Bg:SetActive(false)
  self.uiObjs.countDown:SetActive(true)
  local t = JZJXMgr.Instance():GetEnterActivityMapStartTime()
  local startTimestamp = t.timestamp
  local function UpdateCountDownValue()
    if self.uiObjs == nil then
      return
    end
    local curTimestamp = _G.GetServerTime()
    local seconds = startTimestamp - curTimestamp
    self:SetCountDownValue(seconds)
  end
  if self.countDownTimerId == 0 then
    self.countDownTimerId = GameUtil.AddGlobalTimer(1, false, function()
      UpdateCountDownValue()
    end)
  end
  UpdateCountDownValue()
end
def.method("number").SetCountDownValue = function(self, value)
  local text
  if value > 0 then
    local timeText = JZJXUtils.Seconds2TimeText(value)
    text = string.format(textRes.JueZhanJiuXiao[1], timeText)
    GUIUtils.SetActive(self.uiObjs.countDown, true)
  else
    text = ""
    GUIUtils.SetActive(self.uiObjs.countDown, false)
  end
  self.uiObjs.countDownLabel.text = text
end
def.method().ShowActivityView = function(self)
  self.uiObjs.Img_Bg:SetActive(true)
  self.uiObjs.countDown:SetActive(false)
  self:ClearCountDown()
  self:UpdateTargetList()
end
def.method().UpdateTargetList = function(self)
  local viewData = JZJXUIMgr.Instance():GetCurLayerMapViewData()
  if viewData == nil then
    self.uiObjs.Img_Bg:SetActive(false)
    return
  end
  local uiList = self.uiObjs.Target_List:GetComponent("UIList")
  self:SetTargetList(viewData, uiList)
  self.m_viewData = viewData
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("table", "userdata").SetTargetList = function(self, viewData, uiList)
  local itemCount = #viewData.npcList
  if viewData.bossNPC then
    uiList.itemCount = itemCount + 1
  end
  uiList:Resize()
  local listItems = uiList.children
  for i = 1, itemCount do
    self:SetTargetListItem(i, viewData.npcList[i], listItems[i])
  end
  if viewData.bossNPC then
    local i = itemCount + 1
    self:SetBossTargetListItem(i, viewData, listItems[i])
  end
end
def.method("number", "table", "userdata").SetTargetListItem = function(self, index, npcViewData, listItem)
  local uiLabel = listItem:FindDirect("Label"):GetComponent("UILabel")
  uiLabel.text = npcViewData.npcName
  local isFound = npcViewData.isFound
  GUIUtils.SetActive(listItem:FindDirect("Btn_Find"), not isFound)
  GUIUtils.SetActive(listItem:FindDirect("Img_Completed"), isFound)
  GUIUtils.SetActive(listItem:FindDirect("Btn_Fight"), false)
end
def.method("number", "table", "userdata").SetBossTargetListItem = function(self, index, viewData, listItem)
  local bossNPC = viewData.bossNPC
  local uiLabel = listItem:FindDirect("Label"):GetComponent("UILabel")
  uiLabel.text = bossNPC.npcName
  local isFoundAll = self:IsFoundAll(viewData.npcList)
  GUIUtils.SetActive(listItem:FindDirect("Btn_Find"), false)
  if bossNPC.isDefeat then
    GUIUtils.SetActive(listItem:FindDirect("Img_Completed"), true)
    GUIUtils.SetActive(listItem:FindDirect("Btn_Fight"), false)
  else
    GUIUtils.SetActive(listItem:FindDirect("Img_Completed"), false)
    local Btn_Fight = listItem:FindDirect("Btn_Fight")
    GUIUtils.SetActive(Btn_Fight, true)
    if isFoundAll then
      if Btn_Fight then
        local uiButton = Btn_Fight:GetComponent("UIButton")
        uiButton:ResetDefaultColor()
        uiButton.hover = uiButton.defaultColor
        uiButton.pressed = uiButton.defaultColor
      end
    elseif Btn_Fight then
      local uiButton = Btn_Fight:GetComponent("UIButton")
      uiButton.defaultColor = uiButton.disabledColor
      uiButton.hover = uiButton.disabledColor
      uiButton.pressed = uiButton.disabledColor
    end
  end
end
def.method().OnTipsButtonClicked = function(self)
  local CommonUISmallTip = require("GUI.CommonUISmallTip")
  local sourceObj = self.uiObjs.Img_Bg:FindDirect("Img_Split1")
  local position = sourceObj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = sourceObj:GetComponent("UIWidget")
  CommonUISmallTip.Instance():ShowTip(textRes.JueZhanJiuXiao[8], screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
end
def.method().QuitActivity = function(self)
  local TeamData = require("Main.Team.TeamData")
  local teamData = TeamData.Instance()
  local isNotTmpLeave = teamData:GetStatus() ~= require("netio.protocol.mzm.gsp.team.TeamMember").ST_TMP_LEAVE
  if teamData:HasTeam() and not teamData:MeIsCaptain() and isNotTmpLeave then
    Toast(textRes.JueZhanJiuXiao[9])
    return
  else
    local CommonActivityPanel = require("GUI.CommonActivityPanel")
    CommonActivityPanel.Instance():ShowQuitConfirm(function(s)
      if s == 1 then
        JZJXMgr.Instance():QuitActivity()
      end
    end, nil)
  end
end
def.method("number").OnNPCItemClicked = function(self, index)
  if not self:IsAllow() then
    return
  end
  if self.m_viewData == nil then
    return
  end
  local npc = self.m_viewData.npcList[index]
  if npc == nil then
    npc = self.m_viewData.bossNPC
    if not self:IsFoundAll(self.m_viewData.npcList) then
      Toast(textRes.JueZhanJiuXiao[11])
      return
    end
  end
  local npcId = npc.npcId
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_NPC, {npcId})
end
def.method("table", "=>", "boolean").IsFoundAll = function(self, npcList)
  local isFoundAll = true
  for i, v in ipairs(npcList) do
    if v.isFound ~= true then
      isFoundAll = false
      break
    end
  end
  return isFoundAll
end
def.method("=>", "boolean").IsAllow = function(self)
  local TeamData = require("Main.Team.TeamData")
  local teamData = TeamData.Instance()
  if teamData:HasTeam() and not teamData:MeIsCaptain() then
    Toast(textRes.JueZhanJiuXiao[9])
    return false
  end
  return true
end
def.static("table", "table").OnSyncLayerMapData = function(params)
  local self = instance
  if self.viewType == ViewType.Activity then
    self:UpdateUI()
  end
end
def.static("table", "table").OnEnterFight = function(params)
  local self = instance
  self:Show(false)
end
def.static("table", "table").OnLeaveFight = function(params)
  local self = instance
  self:Show(true)
end
return JZJXMainPanel.Commit()
