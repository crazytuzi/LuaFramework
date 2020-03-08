local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local FashionEffectPanel = Lplus.Extend(ECPanelBase, "FashionEffectPanel")
local TabNode = require("GUI.TabNode")
local FashionData = require("Main.Fashion.FashionData")
local FashionUtils = require("Main.Fashion.FashionUtils")
local FashionModule = Lplus.ForwardDeclare("FashionModule")
local def = FashionEffectPanel.define
local instance
local TAB_ID = {TAB_EFFECT = 1, TAB_PROPERTY = 2}
def.field("table")._uiObjs = nil
def.field("table")._currentFashions = nil
def.field("number")._currentTabId = TAB_ID.TAB_PROPERTY
def.static("=>", FashionEffectPanel).Instance = function()
  if instance == nil then
    instance = FashionEffectPanel()
  end
  return instance
end
def.method().ShowFashionEffect = function(self)
  self:CreatePanel(RESPATH.PREFAB_FASHION_EFFECT_PANEL, 2)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self._uiObjs = {}
  self._uiObjs.Img_0 = self.m_panel:FindDirect("Img_0")
  self._uiObjs.Tab_Effect = self._uiObjs.Img_0:FindDirect("Tab_Effect")
  self._uiObjs.Tab_Attribute = self._uiObjs.Img_0:FindDirect("Tab_Attribute")
  self._uiObjs.ScrollView = self._uiObjs.Img_0:FindDirect("Group_Content/Scroll View")
  self._uiObjs.List_Effect = self._uiObjs.ScrollView:FindDirect("List_Effect")
  self._uiObjs.List_Attribute = self._uiObjs.ScrollView:FindDirect("List_Attribute")
  self._uiObjs.Tab_Attribute:GetComponent("UIToggle").value = true
  self._currentTabId = TAB_ID.TAB_PROPERTY
  self:_CheckNotify()
  self:_LoadCurrentFashionData()
  self:_FillTabContent()
  Event.RegisterEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionExpired, FashionEffectPanel._OnFashionExpired)
  Event.RegisterEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionOperateFailed, FashionEffectPanel._OnFashionOperateFailed)
  Event.RegisterEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionPropertyChanged, FashionEffectPanel._OnFashionPropertyChanged)
end
def.method()._CheckNotify = function(self)
  if FashionData.Instance():HasEffectNotify() then
    self._uiObjs.Tab_Attribute:FindDirect("Img_Red"):SetActive(true)
  end
end
def.method()._ClearNotify = function(self)
  FashionData.Instance():ClearEffectNotify()
  self._uiObjs.Tab_Attribute:FindDirect("Img_Red"):SetActive(false)
end
def.method()._LoadCurrentFashionData = function(self)
  local haveFashionInfo = FashionData.Instance().haveFashionInfo
  local fashionItems = {}
  for id, leftTime in pairs(haveFashionInfo) do
    table.insert(fashionItems, FashionUtils.GetFashionItemDataById(id))
  end
  self._currentFashions = fashionItems
end
def.method()._FillTabContent = function(self)
  if self._currentTabId == TAB_ID.TAB_PROPERTY then
    self._uiObjs.Tab_Effect:GetComponent("UIToggle").value = false
    self._uiObjs.Tab_Attribute:GetComponent("UIToggle").value = true
    self._uiObjs.List_Effect:SetActive(false)
    self._uiObjs.List_Attribute:SetActive(true)
    self:_FillCurrentProperty()
  elseif self._currentTabId == TAB_ID.TAB_EFFECT then
    self._uiObjs.Tab_Effect:GetComponent("UIToggle").value = true
    self._uiObjs.Tab_Attribute:GetComponent("UIToggle").value = false
    self._uiObjs.List_Effect:SetActive(true)
    self._uiObjs.List_Attribute:SetActive(false)
    self:_FillCurrentEffect()
  end
end
def.method()._FillCurrentEffect = function(self)
  local fashionItemCount = #self._currentFashions
  local fashionInfo = {}
  for i = 1, fashionItemCount do
    local fashionItem = self._currentFashions[i]
    local skillEffects = fashionItem.effects
    local effectDesc = {}
    for i = 1, #skillEffects do
      local skillId = skillEffects[i]
      local skillCfg = require("Main.Skill.SkillUtility").GetSkillCfg(skillId)
      if skillCfg ~= nil then
        table.insert(effectDesc, skillCfg.description)
      end
    end
    if #effectDesc > 0 then
      local showInfo = {}
      showInfo.name = fashionItem.fashionDressName
      showInfo.effectDesc = table.concat(effectDesc, "\n")
      table.insert(fashionInfo, showInfo)
    end
  end
  local showCount = #fashionInfo
  local uiList = self._uiObjs.List_Effect:GetComponent("UIList")
  uiList.itemCount = showCount
  uiList:Resize()
  local uiItems = uiList.children
  for i = 1, showCount do
    local uiItem = uiItems[i]
    local showInfo = fashionInfo[i]
    local fashionItem = self._currentFashions[i]
    local labelName = uiItem:FindDirect("Label_Name_" .. i):GetComponent("UILabel")
    local labelInfo = uiItem:FindDirect("Label_Info_" .. i):GetComponent("UILabel")
    labelName:set_text(showInfo.name)
    labelInfo:set_text(showInfo.effectDesc)
  end
  GameUtil.AddGlobalTimer(0, true, function()
    GameUtil.AddGlobalTimer(0, true, function()
      uiList:Reposition()
    end)
  end)
