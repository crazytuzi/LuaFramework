local ResShortageView = class("ResShortageView", CcsSubView)
ResShortageView.__viewIns = nil
function ResShortageView:ctor(id, title, shortageObj, needGold, btnName)
  ResShortageView.super.ctor(self, "views/res_shortage_get.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  ResShortageView.__viewIns = self
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_OK),
      variName = "btn_close"
    },
    btn_get = {
      listener = handler(self, self.OnBtn_GET),
      variName = "btn_get"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.layer_objPos = self:getNode("layer_objPos")
  self.pic_CoinBg = self:getNode("pic_CoinBg")
  self.btn_get = self:getNode("btn_get")
  local x1, y1 = self.layer_objPos:getPosition()
  local x2, y2 = self.pic_CoinBg:getPosition()
  self.m_CoinPos = {
    x2,
    y2,
    y1
  }
  self.m_Objs = {}
  self.m_NeedGold = needGold or 0
  self.m_NeedSilverIn = 0
  self.m_NeedSilverForObjs = 0
  self.m_SilverNumIns = nil
  self.m_UpdateTime = 5
  self:updateData(id, title, shortageObj, needGold, btnName)
  getCurSceneView():addSubView({
    subView = self,
    zOrder = MainUISceneZOrder.menuView
  })
  g_TouchEvent:setCanTouch(false)
end
function ResShortageView:frameUpdate(dt)
end
function ResShortageView:OnBtn_OK(obj, t)
  self:CloseSelf()
  netsend.netnotify.confirmViewToServer(self.m_ServerId, 0)
end
function ResShortageView:OnBtn_GET(obj, t)
  local myGold = g_LocalPlayer:getGold()
  if myGold < self.m_NeedGold then
    ShowNotifyTips("元宝不足")
    self:HideSelf()
    ShowRechargeView({
      callBack = function()
        self:ShowSelf()
      end
    })
  else
    self:CloseSelf()
    netsend.netnotify.confirmViewToServer(self.m_ServerId, 1)
  end
end
function ResShortageView:flushCoinPos()
  if table_is_empty(self.m_Objs) == true then
    local x, y = unpack(self.m_CoinPos, 1, 2)
    y = self.m_CoinPos[3]
    self.pic_CoinBg:setPosition(ccp(x, y))
  end
end
function ResShortageView:createCoinOrSilverNum(resType, needNum)
  self.pic_CoinBg:setEnabled(true)
  if self.pic_CoinBg.__icon then
    self.pic_CoinBg.__icon:removeSelf()
  end
  if self.pic_CoinBg.__coinNumTxt then
    self.pic_CoinBg.__coinNumTxt:removeSelf()
  end
  local icon = display.newSprite(data_getResPathByResIDForRichText(resType))
  local iconSize = icon:getContentSize()
  self.pic_CoinBg:addNode(icon)
  self.pic_CoinBg.__icon = icon
  local bgSize = self.pic_CoinBg:getSize()
  local iconSize = icon:getContentSize()
  local iconScale = bgSize.height / iconSize.height
  icon:setScale(iconScale)
  icon:setPosition(ccp(-bgSize.width / 2, 0))
  local coinNumTxt = ui.newTTFLabel({
    text = tostring(checkint(needNum)),
    font = KANG_TTF_FONT,
    size = 20,
    color = ccc3(255, 0, 0)
  })
  coinNumTxt:setAnchorPoint(ccp(0, 0.5))
  self.pic_CoinBg:addNode(coinNumTxt)
  local x = -bgSize.width / 2 + iconSize.width * iconScale / 2 + 6
  coinNumTxt:setPosition(ccp(x, 0))
  self.pic_CoinBg.__coinNumTxt = coinNumTxt
  self:flushCoinPos()
  return coinNumTxt
end
function ResShortageView:updateData(id, title, shortageObj, needGold, btnName)
  self.m_ServerId = id
  title = title or "条件不足"
  self:getNode("txt_title"):setText(title)
  self.layer_objPos:setEnabled(false)
  local objShortage = shortageObj.objs
  if objShortage then
    local itemList = {}
    local totalWidth = 0
    local oldObjs = self.m_Objs
    self.m_Objs = {}
    for objId, needNum in pairs(objShortage) do
      local totalNum = g_LocalPlayer:GetItemNum(objId) or 0
      local item = oldObjs[objId]
      if oldObjs[objId] == nil then
        item = createClickItem({
          itemID = objId,
          autoSize = nil,
          num = 0,
          LongPressTime = 0.01,
          clickListener = function()
          end,
          LongPressListener = nil,
          LongPressEndListner = nil,
          clickDel = nil,
          noBgFlag = nil
        })
        self.layer_objPos:getParent():addChild(item, self.layer_objPos:getZOrder() + 1)
      end
      self.m_Objs[objId] = item
      local size = item:getSize()
      if item._numLabel == nil then
        local numLabel = CCLabelTTF:create(string.format("%s", needNum), KANG_TTF_FONT, 23)
        numLabel:setAnchorPoint(ccp(1, 0))
        numLabel:setPosition(ccp(size.width - 5, 5))
        numLabel:setColor(ccc3(255, 0, 0))
        item:addNode(numLabel)
        item._numLabel = numLabel
      else
        item._numLabel:setString(string.format("%s", needNum))
      end
      totalWidth = totalWidth + size.width
      itemList[#itemList + 1] = item
    end
    for k, v in pairs(oldObjs) do
      if self.m_Objs[k] == nil then
        v:removeSelf()
      end
    end
    oldObjs = {}
    if #itemList > 0 then
      local posLayerSize = self.layer_objPos:getSize()
      local x1, y1 = self.layer_objPos:getPosition()
      local x = x1 + (posLayerSize.width - totalWidth) / 2
      local y = y1
      for i, item in ipairs(itemList) do
        local size = item:getSize()
        item:setPosition(ccp(x, y))
        x = x + size.width
      end
    end
  end
  self.m_NeedSilverIn = shortageObj.silver or 0
  local coin = shortageObj.coin
  if self.m_NeedSilverIn ~= 0 then
    self.m_SilverNumIns = self:createCoinOrSilverNum(RESTYPE_SILVER, self.m_NeedSilverIn)
  elseif coin then
    self.m_CoinNeed = coin
    self:createCoinOrSilverNum(RESTYPE_COIN, coin)
  else
    self.pic_CoinBg:setEnabled(false)
  end
  self.m_NeedGold = needGold or 0
  local getBtnSize = self.btn_get:getSize()
  if self.m_NeedGoldTxt == nil then
    self.m_NeedGoldTxt = RichText.new({
      width = getBtnSize.width,
      verticalSpace = 0,
      color = ccc3(0, 0, 0),
      font = KANG_TTF_FONT,
      fontSize = 23,
      align = CRichText_AlignType_Center
    })
    self.btn_get:addChild(self.m_NeedGoldTxt, 10)
  end
  self.m_NeedGoldTxt:clearAll()
  self.m_NeedGoldTxt:addRichText(btnName)
  local size = self.m_NeedGoldTxt:getRichTextSize()
  local s = 1
  local maxw = 150
  if maxw < size.width then
    s = maxw / size.width
    self.m_NeedGoldTxt:setScale(s)
  end
  self.m_NeedGoldTxt:setPosition(ccp(-size.width * s / 2, -size.height * s / 2))
  self:flushCoinPos()
end
function ResShortageView:HideSelf()
  self:setVisible(false)
  if self._auto_create_opacity_bg_ins then
    self._auto_create_opacity_bg_ins:setVisible(false)
  end
end
function ResShortageView:ShowSelf()
  self:setVisible(true)
  if self._auto_create_opacity_bg_ins then
    self._auto_create_opacity_bg_ins:setVisible(true)
  end
end
function ResShortageView:Clear()
  self.m_Objs = {}
  if ResShortageView.__viewIns == self then
    ResShortageView.__viewIns = nil
  end
  g_TouchEvent:setCanTouch(true)
end
function ShowResShortageView(id, title, shortageObj, needGold, btnName)
  if shortageObj == nil then
    printLog("ERROR", "ShowResShortageView 参数为空")
    return
  end
  if ResShortageView.__viewIns then
    ResShortageView.__viewIns:updateData(id, title, shortageObj, needGold, btnName)
  else
    ResShortageView.new(id, title, shortageObj, needGold, btnName)
  end
end
