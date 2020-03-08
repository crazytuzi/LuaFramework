local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ChargeAndCostPanel = require("Main.CustomActivity.ui.ChargeAndCostPanel")
local TimeLimitedGiftPanel = require("Main.CustomActivity.ui.TimeLimitedGiftPanel")
local TimedLoginPanel = require("Main.CustomActivity.ui.TimedLoginPanel")
local TimedLoginMgr = require("Main.CustomActivity.TimedLoginMgr")
local LimitTimeSignInPanel = require("Main.CustomActivity.ui.LimitTimeSignInPanel")
local CustomActivityPanel = Lplus.Extend(ECPanelBase, "CustomActivityPanel")
local ActivityInterface = require("Main.activity.ActivityInterface")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local CustomActivityInterface = require("Main.CustomActivity.CustomActivityInterface")
local Vector3 = require("Types.Vector3").Vector3
local customActivityInterface = CustomActivityInterface.Instance()
local GUIUtils = require("GUI.GUIUtils")
local def = CustomActivityPanel.define
local instance
def.field("string").curTab = "Tab_LimitRecharge"
def.field("string").targetTab = ""
local PanelSort = {
  "Tab_LimitRecharge",
  "Tab_LimitCost",
  "Tab_LimitGiftBa",
  "Tab_Carnival",
  "Tab_QianDao"
}
local PanelDef = {
  Tab_LimitRecharge = {
    dynamicActivityId = function()
      return CustomActivityInterface.LIMIT_CHARGE_ACTIVITY_ID
    end,
    objCls = ChargeAndCostPanel,
    featureType = Feature.TYPE_QING_FU_TIME_LIMITED_SAVE_AMT,
    dynamicTabName = function()
      return CustomActivityPanel.GetTabNameByActivityId(CustomActivityInterface.LIMIT_CHARGE_ACTIVITY_ID)
    end
  },
  Tab_LimitCost = {
    dynamicActivityId = function()
      return CustomActivityInterface.LIMIT_COST_ACTIVITY_ID
    end,
    objCls = ChargeAndCostPanel,
    featureType = Feature.TYPE_QING_FU_TIME_LIMITED_ACCUM_TOTAL_COST,
    dynamicTabName = function()
      return CustomActivityPanel.GetTabNameByActivityId(CustomActivityInterface.LIMIT_COST_ACTIVITY_ID)
    end
  },
  Tab_LimitGiftBa = {
    dynamicActivityId = function()
      return CustomActivityInterface.Instance():GetTimeLimitedGiftActivityId()
    end,
    activityId = nil,
    objCls = TimeLimitedGiftPanel,
    featureType = Feature.TYPE_TIME_LIMIT_GIFT,
    dynamicTabName = function()
      return CustomActivityPanel.GetTimeLimitedGifTabName()
    end
  },
  Tab_Carnival = {
    dynamicActivityId = function()
      return TimedLoginMgr.Instance():GetDynamicActId()
    end,
    activityId = nil,
    objCls = TimedLoginPanel,
    featureType = nil,
    dynamicFeatureType = function()
      return TimedLoginMgr.Instance():GetDynamicFeatureType()
    end,
    dynamicTabName = function()
      return TimedLoginMgr.Instance():GetDynamicActName()
    end
  },
  Tab_QianDao = {
    dynamicActivityId = function()
      return CustomActivityInterface.Instance():GetLimitTimeSingInActivityId()
    end,
    objCls = LimitTimeSignInPanel,
    featureType = Feature.TYPE_LOGIN_SIGN_ACTIVITY,
    dynamicTabName = function()
      return CustomActivityPanel.GetLimitTimeSignInTabName()
    end
  }
}
def.static("=>", CustomActivityPanel).Instance = function()
  if instance == nil then
    instance = CustomActivityPanel()
    instance:Init()
    instance.m_TrigGC = true
    instance.m_TryIncLoadSpeed = true
  end
  return instance
end
def.static("=>", "boolean").isOwnOpendActivity = function()
  customActivityInterface:setLimitChargeActivityId()
  customActivityInterface:setLimitCostActivityId()
  local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
  for i, v in pairs(PanelDef) do
    local isOpen = CustomActivityPanel.Instance():IsActivityOpend(v)
    local featureType = -1
    if v.featureType then
      featureType = v.featureType
    elseif v.dynamicFeatureType then
      featureType = v.dynamicFeatureType()
    end
    local open = feature:CheckFeatureOpen(featureType)
    if isOpen and open then
      return true
    end
  end
  return false
