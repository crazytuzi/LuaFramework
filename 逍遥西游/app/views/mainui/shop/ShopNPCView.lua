ShopNPCView = class("ShopNPCView", CcsSubView)
local _sortItem = function(itemA, itemB)
  if itemA == nil or itemB == nil then
    return false
  end
  local dataList = {
    data_Shop_NPC_Yifu,
    data_Shop_NPC_Maozi,
    data_Shop_NPC_XieziXianglian,
    data_Shop_NPC_Wuqi,
    data_Shop_NPC_Yaopin,
    data_Shop_NPC_Zawu
  }
  local sortNumA = data_getShopItemSortNum(itemA, dataList)
  local sortNumB = data_getShopItemSortNum(itemB, dataList)
  if sortNumA == sortNumB then
    return itemA < itemB
  else
    return sortNumA < sortNumB
  end
end
function ShopNPCView:ctor(npcID, initItemId, mid)
  ShopNPCView.super.ctor(self, "views/shop.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_addmoney = {
      listener = handler(self, self.OnBtn_AddMoney),
      variName = "m_Btn_AddMoney"
    },
    btn_daoju = {
      listener = handler(self, self.OnBtn_1),
      variName = "btn_1"
    },
    btn_drug = {
      listener = handler(self, self.OnBtn_2),
      variName = "btn_2"
    },
    btn_xiayi = {
      listener = handler(self, self.OnBtn_3),
      variName = "btn_3"
    },
    btn_smsd = {
      listener = handler(self, self.OnBtn_4),
      variName = "btn_4"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:getNode("btn_frush"):setEnabled(false)
  self:getNode("text_frush"):setVisible(false)
  self:getNode("xiayibg"):setVisible(false)
  self:addBtnSigleSelectGroup({
    {
      self.btn_1,
      nil,
      ccc3(251, 248, 145)
    },
    {
      self.btn_2,
      nil,
      ccc3(251, 248, 145)
    },
    {
      self.btn_3,
      nil,
      ccc3(251, 248, 145)
    }
  })
  self.m_PageObjList = {}
  self.m_PageObjNameList = {
    "equip_list",
    "drug_list",
    "daoju_list",
    "smsd_list",
    "xiayi_list"
  }
  self:setGoldNum()
  self:setNPCId(npcID, initItemId, mid)
  self:ListenMessage(MsgID_PlayerInfo)
end
function ShopNPCView:setNPCId(npcID, initItemId, mid)
  local pNum = 1
  local itemSortNum = 1
  self.m_ShopNPCID = npcID
  self.m_initItemId = initItemId
  self.m_mid = mid
  local _, npcName = data_getRoleShapeAndName(npcID)
  self:getNode("title"):setText(npcName)
  local textList = {}
  if npcID == 90003 then
    textList = {
      "衣服",
      "帽子",
      "鞋子项链"
    }
  elseif npcID == 90910 then
    textList = {"药品"}
  elseif npcID == 90908 then
    textList = {"杂货"}
  elseif npcID == 90002 then
    textList = {"武器"}
  end
  for i = 1, 4 do
    local btn = self[string.format("btn_%d", i)]
    if btn then
      local btnName = textList[i]
      if btnName then
        btn:setTitleText(btnName)
      else
        btn:setEnabled(false)
      end
    end
  end
  if npcID == 90003 then
    self.m_DataList = {
      data_Shop_NPC_Yifu,
      data_Shop_NPC_Maozi,
      data_Shop_NPC_XieziXianglian
    }
    self.m_DataPageList = {
      Shop_NPC_Yifu_Page,
      Shop_NPC_Maozi_Page,
      Shop_NPC_XieziXianglian_Page
    }
  elseif npcID == 90910 then
    self.m_DataList = {data_Shop_NPC_Yaopin}
    self.m_DataPageList = {Shop_NPC_Yaopin_Page}
  elseif npcID == 90908 then
    self.m_DataList = {data_Shop_NPC_Zawu}
    self.m_DataPageList = {Shop_NPC_Zawu_Page}
  elseif npcID == 90002 then
    self.m_DataList = {data_Shop_NPC_Wuqi}
    self.m_DataPageList = {Shop_NPC_Wuqi_Page}
  else
    self.m_DataList = {}
    self.m_DataPageList = {}
  end
  local priceResType, priceNum
  if initItemId ~= nil then
    for index, tData in ipairs(self.m_DataList) do
      if tData[initItemId] ~= nil then
        pNum = index
        itemSortNum = data_getShopItemSortNum(initItemId, {tData})
        if tData[initItemId].gold == nil or tData[initItemId].gold == 0 then
          priceResType = RESTYPE_COIN
          priceNum = tData[initItemId].price
          break
        end
        priceResType = RESTYPE_GOLD
        priceNum = tData[initItemId].gold
        break
      end
    end
  end
  self:ShowPage(pNum)
  self:setGroupBtnSelected(self[string.format("btn_%d", pNum)])
  if mid ~= nil then
    local action1 = CCDelayTime:create(0.01)
    local action2 = CCCallFunc:create(function()
      local curList = self.m_PageObjList[pNum]
      if curList and itemSortNum > 6 then
        curList:scrollToBottom(0.2, false)
      end
      local m_initNum = 1
      if type(mid) == "number" and mid >= 1 then
        m_initNum = g_MissionMgr:getMissionShortageObjs(mid, initItemId)
        m_initNum = m_initNum or 1
      end
      CBuyNormalItemView.new(self.m_DataPageList[pNum], initItemId, priceResType, priceNum, m_initNum)
    end)
    local action = transition.sequence({action1, action2})
    self:runAction(action)
  end
end
function ShopNPCView:ShowPage(pageNum)
  self.m_CurPageNum = pageNum
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
function ShopNPCView:SetPage(pageNum)
  local everyLineNum = 2
  local listObj = self:getNode(self.m_PageObjNameList[pageNum])
  local tempWidget = Widget:create()
  tempWidget:setAnchorPoint(ccp(0, 0))
  listObj:removeAllItems()
  listObj:pushBackCustomItem(tempWidget)
  local showItemList = {}
  local ShopData = self.m_DataList[pageNum]
  if ShopData ~= nil then
    local shapeIdList = {}
    for id, _ in pairs(ShopData) do
      shapeIdList[#shapeIdList + 1] = id
    end
    table.sort(shapeIdList, _sortItem)
    for _, id in pairs(shapeIdList) do
      if ShopData[id].gold == nil or ShopData[id].gold == 0 then
        showItemList[#showItemList + 1] = {
          shapeId = id,
          num = 0,
          price = ShopData[id].price,
          resType = RESTYPE_COIN,
          lvLimit = ShopData[id].lvLimit,
          zsLimit = ShopData[id].zsLimit
        }
      else
        showItemList[#showItemList + 1] = {
          shapeId = id,
          num = 0,
          price = ShopData[id].gold,
          resType = RESTYPE_GOLD,
          lvLimit = ShopData[id].lvLimit,
          zsLimit = ShopData[id].zsLimit
        }
      end
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
      local item = ShopViewItem.new(self.m_DataPageList[pageNum])
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
      if self.m_initItemId == data.shapeId and type(self.m_mid) == "number" then
        item:setBuyInitNum(self.m_mid)
      end
      item:setPriceType(data.resType)
      item:setPriceNum(data.price)
      index = index + 1
    end
  end
  local listSize = listObj:getInnerContainerSize()
  tempWidget:ignoreContentAdaptWithSize(false)
  tempWidget:setSize(CCSize(listSize.width, h))
  listObj:sizeChangedForShowMoreTips()
end
function ShopNPCView:setGoldNum()
  local player = g_DataMgr:getPlayer()
  local x, y = self:getNode("box_gold"):getPosition()
  local z = self:getNode("box_gold"):getZOrder()
  local size = self:getNode("box_gold"):getSize()
  local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_GOLD))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setScale(size.width / tempImg:getContentSize().width)
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addNode(tempImg, z)
  local x, y = self:getNode("box_coin"):getPosition()
  local z = self:getNode("box_coin"):getZOrder()
  local size = self:getNode("box_coin"):getSize()
  local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_COIN))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setScale(size.width / tempImg:getContentSize().width)
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addNode(tempImg, z)
  self:updateGoldNum()
