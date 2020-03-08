local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SellBatchPanel = Lplus.Extend(ECPanelBase, "SellBatchPanel")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local GUIUtils = require("GUI.GUIUtils")
local Uuid2num = require("netio.protocol.mzm.gsp.item.Uuid2num")
local EquipUtils = require("Main.Equip.EquipUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local Vector = require("Types.Vector")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local def = SellBatchPanel.define
local instance
def.static("=>", SellBatchPanel).Instance = function()
  if instance == nil then
    instance = SellBatchPanel()
  end
  return instance
end
def.static().ShowSellBatch = function()
  local sellBatchPanel = SellBatchPanel.Instance()
  sellBatchPanel:CreatePanel(RESPATH.PREFAB_SELL_BATCH, 1)
  sellBatchPanel:SetModal(true)
end
def.field("table").sellItemData = nil
def.field("table").sellList = nil
def.field("table").keepList = nil
def.field("number").reduceTimer = 0
def.override().OnCreate = function(self)
  self.sellItemData = {}
  self.sellList = {}
  self.keepList = {}
  self:ProcessItemData()
  self:UpdatePanel()
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, SellBatchPanel.OnBagChange)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, SellBatchPanel.OnBagChange)
  self:StopPressTimer()
end
def.static("table", "table").OnBagChange = function(p1, p2)
  SellBatchPanel.Instance():ProcessItemData()
  SellBatchPanel.Instance():UpdatePanel()
  SellBatchPanel.Instance():ResetScoll()
end
def.method("table", "table", "=>", "boolean").CanNotRecycleEquip = function(self, item, itemBase)
  if itemBase.itemType == ItemType.EQUIP then
    local strenLevel = item.extraMap[ItemXStoreType.STRENGTH_LEVEL] or 0
    if strenLevel >= 5 then
      return true
    else
      return false
    end
  else
    return false
  end
end
def.method().ProcessItemData = function(self)
  local CommercePitchUtils = require("Main.CommerceAndPitch.CommercePitchUtils")
  local commerceItems = CommercePitchUtils.GetItemsCanSellToCommerce()
  local allItems = ItemModule.Instance():GetAllItems()
  local itemsCanSell = {}
  local uuids = {}
  for k, v in pairs(allItems) do
    for k1, v1 in pairs(v) do
      local itemBase = ItemUtils.GetItemBase(v1.id)
      local isBind = ItemUtils.IsItemBind(v1)
      if itemBase.canSellAndThrow and itemBase.isProprietary == false then
        if isBind then
        else
        end
        if not commerceItems[v1.id] and not self:CanNotRecycleEquip(v1, itemBase) then
          local uuid = v1.uuid[1]
          local uuidStr = uuid:tostring()
          local oldData = self.sellItemData[uuidStr]
          local gold = ItemUtils.GetItemRecycleGold(v1.id)
          itemsCanSell[uuidStr] = {
            key = k1,
            bagId = k,
            item = v1,
            sell = 0,
            itemBase = itemBase,
            gold = gold
          }
          table.insert(uuids, uuidStr)
        end
      end
    end
  end
  for k, v in pairs(self.sellItemData) do
    local newData = itemsCanSell[k]
    if newData then
      newData.sell = v.sell < newData.item.number and v.sell or newData.item.number
    end
  end
  self.sellItemData = itemsCanSell
  table.sort(uuids, function(a, b)
    local aInfo = self.sellItemData[a]
    local bInfo = self.sellItemData[b]
    if aInfo.bagId < bInfo.bagId then
      return true
    elseif aInfo.bagId > bInfo.bagId then
      return false
    else
      return aInfo.key < bInfo.key
    end
  end)
  self.keepList = uuids
  local removeKeys = {}
  for k, v in ipairs(self.sellList) do
    if not self.sellItemData[v] or self.sellItemData[v].sell <= 0 then
      table.insert(removeKeys, k)
    end
  end
  for i = #removeKeys, 1, -1 do
    table.remove(self.sellList, removeKeys[i])
  end
