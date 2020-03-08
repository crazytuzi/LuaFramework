local Lplus = require("Lplus")
local CommonAssignPropSettingPanel = require("GUI.CommonAssignPropSettingPanel")
local AutoAssignPropSettingPanel = Lplus.Extend(CommonAssignPropSettingPanel, "AutoAssignPropSettingPanel")
local Base = CommonAssignPropSettingPanel
local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr")
local HeroAssignPointMgr = require("Main.Hero.mgr.HeroAssignPointMgr")
local HeroSecondProp = Lplus.ForwardDeclare("HeroSecondProp")
local HeroExtraProp = Lplus.ForwardDeclare("HeroExtraProp")
local HeroUtility = require("Main.Hero.HeroUtility")
local GUIUtils = require("GUI.GUIUtils")
local def = AutoAssignPropSettingPanel.define
local instance
def.static("=>", AutoAssignPropSettingPanel).Instance = function()
  if instance == nil then
    instance = AutoAssignPropSettingPanel()
  end
  return instance
end
def.override().OnCreate = function(self)
  local enabledIndex = HeroAssignPointMgr.Instance():GetEnabledSchemeIndex()
  self.scheme = HeroAssignPointMgr.Instance():GetAssignPointScheme(enabledIndex)
  Base.OnCreate(self)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.SAVE_ASSIGN_RROP_SETTING_SUCCESS, AutoAssignPropSettingPanel.OnSuccessSaveAutoAssignPropSetting)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_USE_RECOMMEND_ASSIGN_PROP_SCHEME, AutoAssignPropSettingPanel.OnRecommendUpdate)
end
def.override().OnDestroy = function(self)
  Base.OnDestroy(self)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.SAVE_ASSIGN_RROP_SETTING_SUCCESS, AutoAssignPropSettingPanel.OnSuccessSaveAutoAssignPropSetting)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_USE_RECOMMEND_ASSIGN_PROP_SCHEME, AutoAssignPropSettingPanel.OnRecommendUpdate)
  self.scheme:ResetAutoAssigning()
  self.scheme = nil
end
def.override("string").OnIncProp = function(self, propName)
  local enabledIndex = HeroAssignPointMgr.Instance():GetEnabledSchemeIndex()
  HeroAssignPointMgr.Instance():IncBasePropSetting(enabledIndex, propName)
  self:UpdateBaseProp()
end
def.override("string").OnDecProp = function(self, propName)
  local enabledIndex = HeroAssignPointMgr.Instance():GetEnabledSchemeIndex()
  HeroAssignPointMgr.Instance():DecBasePropSetting(enabledIndex, propName)
  self:UpdateBaseProp()
end
def.override().OnSettingClearButtonClicked = function(self)
  local HeroAssignPointMgr = require("Main.Hero.mgr.HeroAssignPointMgr").Instance()
  local enabledIndex = HeroAssignPointMgr:GetEnabledSchemeIndex()
  HeroAssignPointMgr:ClearAutoAssignSetting(enabledIndex)
  self:UpdateBaseProp()
end
def.override().OnSettingSaveButtonClicked = function(self)
  if not self.isEnableConfirm then
    Toast(textRes.Hero[44])
    return
  end
  local HeroAssignPointMgr = require("Main.Hero.mgr.HeroAssignPointMgr").Instance()
  local enabledIndex = HeroAssignPointMgr:GetEnabledSchemeIndex()
  HeroAssignPointMgr:SaveAutoAssignSetting(enabledIndex)
end
def.override().OnRecommendBtnClicked = function(self)
  require("Main.Hero.ui.PropRecommendPanel").Instance():ShowPanel()
end
def.static("table", "table").OnSuccessSaveAutoAssignPropSetting = function(params, context)
  instance:DestroyPanel()
  local enabledIndex = HeroAssignPointMgr.Instance():GetEnabledSchemeIndex()
  HeroAssignPointMgr.Instance():EnableAutoAssignPoint(enabledIndex, true)
end
def.static("table", "table").OnRecommendUpdate = function(params, context)
  instance:UpdateBaseProp()
end
def.override("string", "number", "=>", "number").UpdateEnteredValue = function(self, propName, value)
  local enabledIndex = HeroAssignPointMgr.Instance():GetEnabledSchemeIndex()
  local actualValue = HeroAssignPointMgr.Instance():SetBasePropSetting(enabledIndex, propName, value)
  self:UpdateBaseProp()
  return actualValue
end
return AutoAssignPropSettingPanel.Commit()
