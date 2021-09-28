g_HuodongView = nil
CHuodongShow = class("CHuodongShow", CcsSubView)
function CHuodongShow:ctor(para)
  para = para or {}
  self.m_ViewPara = para
  self.m_InitHuodongShow = para.InitHuodongShow or HuodongShow_EventView
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Huodong)
  if openFlag == false then
    self.m_InitHuodongShow = HuodongShow_GiftView
  end
  local giftFlag = false
  if gift.festival:getFestivalId() then
    giftFlag = true
  elseif gift.levelup:CanGetLevelupReward() then
    giftFlag = true
  elseif gift.checkin:CanTodayCheckIn() then
    giftFlag = true
  elseif gift.newTermCheckIn:IsCanNewTermCheckInToday() then
    giftFlag = true
  elseif gift.guoQingCheckIn:IsCanGuoQingCheckInToday() then
    giftFlag = true
  elseif data_GiftOfOnline[gift.online:getRewardId()] ~= nil then
    local nextCmpTime = gift.online:getNextCmpTime()
    local svrTime = g_DataMgr:getServerTime()
    if nextCmpTime - svrTime < 0 or nextCmpTime < 0 or svrTime < 0 then
      giftFlag = true
    end
  end
  if giftFlag then
    self.m_InitHuodongShow = HuodongShow_GiftView
  end
  CHuodongShow.super.ctor(self, "views/huodong.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_event = {
      listener = handler(self, self.OnBtn_Event),
      variName = "btn_event"
    },
    btn_gift = {
      listener = handler(self, self.OnBtn_Gift),
      variName = "btn_gift"
    },
    btn_schedule = {
      listener = handler(self, self.OnBtn_Schedule),
      variName = "btn_schedule"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:addBtnSigleSelectGroup({
    {
      self.btn_event,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_gift,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_schedule,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    }
  })
  self.btn_event:setTitleText("活\n动")
  self.btn_gift:setTitleText("礼\n包")
  self.btn_schedule:setTitleText("活\n动\n周\n历")
  local size = self.btn_event:getContentSize()
  self:adjustClickSize(self.btn_event, size.width + 30, size.height, true)
  local size = self.btn_gift:getContentSize()
  self:adjustClickSize(self.btn_gift, size.width + 30, size.height, true)
  local size = self.btn_schedule:getContentSize()
  self:adjustClickSize(self.btn_schedule, size.width + 30, size.height, true)
  self:setGroupAllNotSelected(self.btn_event)
  self.m_GiftView = nil
  self.m_EventView = nil
  self.m_ScheduleView = nil
  self:SelectView(self.m_InitHuodongShow)
  g_HuodongView = self
  netsend.netactivity.reqEventFinishCount()
end
function CHuodongShow:CreateView(viewNum)
  local tempViewNameDict = {
    [HuodongShow_EventView] = "m_EventView",
    [HuodongShow_GiftView] = "m_GiftView",
    [HuodongShow_ScheduleView] = "m_ScheduleView"
  }
  local viewObj = self[tempViewNameDict[i]]
  if viewObj == nil then
    local tempView
    if viewNum == HuodongShow_EventView then
      tempView = EventView.new(self)
      self.m_EventView = tempView
    elseif viewNum == HuodongShow_GiftView then
      tempView = GiftReward.new()
      self.m_GiftView = tempView
    elseif viewNum == HuodongShow_ScheduleView then
      tempView = CHDSchedule.new()
      self.m_ScheduleView = tempView
    end
    if tempView ~= nil then
      self:addChild(tempView.m_UINode, 1)
      tempView:setPosition(ccp(0, 0))
    end
  end
end
function CHuodongShow:SelectView(viewNum)
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Huodong)
  if openFlag == false and viewNum == HuodongShow_EventView then
    viewNum = HuodongShow_GiftView
    ShowNotifyTips(tips)
  end
  local viewNumList = {
    HuodongShow_EventView,
    HuodongShow_GiftView,
    HuodongShow_ScheduleView
  }
  local tempViewNameDict = {
    [HuodongShow_EventView] = "m_EventView",
    [HuodongShow_GiftView] = "m_GiftView",
    [HuodongShow_ScheduleView] = "m_ScheduleView"
  }
  local tempBtnNameDict = {
    [HuodongShow_EventView] = self.btn_event,
    [HuodongShow_GiftView] = self.btn_gift,
    [HuodongShow_ScheduleView] = self.btn_schedule
  }
  local viewObj = self[tempViewNameDict[viewNum]]
  if viewObj == nil then
    self:CreateView(viewNum)
  end
  for _, i in pairs(viewNumList) do
    local viewObj = self[tempViewNameDict[i]]
    if viewObj ~= nil then
      viewObj:setVisible(i == viewNum)
      viewObj:setEnabled(i == viewNum)
    end
  end
  if viewNum == HuodongShow_EventView then
    self.m_EventView:reflushAll()
  elseif viewNum == HuodongShow_GiftView then
    self.m_GiftView:reflushAll()
  end
  self:setGroupBtnSelected(tempBtnNameDict[viewNum])
end
function CHuodongShow:OnBtn_Event(btnObj, touchType)
  self:SelectView(HuodongShow_EventView)
end
function CHuodongShow:OnBtn_Gift(btnObj, touchType)
  self:SelectView(HuodongShow_GiftView)
end
function CHuodongShow:OnBtn_Schedule(btnObj, touchType)
  self:SelectView(HuodongShow_ScheduleView)
end
function CHuodongShow:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function CHuodongShow:ShowSelf()
  self:setVisible(true)
  if self._auto_create_opacity_bg_ins then
    self._auto_create_opacity_bg_ins:setVisible(true)
  end
end
function CHuodongShow:HideSelf()
  self:setVisible(false)
  if self._auto_create_opacity_bg_ins then
    self._auto_create_opacity_bg_ins:setVisible(false)
  end
end
function CHuodongShow:Clear()
  if g_HuodongView == self then
    g_HuodongView = nil
  end
end
