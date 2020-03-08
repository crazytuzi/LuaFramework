local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local ThemeFashionNode = Lplus.Extend(TabNode, "ThemeFashionNode")
local GUIUtils = require("GUI.GUIUtils")
local FashionUtils = require("Main.Fashion.FashionUtils")
local FashionData = require("Main.Fashion.FashionData")
local def = ThemeFashionNode.define
def.field("table").uiObjs = nil
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.method("=>", "boolean").IsShow = function(self)
  return self.isShow
end
def.override().OnShow = function(self)
  if self.uiObjs == nil then
    self:InitUI()
    self:ShowThemeFashion()
    self:UpdateLimitedThemeFashionInfo()
  end
  Event.RegisterEventWithContext(ModuleId.FASHION, gmodule.notifyId.Fashion.ThemeFashionChanged, ThemeFashionNode.OnThemeFashionChanged, self)
  Event.RegisterEventWithContext(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionNotifyChanged, ThemeFashionNode.OnFashionNotifyChanged, self)
end
def.override().OnHide = function(self)
  self.uiObjs = nil
  Event.UnregisterEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.ThemeFashionChanged, ThemeFashionNode.OnThemeFashionChanged)
  Event.UnregisterEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionNotifyChanged, ThemeFashionNode.OnFashionNotifyChanged)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Group_Scrollview = self.m_node:FindDirect("Group_List/Group_Scroll View")
  self.uiObjs.List = self.uiObjs.Group_Scrollview:FindDirect("List")
  self.uiObjs.MonthTheme = self.m_node:FindDirect("MonthTheme")
  self.uiObjs.Group_Open = self.uiObjs.MonthTheme:FindDirect("Group_Open")
  self.uiObjs.Group_Close = self.uiObjs.MonthTheme:FindDirect("Group_Close")
end
def.method().ShowThemeFashion = function(self)
  local themeFashionCfgData = FashionUtils.GetAllThemeFashionCfgData()
  local uiList = self.uiObjs.List:GetComponent("UIList")
  uiList.itemCount = #themeFashionCfgData
  uiList:Resize()
  local uiItems = uiList.children
  for i = 1, #themeFashionCfgData do
    local item = uiItems[i]
    self:FillFashionItemInfo(i, item, themeFashionCfgData[i])
  end
end
def.method().UpdateThemeFashionData = function(self)
  local themeFashionCfgData = FashionUtils.GetAllThemeFashionCfgData()
  local uiList = self.uiObjs.List:GetComponent("UIList")
  local uiItems = uiList.children
  for i = 1, #themeFashionCfgData do
    local item = uiItems[i]
    self:FillFashionItemInfo(i, item, themeFashionCfgData[i])
  end
end
def.method("number", "userdata", "table").FillFashionItemInfo = function(self, idx, item, themeFashion)
  local Img_Theme = item:FindDirect("Img_Theme_" .. idx)
  local Img_Bg_Proportion = item:FindDirect("Img_Bg_Proportion_" .. idx)
  local Label_Proportion = Img_Bg_Proportion:FindDirect("Label_Proportion_" .. idx)
  local Img_ThemeSign = item:FindDirect("Img_ThemeSign_" .. idx)
  local curUnlockNum = 0
  local totalNum = #themeFashion.relatedFashionType
  for i = 1, totalNum do
    local fashionType = themeFashion.relatedFashionType[i]
    if FashionData.Instance():IsThemeFashionUnlock(fashionType) then
      curUnlockNum = curUnlockNum + 1
    end
  end
  GUIUtils.SetText(Label_Proportion, string.format("%d/%d", curUnlockNum, totalNum))
  GUIUtils.FillIcon(Img_Theme:GetComponent("UITexture"), themeFashion.iconId)
  local Slider_Unlock = item:FindDirect("Slider_Unlock_" .. idx)
  local Img_SliderFore = Slider_Unlock:FindDirect("Img_SliderFore_" .. idx)
  GUIUtils.SetSprite(Img_SliderFore, themeFashion.progressBarName)
  GUIUtils.SetProgress(Slider_Unlock, GUIUtils.COTYPE.SLIDER, curUnlockNum / totalNum)
  GUIUtils.SetLightEffect(Img_Theme, GUIUtils.Light.None)
  local FashionModule = require("Main.Fashion.FashionModule")
  local needLight = false
  if FashionModule.Instance():IsThemeFashionHasFullUnlockNotify(themeFashion.id) or FashionModule.Instance():IsThemeFashionHasAwardNotify(themeFashion.id) then
    needLight = true
  end
  if FashionModule.Instance():IsLimitedThemeFashionHasNotify() then
    local curCfg = FashionUtils.GetNowLimitedThemeFashionCfg()
    local curThemeId = curCfg and curCfg.theme_fashion_dress_cfg_id or 0
    needLight = curThemeId == themeFashion.id
  end
  if needLight then
    GameUtil.AddGlobalTimer(0.5, true, function()
      if self.uiObjs ~= nil then
        GUIUtils.SetLightEffect(Img_Theme, GUIUtils.Light.Square)
        GUIUtils.DragToMakeVisible(self.uiObjs.Group_Scrollview, item, false, 256)
      end
    end)
  end
  local isLimitedThemeOpen = _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_TIME_LIMITED_THEME_FASHION_DRESS)
  local limitedCfg, period = FashionUtils.GetNowLimitedThemeFashionCfg()
  if isLimitedThemeOpen and limitedCfg and limitedCfg.theme_fashion_dress_cfg_id == themeFashion.id then
    GUIUtils.SetActive(Img_ThemeSign, true)
  else
    GUIUtils.SetActive(Img_ThemeSign, false)
  end
