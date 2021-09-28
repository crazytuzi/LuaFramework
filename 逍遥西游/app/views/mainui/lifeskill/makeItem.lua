function ShowMakeLifeItem(skID, callback)
  print("ShowMakeLifeItem")
  if skID ~= LIFESKILL_MAKEFOOD and skID ~= LIFESKILL_MAKEFU and skID ~= LIFESKILL_MAKEDRUG then
    print("不是显示的那些技能。")
    if callback then
      callback()
    end
    return
  end
  getCurSceneView():addSubView({
    subView = CMakeLifeItemView.new(skID, callback),
    zOrder = MainUISceneZOrder.menuView
  })
end
CMakeLifeItemView = class("CMakeLifeItemView", CcsSubView)
function CMakeLifeItemView:ctor(skID, callback)
  self.m_LifeSkillID = skID
  self.m_CallBack = callback
  CMakeLifeItemView.super.ctor(self, "views/makeitemshow.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_upgrade = {
      listener = handler(self, self.OnBtn_Create),
      variName = "btn_upgrade"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:SetTitleText()
  self:InitTypeList()
  local firstBigType = self.m_BigTypeList[1]
  local firstSmallType = self.m_SmallTypeList[firstBigType][1]
  self:ShowItemInfo(firstBigType, firstSmallType)
  self:ShowSubType(0, firstBigType)
  self:SetAttrTips()
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_ItemInfo)
  self:ListenMessage(MsgID_MoveScene)
end
function CMakeLifeItemView:SetAttrTips()
  clickArea_check.extend(self)
  self:attrclick_check_withWidgetObj(self:getNode("coinBg"), "reshuoli")
