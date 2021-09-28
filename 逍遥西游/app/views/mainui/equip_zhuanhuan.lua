function ShowHasZhuanHuanXianQi(itemId)
  local viewObj = CShowZhuanHuanXianqi.new(itemId)
  getCurSceneView():addSubView({
    subView = viewObj,
    zOrder = MainUISceneZOrder.popView
  })
end
function ShowEquipZhuanHuan()
  local hlList = GetEquipZhuanHuanList()
  if #hlList <= 0 then
    ShowNotifyTips("背包中没有可以转换的仙器")
    return
  end
  local viewObj = CEquipZhuanHuan.new()
  getCurSceneView():addSubView({
    subView = viewObj,
    zOrder = MainUISceneZOrder.popView
  })
end
function GetEquipZhuanHuanList()
  local tempPosList = {}
  for _, typeName in pairs({ITEM_LARGE_TYPE_XIANQI}) do
    local tempItemList = g_LocalPlayer:GetItemTypeList(typeName)
    for _, itemId in pairs(tempItemList) do
      local tempItemIns = g_LocalPlayer:GetOneItem(itemId)
      if tempItemIns ~= nil then
        local mainHero = g_LocalPlayer:getMainHero()
        if mainHero and mainHero:CanZhuangbeiZhuanHuan(tempItemIns) then
          local tempPos = tempItemIns:getProperty(ITME_PRO_PACKAGE_POS)
          if tempPos ~= 0 and tempPos ~= nil then
            tempPosList[#tempPosList + 1] = tempPos
          end
        end
      end
    end
  end
  table.sort(tempPosList)
  return tempPosList
end
CEquipZhuanHuan = class("CEquipZhuanHuan", CcsSubView)
function CEquipZhuanHuan:ctor()
  CEquipZhuanHuan.super.ctor(self, "views/equit_zhuanhuan.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_zh = {
      listener = handler(self, self.OnBtn_ZhuanHuan),
      variName = "btn_zh"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_SelectItemId = nil
  self:SetTipsText()
  self:SetEquipList()
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_ItemInfo)
  self:ListenMessage(MsgID_MoveScene)
  self:SelectTheFirstOne()
end
function CEquipZhuanHuan:SetEquipList()
  self.poslayer = self:getNode("layer_itemlist")
  self.poslayer:setVisible(false)
  local p = self.poslayer:getParent()
  local x, y = self.poslayer:getPosition()
  local z = self.poslayer:getZOrder()
  local param = {
    itemSize = CCSize(84, 84),
    pageLines = 2,
    oneLineNum = 3,
    fadeoutAction = fadeoutAction,
    xySpace = ccp(1, 12),
    pageIconOffY = -15
  }
  local tempSelectFunc = function(itemObj)
    local itemId = itemObj:getObjId()
    local itemType = itemObj:getTypeId()
    local itemLargeType = itemObj:getType()
    if itemLargeType == ITEM_LARGE_TYPE_XIANQI then
      local mainHero = g_LocalPlayer:getMainHero()
      if mainHero and mainHero:CanZhuangbeiZhuanHuan(itemObj) then
        return true
      end
    end
    return false
  end
  self.m_PackageFrame = CPackageFrame.new(ITEM_PACKAGE_TYPE_XIANQIZHUANHUAN, handler(self, self.SetItemDetail), nil, param, tempSelectFunc, nil, nil, nil, nil, nil, nil, handler(self, self.SetSelectItem))
  self.m_PackageFrame:setPosition(ccp(x + 5, y + 50))
  p:addChild(self.m_PackageFrame, z)
end
function CEquipZhuanHuan:SelectTheFirstOne()
  local tempPosList = GetEquipZhuanHuanList()
  local firstItemId
  if tempPosList[1] ~= nil then
    local tempId = g_LocalPlayer:GetItemIdByPos(tempPosList[1])
    if tempId == nil or tempId == 0 then
    else
      firstItemId = tempId
    end
  end
  if firstItemId == nil then
    self:CloseSelf()
    return
  else
    self.m_PackageFrame:JumpToItemPage(firstItemId)
  end
end
function CEquipZhuanHuan:SetTipsText()
  local tipsText = "#<IRP>#仙器转换时，将会随机转换成自身种族能装备的仙器，转换后强化值保留，炼化属性不保留。"
  local tBox = self:getNode("tipspos")
  local size = tBox:getContentSize()
  if self.m_TipsText == nil then
    self.m_TipsText = CRichText.new({
      width = size.width,
      fontSize = 18,
      color = ccc3(94, 211, 207),
      align = CRichText_AlignType_Left
    })
    self:addChild(self.m_TipsText)
  else
    self.m_TipsText:clearAll()
  end
  self.m_TipsText:addRichText(tipsText)
  local h = self.m_TipsText:getContentSize().height
  local x, y = tBox:getPosition()
  self.m_TipsText:setPosition(ccp(x, y + (size.height - h) / 2))
end
function CEquipZhuanHuan:SetItemDetail(itemId)
  self.m_SelectItemId = itemId
  self:SetCostMoney()
  self:SetCostStuff()
  self:SetDetailBoard()
end
function CEquipZhuanHuan:SetSelectItem(item)
  if item then
    self.m_PackageFrame:ClearSelectItem()
    item:setSelected(true)
  end
end
function CEquipZhuanHuan:SetDetailBoard()
  local itemObj = g_LocalPlayer:GetOneItem(self.m_SelectItemId)
  if itemObj == nil then
    return
  end
  self.list_detail = self:getNode("list_detail")
  local x, y = self.list_detail:getPosition()
  local lSize = self.list_detail:getContentSize()
  local w, h = lSize.width, lSize.height
  self.list_detail:removeAllItems()
  local roleId = g_LocalPlayer:getMainHeroId()
  self.m_ItemDetailText = CItemDetailText.new(self.m_SelectItemId, {
    width = lSize.width - 5
  }, nil, roleId)
  self.list_detail:pushBackCustomItem(self.m_ItemDetailText)
  if self.m_ItemDetailHead then
    self.m_ItemDetailHead:removeFromParent()
  end
  self.m_ItemDetailHead = CItemDetailHead.new({
    width = w - 5
  })
  self:addChild(self.m_ItemDetailHead)
  self.m_ItemDetailHead:ShowItemDetail(self.m_SelectItemId, nil, roleId, nil, self.m_OnRoleFlag, false)
  local newSize = self.m_ItemDetailHead:getContentSize()
  self.m_ItemDetailHead:setPosition(ccp(x, y + h + newSize.height))
end
function CEquipZhuanHuan:SetCostMoney()
  local itemObj = g_LocalPlayer:GetOneItem(self.m_SelectItemId)
  if itemObj == nil then
    return
  end
  local itemTypeId = itemObj:getTypeId()
  local needMoney = data_getZhuanHuanMoney(itemTypeId)
  if self.m_MoneyIcon == nil then
    local x, y = self:getNode("box_coin"):getPosition()
    local z = self:getNode("box_coin"):getZOrder()
    local size = self:getNode("box_coin"):getSize()
    self:getNode("box_coin"):setTouchEnabled(false)
    local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_COIN))
    tempImg:setAnchorPoint(ccp(0.5, 0.5))
    tempImg:setScale(size.width / tempImg:getContentSize().width)
    tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
    self:addNode(tempImg, z)
    self.m_MoneyIcon = tempImg
  end
  self:getNode("txt_coin"):setText(string.format("%d", needMoney))
  if needMoney > g_LocalPlayer:getCoin() then
    self:getNode("txt_coin"):setColor(VIEW_DEF_WARNING_COLOR)
  else
    self:getNode("txt_coin"):setColor(ccc3(255, 255, 255))
  end
