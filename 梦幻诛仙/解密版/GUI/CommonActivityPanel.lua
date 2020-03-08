local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local CommonActivityPanel = Lplus.Extend(ECPanelBase, "CommonActivityPanel")
local def = CommonActivityPanel.define
def.field("boolean").bShowTeam = true
def.field("boolean").bShowQuit = true
def.field("function").callbackTeam = nil
def.field("table").tagTeam = nil
def.field("function").callbackQuit = nil
def.field("table").tagQuit = nil
def.field("boolean").bShowConfirm = true
local instance
def.const("table").ActivityType = {
  PhantomCave = 1,
  JZJX = 2,
  TeamDungeon = 3,
  SXZB = 4,
  TXHW = 5,
  QMHW = 6,
  WEDDING = 7,
  HULA = 8,
  INTERACTIVE_TASK = 9,
  ZHUXIANJIANZHEN = 10,
  GANG_DUNGEON = 11,
  SINGLE_BATTLE = 12,
  TREASURE_HUNT = 13
}
def.field("number").activityType = 0
def.static("=>", CommonActivityPanel).Instance = function()
  if instance == nil then
    instance = CommonActivityPanel()
    instance:SetDepth(GUIDEPTH.BOTTOM)
  end
  return instance
end
def.method("boolean", "boolean", "function", "table", "function", "table", "boolean", "number").ShowActivityPanel = function(self, bShowTeam, bShowQuit, callbackTeam, tagTeam, callbackQuit, tagQuit, bShowConfirm, activityType)
  self.bShowTeam = bShowTeam
  self.bShowQuit = bShowQuit
  self.callbackTeam = callbackTeam
  self.tagTeam = tagTeam
  self.callbackQuit = callbackQuit
  self.tagQuit = tagQuit
  self.bShowConfirm = bShowConfirm
  self.activityType = activityType
  if self:IsShow() then
    self:UpdateInfo()
    if _G.PlayerIsInFight() then
      self:Show(false)
    end
    return
  end
  self:CreatePanel(RESPATH.PREFAB_ACTIVITY_BTN_PANEL, 0)
end
def.method("number").HidePanel = function(self, activityType)
  if self.activityType == activityType then
    self:DestroyPanel()
    self = nil
  end
end
def.override().OnCreate = function(self)
  self:UpdateInfo()
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, CommonActivityPanel.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, CommonActivityPanel.OnLeaveFight)
  if _G.PlayerIsInFight() then
    self:Show(false)
  end
end
def.override("boolean").OnShow = function(self, s)
  if s and _G.PlayerIsInFight() then
    self:Show(false)
  end
end
def.override().OnDestroy = function(self)
  self.callbackTeam = nil
  self.callbackQuit = nil
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, CommonActivityPanel.OnEnterFight)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, CommonActivityPanel.OnLeaveFight)
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  local self = instance
  self:Show(false)
end
def.static("table", "table").OnLeaveFight = function(p1, p2)
  local self = instance
  self:Show(true)
end
def.method().UpdateInfo = function(self)
  local Btn_Team = self.m_panel:FindDirect("Btn_Team")
  local Btn_Leave = self.m_panel:FindDirect("Btn_Leave")
  if self.bShowQuit then
    Btn_Leave:SetActive(true)
  else
    Btn_Leave:SetActive(false)
  end
  if self.bShowTeam then
    Btn_Team:SetActive(true)
  else
    Btn_Team:SetActive(false)
  end
end
def.static("number", "table").QuitBtnClickCallback = function(i, tag)
  if 1 == i then
    local self = tag.id
    if self.callbackQuit then
      self.callbackQuit(self.tagQuit)
    end
  elseif 0 == i then
    return
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Team" then
    if self.callbackTeam then
      self.callbackTeam(self.tagTeam)
    end
  elseif id == "Btn_Leave" and self.callbackQuit then
    if self.bShowConfirm then
      local tag = {id = self}
      self:ShowQuitConfirm(CommonActivityPanel.QuitBtnClickCallback, tag)
    else
      self.callbackQuit(self.tagQuit)
    end
  end
end
def.method("function", "table").ShowQuitConfirm = function(self, callback, tag)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  local tag = {id = self}
  CommonConfirmDlg.ShowConfirm("", textRes.Common[250], callback, tag)
end
return CommonActivityPanel.Commit()
