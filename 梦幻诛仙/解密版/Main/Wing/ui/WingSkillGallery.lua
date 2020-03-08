local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local WingSkillGallery = Lplus.Extend(ECPanelBase, "WingSkillGallery")
local WingModule = require("Main.Wing.WingModule")
local WingUtils = require("Main.Wing.WingUtils")
local GUIUtils = require("GUI.GUIUtils")
local SkillUtility = require("Main.Skill.SkillUtility")
local def = WingSkillGallery.define
local instance
def.static("=>", WingSkillGallery).Instance = function()
  if instance == nil then
    instance = WingSkillGallery()
  end
  return instance
end
def.field("table").data = nil
def.field("number").select = -1
def.field("number").skillLevel = -1
def.field("table").skillHave = nil
def.field("number")._targetPosIdx = 0
def.static("number", "number").ShowWingSkillsByTargetPosIdx = function(phase, targetPosIdx)
  local self = WingSkillGallery.Instance()
  self._targetPosIdx = targetPosIdx
  WingSkillGallery.ShowWingSkills(phase)
end
def.static("number").ShowWingSkills = function(phase)
  local self = WingSkillGallery.Instance()
  local curPhase = require("Main.Wing.WingInterface").GetCurWingPhase()
  self.data = WingUtils.GetWingSkillLib(curPhase)
  local wingData = WingModule.Instance():GetWingData()
  local skills = wingData and wingData:GetSkills() or {}
  self.skillHave = {}
  for k, v in ipairs(skills) do
    self.skillHave[v] = true
  end
  self.select = 1
  for k, v in ipairs(self.data) do
    if v.sort == phase then
      self.select = k
      self.skillLevel = k
      break
    end
  end
  if self:IsShow() then
    self:Select(self.select)
  else
    self:CreatePanel(RESPATH.PANEL_GALLERY, 2)
    self:SetModal(true)
  end
end
def.static("number").ShowOneWingSkills = function(wingId)
  local self = WingSkillGallery.Instance()
  self.data = WingUtils.GetOneWingSkillLib(wingId)
  if self.data == nil then
    return
  end
  local wingData = WingModule.Instance():GetWingData()
  local skills = wingData and wingData:GetSkills() or {}
  self.skillHave = {}
  for k, v in ipairs(skills) do
    self.skillHave[v] = true
  end
  self.select = 1
  if self:IsShow() then
    self:Select(self.select)
  else
    self:CreatePanel(RESPATH.PANEL_GALLERY, 2)
    self:SetModal(true)
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.WING, gmodule.notifyId.Wing.GOAL_WINGSKILL_CHANGE, WingSkillGallery.OnGoalWingSkillChange)
  Event.RegisterEvent(ModuleId.WING, gmodule.notifyId.Wing.UNSET_TARGET_SKILL, WingSkillGallery.OnUnsetTargetSkill)
  local left = self.m_panel:FindDirect("Img_Bg/Group_Left")
  self:FillList(left, self.data)
  self:Select(self.select)
  self:AdjustLeftList()
end
def.override("boolean").OnShow = function(self, isShow)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.WING, gmodule.notifyId.Wing.GOAL_WINGSKILL_CHANGE, WingSkillGallery.OnGoalWingSkillChange)
  Event.UnregisterEvent(ModuleId.WING, gmodule.notifyId.Wing.UNSET_TARGET_SKILL, WingSkillGallery.OnUnsetTargetSkill)
end
def.method().AdjustLeftList = function(self)
  local list = self.m_panel:FindDirect("Img_Bg/Group_Left"):FindDirect("Scroll View/List_Zhu")
  local scroll = self.m_panel:FindDirect("Img_Bg/Group_Left"):FindDirect("Scroll View")
  local listCmp = list:GetComponent("UIList")
  local items = listCmp:get_children()
  GameUtil.AddGlobalTimer(0.15, true, function()
    if self:IsShow() then
      local panelHeight = scroll:GetComponent("UIPanel"):get_height()
      local itemHeight = list:FindDirect("Group_SkillZhu"):GetComponent("UISprite"):get_height()
      local paddingY = listCmp:get_padding().y
      local amountOnShow = math.ceil(panelHeight / (itemHeight + paddingY)) - 1
      if self.skillLevel > #items - amountOnShow then
        self.m_panel:FindDirect("Img_Bg/Group_Left/Scroll View/List_Zhu"):GetComponent("UIList"):DragToMakeVisible(#items - 1, 100)
      else
        self.m_panel:FindDirect("Img_Bg/Group_Left/Scroll View/List_Zhu"):GetComponent("UIList"):DragToMakeVisible(self.skillLevel - 1 + amountOnShow - 1, 100)
      end
    end
  end)
end
def.method("userdata", "table").FillList = function(self, ui, data)
  local list = ui:FindDirect("Scroll View/List_Zhu")
  local scroll = ui:FindDirect("Scroll View")
  local listCmp = list:GetComponent("UIList")
  local num = #data
  listCmp:set_itemCount(num)
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
    local info = data[i]
    local lbl = uiGo:FindDirect("Label_" .. i)
    lbl:GetComponent("UILabel"):set_text(info.name)
    self.m_msgHandler:Touch(uiGo)
  end
end
def.method().UpdateSelect = function(self)
  local item = self.m_panel:FindDirect("Img_Bg/Group_Left/Scroll View/List_Zhu/Group_SkillZhu_" .. self.select)
  warn("item", item.name)
  if item then
    item:GetComponent("UIToggle"):set_value(true)
  end
end
def.method("userdata", "table").FillSkillInfo = function(self, ui, data)
  local list = ui:FindDirect("Group_Skill/Scroll View/List")
  local scroll = ui:FindDirect("Group_Skill/Scroll View")
  local listCmp = list:GetComponent("UIList")
  local num = #data.skills
  listCmp:set_itemCount(num)
  listCmp:Resize()
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if not listCmp.isnil and not scroll.isnil then
      listCmp:Reposition()
      scroll:GetComponent("UIScrollView"):ResetPosition()
    end
  end)
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local info = data[i]
    local typeName = data.skills[i].name
    self:FillOneSkill(uiGo, typeName, data.skills[i], data.wingId or 0)
    self.m_msgHandler:Touch(uiGo)
  end
