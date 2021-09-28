local CGuoQingRewardItem = class("CGuoQingRewardItem", function()
  local widget = Widget:create()
  widget:setAnchorPoint(ccp(0, 0))
  widget:ignoreContentAdaptWithSize(false)
  return widget
end)
function CGuoQingRewardItem:ctor(day, clickFunc)
  self.m_Day = day
  self.m_IsGetReward = false
  self.m_GetSprite = nil
  self.m_ClickFunc = clickFunc
  self.m_canCheckinAni = nil
  self:setNodeEventEnabled(true)
end
function CGuoQingRewardItem:getRewardId()
  return self.m_RewardId
end
function CGuoQingRewardItem:getDaynum()
  return self.m_Day
end
function CGuoQingRewardItem:Init()
  local delY = 10
  local bg = display.newSprite("views/gift/pic_checkin_bg.png")
  bg:setAnchorPoint(ccp(0, 0))
  self:addNode(bg, 0)
  local bgSize = bg:getContentSize()
  self.m_RewardId = self.m_Day
  local data = data_GuoQinQianDao[self.m_RewardId]
  if data == nil then
    return false
  end
  local function func()
    if self.m_ClickFunc then
      self.m_ClickFunc(self)
    end
  end
  local reward = data.reward
  local t, num = unpack(reward, 1, 2)
  local item
  if t == RESTYPE_GOLD then
    item = createClickResItem({
      resID = RESTYPE_GOLD,
      num = 0,
      autoSize = nil,
      clickListener = func,
      clickDel = nil,
      noBgFlag = nil,
      LongPressTime = 0,
      LongPressListener = nil,
      LongPressEndListner = nil
    })
  elseif t == RESTYPE_COIN then
    item = createClickResItem({
      resID = RESTYPE_COIN,
      num = 0,
      autoSize = nil,
      clickListener = func,
      clickDel = nil,
      noBgFlag = nil,
      LongPressTime = 0,
      LongPressListener = nil,
      LongPressEndListner = nil
    })
  elseif t == RESTYPE_SILVER then
    item = createClickResItem({
      resID = RESTYPE_SILVER,
      num = 0,
      autoSize = nil,
      clickListener = func,
      clickDel = nil,
      noBgFlag = nil,
      LongPressTime = 0,
      LongPressListener = nil,
      LongPressEndListner = nil
    })
  elseif t == RESTYPE_EXP then
    item = createClickResItem({
      resID = RESTYPE_EXP,
      num = 0,
      autoSize = nil,
      clickListener = func,
      clickDel = nil,
      noBgFlag = nil,
      LongPressTime = 0,
      LongPressListener = nil,
      LongPressEndListner = nil
    })
  else
    item = createClickItem({
      itemID = t,
      autoSize = nil,
      num = 0,
      LongPressTime = 0,
      clickListener = func,
      LongPressListener = nil,
      LongPressEndListner = nil,
      clickDel = nil,
      noBgFlag = nil
    })
  end
  if item == nil then
    return false
  end
  self:addChild(item, 2)
  self.m_RewardItem = item
  local numBg = display.newSprite("views/common/bg/bgdetail.png")
  self:addNode(numBg, 1)
  local numBgSize = numBg:getContentSize()
  local txtNum = CRichText.new({
    width = numBgSize.width,
    verticalSpace = 1,
    font = KANG_TTF_FONT,
    fontSize = 22,
    color = ccc3(255, 255, 255),
    align = CRichText_AlignType_Center
  })
  numBg:addChild(txtNum)
  txtNum:addRichText(string.format("x%d", num))
  local numDy = -7
  local itemSize = item:getSize()
  local txtSize = txtNum:getRichTextSize()
  local w, h = bgSize.width, bgSize.height
  self:setSize(CCSize(w, h))
  numBg:setPosition(ccp(w / 2, numBgSize.height / 2 + delY))
  self.m_RewardItem:setPosition(ccp((w - itemSize.width) / 2, numBgSize.height + numDy + delY))
  txtNum:setPosition(ccp(0, (numBgSize.height - txtSize.height) / 2))
  self:reflush()
  return true
end
function CGuoQingRewardItem:reflush()
  if gift.guoQingCheckIn:getIsHasAccept(self.m_Day) then
    if self.m_GetSprite == nil then
      self.m_GetSprite = display.newSprite("views/gift/pic_checkin_select.png")
      self.m_GetSprite:setAnchorPoint(ccp(0, 0))
      self:addNode(self.m_GetSprite, 9999)
    else
      self.m_GetSprite:setVisible(true)
    end
  elseif self.m_GetSprite then
    self.m_GetSprite:setVisible(false)
  end
  if gift.guoQingCheckIn:getIsCanAccept(self.m_Day) then
    if self.m_canCheckinAni == nil then
      local eff = CreateSeqAnimation("xiyou/ani/btn_circle.plist", -1)
      self:addNode(eff, 100)
      local size = self.m_RewardItem:getSize()
      local spriteSize = eff:getContentSize()
      local x, y = self.m_RewardItem:getPosition()
      local itemSize = self:getSize()
      eff:setPosition(ccp(itemSize.width / 2, y + size.height / 2))
      self.m_canCheckinAni = eff
    end
    self.m_canCheckinAni:setVisible(true)
  elseif self.m_canCheckinAni then
    self.m_canCheckinAni:setVisible(false)
  end
