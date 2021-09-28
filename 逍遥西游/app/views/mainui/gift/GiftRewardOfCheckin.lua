local CheckinRewardItem = class("CheckinRewardItem", function()
  local widget = Widget:create()
  widget:setAnchorPoint(ccp(0, 0))
  widget:ignoreContentAdaptWithSize(false)
  return widget
end)
function CheckinRewardItem:ctor(month, day, clickFunc)
  self.m_DayParam = {month, day}
  self.m_IsGetReward = false
  self.m_GetSprite = nil
  self.m_ClickFunc = clickFunc
  self.m_canCheckinAni = nil
  self:setNodeEventEnabled(true)
end
function CheckinRewardItem:getRewardId()
  return self.m_RewardId
end
function CheckinRewardItem:getDaynum()
  return self.m_DayParam[2]
end
function CheckinRewardItem:Init()
  local delY = 10
  local bg = display.newSprite("views/gift/pic_checkin_bg.png")
  bg:setAnchorPoint(ccp(0, 0))
  self:addNode(bg, 0)
  local bgSize = bg:getContentSize()
  self.m_RewardId = 3000 + self.m_DayParam[2]
  local data = data_GiftOfCheckIn[self.m_RewardId]
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
  print("data.vipLv:", data.vipLv)
  if 0 < data.vipLv then
    local p = string.format("xiyou/viplevel/viplevel_%d.png", data.vipLv)
    local vipSp = display.newSprite(p)
    self.m_RewardItem:addNode(vipSp, 9998)
    vipSp:setPosition(ccp(21, 20))
  end
  self:reflush()
  return true
end
function CheckinRewardItem:reflush()
  local status = gift.checkin:getCheckinStatus(self.m_DayParam[2])
  if status == CHECKINSTATUS_HADACCEPTALL or status == CHECKINSTATUS_BASEACCEPTED then
    self.m_IsGetReward = true
  else
    self.m_IsGetReward = false
  end
  print("CheckinRewardItem:reflush:", self.m_DayParam[2], status, self.m_IsGetReward)
  if self.m_IsGetReward then
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
  if gift.checkin:getIsCanAccept(self.m_DayParam[2]) then
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
function CheckinRewardItem:onCleanup()
  self.m_canCheckinAni = nil
