function ShowEquipHuiLu()
  local hlList = GetEquipHuiLuList()
  if #hlList <= 0 then
    ShowNotifyTips("背包中没有需要回炉的装备")
    return
  end
  local viewObj = CEquipHuiLu.new()
  getCurSceneView():addSubView({
    subView = viewObj,
    zOrder = MainUISceneZOrder.popView
  })
end
function GetEquipHuiLuList()
  local tempPosList = {}
  for _, typeName in pairs({ITEM_LARGE_TYPE_XIANQI, ITEM_LARGE_TYPE_SENIOREQPT}) do
    local tempItemList = g_LocalPlayer:GetItemTypeList(typeName)
    for _, itemId in pairs(tempItemList) do
      local tempItemIns = g_LocalPlayer:GetOneItem(itemId)
      if tempItemIns ~= nil then
        local mainHero = g_LocalPlayer:getMainHero()
        if mainHero and mainHero:CanZhuangbeiHuiLu(tempItemIns) then
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
CEquipHuiLu = class("CEquipHuiLu", CcsSubView)
function CEquipHuiLu:ctor()
  CEquipHuiLu.super.ctor(self, "views/equit_huilu.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_hl = {
      listener = handler(self, self.OnBtn_HuiLu),
      variName = "btn_hl"
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
function CEquipHuiLu:SetEquipList()
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
    if itemLargeType == ITEM_LARGE_TYPE_SENIOREQPT or itemLargeType == ITEM_LARGE_TYPE_XIANQI then
      local mainHero = g_LocalPlayer:getMainHero()
      if mainHero and mainHero:CanZhuangbeiHuiLu(itemObj) then
        return true
      end
    end
    return false
  end
  self.m_PackageFrame = CPackageFrame.new(ITEM_PACKAGE_TYPE_HERO, handler(self, self.SetItemDetail), nil, param, tempSelectFunc, nil, nil, nil, nil, nil, nil, handler(self, self.SetSelectItem))
  self.m_PackageFrame:setPosition(ccp(x + 5, y + 50))
  p:addChild(self.m_PackageFrame, z)
end
function CEquipHuiLu:SetSelectItem(item)
  if item then
    self.m_PackageFrame:ClearSelectItem()
    item:setSelected(true)
  end
end
function CEquipHuiLu:SelectTheFirstOne()
  local tempPosList = GetEquipHuiLuList()
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
function CEquipHuiLu:SetTipsText()
  local tipsText = "#<IRP>#只能选择转生后主角不能穿上的装备，回炉后原装备会消失并回炉成主角对应的装备。"
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
function CEquipHuiLu:SetItemDetail(itemId)
  self.m_SelectItemId = itemId
  self:SetCostMoney()
  self:SetCostStuff()
  self:SetDetailBoard()
end
function CEquipHuiLu:SetDetailBoard()
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
function CEquipHuiLu:SetCostMoney()
  local itemObj = g_LocalPlayer:GetOneItem(self.m_SelectItemId)
  if itemObj == nil then
    return
  end
  local itemTypeId = itemObj:getTypeId()
  local needMoney = data_getHuiLuItemMoney(itemTypeId)
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
function CEquipHuiLu:SetCostStuff()
  local itemObj = g_LocalPlayer:GetOneItem(self.m_SelectItemId)
  if itemObj == nil then
    return
  end
  local itemTypeId = itemObj:getTypeId()
  local needStuffList = data_getHuiLuItemList(itemTypeId)
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
function CEquipHuiLu:AddOneStuffIcon(itemTypeId, itemNeedNum)
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
function CEquipHuiLu:ShowStuffDetail(obj, t)
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
function CEquipHuiLu:CloseStuffDetail()
  if self.m_PopStuffDetail then
    local tempObj = self.m_PopStuffDetail
    self.m_PopStuffDetail = nil
    tempObj:CloseSelf()
  end
end
function CEquipHuiLu:OnBtn_Close(obj, t)
  self:CloseSelf()
end
function CEquipHuiLu:OnBtn_HuiLu(obj, t)
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
    text = string.format("你确定要回炉#<CI:%d>%s#吗？回炉后将会变更为你当前主角的对应装备部位（属性要求随机）。", itemTypeId, itemName),
    confirmFunc = function()
      netsend.netitem.equipHuiLu(self.m_SelectItemId)
    end,
    confirmText = "确定",
    cancelText = "取消",
    align = CRichText_AlignType_Left
  })
  dlg:ShowCloseBtn(false)
end
function CEquipHuiLu:OnMessage(msgSID, ...)
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
function CEquipHuiLu:Clear()
  self:CloseStuffDetail()
end
