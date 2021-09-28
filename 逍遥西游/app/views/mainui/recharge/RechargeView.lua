function ShowRechargeView(para, showVIPLv)
  if g_LocalPlayer:getCanShowRechargeView() then
    para = para or {}
    para.InitStoreShow = StoreShow_RechargeView
    if para.resType == RESTYPE_GOLD then
      para.resType = Shop_ReChargeGold_Page
    elseif para.resType == RESTYPE_SILVER then
      para.resType = Shop_ReChargeSilver_Page
    elseif para.resType == RESTYPE_COIN then
      para.resType = Shop_ReChargeCoin_Page
    end
    getCurSceneView():addSubView({
      subView = CStoreShow.new(para),
      zOrder = MainUISceneZOrder.menuView
    })
    if showVIPLv ~= nil then
      getCurSceneView():addSubView({
        subView = RechargeVIPView.new({VIPIndex = showVIPLv}),
        zOrder = MainUISceneZOrder.menuView
      })
    end
  else
    ShowNotifyTips("前往充值页面")
    device.openURL("http://h5.youvipwan.com/xingyue/dt1.html")
    if para and para.callBack then
      para.callBack()
    end
  end
end
RechargeView = class("RechargeView", CcsSubView)
function RechargeView:ctor(para)
  RechargeView.super.ctor(self, "views/recharge.json", {isAutoCenter = true, opacityBg = 100})
  clickArea_check.extend(self)
  para = para or {}
  self.m_CallBack = para.callBack
  self.m_PageNum = para.resType or Shop_ReChargeGold_Page
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_vip = {
      listener = handler(self, self.OnBtn_ShowVIP),
      variName = "btn_vip"
    },
    btn_1 = {
      listener = handler(self, self.OnBtn_ShowGold),
      variName = "btn_1"
    },
    btn_2 = {
      listener = handler(self, self.OnBtn_ShowTeMai),
      variName = "btn_2"
    },
    btn_3 = {
      listener = handler(self, self.OnBtn_ShowSilver),
      variName = "btn_3"
    },
    btn_4 = {
      listener = handler(self, self.OnBtn_ShowCoin),
      variName = "btn_4"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
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
    },
    {
      self.btn_4,
      nil,
      ccc3(251, 248, 145)
    }
  })
  self.m_PageIndexDict = {
    [Shop_ReChargeGold_Page] = 1,
    [Shop_ReChargeTeMai_Page] = 2,
    [Shop_ReChargeSilver_Page] = 3,
    [Shop_ReChargeCoin_Page] = 4
  }
  self.m_PageObjList = {}
  self.m_PageObjNameList = {
    "gold_list",
    "temai_list",
    "silver_list",
    "coin_list"
  }
  self:ShowPage(self.m_PageNum)
  self:SetVIPData()
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_ChongZhi)
end
function RechargeView:ShowPage(shopPageNum)
  self.m_PageNum = shopPageNum
  local pageIndex = self.m_PageIndexDict[self.m_PageNum]
  if self.m_PageObjList[pageIndex] == nil then
    self:SetPage(pageIndex)
    self.m_PageObjList[pageIndex] = self:getNode(self.m_PageObjNameList[pageIndex])
  end
  for index, name in pairs(self.m_PageObjNameList) do
    local listObj = self:getNode(name)
    if listObj then
      listObj:setVisible(index == pageIndex)
      listObj:setEnabled(index == pageIndex)
      listObj:showMoreTips_setTipsShow_(index == pageIndex)
    end
  end
  self:setResNum()
  local btnIndex = self.m_PageIndexDict[self.m_PageNum]
  self:setGroupBtnSelected(self[string.format("btn_%d", btnIndex)])
  if shopPageNum == Shop_ReChargeGold_Page then
    self:attrclick_check_withWidgetObj(self:getNode("resbg"), "resgold")
  elseif shopPageNum == Shop_ReChargeTeMai_Page then
    self:attrclick_check_withWidgetObj(self:getNode("resbg"), "resgold")
  elseif shopPageNum == Shop_ReChargeSilver_Page then
    self:attrclick_check_withWidgetObj(self:getNode("resbg"), "ressilver")
  elseif shopPageNum == Shop_ReChargeCoin_Page then
    self:attrclick_check_withWidgetObj(self:getNode("resbg"), "rescoin")
  end
