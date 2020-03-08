local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgPetSkill = Lplus.Extend(ECPanelBase, "DlgPetSkill")
local def = DlgPetSkill.define
local dlg
local fightMgr = Lplus.ForwardDeclare("FightMgr")
local FightUnit = Lplus.ForwardDeclare("FightUnit")
local GameUnitType = require("consts/mzm/gsp/common/confbean/GameUnitType")
local GUIUtils = require("GUI.GUIUtils")
def.field("table").skills = nil
def.field(FightUnit).unit = nil
def.field("boolean").isAuto = false
def.field("number").selectedSkillId = 0
def.static("=>", DlgPetSkill).Instance = function()
  if dlg == nil then
    dlg = DlgPetSkill()
  end
  return dlg
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.CLOSE_SECOND_LEVEL_UI, DlgPetSkill.OnCloseSecondLevelUI)
end
def.method("number", "=>", "boolean").ShowDlg = function(self, skillTypes)
  if self.m_panel then
    self:DestroyPanel()
  end
  self:SetUnitSkills()
  if self.skills == nil or #self.skills == 0 then
    return false
  end
  self:CreatePanel(RESPATH.DLG_FIGHT_PET_SKILL, 1)
  return true
end
def.static("table", "table").OnCloseSecondLevelUI = function()
  dlg:Hide()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.CLOSE_SECOND_LEVEL_UI, DlgPetSkill.OnCloseSecondLevelUI)
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if string.find(id, "Img_BgIcon") then
    local index = tonumber(string.sub(id, string.len("Img_BgIcon") + 1))
    if self.isAuto then
      Debug.LogWarning(string.format("select pet skill, index=%d, unit_type=%d(%s), skill_id=%d ", index, self.unit.fightUnitType, tostring(self.unit.roleId), self.skills[index].id))
      if self.unit.fightUnitType == GameUnitType.PET then
        fightMgr.Instance():SetPetAutoSkill(self.unit.roleId, self.skills[index].id)
      elseif self.unit.fightUnitType == GameUnitType.CHILDREN then
        fightMgr.Instance():SetChildAutoSkill(self.unit.roleId, self.skills[index].id)
      end
    else
      fightMgr.Instance():SetAction(0, self.skills[index].id)
      if self.skills[index].id ~= constant.FightConst.ATTACK_SKILL and self.skills[index].id ~= constant.FightConst.DEFENCE_SKILL and self.skills[index].canAuto then
        if self.unit.fightUnitType == GameUnitType.PET then
          fightMgr.Instance().pet_shortcut_skill[self.unit.roleId:tostring()] = self.skills[index].id
        elseif self.unit.fightUnitType == GameUnitType.CHILDREN then
          fightMgr.Instance().child_shortcut_skill[self.unit.roleId:tostring()] = self.skills[index].id
        end
      end
      require("Main.Fight.ui.DlgFight").Instance():ShowSelectSkill(self.skills[index])
    end
    self:Hide()
  elseif id == "Btn_Close" then
    self:Hide()
  end
end
def.method("string").onLongPress = function(self, objName)
  if string.find(objName, "Img_BgIcon") then
    local index = tonumber(string.sub(objName, string.len("Img_BgIcon") + 1))
    local skillPanelName = string.format("Skill%02d/", index)
    local obj = self.m_panel:FindDirect("Table_Bg0/Scroll View/Container/" .. skillPanelName .. objName)
    if self.unit.fightUnitType == GameUnitType.PET or self.unit.fightUnitType == GameUnitType.CHILDREN then
      local skillData = require("Main.Skill.data.SkillData")()
      skillData.id = self.skills[index].id
      skillData.level = self.skills[index].level
      require("Main.Pet.PetUtility").ShowPetSkillDataTip(skillData, obj, -1)
    end
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  local title = self.m_panel:FindDirect("Group_Title/Img_BgTitle/Label_AutoSkill"):GetComponent("UILabel")
  if self.isAuto then
    if self.unit.fightUnitType == GameUnitType.PET then
      title.text = textRes.Fight[31]
    elseif self.unit.fightUnitType == GameUnitType.CHILDREN then
      title.text = textRes.Fight[60]
    end
  elseif self.unit.fightUnitType == GameUnitType.PET then
    title.text = textRes.Fight[30]
  elseif self.unit.fightUnitType == GameUnitType.CHILDREN then
    title.text = textRes.Fight[59]
  end
  self:ShowSkills()