end
local CheckinRewardConffirm = class("CheckinRewardConffirm", CcsSubView)
function CheckinRewardConffirm:ctor(rewardId, canAccept, mclickOutSideToClose)
  print("==>>CheckinRewardConffirm:", rewardId)
  CheckinRewardConffirm.super.ctor(self, "views/recheckin_rewards.json", {
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
  local data = data_GiftOfCheckIn[rewardId]
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
  if 0 >= data.vipLv then
    self:getNode("txt_VIP"):setEnabled(false)
  else
    self:getNode("txt_VIP"):setText(string.format("VIP%d可领取双倍奖励", data.vipLv))
  end
end
function CheckinRewardConffirm:OnBtn_OK(btnObj, touchType)
  print("CheckinRewardConffirm:OnBtn_OK")
  if self.m_CanAccept == true then
    netsend.netgift.reqGetCheckinReward()
  end
  self:CloseSelf()
end
local ReCheckin = class("ReCheckin", CcsSubView)
function ReCheckin:ctor(canReCheckinDays)
  print("==>>CheckinRewardConffirm:", rewardId)
  CheckinRewardConffirm.super.ctor(self, "views/recheckin.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_1 = {
      listener = handler(self, self.OnBtn_ReChckInOneTimes),
      variName = "btn_1"
    },
    btn_all = {
      listener = handler(self, self.OnBtn_ReCheckInAll),
      variName = "btn_all"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:createCost(self:getNode("txt_cost1"), 1, self:getNode("bg_check1"))
  if canReCheckinDays == 1 then
    self:getNode("bg_checkall"):setEnabled(false)
  else
    self:getNode("txt_5"):setText(string.format("补签全部(%d天)", canReCheckinDays))
    self:createCost(self:getNode("txt_costall"), canReCheckinDays, self:getNode("bg_checkall"))
  end
end
function ReCheckin:createCost(txtCostNode, costNum, parentNode)
  local cost = RE_CHECKIN_COST * costNum
  txtCostNode:setText(string.format("花费%d", cost))
  local x, y = txtCostNode:getPosition()
  local txtSize = txtCostNode:getSize()
  local size = CCSize(50, 50)
  local s = 0.5
  local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_GOLD))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  tempImg:setScale(s)
  tempImg:setPosition(ccp(x + txtSize.width + s * tempImg:getContentSize().width / 2 + 5, y))
  parentNode:addNode(tempImg, 10)
end
function ReCheckin:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function ReCheckin:OnBtn_ReChckInOneTimes(btnObj, touchType)
  print("==>> OnBtn_ReChckInOneTimes")
  netsend.netgift.reqGetReCheckin(1)
  self:CloseSelf()
end
function ReCheckin:OnBtn_ReCheckInAll(btnObj, touchType)
  print("==>> OnBtn_ReCheckInAll")
  netsend.netgift.reqGetReCheckin(0)
  self:CloseSelf()
end
GiftRewardOfCheckin = class("GiftRewardOfCheckin", CcsSubView)
function GiftRewardOfCheckin:ctor(closeFunc)
  GiftRewardOfCheckin.super.ctor(self, "views/gift_checkin.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_reCheckin = {
      listener = handler(self, self.OnBtn_ReCheckIn),
      variName = "btn_reCheckin"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_CloseFunc = closeFunc
  self.list_reward = self:getNode("list_reward")
  local svrTime = g_DataMgr:getServerTime()
  if svrTime == nil or svrTime <= 0 then
    svrTime = os.time()
  end
  local month = checkint(os.date("%m", svrTime))
  local year = checkint(os.date("%Y", svrTime))
  local day = checkint(os.date("%d", svrTime))
  local days = getDaysWithMonth(month, year)
  print("==>>days:", year, month, day, days)
  local everyLineNum = 5
  local deltaY = 0
  local allItems = {}
  local clickFunc = handler(self, self.ClickItem)
  for i = 1, days do
    local item = CheckinRewardItem.new(month, i, clickFunc)
    if item:Init() then
      allItems[#allItems + 1] = item
    end
  end
  self.m_RewardItems = allItems
  self.m_EveryLineNum = everyLineNum
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
      if curShowLine == -1 and (gift.checkin:getCheckinStatus(item:getDaynum()) == CHECKINSTATUS_CANACCEPT or gift.checkin:getCheckinStatus(item:getDaynum() + 1) == nil) then
        curShowLine = lineY
      end
    end
    if curShowLine > -1 then
      local per = curShowLine / lineNum
      self.m_InitListPercent = per * 100
      self.list_reward:scrollToPercentVertical(per * 100, 0.5, true)
    end
  end
  self.m_DesNode = nil
  self:InitDesShow()
  self:reflushShow()
  self:ListenMessage(MsgID_Gift)
  self.m_DelayTimerHandler = scheduler.performWithDelayGlobal(function()
    allItems = allItems or {}
    for k, v in pairs(allItems) do
      local canAccept, _, _ = gift.checkin:getIsCanAccept(v:getDaynum())
      if canAccept then
        self:ClickItem(v, true)
        break
      end
    end
  end, 0.2)
end
function GiftRewardOfCheckin:reflush()
  self:reflushShow()
  local curShowLine = -1
  local lineNum = checkint((#self.m_RewardItems - 1) / self.m_EveryLineNum) + 1
  for idx, item in ipairs(self.m_RewardItems) do
    item:reflush()
    local itemSize = item:getSize()
    local _, y = item:getPosition()
    local lineY = math.floor((idx - 1) / self.m_EveryLineNum)
    if curShowLine == -1 and (gift.checkin:getCheckinStatus(item:getDaynum()) == CHECKINSTATUS_CANACCEPT or gift.checkin:getCheckinStatus(item:getDaynum() + 1) == nil) then
      curShowLine = lineY
    end
  end
  if curShowLine > -1 then
    local per = curShowLine / lineNum
    self.m_InitListPercent = per * 100
    self.list_reward:scrollToPercentVertical(per * 100, 0.5, true)
  end
end
function GiftRewardOfCheckin:reflushShow()
  self:getNode("times"):setText(string.format("%d", gift.checkin:getCount()))
  self:getNode("txt_reCheckinTimes"):setText(string.format("%d", gift.checkin:getReCount()))
  local svrTime = g_DataMgr:getServerTime()
  if svrTime == nil or svrTime <= 0 then
    svrTime = os.time()
  end
  local month = os.date("%m", svrTime)
  local monthStr = Month_Chinese[checkint(month)]
  self:getNode("txt_monthCheckinTimes"):setText(string.format("%s月签到有奖", monthStr))
end
function GiftRewardOfCheckin:OnMessage(msgSID, ...)
  if msgSID == MsgID_Gift_CheckinRewardUpdate then
    self:reflush()
  end
end
function GiftRewardOfCheckin:ClickItem(item, isauto)
  print("===> GiftRewardOfCheckin:ClickItem:", item, item:getRewardId())
  if isauto == true then
    isauto = false
  else
    isauto = true
  end
  local canAccept, needVipLv, myVipLv = gift.checkin:getIsCanAccept(item:getDaynum())
  if canAccept == true then
    getCurSceneView():addSubView({
      subView = CheckinRewardConffirm.new(item:getRewardId(), true, isauto),
      zOrder = MainUISceneZOrder.menuView
    })
  elseif needVipLv ~= nil then
    local function openChargeView()
      self:CloseSelf()
      print("==>> openChargeView----")
      print("\n\n打开充值界面\n\n")
    end
    CPopWarning.new({
      title = "当日签到奖励已领取",
      text = string.format("升级至VIP%d可领取双倍奖励，是否充值 ", needVipLv),
      confirmFunc = openChargeView
    })
  else
    getCurSceneView():addSubView({
      subView = CheckinRewardConffirm.new(item:getRewardId(), false),
      zOrder = MainUISceneZOrder.menuView
    })
  end
end
function GiftRewardOfCheckin:onEnterEvent()
end
function GiftRewardOfCheckin:Clear()
  self.m_RewardItems = {}
  self.m_DesNode = nil
  if self.m_CloseFunc then
    self.m_CloseFunc()
  end
  if self.m_DelayTimerHandler ~= nil then
    scheduler.unscheduleGlobal(self.m_DelayTimerHandler)
    self.m_DelayTimerHandler = nil
  end
end
function GiftRewardOfCheckin:InitDesShow()
  local btn = self:getNode("btn_checkinDes")
  btn:enableTitleTxtBold()
  btn:setTouchEnabled(true)
  btn:addTouchEventListener(function(touchObj, t)
    if t == TOUCH_EVENT_BEGAN then
      self:ShowRewardDes(true)
    elseif t == TOUCH_EVENT_ENDED or t == TOUCH_EVENT_CANCELED then
      self:ShowRewardDes(false)
    end
  end)
end
function GiftRewardOfCheckin:ShowRewardDes(isShow)
  print("ShowRewardDes:", isShow)
  if isShow then
    if self.m_DesNode == nil then
      self:createDesNode_()
    end
    self.m_DesNode:setVisible(true)
  elseif self.m_DesNode then
    self.m_DesNode:setVisible(false)
  end
end
function GiftRewardOfCheckin:createDesNode_()
  self.m_DesNode = Widget:create()
  self:getUINode():addChild(self.m_DesNode)
  local p = self.getUINode():convertToNodeSpace(ccp(display.width / 2, display.height / 2))
  self.m_DesNode:setPosition(p)
  local sp = display.newSprite("views/common/bg/bg106.png")
  self.m_DesNode:addNode(sp)
  local spSize = sp:getContentSize()
  local w = spSize.width - 40
  local txt = CRichText.new({
    width = w,
    verticalSpace = 0,
    font = KANG_TTF_FONT,
    fontSize = 21,
    color = ccc3(231, 185, 99),
    align = CRichText_AlignType_Left
  })
  self.m_DesNode:addChild(txt)
  txt:addRichText("每月累计签到天数，领取相应的签到奖励。\n\n在特定日子里，达到对应VIP等级及以上的玩家可以领取双倍奖励！第二份奖励可以当日内升级VIP等级后补领。\n\n注：每日签到奖励在每天的05:00计算隔天，当天未领取的奖励隔天不可以再补领，但可以通过补签的办法补领哟。")
  local s = txt:getRichTextSize()
  txt:setPosition(ccp(-w / 2, spSize.height / 2 - s.height - 20))
end
function GiftRewardOfCheckin:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function GiftRewardOfCheckin:OnBtn_ReCheckIn(btnObj, touchType)
  print("GiftRewardOfCheckin:OnBtn_ReCheckIn")
  local cnt = gift.checkin:getCanReCheckInDays()
  if cnt > 0 then
    getCurSceneView():addSubView({
      subView = ReCheckin.new(cnt),
      zOrder = self:getUINode():getZOrder()
    })
  else
    ShowNotifyTips("你本月全勤,没有可补签的天数")
  end
end
