local CItemDetailHead_ChatShow = class("CItemDetailHead_ChatShow", CItemDetailHead)
function CItemDetailHead_ChatShow:ctor(param, itemObj)
  self.m_ItemObj = itemObj
  CItemDetailHead_ChatShow.super.ctor(self, param)
end
function CItemDetailHead_ChatShow:GetItemObj()
  return self.m_ItemObj
end
function CItemDetailHead_ChatShow:onCleanup()
  CItemDetailHead_ChatShow.super.onCleanup(self)
  self.m_ItemObj = nil
end
function CItemDetailHead_ChatShow:ShowItemDetailTemp(itemObjId)
  self.m_ItemObjId = itemObjId
  self:ClearDetail()
  local itemObj = self:GetItemObj()
  self:SetImgAndNameTemp(itemObj)
  self:SetAllPos()
end
function CItemDetailHead_ChatShow:SetImgAndNameTemp(itemObj)
  local itemName, itemShapeId, path, iconPath, itemType
  if itemObj ~= nil then
    itemName = itemObj:getProperty(ITEM_PRO_NAME)
    itemShapeId = itemObj:getProperty(ITEM_PRO_SHAPE)
    path = data_getItemPathByShape(itemShapeId)
    iconPath = data_getItemPackageIconPath(itemObj:getTypeId())
    itemType = itemObj:getTypeId()
  end
  self.m_ItemDetailNameObj = ui.newTTFLabel({
    text = itemName,
    font = KANG_TTF_FONT,
    size = self.m_NameTextSize,
    color = ccc3(255, 255, 0)
  })
  local itemPj = data_getItemPinjie(itemType)
  local color = NameColor_Item[itemPj] or NameColor_Item[0]
  self.m_ItemDetailNameObj:setColor(color)
  self.m_ItemDetailNameObj:setAnchorPoint(ccp(0, 0.5))
  self:addNode(self.m_ItemDetailNameObj)
  if self.m_ItemDetailItemImg then
    self.m_ItemDetailItemImg:removeFromParent()
  end
  local tempImg = display.newSprite(path)
  tempImg:setAnchorPoint(ccp(0, 1))
  tempImg:setScale(self.m_ItemImgW / tempImg:getContentSize().width)
  self:addNode(tempImg)
  self.m_ItemDetailItemImg = tempImg
  if self.m_ItemDetailTypeImg then
    self.m_ItemDetailTypeImg:removeFromParent()
  end
  local tempImg = display.newSprite(iconPath)
  tempImg:setAnchorPoint(ccp(0, 1))
  self:addNode(tempImg)
  self.m_ItemDetailTypeImg = tempImg
end
local CItemDetailText_ChatShow = class("CItemDetailText_ChatShow", CItemDetailText)
function CItemDetailText_ChatShow:ctor(itemId, param, itemObj)
  self.m_ItemObj = itemObj
  CItemDetailText_ChatShow.super.ctor(self, itemId, param)
end
function CItemDetailText_ChatShow:GetItemObj()
  return self.m_ItemObj
end
function CItemDetailText_ChatShow:onCleanup()
  CItemDetailHead_ChatShow.super.onCleanup(self)
  self.m_ItemObj = nil
end
CChatDetail_Item = class("CChatDetail_Item", CcsSubView)
function CChatDetail_Item:ctor(playerId, itemId, itemTypeId, data)
  CChatDetail_Item.super.ctor(self, "views/chatdetail_item.json")
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  PackageExtend.extend(self)
  self.m_PlayerId = playerId
  self.m_ItemId = itemId
  self.m_ItemTypeId = itemTypeId
  self.list_detail = self:getNode("list_detail")
  if data == nil then
    self:LoadDetail()
  else
    self:LoadDetailWithSvrData(data)
  end
  self:enableCloseWhenTouchOutside(self:getNode("boxbg"), true)
  if g_CheckDetailDlg ~= nil then
    g_CheckDetailDlg:CloseSelf()
    g_CheckDetailDlg = nil
  end
  g_CheckDetailDlg = self
end
function CChatDetail_Item:getPlayerId()
  return self.m_PlayerId
end
function CChatDetail_Item:getItemId()
  return self.m_ItemId
