local Lplus = require("Lplus")
local BaodianBasePanel = require("Main.Grow.ui.BaodianBasePanel")
local BaodianUtils = require("Main.Grow.BaodianUtils")
local GUIUtils = require("GUI.GUIUtils")
local CharacterPanel = require("Main.Hero.ui.HeroPropPanel")
local BaodianWingsPanel = Lplus.Extend(BaodianBasePanel, "BaodianWingsPanel")
local def = BaodianWingsPanel.define
def.field("number").mNeedLevel = 0
def.field("table").mWingviewItemList = nil
def.field("userdata").mParent = nil
local instance
def.static("=>", BaodianWingsPanel).Instance = function()
  if instance == nil then
    instance = BaodianWingsPanel()
  end
  return instance
end
def.override("userdata").ShowPanel = function(self, parentPanel)
  if self:IsShow() then
    return
  end
  self.mParent = parentPanel
  GameUtil.AddGlobalLateTimer(0, true, function()
    self:CreatePanel(RESPATH.PREFAB_BAODIAN_WING, 2)
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
  local attrLabel = self.m_panel:FindDirect("Lead_BD_Wing/Group_Wing_Attribute/Group_Tips/Label_Tips")
  local upLabel = self.m_panel:FindDirect("Lead_BD_Wing/Group_Wing_Upgrade/Group_Tips/Label_Tips")
  local degreeLabel = self.m_panel:FindDirect("Lead_BD_Wing/Group_Wing_Degree/Group_Tips/Label_Tips")
  local appearLabel = self.m_panel:FindDirect("Lead_BD_Wing/Group_Wing_Appearance/Group_Tips/Label_Tips")
  local attrDesc = BaodianUtils.GetBaodianDescByName("GROW_WING_ATT_DESC")
  local upDesc = BaodianUtils.GetBaodianDescByName("GROW_WING_LEVELUP_DESC")
  local degreeDesc = BaodianUtils.GetBaodianDescByName("GROW_WING_SHENGJIE_DESC")
  local appearDesc = BaodianUtils.GetBaodianDescByName("GROW_WING_SHOW_DESC")
  attrLabel:GetComponent("UILabel").text = attrDesc
  upLabel:GetComponent("UILabel").text = upDesc
  degreeLabel:GetComponent("UILabel").text = degreeDesc
  appearLabel:GetComponent("UILabel").text = appearDesc
end
def.override().ReleaseUI = function(self)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_GetWing" then
    require("Main.Wing.WingInterface").OpenWingPanel(2)
  elseif id == "Btn_SX" then
    require("Main.Wing.WingInterface").OpenWingPanel(1)
  elseif id == "Btn_UgpradeWing" then
    require("Main.Wing.WingInterface").OpenWingPanel(1)
  elseif id == "Btn_Degree" then
    require("Main.Wing.WingInterface").OpenWingPanel(1)
  elseif id == "Btn_Get_Appearance" then
    require("Main.Wing.WingInterface").OpenWingPanel(2)
  elseif id == "Btn_Set_Appearance" then
    require("Main.Wing.WingInterface").OpenWingPanel(2)
  end
end
def.method("=>", "boolean").IsOpenWings = function(self)
  local HeroLevel = require("Main.Hero.HeroModule").Instance():GetHeroProp().level
  if HeroLevel < self.mNeedLevel then
    return false
  end
  return true
end
def.override().OnDestroy = function(self)
  self:ReleaseUI()
  self.mWingviewItemList = nil
  self.mParent = nil
end
BaodianWingsPanel.Commit()
return BaodianWingsPanel
