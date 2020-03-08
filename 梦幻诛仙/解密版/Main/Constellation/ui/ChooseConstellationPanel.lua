local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ChooseConstellationPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local ConstellationUtils = import("..ConstellationUtils")
local ConstellationModule = import("..ConstellationModule")
local CommonGuideTip = require("GUI.CommonGuideTip")
local def = ChooseConstellationPanel.define
local instance
def.static("=>", ChooseConstellationPanel).Instance = function()
  if instance == nil then
    instance = ChooseConstellationPanel()
  end
  return instance
end
local CONSTELLATION_NONE = ConstellationModule.CONSTELLATION_NONE
def.field("table").m_uiObjs = nil
def.field("table").m_constellations = nil
def.field("number").m_natalConstellation = CONSTELLATION_NONE
def.field("number").m_selIndex = 0
def.method().ShowPanel = function(self)
  if self.m_panel ~= nil then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PERFAB_12CONSTELLATIONS_CHOOSE_CONSTELLATION, 2)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.CONSTELLATION, gmodule.notifyId.Constellation.SET_NATAL_CONSTELLATION_SUCCESS, ChooseConstellationPanel.OnSetNatalConstellationSuccess)
  Event.RegisterEvent(ModuleId.CONSTELLATION, gmodule.notifyId.Constellation.NATAL_CONSTELLATION_UPDATE, ChooseConstellationPanel.OnNatalConstellationUpdate)
end
def.override().OnDestroy = function(self)
  self:HideGuide()
  self.m_uiObjs = nil
  self.m_constellations = nil
  self.m_selIndex = 0
  Event.UnregisterEvent(ModuleId.CONSTELLATION, gmodule.notifyId.Constellation.SET_NATAL_CONSTELLATION_SUCCESS, ChooseConstellationPanel.OnSetNatalConstellationSuccess)
  Event.UnregisterEvent(ModuleId.CONSTELLATION, gmodule.notifyId.Constellation.NATAL_CONSTELLATION_UPDATE, ChooseConstellationPanel.OnNatalConstellationUpdate)
