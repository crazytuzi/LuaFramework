PRESENT_GIFT_ROSE_93011 = 93011
PRESENT_GIFT_ROSE_93012 = 93012
PRESENT_GIFT_ROSE_93013 = 93013
function ShowYouHaoDuView(para)
  if g_FriendsMgr:getFriendNum() > 0 then
    para = para or {}
    local fID = para.fID
    local callBackFunc = para.cbFunc
    getCurSceneView():addSubView({
      subView = CPresentView.new({callBackFunc = callBackFunc, selectId = fID}),
      zOrder = MainUISceneZOrder.menuView
    })
  else
    ShowNotifyTips("您当前没有好友")
  end
end
CPresentView = class("CPresentView", CcsSubView)
function CPresentView:ctor(listParam)
  CPresentView.super.ctor(self, "views/presentview.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_help = {
      listener = handler(self, self.Btn_Help),
      variName = "btn_close",
      param = {3}
    }
  }
  local listParam = listParam or {}
  self.m_CloseCallBack = listParam.callBackFunc
  self.m_selectFriendId = listParam.selectId or 0
  self.m_friendId = self.m_selectFriendId
  self:addBatchBtnListener(btnBatchListener)
  self:getNode("txt_name"):setText("")
  self.m_friendslist = self:getNode("friendslist")
  self.m_presentlist = self:getNode("presentlist")
  self.m_propertylist = self:getNode("propertylist")
  self.m_CurrPageItemObjs = {}
  self.m_DaoJuMaxUseTimes = 20
  self.m_GiftMaxUseTimes = 1
  self:setDaoJuList()
  self:setGiftList()
  self:InitFriendsList()
  self:SelectFriendItem(self.m_friendId)
  self:setTodayTimes()
  self:ListenMessage(MsgID_Friends)
end
function CPresentView:Btn_Help()
  local title = "增加好友度说明"
  local text = "1.有好友关系的玩家之间才能增加友好度。\n2.好友间组队PVE战斗时，每场战斗胜利50%获得1点亲密度，每天最多获得20点。\n3.通过相互送增礼物（玫瑰）可以增加双方的友好度。\n4.每天限相互赠送一次加友好度的物品。\n5.赠送次数每日5:00刷新"
  getCurSceneView():addSubView({
    subView = CPresentHelp.new({title = title, tip = text}),
    zOrder = MainUISceneZOrder.menuView
  })
end
function CPresentView:Btn_Close()
  self:CloseSelf()
end
function CPresentView:setGiftList()
  local x, y = self.m_presentlist:getPosition()
  local count = 0
  for typeId, itemIfon in pairs(data_FriendGifts) do
    if 0 < itemIfon.close then
      local item = CPresentGiftItem.new({
        itemTypeId = typeId,
        listener = handler(self, self.ClickAtPresent)
      })
      local size = item:getBoxSize()
      item:setPosition(ccp(x + (size.width + 8) * count, y + 5))
      self:addChild(item)
      count = count + 1
    end
  end
end
function CPresentView:ClickAtPresent(obj)
  if obj ~= nil then
    local objList = self.m_daojuList:getCurPageObj()
    for k, itemObj in pairs(objList) do
      itemObj:setSelected(false)
    end
    if self.m_ChoosedPresentItme ~= nil then
      self.m_ChoosedPresentItme:setSelected(false)
    end
    self.m_ChoosedPresentItme = obj
    self.m_ChoosedPresentItme:setSelected(true)
    local GiftTypeId = self.m_ChoosedPresentItme:getGifgTypeId()
    self.m_GiftTypeId = GiftTypeId
    local ItemId = g_LocalPlayer:GetOneItemIdByType(GiftTypeId)
    self:setTodayTimes(GiftTypeId)
    if ItemId == 0 or ItemId == nil then
      ItemId = nil
      local sourceview = CEquipDetail.new(ItemId, {itemType = GiftTypeId})
      if sourceview ~= nil then
        self:addSubView({
          subView = sourceview,
          zOrder = MainUISceneZOrder.menuView
        })
        local x, y = self:getNode("bg_right_1"):getPosition()
        local iSize = self:getNode("bg_right_1"):getContentSize()
        local bSize = sourceview:getBoxSize()
        sourceview:setPosition(ccp(x - 2 * bSize.width + iSize.width, y - bSize.height / 2 + 9))
        sourceview:ShowCloseBtn()
      end
    else
      local params = {
        itemObjId = ItemId,
        pid = self.m_friendId,
        isGift = true
      }
      getCurSceneView():addSubView({
        subView = CPresentDaoJuBuyView.new(params),
        zOrder = MainUISceneZOrder.menuView
      })
    end
  end
