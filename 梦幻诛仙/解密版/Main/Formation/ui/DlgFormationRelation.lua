local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgFormationRelation = Lplus.Extend(ECPanelBase, "DlgFormationRelation")
local def = DlgFormationRelation.define
local FormationModule = Lplus.ForwardDeclare("FormationModule")
local FormationUtils = require("Main.Formation.FormationUtils")
local GUIUtils = require("GUI.GUIUtils")
def.field("number").formationId = 0
def.method("number").ShowTips = function(self, formationId)
  self.formationId = formationId
  self:CreatePanel(RESPATH.FORMATION_RELATION_DLG, 2)
  self:SetOutTouchDisappear()
end
def.override().OnCreate = function(self)
  self:UpdatePanel()
end
def.override().OnDestroy = function(self)
  self = nil
end
def.method().UpdatePanel = function(self)
  local formationcfg = FormationUtils.GetFormationCfg(self.formationId)
  local kzGroup = self.m_panel:FindDirect("Img_Bg0/Group_Kz")
  local lastFormation
  for i = 1, 3 do
    local formationItem = kzGroup:FindDirect(string.format("Group_Zf%02d", i))
    local k, v = next(formationcfg.KZInfo, lastFormation)
    lastFormation = k
    if lastFormation == nil then
      break
    end
    local cfg = FormationUtils.GetFormationCfg(k)
    local name = cfg.name
    local icon = cfg.icon
    local value = string.format(" %2d%%", v.value / 100)
    self:FillOneFormation(formationItem, icon, name, value)
  end
  local kzGroup = self.m_panel:FindDirect("Img_Bg0/Group_Bk")
  lastFormation = nil
  for i = 1, 3 do
    local formationItem = kzGroup:FindDirect(string.format("Group_Zf%02d", i))
    local k, v = next(formationcfg.BKInfo, lastFormation)
    lastFormation = k
    if lastFormation == nil then
      break
    end
    local cfg = FormationUtils.GetFormationCfg(k)
    local name = cfg.name
    local icon = cfg.icon
    local value = string.format("%2d%%", v.value / 100)
    self:FillOneFormation(formationItem, icon, name, value)
  end
end
def.method("userdata", "number", "string", "string").FillOneFormation = function(self, formationItem, icon, name, value)
  local uiTex = formationItem:FindDirect("Img_Zf/Texture_Zf"):GetComponent("UITexture")
  GUIUtils.FillIcon(uiTex, icon)
  formationItem:FindDirect("Label_Name"):GetComponent("UILabel"):set_text(name)
  formationItem:FindDirect("Label_Num"):GetComponent("UILabel"):set_text(value)
end
DlgFormationRelation.Commit()
return DlgFormationRelation
