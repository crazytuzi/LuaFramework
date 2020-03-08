local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgSelectSkill = Lplus.Extend(ECPanelBase, "DlgSelectSkill")
local def = DlgSelectSkill.define
local dlg
local fightMgr = Lplus.ForwardDeclare("FightMgr")
local FightUnit = Lplus.ForwardDeclare("FightUnit")
local GameUnitType = require("consts/mzm/gsp/common/confbean/GameUnitType")
local SkillType = require("consts.mzm.gsp.skill.confbean.SkillType")
local GUIUtils = require("GUI.GUIUtils")
local SkillInterface = require("Main.Skill.Interface")
local SkillData = require("Main.Skill.data.SkillData")
local FightUtils = require("Main.Fight.FightUtils")
def.field("table").skills = nil
def.field(FightUnit).unit = nil
def.field("number").unit_state = 0
def.field("boolean").isAuto = false
def.field("number").skillTypes = 0
def.field("number").selectedSkillId = 0
def.field("userdata").defaultSkillColor = nil
def.static("=>", DlgSelectSkill).Instance = function()
  if dlg == nil then
    dlg = DlgSelectSkill()
  end
  return dlg
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.CLOSE_SECOND_LEVEL_UI, DlgSelectSkill.OnCloseSecondLevelUI)
end
def.method("number", "=>", "boolean").ShowDlg = function(self, skillTypes)
  if self.m_panel then
    self:DestroyPanel()
  end
  if skillTypes > 0 then
    self.skillTypes = skillTypes
    self:SetUnitSkills()
  else
    local unit = fightMgr.Instance():GetCurrentControllable()
    if unit and (self.unit == nil or unit.id ~= self.unit.id or unit.state ~= self.unit_state) then
      self:SetUnitSkills()
    end
  end
  if self.skills == nil or #self.skills == 0 then
    return false
  end
  self:CreatePanel(RESPATH.DLG_FIGHT_SELECT_SKILL, 1)
  return true
end
def.static("table", "table").OnCloseSecondLevelUI = function()
  dlg:Hide()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.CLOSE_SECOND_LEVEL_UI, DlgSelectSkill.OnCloseSecondLevelUI)
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if string.find(id, "Img_BgIcon") then
    local index = tonumber(string.sub(id, string.len("Img_BgIcon") + 1))
    if self.isAuto then
      if not self.skills[index].canAuto then
        Toast(textRes.Fight[41])
        return
      end
      if self.unit.fightUnitType == GameUnitType.ROLE then
        fightMgr.Instance():SetAutoSkill(self.skills[index].realSkillId)
      end
    else
      local usedData = self.unit.skillUsedData[self.skills[index].realSkillId]
      local skillCfg = fightMgr.Instance():GetSkillCfg(self.skills[index].realSkillId)
      if skillCfg.count > 0 then
        local used = usedData and usedData.skillUseCount or 0
        local leftCount = skillCfg.count - used
        if leftCount <= 0 then
          Toast(textRes.Fight[47])
          return
        end
      end
      if 0 < skillCfg.cdRound and usedData and usedData.skillUseRound and fightMgr.Instance().curRound <= usedData.skillUseRound then
        Toast(textRes.Fight[46])
        return
      end
      fightMgr.Instance():SetAction(0, self.skills[index].realSkillId)
      if not FightUtils.IsNormalAttack(self.unit.menpai, self.skills[index].id) and self.skills[index].id ~= constant.FightConst.DEFENCE_SKILL and self.skills[index].canAuto and self.unit.fightUnitType == GameUnitType.ROLE then
        fightMgr.Instance().role_shortcut_skill = self.skills[index].realSkillId
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
    local obj = self.m_panel:FindDirect("Table_Bg0/Scroll View/Table/" .. skillPanelName .. objName)
    if self.unit.fightUnitType == GameUnitType.ROLE then
      local position = obj:get_position()
      local screenPos = WorldPosToScreen(position.x, position.y)
      local widget = obj:GetComponent("UIWidget")
      local skillData = SkillData()
      skillData.id = self.skills[index].id
      skillData.level = self.skills[index].level
      require("Main.Skill.SkillTipMgr").Instance():ShowTip(skillData, screenPos.x, screenPos.y, widget.width, widget.height, 0)
    end
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  if self.defaultSkillColor == nil then
    local defaultSkillName = self.m_panel:FindDirect("Table_Bg0/Scroll View/Table/Skill01/Label_Name")
    if defaultSkillName then
      self.defaultSkillColor = defaultSkillName:GetComponent("UILabel").textColor
    end
  end
  self:ShowSkills()
  local title = self.m_panel:FindDirect("Group_Title/Img_BgTitle/Label_AutoSkill"):GetComponent("UILabel")
  if self.isAuto then
    title.text = textRes.Fight[29]
  elseif bit.band(self.skillTypes, SkillType.SPECIAL) > 0 then
    title.text = textRes.Fight[34]
  else
    title.text = textRes.Fight[28]
  end