end
def.method().UpdateLimitedThemeFashionInfo = function(self)
  local limitedCfg, period = FashionUtils.GetNowLimitedThemeFashionCfg()
  local themeFashionCfg = FashionUtils.GetThemeFashionCfgById(limitedCfg and limitedCfg.theme_fashion_dress_cfg_id or 0)
  local isOpen = _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_TIME_LIMITED_THEME_FASHION_DRESS)
  if limitedCfg == nil or themeFashionCfg == nil or not isOpen then
    GUIUtils.SetActive(self.uiObjs.Group_Open, false)
    GUIUtils.SetActive(self.uiObjs.Group_Close, true)
  else
    GUIUtils.SetActive(self.uiObjs.Group_Open, true)
    GUIUtils.SetActive(self.uiObjs.Group_Close, false)
    local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
    local timeLimitCommonCfg = TimeCfgUtils.GetTimeLimitCommonCfg(limitedCfg.time_limit_cfg_id)
    local nextPeriodLimitedCfg = FashionUtils.GetNextPeriodLimitedThemeFashionCfg(period)
    local Label = self.uiObjs.Group_Open:FindDirect("Label")
    local Img_BgTitle = self.uiObjs.Group_Open:FindDirect("Img_BgTitle")
    local Label_Buff_Month = self.uiObjs.Group_Open:FindDirect("Label_Buff_Month")
    local Img_BgTitleNext = self.uiObjs.Group_Open:FindDirect("Img_BgTitleNext")
    local Label_Buff_MonthNext = self.uiObjs.Group_Open:FindDirect("Label_Buff_MonthNext")
    local curbuffCfg = require("Main.Buff.BuffUtility").GetBuffCfg(limitedCfg.buff_cfg_id)
    GUIUtils.FillIcon(Img_BgTitle:GetComponent("UITexture"), limitedCfg.icon_id)
    GUIUtils.SetText(Label_Buff_Month, string.format(textRes.Fashion[49], timeLimitCommonCfg.startMonth, timeLimitCommonCfg.startDay, timeLimitCommonCfg.endMonth, timeLimitCommonCfg.endDay))
    GUIUtils.SetText(Label, string.format(textRes.Fashion[45], themeFashionCfg.fashionDressName, curbuffCfg.desc))
    if nextPeriodLimitedCfg == nil then
      GUIUtils.FillIcon(Img_BgTitleNext:GetComponent("UITexture"), 0)
      GUIUtils.SetText(Label_Buff_MonthNext, textRes.Fashion[48])
    else
      GUIUtils.FillIcon(Img_BgTitleNext:GetComponent("UITexture"), nextPeriodLimitedCfg.icon_id)
      GUIUtils.SetText(Label_Buff_MonthNext, "")
    end
  end
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if string.find(id, "Btn_Theme_") then
    local index = tonumber(string.sub(id, #"Btn_Theme_" + 1))
    self:OnFashionIconClick(index)
  end
end
def.method("number").OnFashionIconClick = function(self, index)
  local themeFashionCfgData = FashionUtils.GetAllThemeFashionCfgData()
  local themeFashion = themeFashionCfgData[index]
  if themeFashion == nil then
    warn("themeFashion is nil at idx:" .. index)
    return
  end
  require("Main.Fashion.ui.ThemeFashionDetailPanel").Instance():ShowPanelWithThemeFashion(themeFashion)
end
def.method("table").OnThemeFashionChanged = function(self, params)
  self:UpdateThemeFashionData()
end
def.method("table").OnFashionNotifyChanged = function(self, params)
  self:UpdateThemeFashionData()
  self:UpdateLimitedThemeFashionInfo()
end
ThemeFashionNode.Commit()
return ThemeFashionNode
