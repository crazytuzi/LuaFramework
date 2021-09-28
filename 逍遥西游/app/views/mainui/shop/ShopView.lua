MAX_XIAYI_VALUE = 30000
ShopView = class("ShopView", CcsSubView)
local _sortItem = function(itemA, itemB)
  if itemA == nil or itemB == nil then
    return false
  end
  local dataList = {
    data_ShopDrug,
    data_ShopEquip,
    data_ShopOther
  }
  local sortNumA = data_getShopItemSortNum(itemA, dataList)
  local sortNumB = data_getShopItemSortNum(itemB, dataList)
  if sortNumA == sortNumB then
    return itemA < itemB
  else
    return sortNumA < sortNumB
  end
end
local _sortXianGouItem = function(itemA, itemB)
  if itemA == nil or itemB == nil then
    return false
  end
  local dataA = data_ShopXianGou[itemA] or {}
  local dataB = data_ShopXianGou[itemB] or {}
  local sortNumA = dataA.sortNo or 9999
  local sortNumB = dataB.sortNo or 9999
  if sortNumA == sortNumB then
    return itemA < itemB
  else
    return sortNumA < sortNumB
  end
end
function SetSecretShopData(data)
  if ShopView.viewObj then
    ShopView.viewObj:SetSecretShopData(data)
  end
end
function SetSecretShopFrushNum(smsdFrushNum)
  if ShopView.viewObj then
    ShopView.viewObj.m_FrushNum = smsdFrushNum
    ShopView.viewObj.btn_frush:setEnabled(ShopView.viewObj.m_IsShowSMSD)
    ShopView.viewObj:getNode("text_frush"):setVisible(ShopView.viewObj.m_IsShowSMSD)
    ShopView.viewObj:setAutoFrush()
  end
end
function UpdateSecretShopData(sellId, restNum)
  if ShopView.viewObj then
    local data = DeepCopyTable(ShopView.viewObj.m_SecretShopData)
    if data[sellId] ~= nil then
      data[sellId].i_n = restNum or 0
      ShopView.viewObj:SetSecretShopData(data)
    end
  end
end
function SetXiaYiShopData(itemTable)
  if ShopView.viewObj then
    ShopView.viewObj:SetXiaYiShopData(itemTable)
  end
end
function ShopView:ctor(para)
  para = para or {}
  ShopView.super.ctor(self, "views/shop.json", {isAutoCenter = true, opacityBg = 100})
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
    btn_drug = {
      listener = handler(self, self.OnBtn_drug),
      variName = "btn_drug"
    },
    btn_daoju = {
      listener = handler(self, self.OnBtn_daoju),
      variName = "btn_daoju"
    },
    btn_smsd = {
      listener = handler(self, self.OnBtn_smsd),
      variName = "btn_smsd"
    },
    btn_xiayi = {
      listener = handler(self, self.OnBtn_xiayi),
      variName = "btn_xiayi"
    },
    btn_frush = {
      listener = handler(self, self.OnBtn_frush),
      variName = "btn_frush"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:getNode("bg_shop"):setEnabled(false)
  self:getNode("titlebg"):setEnabled(false)
  self:getNode("bg_shop"):setVisible(false)
  self:getNode("titlebg"):setVisible(false)
  self.m_FrushNum = 0
  self.m_IsShowSMSD = false
  self.m_IsShowXYSD = false
  self.btn_frush:setEnabled(false and ShopView.viewObj.m_IsShowSMSD)
  self:getNode("text_frush"):setVisible(false and ShopView.viewObj.m_IsShowSMSD)
  self:addBtnSigleSelectGroup({
    {
      self.btn_drug,
      nil,
      ccc3(251, 248, 145)
    },
    {
      self.btn_daoju,
      nil,
      ccc3(251, 248, 145)
    },
    {
      self.btn_smsd,
      nil,
      ccc3(251, 248, 145)
    },
    {
      self.btn_xiayi,
      nil,
      ccc3(251, 248, 145)
    }
  })
  self.m_PageObjList = {}
  self.m_PageObjNameList = {
    [Shop_Equip_Page] = "equip_list",
    [Shop_Drug_Page] = "drug_list",
    [Shop_Daoju_Page] = "daoju_list",
    [Shop_Smsd_Page] = "smsd_list",
    [Shop_Xiayi_Page] = "xiayi_list"
  }
  self:ListenMessage(MsgID_PlayerInfo)
  self.m_SecretShopData = {}
  netsend.netshop.openSecretShop()
  self.m_XiaYiShopData = {}
  netsend.netshop.OpenXiaYiShop()
  netsend.netshop.AskXianGouList()
  self:SetAttrTips()
  local initPageNum = para.initPage or Shop_Daoju_Page
  self.m_itmeTypeId = para.itmeTypeId
  self:setGoldNum(initPageNum)
  self:ShowPage(initPageNum)
  self:SetShopBtnClick(initPageNum)
  self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.updateFreshTime))
  self:scheduleUpdate()
  ShopView.viewObj = self
  local act1 = CCDelayTime:create(0.01)
  local act2 = CCCallFunc:create(function()
    self:InitBuyView(self.m_itmeTypeId, initPageNum)
  end)
  self:runAction(transition.sequence({act1, act2}))
