local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PropRecommendPanel = Lplus.Extend(ECPanelBase, "PropRecommendPanel")
local HeroUtility = require("Main.Hero.HeroUtility")
local HeroAssignPointMgr = require("Main.Hero.mgr.HeroAssignPointMgr")
local GUIUtils = require("GUI.GUIUtils")
local def = PropRecommendPanel.define
local Vector = require("Types.Vector")
def.field("number").selectedScheme = 1
def.field("table").schemeCfgList = nil
def.field("table").uiObjs = nil
local instance
def.static("=>", PropRecommendPanel).Instance = function()
  if instance == nil then
    instance = PropRecommendPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_HERO_RECOMMEND_ASSIGN_PROP_PANEL, 2)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self:Clear()
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  elseif string.sub(id, 1, #"Btn_Toggle") == "Btn_Toggle" then
    local index = tonumber(string.sub(id, #"Btn_Toggle" + 1, -1))
    self:OnSchemeClicked(index)
  elseif id == "Btn_Confirm" then
    self:OnConfirmButtonClicked()
  end
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.uiObjs.Group_AddPlan = self.uiObjs.Img_Bg:FindDirect("Group_AddPlan")
end
def.method().UpdateUI = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local cfgList = HeroUtility.GetRoleRecommandAssignPropCfg(heroProp.occupation)
  self.schemeCfgList = cfgList
  self:LocateMatchScheme()
  self:SetSchemes(cfgList)
end
def.method("table").SetSchemes = function(self, schemes)
  for i, scheme in ipairs(schemes) do
    self:SetScheme(i, scheme)
  end
end
def.method("number", "table").SetScheme = function(self, index, scheme)
  local Img_Plan = self.uiObjs.Group_AddPlan:FindDirect("Img_Plan" .. index)
  local Btn_Toggle = Img_Plan:FindDirect("Btn_Toggle" .. index)
  local Label_PlanContent = Img_Plan:FindDirect("Label_PlanContent" .. index)
  local desc = self:GetFormatRecommandAssignText(scheme)
  Label_PlanContent:GetComponent("UILabel").text = desc
end
def.method("table", "=>", "string").GetFormatRecommandAssignText = function(self, cfg)
  local atrrNameMap = {
    [103] = "str",
    [104] = "spi",
    [105] = "con",
    [106] = "sta",
    [107] = "dex"
  }
  local lineTextTable = {}
  for k, v in pairs(atrrNameMap) do
    if cfg[v] > 0 then
      table.insert(lineTextTable, string.format(textRes.Hero[47] .. " ", cfg[v], textRes.Hero[k]))
    end
  end
  local descTable = string.split(cfg.desc, "|")
  local descStr = table.concat(descTable, " ")
  table.insert(lineTextTable, descStr)
  local line = table.concat(lineTextTable, "")
  return line
end
def.method("number").OnSchemeClicked = function(self, index)
  self.selectedScheme = index
end
def.method().OnConfirmButtonClicked = function(self)
  local schemeId = HeroAssignPointMgr.Instance():GetEnabledSchemeIndex()
  local scheme = self.schemeCfgList[self.selectedScheme]
  HeroAssignPointMgr.Instance():ClearAutoAssignSetting(schemeId)
  for propName, value in pairs(scheme) do
    if propName ~= "desc" then
      HeroAssignPointMgr.Instance():SetBasePropSetting(schemeId, propName, value)
    end
  end
  self:DestroyPanel()
  Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_USE_RECOMMEND_ASSIGN_PROP_SCHEME, nil)
end
def.method().LocateMatchScheme = function(self)
  local schemeId = HeroAssignPointMgr.Instance():GetEnabledSchemeIndex()
  local scheme = HeroAssignPointMgr.Instance():GetAssignPointScheme(schemeId)
  scheme:GetAutoAssigning()
  if scheme.autoAssigning == nil then
    return
  end
  local schemeCfgList = self.schemeCfgList
  local idx = 1
  for i, rec in ipairs(schemeCfgList) do
    local isMatch = true
    for propName, value in pairs(rec) do
      if propName ~= "desc" and scheme.autoAssigning[propName] ~= value then
        isMatch = false
        break
      end
    end
    if isMatch then
      idx = i
      break
    end
  end
  self.selectedScheme = idx
  for i = 1, 3 do
    local toggleName = string.format("Img_Plan%d/Btn_Toggle%d", i, i)
    local toggle = self.uiObjs.Group_AddPlan:FindDirect(toggleName)
    GUIUtils.Toggle(toggle, i == idx)
  end
end
def.method().Clear = function(self)
  self.uiObjs = nil
  self.selectedScheme = 1
end
return PropRecommendPanel.Commit()