end
def.method("userdata", "string", "table", "number").FillOneSkill = function(self, ui, name, skills, wingId)
  local nameLbl = ui:FindDirect("Label_Title")
  nameLbl:GetComponent("UILabel"):set_text(name)
  local list = ui:FindDirect("List")
  local listCmp = list:GetComponent("UIList")
  local num = #skills
  listCmp:set_itemCount(num)
  listCmp:Resize()
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if listCmp.isnil then
      listCmp:Reposition()
    end
  end)
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local skillId = skills[i]
    self:FillSkillIcon(uiGo, skillId, wingId)
  end
end
def.method("userdata", "number", "number").FillSkillIcon = function(self, uiGo, skillId, wingId)
  local tex = uiGo:FindChildByPrefix("WingSkillIcon")
  local skillCfg = skillId > 0 and SkillUtility.GetSkillCfg(skillId) or nil
  if skillCfg then
    tex:SetActive(true)
    local texCmp = tex:GetComponent("UITexture")
    GUIUtils.FillIcon(texCmp, skillCfg.iconId)
    tex.name = "WingSkillIcon_" .. skillId
  else
    tex:SetActive(false)
  end
  local tag = uiGo:FindDirect("Label_Have")
  local bHaveSkill = false
  if tag then
    tag:SetActive(self.skillHave[skillId] == true)
    bHaveSkill = self.skillHave[skillId] == true
  end
  local ctrlSettedTag = uiGo:FindDirect("Img_Sign")
  if not WingModule.IsSetTargetSkillFeatureOpen() then
    ctrlSettedTag:SetActive(false)
    return
  end
  if self.data[self.select].name == textRes.Wing[36] then
    ctrlSettedTag:SetActive(false)
    return
  end
  local bHasSetted = false
  if not bHaveSkill then
    bHasSetted = WingModule.Instance():GetWingData():IsTargetSkill(wingId, skillId)
  end
  ctrlSettedTag:SetActive(bHasSetted)
end
def.method("number").Select = function(self, index)
  local info = self.data[index]
  if info then
    self.select = index
    local right = self.m_panel:FindDirect("Img_Bg/Group_Right")
    self:FillSkillInfo(right, info)
  end
  self:UpdateSelect()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  elseif string.sub(id, 1, 15) == "Group_SkillZhu_" then
    local index = tonumber(string.sub(id, 16))
    self:Select(index)
  elseif string.sub(id, 1, 14) == "WingSkillIcon_" then
    local skillId = tonumber(string.sub(id, 15))
    local findRoot = self.m_panel:FindDirect("Img_Bg/Group_Right/Group_Skill/Scroll View/List")
    local cell = findRoot:FindChild(id)
    if cell and skillId then
      local bSetTarget = WingModule.IsSetTargetSkillFeatureOpen()
      if self.data[self.select].name ~= textRes.Wing[36] and bSetTarget then
        self:OnSetTargetSkillClick(skillId, cell)
      else
        require("Main.Skill.SkillTipMgr").Instance():ShowTipByIdEx(skillId, cell, 0)
      end
    end
  end
end
def.method("number", "userdata").OnSetTargetSkillClick = function(self, skillId, cell)
  local wingData = WingModule.Instance():GetWingData()
  local wingId = self.data[self.select].wingId
  local targetPosIdx = self._targetPosIdx <= 0 and 1 or self._targetPosIdx
  local bHasSetted = wingData:IsTargetSkill(wingId, skillId)
  if bHasSetted then
    targetPosIdx = wingData:GetIndexBySkillId(wingId, skillId)
    if targetPosIdx == 0 then
      warn(">>>>>TargetSkill data error.....")
      return
    end
  else
    local ResetSkillDlg = require("Main.Wing.ui.ResetSkillDlg")
    for i = 1, ResetSkillDlg.MAX_GOAL_SKILLS do
      local targetSkill = wingData:GetTargetSkillIdByIdx(wingId, i)
      if targetSkill == 0 then
        targetPosIdx = i
        break
      end
    end
  end
  local context = {
    wingId = wingId,
    wingSkillId = skillId,
    bHaveSkill = self.skillHave[skillId] == true,
    targetPosIdx = targetPosIdx,
    bHasSetted = bHasSetted
  }
  require("Main.Skill.SkillTipMgr").Instance():ShowTipByIdExWithOperates(skillId, cell, 0, context)
end
def.static("table", "table").OnGoalWingSkillChange = function(p, context)
  local self = WingSkillGallery.Instance()
  if not self:IsShow() then
    return
  end
  self:UpdateUISkillInfo()
end
def.static("table", "table").OnUnsetTargetSkill = function(p, context)
  local self = WingSkillGallery.Instance()
  if not self:IsShow() then
    return
  end
  self:UpdateUISkillInfo()
end
def.method().UpdateUISkillInfo = function(self)
  if not self:IsShow() then
    return
  end
  local index = self.select
  local info = self.data[index]
  if info then
    local right = self.m_panel:FindDirect("Img_Bg/Group_Right")
    self:FillSkillInfo(right, info)
  end
end
return WingSkillGallery.Commit()