end
function ShopView:SetAttrTips()
  clickArea_check.extend(self)
  self:attrclick_check_withWidgetObj(self:getNode("coinbg"), "resgold")
  self:attrclick_check_withWidgetObj(self:getNode("goldbg"), "rescoin")
  self:attrclick_check_withWidgetObj(self:getNode("xiayibg"), "resxiayi")
  self:attrclick_check_withWidgetObj(self:getNode("text_xiayi"), "resxiayi")
end
function ShopView:ShowPage(pageNum)
  if g_Click_Item_View ~= nil then
    g_Click_Item_View:removeFromParentAndCleanup(true)
  end
  if pageNum == Shop_Smsd_Page and g_CMainMenuHandler then
    g_CMainMenuHandler:SetSMSDFlag(false)
  end
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
      listObj:showMoreTips_setTipsShow_(index == pageNum)
    end
  end
  self.m_IsShowSMSD = pageNum == Shop_Smsd_Page
  self.m_IsShowXYSD = pageNum == Shop_Xiayi_Page
  self:getNode("bg_shop"):setEnabled(false)
  self:getNode("titlebg"):setEnabled(false)
  self:getNode("bg_shop"):setVisible(false)
  self:getNode("titlebg"):setVisible(false)
  self:SetXiaYiPage(pageNum)
  self:updateFreshTime()
end
function ShopView:SetXiaYiPage(pageNum)
  local xiaYiView = true
  if pageNum == Shop_Xiayi_Page then
    xiaYiView = false
  end
  self:getNode("text_gold"):setVisible(xiaYiView)
  self:getNode("coinbg"):setVisible(xiaYiView)
  self:getNode("box_gold"):setVisible(xiaYiView)
  self:getNode("btn_addmoney"):setVisible(xiaYiView)
  self:getNode("btn_addmoney"):setEnabled(xiaYiView)
  self:getNode("box_coin"):setVisible(xiaYiView)
  self:getNode("goldbg"):setVisible(xiaYiView)
  self:getNode("text_coin"):setVisible(xiaYiView)
  self.m_goldImg:setVisible(xiaYiView)
  self.m_coinImg:setVisible(xiaYiView)
  self.m_xiaYiImg:setVisible(not xiaYiView)
  self:getNode("red_poind"):setVisible(not xiaYiView)
  self:getNode("txt_xiayi"):setVisible(not xiaYiView)
  self:getNode("xiayibg"):setVisible(not xiaYiView)
  self:getNode("xiayibg"):setTouchEnabled(not xiaYiView)
  self:getNode("text_xiayi"):setVisible(not xiaYiView)
  self:getNode("text_xiayi"):setTouchEnabled(not xiaYiView)
  self:getNode("box_xiayi"):setVisible(not xiaYiView)
