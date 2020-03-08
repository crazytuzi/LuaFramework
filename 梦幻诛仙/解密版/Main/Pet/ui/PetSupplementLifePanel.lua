local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetSupplementLifePanel = Lplus.Extend(ECPanelBase, "PetSupplementLifePanel")
local def = PetSupplementLifePanel.define
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PetData = Lplus.ForwardDeclare("PetData")
local PetUtility = require("Main.Pet.PetUtility")
local PetSkillMgr = require("Main.Pet.mgr.PetSkillMgr")
local PetModule = require("Main.Pet.PetModule")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local EasyItemTipHelper = require("Main.Common.EasyBasicItemTip")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local Vector = require("Types.Vector")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local MAX_SHOW_ITEM_NUM = 3
local instance
def.field("number").selectedItemIndex = 0
def.field("table").itemList = nil
def.field("table").itemFilters = nil
def.field(EasyItemTipHelper).easyItemTipHelper = nil
def.field("table").uiObjs = nil
def.static("=>", PetSupplementLifePanel).Instance = function()
  if instance == nil then
    instance = PetSupplementLifePanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_PET_SUPPLEMENT_LIFE_PANEL_RES, 1)
  self:SetModal(true)
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
  self:Clear()
end
def.override().OnCreate = function(self)
  self:InitUI()
  self.easyItemTipHelper = EasyItemTipHelper()
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PetSupplementLifePanel.OnBagInfoSynchronized)
  self:Fill()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PetSupplementLifePanel.OnBagInfoSynchronized)
  self:Clear()
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img0 = self.m_panel:FindDirect("Img0")
  self.uiObjs.Img_ItemList = {}
  for i = 1, 3 do
    self.uiObjs.Img_ItemList[i] = self.uiObjs.Img0:FindDirect(string.format("Img_Item%02d", i))
  end
  self.selectedItemIndex = 1
