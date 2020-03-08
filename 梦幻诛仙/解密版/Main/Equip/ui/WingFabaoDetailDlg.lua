local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local WingFabaoDetailDlg = Lplus.Extend(ECPanelBase, "WingFabaoDetailDlg")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local GUIUtils = require("GUI.GUIUtils")
local SkillUtility = require("Main.Skill.SkillUtility")
local MathHelper = require("Common.MathHelper")
local EquipModule = require("Main.Equip.EquipModule")
local Vector = require("Types.Vector")
local def = WingFabaoDetailDlg.define
def.field("number").itemId = 0
def.field("number").sourceX = 0
def.field("number").sourceY = 0
def.field("number").sourceW = 0
def.field("number").sourceH = 0
def.field("number").prefer = 0
def.field("string").rename = ""
def.static("number", "number", "number", "number", "number", "number", "string").ShowEquipInfo = function(itemId, sourceX, sourceY, sourceW, sourceH, prefer, rename)
  local dlg = WingFabaoDetailDlg()
  dlg.itemId = itemId
  dlg.sourceX = sourceX
  dlg.sourceY = sourceY
  dlg.sourceW = sourceW
  dlg.sourceH = sourceH
  dlg.prefer = prefer
  dlg.rename = rename
  dlg:CreatePanel(RESPATH.PREFAB_WINGFABAO_INFO_PANEL, 2)
  dlg:SetOutTouchDisappear()
end
def.override().OnCreate = function(self)
  local itemBase = ItemUtils.GetItemBase(self.itemId)
  self:SetTitle(itemBase)
  self:SetAttr(itemBase)
  self:Adjust()
  if self.rename ~= "" then
    self.m_panelName = self.rename
    self.m_panel.name = self.rename
  end
end
def.method("table").SetTitle = function(self, itemBase)
  local titleLabel = self.m_panel:FindDirect("Table_Bg1/Group_Top/Img_Bg/Label_Title"):GetComponent("UILabel")
  local iconTexture = self.m_panel:FindDirect("Table_Bg1/Group_Top/Equip_Info/Img_Item/Img_Icon"):GetComponent("UITexture")
  local nameLabel = self.m_panel:FindDirect("Table_Bg1/Group_Top/Equip_Info/Label_Name"):GetComponent("UILabel")
  local typeLabel = self.m_panel:FindDirect("Table_Bg1/Group_Top/Equip_Info/Label_Type"):GetComponent("UILabel")
  local type = itemBase.itemType
  if type == ItemType.WING_ITEM then
    titleLabel:set_text(textRes.Item[8355])
  elseif type == ItemType.FABAO_ITEM then
    titleLabel:set_text(textRes.Item[8354])
  end
  GUIUtils.FillIcon(iconTexture, itemBase.icon)
  nameLabel:set_text(itemBase.name)
  typeLabel:set_text(itemBase.itemTypeName)
end
def.method("table").SetAttr = function(self, itemBase)
  local nameLabel = self.m_panel:FindDirect("Table_Bg1/Group_Top/Equip_Info/Label_Content1"):GetComponent("UILabel")
  local scopeLabel = self.m_panel:FindDirect("Table_Bg1/Group_Top/Equip_Info/Label_Content2"):GetComponent("UILabel")
  local skillLabel = self.m_panel:FindDirect("Table_Bg1/Group_Top/Equip_Info/Title_Teji/Label_TejiTitle"):GetComponent("UILabel")
  if itemBase.itemType == ItemType.WING_ITEM then
  elseif itemBase.itemType == ItemType.FABAO_ITEM then
  end
end
def.method("number").SetSkill = function(self, skillId)
  local skills = SkillUtility.GetMonsterSkillCfg(skillId)
  local root = self.m_panel:FindDirect("Table_Bg1/Group_TeJiContent")
  local template = root:FindDirect("Label_TejiContent1")
  template:SetActive(false)
  for k, v in ipairs(skills) do
    local skillId = v
    local skillName = SkillUtility.GetSkillCfg(skillId).name
    local itemNew = Object.Instantiate(template)
    itemNew:set_name("skill_" .. skillId)
    itemNew.parent = root
    itemNew:set_localScale(Vector.Vector3.one)
    itemNew:GetComponent("UILabel"):set_text(string.format("[%s]", skillName))
    itemNew:SetActive(true)
  end
  root:GetComponent("UIGrid"):Reposition()
end
def.method().Adjust = function(self)
  self:SetLayer(ClientDef_Layer.Invisible)
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if self.m_panel == nil then
      return
    end
    local tipFrame = self.m_panel:FindDirect("Table_Bg1")
    if tipFrame == nil then
      return
    end
    local uiTable = tipFrame:GetComponent("UITableResizeBackground")
    uiTable:Reposition()
    GameUtil.AddGlobalLateTimer(0.01, true, function()
      if tipFrame == nil or tipFrame.isnil then
        return
      end
      local bg = tipFrame:GetComponent("UISprite")
      local x, y = MathHelper.ComputeTipsAutoPosition(self.sourceX, self.sourceY, self.sourceW, self.sourceH, bg:get_width(), bg:get_height(), self.prefer)
      tipFrame:set_localPosition(Vector.Vector3.new(x, y + bg:get_height() / 2, 0))
      self:SetLayer(ClientDef_Layer.UI)
    end)
    self:TouchGameObject(self.m_panel, self.m_parent)
  end)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
    self = nil
  elseif string.find(id, "skill_") then
    local index = tonumber(string.sub(id, 7))
    local source = self.m_panel:FindDirect("Table_Bg1/Group_TeJiContent/" .. id)
    local position = source:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local label = source:GetComponent("UILabel")
    require("Main.Skill.SkillTipMgr").Instance():ShowPetTip(index, screenPos.x, screenPos.y - label:get_height() / 2, label:get_width(), label:get_height(), 0)
  end
end
WingFabaoDetailDlg.Commit()
return WingFabaoDetailDlg