end
function CChatDetail_Item:LoadDetail()
  local isLocal = self.m_PlayerId == g_LocalPlayer:getPlayerId()
  if not isLocal then
    self.m_ItemObj = self:newItemObject(self.m_ItemId, self.m_ItemTypeId)
    if self.m_ItemObj == nil then
      return
    end
  end
  local x, y = self.list_detail:getPosition()
  local lSize = self.list_detail:getContentSize()
  local w, h = lSize.width, lSize.height
  local p = self.list_detail:getParent()
  if not isLocal then
    local iType = GetItemTypeByItemTypeId(self.m_ItemTypeId)
    if iType == ITEM_LARGE_TYPE_EQPT or iType == ITEM_LARGE_TYPE_SENIOREQPT or iType == ITEM_LARGE_TYPE_SHENBING or iType == ITEM_LARGE_TYPE_XIANQI or self.m_ItemTypeId == ITEM_DEF_OTHER_ZBT or self.m_ItemTypeId == ITEM_DEF_OTHER_GJZBT then
      self.m_ItemDetailHead = CItemDetailHead_ChatShow.new({
        width = w - 5
      }, self.m_ItemObj)
      p:addChild(self.m_ItemDetailHead)
      self.m_ItemDetailHead:ShowItemDetailTemp(self.m_ItemId)
      local newSize = self.m_ItemDetailHead:getContentSize()
      self.m_ItemDetailHead:setPosition(ccp(x, y + h + newSize.height))
      print("----->>>如果执行到这里，说明查看物品链接的类逻辑有错。")
      return
    end
  end
  if isLocal then
    local itemDetailText = CItemDetailText.new(self.m_ItemId, {
      width = lSize.width - 5
    })
    self.list_detail:pushBackCustomItem(itemDetailText)
  else
    local itemDetailText = CItemDetailText_ChatShow.new(self.m_ItemId, {
      width = lSize.width - 5
    }, self.m_ItemObj)
    self.list_detail:pushBackCustomItem(itemDetailText)
  end
  if isLocal then
    self.m_ItemDetailHead = CItemDetailHead.new({
      width = w - 5
    })
  else
    self.m_ItemDetailHead = CItemDetailHead_ChatShow.new({
      width = w - 5
    }, self.m_ItemObj)
  end
  p:addChild(self.m_ItemDetailHead)
  self.m_ItemDetailHead:ShowItemDetail(self.m_ItemId)
  local newSize = self.m_ItemDetailHead:getContentSize()
  self.m_ItemDetailHead:setPosition(ccp(x, y + h + newSize.height))
end
function CChatDetail_Item:LoadDetailWithSvrData(itemInfo)
  self.m_ItemObj = self:newItemObject(self.m_ItemId, self.m_ItemTypeId)
  if self.m_ItemObj == nil then
    return
  end
  self:SetSvrProToItem(self.m_ItemObj, itemInfo)
  local x, y = self.list_detail:getPosition()
  local lSize = self.list_detail:getContentSize()
  local w, h = lSize.width, lSize.height
  if self.m_ItemDetailHead ~= nil then
    self.m_ItemDetailHead:removeFromParent()
  end
  self.m_ItemDetailHead = CItemDetailHead_ChatShow.new({
    width = w - 5
  }, self.m_ItemObj)
  local p = self.list_detail:getParent()
  p:addChild(self.m_ItemDetailHead)
  self.m_ItemDetailHead:ShowItemDetail(self.m_ItemId)
  local newSize = self.m_ItemDetailHead:getContentSize()
  self.m_ItemDetailHead:setPosition(ccp(x, y + h + newSize.height))
  self.list_detail:removeAllItems()
  local lSize = self.list_detail:getContentSize()
  local itemDetailText = CItemDetailText_ChatShow.new(self.m_ItemId, {
    width = lSize.width - 5
  }, self.m_ItemObj)
  self.list_detail:pushBackCustomItem(itemDetailText)
end
function CChatDetail_Item:OnBtn_Close(obj, t)
  self:CloseSelf()
end
function CChatDetail_Item:Clear()
  if g_CheckDetailDlg == self then
    g_CheckDetailDlg = nil
  end
end
