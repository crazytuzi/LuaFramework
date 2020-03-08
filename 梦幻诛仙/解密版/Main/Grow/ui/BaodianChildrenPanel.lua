local Lplus = require("Lplus")
local SkillUtility = require("Main.Skill.SkillUtility")
local BaodianBasePanel = require("Main.Grow.ui.BaodianBasePanel")
local GUIUtils = require("GUI.GUIUtils")
local TipsHelper = require("Main.Common.TipsHelper")
local BaodianChildrenPanel = Lplus.Extend(BaodianBasePanel, "BaodianChildrenPanel")
local def = BaodianChildrenPanel.define
local instance
def.static("=>", BaodianChildrenPanel).Instance = function()
  if instance == nil then
    instance = BaodianChildrenPanel()
  end
  return instance
end
def.const("number").ALL = -1
def.const("number").MAX = 1024
def.field("table").skillData = nil
def.field("number").curIndex = 1
def.field("string").initToggle = ""
def.override("userdata").ShowPanel = function(self, parentPanel)
  if self:IsShow() then
    return
  end
  GameUtil.AddGlobalLateTimer(0, true, function()
    self:CreatePanel(RESPATH.PREFAB_BAODIAN_CHILDREN, 2)
  end)
end
def.override("userdata", "number").ShowPanelWithTargetNode = function(self, parentPanel, subNode)
  local node2Toggle = {
    "Tab_1",
    "Tab_2",
    "Tab_3",
    "Tab_4",
    "Tab_5"
  }
  local toggleName = node2Toggle[subNode]
  if toggleName then
    self.initToggle = toggleName
  else
    self.initToggle = ""
  end
  self:ShowPanel(parentPanel)
end
def.override("=>", "boolean").NeedSubNode = function(self)
  return true
end
def.override().OnCreate = function(self)
  self:InitAllSkills()
  self:UpdateBirth()
  self:UpdateBaby()
  self:UpdateTeen()
  self:UpdateYouth()
  self:UpdateSkills()
  self:SelectToggle()
end
def.method().SelectToggle = function(self)
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if self:IsShow() and self.initToggle ~= "" then
      local toggle = self.m_panel:FindDirect("Group_Tab/Group_TabBtn/" .. self.initToggle)
      if toggle then
        toggle:GetComponent("UIToggle").value = true
      end
      self.initToggle = ""
    end
  end)
end
def.method().UpdateBirth = function(self)
  local lbl1 = self.m_panel:FindDirect("Group_Children_Breed/Group_Single/Group_Details/Scrollview_Note/Drag_Tips_Single")
  local lbl2 = self.m_panel:FindDirect("Group_Children_Breed/Group_Couple/Group_Details/Scrollview_Note/Drag_Tips_Couple")
  self:FillLabelById(lbl1, constant.CChildGuideConst.SINGLE_GET_CHILD_DESC_ID)
  self:FillLabelById(lbl2, constant.CChildGuideConst.COUPLES_GET_CHILD_DESC_ID)
end
def.method().UpdateBaby = function(self)
  local lbl1 = self.m_panel:FindDirect("Group_Children_YingEr/Group_Details/Group_Details/Scrollview_Note/Drag_Tips_YingEr")
  self:FillLabelById(lbl1, constant.CChildGuideConst.BABY_DESC_ID)
end
def.method().UpdateTeen = function(self)
  local lbl1 = self.m_panel:FindDirect("Group_Children_TongNian/Group_Details/Group_Details/Scrollview_Note/Drag_Tips_TongNian")
  self:FillLabelById(lbl1, constant.CChildGuideConst.CHILDHOOD_DESC_ID)