end
def.method().Clear = function(self)
  self.easyItemTipHelper = nil
  self.uiObjs = nil
  self.itemList = nil
  self.selectedItemIndex = 0
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Confirm" then
    self:OnConfirmButtonClicked()
  elseif string.sub(id, 1, #"Img_Item") == "Img_Item" then
    local index = tonumber(string.sub(id, #"Img_Item" + 1, -1))
    if self.itemList[index] then
      self.easyItemTipHelper:CheckItem2ShowTip(id, 0, false)
    end
    self:OnItemClick(index)
  end
end
def.method().Fill = function(self)
  self:UpdateItems()
end
def.method().UpdateItems = function(self)
  local ItemModule = require("Main.Item.ItemModule")
  local itemList = ItemModule.Instance():GetOrderedItemsByBagId(ItemModule.BAG)
  local itemFilters = PetMgr.Instance():GetSupplementLifeFilterCfgs()
  self.itemFilters = itemFilters
  local itemTypeCount = 0
  self.itemList = {}
  for i, itemFilter in ipairs(itemFilters) do
    self:UpdateItemFilterInfo(itemFilter)
    if 0 < itemFilter.itemCount then
      for i = #itemFilter.siftCfgs, 1, -1 do
        local siftCfg = itemFilter.siftCfgs[i]
        if 0 < siftCfg.num then
          itemTypeCount = itemTypeCount + 1
          self:SetItemInfo(itemTypeCount, itemFilter, siftCfg)
          if itemTypeCount >= MAX_SHOW_ITEM_NUM then
            break
          end
        end
      end
    end
    if itemTypeCount >= MAX_SHOW_ITEM_NUM then
      break
    end
  end
  if itemTypeCount == 0 then
    self:ShowEmptyItems()
  else
    self:RefreshSelectedItemIndex()
    self:HideUnsetItems(itemTypeCount + 1)
  end
end
def.method("table").UpdateItemFilterInfo = function(self, itemFilter)
  local itemCount = 0
  for i, siftCfg in ipairs(itemFilter.siftCfgs) do
    local itemId = siftCfg.idvalue
    local count = ItemModule.Instance():GetItemCountById(itemId)
    itemCount = itemCount + count
    siftCfg.num = count
  end
  itemFilter.itemCount = itemCount
end
def.method("number", "table", "table").SetItemInfo = function(self, index, itemFilter, siftCfg)
  if index > MAX_SHOW_ITEM_NUM then
    return
  end
  local gridItem = self.uiObjs.Img_ItemList[index]
  gridItem:SetActive(true)
  local itemCount = siftCfg.num
  local uiLabel_Num = gridItem:FindDirect(string.format("Label_Num%02d", index)):GetComponent("UILabel")
  uiLabel_Num.text = itemCount
  if itemCount == 0 then
    uiLabel_Num:set_color(Color.red)
  else
    uiLabel_Num:set_color(Color.white)
  end
  local itemId = siftCfg.idvalue
  local iconId = itemFilter.icon
  local uiTexture = gridItem:FindDirect(string.format("Img_Icon%02d", index)):GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, iconId)
  local clickedObj = gridItem
  self.itemList[index] = {itemId = itemId, num = itemCount}
  self.easyItemTipHelper:RegisterItem2ShowTip(itemId, clickedObj)
end
def.method("number").HideUnsetItems = function(self, startIndex)
  if startIndex > MAX_SHOW_ITEM_NUM then
    return
  end
  for i = startIndex, MAX_SHOW_ITEM_NUM do
    self.uiObjs.Img_ItemList[i]:SetActive(false)
  end
end
def.method("number").OnItemClick = function(self, index)
  self.selectedItemIndex = index
end
def.method().OnConfirmButtonClicked = function(self)
  local pet = PetMgr.Instance():GetFightingPet()
  if pet == nil then
    warn("No fighting pet!")
    return
  end
  local index = self.selectedItemIndex
  if index == 0 then
    return
  end
  if 0 < #self.itemList then
    local item = self.itemList[index]
    if item == nil then
      return
    end
    local itemKey = self:FetchOneItem(item.itemId)
    if itemKey == -1 then
      Toast(textRes.Pet[106])
      return
    end
    local pet = PetMgr.Instance():GetFightingPet()
    local result = PetMgr.Instance():UseItem(pet.id, itemKey, ItemType.PET_LIFE_ITEM)
    if result == PetMgr.CResult.PET_LIFE_REACH_MAX then
      Toast(textRes.Pet[73])
    end
  else
    Toast(textRes.Pet[106])
  end
end
def.method("number", "=>", "number").FetchOneItem = function(self, itemId)
  local itemKey = -1
  local items = ItemModule.Instance():GetOrderedItemsByBagId(ItemModule.BAG)
  for i, item in ipairs(items) do
    if item.id == itemId then
      itemKey = item.itemKey
      break
    end
  end
  return itemKey
end
def.method().ShowEmptyItems = function(self)
  for i, itemFilter in ipairs(self.itemFilters) do
    self:ShowEmptyItem(i, itemFilter)
  end
end
def.method("number", "table").ShowEmptyItem = function(self, index, itemFilter)
  local gridItem = self.uiObjs.Img_ItemList[index]
  gridItem:SetActive(true)
  local uiLabel_Num = gridItem:FindDirect(string.format("Label_Num%02d", index)):GetComponent("UILabel")
  uiLabel_Num.text = 0
  uiLabel_Num:set_color(Color.red)
  local iconId = itemFilter.icon
  local uiTexture = gridItem:FindDirect(string.format("Img_Icon%02d", index)):GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, iconId)
end
def.method().ShowSkillBookSource = function(self)
  local sourceObj = self.uiObjs.Group_Empty:FindDirect("Btn_Channel")
  local sourceItemId = PetMgr.SKILL_BOOK_SOURCE_ITEM_ID
  local position = sourceObj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = sourceObj:GetComponent("UIWidget")
  local tip = ItemTipsMgr.Instance():ShowBasicTips(sourceItemId, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0, true)
end
def.method().RefreshSelectedItemIndex = function(self)
  if self.selectedItemIndex == 0 then
    return
  end
  local itemCount = #self.itemList
  if itemCount < self.selectedItemIndex then
    self.selectedItemIndex = itemCount
  end
  self:UpdateSelectedItemIndex()
end
def.method().UpdateSelectedItemIndex = function(self)
  local index = self.selectedItemIndex
  local Img_Item = self.uiObjs.Img_ItemList[index]
  local uiToggle = Img_Item:GetComponent("UIToggle")
  if uiToggle then
    uiToggle:set_value(true)
  end
end
def.static("table", "table").OnBagInfoSynchronized = function(params, context)
  instance:UpdateItems()
end
return PetSupplementLifePanel.Commit()
