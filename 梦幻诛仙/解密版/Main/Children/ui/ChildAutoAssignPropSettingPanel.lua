local Lplus = require("Lplus")
local CommonAssignPropSettingPanel = require("GUI.CommonAssignPropSettingPanel")
local ChildAutoAssignPropSettingPanel = Lplus.Extend(CommonAssignPropSettingPanel, "ChildAutoAssignPropSettingPanel")
local Base = CommonAssignPropSettingPanel
local ChildrenDataMgr = require("Main.Children.ChildrenDataMgr")
local ChildAssignPropMgr = require("Main.Children.mgr.ChildAssignPropMgr").Instance()
local GUIUtils = require("GUI.GUIUtils")
local def = ChildAutoAssignPropSettingPanel.define
def.field("userdata").childId = nil
local instance
def.static("=>", ChildAutoAssignPropSettingPanel).Instance = function()
  if instance == nil then
    instance = ChildAutoAssignPropSettingPanel()
  end
  return instance
end
def.method("userdata").ShowPanelEx = function(self, childId)
  self.childId = childId
  self:ShowPanel()
end
def.override().OnCreate = function(self)
  local child = ChildrenDataMgr.Instance():GetChildById(self.childId)
  self.scheme = child.assignPropScheme
  Base.OnCreate(self)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.CHILD_SAVE_ASSIGN_PROP_SUCCESS, ChildAutoAssignPropSettingPanel.OnSaveAssignSuccess)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.CLEAR_PROP_SET, ChildAutoAssignPropSettingPanel.OnResetPropSetting)
  local clear_label = self.uiObjs.Group_BtnSettle:FindDirect("Btn_JDPlanSettle_Clear/Label_JDPlanSettle_Clear")
  if clear_label then
    clear_label:GetComponent("UILabel").text = textRes.Children[3079]
  end
end
def.override().OnDestroy = function(self)
  Base.OnDestroy(self)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.CHILD_SAVE_ASSIGN_PROP_SUCCESS, ChildAutoAssignPropSettingPanel.OnSaveAssignSuccess)
  self.scheme:ResetAutoAssigning()
  self.scheme = nil
end
def.override("string").OnIncProp = function(self, propName)
  ChildAssignPropMgr:IncBasePropPrefab(self.childId, propName)
  self:UpdateBaseProp()
end
def.override("string").OnDecProp = function(self, propName)
  ChildAssignPropMgr:DecBasePropPrefab(self.childId, propName)
  self:UpdateBaseProp()
end
def.override().OnSettingClearButtonClicked = function(self)
  local child_data = ChildrenDataMgr.Instance():GetChildById(self.childId)
  if child_data and not child_data:HasPropSet() then
    child_data.assignPropScheme:ClearAutoAssigning()
    self:UpdateBaseProp()
    Toast(textRes.Children[3019])
    return
  end
  require("GUI.CommonConfirmDlg").ShowConfirm("", string.format(textRes.Children[3020], constant.CChildrenConsts.resetPrefCost), function(id)
    if id == 1 then
      local ItemModule = require("Main.Item.ItemModule")
      local money = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.Children.CResetAddPotentialPrefReq").new(self.childId, money))
    end
  end, nil)
end
def.static("table", "table").OnResetPropSetting = function(params, context)
  instance:UpdateBaseProp()
end
def.override().OnSettingSaveButtonClicked = function(self)
  if not self.isEnableConfirm then
    Toast(textRes.Hero[44])
    return
  end
  ChildAssignPropMgr:SaveAssignedPropPrefab(self.childId)
end
def.override().OnRecommendBtnClicked = function(self)
  local child_data = ChildrenDataMgr.Instance():GetChildById(self.childId)
  local schemeId = require("Main.Children.ChildrenUtils").GetChildDefaultScheme(child_data:GetMenpai())
  local defaultScheme = require("Main.Hero.HeroUtility").GetDefaultAssignPropScheme(schemeId)
  if defaultScheme == nil then
    return
  end
  local scheme = child_data.assignPropScheme
  scheme:ClearAutoAssigning()
  for propName, value in pairs(defaultScheme) do
    ChildAssignPropMgr:SetBasePropSetting(self.childId, propName, value)
  end
  self:UpdateBaseProp()
end
def.static("table", "table").OnSaveAssignSuccess = function(params, context)
  instance:DestroyPanel()
end
def.override("string", "number", "=>", "number").UpdateEnteredValue = function(self, propName, value)
  local actualValue = ChildAssignPropMgr:SetBasePropSetting(self.childId, propName, value)
  self:UpdateBaseProp()
  return actualValue
end
def.override().UpdateBaseProp = function(self)
  CommonAssignPropSettingPanel.UpdateBaseProp(self)
  local child_data = ChildrenDataMgr.Instance():GetChildById(self.childId)
  local hasPropSet = child_data:HasPropSet()
  local grid_baseProp = self.uiObjs.Img_JD_BgPlan0:FindDirect("Grid_JDPlan")
  if hasPropSet then
    for i = 1, 5 do
      local ctrlName = string.format("Label_JDPlan_Attribute0%d/Btn_JDPlan_Minus0%d", i, i)
      local button_prop = grid_baseProp:FindDirect(ctrlName)
      button_prop:SetActive(false)
    end
  end
end
return ChildAutoAssignPropSettingPanel.Commit()