end
def.method().SetUnitSkills = function(self)
  if not self.isAuto then
    self.unit = fightMgr.Instance():GetCurrentControllable()
  end
  if self.unit == nil then
    return
  end
  local skillList
  self.skills = {}
  if self.unit.fightUnitType == GameUnitType.PET then
    self.selectedSkillId = fightMgr.Instance().pet_default_skill[self.unit.roleId:tostring()] or 0
    skillList = fightMgr.Instance():GetPetSkillList()
  elseif self.unit.fightUnitType == GameUnitType.CHILDREN then
    self.selectedSkillId = fightMgr.Instance().child_default_skill[self.unit.roleId:tostring()] or 0
    skillList = fightMgr.Instance():GetChildSkillList()
  end
  if skillList == nil then
    return
  end
  for k, v in pairs(skillList) do
    if self.isAuto or k ~= constant.FightConst.ATTACK_SKILL and k ~= constant.FightConst.DEFENCE_SKILL then
      local skillcfg = fightMgr.Instance():GetSkillCfg(k)
      if skillcfg then
        skillcfg.level = self.unit.level
        if self.isAuto then
          if skillcfg.canAuto then
            table.insert(self.skills, skillcfg)
          end
        elseif skillcfg.displayInFight then
          table.insert(self.skills, skillcfg)
        end
      end
    end
  end
end
def.method().ShowSkills = function(self)
  local tablePanel = self.m_panel:FindDirect("Table_Bg0/Scroll View/Container")
  local template = tablePanel:FindDirect("Skill01")
  local templateIcon = template:FindDirect("Img_BgIcon")
  if templateIcon == nil then
    return
  end
  templateIcon.name = "Img_BgIcon01"
  local idx = 1
  for k, v in pairs(self.skills) do
    local objName = string.format("Skill%02d", idx)
    local skillpanel = tablePanel:FindDirect(objName)
    if skillpanel == nil then
      skillpanel = Object.Instantiate(template)
      skillpanel.name = objName
      skillpanel.parent = tablePanel
      skillpanel.localScale = require("Types.Vector").Vector3.one
    end
    local bgIcon = skillpanel:FindDirect("Img_BgIcon01")
    bgIcon.name = string.format("Img_BgIcon%02d", idx)
    local sp = bgIcon:FindDirect("Img_Icon")
    if sp then
      local texture = sp:GetComponent("UITexture")
      if texture then
        GUIUtils.FillIcon(texture, v.icon)
        GUIUtils.SetCircularEffect(texture)
      end
    end
    local selectImg = bgIcon:FindDirect("Img_Select")
    selectImg:SetActive(self.isAuto and v.id == self.selectedSkillId)
    local nameLabel = skillpanel:FindDirect("Label_Name")
    if nameLabel then
      nameLabel:GetComponent("UILabel").text = v.name
      local valid = fightMgr.Instance():CheckSkillRequirement(self.unit, v.id, v.level, v.count)
      if not valid then
        nameLabel:GetComponent("UILabel").textColor = Color.Color(1, 0, 0, 1)
        local texture = sp:GetComponent("UITexture")
        if texture then
          local mat = texture:get_material()
          if mat then
            mat:EnableKeyword("Grey_On")
          end
        end
      end
    end
    idx = idx + 1
  end
  template:SetActive(#self.skills > 0)
  local uiTable = tablePanel:GetComponent("UITable")
  uiTable:Reposition()
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
DlgPetSkill.Commit()
return DlgPetSkill