end
function CMakeLifeItemView:SetTitleText()
  if self.m_LifeSkillID == LIFESKILL_MAKEFOOD then
    self:getNode("title"):setText("烹饪")
  elseif self.m_LifeSkillID == LIFESKILL_MAKEFU then
    self:getNode("title"):setText("制符")
  elseif self.m_LifeSkillID == LIFESKILL_MAKEDRUG then
    self:getNode("title"):setText("制药")
  end
  local x, y = self:getNode("box_coin"):getPosition()
  local z = self:getNode("box_coin"):getZOrder()
  local size = self:getNode("box_coin"):getSize()
  self:getNode("box_coin"):setTouchEnabled(false)
  local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_HUOLI))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setScale(size.width / tempImg:getContentSize().width)
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addNode(tempImg, z)
end
function CMakeLifeItemView:InitTypeList()
  self.m_SelectBigType = nil
  self.m_SelectSmallType = nil
  self.m_BigTypeList = {}
  self.m_BigNameDict = {}
  self.m_SmallTypeList = {}
  self.m_SmallNameDict = {}
  local iData
  if self.m_LifeSkillID == LIFESKILL_MAKEFOOD then
    iData = data_LifeSkill_Food
  elseif self.m_LifeSkillID == LIFESKILL_MAKEFU then
    iData = data_LifeSkill_Rune
  elseif self.m_LifeSkillID == LIFESKILL_MAKEDRUG then
    iData = data_LifeSkill_Drug
  end
  local itemList = {}
  for itemId, itemData in pairs(iData) do
    local needLv = itemData.NeedLv or 0
    itemList[#itemList + 1] = {itemId, needLv}
  end
  table.sort(itemList, function(data1, data2)
    if data1 == nil or data2 == nil then
      return false
    end
    if data1[2] == data2[2] then
      return data1[1] < data2[1]
    else
      return data1[2] < data2[2]
    end
  end)
  for _, itemData in ipairs(itemList) do
    local itemId = itemData[1]
    local tempData = iData[itemId]
    local bigType = tempData.MainCategoryId
    local bigName = tempData.MainCategoryName
    local smallType = tempData.MinorCategoryId
    local smallName = tempData.MinorCategoryName
    if self.m_BigNameDict[bigType] == nil then
      self.m_BigTypeList[#self.m_BigTypeList + 1] = bigType
      self.m_BigNameDict[bigType] = bigName
      self.m_SmallTypeList[bigType] = {smallType}
      self.m_SmallNameDict[bigType] = {}
      self.m_SmallNameDict[bigType][smallType] = {name = smallName, id = itemId}
    elseif self.m_SmallNameDict[bigType][smallType] == nil then
      self.m_SmallTypeList[bigType][#self.m_SmallTypeList[bigType] + 1] = smallType
      self.m_SmallNameDict[bigType][smallType] = {name = smallName, id = itemId}
    end
  end
  self.list_type = self:getNode("list_type")
  self.list_type:addTouchItemListenerListView(handler(self, self.ChooseTypeItem), handler(self, self.ListEventListener))
  self.m_LargeItemList = {}
  for _, index in ipairs(self.m_BigTypeList) do
    local tempItem = CMainTypeListItem.new(index, self.m_BigNameDict[index])
    self.list_type:pushBackCustomItem(tempItem)
  end
end
function CMakeLifeItemView:HideAllSubType()
  for index = self.list_type:getCount() - 1, 0, -1 do
    local item = self.list_type:getItem(index)
    if iskindof(item, "CSubTypeListItem") then
      self.list_type:removeItem(index)
    end
  end
  self.m_SubTypeIsShow = false
end
function CMakeLifeItemView:ShowSubType(index, mainType)
  local subTypes = self.m_SmallTypeList[mainType]
  if subTypes == nil then
    return
  end
  local temp = {}
  for i = #subTypes, 1, -1 do
    local subType = subTypes[i]
    local subTypeItem = CSubTypeListItem.new(mainType, subType, self.m_SmallNameDict[mainType][subType].name)
    self.list_type:insertCustomItem(subTypeItem, index + 1)
    if self.m_SelectBigType == mainType and self.m_SelectSmallType == subType then
      subTypeItem:setItemChoosed(true)
    end
    firstSubType = subType
    firstSubTypeItem = subTypeItem
  end
  self.list_type:ListViewScrollToIndex_Vertical(index, 0.3)
  self.m_SubTypeIsShow = true
  return firstSubType, firstSubTypeItem
end
function CMakeLifeItemView:ChooseTypeItem(item, index)
  soundManager.playSound("xiyou/sound/clickbutton_1.wav")
  if iskindof(item, "CMainTypeListItem") then
    local mainType = item:getMainType()
    if self.m_SelectBigType == mainType then
      if self.m_SubTypeIsShow then
        self:HideAllSubType()
      else
        self:ShowSubType(index, mainType)
      end
    else
      self:HideAllSubType()
      local insertIndex
      for i = 0, self.list_type:getCount() - 1 do
        local tempItem = self.list_type:getItem(i)
        if iskindof(tempItem, "CMainTypeListItem") and tempItem:getMainType() == mainType then
          insertIndex = i
          break
        end
      end
      if insertIndex ~= nil then
        local firstSubType, firstSubTypeItem = self:ShowSubType(insertIndex, mainType)
        self.m_SelectBigType = mainType
        if firstSubType ~= nil then
          firstSubTypeItem:setItemChoosed(true)
          self:ShowItemInfo(mainType, firstSubType)
        end
      end
    end
  elseif iskindof(item, "CSubTypeListItem") then
    for index = self.list_type:getCount() - 1, 0, -1 do
      local tempItem = self.list_type:getItem(index)
      if iskindof(tempItem, "CSubTypeListItem") then
        if tempItem ~= item then
          tempItem:setItemChoosed(false)
        else
          tempItem:setItemChoosed(true)
        end
      end
    end
    local mainType = item:getMainType()
    local subType = item:getSubType()
    self:ShowItemInfo(mainType, subType)
  end
end
function CMakeLifeItemView:ListEventListener(item, index, listObj, status)
  if status == LISTVIEW_ONSELECTEDITEM_START then
    if item then
      item:setTouchStatus(true)
      self.m_TouchStartItem = item
    end
  elseif status == LISTVIEW_ONSELECTEDITEM_END then
    if self.m_TouchStartItem then
      self.m_TouchStartItem:setTouchStatus(false)
      self.m_TouchStartItem = nil
    end
    if item then
      item:setTouchStatus(false)
    end
  end
end
function CMakeLifeItemView:ShowItemInfo(mainType, subType)
  self.m_SelectBigType = mainType
  self.m_SelectSmallType = subType
  self.m_ShowingItemType = self.m_SmallNameDict[mainType][subType].id
  self:SetCreateStuffs()
  self:SetCreateHuoli()
  self:SetCreateNeedLv()
end
function CMakeLifeItemView:SetCreateStuffs()
  if self.m_ShowingItemType == nil then
    return
  end
  if self.m_IconList == nil then
    self.m_IconList = {}
  end
  for _, icon in pairs(self.m_IconList) do
    icon:removeFromParent()
  end
  self.m_IconList = {}
  for i = 1, 6 do
    local tempPos = self:getNode(string.format("itempos%d", i))
    if tempPos then
      tempPos:setVisible(false)
      if tempPos._posNum ~= nil then
        tempPos._posNum:removeFromParent()
        tempPos._posNum = nil
      end
    end
  end
  local tempDict = {
    {
      self.m_ShowingItemType,
      1
    }
  }
  local tList = data_getStuffsForLifeItem(self.m_ShowingItemType)
  for tType, tNum in pairs(tList) do
    tempDict[#tempDict + 1] = {tType, tNum}
  end
  for index, data in ipairs(tempDict) do
    local itemTypeId = data[1]
    local itemNeedNum = data[2]
    local pos = self:getNode(string.format("itempos%d", index))
    local icon = self:AddOneStuffIcon(index, pos, itemTypeId, itemNeedNum)
    self.m_IconList[#self.m_IconList + 1] = icon
  end
end
function CMakeLifeItemView:GetItemNeedHuoLiValue(itemType)
  local _, lsLv = g_LocalPlayer:getBaseLifeSkill()
  local needHL = data_getHuoliForLifeItem(itemType, lsLv)
  if activity.huoliHuodong:getIsStarting() then
    needHL = math.floor(needHL * 0.5)
  end
  return needHL
end
function CMakeLifeItemView:SetCreateHuoli()
  if self.m_ShowingItemType == nil then
    return
  end
  local needHL = self:GetItemNeedHuoLiValue(self.m_ShowingItemType)
  self:getNode("txt_coin"):setText(string.format("%d/%d", g_LocalPlayer:getHuoli(), needHL))
  if needHL > g_LocalPlayer:getHuoli() then
    self:getNode("txt_coin"):setColor(ccc3(255, 0, 0))
  else
    self:getNode("txt_coin"):setColor(ccc3(255, 255, 255))
  end
end
function CMakeLifeItemView:SetCreateNeedLv()
  if self.m_ShowingItemType == nil then
    return
  end
  local needLV = data_getLifeSkillLvForLifeItem(self.m_ShowingItemType)
  local _, lsLv = g_LocalPlayer:getBaseLifeSkill()
  if needLV <= lsLv then
    self.btn_upgrade:setEnabled(true)
    if self.m_WarningLVText ~= nil then
      self.m_WarningLVText:setVisible(false)
    end
  else
    self.btn_upgrade:setEnabled(false)
    if self.m_WarningLVText ~= nil then
      self.m_WarningLVText:setVisible(true)
      self.m_WarningLVText:setString(string.format("技能%d级开启", needLV))
    else
      self.m_WarningLVText = ui.newTTFLabel({
        text = string.format("技能%d级开启", needLV),
        font = KANG_TTF_FONT,
        size = 20,
        color = ccc3(255, 0, 0)
      })
      self.m_WarningLVText:setAnchorPoint(ccp(0.5, 0.5))
      self:addNode(self.m_WarningLVText)
      local x, y = self.btn_upgrade:getPosition()
      self.m_WarningLVText:setPosition(ccp(x, y))
    end
  end
end
function CMakeLifeItemView:AddOneStuffIcon(index, pos, itemTypeId, itemNeedNum)
  local s = pos:getContentSize()
  local clickListener = handler(self, self.ShowStuffDetail)
  local myItemPath
  if itemTypeId == 702061 then
    myItemPath = "xiyou/item/item_wuxingwine.png"
  end
  icon = createClickItem({
    itemID = itemTypeId,
    autoSize = nil,
    num = 0,
    LongPressTime = 0,
    clickListener = clickListener,
    LongPressListener = nil,
    LongPressEndListner = nil,
    clickDel = nil,
    noBgFlag = true,
    myItemPath = myItemPath
  })
  local size = icon:getContentSize()
  icon:setPosition(ccp(-size.width / 2, -size.height / 2))
  pos:addChild(icon)
  icon.eqptupgradeItemTypePara = itemTypeId
  icon.eqptupgradeItemNeedNumPara = itemNeedNum or 1
  icon.eqptupgradeItemPosPara = index
  pos:setVisible(true)
  if index == 1 then
    icon.showName = self.m_SmallNameDict[self.m_SelectBigType][self.m_SelectSmallType].name
  end
  if index ~= 1 then
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
  end
  return icon
end
function CMakeLifeItemView:ShowStuffDetail(obj, t)
  self.m_PopStuffDetail = CEquipDetail.new(nil, {
    closeListener = handler(self, self.CloseStuffDetail),
    itemType = obj.eqptupgradeItemTypePara,
    showName = obj.showName
  })
  self:addSubView({
    subView = self.m_PopStuffDetail,
    zOrder = 9999
  })
  self:SelectStuffItem(obj.eqptupgradeItemPosPara)
  local x, y = self:getNode("pic_leftbg"):getPosition()
  local size = self:getNode("pic_leftbg"):getContentSize()
  self.m_PopStuffDetail:setPosition(ccp(x - size.width / 2, y - size.height / 2))
  self.m_PopStuffDetail:ShowCloseBtn()
end
function CMakeLifeItemView:SelectStuffItem(index)
  local selectImgTag = 9999
  for i = 1, 6 do
    local obj = self:getNode(string.format("itempos%d", i))
    if obj ~= nil then
      local oldImg = obj:getVirtualRenderer():getChildByTag(selectImgTag)
      if i == index then
        if oldImg == nil then
          local img = display.newSprite("xiyou/item/selecteditem.png")
          obj:getVirtualRenderer():addChild(img, 10, selectImgTag)
          local size = obj:getContentSize()
          img:setPosition(ccp(size.width / 2, size.height / 2))
        end
      elseif oldImg ~= nil then
        obj:getVirtualRenderer():removeChild(oldImg)
      end
    end
  end
end
function CMakeLifeItemView:CloseStuffDetail()
  if self.m_PopStuffDetail then
    self:SelectStuffItem()
    local tempObj = self.m_PopStuffDetail
    self.m_PopStuffDetail = nil
    tempObj:CloseSelf()
  end
end
function CMakeLifeItemView:OnBtn_Create(obj, t)
  if self.m_SelectBigType == nil or self.m_SelectSmallType == nil then
    ShowNotifyTips("请选择合成的物品")
    return
  end
  local _, lsLv = g_LocalPlayer:getBaseLifeSkill()
  local needHL = self:GetItemNeedHuoLiValue(self.m_ShowingItemType)
  if needHL > g_LocalPlayer:getHuoli() then
    ShowNotifyTips("活力不足")
    return
  end
  local needLV = data_getLifeSkillLvForLifeItem(self.m_ShowingItemType)
  if lsLv < needLV then
    ShowNotifyTips("生活技能不足")
    return
  end
  local tList = data_getStuffsForLifeItem(self.m_ShowingItemType)
  local tempDict = {}
  for tType, tNum in pairs(tList) do
    local curNum = g_LocalPlayer:GetItemNum(tType)
    if tNum > curNum then
      tempDict[tType] = tNum - curNum
    end
  end
  local needMoney = 0
  for tType, tNum in pairs(tempDict) do
    local addPrice = 0
    if data_Shop_NPC_Zawu[tType] ~= nil then
      local price = data_Shop_NPC_Zawu[tType].price
      addPrice = price * tNum
    elseif data_Shop_NPC_Yaopin[tType] ~= nil then
      local price = data_Shop_NPC_Yaopin[tType].price
      addPrice = price * tNum
    end
    needMoney = needMoney + addPrice
  end
  if needMoney > 0 then
    local warningText = string.format("是否使用#<IR1>#%d换取？", needMoney)
    local tempPop = CPopWarning.new({
      title = "条件不足",
      text = warningText,
      confirmFunc = function()
        netsend.netlifeskill.lifeSkillMakeItem(self.m_SelectBigType * 100 + self.m_SelectSmallType)
      end,
      confirmText = "确定",
      cancelText = "取消",
      align = CRichText_AlignType_Center,
      lackList = tempDict
    })
    tempPop:ShowCloseBtn(false)
  else
    netsend.netlifeskill.lifeSkillMakeItem(self.m_SelectBigType * 100 + self.m_SelectSmallType)
  end
end
function CMakeLifeItemView:OnBtn_Close(obj, t)
  self:CloseSelf()
end
function CMakeLifeItemView:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_HouliUpdate then
    self:SetCreateHuoli()
  elseif msgSID == MsgID_LifeSkillUpdate then
    self:CloseSelf()
  elseif msgSID == MsgID_ItemInfo_AddItem then
    self:SetCreateStuffs()
  elseif msgSID == MsgID_ItemInfo_DelItem then
    self:SetCreateStuffs()
  elseif msgSID == MsgID_ItemInfo_ChangeItemNum then
    self:SetCreateStuffs()
  elseif msgSID == MsgID_ItemSource_Jump then
    self:CloseStuffDetail()
    local d = arg[1][1]
    for _, t in pairs(Item_Source_MoveMapList) do
      if d == t then
        self:CloseSelf()
        break
      end
    end
  end
end
function CMakeLifeItemView:Clear()
  self:CloseStuffDetail()
  if self.m_CallBack then
    self.m_CallBack()
    self.m_CallBack = nil
  end
end
