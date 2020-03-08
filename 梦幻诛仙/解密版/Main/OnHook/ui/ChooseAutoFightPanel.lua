local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECGUIMan = require("GUI.ECGUIMan")
local ChooseAutoFightPanel = Lplus.Extend(ECPanelBase, "ChooseAutoFightPanel")
local ItemModule = require("Main.Item.ItemModule")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local CommonSkillTip = require("GUI.CommonSkillTip")
local def = ChooseAutoFightPanel.define
def.field("table")._chooseSkills = nil
def.field("boolean")._bChooseTemplateFill = false
def.field("number")._chooseSkillIndex = -1
def.field("function")._callback = nil
def.field("string")._title = ""
def.field("table")._tag = nil
def.field("number")._pressTimerId = 0
def.field("string")._pressedButtonId = ""
def.override().OnCreate = function(self)
  self:UpdateTitle()
  self:UpdateInfo()
end
def.static("table", "function", "string", "table").ShowSkillChoose = function(skills, callback, title, tag)
  local dlg = ChooseAutoFightPanel()
  dlg._chooseSkills = skills
  dlg._callback = callback
  dlg._title = title
  dlg._tag = tag
  dlg:SetModal(true)
  dlg:CreatePanel(RESPATH.PREFAB_AUTOSKILL_CHOOSE_PANEL, 2)
end
def.method().UpdateTitle = function(self)
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Img_BgTitle = Img_Bg0:FindDirect("Group_Title/Img_BgTitle")
  local Label_AutoSkill = Img_BgTitle:FindDirect("Label_AutoSkill")
  Label_AutoSkill:GetComponent("UILabel"):set_text(self._title)
end
def.method().UpdateInfo = function(self)
  if nil == self.m_panel then
    return
  end
  self._bChooseTemplateFill = false
  local bg = self.m_panel:FindDirect("Img_Bg0")
  local gridTemplate = bg:FindDirect("Scroll View/Table")
  local chooseTemplate = gridTemplate:FindDirect("Img_BgSkill01")
  if 0 == #self._chooseSkills then
    chooseTemplate:SetActive(false)
    return
  end
  local count = 1
  gridTemplate:GetChild(0):SetActive(true)
  self._bChooseTemplateFill = self:FillChooseList(count, chooseTemplate, gridTemplate)
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("number", "userdata", "userdata", "=>", "boolean").FillChooseList = function(self, count, chooseTemplate, gridTemplate)
  local index = 1
  if false == self._bChooseTemplateFill then
    index = 2
    if #self._chooseSkills > 0 then
      self:FillChooseInfo(1, count, chooseTemplate, gridTemplate)
      self._bChooseTemplateFill = true
    end
  else
    index = 1
  end
  for i = index, #self._chooseSkills do
    count = count + 1
    local chooseNew = Object.Instantiate(chooseTemplate)
    self:FillChooseInfo(i, count, chooseNew, gridTemplate)
  end
  return self._bChooseTemplateFill
end
def.method("number", "number", "userdata", "userdata").FillChooseInfo = function(self, index, count, chooseNew, gridTemplate)
  chooseNew:set_name(string.format("Img_BgSkill0%d", count))
  chooseNew.parent = gridTemplate
  chooseNew:set_localScale(Vector.Vector3.one)
  local id = self._chooseSkills[index]
  if false == self._tag.bIsPet then
    id = self._chooseSkills[index].id
  end
  local skillCfg
  if self._tag.bIsPet then
    skillCfg = require("Main.Pet.PetUtility").Instance():GetPetSkillCfg(id)
  else
    skillCfg = GetSkillCfg(id)
  end
  if nil == skillCfg then
    return
  end
  local chooseTexture = chooseNew:FindDirect("Img_BgIcon/Img_Icon"):GetComponent("UITexture")
  if self._tag.bIsPet then
    GUIUtils.FillIcon(chooseTexture, skillCfg.iconId)
  else
    GUIUtils.FillIcon(chooseTexture, skillCfg.icon)
  end
  local chooseLabel = chooseNew:FindDirect("Label_Name"):GetComponent("UILabel")
  chooseLabel:set_text(skillCfg.name)
  if _G.GetOriginalSkill(self._tag.autoSkillId) == id then
    chooseNew:GetComponent("UIToggle"):set_isChecked(true)
  else
    chooseNew:GetComponent("UIToggle"):set_isChecked(false)
  end
end
def.method("string", "boolean").onPress = function(self, id, state)
  if state == true then
    self:_RemovePressTimer()
    self._pressedButtonId = ""
    self._pressTimerId = GameUtil.AddGlobalTimer(0.5, true, function()
      self._pressedButtonId = id
      self:OnButtonPressed(id)
    end)
  else
    self:_RemovePressTimer()
  end
end
def.method()._RemovePressTimer = function(self)
  if self._pressTimerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self._pressTimerId)
    self._pressTimerId = 0
  end
end
def.method("string").OnButtonPressed = function(self, id)
  if string.find(id, "Img_BgSkill0") then
    local sourceObj = self.m_panel:FindDirect("Img_Bg0")
    local position = sourceObj:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local widget = sourceObj:GetComponent("UIWidget")
    local indexStr = string.sub(id, string.len("Img_BgSkill0") + 1)
    local index = tonumber(indexStr)
    local skillData = self._chooseSkills[index]
    if self._tag.bIsPet then
      require("Main.Skill.SkillTipMgr").Instance():ShowPetTipEx(skillData, self._tag.level, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
    else
      require("Main.Skill.SkillTipMgr").Instance():ShowTip(skillData, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
    end
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if id == self._pressedButtonId then
    self._pressedButtonId = ""
  end
  if string.find(id, "Img_BgSkill0") then
    local indexStr = string.sub(id, string.len("Img_BgSkill0") + 1)
    local index = tonumber(indexStr)
    self._chooseSkillIndex = index
    local skillId = self._chooseSkills[index]
    if false == self._tag.bIsPet then
      skillId = require("Main.Oracle.data.OracleData").Instance():GetTalentSkillId(self._chooseSkills[index].id)
    end
    self._callback(self._tag, skillId)
    self:DestroyPanel()
    self = nil
  elseif id == "Btn_Close" then
    self:DestroyPanel()
    self = nil
  elseif "Modal" == id then
    self:DestroyPanel()
    self = nil
  end
end
ChooseAutoFightPanel.Commit()
return ChooseAutoFightPanel