end
def.method().UpdateLeft = function(self)
  local itemCount = #self.sellList
  local showCount = itemCount > 25 and (itemCount % 5 == 0 and itemCount or itemCount + (5 - itemCount % 5)) or 25
  local scroll = self.m_panel:FindDirect("Img_Bg0/Img_Recycle/Scroll View_Recycle")
  local grid = scroll:FindDirect("Grid_Recycle")
  local template = self.m_panel:FindDirect("Img_Bg0/Img_Recycle/Recycle")
  template:SetActive(false)
  local itemCount = grid:get_childCount()
  if itemCount ~= showCount then
    self:DestroyAllChild(grid)
    for i = 1, showCount do
      local itemNew = Object.Instantiate(template)
      itemNew:SetActive(true)
      itemNew:set_name(string.format("Recycle_%03d", i))
      local reduce = itemNew:FindChild("Btn_Reduce")
      reduce:set_name(string.format("Btn_Reduce_%03d", i))
      itemNew.parent = grid
      itemNew:set_localScale(Vector.Vector3.one)
      self.m_msgHandler:Touch(itemNew)
    end
  end
  for i = 1, showCount do
    local child = grid:FindDirect(string.format("Recycle_%03d", i))
    if child then
      local uuid = self.sellList[i]
      if uuid then
        local itemInfo = self.sellItemData[uuid]
        if itemInfo then
          self:SetItemSell(child, itemInfo)
        else
          self:ClearItem(child)
        end
      else
        self:ClearItem(child)
      end
    end
  end
  grid:GetComponent("UIGrid"):Reposition()
end
def.method().UpdateRight = function(self)
  local itemCount = #self.keepList
  local showCount = itemCount > 25 and (itemCount % 5 == 0 and itemCount or itemCount + (5 - itemCount % 5)) or 25
  local scroll = self.m_panel:FindDirect("Img_Bg0/Img_Item/Scroll View_Item")
  local grid = scroll:FindDirect("Grid_Item")
  local template = self.m_panel:FindDirect("Img_Bg0/Img_Item/Item")
  template:SetActive(false)
  local itemCount = grid:get_childCount()
  if itemCount ~= showCount then
    self:DestroyAllChild(grid)
    for i = 1, showCount do
      local itemNew = Object.Instantiate(template)
      itemNew:SetActive(true)
      itemNew:set_name(string.format("Item_%03d", i))
      itemNew.parent = grid
      itemNew:set_localScale(Vector.Vector3.one)
      self.m_msgHandler:Touch(itemNew)
    end
  end
  for i = 1, showCount do
    local child = grid:FindDirect(string.format("Item_%03d", i))
    if child then
      local uuid = self.keepList[i]
      if uuid then
        local itemInfo = self.sellItemData[uuid]
        if itemInfo then
          if itemInfo.sell >= itemInfo.item.number then
            self:ClearItem(child)
          else
            self:SetItemKeep(child, itemInfo)
          end
        else
          self:ClearItem(child)
        end
      else
        self:ClearItem(child)
      end
    end
  end
  grid:GetComponent("UIGrid"):Reposition()
end
def.method().ResetScoll = function(self)
  local scroll1 = self.m_panel:FindDirect("Img_Bg0/Img_Item/Scroll View_Item")
  local scroll2 = self.m_panel:FindDirect("Img_Bg0/Img_Recycle/Scroll View_Recycle")
  scroll1:GetComponent("UIScrollView"):ResetPosition()
  scroll2:GetComponent("UIScrollView"):ResetPosition()
end
def.method().ClearSell = function(self)
  sellBatchPanel.sellItemData = {}
  sellBatchPanel.sellList = {}
  sellBatchPanel.keepList = {}
  self:ProcessItemData()
  self:UpdatePanel()
end
def.method().UpdateMoney = function(self)
  local allSilver = 0
  local allGold = 0
  for k, v in ipairs(self.sellList) do
    local info = self.sellItemData[v]
    if info then
      if 0 <= info.gold then
        allGold = allGold + info.sell * info.gold
      else
        allSilver = allSilver + info.sell * info.itemBase.sellSilver
      end
    end
  end
  local silverLabel = self.m_panel:FindDirect("Img_Bg0/Img_Recycle/Img_BgCoin/Label_Coin"):GetComponent("UILabel")
  silverLabel:set_text(allSilver)
  local goldLabel = self.m_panel:FindDirect("Img_Bg0/Img_Recycle/Img_BgCoin2/Label_Coin"):GetComponent("UILabel")
  goldLabel:set_text(allGold)
