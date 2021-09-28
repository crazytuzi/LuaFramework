RechargeViewItem = class("RechargeViewItem", CcsSubView)
function RechargeViewItem:ctor(para)
  self.m_num = para.num
  self.m_Type = para.resType
  RechargeViewItem.super.ctor(self, "views/recharge_item.json")
  self:getNode("txt_name"):setText(string.format("充值%d元宝", self.m_num))
  if self.m_Type == RESTYPE_COIN then
    local name = data_Shop_BuyCoin[self.m_num].name or ""
    self:getNode("txt_name"):setText(name)
  elseif self.m_Type == RESTYPE_SILVER then
    local name = data_Shop_BuySilver[self.m_num].name or ""
    self:getNode("txt_name"):setText(name)
  elseif self.m_Type == RESTYPE_GOLD then
    local name = data_Shop_ChongZhi[self.m_num].showName or ""
    self:getNode("txt_name"):setText(name)
  end
  if self.m_Type == RESTYPE_GOLD then
    local des = data_Shop_ChongZhi[self.m_num].des
    if des ~= nil then
      if self.m_num == 1 or self.m_num == 101 then
        local endTimePoint = activity.event:getYueKaEndTime()
        if endTimePoint ~= 0 then
          local restTime = endTimePoint - g_DataMgr:getServerTime()
          if restTime > 0 then
            local dayNum = math.ceil(restTime / 3600 / 24)
            if dayNum > 0 then
              des = string.format("月卡生效中,剩余%d天", dayNum)
            end
          end
        end
      end
      tempDesTxt = ui.newTTFLabel({
        text = des,
        font = KANG_TTF_FONT,
        size = 18,
        color = ccc3(77, 48, 14)
      })
      local x, _ = self:getNode("txt_name"):getPosition()
      local _, y = self:getNode("itempos"):getPosition()
      self:addNode(tempDesTxt, 1)
      tempDesTxt:setAnchorPoint(ccp(0, 0))
      tempDesTxt:setPosition(ccp(x - 5, y))
    end
  end
  if self.m_Type == RESTYPE_COIN then
    local gold = data_Shop_BuyCoin[self.m_num].gold or 0
    self:getNode("text_price"):setText(string.format("%d", gold))
    self:setPriceIcon()
    self:setPriceColor()
  elseif self.m_Type == RESTYPE_SILVER then
    local gold = data_Shop_BuySilver[self.m_num].gold or 0
    self:getNode("text_price"):setText(string.format("%d", gold))
    self:setPriceIcon()
    self:setPriceColor()
  elseif self.m_Type == RESTYPE_GOLD then
    local rmb = data_Shop_ChongZhi[self.m_num].rmb or 0
    self:getNode("text_price"):setText(string.format("￥%d", rmb))
  end
  self:getNode("itempos"):setTouchEnabled(false)
  self:getNode("resicon"):setTouchEnabled(false)
  local pos = self:getNode("itempos")
  local x, y = pos:getPosition()
  local size = pos:getContentSize()
  local tempPath = data_Shop_ChongZhi[self.m_num].respath or "xiyou/pic/pic_buygold.png"
  if self.m_Type == RESTYPE_GOLD and 0 < data_Shop_ChongZhi[self.m_num].pettype then
    local petId = data_Shop_ChongZhi[self.m_num].pettype
    tempPath = data_getHeadPathByShape(data_getRoleShape(petId))
    local petBg = display.newSprite("views/mainviews/pic_headiconbg.png")
    self:addNode(petBg, 1)
    petBg:setPosition(ccp(x + size.width / 2 - HEAD_OFF_X, y + size.height / 2 - HEAD_OFF_Y))
  elseif self.m_Type == RESTYPE_SILVER then
    tempPath = data_Shop_BuySilver[self.m_num].respath or "xiyou/item/item30019.png"
  elseif self.m_Type == RESTYPE_COIN then
    tempPath = data_Shop_BuyCoin[self.m_num].respath or "xiyou/item/item30018.png"
  end
  local tempPic = display.newSprite(tempPath)
  self:addNode(tempPic, 1)
  tempPic:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  local size = self:getNode("bg"):getContentSize()
  self.m_IsTouchMoved = false
  self.m_TouchNode = clickwidget.create(size.width, size.height, 0, 0, function(touchNode, event)
    self:OnTouchEvent(event)
  end)
  self:addChild(self.m_TouchNode)
  self:setSellOut()
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_ChongZhi)
end
function RechargeViewItem:OnBtn_Buy()
  if self.m_Type == RESTYPE_GOLD then
    if g_LocalPlayer and g_LocalPlayer:JudgeCanBuyGift(self.m_num) == false then
      ShowNotifyTips("商品仅限购一次")
      return
    end
    do
      local rmb = data_Shop_ChongZhi[self.m_num].rmb
      local numLimit = data_Shop_ChongZhi[self.m_num].numLimit
      if rmb ~= nil and rmb > 0 then
        local text = string.format("充值1元=1VIP积分，VIP积分达到一定积分时可激活GM权限\n假设玩家已经开通GM1，在充值10元GM1项目就会增加10vip经验\n\nVIP21=10元(激活GM1特权)\n\nVIP22=100元(激活GM2特权)\n\nVIP23=300元(激活GM3特权)\n\nVIP24=600元(激活GM4特权)\n\nVIP25=800元(激活GM5特权)\n\nVIP26=1000元(激活GM6特权)", numLimit)
        if self.m_num == 12 or self.m_num == 118 then
          text = "为保证服务能长久运营更新，喜欢此游戏朋友，欢迎赞助我们，共创经典回合，宝典赞助分为三个档10,100,1000，赞助成功之后宝典自动到账，出现到账延迟问题，请联系客服解决"
        elseif self.m_num == 13 or self.m_num == 119 then
          text = "为保证服务能长久运营更新，喜欢此游戏朋友，欢迎赞助我们，共创经典回合，宝典赞助分为三个档10,100,1000，赞助成功之后宝典自动到账，出现到账延迟问题，请联系客服解决"
        elseif self.m_num == 14 or self.m_num == 120 then
          text = "为保证服务能长久运营更新，喜欢此游戏朋友，欢迎赞助我们，共创经典回合，宝典赞助分为三个档10,100,1000，赞助成功之后宝典自动到账，出现到账延迟问题，请联系客服解决"
        end
        if numLimit > 0 then
          local tempView = CPopWarning.new({
            title = "开通GM温馨提示",
            text = text,
            cancelFunc = nil,
            confirmFunc = function()
              g_ChannelMgr:startPay(rmb, self.m_num)
            end,
            confirmText = "下一步",
            align = CRichText_AlignType_Left
          })
          tempView:ShowCloseBtn(false)
        else
          g_ChannelMgr:startPay(rmb, self.m_num)
        end
      end
    end
  elseif self.m_Type == RESTYPE_SILVER then
    local needGold = data_Shop_BuySilver[self.m_num].gold
    local buySilver = data_Shop_BuySilver[self.m_num].silver
    if needGold == nil then
      return
    end
    local curGold = g_LocalPlayer:getGold()
    if needGold <= curGold then
      local dlg = CPopWarning.new({
        title = "提示",
        text = string.format("确定花费%d#<IR2>#\n购买%d#<IR7>#?", needGold, buySilver),
        confirmFunc = function()
          netsend.netshop.BuySilverUseGold(self.m_num)
        end,
        cancelText = "取消",
        confirmText = "确定"
      })
      dlg:ShowCloseBtn(false)
    else
      ShowNotifyTips("元宝不足")
    end
  elseif self.m_Type == RESTYPE_COIN then
    local needGold = data_Shop_BuyCoin[self.m_num].gold
    local buyCoin = data_Shop_BuyCoin[self.m_num].coin
    if needGold == nil then
      return
    end
    local curGold = g_LocalPlayer:getGold()
    if needGold <= curGold then
      local dlg = CPopWarning.new({
        title = "提示",
        text = string.format("确定花费%d#<IR2>#\n购买%d#<IR1>#?", needGold, buyCoin),
        confirmFunc = function()
          netsend.netshop.BuyCoinUseGold(self.m_num)
        end,
        cancelText = "取消",
        confirmText = "确定"
      })
      dlg:ShowCloseBtn(false)
    else
      ShowNotifyTips("元宝不足")
    end
  end
