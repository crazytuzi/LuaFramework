MARKET_SCROLL_ITEM_STATE_CANSELL = 1
MARKET_SCROLL_ITEM_STATE_OTIME = 2
CMarketGoodsItem = class("CMarketGoodsItem", CcsSubView)
function CMarketGoodsItem:ctor(goodId, viewTag)
  CMarketGoodsItem.super.ctor(self, "views/market_goods.json")
  self.m_ViewTag = viewTag
  self.m_goodID = goodId
  self.bg_image = self:getNode("bg_image")
  self.goods_icon = self:getNode("goods_icon")
  self.goods_icon:setTouchEnabled(false)
  self.lable_num = self:getNode("lable_num")
  self.resbg = self:getNode("resbg")
  self.txt_price = self:getNode("txt_price")
  self.txt_goodsname = self:getNode("txt_goodsname")
  self.pic_soldout = self:getNode("pic_soldout")
  self.pic_timeout = self:getNode("pic_timeout")
  self.pic_tixian = self:getNode("pic_tixian")
  local zOrder = self.bg_image:getZOrder()
  self.pic_soldout:setZOrder(zOrder + 10)
  self.pic_timeout:setZOrder(zOrder + 10)
  self.pic_tixian:setZOrder(zOrder + 10)
  self.lable_num:setZOrder(zOrder + 9)
  self:getUINode():setNodeEventEnabled(true)
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_Stall)
  self:setCoinIcon()
  self:UpdateData()
  self:setTouchEnabled(false)
  self.m_IsTouchMoved = false
end
function CMarketGoodsItem:UpdateData()
  local goodId = self.m_goodID
  if self.goodicon_bg then
    self.goodicon_bg:removeFromParent()
    self.goodicon_bg = nil
  end
  local param = g_BaitanDataMgr:GetOneGoodSellingData(goodId)
  local itemObj = g_BaitanDataMgr:GetOneGood(goodId)
  if param == nil or itemObj == nil then
    print("g_BaitanDataMgr里面没有goodID", goodId)
    return
  end
  local itemDataId = itemObj:getTypeId()
  if param.ispet ~= 1 then
    self.goodicon_bg = createClickItem({
      itemID = itemDataId,
      autoSize = nil,
      num = 0,
      LongPressTime = 0,
      clickListener = nil,
      LongPressListener = nil,
      LongPressEndListner = nil,
      clickDel = nil,
      noBgFlag = false
    })
    self.goodicon_bg:setTouchEnabled(false)
  else
    self.goodicon_bg = createClickPetHead({
      roleTypeId = itemDataId,
      autoSize = nil,
      clickListener = nil,
      noBgFlag = nil,
      offx = nil,
      offy = nil,
      clickDel = nil,
      LongPressTime = 0.01,
      LongPressListener = nil,
      LongPressEndListner = nil
    })
    self.goodicon_bg:setTouchEnabled(false)
  end
  local x, y = self.goods_icon:getPosition()
  local csize = self.bg_image:getContentSize()
  local iconbgsize = self.goodicon_bg:getContentSize()
  self.goodicon_bg:setPosition(ccp(x, (csize.height - iconbgsize.height) / 2))
  self:addChild(self.goodicon_bg)
  local name = ""
  if param.ispet ~= 1 then
    name = data_getItemName(itemDataId)
  else
    name = data_getPetName(itemDataId)
  end
  self.txt_goodsname:setText(name)
  if data_Stall[itemDataId] == nil then
    print("======================没有这个物品", itemDataId)
    return
  end
  local ShelvesNum = data_Stall[itemDataId].LimitPerSoldin
  if ShelvesNum == nil or ShelvesNum == 1 or param.num == nil or param.num == 0 then
    self.lable_num:setVisible(false)
  else
    self.lable_num:setVisible(true)
    self.lable_num:setText(param.num)
  end
  local soutFlag = false
  local toutFlag = false
  local tixianFlag = false
  if self.m_ViewTag == MARKET_SCROLL_SELL_VIEW then
    if param.num > 0 and 0 < param.son then
      tixianFlag = true
    end
  else
    tixianFlag = false
  end
  if param.num == nil or param.num <= 0 then
    soutFlag = true
  end
  if param.s == MARKET_SCROLL_ITEM_STATE_OTIME then
    toutFlag = true
  end
  if soutFlag == true then
    toutFlag = false
  end
  if tixianFlag == true then
    toutFlag = false
  end
  self.pic_soldout:setVisible(soutFlag)
  self.pic_timeout:setVisible(toutFlag)
  self.pic_tixian:setVisible(tixianFlag)
  if self.m_ViewTag == MARKET_SCROLL_SELL_VIEW then
    if soutFlag == true then
      self.txt_price:setText(param.p * param.son)
    elseif tixianFlag == true then
      self.txt_price:setText(param.p * param.son)
    elseif toutFlag == true then
      self.txt_price:setText(param.p * param.num)
    else
      self.txt_price:setText(param.p * param.num)
    end
  else
    self.txt_price:setText(param.p)
  end
  local mneedflag = false
  if GetItemTypeByItemTypeId(itemDataId) == ITEM_LARGE_TYPE_LIFEITEM then
    local sortItemid = g_MissionMgr:getAllShortageObjs()
    if sortItemid ~= nil and type(sortItemid) == "table" then
      for k, v in pairs(sortItemid) do
        if GetItemTypeByItemTypeId(v) == ITEM_LARGE_TYPE_LIFEITEM and self:IsSameKindLifeObj(v) == true then
          mneedflag = true
        end
      end
    end
  else
    mneedflag = g_MissionMgr:isObjShortage(itemObj:getTypeId())
  end
  print("  MIssion Need ?    ", mneedflag)
  if self.needimg == nil then
    self.needimg = display.newSprite("views/pic/pic_taskneeditem.png")
    local x, y = self.bg_image:getPosition()
    local size = self.bg_image:getContentSize()
    self.needimg:setAnchorPoint(ccp(0, 1))
    self.needimg:setPosition(ccp(x - size.width / 2, y + size.height / 2))
    self:addNode(self.needimg, 100)
  end
  self.needimg:setVisible(mneedflag and not soutFlag and not toutFlag)
