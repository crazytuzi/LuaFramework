local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local WingCheckDlg = Lplus.Extend(ECPanelBase, "WingCheckDlg")
local GUIUtils = require("GUI.GUIUtils")
local WingModel = require("Main.Wing.ui.WingModel")
local SkillUtility = require("Main.Skill.SkillUtility")
local def = WingCheckDlg.define
local instance
def.static("=>", WingCheckDlg).Instance = function()
  if instance == nil then
    instance = WingCheckDlg()
  end
  return instance
end
def.const("number").MAXSKILLNUM = 15
def.field("string").name = ""
def.field("number").level = 0
def.field("number").phase = 0
def.field("number").outlookId = 0
def.field("number").colorId = 0
def.field("table").wingProp = nil
def.field("table").skills = nil
def.field(WingModel).wingModel = nil
def.field("boolean").isDrag = false
def.static("string", "number", "number", "number", "number", "table", "table").CheckWing = function(name, lv, ph, outlookId, colorId, prop, skills)
  warn("CheckWing:", name, lv, ph, outlookId, colorId, prop, skills)
  local self = WingCheckDlg.Instance()
  self.name = name
  self.level = lv
  self.phase = ph
  self.outlookId = outlookId
  self.colorId = colorId
  self.wingProp = prop
  self.skills = skills
  if self:IsShow() then
    self:UpdateAll()
  else
    self:CreatePanel(RESPATH.PANEL_CHECKWING, 1)
    self:SetModal(true)
  end
end
def.override().OnCreate = function(self)
  self:UpdateAll()
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow and self.wingModel then
    self.wingModel:Stand()
  end
end
def.override().OnDestroy = function(self)
  if self.wingModel then
    self.wingModel:Destroy()
    self.wingModel = nil
  end
end
def.method().UpdateAll = function(self)
  self:UpdateBasic()
  self:UpdateProp()
  self:UpdateSkill()
  self:UpdateModel()
end
def.method().UpdateBasic = function(self)
  local nameLabel = self.m_panel:FindDirect("Img_Bg0/Img_YY/Group_Left/Img_NameBg/Label")
  nameLabel:GetComponent("UILabel"):set_text(self.name)
  local lvLabel = self.m_panel:FindDirect("Img_Bg0/Img_YY/Group_Right/Group_Attribute/Label_Level")
  lvLabel:GetComponent("UILabel"):set_text(string.format(textRes.Wing[1], self.level))
  local phaseLabel = self.m_panel:FindDirect("Img_Bg0/Img_YY/Group_Right/Group_Attribute/Labe_PinjieLevel")
  phaseLabel:GetComponent("UILabel"):set_text(string.format(textRes.Wing[2], self.phase))
  local tryBtn = self.m_panel:FindDirect("Img_Bg0/Img_YY/Group_Left/Btn_Dressed")
  tryBtn:SetActive(self.outlookId > 0)
end
def.method().UpdateProp = function(self)
  local propUI = self.m_panel:FindDirect("Img_Bg0/Img_YY/Group_Right/Group_Attribute/Img_Bg")
  local prop1 = propUI:FindDirect("Attribute_1/Label2")
  local prop2 = propUI:FindDirect("Attribute_2/Label2")
  local prop3 = propUI:FindDirect("Attribute_3/Label2")
  local prop4 = propUI:FindDirect("Attribute_4/Label2")
  local prop5 = propUI:FindDirect("Attribute_5/Label2")
  local prop6 = propUI:FindDirect("Attribute_6/Label2")
  local prop7 = propUI:FindDirect("Attribute_7/Label2")
  local prop8 = propUI:FindDirect("Attribute_8/Label2")
  local prop9 = propUI:FindDirect("Attribute_9/Label2")
  local prop10 = propUI:FindDirect("Attribute_10/Label2")
  local prop11 = propUI:FindDirect("Attribute_11/Label2")
  local prop12 = propUI:FindDirect("Attribute_12/Label2")
  local props = self.wingProp
  prop1:GetComponent("UILabel"):set_text(tostring(props.PHYATK))
  prop2:GetComponent("UILabel"):set_text(tostring(props.PHYDEF))
  prop3:GetComponent("UILabel"):set_text(tostring(props.MAGATK))
  prop4:GetComponent("UILabel"):set_text(tostring(props.MAGDEF))
  prop5:GetComponent("UILabel"):set_text(tostring(props.MAX_HP))
  prop6:GetComponent("UILabel"):set_text(tostring(props.SPEED))
  prop7:GetComponent("UILabel"):set_text(tostring(props.PHY_CRIT_LEVEL))
  prop8:GetComponent("UILabel"):set_text(tostring(props.PHY_CRT_DEF_LEVEL))
  prop9:GetComponent("UILabel"):set_text(tostring(props.MAG_CRT_LEVEL))
  prop10:GetComponent("UILabel"):set_text(tostring(props.MAG_CRT_DEF_LEVEL))
  prop11:GetComponent("UILabel"):set_text(tostring(props.SEAL_HIT))
  prop12:GetComponent("UILabel"):set_text(tostring(props.SEAL_RESIST))