end
def.method().SetUnitSkills = function(self)
  if not self.isAuto then
    self.unit = fightMgr.Instance():GetCurrentControllable()
  end
  if self.unit == nil then
    return
  end
  self.unit_state = self.unit.state
  local skillList
  self.skills = {}
  if self.unit.fightUnitType == GameUnitType.ROLE then
    skillList = fightMgr.Instance():GetRoleSkillList()
    if skillList then
      local normalAttack
      for k, v in pairs(skillList) do
        local isNormalAttack = FightUtils.IsNormalAttack(self.unit.menpai, k)
        if self.isAuto or not isNormalAttack and k ~= constant.FightConst.DEFENCE_SKILL then
          local showSkillId = _G.GetOriginalSkill(k)
          local skillcfg = fightMgr.Instance():GetSkillCfg(showSkillId)
          if skillcfg == nil then
            warn("Set Auto skill: skill cfg is nil for id ", showSkillId)
          end
          skillcfg.level = v
          skillcfg.realSkillId = k
          if skillcfg.displayInFight and bit.band(skillcfg.skillType, self.skillTypes) > 0 or self.isAuto and k == constant.FightConst.DEFENCE_SKILL then
            if isNormalAttack then
              normalAttack = skillcfg
            else
              table.insert(self.skills, skillcfg)
            end
          end
        end
      end
      table.sort(self.skills, function(a, b)
        return a.id < b.id
      end)
      if normalAttack then
        table.insert(self.skills, 1, normalAttack)
      end
    end
    self.selectedSkillId = _G.GetOriginalSkill(fightMgr.Instance().role_default_skill or 0)
  end
end
def.method().ShowSkills = function(self)
  local tablePanel = self.m_panel:FindDirect("Table_Bg0/Scroll View/Table")
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
        GUIUtils.SetCircularEffect(texture)
        GUIUtils.FillIcon(texture, v.icon)
      end
    end
    local selectImg = bgIcon:FindDirect("Img_Select")
    selectImg:SetActive(self.isAuto and v.id == self.selectedSkillId)
    local nameLabel = skillpanel:FindDirect("Label_Name")
    if nameLabel then
      local valid = fightMgr.Instance():CheckSkillRequirement(self.unit, v.realSkillId, v.level, v.count)
      if self.isAuto and valid then
        valid = v.canAuto
      end
      nameLabel:GetComponent("UILabel").text = v.name
      if not valid then
        nameLabel:GetComponent("UILabel").textColor = Color.Color(1, 0, 0, 1)
        local texture = sp:GetComponent("UITexture")
        if texture then
          local mat = texture:get_material()
          if mat then
            mat:EnableKeyword("Grey_On")
          end
        end
      else
        nameLabel:GetComponent("UILabel").textColor = self.defaultSkillColor
        local texture = sp:GetComponent("UITexture")
        if texture then
          local mat = texture:get_material()
          if mat then
            mat:DisableKeyword("Grey_On")
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
DlgSelectSkill.Commit()
return DlgSelectSkill