end
function ShopView:SetPage(pageNum)
  local everyLineNum = 2
  local listObj = self:getNode(self.m_PageObjNameList[pageNum])
  local tempWidget = Widget:create()
  tempWidget:setAnchorPoint(ccp(0, 0))
  listObj:removeAllItems()
  listObj:pushBackCustomItem(tempWidget)
  local showItemList = {}
  local xiangouList = g_LocalPlayer:GetXianGouShopList()
  local xgList = {}
  local curTime = g_DataMgr:getServerTime()
  for xiangouId, tData in pairs(xiangouList) do
    local timePoint = tData.endTimePoint
    if data_ShopXianGou[xiangouId] and data_ShopXianGou[xiangouId].shopNum == pageNum and curTime < timePoint then
      xgList[#xgList + 1] = xiangouId
    end
  end
  table.sort(xgList, _sortXianGouItem)
  for _, xgId in pairs(xgList) do
    local xgData = data_ShopXianGou[xgId]
    local id = xgData.itemid
    if xgData.gold == nil or xgData.gold == 0 then
      showItemList[#showItemList + 1] = {
        shapeId = id,
        num = 0,
        price = xgData.price,
        resType = RESTYPE_COIN,
        lvLimit = xgData.lvLimit,
        zsLimit = xgData.zsLimit,
        xgId = xgId
      }
    else
      showItemList[#showItemList + 1] = {
        shapeId = id,
        num = 0,
        price = xgData.gold,
        resType = RESTYPE_GOLD,
        lvLimit = xgData.lvLimit,
        zsLimit = xgData.zsLimit,
        xgId = xgId
      }
    end
  end
  if pageNum == Shop_Equip_Page then
    local shapeIdList = {}
    for id, _ in pairs(data_ShopEquip) do
      shapeIdList[#shapeIdList + 1] = id
    end
    table.sort(shapeIdList, _sortItem)
    for _, id in pairs(shapeIdList) do
      if data_ShopEquip[id].gold == nil or data_ShopEquip[id].gold == 0 then
        showItemList[#showItemList + 1] = {
          shapeId = id,
          num = 0,
          price = data_ShopEquip[id].price,
          resType = RESTYPE_COIN,
          lvLimit = data_ShopEquip[id].lvLimit,
          zsLimit = data_ShopEquip[id].zsLimit
        }
      else
        showItemList[#showItemList + 1] = {
          shapeId = id,
          num = 0,
          price = data_ShopEquip[id].gold,
          resType = RESTYPE_GOLD,
          lvLimit = data_ShopEquip[id].lvLimit,
          zsLimit = data_ShopEquip[id].zsLimit
        }
      end
    end
  elseif pageNum == Shop_Drug_Page then
    local shapeIdList = {}
    for id, _ in pairs(data_ShopDrug) do
      shapeIdList[#shapeIdList + 1] = id
    end
    table.sort(shapeIdList, _sortItem)
    for _, id in pairs(shapeIdList) do
      if data_ShopDrug[id].gold == nil or data_ShopDrug[id].gold == 0 then
        showItemList[#showItemList + 1] = {
          shapeId = id,
          num = 0,
          price = data_ShopDrug[id].price,
          resType = RESTYPE_COIN,
          lvLimit = data_ShopDrug[id].lvLimit,
          zsLimit = data_ShopDrug[id].zsLimit
        }
      else
        showItemList[#showItemList + 1] = {
          shapeId = id,
          num = 0,
          price = data_ShopDrug[id].gold,
          resType = RESTYPE_GOLD,
          lvLimit = data_ShopDrug[id].lvLimit,
          zsLimit = data_ShopDrug[id].zsLimit
        }
      end
    end
  elseif pageNum == Shop_Daoju_Page then
    local shapeIdList = {}
    for id, _ in pairs(data_ShopOther) do
      shapeIdList[#shapeIdList + 1] = id
    end
    table.sort(shapeIdList, _sortItem)
    for _, id in pairs(shapeIdList) do
      if data_ShopOther[id].gold == nil or data_ShopOther[id].gold == 0 then
        showItemList[#showItemList + 1] = {
          shapeId = id,
          num = 0,
          price = data_ShopOther[id].price,
          resType = RESTYPE_COIN,
          lvLimit = data_ShopOther[id].lvLimit,
          zsLimit = data_ShopOther[id].zsLimit
        }
      else
        showItemList[#showItemList + 1] = {
          shapeId = id,
          num = 0,
          price = data_ShopOther[id].gold,
          resType = RESTYPE_GOLD,
          lvLimit = data_ShopOther[id].lvLimit,
          zsLimit = data_ShopOther[id].zsLimit
        }
      end
    end
  elseif pageNum == Shop_Xiayi_Page then
    for xiayiNo, data in pairs(self.m_XiaYiShopData) do
      showItemList[#showItemList + 1] = {
        shapeId = data.itemid,
        num = data.leftnum,
        price = data.price,
        id = data.id,
        resType = RESTYPE_XIAYI,
        xiayiNo = xiayiNo
      }
    end
  else
    for smsdNo, data in pairs(self.m_SecretShopData) do
      if data.i_g == nil or data.i_g == 0 then
        showItemList[#showItemList + 1] = {
          shapeId = data.i_it,
          num = data.i_n,
          price = data.i_p,
          resType = RESTYPE_COIN,
          smsdNo = smsdNo
        }
      else
        showItemList[#showItemList + 1] = {
          shapeId = data.i_it,
          num = data.i_n,
          price = data.i_g,
          resType = RESTYPE_GOLD,
          smsdNo = smsdNo
        }
      end
    end
  end
  local itemSize
  local h = 0
  local index = 1
  local curLv = 0
  local curZs = 0
  self.m_ItemTable = {}
  local heroObj = g_LocalPlayer:getMainHero()
  if heroObj ~= nil then
    curZs = heroObj:getProperty(PROPERTY_ZHUANSHENG)
    curLv = heroObj:getProperty(PROPERTY_ROLELEVEL)
  end
  for _, data in pairs(showItemList) do
    local lvLimit = data.lvLimit or 0
    local zsLimit = data.zsLimit or 0
    if curZs > zsLimit or curZs == zsLimit and curLv >= lvLimit then
      local item
      if data.xgId ~= nil then
        item = ShopViewXianGouItem.new(data.xgId)
      else
        item = ShopViewItem.new(pageNum)
      end
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
      if data.xgId ~= nil then
      elseif pageNum == Shop_Xiayi_Page then
        local itemNum = data_XiaYiShop[data.id].Num
        item:setSMSD_No(data.xiayiNo)
        item:setXiaYiGoods_No(data.id)
        item:setPriceNum(data.price * itemNum)
        item:setItemId(data.shapeId, data.num)
        item:setPriceType(data.resType)
      else
        item:setSMSD_No(data.smsdNo)
        item:setPriceNum(data.price)
        item:setItemId(data.shapeId, data.num)
        item:setPriceType(data.resType)
      end
      self.m_ItemTable[#self.m_ItemTable + 1] = item
      index = index + 1
    end
  end
  local listSize = listObj:getInnerContainerSize()
  tempWidget:ignoreContentAdaptWithSize(false)
  tempWidget:setSize(CCSize(listSize.width, h))
  listObj:sizeChangedForShowMoreTips()
end
function ShopView:SetSecretShopData(data)
  self.m_SecretShopData = data
  ShopView.viewObj:SetPage(Shop_Smsd_Page)
  ShopView.viewObj:ShowPage(self.m_CurPageNum)
  if g_StoreView then
    g_StoreView:FlushViewData()
  end
end
function ShopView:SetXiaYiShopData(data)
  self.m_XiaYiShopData = data
  ShopView.viewObj:SetPage(Shop_Xiayi_Page)
  ShopView.viewObj:ShowPage(self.m_CurPageNum)
  if g_StoreView then
    g_StoreView:FlushViewData()
  end
end
function ShopView:InitBuyView(itmeTypeId, PageNum)
  local tag = false
  local PriceResType, TypeId, Price
  for k, item in pairs(self.m_ItemTable) do
    TypeId, PriceResType, Price = item:getItemId()
    if TypeId == itmeTypeId then
      tag = true
      break
    end
  end
  if tag == false then
    return
  end
  if g_Click_Item_View ~= nil then
    g_Click_Item_View:removeFromParentAndCleanup(true)
  end
  if JudgeIsInWar() and GetItemTypeByItemTypeId(itmeTypeId) == ITEM_LARGE_TYPE_DRUG then
    ShowNotifyTips("处于战斗中，不能购买药品")
    return
  end
  local player = g_LocalPlayer
  if (PageNum == Shop_Smsd_Page or PageNum == Shop_Xiayi_Page) and self.m_ItemNum == 0 then
    ShowNotifyTips("该物品已售罄")
    return
  end
  if PriceResType == RESTYPE_GOLD then
    if Price > player:getGold() then
      ShowNotifyTips("元宝不足")
      return
    end
  elseif PriceResType == RESTYPE_Honour then
    if Price > player:getHonour() then
      ShowNotifyTips("荣誉不足")
      return
    end
  elseif PriceResType == RESTYPE_XIAYI then
  end
  if PageNum == Shop_Daoju_Page then
    local m_initNum = g_MissionMgr:getMissionShortageObjs(self.m_mid, itmeTypeId)
    if m_initNum ~= nil then
      self.m_ItemNum = m_initNum
    else
      self.m_ItemNum = 1
    end
    CBuyNormalItemView.new(PageNum, itmeTypeId, PriceResType, Price, self.m_ItemNum)
  end
end
function ShopView:getFreshRestTime()
  local tempDict = data_Variables.ShenMiShopFlushTimeDict or {}
  local curTime = g_DataMgr:getServerTime()
  local timeTable = os.date("*t", checkint(curTime))
  local hour = timeTable.hour
  local nextHour = -1
  local addDay = 0
  for _, tempH in ipairs(tempDict) do
    if tempH > hour then
      nextHour = tempH
      break
    end
  end
  if nextHour == -1 then
    nextHour = 9
    addDay = 1
  end
  local nextTime = os.time({
    year = timeTable.year,
    month = timeTable.month,
    day = timeTable.day,
    hour = nextHour,
    min = 0,
    sec = 0,
    isdst = timeTable.isdst
  })
  if addDay == 1 then
    nextTime = nextTime + 86400
  end
  local restTime = math.floor(nextTime - curTime)
  return restTime
end
function ShopView:setAutoFrush()
  local restTime = self:getFreshRestTime()
  if self.m_DelayShowFrushWarningHandler then
    scheduler.unscheduleGlobal(self.m_DelayShowFrushWarningHandler)
    self.m_DelayShowFrushWarningHandler = nil
  end
  self.m_DelayShowFrushWarningHandler = scheduler.performWithDelayGlobal(function()
    self:ShowFrushWarning()
  end, restTime)
  self:updateFreshTime()
end
function ShopView:updateFreshTime(dt)
  if ShopView.viewObj then
    local restTime = self:getFreshRestTime()
    if restTime == 0 then
      self:getNode("text_frush"):setVisible(false and ShopView.viewObj.m_IsShowSMSD)
      self.btn_frush:setEnabled(false and ShopView.viewObj.m_IsShowSMSD)
    else
      self:getNode("text_frush"):setVisible(ShopView.viewObj.m_IsShowSMSD)
      self.btn_frush:setEnabled(ShopView.viewObj.m_IsShowSMSD)
      local text = ""
      local h, m, s = getHMSWithSeconds(restTime)
      text = string.format("%02d:%02d:%02d", h, m, s)
      self:getNode("text_frush"):setText(text)
    end
  end
end
function ShopView:setGoldNum(initPageNum)
  local player = g_DataMgr:getPlayer()
  local x, y = self:getNode("box_gold"):getPosition()
  local z = self:getNode("box_gold"):getZOrder()
  local size = self:getNode("box_gold"):getSize()
  self:getNode("box_gold"):setTouchEnabled(false)
  self.m_goldImg = display.newSprite(data_getResPathByResID(RESTYPE_GOLD))
  self.m_goldImg:setAnchorPoint(ccp(0.5, 0.5))
  self.m_goldImg:setScale(size.width / self.m_goldImg:getContentSize().width)
  self.m_goldImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addNode(self.m_goldImg, z)
  self.m_goldImg:setVisible(initPageNum ~= Shop_Xiayi_Page)
  local x, y = self:getNode("box_coin"):getPosition()
  local z = self:getNode("box_coin"):getZOrder()
  local size = self:getNode("box_coin"):getSize()
  self:getNode("box_coin"):setTouchEnabled(false)
  self.m_coinImg = display.newSprite(data_getResPathByResID(RESTYPE_COIN))
  self.m_coinImg:setAnchorPoint(ccp(0.5, 0.5))
  self.m_coinImg:setScale(size.width / self.m_coinImg:getContentSize().width)
  self.m_coinImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addNode(self.m_coinImg, z)
  self.m_coinImg:setVisible(initPageNum ~= Shop_Xiayi_Page)
  local x, y = self:getNode("box_xiayi"):getPosition()
  local z = self:getNode("box_xiayi"):getZOrder()
  local size = self:getNode("box_xiayi"):getSize()
  self:getNode("box_xiayi"):setTouchEnabled(false)
  self.m_xiaYiImg = display.newSprite(data_getResPathByResID(RESTYPE_XIAYI))
  self.m_xiaYiImg:setAnchorPoint(ccp(0.5, 0.5))
  self.m_xiaYiImg:setScale(size.width / self.m_xiaYiImg:getContentSize().width)
  self.m_xiaYiImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addNode(self.m_xiaYiImg, z)
  self.m_xiaYiImg:setVisible(not xiaYiView)
  self.m_xiaYiImg:setVisible(initPageNum == Shop_Xiayi_Page)
  self:updateGoldNum()
end
function ShopView:updateGoldNum()
  local player = g_DataMgr:getPlayer()
  self:getNode("text_gold"):setText(string.format("%d", player:getGold()))
  self:getNode("text_coin"):setText(string.format("%d", player:getCoin()))
  self:getNode("text_xiayi"):setText(string.format("%d/%d", player:getXiaYiValue(), MAX_XIAYI_VALUE))
end
function ShopView:OnMessage(msgSID, ...)
  if msgSID == MsgID_MoneyUpdate then
    self:updateGoldNum()
  elseif msgSID == MsgID_ShopXianGouListChange then
    local arg = {
      ...
    }
    local changePageList = arg[1]
    for pageNum, _ in pairs(changePageList) do
      self:SetPage(pageNum)
    end
    self:ShowPage(self.m_CurPageNum)
    if g_StoreView then
      g_StoreView:FlushViewData()
    end
  end
end
function ShopView:Clear()
  if ShopView.viewObj == self then
    ShopView.viewObj = nil
  end
  if self.m_DelayShowFrushWarningHandler then
    scheduler.unscheduleGlobal(self.m_DelayShowFrushWarningHandler)
    self.m_DelayShowFrushWarningHandler = nil
  end
  self.m_ItemTable = nil
end
function ShopView:CloseSelf()
  g_StoreView:CloseSelf()
end
function ShopView:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function ShopView:OnBtn_AddMoney(obj, t)
  g_StoreView:SelectView(StoreShow_RechargeView)
end
function ShopView:OnBtn_equip(obj, t)
  self:ShowPage(Shop_Equip_Page)
end
function ShopView:OnBtn_drug(obj, t)
  self:ShowPage(Shop_Drug_Page)
end
function ShopView:OnBtn_daoju(obj, t)
  self:ShowPage(Shop_Daoju_Page)
end
function ShopView:OnBtn_smsd(obj, t)
  self:ShowPage(Shop_Smsd_Page)
end
function ShopView:OnBtn_xiayi(obj, t)
  self:ShowPage(Shop_Xiayi_Page)
end
function ShopView:SetShopBtnClick(pageNum)
  self:ShowPage(pageNum)
  local btn
  if pageNum == Shop_Equip_Page then
    btn = self.btn_equip
  elseif pageNum == Shop_Drug_Page then
    btn = self.btn_drug
  elseif pageNum == Shop_Daoju_Page then
    btn = self.btn_daoju
  elseif pageNum == Shop_Smsd_Page then
    btn = self.btn_smsd
  end
  if btn ~= nil then
    self:setGroupBtnSelected(btn)
  end
end
function ShopView:OnBtn_frush(obj, t)
  local maxNum = 0
  for num, _ in pairs(data_ShopSecretFresh) do
    if num > maxNum then
      maxNum = num
    end
  end
  if maxNum <= self.m_FrushNum then
    ShowNotifyTips(string.format("已经刷了%d次，不能再刷了", maxNum))
    return
  end
  local needGold = 0
  if data_ShopSecretFresh[self.m_FrushNum + 1] then
    needGold = data_ShopSecretFresh[self.m_FrushNum + 1].gold
  end
  if needGold == 0 then
    return
  end
  local txt = string.format("显示新货物需要消耗%d#<IR2>#，是否继续？\n\n（今日已刷新%d次）", needGold, self.m_FrushNum)
  local tempPop = CPopWarning.new({
    title = "提示",
    text = txt,
    confirmFunc = function()
      self:FrushSMSD()
    end,
    cancelFunc = nil,
    closeFunc = function()
      self.m_FrushView = nil
    end,
    confirmText = "确定",
    cancelText = "取消",
    align = CRichText_AlignType_Left
  })
  tempPop:ShowCloseBtn(false)
  self.m_FrushView = tempPop
end
function ShopView:FrushSMSD()
  local needGold = 0
  if data_ShopSecretFresh[self.m_FrushNum + 1] then
    needGold = data_ShopSecretFresh[self.m_FrushNum + 1].gold
  end
  if needGold == 0 then
    return
  end
  local player = g_LocalPlayer
  if needGold > player:getGold() then
    ShowNotifyTips("元宝不足")
    return
  end
  netsend.netshop.frushSecretShop()
end
function ShopView:ShowFrushWarning()
  local tempPop = CPopWarning.new({
    title = "提示",
    text = "神秘商店已刷新，请重新打开",
    confirmFunc = function()
      self:CloseAllView()
    end,
    cancelFunc = nil,
    closeFunc = nil,
    confirmText = "确定",
    cancelText = "",
    align = CRichText_AlignType_Left
  })
  tempPop:ShowCloseBtn(false)
  tempPop:OnlyShowConfirmBtn()
  if self.m_DelayShowFrushWarningHandler then
    scheduler.unscheduleGlobal(self.m_DelayShowFrushWarningHandler)
    self.m_DelayShowFrushWarningHandler = nil
  end
end
function ShopView:HideSelf()
  self:setVisible(false)
  if self._auto_create_opacity_bg_ins then
    self._auto_create_opacity_bg_ins:setVisible(false)
  end
end
function ShopView:ShowSelf()
  self:setVisible(true)
  if self._auto_create_opacity_bg_ins then
    self._auto_create_opacity_bg_ins:setVisible(true)
  end
end
function ShopView:CloseAllView()
  if self.m_FrushView then
    self.m_FrushView:OnClose()
  end
  if CBuyNormalItemView.viewObj then
    CBuyNormalItemView.viewObj:OnClose()
  end
  if CBuySecretItemView.viewObj then
    CBuySecretItemView.viewObj:OnClose()
  end
  if CBuyXianGouItemView.viewObj then
    CBuyXianGouItemView.viewObj:OnClose()
  end
  self:CloseSelf()
end