end
function ShopNPCView:updateGoldNum()
  local player = g_DataMgr:getPlayer()
  self:getNode("text_gold"):setText(string.format("%d", player:getGold()))
  self:getNode("text_coin"):setText(string.format("%d", player:getCoin()))
end
function ShopNPCView:OnMessage(msgSID, ...)
  if msgSID == MsgID_MoneyUpdate then
    self:updateGoldNum()
  end
end
function ShopNPCView:Clear()
end
function ShopNPCView:HideSelf()
  self:setVisible(false)
  if self._auto_create_opacity_bg_ins then
    self._auto_create_opacity_bg_ins:setVisible(false)
  end
end
function ShopNPCView:ShowSelf()
  self:setVisible(true)
  if self._auto_create_opacity_bg_ins then
    self._auto_create_opacity_bg_ins:setVisible(true)
  end
end
function ShopNPCView:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function ShopNPCView:OnBtn_AddMoney(obj, t)
  print("ShopNPCView:OnBtn_AddMoney")
  self:HideSelf()
  ShowRechargeView({
    callBack = function()
      self:ShowSelf()
    end
  })
end
function ShopNPCView:OnBtn_1(obj, t)
  self:ShowPage(1)
end
function ShopNPCView:OnBtn_2(obj, t)
  self:ShowPage(2)
end
function ShopNPCView:OnBtn_3(obj, t)
  self:ShowPage(3)
end
function ShopNPCView:OnBtn_4(obj, t)
end
