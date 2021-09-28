function ShowMarryGiveItemView(taskId)
  if taskId == 100004 or taskId == 110004 then
    getCurSceneView():addSubView({
      subView = CMarryGiveItemView.new(taskId),
      zOrder = MainUISceneZOrder.menuView
    })
  else
    print("任务id不对")
  end
end
CMarryGiveItemView = class("CMarryGiveItemView", CcsSubView)
function CMarryGiveItemView:ctor(taskId)
  CMarryGiveItemView.super.ctor(self, "views/marryneeditem.json", {isAutoCenter = true, opacityBg = 100})
  self.m_JHTaskId = 100004
  self.m_JQTaskId = 110004
  self.m_TaskId = taskId
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_get = {
      listener = handler(self, self.OnBtn_Confirm),
      variName = "btn_get"
    }
  }
  self.m_CallBackFunc = callback
  self:addBatchBtnListener(btnBatchListener)
  self.layer_objPos = self:getNode("layer_objPos")
  self.pic_CoinBg = self:getNode("pic_CoinBg")
  self:getNode("txt_title"):setText("提示")
  self:setItemData()
  self:setCoinData()
  self:setTips()
  self:ListenMessage(MsgID_ItemInfo)
end
function CMarryGiveItemView:setItemData()
  self.layer_objPos:setEnabled(false)
  local itemDataDict = {}
  if self.m_TaskId == self.m_JHTaskId then
    itemDataDict = data_MarryNeedItem.Marry.Item
  elseif self.m_TaskId == self.m_JQTaskId then
    itemDataDict = data_MarryNeedItem.MakeBrother.Item
  end
  print("objS", itemDataDict)
  local itemList = {}
  local totalWidth = 0
  for objId, needNum in pairs(itemDataDict) do
    do
      local totalNum = g_LocalPlayer:GetItemNum(objId) or 0
      local item = createClickItem({
        itemID = objId,
        autoSize = nil,
        num = 0,
        LongPressTime = 0,
        clickListener = function()
          local totalNum = g_LocalPlayer:GetItemNum(objId) or 0
          if totalNum < needNum then
            enterMarket({
              initItemType = MarketShow_InitShow_SilverView,
              initItemType = objId,
              SilverAutoBuy = true
            })
          end
        end,
        LongPressListener = nil,
        LongPressEndListner = nil,
        clickDel = nil,
        noBgFlag = nil
      })
      self.layer_objPos:getParent():addChild(item, self.layer_objPos:getZOrder() + 1)
      local size = item:getSize()
      if item._numLabel == nil then
        local numLabel = CCLabelTTF:create(string.format("%s/%s", totalNum, needNum), KANG_TTF_FONT, 23)
        numLabel:setAnchorPoint(ccp(1, 0))
        numLabel:setPosition(ccp(size.width - 5, 5))
        item:addNode(numLabel)
        item._numLabel = numLabel
      else
        item._numLabel:setString(string.format("%s/%s", totalNum, needNum))
      end
      local color = ccc3(255, 0, 0)
      if needNum <= totalNum then
        color = ccc3(0, 255, 0)
      end
      item._numLabel:setColor(color)
      item._needNum = needNum
      item._needItemType = objId
      totalWidth = totalWidth + size.width
      itemList[#itemList + 1] = item
    end
  end
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
  self.m_ItemList = itemList
end
function CMarryGiveItemView:resetItemNum()
  for _, item in pairs(self.m_ItemList) do
    if item._numLabel ~= nil and item._needNum ~= nil and item._needItemType ~= nil then
      local totalNum = g_LocalPlayer:GetItemNum(item._needItemType) or 0
      local needNum = item._needNum
      item._numLabel:setString(string.format("%s/%s", totalNum, needNum))
      local color = ccc3(255, 0, 0)
      if totalNum >= needNum then
        color = ccc3(0, 255, 0)
      end
      item._numLabel:setColor(color)
    end
  end
end
function CMarryGiveItemView:setCoinData()
  self.pic_CoinBg:setEnabled(true)
  local needNum = 0
  if self.m_TaskId == self.m_JHTaskId then
    needNum = data_MarryNeedItem.Marry.Coin
  elseif self.m_TaskId == self.m_JQTaskId then
    needNum = data_MarryNeedItem.MakeBrother.Coin
  end
  if self.pic_CoinBg.__icon then
    self.pic_CoinBg.__icon:removeSelf()
  end
  local icon = display.newSprite(data_getResPathByResIDForRichText(RESTYPE_COIN))
  local iconSize = icon:getContentSize()
  self.pic_CoinBg:addNode(icon)
  self.pic_CoinBg.__icon = icon
  local bgSize = self.pic_CoinBg:getSize()
  local iconSize = icon:getContentSize()
  local iconScale = bgSize.height / iconSize.height
  icon:setScale(iconScale)
  icon:setPosition(ccp(-bgSize.width / 2, 0))
  local color = ccc3(255, 0, 0)
  if needNum <= g_LocalPlayer:getCoin() then
    color = ccc3(255, 255, 255)
  end
  local coinNumTxt = ui.newTTFLabel({
    text = tostring(checkint(needNum)),
    font = KANG_TTF_FONT,
    size = 20,
    color = color
  })
  coinNumTxt:setAnchorPoint(ccp(0, 0.5))
  self.pic_CoinBg:addNode(coinNumTxt)
  local x = -bgSize.width / 2 + iconSize.width * iconScale / 2 + 6
  coinNumTxt:setPosition(ccp(x, 0))
  self.pic_CoinBg.__coinNumTxt = coinNumTxt
  if needNum <= 0 then
    self.pic_CoinBg:setEnabled(false)
  end
end
function CMarryGiveItemView:setTips()
  local tipsText = ""
  if self.m_TaskId == self.m_JHTaskId then
    tipsText = "#<IRP>#提示:您需要递交以上物品来举办婚宴"
  elseif self.m_TaskId == self.m_JQTaskId then
    tipsText = "#<IRP>#提示:您需要供奉以上物品与伙伴完成结契"
  end
  local x, y = self:getNode("tipsPos"):getPosition()
  local size = self:getNode("tipsPos"):getContentSize()
  if self.m_TipsText == nil then
    self.m_TipsText = CRichText.new({
      width = size.width,
      fontSize = 16,
      color = ccc3(94, 211, 207),
      align = CRichText_AlignType_Center
    })
    self:addChild(self.m_TipsText)
  end
  self.m_TipsText:clearAll()
  self.m_TipsText:addRichText(tipsText)
  local h = self.m_TipsText:getContentSize().height
  self.m_TipsText:setPosition(ccp(x, y + (size.height - h) / 2))
end
function CMarryGiveItemView:OnBtn_Close(...)
  self:CloseSelf()
end
function CMarryGiveItemView:OnBtn_Confirm(...)
  if self.m_TaskId == self.m_JHTaskId then
    netsend.netmarry.marryGiveItem()
    self:CloseSelf()
  elseif self.m_TaskId == self.m_JQTaskId then
    CPopWarning.new({
      title = "提示",
      text = "如果对方放弃结契任务，所交物品将不做退还。请仔细考虑。",
      confirmText = "确定提交",
      confirmFunc = function()
        print("--->> 确定提交")
        netsend.netmarry.FinishedJieTi()
        self:CloseSelf()
      end,
      cancelText = "再想一下",
      cancelFunc = function()
        print("--->> 再想一下")
      end,
      clearFunc = function()
      end
    })
  end
end
function CMarryGiveItemView:OnMessage(msgSID, ...)
  if msgSID == MsgID_ItemInfo_AddItem or msgSID == MsgID_ItemInfo_DelItem or msgSID == MsgID_ItemInfo_ChangeItemNum then
    self:resetItemNum()
  end
end
function CMarryGiveItemView:Clear()
  self.m_ClickHeadListener = nil
end