end
def.override("boolean").OnShow = function(self, s)
end
def.method().InitUI = function(self)
  self.m_uiObjs = {}
  self.m_uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.m_uiObjs.Group_Up = self.m_uiObjs.Img_Bg0:FindDirect("Group_Up")
  self.m_uiObjs.Group_Down = self.m_uiObjs.Img_Bg0:FindDirect("Group_Down")
  self.m_uiObjs.Group_Stars = self.m_uiObjs.Img_Bg0:FindDirect("Group_Stars")
  self.m_uiObjs.Grid = self.m_uiObjs.Group_Stars:FindDirect("Grid")
  local uiGrid = self.m_uiObjs.Grid:GetComponent("UIGrid")
  uiGrid.sorting = 0
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  elseif string.find(id, "Star_") then
    local index = tonumber(string.sub(id, #"Star_" + 1, -1))
    if index then
      self:OnClickConstellation(index)
    end
  elseif id == "Btn_Confirm" then
    self:OnConfirmBtnClick()
  end
end
def.method().UpdateUI = function(self)
  self.m_natalConstellation = ConstellationModule.Instance():GetNatalConstellation()
  self:UpdateAllConstellations()
  self:UpdateNatalConstellation()
  self:UpdateLeftChangeTimes()
  self:UpdateSelectedConstellation()
  self:UpdateGuide()
end
def.method().UpdateAllConstellations = function(self)
  local constellations = ConstellationUtils.GetAllConstellations()
  self.m_constellations = constellations
  GUIUtils.ResizeGrid(self.m_uiObjs.Grid, #constellations, "Star_")
  for i, v in ipairs(constellations) do
    local constellationInfo = self:GetConstellationInfo(v)
    self:SetConstellation(i, constellationInfo)
  end
end
def.method("number", "table").SetConstellation = function(self, index, constellationInfo)
  local itemGO = self.m_uiObjs.Grid:FindDirect("Star_" .. index)
  local Label_Select = itemGO:FindDirect("Label_Select")
  local Img_Icon = itemGO:FindDirect("Img_Icon")
  Label_Select:SetActive(false)
  GUIUtils.SetTexture(Img_Icon, constellationInfo.icon)
  local uiTexture = Img_Icon:GetComponent("UITexture")
  if constellationInfo.constellation == self.m_natalConstellation then
    GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Gray)
  else
    GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Normal)
  end
end
def.method().UpdateNatalConstellation = function(self)
  local constellation = self.m_natalConstellation
  local icon = 0
  local constellationName
  if constellation ~= CONSTELLATION_NONE then
    local info = self:GetConstellationInfo(constellation)
    icon = info.icon
    constellationName = info.name
  end
  local Item0 = self.m_uiObjs.Group_Up:FindDirect("Item0")
  local Img_Icon = Item0:FindDirect("Img_Icon")
  local Label_Star = Item0:FindDirect("Label_Star")
  GUIUtils.SetTexture(Img_Icon, icon)
  if constellationName then
    Label_Star:SetActive(true)
    local text = string.format(textRes.Constellation[1], constellationName)
    GUIUtils.SetText(Label_Star, text)
  else
    GUIUtils.SetText(Label_Star, "")
  end
end
def.method().UpdateLeftChangeTimes = function(self)
  local Label_Info02 = self.m_uiObjs.Group_Down:FindDirect("Label_Info02")
  local leftTimes = self:GetLeftChangeTimes()
  local text = string.format(textRes.Constellation[4], leftTimes)
  GUIUtils.SetText(Label_Info02, text)
end
def.method("number").OnClickConstellation = function(self, index)
  local constellation = self:GetConstellationByIndex(index)
  if constellation == nil then
    return
  end
  if constellation == self.m_natalConstellation then
    self:ToggleGridItem(index, false)
    self:ToggleGridItem(self.m_selIndex, true)
    return
  end
  self:OnSelectConstellation(index, constellation)
end
def.method("number", "number").OnSelectConstellation = function(self, index, constellation)
  self.m_selIndex = index
  self:ToggleGridItem(index, true)
  self:UpdateSelectedConstellation()
end
def.method().OnConfirmBtnClick = function(self)
  local constellation = self:GetConstellationByIndex(self.m_selIndex)
  if constellation == CONSTELLATION_NONE then
    Toast(textRes.Constellation[5])
    return
  end
  local leftTimes = self:GetLeftChangeTimes()
  if leftTimes <= 0 then
    Toast(textRes.Constellation[3])
    return
  end
  ConstellationModule.Instance():SetNatalConstellationReq(constellation)
end
def.method().UpdateSelectedConstellation = function(self)
  local constellation = self:GetConstellationByIndex(self.m_selIndex)
  local icon = 0
  local constellationName
  if constellation ~= CONSTELLATION_NONE then
    local info = self:GetConstellationInfo(constellation)
    icon = info.icon
    constellationName = info.name
  end
  local Item1 = self.m_uiObjs.Group_Up:FindDirect("Item1")
  local Img_Icon = Item1:FindDirect("Img_Icon")
  local Label_Star = Item1:FindDirect("Label_Star")
  GUIUtils.SetTexture(Img_Icon, icon)
  if constellationName then
    Label_Star:SetActive(true)
    local text = string.format(textRes.Constellation[2], constellationName)
    GUIUtils.SetText(Label_Star, text)
  else
    GUIUtils.SetText(Label_Star, "")
  end
end
def.method("number", "boolean").ToggleGridItem = function(self, index, isToggle)
  local itemGO = self.m_uiObjs.Grid:FindDirect("Star_" .. index)
  if itemGO == nil then
    return
  end
  GUIUtils.Toggle(itemGO, isToggle)
end
def.method().UpdateGuide = function(self)
  if self.m_natalConstellation == CONSTELLATION_NONE then
    if self.m_uiObjs.guideDlg and self.m_uiObjs.guideDlg.m_panel then
      return
    end
    do
      local content = textRes.Constellation[14]
      local target = self.m_uiObjs.Group_Stars:FindDirect("Widget_Guide")
      local dir = CommonGuideTip.StyleEnum.RIGHT
      GameUtil.AddGlobalTimer(0, true, function(...)
        if target.isnil then
          return
        end
        self.m_uiObjs.guideDlg = CommonGuideTip.ShowGuideTip(content, target, dir)
      end)
    end
  else
    self:HideGuide()
  end
end
def.method().HideGuide = function(self)
  if self.m_uiObjs.guideDlg then
    self.m_uiObjs.guideDlg:HideDlg()
    self.m_uiObjs.guideDlg = nil
  end
end
def.method("number", "=>", "number").GetConstellationByIndex = function(self, index)
  if self.m_constellations == nil then
    return CONSTELLATION_NONE
  end
  local constellation = self.m_constellations[index] or CONSTELLATION_NONE
  return constellation
end
def.method("number", "=>", "table").GetConstellationInfo = function(self, constellation)
  local info = {constellation = constellation}
  local cfg = ConstellationUtils.GetConstellationCfg(constellation)
  info.icon = cfg.icon
  info.name = cfg.name
  return info
end
def.method("=>", "number").GetLeftChangeTimes = function(self)
  return ConstellationModule.Instance():GetNatalConstellationLCT()
end
def.static("table", "table").OnSetNatalConstellationSuccess = function()
  print("OnSetNatalConstellationSuccess")
  local self = instance
  self:DestroyPanel()
end
def.static("table", "table").OnNatalConstellationUpdate = function()
end
return ChooseConstellationPanel.Commit()
