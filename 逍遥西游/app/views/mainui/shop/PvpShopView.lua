PvpShopView = class("PvpShopView", CcsSubView)
local _sortItem = function(itemA, itemB)
  if itemA == nil or itemB == nil then
    return false
  end
  local sortNumA = data_getPvpShopItemSortNum(itemA)
  local sortNumB = data_getPvpShopItemSortNum(itemB)
  if sortNumA == sortNumB then
    return itemA < itemB
  else
    return sortNumA < sortNumB
  end
end
function PvpShopView:ctor(closeListener)
  PvpShopView.super.ctor(self, "views/pvp_shop.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_tool = {
      listener = handler(self, self.OnBtn_Tool),
      variName = "btn_tool"
    },
    btn_nd = {
      listener = handler(self, self.OnBtn_NeiDan),
      variName = "btn_nd"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:addBtnSigleSelectGroup({
    {
      self.btn_tool,
      nil,
      ccc3(251, 248, 145)
    },
    {
      self.btn_nd,
      nil,
      ccc3(251, 248, 145)
    }
  })
  self.m_CloseListener = closeListener
  self.m_PageObjList = {}
  self.m_PageObjNameList = {
    "equip_list",
    "drug_list",
    "daoju_list",
    "smsd_list",
    "tool_list",
    "nd_list",
    "xiayi_list"
  }
  self:setHonourNum()
  self:ListenMessage(MsgID_PlayerInfo)
  self:SetAttrTips()
  self:ShowPage(Shop_Honour_Tool_Page)
end
function PvpShopView:SetAttrTips()
  clickArea_check.extend(self)
  self:attrclick_check_withWidgetObj(self:getNode("coinbg"), "reshonour")
end
function PvpShopView:ShowPage(pageNum)
  if g_Click_Item_View ~= nil then
    g_Click_Item_View:removeFromParentAndCleanup(true)
  end
  if self.m_PageObjList[pageNum] == nil then
    self:SetPage(pageNum)
    self.m_PageObjList[pageNum] = self:getNode(self.m_PageObjNameList[pageNum])
  end
  for index, name in pairs(self.m_PageObjNameList) do
    local listObj = self:getNode(name)
    if listObj then
      listObj:setVisible(index == pageNum)
      listObj:setEnabled(index == pageNum)
    end
  end
end
function PvpShopView:SetPage(pageNum)
  local everyLineNum = 2
  local listObj = self:getNode(self.m_PageObjNameList[pageNum])
  local tempWidget = Widget:create()
  tempWidget:setAnchorPoint(ccp(0, 0))
  listObj:removeAllItems()
  listObj:pushBackCustomItem(tempWidget)
  local showItemList = {}
  if pageNum == Shop_Honour_Tool_Page then
    local shapeIdList = {}
    for id, _ in pairs(data_ShopHonour2) do
      shapeIdList[#shapeIdList + 1] = id
    end
    table.sort(shapeIdList, _sortItem)
    for _, id in pairs(shapeIdList) do
      showItemList[#showItemList + 1] = {
        shapeId = id,
        num = 0,
        price = data_ShopHonour2[id].honour,
        resType = RESTYPE_Honour,
        lvLimit = data_ShopHonour2[id].lvLimit,
        zsLimit = data_ShopHonour2[id].zsLimit
      }
    end
  elseif pageNum == Shop_Honour_Nd_Page then
    local shapeIdList = {}
    for id, _ in pairs(data_ShopHonour) do
      shapeIdList[#shapeIdList + 1] = id
    end
    table.sort(shapeIdList, _sortItem)
    for _, id in pairs(shapeIdList) do
      showItemList[#showItemList + 1] = {
        shapeId = id,
        num = 0,
        price = data_ShopHonour[id].honour,
        resType = RESTYPE_Honour,
        lvLimit = data_ShopHonour[id].lvLimit,
        zsLimit = data_ShopHonour[id].zsLimit
      }
    end
  end
  local itemSize
  local h = 0
  local index = 1
  local curLv = 0
  local curZs = 0
  local heroObj = g_LocalPlayer:getMainHero()
  if heroObj ~= nil then
    curZs = heroObj:getProperty(PROPERTY_ZHUANSHENG)
    curLv = heroObj:getProperty(PROPERTY_ROLELEVEL)
  end
  for _, data in pairs(showItemList) do
    local lvLimit = data.lvLimit or 0
    local zsLimit = data.zsLimit or 0
    if curZs > zsLimit or curZs == zsLimit and curLv >= lvLimit then
      local item = ShopViewItem.new(pageNum)
      if itemSize == nil then
        itemSize = item:getContentSize()
        h = math.ceil(#showItemList / everyLineNum) * itemSize.height
      end
      tempWidget:addChild(item:getUINode())
      local lineY = math.floor((index - 1) / everyLineNum)
      local lineX = (index - 1) % everyLineNum
      local x = lineX * itemSize.width
      local y = -(lineY * itemSize.height)
      item:setPosition(ccp(x, h + y - itemSize.height))
      item:setItemId(data.shapeId, data.num)
      item:setPriceType(data.resType)
      item:setPriceNum(data.price)
      index = index + 1
    end
  end
  local listSize = listObj:getInnerContainerSize()
  tempWidget:ignoreContentAdaptWithSize(false)
  tempWidget:setSize(CCSize(listSize.width, h))
end
function PvpShopView:SetShopBtnClick(pageNum)
  self:ShowPage(pageNum)
  local btn
  if pageNum == Shop_Honour_Tool_Page then
    btn = self.btn_tool
  elseif pageNum == Shop_Honour_Nd_Page then
    btn = self.btn_nd
  end
  if btn ~= nil then
    self:setGroupBtnSelected(btn)
  end
end
function PvpShopView:setHonourNum()
  local box_honour = self:getNode("box_honour")
  box_honour:setVisible(false)
  box_honour:setTouchEnabled(false)
  local x, y = box_honour:getPosition()
  local z = box_honour:getZOrder()
  local size = box_honour:getSize()
  local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_Honour))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setScale(size.width / tempImg:getContentSize().width)
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addNode(tempImg, z)
  self:updateHonourNum()
end
function PvpShopView:updateHonourNum()
  self:getNode("text_honour"):setText(string.format("%d", g_LocalPlayer:getHonour()))
end
function PvpShopView:OnMessage(msgSID, ...)
  if msgSID == MsgID_HonourUpdate then
    self:updateHonourNum()
  end
end
function PvpShopView:Clear()
  if self.m_CloseListener then
    self.m_CloseListener()
    self.m_CloseListener = nil
  end
end
function PvpShopView:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function PvpShopView:OnBtn_Tool(obj, t)
  self:ShowPage(Shop_Honour_Tool_Page)
end
function PvpShopView:OnBtn_NeiDan(obj, t)
  self:ShowPage(Shop_Honour_Nd_Page)
end
