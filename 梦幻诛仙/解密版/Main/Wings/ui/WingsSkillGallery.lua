local EC = require("Types.Vector3")
local Vector = require("Types.Vector")
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local WingsUtility = require("Main.Wings.WingsUtility")
local SkillUtility = require("Main.Skill.SkillUtility")
local WingsSkillGallery = Lplus.Extend(ECPanelBase, "WingsSkillGallery")
local def = WingsSkillGallery.define
def.field("table").uiNodes = nil
def.field("table").data = nil
def.field("number").selected = 1
local instance
def.static("=>", WingsSkillGallery).Instance = function()
  if instance == nil then
    instance = WingsSkillGallery()
    instance:GetData()
  end
  return instance
end
def.method().GetData = function(self)
  self.data = WingsUtility.GetAllWingsSkills()
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  if not self.data then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_WING_SKILL_GALLERY_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self.selected = 1
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow == false then
    return
  end
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self:ClearUp()
  self.selected = 1
end
def.method().ClearUp = function(self)
end
def.method().InitUI = function(self)
  self.uiNodes = {}
  self.uiNodes.imgBg = self.m_panel:FindDirect("Img_Bg")
  self.uiNodes.grpMainSkills = self.uiNodes.imgBg:FindDirect("Group_Left")
  self.uiNodes.grpSubSkills = self.uiNodes.imgBg:FindDirect("Group_Right/Group_SubSkills")
  self.uiNodes.labelDesc = self.uiNodes.imgBg:FindDirect("Group_Right/Group_SkillDescrib/Label_TIps")
end
def.method().UpdateUI = function(self)
  self:UpdateMainSkillUI()
  self:UpdateSubSkillUI()
  self:UpdateSkillDesc()
end
def.method().UpdateMainSkillUI = function(self)
  local skillList = self.data.mainSkillList
  local listMain = self.uiNodes.grpMainSkills:FindDirect("Scroll View/List_Zhu")
  local uiList = listMain:GetComponent("UIList")
  uiList.itemCount = #skillList
  uiList:Resize()
  uiList:Reposition()
  for i = 1, #skillList do
    local item = listMain:FindDirect("Group_SkillZhu_" .. i)
    local mainSkillId = skillList[i]
    local mainSkillCfg = SkillUtility.GetPassiveSkillCfg(mainSkillId)
    if not mainSkillCfg then
      return
    end
    local uiTexture = item:FindDirect(string.format("Img_BgSkill_%d/Texture_%d", i, i)):GetComponent("UITexture")
    GUIUtils.FillIcon(uiTexture, mainSkillCfg.iconId)
    item:FindDirect(string.format("Img_BgSkill_%d/Label_%d", i, i)):SetActive(false)
    local uiLabel = item:FindDirect(string.format("Label_%d", i, i)):GetComponent("UILabel")
    uiLabel:set_text(mainSkillCfg.name)
  end
  self.m_msgHandler:Touch(listMain)
  if #skillList >= 1 then
    local firstItem = listMain:FindDirect("Group_SkillZhu_1")
    if not firstItem then
      return
    end
    local uiToggle = firstItem:GetComponent("UIToggle")
    if not uiToggle then
      return
    end
    uiToggle.value = true
  end
end
def.method().UpdateSubSkillUI = function(self)
  local skillList = self.data.subSkillList[self.selected]
  if not skillList then
    return
  end
  local listSub = self.uiNodes.grpSubSkills:FindDirect("Scroll View/List_Fu")
  local uiList = listSub:GetComponent("UIList")
  uiList.itemCount = #skillList
  uiList:Resize()
  uiList:Reposition()
  for i = 1, #skillList do
    local item = listSub:FindDirect("Img_BgSkill_" .. i)
    local subSkillId = skillList[i]
    local subSkillCfg = SkillUtility.GetPassiveSkillCfg(subSkillId)
    local uiTextureSubSkill = item:FindDirect("Texture_" .. i):GetComponent("UITexture")
    GUIUtils.FillIcon(uiTextureSubSkill, subSkillCfg.iconId)
    item:FindDirect("Label_" .. i):SetActive(false)
    item:GetComponent("UIToggle").value = false
  end
  self.m_msgHandler:Touch(listSub)
end
def.method().UpdateSkillDesc = function(self)
  local mainSkillId = self.data.mainSkillList[self.selected]
  if not mainSkillId or mainSkillId == 0 then
    return
  end
  local skillCfg = SkillUtility.GetPassiveSkillCfg(mainSkillId)
  local uiLabel = self.uiNodes.labelDesc:GetComponent("UILabel")
  uiLabel:set_text(skillCfg.description)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  elseif string.find(id, "Group_SkillZhu_") then
    local index = string.sub(id, 16)
    self:OnMainSkillCellClicked(tonumber(index))
  elseif string.find(id, "Img_BgSkill_") then
    local index = string.sub(id, 13)
    self:OnSubSkillCellClicked(tonumber(index))
  end
end
def.method("number").OnMainSkillCellClicked = function(self, index)
  if self.selected == index then
    return
  end
  self.selected = index
  self:UpdateSubSkillUI()
  self:UpdateSkillDesc()
end
def.method("number").OnSubSkillCellClicked = function(self, index)
  local skillList = self.data.subSkillList[self.selected]
  if not skillList then
    return
  end
  local skillId = skillList[index]
  if not skillId then
    return
  end
  local cell = self.uiNodes.grpSubSkills:FindDirect("Scroll View/List_Fu/Img_BgSkill_" .. index)
  require("Main.Skill.SkillTipMgr").Instance():ShowTipByIdEx(skillId, cell, 0)
end
return WingsSkillGallery.Commit()