end
function CGuoQingRewardItem:onCleanup()
  self.m_canCheckinAni = nil
  if self.m_ClickFunc then
    self.m_ClickFunc = nil
  end
end
local CGuoQingRewardConffirm = class("CGuoQingRewardConffirm", CcsSubView)
function CGuoQingRewardConffirm:ctor(rewardId, canAccept, mclickOutSideToClose)
  print("==>>CGuoQingRewardConffirm:", rewardId)
  CGuoQingRewardConffirm.super.ctor(self, "views/guoqing_rewards.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = mclickOutSideToClose
  })
  local btnBatchListener = {
    btn_ok = {
      listener = handler(self, self.OnBtn_OK),
      variName = "btn_ok"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_CanAccept = canAccept
  if self.m_CanAccept then
    self.btn_ok:setTitleText("签到")
  else
    self.btn_ok:setTitleText("好的")
    self:getNode("title"):setText("签到奖励")
    self:getNode("txt_1"):setEnabled(false)
  end
  local data = data_GuoQinQianDao[rewardId]
  if data == nil then
    return
  end
  local reward = data.reward
  local t, num = unpack(reward, 1, 2)
  local item, text
  local name = data_getResNameByResID(t)
  if t == RESTYPE_GOLD then
    item = createClickResItem({
      resID = RESTYPE_GOLD,
      num = 0,
      autoSize = nil,
      clickListener = nil,
      clickDel = nil,
      noBgFlag = nil,
      LongPressTime = nil,
      LongPressListener = nil,
      LongPressEndListner = nil
    })
    text = string.format("#<Y>%s x%d#", name, num)
  elseif t == RESTYPE_COIN then
    item = createClickResItem({
      resID = RESTYPE_COIN,
      num = 0,
      autoSize = nil,
      clickListener = nil,
      clickDel = nil,
      noBgFlag = nil,
      LongPressTime = nil,
      LongPressListener = nil,
      LongPressEndListner = nil
    })
    text = string.format("#<Y>%s x%d#", name, num)
  elseif t == RESTYPE_SILVER then
    item = createClickResItem({
      resID = RESTYPE_SILVER,
      num = 0,
      autoSize = nil,
      clickListener = nil,
      clickDel = nil,
      noBgFlag = nil,
      LongPressTime = nil,
      LongPressListener = nil,
      LongPressEndListner = nil
    })
    text = string.format("#<Y>%s x%d#", name, num)
  elseif t == RESTYPE_EXP then
    item = createClickResItem({
      resID = RESTYPE_EXP,
      num = 0,
      autoSize = nil,
      clickListener = nil,
      clickDel = nil,
      noBgFlag = nil,
      LongPressTime = nil,
      LongPressListener = nil,
      LongPressEndListner = nil
    })
    text = string.format("#<Y>%s x%d#", name, num)
  else
    item = createClickItem({
      itemID = t,
      autoSize = nil,
      num = 0,
      LongPressTime = nil,
      clickListener = nil,
      LongPressListener = nil,
      LongPressEndListner = nil,
      clickDel = nil,
      noBgFlag = nil
    })
    name = data_getItemName(t)
    text = string.format("#<CI:%d>%s x%d#", t, name, num)
  end
  if item == nil then
    return false
  end
  local pBg = self:getNode("pic_recheckinbg1")
  local bg = self:getNode("pic_recheckinbg2")
  local bgx, bgy = bg:getPosition()
  local s = bg:getSize()
  local w = s.width * bg:getScaleX()
  local h = s.height * bg:getScaleY()
  local x = bgx - w / 2 + 50
  local y = bgy
  local itemS = 0.7
  item:setScale(itemS)
  local itemSize = item:getSize()
  pBg:addChild(item, 200)
  item:setPosition(ccp(x, y - itemSize.height * itemS / 2))
  x = x + itemSize.width * itemS + 10
  if name == nil then
    name = "未知物品"
  end
  local nameTxt = CRichText.new({
    width = w - x - 10,
    verticalSpace = 0,
    font = KANG_TTF_FONT,
    fontSize = 25,
    color = ccc3(231, 185, 99),
    align = CRichText_AlignType_Left
  })
  pBg:addChild(nameTxt, 201)
  nameTxt:addRichText(text)
  local s = nameTxt:getRichTextSize()
  nameTxt:setPosition(ccp(x, y - s.height / 2))
  self:getNode("txt_VIP"):setEnabled(false)
end
function CGuoQingRewardConffirm:OnBtn_OK(btnObj, touchType)
  print("CGuoQingRewardConffirm:OnBtn_OK")
  if self.m_CanAccept == true then
    netsend.netgift.reqGetCheckInForGuoQing()
  end
  self:CloseSelf()
end
CGuoQingCheckInView = class("CGuoQingCheckInView", CcsSubView)
function CGuoQingCheckInView:ctor(closeFunc)
  CGuoQingCheckInView.super.ctor(self, "views/gift_guoqingcheckin.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_CloseFunc = closeFunc
  self:getNode("title"):setText("国庆签到")
  self.list_reward = self:getNode("list_reward")
  local everyLineNum = 5
  local deltaY = 0
  local allItems = {}
  local clickFunc = handler(self, self.ClickItem)
  local dayNumList = {}
  for day, _ in pairs(data_GuoQinQianDao) do
    dayNumList[#dayNumList + 1] = day
  end
  table.sort(dayNumList)
  for _, day in ipairs(dayNumList) do
    local item = CGuoQingRewardItem.new(day, clickFunc)
    if item:Init() then
      allItems[#allItems + 1] = item
    end
  end
  self.m_RewardItems = allItems
  if #allItems > 0 then
    local itemSize = allItems[1]:getSize()
    local lineNum = math.floor((#allItems - 1) / everyLineNum) + 1
    local listSize = self.list_reward:getInnerContainerSize()
    local h = lineNum * (itemSize.height + deltaY) + deltaY
    self.list_reward:setInnerContainerSize(CCSize(listSize.width, h))
    local deltaX = (listSize.width - everyLineNum * itemSize.width) / (everyLineNum + 1)
    local curShowLine = -1
    for idx, item in ipairs(allItems) do
      self.list_reward:addChild(item)
      local lineY = math.floor((idx - 1) / everyLineNum)
      local lineX = (idx - 1) % everyLineNum
      local x = deltaX + lineX * (deltaX + itemSize.width)
      local y = h - (deltaY + lineY * (deltaY + itemSize.height))
      item:setPosition(ccp(x, y - itemSize.height))
    end
  end
  self:SetDayText()
  self:SetTipsText()
  self:ListenMessage(MsgID_Gift)
  self.m_DelayTimerHandler = scheduler.performWithDelayGlobal(function()
    allItems = allItems or {}
    for k, v in pairs(allItems) do
      if gift.guoQingCheckIn:getIsCanAccept(v:getDaynum()) then
        self:ClickItem(v, true)
        break
      end
    end
  end, 0.2)
end
function CGuoQingCheckInView:ClickItem(item, isauto)
  print("===> CGuoQingCheckInView:ClickItem:", item, item:getRewardId())
  local clickOutSideFlag = false
  if isauto == true then
    clickOutSideFlag = false
  else
    clickOutSideFlag = true
  end
  if gift.guoQingCheckIn:getIsCanAccept(item:getDaynum()) then
    getCurSceneView():addSubView({
      subView = CGuoQingRewardConffirm.new(item:getRewardId(), true, clickOutSideFlag),
      zOrder = MainUISceneZOrder.menuView
    })
  else
    getCurSceneView():addSubView({
      subView = CGuoQingRewardConffirm.new(item:getRewardId(), false),
      zOrder = MainUISceneZOrder.menuView
    })
  end
end
function CGuoQingCheckInView:SetDayText(item, isauto)
  local day = gift.guoQingCheckIn:GetGuoQingCheckInDay()
  self:getNode("txt_times"):setText(string.format("连续签到:%d次", day))
end
function CGuoQingCheckInView:SetTipsText()
  local x, y = self:getNode("tips_pos"):getPosition()
  local tipsSize = self:getNode("tips_pos"):getContentSize()
  local tipsText = "#<IRP,CTP>签到间断后，奖励从第一天重新计算。#"
  self.m_TipsText = CRichText.new({
    width = tipsSize.width,
    font = KANG_TTF_FONT,
    fontSize = 18,
    color = ccc3(242, 203, 128)
  })
  self:addChild(self.m_TipsText, 10)
  self.m_TipsText:addRichText(tipsText)
  local myTipsSize = self.m_TipsText:getContentSize()
  self.m_TipsText:setPosition(ccp(x, y + tipsSize.height - myTipsSize.height))
end
function CGuoQingCheckInView:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function CGuoQingCheckInView:OnMessage(msgSID, ...)
  if msgSID == MsgID_Gift_GuoQingCheckInUpdate then
    for idx, item in ipairs(self.m_RewardItems) do
      item:reflush()
    end
    self:SetDayText()
  end
end
function CGuoQingCheckInView:Clear()
  self.m_RewardItems = {}
  if self.m_CloseFunc then
    self.m_CloseFunc()
  end
  if self.m_DelayTimerHandler ~= nil then
    scheduler.unscheduleGlobal(self.m_DelayTimerHandler)
    self.m_DelayTimerHandler = nil
  end
end