end
def.method("string").UpdateOne = function(self, uuid)
  for k, v in ipairs(self.keepList) do
    if v == uuid then
      local child = self.m_panel:FindDirect(string.format("Img_Bg0/Img_Item/Scroll View_Item/Grid_Item/Item_%03d", k))
      if child then
        local itemInfo = self.sellItemData[uuid]
        if itemInfo then
          if itemInfo.sell >= itemInfo.item.number then
            self:ClearItem(child)
            break
          end
          self:SetItemKeep(child, itemInfo)
          break
        end
        self:ClearItem(child)
      end
      break
    end
  end
  for k, v in ipairs(self.sellList) do
    if v == uuid then
      local child = self.m_panel:FindDirect(string.format("Img_Bg0/Img_Recycle/Scroll View_Recycle/Grid_Recycle/Recycle_%03d", k))
      if child then
        local itemInfo = self.sellItemData[uuid]
        if itemInfo then
          if itemInfo.sell >= itemInfo.item.number then
            self:ClearItem(child)
          else
            self:SetItemSell(child, itemInfo)
          end
        else
          self:ClearItem(child)
        end
      end
    end
  end
end
def.method().UpdatePanel = function(self)
  self:UpdateRight()
  self:UpdateLeft()
  self:UpdateMoney()
end
def.method().SellBatch = function(self)
  local sellInfo = self:GetCurrentSellInfo()
  if next(sellInfo) then
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirm(textRes.Item[156], textRes.Item[157], function(selection, tag)
      if selection == 1 then
        for k, v in pairs(sellInfo) do
          local sell = require("netio.protocol.mzm.gsp.item.COneKeySellItemReq").new(k, v)
          gmodule.network.sendProtocol(sell)
        end
      end
    end, nil)
  else
    Toast(textRes.Item[155])
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
    self = nil
  elseif id == "Btn_Recycle" then
    self:SellBatch()
  elseif string.sub(id, 1, 5) == "Item_" then
    local index = tonumber(string.sub(id, 6))
    local uuid = self.keepList[index] or -1
    local info = self.sellItemData[uuid]
    if info and info.sell < info.item.number then
      ItemTipsMgr.Instance():ShowTips(info.item, info.bagId, info.key, ItemTipsMgr.Source.RecycleRight, 0, 0, 0, 0, 0)
    end
  elseif string.sub(id, 1, 8) == "Recycle_" then
    local index = tonumber(string.sub(id, 9))
    local uuid = self.sellList[index] or -1
    local info = self.sellItemData[uuid]
    if info then
      ItemTipsMgr.Instance():ShowTips(info.item, info.bagId, info.key, ItemTipsMgr.Source.RecycleLeft, 0, 0, 0, 0, 0)
    end
  elseif string.sub(id, 1, 11) == "Btn_Reduce_" then
    local index = tonumber(string.sub(id, 12))
    local uuid = self.sellList[index] or -1
    local info = self.sellItemData[uuid]
    if info then
      info.sell = info.sell - 1
      if info.sell > 0 then
        self:UpdateOne(uuid)
        self:UpdateMoney()
      else
        table.remove(self.sellList, index)
        self:UpdatePanel()
      end
    end
  end
end
def.method("string").onLongPress = function(self, id)
  if string.sub(id, 1, 11) == "Btn_Reduce_" then
    local index = tonumber(string.sub(id, 12))
    self:StartPressTimer(index)
  end
end
def.method("string", "boolean").onPress = function(self, id, state)
  if string.sub(id, 1, 11) == "Btn_Reduce_" and not state then
    self:StopPressTimer()
  end
