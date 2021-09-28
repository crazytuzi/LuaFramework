function ShowChangeZSXZ()
  getCurSceneView():addSubView({
    subView = CChangeZSXZ.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
CChangeZSXZ = class("CChangeZSXZ", CcsSubView)
function CChangeZSXZ:ctor(para)
  CChangeZSXZ.super.ctor(self, "views/zsxz_view.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_zs1 = {
      listener = handler(self, self.OnBtn_ZS1),
      variName = "btn_zs1"
    },
    btn_zs2 = {
      listener = handler(self, self.OnBtn_ZS2),
      variName = "btn_zs2"
    },
    btn_zs3 = {
      listener = handler(self, self.OnBtn_ZS3),
      variName = "btn_zs3"
    },
    btn_zs4 = {
      listener = handler(self, self.OnBtn_ZS4),
      variName = "btn_zs4"
    },
    btn_addcoin = {
      listener = handler(self, self.OnBtn_AddMoney),
      variName = "btn_addcoin"
    },
    btn_zsxz = {
      listener = handler(self, self.OnBtn_ZSXZ),
      variName = "btn_zsxz"
    },
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:addBtnSigleSelectGroup({
    {
      self.btn_zs1,
      nil,
      ccc3(251, 248, 145)
    },
    {
      self.btn_zs2,
      nil,
      ccc3(251, 248, 145)
    },
    {
      self.btn_zs3,
      nil,
      ccc3(251, 248, 145)
    },
    {
      self.btn_zs4,
      nil,
      ccc3(251, 248, 145)
    }
  })
  self.m_Items = {}
  self.m_DataList = self:getNode("datalist")
  self.m_ShowZSIndex = 1
  self.m_NewChangeTypeID = nil
  self:InitList()
  self:SetZSIndex(self.m_ShowZSIndex)
  self:ListenMessage(MsgID_PlayerInfo)
end
function CChangeZSXZ:SetZSIndex(newIndex)
  self.m_ShowZSIndex = newIndex
  local tempBtnNameDict = {
    [1] = self.btn_zs1,
    [2] = self.btn_zs2,
    [3] = self.btn_zs3,
    [4] = self.btn_zs4
  }
  self:setGroupBtnSelected(tempBtnNameDict[self.m_ShowZSIndex])
  self:UpdateList()
  self:SetCost()
end
function CChangeZSXZ:ChangeIndex(newIndex)
  local curZs = g_LocalPlayer:getObjProperty(1, PROPERTY_ZHUANSHENG)
  if newIndex > curZs then
    ShowNotifyTips(string.format("还没经历%d转，没有转生修正，无法查看", newIndex))
    self:SetZSIndex(self.m_ShowZSIndex)
    return
  end
  self:SetZSIndex(newIndex)
end
function CChangeZSXZ:InitList()
  self.m_DataList:addTouchItemListenerListView(handler(self, self.ChooseItem), handler(self, self.ListEventListener))
  local tempList = {
    MALE_REN_ZS_INDEX,
    FEMALE_REN_ZS_INDEX,
    MALE_XIAN_ZS_INDEX,
    FEMALE_XIAN_ZS_INDEX,
    MALE_MO_ZS_INDEX,
    FEMALE_MO_ZS_INDEX,
    MALE_GUI_ZS_INDEX,
    FEMALE_GUI_ZS_INDEX
  }
  for _, typeId in ipairs(tempList) do
    local tempItem = CChangeZSXZ_Item.new(typeId, self)
    self.m_DataList:pushBackCustomItem(tempItem.m_UINode)
    self.m_Items[#self.m_Items + 1] = tempItem
  end
  self.m_DataList:sizeChangedForShowMoreTips()
end
function CChangeZSXZ:ChooseItem(item, index, listObj)
end
function CChangeZSXZ:ListEventListener(item, index, listObj, status)
end
function CChangeZSXZ:UpdateList()
  for _, itemObj in ipairs(self.m_Items) do
    itemObj._execNodeEvent = false
    itemObj.m_UINode:retain()
  end
  self.m_DataList:removeAllItems()
  self.m_DataList:setInnerContainerSize(CCSize(0, 0))
  local zsData = g_LocalPlayer:getObjProperty(1, PROPERTY_ZSNUMLIST)
  if zsData == nil or zsData == 0 then
    zsData = {}
  end
  local zsTempData = zsData[self.m_ShowZSIndex] or {}
  local tempZSType = zsTempData[1] or 0
  for _, itemObj in ipairs(self.m_Items) do
    if itemObj:getZSTypeID() == tempZSType then
      self.m_DataList:pushBackCustomItem(itemObj.m_UINode)
      itemObj:SetIsCurFlag(true)
      itemObj:SetIsSelected(true)
      itemObj:setZSNum(self.m_ShowZSIndex)
      self.m_NewChangeTypeID = tempZSType
    end
  end
  for _, itemObj in ipairs(self.m_Items) do
    if itemObj:getZSTypeID() ~= tempZSType then
      self.m_DataList:pushBackCustomItem(itemObj.m_UINode)
      itemObj:SetIsCurFlag(false)
      itemObj:SetIsSelected(false)
      itemObj:setZSNum(self.m_ShowZSIndex)
    end
  end
  for _, itemObj in ipairs(self.m_Items) do
    itemObj.m_UINode:release()
    itemObj._execNodeEvent = true
  end
  self.m_DataList:sizeChangedForShowMoreTips()
end
function CChangeZSXZ:SetCost(price)
  local zsData = g_LocalPlayer:getObjProperty(1, PROPERTY_ZSNUMLIST)
  if zsData == nil or zsData == 0 then
    zsData = {}
  end
  local zsTempData = zsData[self.m_ShowZSIndex] or {}
  local changeNum = (zsTempData[2] or 0) + 1
  local price = data_getRbChangeCost(self.m_ShowZSIndex, changeNum)
  if self.m_CoinIcon == nil then
    local x, y = self:getNode("box_coin_cur"):getPosition()
    local z = self:getNode("box_coin_cur"):getZOrder()
    local size = self:getNode("box_coin_cur"):getSize()
    self:getNode("box_coin_cur"):setTouchEnabled(false)
    local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_COIN))
    tempImg:setAnchorPoint(ccp(0.5, 0.5))
    tempImg:setScale(size.width / tempImg:getContentSize().width)
    tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
    self:addNode(tempImg, z)
    self.m_CoinIcon = tempImg
  end
  self:getNode("txt_coin_cur"):setText(string.format("%d", price))
  AutoLimitObjSize(self:getNode("txt_coin_cur"), 100)
  local player = g_DataMgr:getPlayer()
  if price > player:getCoin() then
    self:getNode("txt_coin_cur"):setColor(ccc3(255, 0, 0))
  else
    self:getNode("txt_coin_cur"):setColor(ccc3(255, 255, 255))
  end
end
function CChangeZSXZ:setSelectTypeId(typeId)
  for index, itemObj in ipairs(self.m_Items) do
    itemObj:SetIsSelected(typeId == itemObj:getZSTypeID())
  end
  self.m_NewChangeTypeID = typeId
end
function CChangeZSXZ:OnBtn_ZSXZ(obj, t)
  local zsData = g_LocalPlayer:getObjProperty(1, PROPERTY_ZSNUMLIST)
  if zsData == nil or zsData == 0 then
    zsData = {}
  end
  local zsTempData = zsData[self.m_ShowZSIndex] or {}
  local tempZSType = zsTempData[1] or 0
  local changeNum = (zsTempData[2] or 0) + 1
  local price = data_getRbChangeCost(self.m_ShowZSIndex, changeNum)
  if self.m_NewChangeTypeID == nil or self.m_NewChangeTypeID == 0 then
    ShowNotifyTips("请选择新的种族修正")
    return
  end
  if tempZSType == self.m_NewChangeTypeID then
    ShowNotifyTips("种族修正没有改变，不需转换")
    return
  end
  local tempNameList = {
    [MALE_REN_ZS_INDEX] = "男人",
    [FEMALE_REN_ZS_INDEX] = "女人",
    [MALE_XIAN_ZS_INDEX] = "男仙",
    [FEMALE_XIAN_ZS_INDEX] = "女仙",
    [MALE_MO_ZS_INDEX] = "男魔",
    [FEMALE_MO_ZS_INDEX] = "女魔",
    [MALE_GUI_ZS_INDEX] = "男鬼",
    [FEMALE_GUI_ZS_INDEX] = "女鬼"
  }
  local zsName = tempNameList[self.m_NewChangeTypeID] or ""
  local dlg = CPopWarning.new({
    title = "提示",
    text = string.format("你确定要花费%d#<IR1>#\n转成%s(%d转)的种族修正吗？", price, zsName, self.m_ShowZSIndex),
    confirmFunc = function()
      netsend.netbaseptc.SetZhuanShengXiuZheng(self.m_ShowZSIndex, self.m_NewChangeTypeID)
    end,
    confirmText = "确定",
    cancelText = "取消",
    align = CRichText_AlignType_Left
  })
  dlg:ShowCloseBtn(false)
end
function CChangeZSXZ:OnBtn_Close(obj, t)
  self:CloseSelf()
end
function CChangeZSXZ:OnBtn_AddMoney()
  ShowRechargeView({resType = RESTYPE_COIN})
end
function CChangeZSXZ:OnBtn_ZS1(obj, t)
  local newIndex = 1
  self:ChangeIndex(newIndex)
end
function CChangeZSXZ:OnBtn_ZS2(obj, t)
  local newIndex = 2
  self:ChangeIndex(newIndex)
end
function CChangeZSXZ:OnBtn_ZS3(obj, t)
  local newIndex = 3
  self:ChangeIndex(newIndex)
end
function CChangeZSXZ:OnBtn_ZS4(obj, t)
  local newIndex = 4
  self:ChangeIndex(newIndex)
end
function CChangeZSXZ:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_HeroUpdate then
    local playerId = arg[1].pid
    local heroId = arg[1].heroId
    if playerId ~= g_LocalPlayer:getPlayerId() then
      return
    end
    if heroId ~= g_LocalPlayer:getMainHeroId() then
      return
    end
    local zsData = arg[1].pro[PROPERTY_ZSNUMLIST]
    if zsData ~= nil then
      self:SetZSIndex(self.m_ShowZSIndex)
    end
  end
end
function CChangeZSXZ:Clear()
end
CChangeZSXZ_Item = class("CChangeZSXZ_Item", CcsSubView)
function CChangeZSXZ_Item:ctor(typeID, viewObj)
  CChangeZSXZ_Item.super.ctor(self, "views/zsxz_bar.json")
  self.m_ViewObj = viewObj
  self.m_TypeID = typeID
  self.m_DetailText = nil
  self:SetZsData()
  local size = self:getNode("bg"):getContentSize()
  self.m_IsTouchMoved = false
  self.m_TouchNode = clickwidget.create(size.width, size.height, 0, 0, function(touchNode, event)
    self:OnTouchEvent(event)
  end)
  self:addChild(self.m_TouchNode)
end
function CChangeZSXZ_Item:SetZsData()
  local tempNameList = {
    [MALE_REN_ZS_INDEX] = {
      "男人修正",
      "ren"
    },
    [FEMALE_REN_ZS_INDEX] = {
      "女人修正",
      "ren"
    },
    [MALE_XIAN_ZS_INDEX] = {
      "男仙修正",
      "xian"
    },
    [FEMALE_XIAN_ZS_INDEX] = {
      "女仙修正",
      "xian"
    },
    [MALE_MO_ZS_INDEX] = {
      "男魔修正",
      "mo"
    },
    [FEMALE_MO_ZS_INDEX] = {
      "女魔修正",
      "mo"
    },
    [MALE_GUI_ZS_INDEX] = {
      "男鬼修正",
      "gui"
    },
    [FEMALE_GUI_ZS_INDEX] = {
      "女鬼修正",
      "gui"
    }
  }
  local text = tempNameList[self.m_TypeID][1]
  self:getNode("txt_name"):setText(text)
  local raceTxt = tempNameList[self.m_TypeID][2]
  self.m_RaceImage = display.newSprite(string.format("views/rolelist/pic_roleicon_%s_unselect.png", raceTxt))
  local x, y = self:getNode("img_pos"):getPosition()
  local size = self:getNode("img_pos"):getContentSize()
  self:addNode(self.m_RaceImage)
  self.m_RaceImage:setPosition(x, y)
  self.m_RaceImage:setPosition(x + size.width / 2, y + size.height / 2)
end
function CChangeZSXZ_Item:setZSNum(num)
  if self.m_DetailText == nil then
    local size = self:getNode("tips_pos"):getContentSize()
    self.m_DetailText = CRichText.new({
      width = size.width,
      fontSize = 20,
      color = ccc3(255, 255, 255),
      align = CRichText_AlignType_Left
    })
    self:addChild(self.m_DetailText)
  else
    self.m_DetailText:clearAll()
  end
  local text = GetZSXZText(self.m_TypeID, num)
  self.m_DetailText:addRichText(text)
  local h = self.m_DetailText:getContentSize().height
  local x, y = self:getNode("tips_pos"):getPosition()
  local size = self:getNode("tips_pos"):getContentSize()
  self.m_DetailText:setPosition(ccp(x, y + (size.height - h) / 2))
end
function CChangeZSXZ_Item:getZSTypeID()
  return self.m_TypeID
end
function CChangeZSXZ_Item:SetIsCurFlag(flag)
  self:getNode("txt_p"):setVisible(flag)
end
function CChangeZSXZ_Item:SetIsSelected(flag)
  self:getNode("panel_sel"):setVisible(flag)
end
function CChangeZSXZ_Item:OnTouchEvent(event)
  local bg = self:getNode("bg")
  if event == TOUCH_EVENT_BEGAN then
    bg:setColor(ccc3(100, 100, 100))
    self.m_IsTouchMoved = false
  elseif event == TOUCH_EVENT_MOVED then
    if not self.m_IsTouchMoved then
      local startPos = self.m_TouchNode:getTouchStartPos()
      local movePos = self.m_TouchNode:getTouchMovePos()
      if math.abs(startPos.x - movePos.x) + math.abs(startPos.y - movePos.y) > 20 then
        self.m_IsTouchMoved = true
        bg:setColor(ccc3(255, 255, 255))
      end
    end
  elseif event == TOUCH_EVENT_ENDED or event == TOUCH_EVENT_CANCELED then
    if bg == nil then
      return
    end
    if not self.m_IsTouchMoved then
      self:OnSelectItem()
      bg:setColor(ccc3(255, 255, 255))
      soundManager.playSound("xiyou/sound/clickbutton_2.wav")
    end
  end
end
function CChangeZSXZ_Item:OnSelectItem()
  if self.m_ViewObj then
    self.m_ViewObj:setSelectTypeId(self.m_TypeID)
  end
end
function CChangeZSXZ_Item:Clear()
  self.m_ViewObj = nil
end