end
function CMarketGoodsItem:getItemID()
  return self.m_goodID
end
function CMarketGoodsItem:setCoinIcon(...)
  local x, y = self:getNode("resicon"):getPosition()
  local z = self:getNode("resicon"):getZOrder()
  local size = self:getNode("resicon"):getSize()
  self:getNode("resicon"):setEnabled(false)
  self.goldIcon = display.newSprite(data_getResPathByResID(RESTYPE_COIN))
  self.goldIcon:setAnchorPoint(ccp(0.5, 0.5))
  self.goldIcon:setScale(size.width / self.goldIcon:getContentSize().width + 0.1)
  self.goldIcon:setPosition(ccp(x + size.width / 2, y + size.height / 2 + 2))
  self:addNode(self.goldIcon, z)
end
function CMarketGoodsItem:setTouchState(flag)
  if flag then
    self.bg_image:setColor(ccc3(200, 200, 200))
  else
    self.bg_image:setColor(ccc3(255, 255, 255))
  end
end
function CMarketGoodsItem:SetItemChoosed(flag)
  local bg = self:getNode("bg_image")
  local size = self:getNode("bg_image"):getContentSize()
  if flag then
    if bg._SelectObjList then
      return
    else
      local bgSize = bg:getSize()
      local temp1 = display.newSprite("views/pic/pic_selectcorner.png")
      local temp2 = display.newSprite("views/pic/pic_selectcorner.png")
      local temp3 = display.newSprite("views/pic/pic_selectcorner.png")
      local temp4 = display.newSprite("views/pic/pic_selectcorner.png")
      local del = 5
      bg:addNode(temp1)
      temp1:setPosition(ccp(0 - del - size.width / 2, 0 - del - size.height / 2))
      temp1:setAnchorPoint(ccp(0, 1))
      temp1:setScaleY(-1)
      bg:addNode(temp2)
      temp2:setPosition(ccp(0 - del - size.width / 2, bgSize.height + del - size.height / 2))
      temp2:setAnchorPoint(ccp(0, 1))
      bg:addNode(temp3)
      temp3:setPosition(ccp(bgSize.width + del - size.width / 2, 0 - del - size.height / 2))
      temp3:setAnchorPoint(ccp(0, 1))
      temp3:setScaleX(-1)
      temp3:setScaleY(-1)
      bg:addNode(temp4)
      temp4:setPosition(ccp(bgSize.width + del - size.width / 2, bgSize.height + del - size.height / 2))
      temp4:setAnchorPoint(ccp(0, 1))
      temp4:setScaleX(-1)
      bg._SelectObjList = {
        temp1,
        temp2,
        temp3,
        temp4
      }
    end
  elseif bg._SelectObjList then
    for _, obj in pairs(bg._SelectObjList) do
      obj:removeFromParent()
    end
    bg._SelectObjList = nil
  end
