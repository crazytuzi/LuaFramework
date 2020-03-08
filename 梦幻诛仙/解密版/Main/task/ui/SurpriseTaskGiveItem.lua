local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local SurpriseTaskGiveItem = Lplus.Extend(ECPanelBase, "SurpriseTaskGiveItem")
local SurpriseTaskMgr = require("Main.task.SurpriseTaskMgr")
local TaskNeedItemType = require("consts.mzm.gsp.activity3.confbean.TaskNeedItemType")
local ItemData = require("Main.Item.ItemData")
local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local def = SurpriseTaskGiveItem.define
local instance
def.field("number").serverId = 0
def.field("number").libId = 0
def.field("number").itemType = 0
def.field("number").curTabIdx = 1
def.field("table").curItemList = nil
def.field("table").selectedItems = nil
def.field("table").itemKey2Index = nil
def.static("=>", SurpriseTaskGiveItem).Instance = function()
  if not instance then
    instance = SurpriseTaskGiveItem()
  end
  return instance
end
def.method("number").ShowPanel = function(self, serverId)
  if self:IsShow() then
    return
  end
  self.serverId = serverId
  local surpriseCfg = SurpriseTaskMgr.GetSurpriseItemTaskCfg(serverId)
  self.libId = surpriseCfg.itemConId
  self.itemType = surpriseCfg.itemType
  self:CreatePanel(RESPATH.PREFAB_MISSION_TARGET, GUILEVEL.NORMAL)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, SurpriseTaskGiveItem.OnBagInfoSynchronized)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.GO_TO_NPC_SHOP_BUY_ITEM, SurpriseTaskGiveItem.OnGotoNPCShop)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, SurpriseTaskGiveItem.OnBagInfoSynchronized)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.GO_TO_NPC_SHOP_BUY_ITEM, SurpriseTaskGiveItem.OnGotoNPCShop)
end
def.static("table", "table").OnGotoNPCShop = function(p1, p2)
  if instance and instance:IsShow() then
    instance:Hide()
  end
end
def.static("table", "table").OnBagInfoSynchronized = function(p1, p2)
  if instance and instance:IsShow() then
    instance:setItemList()
  end
end
def.override("boolean").OnShow = function(self, bs)
  if bs then
    self.selectedItems = {}
    self:setItemList()
    self:setSelectedItemList()
  else
    self.serverId = 0
    self.libId = 0
    self.itemType = 0
    self.curTabIdx = 1
    self.curItemList = nil
    self.selectedItems = nil
    self.itemKey2Index = nil
  end
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("userdata").onClickObj = function(self, clicObj)
  local id = clicObj.name
  local strs = string.split(id, "_")
  if id == "Btn_Close" then
    self:Hide()
  elseif id == "Btn_Confirm" then
    self:confirmCommit()
  elseif strs[1] == "Group" and strs[2] == "BuyItem" then
    local idx = tonumber(strs[3])
    if idx then
      local uitoggle = clicObj:GetComponent("UIToggle")
      local itemInfo = self.curItemList[idx]
      local index = self.itemKey2Index[itemInfo.itemKey]
      if uitoggle.value then
        local lastItem = self.selectedItems[index]
        if lastItem then
          for i, v in ipairs(self.curItemList) do
            if v.itemKey == lastItem.itemKey then
              local List_Item = self.m_panel:FindDirect("Img_Bg0/Group_Item/Scrollview_Item/List_Item")
              local Group_BuyItem = List_Item:FindDirect("Group_BuyItem_" .. i)
              if Group_BuyItem then
                Group_BuyItem:GetComponent("UIToggle").value = false
              end
              break
            end
          end
        end
        self.selectedItems[index] = itemInfo
      else
        self.selectedItems[index] = nil
      end
    end
    self:setSelectedItemList()
  elseif strs[1] == "Img" and strs[2] == "BgItem" then
    local idx = tonumber(strs[3])
    if idx then
      local itemInfo = self.curItemList[idx]
      self:displayItemTips(itemInfo.id, clicObj)
    end
  elseif strs[1] == "item" then
    local pname = clicObj.parent.name
    local idx = tonumber(strs[2])
    if pname == "List_Tab" then
      self.curTabIdx = idx
      self:setCurTabItems()
    elseif pname == "List_Target" then
      local itemTaskCfg = SurpriseTaskMgr.GetSurpriseItemConCfg(self.libId)
      local itemId = itemTaskCfg.needItems[idx].itemXId
      self:displayItemTips(itemId, clicObj)
    end
  end
