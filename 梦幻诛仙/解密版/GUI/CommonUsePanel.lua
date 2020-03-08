local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECGUIMan = require("GUI.ECGUIMan")
local CommonUsePanel = Lplus.Extend(ECPanelBase, "CommonUsePanel")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemModule = require("Main.Item.ItemModule")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local def = CommonUsePanel.define
def.const("table").Source = ItemTipsMgr.Source
def.field("number").selectedIndex = 0
def.field("table").itemList = nil
def.field("function").filterFunc = nil
def.field("function").sortFunc = nil
def.field("function").callbackFunc = nil
def.field("function").allUseCallbackFunc = nil
def.field("number").source = 0
def.field("table").useTrace = nil
def.field("table").tag = nil
def.field("table").pos = nil
def.field("table").uiObjs = nil
def.field("string").originalTitle = ""
def.field("table").itemIdList = nil
def.field("string").descText = ""
def.const("number").ALL_USE_TRIGGER_TIMES = 3
local instance
def.static("=>", CommonUsePanel).Instance = function()
  if instance == nil then
    instance = CommonUsePanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.pos = {x = 268, y = 0}
  self.useTrace = {}
end
def.method("function", "function", "number", "table", "=>", "table").ShowPanel = function(self, filterFunc, sortFunc, source, tag)
  self.filterFunc = filterFunc
  self.sortFunc = sortFunc
  self.source = source
  self.tag = tag
  if self:IsShow() then
    self:DestroyPanel()
  end
  self.itemList = self:GenItemList()
  if #self.itemList == 0 and self:ShowNoneItemInfo() then
    self:Clear()
    return self
  end
  self:CreatePanel(RESPATH.PREFAB_COMMON_USE_PANEL, 2)
  self:SetModal(true)
  return self
end
def.method("function", "function", "number", "table", "table", "=>", "table").ShowPanelWithItems = function(self, filterFunc, sortFunc, source, items, tag)
  self.filterFunc = filterFunc
  self.sortFunc = sortFunc
  self.source = source
  self.tag = tag
  if self:IsShow() then
    self:DestroyPanel()
  end
  self.itemList = items
  if #self.itemList == 0 and self:ShowNoneItemInfo() then
    self:Clear()
    return self
  end
  self:CreatePanel(RESPATH.PREFAB_COMMON_USE_PANEL, 2)
  self:SetModal(true)
  return self
end
def.method("function").SetAllUseCallback = function(self, callbackFunc)
  self.allUseCallbackFunc = callbackFunc
end
def.method("table").SetItemIdList = function(self, itemIdList)
  self.itemIdList = itemIdList
end
def.method("string").SetDescText = function(self, descText)
  self.descText = descText
  if self:IsShow() then
    self:UpdateDescText()
  end
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, CommonUsePanel.OnBagInfoSynchronized)
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, CommonUsePanel.OnBagInfoSynchronized)
  self:Clear()