end
function CMarketGoodsItem:OnClickIcon(touchObj, event)
  if event == TOUCH_EVENT_BEGAN then
    touchObj:setScale(1.2)
  elseif event == TOUCH_EVENT_ENDED or event == TOUCH_EVENT_CANCELED then
    touchObj:setScale(1)
  end
end
function CMarketGoodsItem:doProcess(obj)
  if obj == nil then
    return
  end
  obj:setOpacity(0)
  obj:runAction(CCFadeIn:create(0.8))
end
function CMarketGoodsItem:setFadeIn()
  self:doProcess(self.bg_image)
  self:doProcess(self.goods_icon)
  self:doProcess(self.resbg)
  self:doProcess(self.txt_price)
  self:doProcess(self.pic_soldout)
  self:doProcess(self.txt_goodsname)
  self:doProcess(self.pic_timeout)
  self:doProcess(self.goldIcon)
  self:doProcess(self.goodicon)
  self:doProcess(self.lable_num)
  self:doProcess(self.pic_tixian)
  self:doProcess(self.needimg)
  if self.goodicon_bg then
    self:doProcess(self.goodicon_bg._Icon)
    self:doProcess(self.goodicon_bg._BgIcon)
  end
end
function CMarketGoodsItem:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_Stall_UpdateOneGood then
    if arg[1].goodId == self.m_goodID and self.__isExist then
      self:UpdateData()
    end
  elseif msgSID == MsgID_Stall_UpdateOneKindGoods then
    local itemdata_1 = g_BaitanDataMgr:GetOneGood(self.m_goodID)
    local isupdate = false
    if itemdata_1 ~= nil then
      if GetItemTypeByItemTypeId(arg[1].goodId) == ITEM_LARGE_TYPE_LIFEITEM then
        isupdate = self:IsSameKindLifeObj(arg[1].goodId)
      else
        print(" lalala ", self.m_goodID == arg[1].goodId, self.m_goodID, arg[1].goodId)
        isupdate = itemdata_1:getTypeId() == arg[1].goodId
      end
    end
    if isupdate == true and self.__isExist then
      self:UpdateData()
    end
  end
end
function CMarketGoodsItem:IsSameKindLifeObj(objTypeId)
  local itemdata_1 = g_BaitanDataMgr:GetOneGood(self.m_goodID)
  if itemdata_1 == nil then
    return false
  end
  local locobjid = itemdata_1:getTypeId()
  local itemtb_1 = GetItemDataByItemTypeId(locobjid)
  local itemtb_2 = GetItemDataByItemTypeId(objTypeId)
  if itemtb_1 ~= nil and itemtb_1[locobjid] ~= nil and itemtb_2 ~= nil and itemtb_2[objTypeId] ~= nil then
    local LifeItemType = GetLifeSkillItemType(objTypeId)
    local showBigType = false
    if LifeItemType == LIFESKILL_PRODUCE_RUNE then
      if itemtb_2[objTypeId].MainCategoryId == 5 then
        showBigType = false
      elseif itemtb_2[objTypeId].MainCategoryId == 1 or itemtb_2[objTypeId].MainCategoryId == 2 or itemtb_2[objTypeId].MainCategoryId == 3 or itemtb_2[objTypeId].MainCategoryId == 4 or itemtb_2[objTypeId].MainCategoryId == 6 then
        showBigType = true
      end
    elseif LifeItemType == LIFESKILL_PRODUCE_FOOD then
      if itemtb_2[objTypeId].MainCategoryId == 2 or itemtb_2[objTypeId].MainCategoryId == 3 or itemtb_2[objTypeId].MainCategoryId == 5 then
        showBigType = true
      elseif itemtb_2[objTypeId].MainCategoryId == 1 then
        showBigType = false
      end
    else
      showBigType = false
    end
    local tempNum_1 = math.floor(locobjid / 1000)
    local tempNum_2 = math.floor(objTypeId / 1000)
    if showBigType then
      return tempNum_1 == tempNum_2 and itemtb_1[locobjid].MainCategoryId == itemtb_2[objTypeId].MainCategoryId
    end
    return tempNum_1 == tempNum_2 and itemtb_1[locobjid].MainCategoryId == itemtb_2[objTypeId].MainCategoryId and itemtb_1[locobjid].MinorCategoryId == itemtb_2[objTypeId].MinorCategoryId
  end
  return false
end
function CMarketGoodsItem:Clear()
end
