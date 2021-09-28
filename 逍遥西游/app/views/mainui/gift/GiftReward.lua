GiftReward = class("GiftReward", CcsSubView)
Gift_OnLine_ID = 1
Gift_LevelUp_ID = 2
Gift_SignUp_ID = 3
Gift_GetInput_ID = 4
Gift_Festival_ID = 5
Gift_NewTermCheckIn_ID = 6
Gift_GuoQingCheckIn_ID = 7
Gift_Login_ID = 8
function GiftReward:ctor()
  GiftReward.super.ctor(self, "views/gift.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_GiftList = self:getNode("list")
  self.m_GiftList:addTouchItemListenerListView(handler(self, self.ChooseItem), handler(self, self.ListGiftListener))
  self:ListenMessage(MsgID_Gift)
end
function GiftReward:reflushAll(dt)
  local giftIds = {}
  if gift.levelup:getDataShowLogindate() then
    local rewardId = gift.levelup:getLoginRewardId()
    local zs, lv, rewardList = gift.levelup:getLoginData()
    if rewardId <= 0 or zs == nil or lv == nil or rewardList == nil then
    else
      giftIds[#giftIds + 1] = Gift_Login_ID
    end
  end
  local fId = gift.festival:getFestivalId()
  if data_GiftOfFestival[fId] ~= nil then
    giftIds[#giftIds + 1] = Gift_Festival_ID
  end
  local rId = gift.online:getRewardId()
  if data_GiftOfOnline[rId] ~= nil then
    giftIds[#giftIds + 1] = Gift_OnLine_ID
  end
  if gift.levelup:getDataShowUpdate() then
    local rewardId = gift.levelup:getRewardId()
    local zs, lv, rewardList = gift.levelup:getData()
    if rewardId <= 0 or zs == nil or lv == nil or rewardList == nil then
    else
      giftIds[#giftIds + 1] = Gift_LevelUp_ID
    end
  end
  giftIds[#giftIds + 1] = Gift_SignUp_ID
  if gift.newTermCheckIn and gift.newTermCheckIn:IsInNewTermTime() then
    giftIds[#giftIds + 1] = Gift_NewTermCheckIn_ID
  end
  if gift.guoQingCheckIn and gift.guoQingCheckIn:IsInGuoQingTime() then
    giftIds[#giftIds + 1] = Gift_GuoQingCheckIn_ID
  end
  self.m_Items = {}
  self.m_GiftList:removeAllItems()
  for i, giftId in ipairs(giftIds) do
    local item = CGiftItem.new(giftId, self)
    self.m_GiftList:pushBackCustomItem(item:getUINode())
    self.m_Items[#self.m_Items + 1] = item
  end
  if channel.showGiftInputCode == true then
    local item = CGiftItem.new(Gift_GetInput_ID, self)
    self.m_GiftList:pushBackCustomItem(item:getUINode())
    self.m_Items[#self.m_Items + 1] = item
    giftIds = {}
    local showList = gift.identify:getShowIdentify()
    local acceptList = gift.identify:getAcceptIdentify()
    local allId = {}
    for _, tempGID in pairs(showList) do
      allId[#allId + 1] = tempGID
    end
    table.sort(allId)
    for _, tempGID in ipairs(allId) do
      local hasAcceptFlag = false
      for _, t in pairs(acceptList) do
        if tempGID == t then
          hasAcceptFlag = true
          break
        end
      end
      if hasAcceptFlag == false then
        giftIds[#giftIds + 1] = tempGID
      end
    end
    for i, giftId in ipairs(giftIds) do
      local item = CGiftItem.new(giftId, self)
      self.m_GiftList:pushBackCustomItem(item:getUINode())
      self.m_Items[#self.m_Items + 1] = item
    end
    local addGiftList = gift.identify:getAddIdentifyGift()
    local addAllId = {}
    for tempAID, _ in pairs(addGiftList) do
      addAllId[#addAllId + 1] = tempAID
    end
    table.sort(addAllId)
    for _, tempAID in pairs(addAllId) do
      local AData = addGiftList[tempAID]
      local item = CGiftItem.new(tempAID, self, AData)
      self.m_GiftList:pushBackCustomItem(item:getUINode())
      self.m_Items[#self.m_Items + 1] = item
    end
  end
  if gift.levelup:CanGetLevelupReward() == false and gift.checkin:CanTodayCheckIn() == false and (gift.newTermCheckIn:IsCanNewTermCheckInToday() == true or gift.guoQingCheckIn:IsCanGuoQingCheckInToday() == true) then
    local act1 = CCDelayTime:create(0.1)
    local act2 = CCCallFunc:create(function()
      self.m_GiftList:scrollToPercentVertical(100, 0.3, false)
      self.m_GiftList:sizeChangedForShowMoreTips()
    end)
    self:stopAllActions()
    self:runAction(transition.sequence({act1, act2}))
  end
  self.m_GiftList:sizeChangedForShowMoreTips()
end
function GiftReward:ChooseItem(item, index, listObj)
  print("-->GiftReward:ChooseItem:", item, index, listObj)
  local realItem = self.m_Items[index + 1]
  realItem:Touched()
end
function GiftReward:ListGiftListener(item, index, listObj, status)
  local realItem = self.m_Items[index + 1]
  if status == LISTVIEW_ONSELECTEDITEM_START then
    if realItem then
      realItem:setTouchStatus(true)
      self.m_TouchStartItem = realItem
    end
  elseif status == LISTVIEW_ONSELECTEDITEM_END then
    if self.m_TouchStartItem then
      self.m_TouchStartItem:setTouchStatus(false)
      self.m_TouchStartItem = nil
    end
    if realItem then
      realItem:setTouchStatus(false)
    end
  end
end
function GiftReward:OnMessage(msgSID, ...)
  if msgSID == MsgID_Gift_OnlineRewardUpdate then
    self:reflushAll()
  elseif msgSID == MsgID_Gift_LevelupRewardUpdate then
    self:reflushAll()
  elseif msgSID == MsgID_Gift_CheckinRewardUpdate then
    for _, item in pairs(self.m_Items) do
      if item ~= nil and item.SetDataEx and item.m_GiftId == Gift_SignUp_ID then
        item:SetDataEx()
      end
    end
  elseif msgSID == MsgID_Gift_GetGiftOfIdentify then
    self:reflushAll()
  elseif msgSID == MsgID_Gift_ShowGiftOfIdentify then
    self:reflushAll()
  elseif msgSID == MsgID_Gift_AddExGiftOfIdentify then
    self:reflushAll()
  elseif msgSID == MsgID_Gift_FestivalRewardUpdate then
    self:reflushAll()
  elseif msgSID == MsgID_Gift_NewTermCheckInUpdate then
    self:reflushAll()
  elseif msgSID == MsgID_Gift_GuoQingCheckInUpdate then
    self:reflushAll()
  end
end
function GiftReward:OnBtn_Close(btnObj, touchType)
  g_HuodongView:CloseSelf()
end
function GiftReward:Clear()
end
