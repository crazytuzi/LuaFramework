local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetHuaShengPreviewPanel = Lplus.Extend(ECPanelBase, "PetHuaShengPreviewPanel")
local def = PetHuaShengPreviewPanel.define
local EC = require("Types.Vector3")
local Vector3 = EC.Vector3
local PetUtility = require("Main.Pet.PetUtility")
local PetData = require("Main.Pet.data.PetData")
local PetSkillMgr = require("Main.Pet.mgr.PetSkillMgr")
local GUIUtils = require("GUI.GUIUtils")
local PetModule = require("Main.Pet.PetModule")
def.const("number").SKILL_CELL_NUM = 20
def.field(PetData).mainPet = nil
def.field(PetData).subPet = nil
def.field("table").skillList = nil
def.field("table").uiObjs = nil
local instance
def.static("=>", PetHuaShengPreviewPanel).Instance = function()
  if instance == nil then
    instance = PetHuaShengPreviewPanel()
  end
  return instance
end
def.method(PetData, PetData).ShowPanel = function(self, mainPet, subPet)
  self.mainPet = mainPet
  self.subPet = subPet
  if self:IsShow() then
    self:UpdateUI()
    return
  end
  self:CreatePanel(RESPATH.PREFAB_PET_HUA_SHENG_PREVIEW_PANEL_RES, _G.GUILEVEL.DEPENDEND)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self.skillList = {}
  self:InitUI()
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.skillList = nil
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  elseif string.sub(id, 1, #"Img_BgSkill_") == "Img_BgSkill_" then
    local index = tonumber(string.sub(id, #"Img_BgSkill_" + 1, -1))
    self:OnPetSkillIconClick(index)
  end
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg01 = self.m_panel:FindDirect("Img_Bg01")
  self.uiObjs.Group_PetInfo = self.uiObjs.Img_Bg01:FindDirect("Group_PetInfo")
  self.uiObjs.Group_BgSkillGroup = self.uiObjs.Img_Bg01:FindDirect("Group_BgSkillGroup")
  self.uiObjs.List = self.uiObjs.Group_BgSkillGroup:FindDirect("Scroll View/List")
  self.uiObjs.Group_Tips = self.uiObjs.Img_Bg01:FindDirect("Group_Tips")
  self.uiObjs.Label_Tips = self.uiObjs.Group_Tips:FindDirect("Label_Tips")
end
def.method().UpdateUI = function(self)
  local pet = self.mainPet
  local iconId = pet:GetHeadIconId()
  local Img_IconPe = GUIUtils.FindDirect(self.uiObjs.Group_PetInfo, "Img_BgPet/Img_IconPe")
  GUIUtils.SetTexture(Img_IconPe, iconId)
  local Label_PetType = GUIUtils.FindDirect(self.uiObjs.Group_PetInfo, "Label_PetType")
  local petType = pet:GetPetCfgData().type
  GUIUtils.SetText(Label_PetType, textRes.Pet.Type[petType])
  local Label_PetLv = GUIUtils.FindDirect(self.uiObjs.Group_PetInfo, "Label_PetLv")
  local text = string.format(textRes.Common[3], pet.level)
  GUIUtils.SetText(Label_PetLv, text)
  local Label_PetName = GUIUtils.FindDirect(self.uiObjs.Group_PetInfo, "Label_PetName")
  GUIUtils.SetText(Label_PetName, pet.name)
  self:UpdateSkillList()
  self:TouchGameObject(self.m_panel, self.m_parent)
  local tipId = PetModule.PET_HUA_SHENG_PREVIEW_TIP_ID
  local content = require("Main.Common.TipsHelper").GetHoverTip(tipId) or ""
  GUIUtils.SetText(self.uiObjs.Label_Tips, content)
end
def.method().UpdateSkillList = function(self)
  local skillList = PetSkillMgr.Instance():GetHuaShengPreviewSkillList(self.mainPet, self.subPet)
  self.skillList = skillList
  local ListObj = self.uiObjs.List
  local uiList = ListObj:GetComponent("UIList")
  if uiList then
    uiList:Resize()
  end
  for i = 1, PetHuaShengPreviewPanel.SKILL_CELL_NUM do
    local skill = skillList[i]
    local Img_BgSkill = ListObj:FindDirect("Img_BgSkill_" .. i)
    if Img_BgSkill then
      local Img_HS_IconSkill = Img_BgSkill:FindDirect("Img_HS_IconSkill01_01_" .. i)
      local Img_HS_SignRemember = Img_BgSkill:FindDirect("Img_HS_Sign_" .. i)
      local Img_HS_SignAmulet = Img_BgSkill:FindDirect("Img_HS_Sign0_" .. i)
      GUIUtils.SetTexture(Img_HS_IconSkill, 0)
      GUIUtils.SetActive(Img_HS_SignRemember, false)
      GUIUtils.SetActive(Img_HS_SignAmulet, false)
      PetUtility.SetOriginPetSkillBg(Img_BgSkill, "Img_SkillFg")
      if skill then
        if 0 < skill.id then
          local skillCfg = PetUtility.Instance():GetPetSkillCfg(skill.id)
          GUIUtils.SetTexture(Img_HS_IconSkill, skillCfg.iconId)
          GUIUtils.SetActive(Img_HS_SignRemember, skill.isRemembered == true)
          GUIUtils.SetActive(Img_HS_SignAmulet, skill.belongAmulet == true)
          PetUtility.SetPetSkillBgColor(Img_BgSkill, skill.id)
        else
          local fakeSkillId = constant.CPetHuaShengYuanBaoMakeUpViceConsts.VICE_PET_SKILL_ID
          local skillCfg = PetUtility.Instance():GetPetSkillCfg(fakeSkillId)
          GUIUtils.SetTexture(Img_HS_IconSkill, skillCfg.iconId)
          PetUtility.SetPetSkillBgColor(Img_BgSkill, fakeSkillId)
        end
      end
    end
  end
end
def.method("number").OnPetSkillIconClick = function(self, index)
  local skill = self.skillList[index]
  if skill == nil then
    return
  end
  local skillId, level = skill.id, self.mainPet.level
  if skillId < 0 then
    skillId = constant.CPetHuaShengYuanBaoMakeUpViceConsts.VICE_PET_SKILL_ID
  end
  local anchorObj = self.uiObjs.Group_BgSkillGroup
  local hPrefer = 0
  PetUtility.ShowPetSkillTipEx(skillId, level, anchorObj, hPrefer, context)
end
return PetHuaShengPreviewPanel.Commit()
