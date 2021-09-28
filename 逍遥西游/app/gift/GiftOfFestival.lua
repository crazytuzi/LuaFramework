local festival = class("CGiftOfFestival")
function festival:ctor()
  self.m_CurFestivalId = nil
  self.m_HasReciveFestivalList = {}
  self.m_UpdateFestivalScheduler = scheduler.scheduleGlobal(handler(self, self.updateFestivalId), 5)
end
function festival:setHasGetFestival(tempList)
  self.m_HasReciveFestivalList = tempList
  self:updateFestivalId()
end
function festival:getFestivalId()
  return self.m_CurFestivalId
end
function festival:updateFestivalId()
  local newFId, _ = self:CalculateFestivalId()
  local oldFId = self.m_CurFestivalId
  self.m_CurFestivalId = newFId
  if newFId ~= oldFId then
    SendMessage(MsgID_Gift_FestivalRewardUpdate)
  end
end
function festival:CalculateFestivalId()
  local fIdList = {}
  for fId, _ in pairs(data_GiftOfFestival) do
    fIdList[#fIdList + 1] = fId
  end
  table.sort(fIdList)
  local curFId, nextFId
  local curTime = g_DataMgr:getServerTime()
  local curYear = tonumber(os.date("%Y", curTime))
  local curMon = tonumber(os.date("%m", curTime))
  local curDay = tonumber(os.date("%d", curTime))
  local curH = tonumber(os.date("%H", curTime))
  local curM = tonumber(os.date("%M", curTime))
  local curS = tonumber(os.date("%S", curTime))
  local curTimeList = {
    curYear,
    curMon,
    curDay,
    curH,
    curM,
    curS
  }
  for _, fId in ipairs(fIdList) do
    local hasGetFlag = false
    for _, gId in pairs(self.m_HasReciveFestivalList) do
      if fId == gId then
        hasGetFlag = true
        break
      end
    end
    local fData = data_GiftOfFestival[fId]
    local startTimeList = fData.startTime
    local endTimeList = fData.endTime
    if curFId == nil and hasGetFlag == false and self:JudgeTime(curTimeList, startTimeList) == false and self:JudgeTime(curTimeList, endTimeList) == true then
      curFId = fId
    end
    if nextFId == nil and hasGetFlag == false and self:JudgeTime(curTimeList, startTimeList) == true then
      nextFId = fId
    end
    if curFId ~= nil and nextFId ~= nil then
      break
    end
  end
  return curFId, nextFId
end
function festival:JudgeTime(t1List, t2List)
  for i = 1, 6 do
    if t1List[i] > t2List[i] then
      return false
    elseif t1List[i] < t2List[i] then
      return true
    end
  end
  return true
end
function festival:CheckFestivalGift()
  local curFId = self:getFestivalId()
  if curFId then
    local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_FestivalGift)
    if openFlag == false then
      ShowNotifyTips(tips)
      return
    end
    netsend.netgift.reqGetGiftOfFestival(curFId)
  else
    local _, nextFId = self:CalculateFestivalId()
    if data_GiftOfFestival[nextFId] then
      getCurSceneView():addSubView({
        subView = CFestival_Info.new(nextFId),
        zOrder = MainUISceneZOrder.popDetailView
      })
    end
  end
end
function festival:Clean()
  if self.m_UpdateFestivalScheduler then
    scheduler.unscheduleGlobal(self.m_UpdateFestivalScheduler)
    self.m_UpdateFestivalScheduler = nil
  end
end
CFestival_Info = class("CFestival_Info", function()
  local widget = Widget:create()
  widget:setAnchorPoint(ccp(0, 0))
  widget:ignoreContentAdaptWithSize(false)
  widget:setSize(CCSize(display.width, display.height))
  return widget
end)
function CFestival_Info:ctor(fId)
  self:setTouchEnabled(true)
  self:addTouchEventListener(handler(self, self.Touch))
  local title = "节日礼品使者"
  local fData = data_GiftOfFestival[fId]
  local startTime = fData.startTime
  local month = startTime[2]
  local day = startTime[3]
  local name = fData.name
  local des = string.format("下次礼物将于#<Y>%d月%d日%s#发放!", month, day, name)
  self.m_TxtX = 255
  local blackH = 130
  local layerC = display.newColorLayer(ccc4(0, 0, 0, 200))
  layerC:setContentSize(CCSize(display.width, blackH))
  self:addNode(layerC, 5)
  layerC:setPosition(ccp(0, 0))
  local sharedFileUtils = CCFileUtils:sharedFileUtils()
  self.m_HeadImg = display.newSprite("xiyou/head/head20033_big.png")
  self:addNode(self.m_HeadImg, 10)
  local size = self.m_HeadImg:getContentSize()
  self.m_HeadImg:setPosition(ccp(self.m_TxtX / 2, size.height / 2))
  local titleW = display.width - self.m_TxtX - 30
  local titleColor = ccc3(255, 196, 98)
  local titleTxt = CRichText.new({
    width = titleW,
    verticalSpace = 1,
    font = KANG_TTF_FONT,
    fontSize = 24,
    color = titleColor
  })
  self:addChild(titleTxt, 10)
  titleTxt:addRichText(string.format("%s", title))
  local titleTxtSize = titleTxt:getRichTextSize()
  local titleY = blackH - titleTxtSize.height - 15
  titleTxt:setPosition(ccp(self.m_TxtX, titleY))
  titleY = titleY - titleTxtSize.height
  local desColor = ccc3(255, 255, 255)
  local desTxt = CRichText.new({
    width = titleW,
    verticalSpace = 1,
    font = KANG_TTF_FONT,
    fontSize = 22,
    color = desColor
  })
  self:addChild(desTxt, 10)
  desTxt:addRichText(string.format("%s", des))
  local desTxtSize = desTxt:getRichTextSize()
  local s = desTxt:getRichTextSize()
  titleY = blackH - 50 - desTxtSize.height
  desTxt:setPosition(ccp(self.m_TxtX, titleY))
end
function CFestival_Info:Touch(touchObj, t)
  if t == TOUCH_EVENT_ENDED then
    self:removeSelf()
  end
end
return festival