end
def.method("number", "userdata").displayItemTips = function(self, itemId, go)
  local position = go:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = go:GetComponent("UIWidget")
  local itemBase = ItemUtils.GetItemBase(itemId)
  if itemBase then
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, go, 0, true)
  else
    ItemTipsMgr.Instance():ShowItemFilterTips(itemId, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0, true)
  end
end
def.method().confirmCommit = function(self)
  local UUIDs = {}
  if self.selectedItems then
    for i, v in pairs(self.selectedItems) do
      table.insert(UUIDs, v.uuid[1])
    end
  end
  local itemTaskCfg = SurpriseTaskMgr.GetSurpriseItemConCfg(self.libId)
  if #UUIDs >= #itemTaskCfg.needItems then
    local surpriseCfg = SurpriseTaskMgr.GetSurpriseItemTaskCfg(self.serverId)
    local NPCInterface = require("Main.npc.NPCInterface")
    if NPCInterface.Instance():isInNpcNear(surpriseCfg.npcId) then
      local p = require("netio.protocol.mzm.gsp.task.CAccepteSurpriseItemReq").new(self.serverId, UUIDs)
      gmodule.network.sendProtocol(p)
    else
      Toast(textRes.Task[406])
    end
    self:Hide()
  else
    Toast(textRes.Task[402])
  end
end
def.method().setTabList = function(self)
  local itemTaskCfg = SurpriseTaskMgr.GetSurpriseItemConCfg(self.libId)
  local num = #itemTaskCfg.needItems
  local List_Tab = self.m_panel:FindDirect("Img_Bg0/List_Tab")
  local uiList = List_Tab:GetComponent("UIList")
  uiList.itemCount = num
  uiList.columns = num
  uiList:Resize()
  for i = 1, num do
    local item = List_Tab:FindDirect("item_" .. i)
    local Label = item:FindDirect("Label")
    Label:GetComponent("UILabel"):set_text(i)
    local uitoggle = item:GetComponent("UIToggle")
    uitoggle.value = i == self.curTabIdx
  end
end
def.method().setCurTabItems = function(self)
  local itemTaskCfg = SurpriseTaskMgr.GetSurpriseItemConCfg(self.libId)
  local itemInfo = itemTaskCfg.needItems[self.curTabIdx]
  local id = itemInfo.itemXId
  if self.itemType == TaskNeedItemType.CONDITION then
    local bag = ItemData.Instance():GetBag(BagInfo.BAG)
    local itemList = {}
    local itemSiftCfg = ItemUtils.GetItemFilterCfg(id)
    if bag ~= nil then
      for itemKey, item in pairs(bag) do
        local itembase = ItemUtils.GetItemBase(item.id)
        if ItemUtils.FiltrateAItem(itembase, itemSiftCfg) == true then
          table.insert(itemList, item)
        end
      end
    end
    self:setItemList(itemList)
  else
    local items = ItemData.Instance():GetItemsByItemID(BagInfo.BAG, id)
    warn("-------setItemId:", id)
    local itemList = {}
    for i, v in pairs(items) do
      table.insert(itemList, v)
    end
    self:setItemList(itemList)
  end