end
def.method()._FillCurrentProperty = function(self)
  local activatePropertyList = FashionData.Instance().activatePropertyList
  local activatePropertyMap = {}
  for idx, cfgId in pairs(activatePropertyList) do
    activatePropertyMap[cfgId] = cfgId
  end
  local fashionItemCount = #self._currentFashions
  local fashionInfo = {}
  for i = 1, fashionItemCount do
    local fashionItem = self._currentFashions[i]
    local skillProperties = fashionItem.properties
    local propertyDesc = {}
    for i = 1, #skillProperties do
      local skillId = skillProperties[i]
      local skillCfg = require("Main.Skill.SkillUtility").GetSkillCfg(skillId)
      if skillCfg ~= nil then
        table.insert(propertyDesc, skillCfg.description)
      end
    end
    if #propertyDesc > 0 then
      local showInfo = {}
      showInfo.id = fashionItem.id
      showInfo.name = fashionItem.fashionDressName
      showInfo.propertyDesc = table.concat(propertyDesc, "\n")
      table.insert(fashionInfo, showInfo)
    end
  end
  local showCount = #fashionInfo
  local uiList = self._uiObjs.List_Attribute:GetComponent("UIList")
  uiList.itemCount = showCount
  uiList:Resize()
  local uiItems = uiList.children
  for i = 1, showCount do
    local uiItem = uiItems[i]
    local showInfo = fashionInfo[i]
    local fashionItem = self._currentFashions[i]
    local labelName = uiItem:FindDirect("Label_Name_" .. i):GetComponent("UILabel")
    local labelInfo = uiItem:FindDirect("Label_Info_" .. i):GetComponent("UILabel")
    labelName:set_text(showInfo.name)
    labelInfo:set_text(showInfo.propertyDesc)
    local toggleObj = uiItem:FindDirect("Img_Toggle_" .. i)
    local toggle = toggleObj:GetComponent("UIToggle")
    uiItem.name = "Img_Effect_" .. showInfo.id
    if activatePropertyMap[showInfo.id] ~= nil then
      toggle.value = true
    else
      toggle.value = false
    end
  end
end
def.method()._ResetScrollView = function(self)
  GameUtil.AddGlobalTimer(0.01, true, function()
    if self.m_panel and not self.m_panel.isnil then
      self._uiObjs.ScrollView:GetComponent("UIScrollView"):ResetPosition()
    end
  end)
end
def.method("number", "boolean")._SetPropertyState = function(self, cfgId, state)
  if state then
    FashionModule.SelectProperty(cfgId)
  else
    FashionModule.UnSelectProperty(cfgId)
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif string.find(id, "Img_Toggle_") == 1 then
    local cfgId = tonumber(string.sub(clickObj.parent.name, #"Img_Effect_" + 1))
    local toggle = clickObj:GetComponent("UIToggle")
    if toggle.value and FashionData.Instance():GetCurrentActivePropertyCount() >= constant.FashionDressConsts.maxUsePropertyNum then
      if 1 < constant.FashionDressConsts.maxUsePropertyNum then
        Toast(textRes.Fashion[18])
        toggle.value = false
      else
        self:_SetPropertyState(cfgId, toggle.value)
      end
    else
      self:_SetPropertyState(cfgId, toggle.value)
    end
  elseif id == "Tab_Attribute" then
    self:OnTabAttributeClick()
  elseif id == "Tab_Effect" then
    self:OnTabEffectClick()
  end
end
def.method().OnTabAttributeClick = function(self)
  self._currentTabId = TAB_ID.TAB_PROPERTY
  self:_ClearNotify()
  self:_FillTabContent()
  self:_ResetScrollView()
end
def.method().OnTabEffectClick = function(self)
  self._currentTabId = TAB_ID.TAB_EFFECT
  self:_FillTabContent()
  self:_ResetScrollView()
end
def.static("table", "table")._OnFashionExpired = function(params, context)
  local self = instance
  if self ~= nil then
    self:_LoadCurrentFashionData()
    self:_FillTabContent()
  end
end
def.static("table", "table")._OnFashionOperateFailed = function(params, context)
  local self = instance
  if self ~= nil then
    self:_LoadCurrentFashionData()
    self:_FillTabContent()
  end
end
def.static("table", "table")._OnFashionPropertyChanged = function(params, context)
  local self = instance
  if self ~= nil then
    self:_FillTabContent()
  end
end
def.override().OnDestroy = function(self)
  self._uiObjs = nil
  self._currentFashions = nil
  self._currentTabId = 0
  Event.UnregisterEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionExpired, FashionEffectPanel._OnFashionExpired)
  Event.UnregisterEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionOperateFailed, FashionEffectPanel._OnFashionOperateFailed)
  Event.UnregisterEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionPropertyChanged, FashionEffectPanel._OnFashionPropertyChanged)
end
FashionEffectPanel.Commit()
return FashionEffectPanel
