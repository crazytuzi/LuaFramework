local isHideFinishCount = false
local cmpZsAndLv = function(zs1, lv1, zs2, lv2)
  if zs1 < zs2 then
    return -1
  elseif zs1 == zs2 then
    if lv1 == lv2 then
      return 0
    elseif lv1 < lv2 then
      return -1
    else
      return 1
    end
  elseif zs2 < zs1 then
    return 1
  end
end
EventView = class("EventView", CcsSubView)
function EventView:ctor(parent)
  EventView.super.ctor(self, "views/event.csb", {isAutoCenter = true, opacityBg = 100})
  self.parent = parent
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_rchd = {
      listener = handler(self, self.OnBtn_RCHD),
      variName = "btn_rchd"
    },
    btn_xshd = {
      listener = handler(self, self.OnBtn_XSHD),
      variName = "btn_xshd"
    },
    btn_jjkq = {
      listener = handler(self, self.OnBtn_JJKQ),
      variName = "btn_jjkq"
    },
    btn_finish_cnt = {
      listener = handler(self, self.OnBtn_FinishCount),
      variName = "btn_finish_cnt"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:addBtnSigleSelectGroup({
    {
      self.btn_rchd,
      nil,
      ccc3(251, 248, 145)
    },
    {
      self.btn_xshd,
      nil,
      ccc3(251, 248, 145)
    },
    {
      self.btn_jjkq,
      nil,
      ccc3(251, 248, 145)
    }
  })
  self.m_ShowBtnIndex = self:getShowEventViewIndex()
  self.m_EventList = self:getNode("list")
  self.m_EventList:addTouchItemListenerListView(handler(self, self.ChooseItem), handler(self, self.ListEventListener))
  self.m_NotFinishCountTips = nil
  self:flushShowFinishCount()
  self:ListenMessage(MsgID_Activity)
end
function EventView:getEventList()
  local events = activity.event:getAllEvent()
  local lv = g_LocalPlayer:getObjProperty(1, PROPERTY_ROLELEVEL)
  local zs = g_LocalPlayer:getObjProperty(1, PROPERTY_ZHUANSHENG)
  local canReciveIds = {}
  local canntReciveIds = {}
  local svrTime = g_DataMgr:getServerTime()
  local curH = tonumber(os.date("%H", svrTime))
  local curM = tonumber(os.date("%M", svrTime))
  if lv >= 1 then
    local data1 = data_DailyHuodongAward[10001]
    local condition1 = data1.Condition
    local beginH1 = condition1[1][1]
    local beginM1 = condition1[1][2]
    local endH1 = condition1[2][1]
    local endM1 = condition1[2][2]
    local data2 = data_DailyHuodongAward[10002]
    local condition2 = data2.Condition
    local beginH2 = condition2[1][1]
    local beginM2 = condition2[1][2]
    local endH2 = condition2[2][1]
    local endM2 = condition2[2][2]
    local isNeedShow10002 = true
    local pd1 = events[10001]
    local pro1
    if pd1 then
      pro1 = pd1.state
    end
    if pro1 == activity.event.Status_CanRecive then
      canReciveIds[#canReciveIds + 1] = 10001
    elseif pro1 == activity.event.Status_CannotRecive then
      if curH > beginH2 or curH == beginH2 and curM > beginM2 or curH < endH1 or curH == endH1 and curM <= endM1 then
        canntReciveIds[#canntReciveIds + 1] = 10001
      end
    elseif curH > beginH2 or curH == beginH2 and curM > beginM2 then
      canntReciveIds[#canntReciveIds + 1] = 10001
    end
    local pd2 = events[10002]
    local pro2
    if pd2 then
      pro2 = pd2.state
    end
    if pro2 == activity.event.Status_CanRecive then
      canReciveIds[#canReciveIds + 1] = 10002
    elseif pro2 == activity.event.Status_CannotRecive and (curH > beginH1 or curH == beginH1 and curM > beginM1) and (curH < endH2 or curH == endH2 and curM <= endM2) then
      canntReciveIds[#canntReciveIds + 1] = 10002
    end
  end
  for eventId, proData in pairs(events) do
    if eventId == 10001 or eventId == 10002 then
    else
      print("YYYYYYYYYYYYYYYYYYYYYYYY:::", eventId)
      local data = data_DailyHuodongAward[eventId]
      if data and data_judgeFuncOpen(zs, lv, data.OpenZs, data.OpenLv, data.AlwaysJudgeLvFlag) == true then
        local statu = proData.state
        if statu == activity.event.Status_CanRecive then
          canReciveIds[#canReciveIds + 1] = eventId
        elseif statu == activity.event.Status_CannotRecive then
          if eventId == 10013 then
            if activity.keju:getStatus(KejuType_1) == 1 then
              canntReciveIds[#canntReciveIds + 1] = eventId
            end
          elseif eventId == 10007 then
            local cur, sum = activity.tianting:getTimes()
            if cur < sum then
              canntReciveIds[#canntReciveIds + 1] = eventId
            end
          elseif eventId == 10021 then
            local needNew = false
            if g_BpMgr then
              local anzhan = BangPaiAnZhan.hadDone == true and BangPaiAnZhan.todayTime > 11 or BangPaiAnZhan.hadDone == true and BangPaiAnZhan.todayTime < 0 or BangPaiAnZhan.hadCommit == true
              local chumo = BangPaiChuMo.serviceState == false and BangPaiChuMo.MissionId == -1
              if g_BpMgr:getOpenChuMoFlag() == true and g_BpMgr:getOpenAnZhanFlag() ~= true then
                if BangPaiChuMo.getCanAcceptChuMo() == true or chumo ~= true then
                  needNew = true
                end
              elseif g_BpMgr:getOpenChuMoFlag() ~= true and g_BpMgr:getOpenAnZhanFlag() == true then
                if BangPaiAnZhan.getCanAcceptAnZhan() == true or anzhan ~= true then
                  needNew = true
                end
              elseif g_BpMgr:getOpenChuMoFlag() == true and g_BpMgr:getOpenAnZhanFlag() == true and (BangPaiChuMo.getCanAcceptChuMo() == true or chumo ~= true or BangPaiAnZhan.getCanAcceptAnZhan() == true or anzhan ~= true) then
                needNew = true
              end
            end
            if needNew == true then
              canntReciveIds[#canntReciveIds + 1] = eventId
            end
          elseif eventId == 10020 then
            local needNew = false
            if 0 < BangPaiPaoShang.todayTimes and (BangPaiPaoShang.isCanAccetp() == true or 0 < BangPaiPaoShang.getCircle() and BangPaiPaoShang.taskid ~= nil) then
              needNew = true
            end
            if needNew == true then
              canntReciveIds[#canntReciveIds + 1] = eventId
            end
          elseif eventId == 10019 then
            local needNew = false
            local ttime = SanJieLiLian.getCircle()
            print("=======>>>>>>>>>  ttime ", ttime, "   SanJieLiLian.today_times ", SanJieLiLian.today_times, SanJieLiLian.doneLastTime, SanJieLiLian.isAccepted())
            if SanJieLiLian.today_times < SanJieLiLian.Limei_Times and SanJieLiLian.doneLastTime ~= true then
              needNew = true
            end
            if needNew == true then
              canntReciveIds[#canntReciveIds + 1] = eventId
            end
          else
            canntReciveIds[#canntReciveIds + 1] = eventId
          end
        end
      end
    end
  end
  local sortFunc = function(t1, t2)
    if t1 == nil or t2 == nil then
      return false
    end
    local needRemind1 = false
    local needRemind2 = false
    if g_CMainMenuHandler then
      needRemind1 = g_CMainMenuHandler:JudgeEventNeedRemind(t1)
      needRemind2 = g_CMainMenuHandler:JudgeEventNeedRemind(t2)
    end
    if needRemind1 == true and needRemind2 == false then
      return true
    elseif needRemind2 == true and needRemind1 == false then
      return false
    end
    local d1 = data_DailyHuodongAward[t1] or {}
    local d2 = data_DailyHuodongAward[t2] or {}
    if d1.showNumber > d2.showNumber then
      return false
    elseif d1.showNumber < d2.showNumber then
      return true
    else
      return t1 < t2
    end
  end
  table.sort(canReciveIds, sortFunc)
  table.sort(canntReciveIds, sortFunc)
  local myEvent = {}
  for i, eventId in ipairs(canReciveIds) do
    myEvent[#myEvent + 1] = eventId
  end
  for i, eventId in ipairs(canntReciveIds) do
    myEvent[#myEvent + 1] = eventId
  end
  local rchdList = {}
  local xshdList = {}
  for i, eventId in ipairs(myEvent) do
    if eventId == 10001 or eventId == 10002 or eventId == 10013 then
      xshdList[#xshdList + 1] = eventId
    else
      local xshdFlag = false
      for xshdEventId, _ in pairs(data_Huodong) do
        if xshdEventId == eventId then
          xshdFlag = true
          break
        end
      end
      if xshdFlag then
        xshdList[#xshdList + 1] = eventId
      else
        rchdList[#rchdList + 1] = eventId
      end
    end
  end
  local jjkqList = {}
  for eventID, data in pairs(data_DailyHuodongAward) do
    local needZs, needLv, alwaysJudgeLvFlag = data.OpenZs, data.OpenLv, data.AlwaysJudgeLvFlag
    if data_judgeFuncOpen(zs, lv, needZs, needLv, alwaysJudgeLvFlag) == false then
      jjkqList[#jjkqList + 1] = eventID
    end
  end
  local sortFuncLv = function(t1, t2)
    if t1 == nil or t2 == nil then
      return false
    end
    local d1 = data_DailyHuodongAward[t1] or {}
    local d2 = data_DailyHuodongAward[t2] or {}
    if d1.OpenLv > d2.OpenLv then
      return false
    elseif d1.OpenLv < d2.OpenLv then
      return true
    else
      return t1 < t2
    end
  end
  table.sort(jjkqList, sortFuncLv)
  local newJjkqList = {}
  local tempLv = {}
  for _, eventID in ipairs(jjkqList) do
    local tData = data_DailyHuodongAward[eventID] or {}
    local openLv = tData.OpenLv or 0
    if #tempLv == 0 or tempLv[#tempLv] ~= openLv then
      tempLv[#tempLv + 1] = openLv
    end
    if #tempLv <= 3 then
      newJjkqList[#newJjkqList + 1] = eventID
    end
  end
  return rchdList, xshdList, newJjkqList
end
function EventView:getShowEventViewIndex()
  local rchdList, xshdList, jjkqList = self:getEventList()
  local eventData = activity.event:getAllEvent()
  for _, eId in ipairs(xshdList) do
    local tData = eventData[eId] or {}
    if tData.state == activity.event.Status_CanRecive then
      return MeiRiHuoDongShow_xshdView
    end
  end
  for _, eId in ipairs(rchdList) do
    local tData = eventData[eId] or {}
    if tData.state == activity.event.Status_CanRecive then
      return MeiRiHuoDongShow_rchdView
    end
  end
  for _, eId in ipairs(jjkqList) do
    local tData = eventData[eId] or {}
    if tData.state == activity.event.Status_CanRecive then
      return MeiRiHuoDongShow_jjkqView
    end
  end
  if g_CMainMenuHandler and g_CMainMenuHandler:JudgeNeedRemindEventList() then
    return MeiRiHuoDongShow_xshdView
  end
  return MeiRiHuoDongShow_rchdView
end
function EventView:reflushAll()
  local rchdList, xshdList, jjkqList = self:getEventList()
  if #jjkqList == 0 then
    self.btn_jjkq:setVisible(false)
    self.btn_jjkq:setTouchEnabled(false)
    if self.m_ShowBtnIndex == MeiRiHuoDongShow_jjkqView then
      self.m_ShowBtnIndex = MeiRiHuoDongShow_rchdView
    end
  else
    self.btn_jjkq:setVisible(true)
    self.btn_jjkq:setTouchEnabled(true)
  end
  local tempBtnNameDict = {
    [MeiRiHuoDongShow_rchdView] = self.btn_rchd,
    [MeiRiHuoDongShow_xshdView] = self.btn_xshd,
    [MeiRiHuoDongShow_jjkqView] = self.btn_jjkq
  }
  self:setGroupBtnSelected(tempBtnNameDict[self.m_ShowBtnIndex])
  self:getNode("tips"):setVisible(self.m_ShowBtnIndex == MeiRiHuoDongShow_rchdView)
  local tempDataDict = {
    [MeiRiHuoDongShow_rchdView] = rchdList,
    [MeiRiHuoDongShow_xshdView] = xshdList,
    [MeiRiHuoDongShow_jjkqView] = jjkqList
  }
  self.m_Items = {}
  self.m_EventList:removeAllItems()
  self.m_EventList:setInnerContainerSize(CCSize(0, 0))
  for i, eventId in ipairs(tempDataDict[self.m_ShowBtnIndex]) do
    local item = EventItem.new(eventId, self)
    self.m_EventList:pushBackCustomItem(item:getUINode())
    self.m_Items[#self.m_Items + 1] = item
  end
  self.m_EventList:sizeChangedForShowMoreTips()
end
function EventView:ChooseItem(item, index, listObj)
  print("-->EventView:ChooseItem:", item, index, listObj)
  local realItem = self.m_Items[index + 1]
  realItem:Touched()
end
function EventView:ListEventListener(item, index, listObj, status)
  local realItem = self.m_Items[index + 1]
  if status == LISTVIEW_ONSELECTEDITEM_START then
    if realItem then
      self.m_TouchStartItem = realItem
    end
  elseif status == LISTVIEW_ONSELECTEDITEM_END then
    if self.m_TouchStartItem then
      self.m_TouchStartItem = nil
    end
    if realItem then
    end
  end
end
function EventView:OnMessage(msgSID, ...)
  if msgSID == MsgID_Activity_Updated then
    self:reflushAll()
  elseif msgSID == MsgID_Activity_FinishCountUpdate then
    self:flushShowFinishCount()
  end
end
function EventView:OnBtn_Close(btnObj, touchType)
  g_HuodongView:CloseSelf()
end
function EventView:OnBtn_RCHD(btnObj, touchType)
  if self.m_ShowBtnIndex == MeiRiHuoDongShow_rchdView then
    return
  else
    self.m_ShowBtnIndex = MeiRiHuoDongShow_rchdView
    self:reflushAll()
  end
end
function EventView:OnBtn_XSHD(btnObj, touchType)
  if self.m_ShowBtnIndex == MeiRiHuoDongShow_xshdView then
    return
  else
    self.m_ShowBtnIndex = MeiRiHuoDongShow_xshdView
    self:reflushAll()
  end
end
function EventView:OnBtn_JJKQ(btnObj, touchType)
  if self.m_ShowBtnIndex == MeiRiHuoDongShow_jjkqView then
    return
  else
    self.m_ShowBtnIndex = MeiRiHuoDongShow_jjkqView
    self:reflushAll()
  end
end
function EventView:OnBtn_FinishCount(btnObj, touchType)
  print("---->> OnBtn_FinishCount")
  ShowFinishCountView()
end
function EventView:flushShowFinishCount()
  if isHideFinishCount then
    self.btn_finish_cnt:setEnabled(false)
    self.btn_finish_cnt:setVisible(false)
    return
  end
  local pos_finishcnt = self:getNode("pos_finishcnt")
  local size = pos_finishcnt:getSize()
  if self.m_NotFinishCountTips == nil then
    local txtWidth = size.width * 2
    self.m_NotFinishCountTips = CRichText.new({
      width = txtWidth,
      fontSize = 20,
      color = ccc3(255, 255, 255),
      align = CRichText_AlignType_Right
    })
    self:addChild(self.m_NotFinishCountTips)
    local x, y = pos_finishcnt:getPosition()
    self.m_NotFinishCountTips:setPosition(ccp(x + size.width - txtWidth, y))
  end
  local data, notFinishCount = g_DataMgr:getFinishEventData()
  if notFinishCount == nil then
    notFinishCount = 0
  end
  local text = string.format("今天还有#<r:0,g:255,b:0>%d#件事可以完成", checkint(notFinishCount))
  self.m_NotFinishCountTips:clearAll()
  self.m_NotFinishCountTips:addRichText(text)
end
function EventView:Clear()
  self.m_NotFinishCountTips = nil
  self.m_Items = {}
  self.m_TouchStartItem = nil
  if self.parent ~= nil then
    self.parent = nil
  end
end