end
def.method().Init = function(self)
end
def.method("number", "=>", "boolean").ShowPanelByActivityId = function(self, activityId)
  if activityId > 0 then
    local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
    for i, v in pairs(PanelDef) do
      local dynamicActivityId = v.dynamicActivityId()
      if v.activityId and v.activityId == activityId or dynamicActivityId and dynamicActivityId == activityId then
        local isOpen = self:IsActivityOpend(v)
        local featureType = -1
        if v.featureType then
          featureType = v.featureType
        elseif v.dynamicFeatureType then
          featureType = v.dynamicFeatureType()
        end
        local open = feature:CheckFeatureOpen(featureType)
        if isOpen and open then
          self:ShowPanelWithTabName(i)
          return true
        else
          return false
        end
      end
    end
  else
    self:ShowPanel()
    return true
  end
  return false
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_PRIZE_LIMIT, 1)
end
def.method("string").ShowPanelWithTabName = function(self, tabName)
  self.targetTab = tabName
  self:ShowPanel()
end
def.override().OnCreate = function(self)
end
def.override().OnDestroy = function(self)
  self.targetTab = ""
end
def.override().AfterCreate = function(self)
  local firstTabName = self:initActivityDisplay()
  self.targetTab = ""
  if firstTabName ~= "" then
    self:selectedPanel(firstTabName)
  end
  self:updateRedPoint()
end
def.override("boolean").OnShow = function(self, show)
  local curPanelInfo = PanelDef[self.curTab]
  if show then
    if curPanelInfo then
      local curInstance = curPanelInfo.objCls.Instance()
      if curInstance then
        curPanelInfo.objCls.Instance():ShowPanel(self.curTab)
      end
    end
    self:updateRedPoint()
    Event.RegisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.UPDATE_RED_POINT, CustomActivityPanel.OnUpdateRedPoint)
    Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, CustomActivityPanel.OnFunctionOpenChange)
    Event.RegisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.CUSTOM_ACTIVITY_OPEN_CHANGE, CustomActivityPanel.OnActiveOpenChange)
  else
    if curPanelInfo then
      curPanelInfo.objCls.Instance():Hide()
    end
    Event.UnregisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.UPDATE_RED_POINT, CustomActivityPanel.OnUpdateRedPoint)
    Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, CustomActivityPanel.OnFunctionOpenChange)
    Event.UnregisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.CUSTOM_ACTIVITY_OPEN_CHANGE, CustomActivityPanel.OnActiveOpenChange)
  end
end
def.static("table", "table").OnUpdateRedPoint = function(p1, p2)
  if instance then
    instance:updateRedPoint()
  end
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  if instance then
    local tabName = instance:initActivityDisplay()
    if tabName == "" then
      instance:Hide()
      return
    end
    local curPaneInfo = PanelDef[instance.curTab]
    if curPaneInfo then
      local featureType = -1
      if curPaneInfo.featureType then
        featureType = curPaneInfo.featureType
      elseif curPaneInfo.dynamicFeatureType then
        featureType = curPaneInfo.dynamicFeatureType()
      end
      local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
      local open = feature:CheckFeatureOpen(featureType)
      if tabName ~= "" and not open then
        instance:selectedPanel(tabName)
      end
    end
  end
end
def.static("table", "table").OnActiveOpenChange = function(p1, p2)
  if instance then
    local tabName = instance:initActivityDisplay()
    if tabName == "" then
      instance:Hide()
      return
    end
    local curPaneInfo = PanelDef[instance.curTab]
    if (not curPaneInfo or not instance:IsActivityOpend(curPaneInfo)) and tabName ~= "" then
      instance:selectedPanel(tabName)
    end
  end
end
def.method().Hide = function(self)
  local curPanelInfo = PanelDef[self.curTab]
  if curPanelInfo then
    curPanelInfo.objCls.Instance():Hide()
  end
  self:DestroyPanel()
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  local strs = string.split(id, "_")
  if id == "Btn_Close" then
    self:Hide()
  elseif strs[1] == "Tab" and strs[2] ~= nil then
    self:selectedPanel(id)
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.TIMELIMITGIFT, {id})
  end