end
function CEquipZhuanHuan:SetCostStuff()
  local itemObj = g_LocalPlayer:GetOneItem(self.m_SelectItemId)
  if itemObj == nil then
    return
  end
  local itemTypeId = itemObj:getTypeId()
  local needStuffList = data_getZhuanHuanItemList(itemTypeId)
  local itemPos = self:getNode("itempos")
  itemPos:setVisible(false)
  if itemPos._posNum ~= nil then
    itemPos._posNum:removeFromParent()
    itemPos._posNum = nil
  end
  if self.m_StuffIcon then
    self.m_StuffIcon:removeFromParent()
    self.m_StuffIcon = nil
  end
  for tempTypeId, tempNeedNum in pairs(needStuffList) do
    local icon = self:AddOneStuffIcon(tempTypeId, tempNeedNum)
    self.m_StuffIcon = icon
    break
  end
end
function CEquipZhuanHuan:AddOneStuffIcon(itemTypeId, itemNeedNum)
  local pos = self:getNode("itempos")
  local s = pos:getContentSize()
  local clickListener = handler(self, self.ShowStuffDetail)
  icon = createClickItem({
    itemID = itemTypeId,
    autoSize = nil,
    num = 0,
    LongPressTime = 0,
    clickListener = clickListener,
    LongPressListener = nil,
    LongPressEndListner = nil,
    clickDel = nil,
    noBgFlag = true
  })
  local size = icon:getContentSize()
  icon:setPosition(ccp(-size.width / 2, -size.height / 2))
  pos:addChild(icon)
  icon.eqptupgradeItemTypePara = itemTypeId
  icon.eqptupgradeItemNeedNumPara = itemNeedNum or 1
  pos:setVisible(true)
  local curNum = g_LocalPlayer:GetItemNum(itemTypeId)
  local numLabel = CCLabelTTF:create(string.format("%s/%s", curNum, itemNeedNum), ITEM_NUM_FONT, 22)
  numLabel:setAnchorPoint(ccp(1, 0))
  numLabel:setPosition(ccp(s.width / 2 - 5, -s.height / 2 + 5))
  if itemNeedNum <= curNum then
    numLabel:setColor(VIEW_DEF_PGREEN_COLOR)
  else
    numLabel:setColor(VIEW_DEF_WARNING_COLOR)
  end
  pos:addNode(numLabel)
  AutoLimitObjSize(numLabel, 70)
  pos._posNum = numLabel
  return icon