end
def.method("string").onClick = function(self, id)
  self:CheckToUnselect()
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  elseif string.sub(id, 1, #"Img_BgItem_") == "Img_BgItem_" then
    local index = tonumber(string.sub(id, #"Img_BgItem_" + 1, -1))
    self:OnItemClicked(index)
  elseif id == "Btn_Use" then
    self:OnUseButtonClicked()
  end
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg1 = self.m_panel:FindDirect("Img_Bg1")
  self.uiObjs.Label_Tips = self.uiObjs.Img_Bg1:FindDirect("Label_Tips")
  self.uiObjs.GridObj = self.uiObjs.Img_Bg1:FindDirect("Scroll View/Grid")
  local template = self.uiObjs.GridObj:FindDirect("Img_BgItem1")
  template.name = "Img_BgItem_0"
  template:SetActive(false)
  self.uiObjs.GridItemTemplate = template
  self.uiObjs.Img_Bg1:FindDirect("Btn_Use"):SetActive(false)
  self.originalTitle = self.uiObjs.Label_Tips:GetComponent("UILabel").text
  self.uiObjs.Label_UseNumber = self.uiObjs.Img_Bg1:FindDirect("Label_UseNumber")
  GUIUtils.SetText(self.uiObjs.Label_UseNumber, self.descText)
end
def.method().UpdateUI = function(self)
  self:SetItemList(self.itemList)
  self:UpdatePos()
  self:UpdateDescText()
end
def.method("=>", "table").GenItemList = function(self)
  local itemList = ItemModule.Instance():GetOrderedItemsByBagId(ItemModule.BAG)
  local filtededList = {}
  for i, item in ipairs(itemList) do
    if self:Filter(item) then
      table.insert(filtededList, item)
    end
  end
  self:Sort(filtededList)
  return filtededList
end
def.method("table", "=>", "boolean").Filter = function(self, item)
  if self.filterFunc == nil then
    return true
  end
  return self.filterFunc(item, self.tag)
end
def.method("table").Sort = function(self, itemList)
  if self.sortFunc == nil then
    return
  end
  table.sort(itemList, self.sortFunc)
end
def.method("table").SetItemList = function(self, itemList)
  local itemCount = #itemList
  self:ResizeItemListGrid(itemCount)
  local uiGrid = self.uiObjs.GridObj:FindDirect("UIGrid")
  for i, pet in ipairs(itemList) do
    self:SetItemListElement(i, pet)
  end
  if itemCount > 0 then
    self:SetPanelTitle(self.originalTitle)
  else
    self:SetPanelTitle(textRes.Common[39])
  end
end
def.method("number").ResizeItemListGrid = function(self, count)
  local uiGrid = self.uiObjs.GridObj:GetComponent("UIGrid")
  local gridItemCount = uiGrid:GetChildListCount()
  if count > gridItemCount then
    for i = gridItemCount + 1, count do
      local gridItem = GameObject.Instantiate(self.uiObjs.GridItemTemplate)
      gridItem.name = "Img_BgItem_" .. i
      gridItem.transform.parent = self.uiObjs.GridObj.transform
      gridItem.transform.localScale = Vector.Vector3.one
      gridItem:SetActive(true)
    end
  elseif count < gridItemCount then
    for i = gridItemCount, count + 1, -1 do
      local gridItem = self.uiObjs.GridObj:FindDirect("Img_BgItem_" .. i)
      if not _G.IsNil(gridItem) then
        gridItem.transform.parent = nil
        GameObject.Destroy(gridItem)
      end
    end
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
  uiGrid:Reposition()
end
local GUIUtils = require("GUI.GUIUtils")
def.method("number", "table").SetItemListElement = function(self, index, item)
  local gridItem = self.uiObjs.GridObj:FindDirect("Img_BgItem_" .. index)
  gridItem:FindDirect("Label_Num"):GetComponent("UILabel").text = item.number
  local itemBase = ItemUtils.GetItemBase(item.id)
  local iconId = itemBase.icon
  local uiTexture = gridItem:FindDirect("Texture"):GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, iconId)
  local bang = gridItem:FindDirect("Img_Bang")
  local zhuan = gridItem:FindDirect("Img_Zhuan")
  local rarity = gridItem:FindDirect("Img_Xiyou")
  if bang and zhuan then
    if itemBase.isProprietary then
      bang:SetActive(false)
      zhuan:SetActive(true)
      GUIUtils.SetActive(rarity, false)
    elseif ItemUtils.IsItemBind(item) then
      bang:SetActive(true)
      zhuan:SetActive(false)
      GUIUtils.SetActive(rarity, false)
    elseif ItemUtils.IsRarity(item.id) then
      bang:SetActive(false)
      zhuan:SetActive(false)
      GUIUtils.SetActive(rarity, true)
    else
      bang:SetActive(false)
      zhuan:SetActive(false)
      GUIUtils.SetActive(rarity, false)
    end
  end
end
def.method("number", "number").SetPos = function(self, x, y)
  self.pos.x = x
  self.pos.y = y
  self:UpdatePos()
end
def.method().UpdatePos = function(self)
  if self.m_panel == nil then
    return
  end
  local x, y = self.pos.x, self.pos.y
  self.uiObjs.Img_Bg1.transform.localPosition = Vector.Vector3.new(x, y, 0)
end
def.method().UpdateDescText = function(self)
  GUIUtils.SetText(self.uiObjs.Label_UseNumber, self.descText)
end
def.method("number").OnItemClicked = function(self, index)
  self:SelectItem(index)
end
def.method("number").SelectItem = function(self, index)
  self.selectedIndex = index
  self:SetItemObjToggleState(index, true)
  self:ShowItemTip(index)
end
def.method("number", "boolean").SetItemObjToggleState = function(self, index, state)
  local itemObj = self.uiObjs.GridObj:FindDirect("Img_BgItem_" .. index)
  if itemObj then
    itemObj:GetComponent("UIToggle").value = state
  end
end
def.method("number").ShowItemTip = function(self, index)
  local item = self.itemList[index]
  if item == nil then
    return
  end
  local itemId = item.id
  local itemKey = item.itemKey
  local source = self.uiObjs.Img_Bg1
  local position = source:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = source:GetComponent("UIWidget")
  local tip = ItemTipsMgr.Instance():ShowTips(item, ItemModule.BAG, itemKey, self.source, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0)
  tip:SetOperateContext(self.tag)
end
def.method("=>", "boolean").ShowNoneItemInfo = function(self)
  if self.itemIdList and #self.itemIdList > 0 then
    self:ShowNoneItemTip()
    return true
  end
  return false
end
def.method().ShowNoneItemTip = function(self)
  local tip = ItemTipsMgr.Instance():ShowMutilItemBasicTipsEx(self.itemIdList, {
    x = 0,
    y = 0,
    vAlign = "center"
  }, true)
end
def.method("string").SetPanelTitle = function(self, title)
  self.uiObjs.Label_Tips:GetComponent("UILabel").text = title
end
def.method().OnUseButtonClicked = function(self)
  if #self.itemList == 0 then
    Toast(textRes.Common[33])
    return
  end
  if self.selectedIndex == 0 then
    Toast(textRes.Common[34])
    return
  end
  self:Callback()
end
def.method().Callback = function(self)
  if self.callbackFunc then
    local item = self.itemList[self.selectedIndex]
    self.callbackFunc(item, self.tag)
    self:TraceUse(item)
  end
end
def.method("table").TraceUse = function(self, item)
  if self.useTrace.lastItemKey == item.itemKey then
    self.useTrace.count = self.useTrace.count + 1
    if self.useTrace.count >= CommonUsePanel.ALL_USE_TRIGGER_TIMES then
      self:AllUse(item)
    end
  else
    self.useTrace.lastItemKey = item.itemKey
    self.useTrace.count = 0
  end
end
def.method("table").AllUse = function(self, item)
  self.useTrace = {}
  if self.allUseCallbackFunc then
    self.allUseCallbackFunc(item)
  end
end
def.method().CheckToUnselect = function(self)
  if self.selectedIndex ~= 0 then
    self:SetItemObjToggleState(self.selectedIndex, false)
    self.selectedIndex = 0
  end
end
def.static("table", "table").OnBagInfoSynchronized = function()
  local self = instance
  self.itemList = self:GenItemList()
  self:UpdateUI()
end
def.method().Clear = function(self)
  self.uiObjs = nil
  self.selectedIndex = 0
  self.pos = {x = 268, y = 0}
  self.useTrace = {}
  self.allUseCallbackFunc = nil
  self.itemIdList = nil
  self.tag = nil
  self.descText = ""
end
CommonUsePanel.Commit()
return CommonUsePanel