end
def.method("=>", "table").filterItemList = function(self)
  local itemList = {}
  self.itemKey2Index = {}
  if self.itemType == TaskNeedItemType.CONDITION then
    local itemTaskCfg = SurpriseTaskMgr.GetSurpriseItemConCfg(self.libId)
    local bag = ItemData.Instance():GetBag(BagInfo.BAG)
    for i, v in ipairs(itemTaskCfg.needItems) do
      local id = v.itemXId
      local itemSiftCfg = ItemUtils.GetItemFilterCfg(id)
      for itemKey, item in pairs(bag) do
        local itembase = ItemUtils.GetItemBase(item.id)
        if ItemUtils.FiltrateAItem(itembase, itemSiftCfg) == true then
          self.itemKey2Index[itemKey] = i
          table.insert(itemList, item)
        end
      end
    end
  end
  return itemList
end
def.method().setItemList = function(self)
  local itemList = self:filterItemList()
  self.curItemList = itemList
  local List_Item = self.m_panel:FindDirect("Img_Bg0/Group_Item/Scrollview_Item/List_Item")
  local uiList = List_Item:GetComponent("UIList")
  uiList.itemCount = #itemList
  uiList:Resize()
  for i, v in ipairs(itemList) do
    local Group_BuyItem = List_Item:FindDirect("Group_BuyItem_" .. i)
    local Img_BgItem = Group_BuyItem:FindDirect("Img_BgItem_" .. i)
    local Texture_Icon = Img_BgItem:FindDirect("Texture_Icon_" .. i)
    local Label_Num = Img_BgItem:FindDirect("Label_Num_" .. i)
    local Label_ItemName = Group_BuyItem:FindDirect(string.format("Group_DetailItemInfo_%d/Label_ItemName_%d", i, i))
    local itemBase = ItemUtils.GetItemBase(v.id)
    local uiTexture = Texture_Icon:GetComponent("UITexture")
    GUIUtils.FillIcon(uiTexture, itemBase.icon)
    Label_Num:GetComponent("UILabel"):set_text(v.number)
    Label_ItemName:GetComponent("UILabel"):set_text(itemBase.name)
    local uitoggle = Group_BuyItem:GetComponent("UIToggle")
    local index = self.itemKey2Index[v.itemKey]
    local selectedItem = self.selectedItems[index]
    if selectedItem and selectedItem.itemKey == v.itemKey then
      uitoggle.value = true
    else
      uitoggle.value = false
    end
  end
  local Group_NoData = self.m_panel:FindDirect("Img_Bg0/Group_NoData")
  Group_NoData:SetActive(#itemList == 0)
end
def.method().setSelectedItemList = function(self)
  local itemTaskCfg = SurpriseTaskMgr.GetSurpriseItemConCfg(self.libId)
  local List_Target = self.m_panel:FindDirect("Img_Bg0/List_Target")
  local uiList = List_Target:GetComponent("UIList")
  uiList.itemCount = #itemTaskCfg.needItems
  uiList:Resize()
  local isfilterItem = self.itemType == TaskNeedItemType.CONDITION
  for i, v in ipairs(itemTaskCfg.needItems) do
    local item = List_Target:FindDirect("item_" .. i)
    local Texture = item:FindDirect("Texture")
    local uiTexture = Texture:GetComponent("UITexture")
    local Img_Get = item:FindDirect("Img_Get")
    local Label = item:FindDirect("Label")
    Label:GetComponent("UILabel"):set_text("")
    if self.selectedItems and self.selectedItems[i] then
      Img_Get:SetActive(true)
    else
      Img_Get:SetActive(false)
    end
    if isfilterItem then
      local filterCfg = ItemUtils.GetItemFilterCfg(v.itemXId)
      GUIUtils.FillIcon(uiTexture, filterCfg.icon)
    else
      local itemBase = ItemUtils.GetItemBase(v.itemXId)
      GUIUtils.FillIcon(uiTexture, itemBase.icon)
    end
  end
end
return SurpriseTaskGiveItem.Commit()