end
def.method("string").onDoubleClick = function(self, id)
  if string.sub(id, 1, 5) == "Item_" then
    local index = tonumber(string.sub(id, 6))
    local uuid = self.keepList[index] or -1
    local info = self.sellItemData[uuid]
    if info then
      if info.sell == 0 then
        info.sell = info.item.number
        table.insert(self.sellList, uuid)
      else
        info.sell = info.item.number
      end
      self:UpdatePanel()
    end
  elseif string.sub(id, 1, 8) == "Recycle_" then
    local index = tonumber(string.sub(id, 9))
    local uuid = self.sellList[index] or -1
    local info = self.sellItemData[uuid]
    if info then
      info.sell = 0
      table.remove(self.sellList, index)
      self:UpdatePanel()
    end
  end
end
def.method("number").StartPressTimer = function(self, index)
  local uuid = self.sellList[index] or -1
  self:StopPressTimer()
  self.reduceTimer = GameUtil.AddGlobalTimer(0.06, false, function()
    local info = self.sellItemData[uuid]
    if info then
      info.sell = info.sell - 1
      if info.sell <= 0 then
        self:StopPressTimer()
        info.sell = 0
        table.remove(self.sellList, index)
        self:UpdatePanel()
      else
        self:UpdateOne(uuid)
        self:UpdateMoney()
      end
    end
  end)
end
def.method().StopPressTimer = function(self)
  GameUtil.RemoveGlobalTimer(self.reduceTimer)
  self.reduceTimer = 0
end
def.method("=>", "table").GetCurrentSellInfo = function(self)
  local tbl = {}
  for k, v in ipairs(self.sellList) do
    local info = self.sellItemData[v]
    if tbl[info.bagId] == nil then
      tbl[info.bagId] = {}
    end
    local sellInfo = Uuid2num.new(Int64.new(v), info.sell)
    table.insert(tbl[info.bagId], sellInfo)
  end
  return tbl
end
def.method("userdata", "table").SetItemSell = function(self, obj, info)
  local Bg = obj:FindDirect("Img_Bg")
  local quality = EquipUtils.GetEquipDynamicColor(info.item, nil, info.itemBase)
  Bg:GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", quality))
  local icon = obj:FindDirect("Img_Icon")
  icon:SetActive(true)
  GUIUtils.FillIcon(icon:GetComponent("UITexture"), info.itemBase.icon)
  local num = obj:FindDirect("Label_Num")
  local showNum = info.sell
  if showNum > 1 then
    num:SetActive(true)
    num:GetComponent("UILabel"):set_text(showNum)
  else
    num:SetActive(false)
  end
  local reduce = obj:FindChildByPrefix("Btn_Reduce")
  if reduce then
    reduce:SetActive(true)
  end
end
def.method("userdata", "table").SetItemKeep = function(self, obj, info)
  local Bg = obj:FindDirect("Img_Bg")
  local quality = EquipUtils.GetEquipDynamicColor(info.item, nil, info.itemBase)
  Bg:GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", quality))
  local icon = obj:FindDirect("Img_Icon")
  icon:SetActive(true)
  GUIUtils.FillIcon(icon:GetComponent("UITexture"), info.itemBase.icon)
  local num = obj:FindDirect("Label_Num")
  local showNum = info.item.number - info.sell
  if showNum > 1 then
    num:SetActive(true)
    num:GetComponent("UILabel"):set_text(showNum)
  else
    num:SetActive(false)
  end
end
def.method("userdata").ClearItem = function(self, obj)
  obj:GetComponent("UIToggle"):set_value(false)
  local Bg = obj:FindDirect("Img_Bg")
  Bg:GetComponent("UISprite"):set_spriteName("Cell_00")
  local icon = obj:FindDirect("Img_Icon")
  icon:SetActive(false)
  local num = obj:FindDirect("Label_Num")
  num:SetActive(false)
  local reduce = obj:FindChildByPrefix("Btn_Reduce")
  if reduce then
    reduce:SetActive(false)
  end
end
def.method("userdata").DestroyAllChild = function(self, obj)
  local count = obj:get_childCount()
  for i = count - 1, 0, -1 do
    local child = obj:GetChild(i)
    Object.DestroyImmediate(child)
  end
end
SellBatchPanel.Commit()
return SellBatchPanel
