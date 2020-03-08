local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECGUIMan = require("GUI.ECGUIMan")
local EquipStrenItemChoosePanel = Lplus.Extend(ECPanelBase, "EquipStrenItemChoosePanel")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local EquipUtils = require("Main.Equip.EquipUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local def = EquipStrenItemChoosePanel.define
local instance
def.const("table").Type = {LuckyFu = 1, Stone = 2}
def.const("table").Position = {
  LuckyFu = {x = 190, y = -28},
  Stone = {x = 290, y = -28}
}
def.field("number").type = 0
def.field("table").luckyFuTbl = nil
def.field("function").callback = nil
def.field("table").tag = nil
def.static("=>", EquipStrenItemChoosePanel).Instance = function()
  if instance == nil then
    instance = EquipStrenItemChoosePanel()
    instance:Init()
  end
  return instance
end
def.override().OnCreate = function(self)
  self:UpdateInfo()
end
def.method().Init = function(self)
  self.luckyFuTbl = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_EQUIP_STREN_ITEM_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local luckyInfo = {}
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    luckyInfo.id = DynamicRecord.GetIntValue(entry, "id")
    luckyInfo.sucRate = DynamicRecord.GetIntValue(entry, "sucRate")
    table.insert(self.luckyFuTbl, luckyInfo)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("number", "function", "table").ShowPanel = function(self, itemType, callback, tag)
  self.type = itemType
  self.callback = callback
  self.tag = tag
  self:CreatePanel(RESPATH.PREFAB_STEN_ITEM_PANEL, 0)
  self:SetOutTouchDisappear()
end
def.override().OnDestroy = function(self)
  self.type = 0
  self.callback = nil
  self.tag = nil
end
def.method().Hide = function(self)
  self:DestroyPanel()
  self = nil
end
def.method().UpdateInfo = function(self)
  if self.type == EquipStrenItemChoosePanel.Type.LuckyFu then
    self:UpdateLuckFuInfo()
  elseif self.type == EquipStrenItemChoosePanel.Type.Stone then
    self:UpdateStoneInfo()
  end
end
def.method().UpdateLuckFuInfo = function(self)
  local Group_Item = self.m_panel:FindDirect("Group_Item")
  for i = 1, 3 do
    local Img_BgItem = Group_Item:FindDirect(string.format("Img_BgItem0%d", i))
    Img_BgItem:SetActive(true)
    local itemId = self.luckyFuTbl[i].id
    self:FillItemInfo(Img_BgItem, itemId)
  end
end
def.method().UpdateStoneInfo = function(self)
  local Group_Item = self.m_panel:FindDirect("Group_Item")
  for i = 1, 3 do
    local Img_BgItem = Group_Item:FindDirect(string.format("Img_BgItem0%d", i))
    if i > 1 then
      Img_BgItem:SetActive(false)
    else
      Img_BgItem:SetActive(true)
      local itemId = EquipUtils.GetEquipStrenZhenlingfuItemId()
      self:FillItemInfo(Img_BgItem, itemId)
    end
  end
end
def.method("userdata", "number").FillItemInfo = function(self, itemUI, itemId)
  local itemBase = ItemUtils.GetItemBase(itemId)
  local Icon_Item = itemUI:FindDirect("Icon_Item"):GetComponent("UITexture")
  local Label_EquipName = itemUI:FindDirect("Label_EquipName"):GetComponent("UILabel")
  local Label_Num = itemUI:FindDirect("Label_Num"):GetComponent("UILabel")
  GUIUtils.FillIcon(Icon_Item, itemBase.icon)
  Label_EquipName:set_text(itemBase.name)
  local have = ItemModule.Instance():GetItemCountById(itemId)
  Label_Num:set_text(string.format(textRes.Equip[303], have))
end
def.method("number").RequireToSelectItem = function(self, itemId)
  local have = ItemModule.Instance():GetItemCountById(itemId)
  if have == 0 then
    self:ShowTips(itemId)
  else
    self.callback(self.tag, itemId)
    self:Hide()
  end
end
def.method("number").ShowTips = function(self, itemId)
  local clickobj = self.m_panel:FindDirect("Img_Bg1")
  local position = clickobj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = clickobj:GetComponent("UISprite")
  ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, true)
end
def.method("number", "boolean").OnItemClick = function(self, index, bSelect)
  if self.type == EquipStrenItemChoosePanel.Type.LuckyFu then
    local itemId = self.luckyFuTbl[index].id
    if bSelect then
      self:RequireToSelectItem(itemId)
    else
      self:ShowTips(itemId)
    end
  elseif self.type == EquipStrenItemChoosePanel.Type.Stone then
    local itemId = EquipUtils.GetEquipStrenZhenlingfuItemId()
    if bSelect then
      self:RequireToSelectItem(itemId)
    else
      self:ShowTips(itemId)
    end
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Icon_Item" == id then
    local index = tonumber(string.sub(clickobj.parent.name, #"Img_BgItem0" + 1, -1))
    self:OnItemClick(index, false)
  elseif string.sub(id, 1, #"Img_BgItem0") == "Img_BgItem0" then
    local index = tonumber(string.sub(id, #"Img_BgItem0" + 1, -1))
    self:OnItemClick(index, true)
  end
end
return EquipStrenItemChoosePanel.Commit()
