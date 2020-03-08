local EC = require("Types.Vector3")
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local WingsData = require("Main.Wings.data.WingsData")
local WingsDataMgr = require("Main.Wings.data.WingsDataMgr")
local WingsUtility = require("Main.Wings.WingsUtility")
local WingsInterface = require("Main.Wings.WingsInterface")
local WingsOverviewPanel = Lplus.Extend(ECPanelBase, "WingsOverviewPanel")
local def = WingsOverviewPanel.define
def.field("table").uiNodes = nil
def.field("table").skillTable = nil
def.field(WingsData).data = nil
def.field("number").fakeViewItemId = 0
local instance
def.static("=>", WingsOverviewPanel).Instance = function()
  if instance == nil then
    instance = WingsOverviewPanel()
  end
  return instance
end
def.method(WingsData).ShowPanel = function(self, data)
  if self:IsShow() then
    return
  end
  if not data then
    return
  end
  self.data = data
  self:CreatePanel(RESPATH.PREFAB_WING_OVERVIEW_PANEL, 2)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self:ClearUp()
end
def.method().ClearUp = function(self)
  self.data = nil
  self.skillTable = nil
  self.fakeViewItemId = 0
end
def.method().InitUI = function(self)
  self.uiNodes = {}
  self.uiNodes.imgBg = self.m_panel:FindDirect("Img _Bg0")
  self.uiNodes.grpAttributes = self.uiNodes.imgBg:FindDirect("Group_Attribute/Img_Bg/Container")
  self.uiNodes.gridMainSkills = self.uiNodes.imgBg:FindDirect("Group_Skill/Scroll View/Grid_Zhu")
  self.uiNodes.gridSubSkills = self.uiNodes.imgBg:FindDirect("Group_Skill/Scroll View/Grid_Fu")
  self.uiNodes.imgView = self.uiNodes.imgBg:FindDirect("Group_Look/Img_Item")
  self.uiNodes.gridPhase = self.uiNodes.imgBg:FindDirect("Group_Level/Grid_PinJie")
  self.uiNodes.lblLevel = self.uiNodes.imgBg:FindDirect("Group_Level/Label_Level")
end
def.method().UpdateUI = function(self)
  self:UpdateProperty()
  self:UpdateSkillGrid()
  self:UpdateLevelPhase()
  self:UpdateWingsView()
end
def.method().UpdateProperty = function(self)
  local propList = self.data.propList
  local propMap = WingsDataMgr.PropListToMap(propList)
  if not propMap then
    return
  end
  for i = 1, WingsDataMgr.WING_PROPERTY_NUM do
    local propRoot = self.uiNodes.grpAttributes:FindDirect("Attribute_" .. i)
    local propitem = propMap[WingsUtility.PropSeq[i]]
    if not propitem then
      return
    end
    propRoot:FindDirect("Label2"):GetComponent("UILabel"):set_text(string.format("+ %d", propitem.value))
    local colorText = string.format("[%s]%s[-]", ItemTipsMgr.Color[propitem.phase], textRes.Wings.PropPhase[propitem.phase])
    propRoot:FindDirect("Label3"):GetComponent("UILabel"):set_text(colorText)
  end
  self.uiNodes.imgBg:FindDirect("Group_Attribute/Img_Bg/Label"):GetComponent("UILabel"):set_text(textRes.Wings[35])
end
def.method().UpdateSkillGrid = function(self)
  local skillList = self.data.skillList
  self.skillTable = WingsDataMgr.SkillListToTable(skillList)
  if not self.skillTable then
    return
  end
  self:UpdateMainSkillGrids()
  self:UpdateSubSkillGrids()
end
def.method().UpdateLevelPhase = function(self)
  local level = self.data.level
  self.uiNodes.lblLevel:GetComponent("UILabel"):set_text(level)
  local phase = self.data.phase
  for i = 1, WingsDataMgr.WING_PHASE_LIMIT do
    local img = self.uiNodes.gridPhase:FindDirect(string.format("Img_QL_Sign%02d", i))
    if i <= phase then
      img:SetActive(true)
    else
      img:SetActive(false)
    end
  end