end
function CEquipZhuanHuan:ShowStuffDetail(obj, t)
  self.m_PopStuffDetail = CEquipDetail.new(nil, {
    closeListener = handler(self, self.CloseStuffDetail),
    itemType = obj.eqptupgradeItemTypePara,
    eqptRoleId = self.m_ForRoleId
  })
  self:addSubView({
    subView = self.m_PopStuffDetail,
    zOrder = 9999
  })
  local x, y = self:getNode("bg1"):getPosition()
  local size = self:getNode("bg1"):getContentSize()
  self.m_PopStuffDetail:setPosition(ccp(x, y - size.height / 2))
  self.m_PopStuffDetail:ShowCloseBtn()
end
function CEquipZhuanHuan:CloseStuffDetail()
  if self.m_PopStuffDetail then
    local tempObj = self.m_PopStuffDetail
    self.m_PopStuffDetail = nil
    tempObj:CloseSelf()
  end
end
function CEquipZhuanHuan:OnBtn_Close(obj, t)
  self:CloseSelf()
end
function CEquipZhuanHuan:OnBtn_ZhuanHuan(obj, t)
  if self.m_SelectItemId == nil then
    return
  end
  local itemObj = g_LocalPlayer:GetOneItem(self.m_SelectItemId)
  if itemObj == nil then
    return
  end
  local itemTypeId = itemObj:getTypeId()
  local itemName = itemObj:getProperty(ITEM_PRO_NAME)
  local dlg = CPopWarning.new({
    title = "提示",
    text = string.format("你确定要转换#<CI:%d>%s#吗？转换后将会随机转换成新的装备部位。", itemTypeId, itemName),
    confirmFunc = function()
      netsend.netitem.equipZhuanHuan(self.m_SelectItemId)
    end,
    confirmText = "确定",
    cancelText = "取消",
    align = CRichText_AlignType_Left
  })
  dlg:ShowCloseBtn(false)