end
function CPresentView:setDaoJuList()
  local x, y = self.m_propertylist:getPosition()
  local z = self.m_propertylist:getZOrder()
  local param = {
    xySpace = ccp(0, 0),
    itemSize = CCSize(90, 94),
    pageLines = 2,
    oneLineNum = 3,
    pageIconOffY = -20
  }
  local tempSelectFunc = function(itemObj)
    local itemId = itemObj:getObjId()
    local itemType = itemObj:getTypeId()
    if itemType == ITEM_DEF_OTHER_PUTONGMEIGUI or itemType == ITEM_DEF_OTHER_LANGMANMEIGUI or itemType == ITEM_DEF_OTHER_SHEHUAMEIGUI then
      return false
    end
    if data_FriendGifts[itemType] == nil then
      return false
    end
    return true
  end
  self.m_daojuList = CPackageFrame.new(ITEM_PACKAGE_TYPE_YOUHAODU, function(itemObjId)
    self:showItemSource(itemObjId, nil)
  end, nil, param, tempSelectFunc, nil, nil, nil, nil)
  self:addChild(self.m_daojuList, z + 100)
  self.m_daojuList:setPosition(ccp(x, y))
end
function CPresentView:showItemSource(itemObjId)
  if self.m_ChoosedPresentItme ~= nil then
    self.m_ChoosedPresentItme:setSelected(false)
    self.m_ChoosedPresentItme = nil
  end
  local params = {
    itemObjId = itemObjId,
    pid = self.m_friendId
  }
  getCurSceneView():addSubView({
    subView = CPresentDaoJuBuyView.new(params),
    zOrder = MainUISceneZOrder.menuView
  })
  self:setTodayTimes()
end
function CPresentView:setTodayTimes(flowerItemId)
  local info = g_FriendsMgr:getPlayerInfo(self.m_friendId)
  local donataTimesList = info.pcnt or 0
  local daojuTimes = g_MissionMgr:getDonateDaoJuTimes() or 0
  if flowerItemId == PRESENT_GIFT_ROSE_93011 then
    giftTimes = donataTimesList[1] or 0
  elseif flowerItemId == PRESENT_GIFT_ROSE_93012 then
    giftTimes = donataTimesList[2] or 0
  elseif flowerItemId == PRESENT_GIFT_ROSE_93013 then
    giftTimes = donataTimesList[3] or 0
  end
  if flowerItemId then
    self:getNode("g_times"):setVisible(true)
    self:getNode("g_times"):setText(string.format("%d/%d", giftTimes, self.m_GiftMaxUseTimes))
  else
    self:getNode("g_times"):setVisible(false)
  end
  self:getNode("d_times"):setText(string.format("%d/%d", daojuTimes, self.m_DaoJuMaxUseTimes))