end
def.method().UpdateMainSkillGrids = function(self)
  local mainSkillTable = self.skillTable.mainSkills
  for i = 1, WingsDataMgr.WING_MAIN_SKILL_NUM do
    local cell = self.uiNodes.gridMainSkills:FindDirect("Zhu_" .. i)
    self:SetSkillCellUI(cell, mainSkillTable[i], i, true)
  end
end
def.method().UpdateSubSkillGrids = function(self)
  local subSkillTable = self.skillTable.subSkills
  local idx = 1
  for i = 1, WingsDataMgr.WING_MAIN_SKILL_NUM do
    for j = 1, WingsDataMgr.WING_SUB_SKILL_NUM do
      local cell = self.uiNodes.gridSubSkills:FindDirect("Fu_" .. idx)
      self:SetSkillCellUI(cell, subSkillTable[idx], i, false)
      idx = idx + 1
    end
  end
end
def.method("userdata", "table", "number", "boolean").SetSkillCellUI = function(self, cell, skillInfo, lineNum, isMain)
  if not cell then
    return
  end
  local texture = cell:FindDirect("Texture")
  local sprite = cell:FindDirect("Sprite")
  local label = cell:FindDirect("Label")
  if isMain then
    if skillInfo.id ~= 0 then
      texture:SetActive(true)
      GUIUtils.FillIcon(texture:GetComponent("UITexture"), skillInfo.cfg.iconId)
    else
      texture:SetActive(false)
    end
  elseif skillInfo.id ~= 0 then
    texture:SetActive(true)
    GUIUtils.FillIcon(texture:GetComponent("UITexture"), skillInfo.cfg.iconId)
  else
    texture:SetActive(false)
  end
  sprite:SetActive(false)
  label:SetActive(false)
end
def.method().UpdateWingsView = function(self)
  local wingsview = self.data.curWingsView
  if not wingsview then
    return
  end
  local wingsCfg = WingsUtility.GetWingsViewCfg(wingsview.modelId)
  if not wingsCfg then
    return
  end
  self.fakeViewItemId = wingsCfg.fakeItemId
  local uiLabelName = self.uiNodes.imgView:FindDirect("Label_ItemName"):GetComponent("UILabel")
  uiLabelName:set_text(wingsCfg.name)
  local uiTextureIcon = self.uiNodes.imgView:FindDirect("Texture_Item"):GetComponent("UITexture")
  GUIUtils.FillIcon(uiTextureIcon, wingsCfg.iconId)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  elseif string.find(id, "Zhu") or string.find(id, "Fu") then
    self:OnSkillTipsClicked(id)
  elseif id == "Texture_Item" then
    self:ShowWingsViewTip()
  elseif id == "Btn_Try" then
    self:TryOnWingsView()
  end
end
def.method("string").OnSkillTipsClicked = function(self, id)
  if not self.skillTable then
    return
  end
  local idx, cell, skillCfg
  if string.find(id, "Zhu") then
    idx = tonumber(string.sub(id, 5))
    cell = self.uiNodes.gridMainSkills:FindDirect(id)
    skillCfg = self.skillTable.mainSkills[idx]
  elseif string.find(id, "Fu") then
    idx = tonumber(string.sub(id, 4))
    cell = self.uiNodes.gridSubSkills:FindDirect(id)
    skillCfg = self.skillTable.subSkills[idx]
  end
  if not skillCfg or skillCfg.id == 0 or not skillCfg.cfg then
    return
  end
  require("Main.Skill.SkillTipMgr").Instance():ShowTipByIdEx(skillCfg.cfg.id, cell, 0)
end
def.method().ShowWingsViewTip = function(self)
  if self.fakeViewItemId == 0 then
    return
  end
  local sourceObj = self.uiNodes.imgView
  local position = sourceObj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = sourceObj:GetComponent("UISprite")
  require("Main.Item.ItemTipsMgr").Instance():ShowBasicTips(self.fakeViewItemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, false)
end
def.method().TryOnWingsView = function(self)
  local wingsview = self.data.curWingsView
  if not wingsview then
    return
  end
  require("Main.Item.ui.FittingRoomPanel").Instance():ShowWingsPanel(wingsview.modelId, wingsview.dyeId)
end
return WingsOverviewPanel.Commit()