end
function CEquipZhuanHuan:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_MoneyUpdate then
    self:SetCostMoney()
  elseif msgSID == MsgID_ItemInfo_AddItem then
    self:SelectTheFirstOne()
  elseif msgSID == MsgID_ItemInfo_DelItem then
    self:SelectTheFirstOne()
  elseif msgSID == MsgID_ItemInfo_ChangeItemNum then
    self:SelectTheFirstOne()
  elseif msgSID == MsgID_ItemSource_Jump then
    self:CloseStuffDetail()
    self:CloseSelf()
  end
end
function CEquipZhuanHuan:Clear()
  self:CloseStuffDetail()
end
CShowZhuanHuanXianqi = class("CShowZhuanHuanXianqi", CcsSubView)
function CShowZhuanHuanXianqi:ctor(itemID)
  CShowZhuanHuanXianqi.super.ctor(self, "views/cangbaotu_result.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_battle = {
      listener = handler(self, self.OnBtn_Confirm),
      variName = "btn_battle"
    },
    btn_continue = {
      listener = handler(self, self.OnBtn_Continue),
      variName = "btn_continue"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:ListenMessage(MsgID_ItemInfo)
  local pos_body = self:getNode("pos_body")
  pos_body:setVisible(false)
  self.m_itemId = itemID
  self:getNode("title"):setText("获得物品!")
  local itemInfo = g_LocalPlayer:GetOneItem(itemID)
  local obj
  if itemID ~= nil and itemInfo ~= nil then
    local itemTypedId = itemInfo:getTypeId()
    local tempItemName = data_getItemName(itemTypedId)
    self:getNode("title_name"):setText(tempItemName)
    obj = createClickItem({
      itemID = itemTypedId,
      autoSize = nil,
      num = 0,
      LongPressTime = 0,
      clickListener = nil,
      LongPressListener = nil,
      LongPressEndListner = nil,
      clickDel = nil,
      noBgFlag = nil
    })
  end
  if obj ~= nil then
    self:addChild(obj, 100)
    local x, y = pos_body:getPosition()
    local size1 = pos_body:getSize()
    local size2 = obj:getSize()
    obj:setPosition(ccp(x + size1.width / 2 - size2.width / 2, y + size1.height / 2 - size2.height / 2))
    local imgPath = "views/peticon/boxlight1.png"
    local imgSprite = display.newSprite(imgPath)
    imgSprite:setPosition(ccp(x + size1.width / 2, y + size1.height / 2))
    self:addNode(imgSprite)
    imgSprite:setScale(0)
    imgSprite:runAction(transition.sequence({
      CCScaleTo:create(0.3, 1.4),
      CCCallFunc:create(function()
        soundManager.playSound("xiyou/sound/openbox.wav")
      end),
      CCScaleTo:create(0.2, 1)
    }))
    imgSprite:runAction(CCRepeatForever:create(CCRotateBy:create(1.5, 360)))
  end
  self:setOnlyShowBtnConfirm()
end
function CShowZhuanHuanXianqi:setBtnTxt()
end
function CShowZhuanHuanXianqi:setOnlyShowBtnContinue()
  self.btn_battle:setVisible(false)
  self.btn_battle:setTouchEnabled(false)
  local x, _ = self:getNode("bg"):getPosition()
  local _, y = self.btn_continue:getPosition()
  self.btn_continue:setPosition(ccp(x, y))
end
function CShowZhuanHuanXianqi:setOnlyShowBtnConfirm()
  self.btn_continue:setVisible(false)
  self.btn_continue:setTouchEnabled(false)
  local x, _ = self:getNode("bg"):getPosition()
  local _, y = self.btn_continue:getPosition()
  self.btn_battle:setPosition(ccp(x, y))
  self.btn_battle:setTitleText("查看")
  self.btn_battle:setTitleFontSize(24)
end
function CShowZhuanHuanXianqi:OnBtn_Confirm()
  self:OnBtn_Close()
  local viewObj = CLookZhuanHuanXianQi.new({
    itemId = self.m_itemId,
    hId = self.m_itemId,
    isOnRoleFlag = false
  })
  getCurSceneView():addSubView({
    subView = viewObj,
    zOrder = MainUISceneZOrder.menuView
  })
end
function CShowZhuanHuanXianqi:OnBtn_Continue()
end
function CShowZhuanHuanXianqi:OnMessage(msgSID, ...)
end
function CShowZhuanHuanXianqi:OnBtn_Close()
  self:CloseSelf()
end
function CShowZhuanHuanXianqi:Clear()
end
CLookZhuanHuanXianQi = class("CLookZhuanHuanXianQi", CcsSubView)
function CLookZhuanHuanXianQi:ctor(para)
  CLookZhuanHuanXianQi.super.ctor(self, "views/showzhuanhuanxianqi.json", {isAutoCenter = true, opacityBg = 100})
  para = para or {}
  self.m_ItemId = para.itemId
  self.m_RoleId = para.hId
  self.m_OnRoleFlag = para.isOnRoleFlag
  local btnBatchListener = {
    btn_confirm = {
      listener = handler(self, self.OnBtn_Confirm),
      variName = "btn_confirm"
    },
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:SetItemData()
end
function CLookZhuanHuanXianQi:SetItemData()
  self.list_detail = self:getNode("list_detail")
  if self.m_ItemDetailText == nil and self.m_OnRoleFlag == true then
    local x, y = self.list_detail:getPosition()
    local lSize = self.list_detail:getContentSize()
    local offy = 70
    self.list_detail:ignoreContentAdaptWithSize(false)
    self.list_detail:setPosition(ccp(x, y - offy))
    self.list_detail:setSize(CCSize(lSize.width, lSize.height + offy))
  end
  local x, y = self.list_detail:getPosition()
  local lSize = self.list_detail:getContentSize()
  local w, h = lSize.width, lSize.height
  self.list_detail:removeAllItems()
  self.m_ItemDetailText = CItemDetailText.new(self.m_ItemId, {
    width = lSize.width - 5
  }, nil, self.m_RoleId)
  self.list_detail:pushBackCustomItem(self.m_ItemDetailText)
  if self.m_ItemDetailHead then
    self.m_ItemDetailHead:removeFromParent()
  end
  self.m_ItemDetailHead = CItemDetailHead.new({
    width = w - 5
  })
  self:addChild(self.m_ItemDetailHead)
  local roleIns = g_LocalPlayer:getObjById(self.m_RoleId)
  if roleIns ~= nil and roleIns:getType() == LOGICTYPE_HERO and self.m_RoleId ~= g_LocalPlayer:getMainHeroId() and self.m_OnRoleFlag == true then
    self.m_ItemDetailHead:ShowItemDetail(self.m_ItemId, nil, self.m_RoleId, nil, self.m_OnRoleFlag, true)
  else
    self.m_ItemDetailHead:ShowItemDetail(self.m_ItemId, nil, self.m_RoleId, nil, self.m_OnRoleFlag, false)
  end
  local newSize = self.m_ItemDetailHead:getContentSize()
  self.m_ItemDetailHead:setPosition(ccp(x, y + h + newSize.height))
end
function CLookZhuanHuanXianQi:OnBtn_Confirm(...)
  self:CloseSelf()
end
function CLookZhuanHuanXianQi:OnBtn_Close(...)
  self:CloseSelf()
end
function CLookZhuanHuanXianQi:Clear()
  print("CLookZhuanHuanXianQi:Clear")
end
