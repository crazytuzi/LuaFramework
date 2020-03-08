local Lplus = require("Lplus")
local GUIUtils = require("GUI.GUIUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local FabaoUtils = require("Main.Fabao.FabaoUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local SkillUtility = require("Main.Skill.SkillUtility")
local FabaoCommonPanel = Lplus.Extend(ECPanelBase, "FabaoCommonPanel")
local def = FabaoCommonPanel.define
def.const("table").TypeDefine = {
  FabaoCompose = 1,
  FabaoLevelUp = 2,
  FabaoStarUp = 3
}
def.field("number").m_CurType = 0
def.field("table").m_Params = nil
def.field("table").m_UIObjs = nil
def.field("number").m_SelectSkillId = 0
local instance
def.static("=>", FabaoCommonPanel).Instance = function()
  if nil == instance then
    instance = FabaoCommonPanel()
    instance.m_CurType = 0
    instance.m_Params = nil
    instance.m_UIObjs = nil
    instance.m_SelectSkillId = 0
  end
  return instance
end
def.method("number", "table").ShowPanel = function(self, targetType, params)
  if self:IsShow() then
    return
  end
  if not self:CheckType(targetType) then
    return
  end
  self.m_CurType = targetType
  self.m_Params = params
  self.m_UIObjs = nil
  self.m_SelectSkillId = 0
  self:CreatePanel(RESPATH.PREFAB_FABAO_COMMON_PANEL, 2)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:Update()
end
def.method().InitUI = function(self)
  if nil == self.m_UIObjs then
    self.m_UIObjs = {}
  end
  self.m_UIObjs[FabaoCommonPanel.TypeDefine.FabaoCompose] = self.m_panel:FindDirect("Img_Bg0/Group_FabaoGet")
  self.m_UIObjs[FabaoCommonPanel.TypeDefine.FabaoLevelUp] = self.m_panel:FindDirect("Img_Bg0/Group_FabaoUpdate")
  self.m_UIObjs[FabaoCommonPanel.TypeDefine.FabaoStarUp] = self.m_panel:FindDirect("Img_Bg0/Group_FabaoUpdateStar")
end
def.method("number", "=>", "boolean").CheckType = function(self, targetType)
  for k, v in pairs(FabaoCommonPanel.TypeDefine) do
    if v == targetType then
      return true
    end
  end
  return false
end
def.method().Update = function(self)
  for k, v in pairs(self.m_UIObjs) do
    if k == self.m_CurType then
      self.m_UIObjs[k]:SetActive(true)
    else
      self.m_UIObjs[k]:SetActive(false)
    end
  end
  if self.m_CurType == FabaoCommonPanel.TypeDefine.FabaoCompose then
    self:UpdateComposeUI()
  elseif self.m_CurType == FabaoCommonPanel.TypeDefine.FabaoLevelUp then
    self:UpdateLevelUpUI()
  elseif self.m_CurType == FabaoCommonPanel.TypeDefine.FabaoStarUp then
    self:UpdateStarUpUI()
  end
end
def.method().UpdateStarUpUI = function(self)
  local starUpInfo = self.m_Params.StarUpInfo
  if nil == starUpInfo then
    return
  end
  local skillId1 = starUpInfo.skillId1
  local skillId2 = starUpInfo.skillId2
  local preFabaoId = starUpInfo.fabaoId1
  local afterFabaoId = starUpInfo.fabaoId2
  local fabaoLevel = starUpInfo.fabaoLevel
  local preFabaoBase = ItemUtils.GetFabaoItem(preFabaoId)
  local afterFabaoBase = ItemUtils.GetFabaoItem(afterFabaoId)
  local preProCfg = FabaoUtils.GetFabaoAttrTypeAndValue(preFabaoBase.attrId, fabaoLevel)
  local afterProCfg = FabaoUtils.GetFabaoAttrTypeAndValue(afterFabaoBase.attrId, fabaoLevel)
  local preFabaoItemBase = ItemUtils.GetItemBase(preFabaoId)
  local afterFabaoitemBase = ItemUtils.GetItemBase(afterFabaoId)
  local preNameLabel = self.m_UIObjs[self.m_CurType]:FindDirect("Label_NamePre")
  local afterNameLabel = self.m_UIObjs[self.m_CurType]:FindDirect("Label_NameAfter")
  preNameLabel:GetComponent("UILabel"):set_text(preFabaoItemBase.name)
  afterNameLabel:GetComponent("UILabel"):set_text(afterFabaoitemBase.name)
  local shuxingLabel = self.m_UIObjs[self.m_CurType]:FindDirect("Label_Shuxing")
  local preAttrLabel = {}
  local afterAttrLabel = {}
  preAttrLabel[1] = self.m_UIObjs[self.m_CurType]:FindDirect("Label_Shuxing/Label_PreQixue")
  afterAttrLabel[1] = self.m_UIObjs[self.m_CurType]:FindDirect("Label_Shuxing/Label_AfterQixue")
  preAttrLabel[2] = self.m_UIObjs[self.m_CurType]:FindDirect("Label_Shuxing/Label_Pre_2")
  afterAttrLabel[2] = self.m_UIObjs[self.m_CurType]:FindDirect("Label_Shuxing/Label_After_2")
  preAttrLabel[3] = self.m_UIObjs[self.m_CurType]:FindDirect("Label_Shuxing/Label_Pre_3")
  afterAttrLabel[3] = self.m_UIObjs[self.m_CurType]:FindDirect("Label_Shuxing/Label_After_3")
  for i = 1, 3 do
    local pro = preProCfg[i]
    if pro and pro.proType and 0 ~= pro.proType then
      preAttrLabel[i]:SetActive(true)
      local attrName = FabaoUtils.GetFabaoProName(pro.proType)
      preAttrLabel[i]:GetComponent("UILabel"):set_text(string.format("%s +%d", attrName, pro.proValue))
    else
      preAttrLabel[i]:SetActive(false)
    end
    pro = afterProCfg[i]
    if pro and pro.proType and 0 ~= pro.proType then
      afterAttrLabel[i]:SetActive(true)
      local attrName = FabaoUtils.GetFabaoProName(pro.proType)
      afterAttrLabel[i]:GetComponent("UILabel"):set_text(string.format("%s +%d", attrName, pro.proValue))
    else
      afterAttrLabel[i]:SetActive(false)
    end
  end
  local skillCfg1 = SkillUtility.GetSkillCfg(skillId1)
  local skillCfg2 = SkillUtility.GetSkillCfg(skillId2)
  local skillIcon1 = self.m_UIObjs[self.m_CurType]:FindDirect("Img_Teji_1/Img_TejiIcon")
  local skillNameLabel1 = self.m_UIObjs[self.m_CurType]:FindDirect("Img_Teji_1/Label_SkillName")
  local skillIcon2 = self.m_UIObjs[self.m_CurType]:FindDirect("Img_Teji_2/Img_TejiIcon")
  local skillNameLabel2 = self.m_UIObjs[self.m_CurType]:FindDirect("Img_Teji_2/Label_SkillName")
  if skillCfg1 then
    GUIUtils.FillIcon(skillIcon1:GetComponent("UITexture"), skillCfg1.iconId)
    skillNameLabel1:GetComponent("UILabel"):set_text(skillCfg1.name)
  end
  if skillCfg2 then
    GUIUtils.FillIcon(skillIcon2:GetComponent("UITexture"), skillCfg2.iconId)
    skillNameLabel2:GetComponent("UILabel"):set_text(skillCfg2.name)
  end
end
def.method().UpdateLevelUpUI = function(self)
  local levelUpInfo = self.m_Params.LevelUpInfo
  if nil == levelUpInfo then
    return
  end
  local fabaoId = levelUpInfo.fabaoId
  local fabaoOldLevel = levelUpInfo.oldLevel
  local fabaoCurLevel = levelUpInfo.curLevel
  local nameLabel = self.m_UIObjs[self.m_CurType]:FindDirect("Label_Name")
  local preLevelLabel = self.m_UIObjs[self.m_CurType]:FindDirect("Label_Dengji/Label_PreLevel")
  local afterLevelLabel = self.m_UIObjs[self.m_CurType]:FindDirect("Label_Dengji/Label_AfterLevel")
  local preAttrLabel = {}
  local afterAttrLabel = {}
  preAttrLabel[1] = self.m_UIObjs[self.m_CurType]:FindDirect("Label_Shuxing/Label_PreShuxing")
  afterAttrLabel[1] = self.m_UIObjs[self.m_CurType]:FindDirect("Label_Shuxing/Label_AfterQixue")
  preAttrLabel[2] = self.m_UIObjs[self.m_CurType]:FindDirect("Label_Shuxing/Label_Pre_2")
  afterAttrLabel[2] = self.m_UIObjs[self.m_CurType]:FindDirect("Label_Shuxing/Label_After_2")
  preAttrLabel[3] = self.m_UIObjs[self.m_CurType]:FindDirect("Label_Shuxing/Label_Pre_3")
  afterAttrLabel[3] = self.m_UIObjs[self.m_CurType]:FindDirect("Label_Shuxing/Label_After_3")
  local fabaoName = ItemUtils.GetItemBase(fabaoId).name
  nameLabel:GetComponent("UILabel"):set_text(fabaoName)
  preLevelLabel:GetComponent("UILabel"):set_text(fabaoOldLevel)
  afterLevelLabel:GetComponent("UILabel"):set_text(fabaoCurLevel)
  local fabaoBase = ItemUtils.GetFabaoItem(fabaoId)
  local attrId = fabaoBase.attrId
  local preProCfg = FabaoUtils.GetFabaoAttrTypeAndValue(attrId, fabaoOldLevel)
  local curProCfg = FabaoUtils.GetFabaoAttrTypeAndValue(attrId, fabaoCurLevel)
  for i = 1, 3 do
    local pro = preProCfg[i]
    if pro and pro.proType and 0 ~= pro.proType then
      preAttrLabel[i]:SetActive(true)
      local attrName = FabaoUtils.GetFabaoProName(pro.proType)
      local attrStr = string.format("%s +%d", attrName, pro.proValue)
      preAttrLabel[i]:GetComponent("UILabel"):set_text(attrStr)
    else
      preAttrLabel[i]:SetActive(false)
    end
    pro = curProCfg[i]
    if pro and pro.proType and 0 ~= pro.proType then
      afterAttrLabel[i]:SetActive(true)
      local attrName = FabaoUtils.GetFabaoProName(pro.proType)
      local attrStr = string.format("%s +%d", attrName, pro.proValue)
      afterAttrLabel[i]:GetComponent("UILabel"):set_text(attrStr)
    else
      afterAttrLabel[i]:SetActive(false)
    end
  end
end
def.method().UpdateComposeUI = function(self)
  local composeInfo = self.m_Params.ComposeInfo
  if nil == composeInfo then
    return
  end
  warn("UpdateComposeUI ", self.m_CurType, self.m_UIObjs[self.m_CurType])
  local fabaoId = composeInfo.fabaoId
  local fabaoLevel = composeInfo.fabaoLevel
  local fabaoSkillId = composeInfo.fabaoSkillId
  local fabaoBase = ItemUtils.GetFabaoItem(fabaoId)
  local fabaoItemBase = ItemUtils.GetItemBase(fabaoId)
  local proCfg = FabaoUtils.GetFabaoAttrTypeAndValue(fabaoBase.attrId, fabaoLevel)
  local fabaoName = fabaoItemBase.name
  local skillCfg = SkillUtility.GetSkillCfg(fabaoSkillId)
  local nameLabel = self.m_UIObjs[self.m_CurType]:FindDirect("Label_Name")
  local skillNameLabel = self.m_UIObjs[self.m_CurType]:FindDirect("Label_Skill/Label_SkillName")
  local attrLabel = self.m_UIObjs[self.m_CurType]:FindDirect("Label_Shuxing/Label_ShuxingNumber")
  nameLabel:GetComponent("UILabel"):set_text(fabaoName)
  if proCfg[1] then
    attrLabel:SetActive(true)
    local attrName = FabaoUtils.GetFabaoProName(proCfg[1].proType)
    local attrStr = string.format("%s +%d", attrName, proCfg[1].proValue)
    attrLabel:GetComponent("UILabel"):set_text(attrStr)
  else
    attrLabel:SetActive(false)
  end
  if skillCfg then
    skillNameLabel:SetActive(true)
    local skillName = skillCfg.name
    skillNameLabel:GetComponent("UILabel"):set_text(skillName)
  else
    skillNameLabel:SetActive(false)
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if "Btn_Confirm" == id then
    self:OnClickComfirmBtn(clickObj)
  elseif string.find(id, "Img_Teji_") then
    local strs = string.split(id, "_")
    local index = tonumber(strs[3])
    self:OnClickSelectSkill(clickObj, index)
  end
end
def.method("userdata", "number").OnClickSelectSkill = function(self, clickObj, index)
  if self.m_CurType ~= FabaoCommonPanel.TypeDefine.FabaoStarUp then
    return
  end
  local starUpInfo = self.m_Params.StarUpInfo
  if starUpInfo == nil then
    return
  end
  if 1 == index then
    self.m_SelectSkillId = starUpInfo.skillId1
  elseif 2 == index then
    self.m_SelectSkillId = starUpInfo.skillId2
  end
  if self.m_SelectSkillId and 0 ~= self.m_SelectSkillId then
    require("Main.Skill.SkillTipMgr").Instance():ShowTipByIdEx(self.m_SelectSkillId, clickObj, 0)
  end
end
def.method("userdata").OnClickComfirmBtn = function(self, clickObj)
  if self.m_CurType == FabaoCommonPanel.TypeDefine.FabaoCompose or self.m_CurType == FabaoCommonPanel.TypeDefine.FabaoLevelUp then
    self:DestroyPanel()
  else
    local starUpInfo = self.m_Params.StarUpInfo
    if nil == starUpInfo then
      self:DestroyPanel()
    end
    if nil == self.m_SelectSkillId then
      self:DestroyPanel()
    end
    if 0 == self.m_SelectSkillId then
      Toast(textRes.Fabao[87])
      return
    else
      local FabaoModule = require("Main.Fabao.FabaoModule")
      FabaoModule.RequestChoiceRankSkill(starUpInfo.equiped, starUpInfo.fabaouuid, self.m_SelectSkillId)
      self:DestroyPanel()
    end
  end
end
def.override().OnDestroy = function(self)
  self.m_CurType = 0
  self.m_Params = nil
  self.m_UIObjs = nil
  self.m_SelectSkillId = 0
end
FabaoCommonPanel.Commit()
return FabaoCommonPanel