end
function RechargeView:SetPage(pageIndex)
  local everyLineNum = 2
  local listObj = self:getNode(self.m_PageObjNameList[pageIndex])
  local tempWidget = Widget:create()
  tempWidget:setAnchorPoint(ccp(0, 0))
  listObj:removeAllItems()
  listObj:pushBackCustomItem(tempWidget)
  local showItemList = {}
  local resType
  if pageIndex == self.m_PageIndexDict[Shop_ReChargeGold_Page] then
    for _, num in pairs(g_LocalPlayer:getCanShowRechargeItemList()) do
      local temaiFlag = false
      for _, tmNum in pairs(WEEKLY_SHOP_ITEM_LIST) do
        if num == tmNum then
          temaiFlag = true
          break
        end
      end
      if temaiFlag == false then
        showItemList[#showItemList + 1] = num
      end
    end
    local _tempSortFunc = function(numA, numB)
      local dataA = data_Shop_ChongZhi[numA]
      local dataB = data_Shop_ChongZhi[numB]
      if dataA == nil or dataB == nil then
        return false
      end
      local sortNumA = dataA.sortNo or 999
      local sortNumB = dataB.sortNo or 999
      if sortNumA == sortNumB then
        return numA < numB
      else
        return sortNumA < sortNumB
      end
    end
    table.sort(showItemList, _tempSortFunc)
    resType = RESTYPE_GOLD
  elseif pageIndex == self.m_PageIndexDict[Shop_ReChargeTeMai_Page] then
    for _, tmNum in pairs(WEEKLY_SHOP_ITEM_LIST) do
      showItemList[#showItemList + 1] = tmNum
    end
    local _tempSortFunc = function(numA, numB)
      local dataA = data_Shop_ChongZhi[numA]
      local dataB = data_Shop_ChongZhi[numB]
      if dataA == nil or dataB == nil then
        return false
      end
      local sortNumA = dataA.sortNo or 999
      local sortNumB = dataB.sortNo or 999
      if sortNumA == sortNumB then
        return numA < numB
      else
        return sortNumA < sortNumB
      end
    end
    table.sort(showItemList, _tempSortFunc)
    resType = RESTYPE_GOLD
  elseif pageIndex == self.m_PageIndexDict[Shop_ReChargeSilver_Page] then
    for num, _ in pairs(data_Shop_BuySilver) do
      showItemList[#showItemList + 1] = num
    end
    table.sort(showItemList)
    resType = RESTYPE_SILVER
  elseif pageIndex == self.m_PageIndexDict[Shop_ReChargeCoin_Page] then
    for num, _ in pairs(data_Shop_BuyCoin) do
      showItemList[#showItemList + 1] = num
    end
    table.sort(showItemList)
    resType = RESTYPE_COIN
  end
  local itemSize
  local h = 0
  for idx, data in pairs(showItemList) do
    local item = RechargeViewItem.new({num = data, resType = resType})
    if itemSize == nil then
      itemSize = item:getContentSize()
      h = math.ceil(#showItemList / everyLineNum) * itemSize.height
    end
    tempWidget:addChild(item:getUINode())
    local lineY = math.floor((idx - 1) / everyLineNum)
    local lineX = (idx - 1) % everyLineNum
    local x = lineX * itemSize.width
    local y = -(lineY * itemSize.height)
    item:setPosition(ccp(x, h + y - itemSize.height))
  end
  local listSize = listObj:getInnerContainerSize()
  tempWidget:ignoreContentAdaptWithSize(false)
  tempWidget:setSize(CCSize(listSize.width, h))
  listObj:sizeChangedForShowMoreTips()
end
function RechargeView:setResNum()
  local player = g_DataMgr:getPlayer()
  if self.m_IconImg ~= nil then
    self.m_IconImg:removeFromParent()
  end
  local tempResTypeDict = {
    [Shop_ReChargeGold_Page] = RESTYPE_GOLD,
    [Shop_ReChargeTeMai_Page] = RESTYPE_GOLD,
    [Shop_ReChargeSilver_Page] = RESTYPE_SILVER,
    [Shop_ReChargeCoin_Page] = RESTYPE_COIN
  }
  local resType = tempResTypeDict[self.m_PageNum]
  local x, y = self:getNode("resbox"):getPosition()
  local z = self:getNode("resbox"):getZOrder()
  local size = self:getNode("resbox"):getSize()
  self:getNode("resbox"):setTouchEnabled(false)
  local tempImg = display.newSprite(data_getResPathByResID(resType))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setScale(size.width / tempImg:getContentSize().width)
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addNode(tempImg, z)
  self.m_IconImg = tempImg
  local num = 0
  local funcName = REST_GET_NUM_FUNC_NAME[resType]
  if funcName then
    local f = g_LocalPlayer[funcName]
    if f then
      num = f()
    end
  end
  self:getNode("resNum"):setText(string.format("%d", num))
end
function RechargeView:SetVIPData()
  local curVIPLv = g_LocalPlayer:getVipLv()
  local addGoldNum = g_LocalPlayer:getVipAddGold()
  self:getNode("txt_curVipLv"):setText(tostring(curVIPLv))
  local maxVIP = data_getMaxVIPLv()
  local newNeedGold = 0
  if curVIPLv >= maxVIP then
    if self.m_GoldImg ~= nil then
      self.m_GoldImg:removeFromParent()
      self.m_GoldImg = nil
    end
    self:getNode("txt1"):setVisible(false)
    self:getNode("txt_moreGoldNum"):setVisible(false)
    self:getNode("txt2"):setVisible(false)
    self:getNode("txt_newVipLv"):setVisible(false)
    self:getNode("pic_vip1"):setVisible(false)
    newNeedGold = data_getVIPNeedGold(maxVIP)
  else
    if self.m_GoldImg == nil then
      local x, y = self:getNode("goldbox"):getPosition()
      local size = self:getNode("goldbox"):getSize()
      local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_GOLD))
      tempImg:setAnchorPoint(ccp(0.5, 0.5))
      tempImg:setScale(size.width / tempImg:getContentSize().width)
      tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
      self:addNode(tempImg)
      self.m_GoldImg = tempImg
    end
    self:getNode("txt1"):setVisible(true)
    self:getNode("txt_moreGoldNum"):setVisible(true)
    self:getNode("txt2"):setVisible(true)
    self:getNode("txt_newVipLv"):setVisible(true)
    self:getNode("pic_vip1"):setVisible(true)
    newNeedGold = data_getVIPNeedGold(curVIPLv + 1)
    self:getNode("txt_moreGoldNum"):setText(tostring(math.max(0, newNeedGold - addGoldNum)))
    self:getNode("txt_newVipLv"):setText(tostring(curVIPLv + 1))
  end
  self:getNode("txt_bar"):setText(string.format("%d/%d", addGoldNum, newNeedGold))
  self:getNode("bar"):setPercent(addGoldNum / newNeedGold * 100)
end
function RechargeView:OnMessage(msgSID, ...)
  if msgSID == MsgID_MoneyUpdate then
    self:setResNum()
  elseif msgSID == MsgID_VIPUpdate then
    self:SetVIPData()
  elseif msgSID == MsgID_VIPUpdateAddGold then
    self:SetVIPData()
  elseif msgSID == MsgID_ChongZhi_ItemListUpdate then
    self:SetPage(self.m_PageIndexDict[Shop_ReChargeGold_Page])
    g_StoreView:FlushViewData()
  end
end
function RechargeView:Clear()
  if self.m_CallBack then
    self.m_CallBack()
  end
end
function RechargeView:OnBtn_Close(btnObj, touchType)
  g_StoreView:CloseSelf()
end
function RechargeView:OnBtn_ShowVIP(btnObj, touchType)
  getCurSceneView():addSubView({
    subView = RechargeVIPView.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
function RechargeView:OnBtn_ShowGold(obj, t)
  self:ShowPage(Shop_ReChargeGold_Page)
end
function RechargeView:OnBtn_ShowTeMai(obj, t)
  self:ShowPage(Shop_ReChargeTeMai_Page)
end
function RechargeView:OnBtn_ShowSilver(obj, t)
  self:ShowPage(Shop_ReChargeSilver_Page)
end
function RechargeView:OnBtn_ShowCoin(obj, t)
  self:ShowPage(Shop_ReChargeCoin_Page)
end
