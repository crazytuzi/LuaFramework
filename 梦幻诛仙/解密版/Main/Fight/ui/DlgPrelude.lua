local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgPrelude = Lplus.Extend(ECPanelBase, "DlgPrelude")
local GUIUtils = require("GUI.GUIUtils")
local def = DlgPrelude.define
local dlg
local EC = require("Types.Vector3")
def.field("number").cfgId = 0
def.field("number").skillIconId = 0
def.field("number").genderActive = 0
def.field("number").genderPassive = 0
def.field("table").models = nil
def.static("=>", DlgPrelude).Instance = function()
  if dlg == nil then
    dlg = DlgPrelude()
  end
  return dlg
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, DlgPrelude.OnLeaveFight)
end
def.method("number", "number", "number", "=>", "boolean").ShowDlg = function(self, cfgId, genderActive, genderPassive)
  if self.m_panel then
    self:DestroyPanel()
  end
  self.models = {}
  local FightUtils = require("Main.Fight.FightUtils")
  local compositeCfg = FightUtils.GetCompositeSkillCfg(cfgId)
  if compositeCfg == nil then
    return
  end
  self.genderActive = genderActive
  self.genderPassive = genderPassive
  self.skillIconId = compositeCfg.skillIconid
  local activeIcon = compositeCfg.activeMale
  local Gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  if self.genderActive == Gender.FEMALE then
    activeIcon = compositeCfg.activeFemale
  end
  local iconRes = GetIconPath(activeIcon)
  GameUtil.AsyncLoad(iconRes, function(obj)
    if obj == nil then
      return
    end
    if self.models == nil then
      return
    end
    self.models[1] = Object.Instantiate(obj, "GameObject")
    self:SetActiveIcon()
  end)
  local passiveIcon = compositeCfg.passiveMale
  if self.genderPassive == Gender.FEMALE then
    passiveIcon = compositeCfg.passiveFemale
  end
  iconRes = GetIconPath(passiveIcon)
  GameUtil.AsyncLoad(iconRes, function(obj)
    if obj == nil then
      return
    end
    if self.models == nil then
      return
    end
    self.models[2] = Object.Instantiate(obj, "GameObject")
    self:SetPassiveIcon()
  end)
  self:CreatePanel(RESPATH.DLG_FIGHT_PRELUDE, -1)
  self:SetDepth(GUIDEPTH.TOP)
  return true
end
def.static("table", "table").OnLeaveFight = function()
  dlg:Hide()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, DlgPrelude.OnLeaveFight)
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self:ShowInfo()
end
def.method().Hide = function(self)
  if self.models then
    for _, v in pairs(self.models) do
      v:Destroy()
    end
  end
  self.models = nil
  self:DestroyPanel()
end
def.method().ShowInfo = function(self)
  self:SetActiveIcon()
  self:SetPassiveIcon()
  local skillNamePanel = self.m_panel:FindDirect("Group_Tween/Img_SkillName")
  local uiTex = skillNamePanel:GetComponent("UITexture")
  GUIUtils.FillIcon(uiTex, self.skillIconId)
end
def.method().SetActiveIcon = function(self)
  if self.m_panel == nil or self.m_panel:get_isnil() then
    return
  end
  local panel = self.m_panel:FindDirect("Group_Tween/Texture_1")
  local uiModel = panel:GetComponent("UIModel")
  uiModel:set_orthographic(true)
  if self.models[1] then
    local m = self.models[1]
    if m == nil or m.isnil then
      return
    end
    m.parent = nil
    m:SetLayer(ClientDef_Layer.UI_Model1)
    m.position = EC.Vector3.new(0, 0, -100)
    m.localRotation = Quaternion.Euler(EC.Vector3.new(0, 180, 0))
    m:GetComponentInChildren("Animation"):Play_3(ActionName.Stand, PlayMode.StopSameLayer)
    uiModel.modelGameObject = m
  end
end
def.method().SetPassiveIcon = function(self)
  if self.m_panel == nil or self.m_panel:get_isnil() then
    return
  end
  local panel = self.m_panel:FindDirect("Group_Tween/Texture_2")
  local passiveModel = panel:GetComponent("UIModel")
  passiveModel:set_orthographic(true)
  if self.models[2] then
    local m = self.models[2]
    if passiveModel == nil or passiveModel:get_isnil() or m == nil or m.isnil then
      return
    end
    m.parent = nil
    m:SetLayer(ClientDef_Layer.UI_Model1)
    m.position = EC.Vector3.new(0, 0, 100)
    m.localRotation = Quaternion.Euler(EC.Vector3.new(0, 180, 0))
    m:GetComponentInChildren("Animation"):Play_3(ActionName.Stand, PlayMode.StopSameLayer)
    passiveModel.modelGameObject = m
  end
end
DlgPrelude.Commit()
return DlgPrelude
