local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemUtils = require("Main.Item.ItemUtils")
local FabaoMgr = require("Main.Fabao.FabaoMgr")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local EquipModule = require("Main.Equip.EquipModule")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local SkillTipMgr = require("Main.Skill.SkillTipMgr")
local PreviewPanel = Lplus.Extend(ECPanelBase, "PreviewPanel")
local def = PreviewPanel.define
def.field("number").m_CurIndex = 1
def.field("table").m_ListData = nil
def.field("table").m_AttriData = nil
def.field("table").m_SkillData = nil
def.field("table").m_UIGO = nil
local instance
def.static("=>", PreviewPanel).Instance = function()
  if not instance then
    instance = PreviewPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_FABAO_DETAIL_PANEL, GUILEVEL.MUTEX)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:Update()
end
def.override().OnDestroy = function(self)
  self.m_CurIndex = 1
  self.m_ListData = nil
  self.m_AttriData = nil
  self.m_SkillData = nil
  self.m_UIGO = nil
end
def.method("string").onClick = function(self, id)
  print(string.format("%s click event: id = %s", tostring(self), id))
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id:find("Group_ListItem1_") == 1 then
    local _, lastIndex = id:find("Group_ListItem1_")
    local index = tonumber(id:sub(lastIndex + 1, id:len()))
    local item = self.m_ListData[index]
    if not item then
      return
    end
    self.m_CurIndex = index
    self:UpdataMainView()
  elseif id:find("Group_Skill_") == 1 then
    local _, lastIndex = id:find("Group_Skill_")
    local index = tonumber(id:sub(lastIndex + 1, id:len()))
    local skillCfg = self.m_SkillData[index]
    local btnGO = self.m_UIGO[id]
    if not skillCfg or not btnGO then
      return
    end
    SkillTipMgr.Instance():ShowTipByIdEx(skillCfg.cfg.id, btnGO, 0)
  end
end
def.method("number").UpdateCurIndex = function(self, id)
  local items = self.m_ListData
  if not items then
    return
  end
  for k, v in pairs(items) do
    if v.id == id then
      self.m_CurIndex = k
    end
  end
end
def.method().UpdataSkillData = function(self)
  local item = self.m_ListData[self.m_CurIndex]
  if not item then
    return
  end
  self.m_SkillData = {}
  local skillCfg = FabaoMgr.GetFabaoEffectCfg(item.id)
  table.sort(skillCfg, function(l, r)
    if l and r then
      return l.specific
    else
      return false
    end
  end)
  for k, v in pairs(skillCfg) do
    self.m_SkillData[k] = {}
    self.m_SkillData[k].specific = v.specific
    self.m_SkillData[k].cfg = FabaoMgr.GetFabaoEffectSkillCfg(v.skillId, 0)
  end
end
def.method().UpdateData = function(self)
  local _, itemData = FabaoMgr.GetFabaoItems()
  self.m_ListData = itemData
  self.m_AttriData = FabaoMgr.GetFabaoAllAttribute()
end
def.method().InitUI = function(self)
  self.m_UIGO = {}
  self.m_UIGO.Grid_List = self.m_panel:FindDirect("Img_JD/Group_List/Scroll View_List/Grid_List")
  self.m_UIGO.Texture_Icon = self.m_panel:FindDirect("Img_JD/Group_Describe/Img_BgIcon/Texture_Icon")
  self.m_UIGO.Label_Describe = self.m_panel:FindDirect("Img_JD/Group_Describe/Label_Describe")
  self.m_UIGO.List_Attribute = self.m_panel:FindDirect("Img_JD/Group_Attribute/Scroll View/List_Attribute")
  self.m_UIGO.List_Skill = self.m_panel:FindDirect("Img_JD/Group_Skill/Scroll View/List_Skill")
end
def.method().UpdateListView = function(self)
  local uiListGO = self.m_UIGO.Grid_List
  local itemCount = #self.m_ListData
  local listItems = GUIUtils.InitUIList(uiListGO, itemCount)
  self.m_msgHandler:Touch(uiListGO)
  for i = 1, itemCount do
    local itemGO = listItems[i]
    local itemData = self.m_ListData[i]
    local iconGO = itemGO:FindDirect(("Group_Icon_%d/Icon_Equip01_%d"):format(i, i))
    local labelGO = itemGO:FindDirect(("Label_Name_%d"):format(i))
    local itemBase = ItemUtils.GetItemBase(itemData.id)
    GUIUtils.SetTexture(iconGO, itemBase.icon)
    GUIUtils.SetText(labelGO, itemBase.name)
  end
  GUIUtils.Reposition(uiListGO, GUIUtils.COTYPE.LIST, 0)
end
def.method().UpdataTopView = function(self)
  local itemData = self.m_ListData[self.m_CurIndex]
  local iconGO = self.m_UIGO.Texture_Icon
  local descGO = self.m_UIGO.Label_Describe
  local itemBase = ItemUtils.GetItemBase(itemData.id)
  GUIUtils.SetTexture(iconGO, itemBase.icon)
  GUIUtils.SetText(descGO, itemBase.desc)
end
def.method().UpdateLeftBottomView = function(self)
  local uiListGO = self.m_UIGO.List_Attribute
  local itemCount = #self.m_AttriData
  local listItems = GUIUtils.InitUIList(uiListGO, itemCount)
  self.m_msgHandler:Touch(uiListGO)
  for i = 1, itemCount do
    local itemGO = listItems[i]
    local itemData = self.m_AttriData[i]
    local nameGO = itemGO:FindDirect(("Label_Name_%d"):format(i))
    local numGO = itemGO:FindDirect(("Label_Num_%d"):format(i))
    local attriName = EquipModule.GetAttriName(itemData.attrId)
    GUIUtils.SetText(nameGO, attriName)
    GUIUtils.SetText(numGO, ("+ %d"):format(itemData.initValue))
  end
  GUIUtils.Reposition(uiListGO, GUIUtils.COTYPE.LIST, 0)
end
def.method().UpdateRightBottomView = function(self)
  local uiListGO = self.m_UIGO.List_Skill
  local itemCount = #self.m_SkillData
  local listItems = GUIUtils.InitUIList(uiListGO, itemCount)
  self.m_msgHandler:Touch(uiListGO)
  for i = 1, itemCount do
    local itemGO = listItems[i]
    local itemData = self.m_SkillData[i]
    local nameGO = itemGO:FindDirect(("Label_Name_%d"):format(i))
    local iconGO = itemGO:FindDirect(("Item_001_%d/Img_Icon_%d"):format(i, i))
    local newGO = itemGO:FindDirect(("Item_001_%d/Img_New_%d"):format(i, i))
    GUIUtils.SetText(nameGO, itemData.cfg.name)
    GUIUtils.SetTexture(iconGO, itemData.cfg.icon)
    GUIUtils.SetActive(newGO, itemData.specific)
    self.m_UIGO[("Group_Skill_%d"):format(i)] = itemGO
  end
  GUIUtils.Reposition(uiListGO, GUIUtils.COTYPE.LIST, 0)
end
def.method().UpdataMainView = function(self)
  self:UpdataSkillData()
  self:UpdataTopView()
  self:UpdateRightBottomView()
end
def.method().Update = function(self)
  self:UpdateListView()
  self:UpdateLeftBottomView()
  self:UpdataMainView()
end
return PreviewPanel.Commit()
