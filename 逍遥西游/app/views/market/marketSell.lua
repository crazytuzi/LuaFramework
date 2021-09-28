CMarketSell = class("CMarketSell", CcsSubView)
function CMarketSell:ctor(uselessItemList)
  CMarketSell.super.ctor(self, "views/marketsell.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  self.m_BuyNum = 1
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnClose),
      variName = "btn_close"
    },
    btn_confirm = {
      listener = handler(self, self.OnBtn_Confirm),
      variName = "btn_confirm"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.list_item = self:getNode("list_item")
  self:setItemList(uselessItemList)
  self:ListenMessage(MsgID_ItemInfo)
  getCurSceneView():addSubView({
    subView = self,
    zOrder = MainUISceneZOrder.menuView
  })
end
function CMarketSell:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_ItemInfo_AddItem or msgSID == MsgID_ItemInfo_ChangeItemNum or msgSID == MsgID_ItemInfo_DelItem then
    self:reloadItemList()
  end
end
function CMarketSell:setItemList(uselessItemList)
  print("--->>>> setItemList !")
  if uselessItemList == nil then
    uselessItemList = getUselessItemListOfMarket()
  end
  if #uselessItemList <= 0 then
    self:OnClose()
  end
  self.m_UselessItemList = uselessItemList
  self.list_item:removeAllItems()
  local itemBoard = Widget:create()
  local offx = 0
  local offy = 0
  local size = self.list_item:getContentSize()
  local w = 95
  local h = size.height / 2
  for index, data in pairs(self.m_UselessItemList) do
    local item = createClickItem({
      itemID = data[1],
      num = data[2],
      LongPressTime = 0.1,
      noBgFlag = false
    })
    local itemSize = item:getContentSize()
    if index <= 6 then
      offx = (index - 1) % 3 * w + (w - itemSize.width) / 2
      offy = math.floor((6 - index) / 3) * h + (h - itemSize.height) / 2
    else
      offx = math.floor((index - 1) / 2) * w + (w - itemSize.width) / 2
      if index % 2 == 1 then
        offy = h + (h - itemSize.height) / 2
      else
        offy = (h - itemSize.height) / 2
      end
    end
    itemBoard:addChild(item)
    item:setPosition(ccp(offx, offy))
  end
  itemBoard:ignoreContentAdaptWithSize(false)
  local n = #self.m_UselessItemList
  if n > 6 then
    itemBoard:setSize(CCSize(math.floor((n + 1) / 2) * w, size.height))
  elseif n >= 3 then
    itemBoard:setSize(CCSize(3 * w, size.height))
  elseif n >= 2 then
    itemBoard:setSize(CCSize(2 * w, size.height))
  elseif n >= 1 then
    itemBoard:setSize(CCSize(1 * w, size.height))
  end
  itemBoard:setAnchorPoint(ccp(0, 0))
  self.list_item:pushBackCustomItem(itemBoard)
end
function CMarketSell:reloadItemList()
  self:stopAllActions()
  local act1 = CCDelayTime:create(0.2)
  local act2 = CCCallFunc:create(function()
    self:setItemList()
  end)
  self:runAction(transition.sequence({act1, act2}))
end
function CMarketSell:OnBtn_Confirm(obj, t)
  local curTime = g_DataMgr:getServerTime()
  if self.m_LastSellTime ~= nil and curTime - self.m_LastSellTime < 0.5 then
    print("点太快了")
    return
  end
  self.m_LastSellTime = curTime
  local itemList = {}
  for _, data in pairs(self.m_UselessItemList) do
    local itemType = data[1]
    local itemId = g_LocalPlayer:GetOneItemIdByType(itemType)
    if itemId ~= nil and itemId ~= 0 then
      itemList[#itemList + 1] = itemId
    end
  end
  if #itemList > 0 then
    netsend.netitem.requestSellItemList(itemList)
  else
    self:OnClose()
  end
end
function CMarketSell:OnClose()
  self:CloseSelf()
end
function CMarketSell:Clear()
end