end
def.method("=>", "string").initActivityDisplay = function(self)
  local Grid = self.m_panel:FindDirect("Img_Bg0/Group_Left/Scroll View/Grid")
  local y = 0
  local firstTabName = ""
  local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
  for i, v in ipairs(PanelSort) do
    local isOpen = self:IsActivityOpend(PanelDef[v])
    local curTab = Grid:FindDirect(v)
    local featureType = -1
    if PanelDef[v].featureType then
      featureType = PanelDef[v].featureType
    elseif PanelDef[v].dynamicFeatureType then
      featureType = PanelDef[v].dynamicFeatureType()
    end
    local open = feature:CheckFeatureOpen(featureType)
    if isOpen and open then
      curTab:SetActive(true)
      local pos = curTab.transform.localPosition
      curTab.transform.localPosition = Vector3.new(pos.x, y, 0)
      y = y - 77
      if firstTabName == "" then
        firstTabName = v
      elseif self.targetTab ~= "" and v == self.targetTab then
        firstTabName = v
      end
      if PanelDef[v] and PanelDef[v].dynamicTabName then
        local tabDisplayName = PanelDef[v].dynamicTabName()
        if tabDisplayName ~= "" then
          local Label_Tab = curTab:FindDirect("Label_Tab")
          GUIUtils.SetText(Label_Tab, tabDisplayName)
        end
      end
    else
      curTab:SetActive(false)
    end
  end
  return firstTabName
end
def.method("table", "=>", "boolean").IsActivityOpend = function(self, tabDef)
  local activityId = tabDef.activityId
  if activityId == nil and tabDef.dynamicActivityId then
    activityId = tabDef.dynamicActivityId()
  end
  if activityId == nil or activityId == 0 then
    return false
  end
  return ActivityInterface.Instance():isActivityOpend(activityId)
end
def.method("string").selectedPanel = function(self, tabName)
  local Grid = self.m_panel:FindDirect("Img_Bg0/Group_Left/Scroll View/Grid")
  if self.curTab ~= tabName and self.curTab then
    local curPanelInfo = PanelDef[self.curTab]
    if curPanelInfo then
      local curTab = Grid:FindDirect(self.curTab)
      local Img_Normal = curTab:FindDirect("Img_Normal")
      local Img_Select = curTab:FindDirect("Img_Select")
      Img_Select:SetActive(false)
      Img_Normal:SetActive(true)
      curPanelInfo.objCls.Instance():Hide()
    end
  end
  local panelInfo = PanelDef[tabName]
  if panelInfo then
    local panelCls = panelInfo.objCls
    self.curTab = tabName
    local curTab = Grid:FindDirect(tabName)
    local Img_Normal = curTab:FindDirect("Img_Normal")
    local Img_Select = curTab:FindDirect("Img_Select")
    Img_Select:SetActive(true)
    Img_Normal:SetActive(false)
    panelCls.Instance():ShowPanel(tabName)
  end
end
def.method().updateRedPoint = function(self)
  local Grid = self.m_panel:FindDirect("Img_Bg0/Group_Left/Scroll View/Grid")
  for i, v in pairs(PanelDef) do
    local Img_Red = Grid:FindDirect(i .. "/Img_Red")
    if Img_Red then
      local flag = customActivityInterface:getCustomActivityRedPointFlag(i)
      if flag then
        Img_Red:SetActive(true)
      else
        Img_Red:SetActive(false)
      end
    end
  end
end
def.static("number", "=>", "string").GetTabNameByActivityId = function(activityId)
  if activityId == 0 then
    return ""
  end
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
  if activityCfg then
    return activityCfg.activityName
  else
    return ""
  end
end
def.static("=>", "string").GetTimeLimitedGifTabName = function()
  local activityId = CustomActivityInterface.Instance():GetTimeLimitedGiftActivityId()
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
  if activityCfg then
    return activityCfg.activityName
  else
    return ""
  end
end
def.static("=>", "string").GetLimitTimeSignInTabName = function()
  local activityId = CustomActivityInterface.Instance():GetLimitTimeSingInActivityId()
  return CustomActivityPanel.GetTabNameByActivityId(activityId)
end
return CustomActivityPanel.Commit()