end
def.method().UpdateYouth = function(self)
  local lbl1 = self.m_panel:FindDirect("Group_Children_ShaoNian/Group_Details/Group_Details/Scrollview_Note/Drag_Tips_ShaoNian")
  self:FillLabelById(lbl1, constant.CChildGuideConst.ADULT_DESC_ID)
  local iconsGroup = self.m_panel:FindDirect("Group_Children_ShaoNian/Group_Equip/Group_Equip")
  local icon1 = iconsGroup:FindDirect("Img_CW_BgEquip01/Img_CW_IconEquip01")
  local icon2 = iconsGroup:FindDirect("Img_CW_BgEquip02/Img_CW_IconEquip02")
  local icon3 = iconsGroup:FindDirect("Img_CW_BgEquip03/Img_CW_IconEquip03")
  local icon4 = iconsGroup:FindDirect("Img_CW_BgEquip04/Img_CW_IconEquip04")
  GUIUtils.SetTexture(icon1, constant.CChildGuideConst.WEAPON_ICON_ID)
  GUIUtils.SetTexture(icon2, constant.CChildGuideConst.CLOTHES_ICON_ID)
  GUIUtils.SetTexture(icon3, constant.CChildGuideConst.SHOES_ICON_ID)
  GUIUtils.SetTexture(icon4, constant.CChildGuideConst.AMULET_ICON_ID)
  self:SelectWearPos(1)
end
def.method("number", "=>", "number").GetWearPosDescId = function(self, pos)
  if pos == 1 then
    return constant.CChildGuideConst.WEAPON_DESC_ID
  elseif pos == 2 then
    return constant.CChildGuideConst.CLOTHES_DESC_ID
  elseif pos == 3 then
    return constant.CChildGuideConst.SHOES_DESC_ID
  elseif pos == 4 then
    return constant.CChildGuideConst.AMULET_DESC_ID
  else
    return 0
  end
end
def.method("number").SelectWearPos = function(self, num)
  local icon = self.m_panel:FindDirect(string.format("Group_Children_ShaoNian/Group_Equip/Group_Equip/Img_CW_BgEquip%02d/Img_CW_BgEquip%02d", num, num))
  local desc = self.m_panel:FindDirect("Group_Children_ShaoNian/Group_Equip/Group_Details/Scrollview_Note/Drag_Tips_Equip")
  self:FillLabelById(desc, self:GetWearPosDescId(num))
end
def.method().UpdateSkills = function(self)
  local popup = self.m_panel:FindDirect("Group_Children_Skill/Group_Choose/Btn_SkillChoose")
  local popupCmp = popup:GetComponent("UIPopupButton")
  local items = self:GetAllOccupations()
  popupCmp:set_items(items)
  self:SelectOccupation(self.curIndex)
end
def.method("number").SelectOccupation = function(self, index)
  self.curIndex = index
  local data = self:GetSkills(index)
  if data then
    local name = data.name
    local nameLbl = self.m_panel:FindDirect("Group_Children_Skill/Group_Choose/Btn_SkillChoose/Label_Btn")
    nameLbl:GetComponent("UILabel"):set_text(name)
    self:UpdateSkillList(data.skills)
    self:SelectSkill(data.skills[1] or 0)
  end
end
def.method("table").UpdateSkillList = function(self, skills)
  local count = #skills
  local scroll = self.m_panel:FindDirect("Group_Children_Skill/Group_List/Scroll View")
  local list = scroll:FindDirect("List")
  local listCmp = list:GetComponent("UIList")
  listCmp:set_itemCount(count)
  listCmp:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not listCmp.isnil and not scroll.isnil then
      listCmp:Reposition()
      scroll:GetComponent("UIScrollView"):ResetPosition()
    end
  end)
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    if i == 1 then
      uiGo:GetComponent("UIToggle").value = true
    end
    local skillId = skills[i]
    local skillCfg = SkillUtility.GetSkillCfg(skillId)
    if skillCfg then
      local nameLbl = uiGo:FindDirect("Label_Name")
      local skillIcon = uiGo:FindDirect("Img_BgIcon/Texture_Icon")
      nameLbl:GetComponent("UILabel"):set_text(skillCfg.name)
      GUIUtils.SetTexture(skillIcon, skillCfg.iconId)
      self.m_msgHandler:Touch(uiGo)
    end
  end