end
function RechargeViewItem:setPriceIcon()
  if self.m_Type == RESTYPE_GOLD then
    return
  end
  local x, y = self:getNode("resicon"):getPosition()
  local z = self:getNode("resicon"):getZOrder()
  local size = self:getNode("resicon"):getSize()
  local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_GOLD))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setScale(size.width / tempImg:getContentSize().width)
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:addNode(tempImg, z)
end
function RechargeViewItem:setPriceColor()
  local curGold = g_LocalPlayer:getGold()
  if self.m_Type == RESTYPE_SILVER then
    local needGold = data_Shop_BuySilver[self.m_num].gold
    if curGold >= needGold then
      self:getNode("text_price"):setColor(ccc3(255, 255, 255))
    else
      self:getNode("text_price"):setColor(ccc3(255, 0, 0))
    end
  elseif self.m_Type == RESTYPE_COIN then
    local needGold = data_Shop_BuyCoin[self.m_num].gold
    if curGold >= needGold then
      self:getNode("text_price"):setColor(ccc3(255, 255, 255))
    else
      self:getNode("text_price"):setColor(ccc3(255, 0, 0))
    end
  end
end
function RechargeViewItem:setSellOut()
  local flag = false
  if self.m_Type == RESTYPE_GOLD and g_LocalPlayer then
    local temaiFlag = false
    local sellOutFlag = true
    for _, tmNum in pairs(WEEKLY_SHOP_ITEM_LIST) do
      if self.m_num == tmNum then
        temaiFlag = true
        break
      end
    end
    for _, num in pairs(g_LocalPlayer:getCanShowRechargeItemList()) do
      if self.m_num == num then
        sellOutFlag = false
        break
      end
    end
    if temaiFlag == true and sellOutFlag == true then
      flag = true
    end
  end
  if flag == true then
    if self.m_SellOutImg == nil then
      local tempImg = display.newSprite("views/pic/pic_sellout.png")
      local size = self:getContentSize()
      tempImg:setAnchorPoint(ccp(0.5, 0.5))
      tempImg:setPosition(ccp(size.width / 2, size.height / 2))
      self:addNode(tempImg, 99)
      self.m_SellOutImg = tempImg
    end
  elseif self.m_SellOutImg then
    self.m_SellOutImg:removeFromParent()
    self.m_SellOutImg = nil
  end
end
function RechargeViewItem:OnTouchEvent(event)
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
      self:OnBtn_Buy()
      bg:setColor(ccc3(255, 255, 255))
      soundManager.playSound("xiyou/sound/clickbutton_2.wav")
    end
  end
end
function RechargeViewItem:Clear()
end
function RechargeViewItem:OnMessage(msgSID, ...)
  if msgSID == MsgID_MoneyUpdate then
    self:setPriceColor()
  elseif msgSID == MsgID_ChongZhi_ItemListUpdate then
    self:setSellOut()
  end
end