end
def.method().UpdateSkill = function(self)
  local skills = self.skills
  local scroll = self.m_panel:FindDirect("Img_Bg0/Img_YY/Group_Right/Group_Skill/Scroll View")
  local list = scroll:FindDirect("List_Skill")
  local uiNum = #skills <= WingCheckDlg.MAXSKILLNUM and WingCheckDlg.MAXSKILLNUM or math.ceil(#skills / 5) * 5
  local listCmp = list:GetComponent("UIList")
  listCmp:set_itemCount(uiNum)
  listCmp:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not listCmp.isnil then
      listCmp:Reposition()
    end
    if not scroll.isnil then
      scroll:GetComponent("UIScrollView"):ResetPosition()
    end
  end)
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local skillId = skills[i]
    self:FillSkillIcon(uiGo, skillId and skillId or 0)
  end
end
def.method("userdata", "number").FillSkillIcon = function(self, uiGo, skillId)
  local tex = uiGo:FindDirect("Texture")
  local skillCfg = skillId > 0 and SkillUtility.GetSkillCfg(skillId) or nil
  if skillCfg then
    tex:SetActive(true)
    local texCmp = tex:GetComponent("UITexture")
    GUIUtils.FillIcon(texCmp, skillCfg.iconId)
  else
    tex:SetActive(false)
  end
end
def.method().UpdateModel = function(self)
  local uiModel = self.m_panel:FindDirect("Img_Bg0/Img_YY/Group_Left/Model")
  local uiModelCmp = uiModel:GetComponent("UIModel")
  if self.outlookId > 0 then
    if self.wingModel then
      self.wingModel:Destroy()
      self.wingModel = nil
    end
    self.wingModel = WingModel()
    self.wingModel:Create(self.outlookId, self.colorId, function()
      if uiModelCmp.isnil then
        return
      end
      uiModelCmp.mCanOverflow = true
      local camera = uiModelCmp:get_modelCamera()
      camera:set_orthographic(true)
      uiModelCmp.modelGameObject = self.wingModel:GetModelGameObject()
    end)
  elseif self.wingModel then
    self.wingModel:Destroy()
    self.wingModel = nil
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Dressed" then
    self:Show(false)
    require("Main.Item.ui.FittingRoomPanel").Instance():ShowWingsPanel(self.outlookId, self.colorId, function()
      self:Show(true)
    end)
  elseif string.sub(id, 1, 5) == "item_" then
    local index = tonumber(string.sub(id, 6))
    local selectSkill = self.skills[index]
    local cell = self.m_panel:FindDirect("Img_Bg0/Img_YY/Group_Right/Group_Skill/Scroll View/List_Skill/" .. id)
    if cell and selectSkill then
      require("Main.Skill.SkillTipMgr").Instance():ShowTipByIdEx(selectSkill, cell, 0)
    end
  end
end
def.method("string").onDragStart = function(self, id)
  if id == "Model" then
    self.isDrag = true
  end
end
def.method("string").onDragEnd = function(self, id)
  self.isDrag = false
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.isDrag and self.wingModel then
    self.wingModel:SetDir(self.wingModel:GetDir() - dx / 2)
  end
end
return WingCheckDlg.Commit()
