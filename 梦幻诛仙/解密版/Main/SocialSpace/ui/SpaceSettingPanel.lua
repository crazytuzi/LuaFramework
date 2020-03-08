local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SpaceSettingPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local def = SpaceSettingPanel.define
local SocialSpaceSettingMan = require("Main.SocialSpace.SocialSpaceSettingMan")
local ECSocialSpaceMan = require("Main.SocialSpace.ECSocialSpaceMan")
def.field("table").m_UIGOs = nil
local instance
def.static("=>", SpaceSettingPanel).Instance = function()
  if instance == nil then
    instance = SpaceSettingPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_SOCIAL_SPACE_SETTING_PANEL, 2)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self.m_UIGOs = nil
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Confirm" then
    self:OnClickConfirmBtn()
  elseif id:sub(1, 7) == "Toggle_" then
    self:OnClickToggle(obj)
  elseif id == "Btn_BlackList" then
    self:OnClickBlacklistBtn()
  elseif id == "Btn_FollowList" then
    self:OnClickFocusListBtn()
  end
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.m_UIGOs.Container = self.m_UIGOs.Img_Bg0:FindDirect("Container")
  local Btn_FollowList = self.m_UIGOs.Img_Bg0:FindDirect("Btn_FollowList")
  local SocialSpaceModule = require("Main.SocialSpace.SocialSpaceModule")
  local showFocusBtn = SocialSpaceModule.Instance():IsFocusFeatureOpen()
  GUIUtils.SetActive(Btn_FollowList, showFocusBtn)
end
def.method().UpdateUI = function(self)
  self:UpdateSettings()
end
def.method().OnClickConfirmBtn = function(self)
  self:DestroyPanel()
end
def.method().UpdateSettings = function(self)
  local setting = SocialSpaceSettingMan.GetSpaceSetting()
  local Container = self.m_UIGOs.Container
  local Toggle_01 = Container:FindDirect("Toggle_01")
  GUIUtils.Toggle(Toggle_01, setting.remindNewMsg == SocialSpaceSettingMan.SETTING_ENABLE)
  local Toggle_02 = Container:FindDirect("Toggle_02")
  GUIUtils.Toggle(Toggle_02, setting.commentSetting == SocialSpaceSettingMan.ACCESS_TYPE.ONLY_FRINEDS)
  local Toggle_03 = Container:FindDirect("Toggle_03")
  GUIUtils.Toggle(Toggle_03, setting.commentSetting == SocialSpaceSettingMan.ACCESS_TYPE.NOBODY)
  local Toggle_04 = Container:FindDirect("Toggle_04")
  GUIUtils.Toggle(Toggle_04, setting.messageSetting == SocialSpaceSettingMan.ACCESS_TYPE.ONLY_FRINEDS)
  local Toggle_05 = Container:FindDirect("Toggle_05")
  GUIUtils.Toggle(Toggle_05, setting.messageSetting == SocialSpaceSettingMan.ACCESS_TYPE.NOBODY)
end
def.method("userdata").OnClickToggle = function(self, obj)
  local toggle = obj:GetComponent("UIToggle")
  local indexStr = obj.name:split("_")[2]
  local func = self:tryget("OnToggle_" .. indexStr)
  if func then
    local setting = SocialSpaceSettingMan.GetSpaceSetting()
    func(self, toggle, setting)
    SocialSpaceSettingMan.SaveSpaceSetting()
  end
end
def.method("userdata", "boolean", "boolean").SetToggleState = function(self, toggle, isSelect, showToast)
  toggle.value = isSelect
  if showToast then
    self:ShowToggleToast(isSelect)
  end
end
def.method("boolean").ShowToggleToast = function(self, isSelect)
  if isSelect then
    Toast(textRes.SocialSpace[39])
  else
    Toast(textRes.SocialSpace[40])
  end
end
def.method("userdata", "table").OnToggle_01 = function(self, toggle, setting)
  if setting.remindNewMsg == SocialSpaceSettingMan.SETTING_ENABLE then
    setting.remindNewMsg = SocialSpaceSettingMan.SETTING_DISABLE
    self:SetToggleState(toggle, false, true)
  else
    setting.remindNewMsg = SocialSpaceSettingMan.SETTING_ENABLE
    self:SetToggleState(toggle, true, true)
  end
  ECSocialSpaceMan.Instance():NotifyUnreadMsgCount()
end
def.method("userdata", "table").OnToggle_02 = function(self, toggle, setting)
  local value = toggle.value
  toggle.value = not value
  local updateSetting = {}
  if value then
    updateSetting.commentSetting = SocialSpaceSettingMan.ACCESS_TYPE.ONLY_FRINEDS
  else
    updateSetting.commentSetting = SocialSpaceSettingMan.ACCESS_TYPE.EVERYBODY
  end
  ECSocialSpaceMan.Instance():Req_UpdateSpaceSetting(updateSetting, function()
    if not self:IsLoaded() then
      return
    end
    self:UpdateSettings()
    self:ShowToggleToast(value)
  end, true)
end
def.method("userdata", "table").OnToggle_03 = function(self, toggle, setting)
  local value = toggle.value
  toggle.value = not value
  local updateSetting = {}
  if value then
    updateSetting.commentSetting = SocialSpaceSettingMan.ACCESS_TYPE.NOBODY
  else
    updateSetting.commentSetting = SocialSpaceSettingMan.ACCESS_TYPE.EVERYBODY
  end
  ECSocialSpaceMan.Instance():Req_UpdateSpaceSetting(updateSetting, function()
    if not self:IsLoaded() then
      return
    end
    self:UpdateSettings()
    self:ShowToggleToast(value)
  end, true)
end
def.method("userdata", "table").OnToggle_04 = function(self, toggle, setting)
  local value = toggle.value
  toggle.value = not value
  local updateSetting = {}
  if value then
    updateSetting.messageSetting = SocialSpaceSettingMan.ACCESS_TYPE.ONLY_FRINEDS
  else
    updateSetting.messageSetting = SocialSpaceSettingMan.ACCESS_TYPE.EVERYBODY
  end
  ECSocialSpaceMan.Instance():Req_UpdateSpaceSetting(updateSetting, function()
    if not self:IsLoaded() then
      return
    end
    self:UpdateSettings()
    self:ShowToggleToast(value)
  end, true)
end
def.method("userdata", "table").OnToggle_05 = function(self, toggle, setting)
  local value = toggle.value
  toggle.value = not value
  local updateSetting = {}
  if value then
    updateSetting.messageSetting = SocialSpaceSettingMan.ACCESS_TYPE.NOBODY
  else
    updateSetting.messageSetting = SocialSpaceSettingMan.ACCESS_TYPE.EVERYBODY
  end
  ECSocialSpaceMan.Instance():Req_UpdateSpaceSetting(updateSetting, function()
    if not self:IsLoaded() then
      return
    end
    self:UpdateSettings()
    self:ShowToggleToast(value)
  end, true)
end
def.method().OnClickBlacklistBtn = function(self)
  require("Main.SocialSpace.ui.SpaceBlacklistPanel").Instance():ShowPanel()
end
def.method().OnClickFocusListBtn = function(self)
  require("Main.SocialSpace.ui.SpaceFocusListPanel").Instance():ShowPanel()
end
return SpaceSettingPanel.Commit()