end
def.method("number").SelectSkill = function(self, skillId)
  local skillCfg = SkillUtility.GetSkillCfg(skillId)
  if skillCfg then
    local group = self.m_panel:FindDirect("Group_Children_Skill/Group_Detail")
    group:SetActive(true)
    local nameLbl = group:FindDirect("Group_Skill/Label_Name")
    local skillIcon = group:FindDirect("Group_Skill/Img_BgIcon/Texture_Icon")
    local detail = group:FindDirect("Group_Attribute/Label_AttributeNum2")
    nameLbl:GetComponent("UILabel"):set_text(skillCfg.name)
    GUIUtils.SetTexture(skillIcon, skillCfg.iconId)
    detail:GetComponent("UILabel"):set_text(skillCfg.description)
  else
    local group = self.m_panel:FindDirect("Group_Children_Skill/Group_Detail")
    group:SetActive(false)
  end
end
def.method("userdata", "number").FillLabelById = function(self, uiGo, tipId)
  local lbl = uiGo:GetComponent("UILabel")
  local tip = TipsHelper.GetHoverTip(tipId)
  lbl:set_text(tip)
end
def.method("string").onClick = function(self, id)
  if string.sub(id, 1, 14) == "Img_CW_BgEquip" then
    local index = tonumber(string.sub(id, 15))
    if index then
      self:SelectWearPos(index)
    end
  end
end
def.method("string", "boolean").onToggle = function(self, id, active)
  if active and string.sub(id, 1, 5) == "item_" then
    local index = tonumber(string.sub(id, 6))
    if index then
      local skillId = self:GetSkill(self.curIndex, index)
      self:SelectSkill(skillId)
    end
  end
end
def.method("string", "string", "number").onSelect = function(self, id, selected, index)
  if id == "Btn_SkillChoose" then
    self:SelectOccupation(index + 1)
  end
end
def.override().OnDestroy = function(self)
  self.skillData = nil
  self.curIndex = 1
end
def.method().InitAllSkills = function(self)
  local ChildrenUtils = require("Main.Children.ChildrenUtils")
  local skill = {}
  local menpaiSkills = ChildrenUtils.GetAllOpenedOccupationSkill()
  local specialSkills = ChildrenUtils.GetAllChildrenSpecialSkills()
  local allSkills = {}
  for k, v in pairs(menpaiSkills) do
    local menpaiName = GetOccupationName(k)
    local menpaiSkill = {name = menpaiName, sort = k}
    menpaiSkill.skills = clone(v)
    table.insert(allSkills, menpaiSkill)
  end
  local specialSkill = {
    name = textRes.Children[32],
    sort = BaodianChildrenPanel.MAX
  }
  specialSkill.skills = clone(specialSkills)
  table.insert(allSkills, specialSkill)
  table.sort(allSkills, function(a, b)
    return a.sort < b.sort
  end)
  local allSkill = {
    name = textRes.Children[31],
    sort = BaodianChildrenPanel.ALL,
    skills = {}
  }
  for _, v in ipairs(allSkills) do
    for _, v1 in ipairs(v.skills) do
      table.insert(allSkill.skills, v1)
    end
  end
  table.insert(allSkills, 1, allSkill)
  self.skillData = allSkills
end
def.method("number", "=>", "table").GetSkills = function(self, idx)
  if self.skillData then
    return self.skillData[idx]
  end
  return nil
end
def.method("number", "number", "=>", "number").GetSkill = function(self, occupation, index)
  if self.skillData then
    if self.skillData[occupation] then
      return self.skillData[occupation].skills[index] or 0
    else
      return 0
    end
  else
    return 0
  end
end
def.method("=>", "table").GetAllOccupations = function(self)
  if self.skillData then
    local allOccupations = {}
    for k, v in ipairs(self.skillData) do
      table.insert(allOccupations, v.name)
    end
    return allOccupations
  end
  return {}
end
BaodianChildrenPanel.Commit()
return BaodianChildrenPanel
