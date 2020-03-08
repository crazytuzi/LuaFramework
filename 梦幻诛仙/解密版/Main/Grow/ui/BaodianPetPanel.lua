local Lplus = require("Lplus")
local BaodianBasePanel = require("Main.Grow.ui.BaodianBasePanel")
local BaodianUtils = require("Main.Grow.BaodianUtils")
local GUIUtils = require("GUI.GUIUtils")
local PetPanel = require("Main.Pet.ui.PetPanel")
local BaodianPetPanel = Lplus.Extend(BaodianBasePanel, "BaodianPetPanel")
local def = BaodianPetPanel.define
def.field("userdata").mParent = nil
local instance
def.static("=>", BaodianPetPanel).Instance = function()
  if instance == nil then
    instance = BaodianPetPanel()
  end
  return instance
end
def.override("userdata").ShowPanel = function(self, parentPanel)
  if self:IsShow() then
    return
  end
  self.mParent = parentPanel
  GameUtil.AddGlobalLateTimer(0, true, function()
    self:CreatePanel(RESPATH.PREFAB_BAODIAN_PET, 2)
  end)
end
def.override().OnCreate = function(self)
  if self.mParent == nil or self.mParent.isnil == true then
    self:DestroyPanel()
    return
  end
  self:InitData()
  self:InitUI()
end
def.method().InitData = function(self)
end
def.method().InitUI = function(self)
  local fsLabel = self.m_panel:FindDirect("Lead_BD_Pet/Group_Pet_FS/Group_Tips/Label_Tips")
  local hsLabel = self.m_panel:FindDirect("Lead_BD_Pet/Group_Pet_HS/Group_Tips/Label_Tips")
  local ccLabel = self.m_panel:FindDirect("Lead_BD_Pet/Group_Pet_CC/Group_Tips/Label_Tips")
  local sxLabel = self.m_panel:FindDirect("Lead_BD_Pet/Group_Pet_SX/Group_Tips/Label_Tips")
  local fsDesc = BaodianUtils.GetBaodianDescByName("GROW_PET_FANSHENG_DESC")
  local hsDesc = BaodianUtils.GetBaodianDescByName("GROW_PET_HUASHENG_DESC")
  local ccDesc = BaodianUtils.GetBaodianDescByName("GROW_PET_GROWUP_DESC")
  local sxDesc = BaodianUtils.GetBaodianDescByName("GROW_PET_ATT_DESC")
  fsLabel:GetComponent("UILabel").text = fsDesc
  hsLabel:GetComponent("UILabel").text = hsDesc
  ccLabel:GetComponent("UILabel").text = ccDesc
  sxLabel:GetComponent("UILabel").text = sxDesc
end
def.method("string").onClick = function(self, id)
  if id == "Btn_FS" then
    PetPanel.Instance():ShowPanelEx(PetPanel.NodeId.FanShengNode)
    GUIUtils.AddLightEffectToPanel("panel_pet/Img_Bg0/FS/Img_FS_Bg0/Img_FS_Skill/Btn_FS_Use", GUIUtils.Light.Square)
  elseif id == "Btn_HS" then
    PetPanel.Instance():ShowPanelEx(PetPanel.NodeId.HuaShengNode)
    GUIUtils.AddLightEffectToPanel("panel_pet/Img_Bg0/HS/Img_HS_BgHS/Btn_HS_Make", GUIUtils.Light.Square)
  elseif id == "Btn_JN" then
    PetPanel.Instance():ShowPanelEx(PetPanel.NodeId.SkillNode)
    GUIUtils.AddLightEffectToPanel("panel_pet/Img_Bg0/JN/Img_JN_Bg0/Btn_JN_Use", GUIUtils.Light.Square)
  elseif id == "Btn_LG" then
    PetPanel.Instance():ShowPanelEx(PetPanel.NodeId.SkillNode)
    GUIUtils.AddLightEffectToPanel("panel_pet/Img_Bg0/JN/Img_JN_Bg0/Btn_JN_Bone", GUIUtils.Light.Square)
  elseif id == "Btn_TJ" then
    PetPanel.Instance():OnTuJianButtonClick()
  elseif id == "Btn_SX" then
    PetPanel.Instance():ShowPanelEx(PetPanel.NodeId.BasicNode)
  end
end
def.override().ReleaseUI = function(self)
end
def.override().OnDestroy = function(self)
  self:ReleaseUI()
  self.mParent = nil
end
BaodianPetPanel.Commit()
return BaodianPetPanel