end
function CPresentView:InitFriendsList()
  self.m_friendslist:removeAllItems()
  local sortFun = function(pid_1, pid_2)
    if pid_1 == nil or pid_2 == nil then
      return false
    end
    local info_1 = g_FriendsMgr:getPlayerInfo(pid_1)
    local info_2 = g_FriendsMgr:getPlayerInfo(pid_2)
    local fValue_1 = info_1.fValue
    local fValue_2 = info_2.fValue
    if fValue_1 > fValue_2 then
      return true
    else
      return false
    end
  end
  local firendlist_Id = {}
  local s_index = 1
  local localPlayerId = g_LocalPlayer:getPlayerId()
  local friendsList = g_FriendsMgr:getFriendsList()
  for _, d in pairs(friendsList) do
    local pid, info = d[1], d[2]
    if pid ~= localPlayerId then
      firendlist_Id[#firendlist_Id + 1] = pid
    end
  end
  table.sort(firendlist_Id, sortFun)
  local banlvId = g_FriendsMgr:getBanLvId() or 0
  if self.m_selectFriendId ~= 0 and self.m_selectFriendId ~= nil and self.m_selectFriendId ~= banlvId then
    for index, id in pairs(firendlist_Id) do
      if self.m_selectFriendId == id then
        table.remove(firendlist_Id, index)
        table.insert(firendlist_Id, 1, self.m_selectFriendId)
        s_index = s_index + 1
      end
    end
  end
  if banlvId ~= nil and banlvId ~= 0 then
    for index, id in pairs(firendlist_Id) do
      if banlvId == id then
        table.remove(firendlist_Id, index)
        table.insert(firendlist_Id, s_index, banlvId)
      end
    end
  end
  for index, pid in pairs(firendlist_Id) do
    local info = g_FriendsMgr:getPlayerInfo(pid)
    if pid ~= localPlayerId then
      local item = CPresentFriendItem.new(pid, info, handler(self, self.ClickFriendListener))
      self.m_CurrPageItemObjs[#self.m_CurrPageItemObjs + 1] = item
      if self.m_selectFriendId == pid and item ~= nil then
        self:ClearSelectItem()
        item:SetItemChoosed(true)
        self.m_friendId = self.m_selectFriendId
      elseif index == 1 and (self.m_selectFriendId == 0 or self.m_selectFriendId == nil) then
        self.m_friendId = pid
        self:ClearSelectItem()
        item:SetItemChoosed(true)
      end
      self.m_friendslist:pushBackCustomItem(item:getUINode())
    end
  end
  self.m_friendslist:sizeChangedForShowMoreTips()
end
function CPresentView:ClickAtFriendItem(obj)
  if obj == nil then
    return
  end
  self.m_TouchBeganHaoYouItem = obj
  self.m_friendId = self.m_TouchBeganHaoYouItem:getPlayerId()
  self:ClearSelectItem()
  self.m_TouchBeganHaoYouItem:SetItemChoosed(true)
  self:SelectFriendItem(self.m_friendId)
  self:setTodayTimes()
end
function CPresentView:SelectFriendItem(friendId)
  local info = g_FriendsMgr:getPlayerInfo(friendId)
  local name = info.name
  self:getNode("txt_name"):setText(string.format("赠送:%s", name))
end
function CPresentView:ClearSelectItem()
  for _, petObj in pairs(self.m_CurrPageItemObjs) do
    petObj:SetItemChoosed(false)
  end
end
function CPresentView:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_Friends_UpdateFirend then
    self:setTodayTimes(self.m_GiftTypeId)
    self.m_GiftTypeId = nil
  elseif msgSID == MsgID_Friends_FlushBanLv then
    self.m_BanLvId = arg[1]
  elseif msgSID == MsgID_Friends_FlushUseDaoJuTimes then
    self:setTodayTimes()
  end
end
function CPresentView:ClickFriendListener(obj)
  self:ClickAtFriendItem(obj)
end
function CPresentView:Clear()
  print("CPresentViewclear")
  if self.m_CloseCallBack then
    self.m_CloseCallBack()
  end
  self.m_CloseCallBack = nil
  self.m_daojuList = nil
  self.m_ChoosedPresentItme = nil
  self.m_TouchBeganHaoYouItem = nil
  self.m_friendslist = nil
end
CPresentDaoJuBuyView = class("CPresentDaoJuBuyView", CcsSubView)
function CPresentDaoJuBuyView:ctor(paramTable)
  paramTable = paramTable or {}
  CPresentDaoJuBuyView.super.ctor(self, "views/presentbuyview.json", {isAutoCenter = true, opacityBg = 100})
  self.m_ItemObjId = paramTable.itemObjId
  self.m_friendId = paramTable.pid
  self.m_isGiftTag = paramTable.isGift or false
  self.m_itemIns = g_LocalPlayer:GetOneItem(self.m_ItemObjId)
  self.m_ItemTypeId = self.m_itemIns:getTypeId()
  local btnBatchListener = {
    btn_left = {
      listener = handler(self, self.OnBtn_Left),
      variName = "btn_left"
    },
    btn_right = {
      listener = handler(self, self.OnBtn_Right),
      variName = "btn_right"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_CloseListener = paramTable.closeListener
  self.m_UseNum = 1
  self.m_MaxDonateNum = 20
  self.m_itemNum = self:getNode("text_num")
  self.m_itemNum:setText(self.m_UseNum)
  self.list_detail = self:getNode("list_detail")
  local x, y = self.list_detail:getPosition()
  local lSize = self.list_detail:getContentSize()
  local w, h = lSize.width, lSize.height
  local showSourceFlag = false
  self.m_ItemDetailText = CItemDetailText.new(self.m_ItemObjId, {
    width = lSize.width
  }, paramTable.itemType, paramTable.eqptRoleId, nil, showSourceFlag, nil)
  self.list_detail:pushBackCustomItem(self.m_ItemDetailText)
  if self.m_ItemDetailHead then
    self.m_ItemDetailHead:removeFromParent()
  end
  self.m_ItemDetailHead = CItemDetailHead.new({
    width = w - 5,
    showName = paramTable.showName
  })
  self:getNode("boxbg"):addChild(self.m_ItemDetailHead)
  local isHuobanFlag = false
  if paramTable.isHuobanFlag == true then
    isHuobanFlag = true
  end
  self.m_ItemDetailHead:ShowItemDetail(self.m_ItemObjId, paramTable.itemType, paramTable.eqptRoleId, nil, paramTable.isCurrEquipShow, isHuobanFlag)
  local newSize = self.m_ItemDetailHead:getContentSize()
  self.m_ItemDetailHead:setPosition(ccp(x, y + h + newSize.height))
  local addpro_bg = self:getNode("bg_num")
  local x, y = addpro_bg:getPosition()
  local p = addpro_bg:getParent()
  self.btn_addnum = createClickButton("views/rolelist/btn_addpro.png", "views/rolelist/btn_addpro_gray.png", handler(self, self.Btn_AddNum))
  self.btn_addMax = createClickButton("views/rolelist/btn_max.png", "views/rolelist/btn_maxpro_gray.png", handler(self, self.Btn_MaxNum))
  p:addChild(self.btn_addnum)
  p:addChild(self.btn_addMax)
  self.btn_addnum:setPosition(ccp(x + 37, y - 26))
  self.btn_addMax:setPosition(ccp(x + 87, y - 26))
  self.btn_subnum = createClickButton("views/rolelist/btn_subpro.png", "views/rolelist/btn_subpro_gray.png", handler(self, self.Btn_SubNum))
  p:addChild(self.btn_subnum)
  self.btn_subnum:setPosition(ccp(x - 83, y - 26))
  self:ListenMessage(MsgID_Friends)
  self:ListenMessage(MsgID_ItemInfo)
  if self.m_isGiftTag == true then
    self:setBtnIsvisible()
  end
end
function CPresentDaoJuBuyView:Btn_AddNum()
  local PackMaxNum = self.m_itemIns:getProperty(ITEM_PRO_NUM)
  local datatable = GetItemDataByItemTypeId(self.m_ItemTypeId)
  local useLimitNum = datatable[self.m_ItemTypeId].usecntLimit or self.m_MaxDonateNum
  if useLimitNum > self.m_UseNum then
    if PackMaxNum > self.m_UseNum then
      self.m_UseNum = self.m_UseNum + 1
      self.m_itemNum:setText(self.m_UseNum)
    else
      ShowNotifyTips("赠送物品数量不能大于背包现有数量")
    end
  else
    ShowNotifyTips("每日最多赠送20个道具")
  end
end
function CPresentDaoJuBuyView:Btn_SubNum()
  if self.m_UseNum > 1 then
    self.m_UseNum = self.m_UseNum - 1
    self.m_itemNum:setText(self.m_UseNum)
  else
    ShowNotifyTips("赠送物品数量不能少于一个")
  end
end
function CPresentDaoJuBuyView:Btn_MaxNum()
  local PackMaxNum = self.m_itemIns:getProperty(ITEM_PRO_NUM)
  local datatable = GetItemDataByItemTypeId(self.m_ItemTypeId)
  local useLimitNum = datatable[self.m_ItemTypeId].usecntLimit or self.m_MaxDonateNum
  if self.m_UseNum == PackMaxNum or self.m_UseNum == useLimitNum then
    if self.m_UseNum < self.m_MaxDonateNum then
      ShowNotifyTips("赠送物品数量不能大于背包现有数量")
    elseif self.m_isGiftTag == true then
      ShowNotifyTips("赠送物品数量不能大于背包现有数量")
    else
      ShowNotifyTips("每日最多赠送20个道具")
    end
    return
  end
  if PackMaxNum < useLimitNum then
    self.m_UseNum = PackMaxNum
  else
    self.m_UseNum = useLimitNum
  end
  self.m_itemNum:setText(self.m_UseNum)
end
function CPresentDaoJuBuyView:OnBtn_Left()
  self:CloseSelf()
end
function CPresentDaoJuBuyView:OnBtn_Right()
  local num = g_LocalPlayer:GetItemNum(self.m_ItemTypeId) or 0
  if self.m_friendId ~= nil and num ~= 0 then
    netsend.netmarry.donatePresent(self.m_friendId, self.m_ItemObjId, self.m_UseNum)
  else
    ShowNotifyTips("请选择你要赠送的对象")
  end
end
function CPresentDaoJuBuyView:setBtnIsvisible()
  self.btn_addnum:setEnabled(false)
  self.btn_addMax:setEnabled(false)
  self.btn_subnum:setEnabled(false)
  local x, y = self:getNode("txt_gmsl"):getPosition()
  local size = self.btn_addnum:getContentSize()
  self:getNode("txt_gmsl"):setPosition(ccp(x + size.width / 2, y))
end
function CPresentDaoJuBuyView:getItemObjId()
  return self.m_ItemObjId
end
function CPresentDaoJuBuyView:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function CPresentDaoJuBuyView:getBoxSize()
  return self:getNode("boxbg"):getSize()
end
function CPresentDaoJuBuyView:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_Friends_UpdateFirend then
    self:CloseSelf()
  elseif msgSID == MsgID_ItemInfo_DelItem then
    local num = g_LocalPlayer:GetItemNum(self.m_ItemTypeId) or 0
    if num == 0 then
      self:CloseSelf()
    end
  end
end
function CPresentDaoJuBuyView:Clear()
end
CPresentHelp = class("CPresentHelp", CcsSubView)
function CPresentHelp:ctor(params)
  CPresentHelp.super.ctor(self, "views/presentgift_tips.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  local title = params.title or "提示"
  local tip = params.tip or ""
  self:setTipAndTitle(title, tip)
end
function CPresentHelp:setTipAndTitle(title, tip)
  self:getNode("title"):setText(title)
  self:getNode("txt_tip"):setText(tip)
end
function CPresentHelp:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function CPresentHelp:Clear()
end
