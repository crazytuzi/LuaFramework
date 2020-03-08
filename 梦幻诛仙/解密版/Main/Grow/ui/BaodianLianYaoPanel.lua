local Lplus = require("Lplus")
local BaodianBasePanel = require("Main.Grow.ui.BaodianBasePanel")
local BaodianUtils = require("Main.Grow.BaodianUtils")
local GUIUtils = require("GUI.GUIUtils")
local SkillPanel = require("Main.Skill.ui.SkillPanel")
local CommerceAndPitchPanel = require("Main.CommerceAndPitch.ui.CommercePitchPanel")
local CommerceAndPitchUtils = require("Main.CommerceAndPitch.CommercePitchUtils")
local BaodianLianYaoPanel = Lplus.Extend(BaodianBasePanel, "BaodianLianYaoPanel")
local def = BaodianLianYaoPanel.define
def.field("number").mCurItemId = 0
def.field("table").mItemCfg = nil
def.field("table").mItemIds = nil
def.field("table").mUIObjs = nil
def.field("userdata").mParent = nil
local instance
def.static("=>", BaodianLianYaoPanel).Instance = function()
  if instance == nil then
    instance = BaodianLianYaoPanel()
  end
  return instance
end
def.override("userdata").ShowPanel = function(self, parentPanel)
  if self:IsShow() then
    return
  end
  self.mParent = parentPanel
  GameUtil.AddGlobalLateTimer(0, true, function()
    self:CreatePanel(RESPATH.PREFAB_BAODIAN_LIANYAO, 2)
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
def.method().InitUI = function(self)
  self.mUIObjs = {}
  self.mUIObjs.ItemInfoView = self.m_panel:FindDirect("Group_BD_LianYao/Group_ItemInfo")
  self.mUIObjs.uiTexture = self.mUIObjs.ItemInfoView:FindDirect("Img_Icon/Texture")
  self.mUIObjs.nameLabel = self.mUIObjs.ItemInfoView:FindDirect("Img_Icon/Label_Name")
  self.mUIObjs.unLockLabel = self.mUIObjs.ItemInfoView:FindDirect("Img_Icon/Label_UnlockLevel")
  self.mUIObjs.effectLabel = self.mUIObjs.ItemInfoView:FindDirect("Label_Effect")
  self.mUIObjs.tipLabel = self.mUIObjs.ItemInfoView:FindDirect("Label_Tip")
  self:InitListView()
  self:UpdateRightView()
end
def.method().InitData = function(self)
  self.mItemCfg = BaodianUtils.GetLianYaoCfg()
  self.mItemIds = {}
  for k, v in pairs(self.mItemCfg) do
    table.insert(self.mItemIds, v.id)
  end
  self.mCurItemId = self.mItemIds[1]
end
def.method().UpdateData = function(self)
end
def.method().InitListView = function(self)
  local ListView = self.m_panel:FindDirect("Group_BD_LianYao/Scroll View/List")
  local listNum = #self.mItemIds
  local listItems = GUIUtils.InitUIList(ListView, listNum)
  for i = 1, listNum do
    local item = listItems[i]
    local iconId = BaodianUtils.GetCfgById(self.mItemIds[i], "lianyao").iconId
    local texture = item:FindDirect(string.format("Img_Icon_%d", i)):FindDirect(string.format("Texture_%d", i))
    local uitexture = texture:GetComponent("UITexture")
    GUIUtils.FillIcon(uitexture, iconId)
    texture.name = string.format("Texture_%d", self.mItemIds[i])
    self.m_msgHandler:Touch(item)
  end
  GUIUtils.Reposition(ListView, "UIList", 0)
  local descLabel = self.m_panel:FindDirect("Group_BD_LianYao/Label_LongTip")
  local desc = BaodianUtils.GetBaodianDescByName("GROW_LIANYAO_DESC")
  descLabel:GetComponent("UILabel").text = desc
end
def.method().UpdateRightView = function(self)
  local itemId = self.mCurItemId
  local itemcfg = BaodianUtils.GetCfgById(itemId, "lianyao")
  local itemName = itemcfg.name
  local iconId = itemcfg.iconId
  local itemDesc = itemcfg.desc
  local itemEffect = itemcfg.effect
  local openLevel = itemcfg.openLevel
  GUIUtils.FillIcon(self.mUIObjs.uiTexture:GetComponent("UITexture"), iconId)
  self.mUIObjs.nameLabel:GetComponent("UILabel").text = itemName
  self.mUIObjs.unLockLabel:GetComponent("UILabel").text = tostring(openLevel)
  self.mUIObjs.effectLabel:GetComponent("UILabel").text = itemEffect
  self.mUIObjs.tipLabel:GetComponent("UILabel").text = itemDesc
end
def.method("number").SetCurItemId = function(self, id)
  self.mCurItemId = id
end
def.method("string").onClick = function(self, id)
  if string.find(id, "Texture_") then
    local strs = string.split(id, "_")
    local itemId = tonumber(strs[2])
    self:SetCurItemId(itemId)
    self:UpdateRightView()
  elseif id == "Btn_GetLianYao1" then
    local hp = require("Main.Hero.HeroModule").Instance():GetHeroProp()
    local heroLevel = hp.level
    local SkillUtil = require("Main.Skill.LivingSkillUtility")
    local openLevel = SkillUtil.GetLivingSkillConst("OPEN_LEVEL")
    if heroLevel < openLevel then
      Toast(string.format(textRes.Grow[10], openLevel))
      return
    end
    SkillPanel.Instance():ShowPanel(3)
  elseif id == "Btn_GetLianYao2" then
    local hp = require("Main.Hero.HeroModule").Instance():GetHeroProp()
    local heroLevel = hp.level
    local openLevel = CommerceAndPitchUtils.GetPitchOpenLevel()
    if heroLevel < openLevel then
      Toast(string.format(textRes.Grow[11], openLevel))
      return
    end
    CommerceAndPitchPanel.ShowCommercePitchPanel(2)
  end
end
def.override().ReleaseUI = function(self)
  if self.mUIObjs then
    for k, v in pairs(self.mUIObjs) do
      k = nil
    end
    self.mUIObjs = nil
  end
end
def.override().OnDestroy = function(self)
  self:ReleaseUI()
  self.mCurItemId = 0
  self.mItemCfg = nil
  self.mItemIds = nil
  self.mParent = nil
end
BaodianLianYaoPanel.Commit()
return BaodianLianYaoPanel
