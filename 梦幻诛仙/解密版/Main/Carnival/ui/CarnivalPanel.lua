local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local CarnivalUtils = require("Main.Carnival.CarnivalUtils")
local CarnivalData = require("Main.Carnival.data.CarnivalData")
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
local ActivityMain = require("Main.activity.ui.ActivityMain")
local ActivityType = require("consts.mzm.gsp.activity.confbean.ActivityType")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CarnivalPanel = Lplus.Extend(ECPanelBase, "CarnivalPanel")
local def = CarnivalPanel.define
local instance
def.static("=>", CarnivalPanel).Instance = function()
  if instance == nil then
    instance = CarnivalPanel()
  end
  return instance
end
def.field("table")._uiObjs = nil
def.const("number").UPDATE_INTERVAL = 0.1
def.const("number").AWARD_MAX_SHOW_NUM = 4
def.const("number").EXCHANGE_MAX_SHOW_NUM = 2
def.field("number")._timerID = 0
def.field("table")._activityCfgList = nil
def.field("table")._awardItems = nil
def.field("table")._exchangeFragments = nil
def.field("table")._activityCompleteCustomCondition = nil
def.field("boolean")._isNeedRefreshList = false
def.static().ShowPanel = function()
  if CarnivalPanel.Instance():IsShow() then
    CarnivalPanel.Instance():UpdateUI()
    return
  end
  instance:CreatePanel(RESPATH.PREFAB_CARNIVAL_PANEL, 1)
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  self:_InitUI()
  self._activityCompleteCustomCondition = ActivityMain.Instance()._activityCompleteCustomCondition
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Group_Activity = self.m_panel:FindDirect("Img_Bg0/Group_Games")
  self._uiObjs.Scrollview_Activity = self._uiObjs.Group_Activity:FindDirect("Scrollview")
  self._uiObjs.actUIScrollview = self._uiObjs.Scrollview_Activity:GetComponent("UIScrollView")
  self._uiObjs.List_Activity = self._uiObjs.Scrollview_Activity:FindDirect("List")
  self._uiObjs.actUIList = self._uiObjs.List_Activity:GetComponent("UIList")
  self._uiObjs.Group_Reward = self.m_panel:FindDirect("Img_Bg0/Group_Reward")
  self._uiObjs.List_Reward = self._uiObjs.Group_Reward:FindDirect("List_Reward")
  self._uiObjs.awardUIList = self._uiObjs.List_Reward:GetComponent("UIList")
  self._uiObjs.Group_Fragment = self.m_panel:FindDirect("Img_Bg0/Group_SReward")
  self._uiObjs.List_Fragment = self._uiObjs.Group_Fragment:FindDirect("List")
  self._uiObjs.fragmentUIList = self._uiObjs.List_Fragment:GetComponent("UIList")
  self._uiObjs.Btn_Exchange = self.m_panel:FindDirect("Img_Bg0/Btn_Exchange")
  self._uiObjs.Img_Red = self._uiObjs.Btn_Exchange:FindDirect("Img_New")
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
    self:UpdateUI()
  else
  end
end
def.method().UpdateUI = function(self)
  self:_ClearTimer()
  self:UpdateActivityList()
  self:UpdateAwardList()
  self:UpdateExchange()
end
def.method().UpdateTime = function(self)
end
def.override().OnDestroy = function(self)
  self:_ClearTimer()
  self:ClearActivityList()
  self:ClearAwardList()
  self:ClearFragmentList()
  self._uiObjs = nil
  self._activityCfgList = nil
  self._awardItems = nil
  self._exchangeFragments = nil
  self._isNeedRefreshList = false
end
def.method()._ClearTimer = function(self)
  if self._timerID ~= 0 then
    GameUtil.RemoveGlobalTimer(self._timerID)
    self._timerID = 0
  end
end
def.method().ClearActivityList = function(self)
  self._uiObjs.actUIList.itemCount = 0
  self._uiObjs.actUIList:Resize()
  self._uiObjs.actUIList:Reposition()
end
def.method().ClearAwardList = function(self)
  self._uiObjs.awardUIList.itemCount = 0
  self._uiObjs.awardUIList:Resize()
  self._uiObjs.awardUIList:Reposition()
end
def.method().ClearFragmentList = function(self)
  self._uiObjs.fragmentUIList.itemCount = 0
  self._uiObjs.fragmentUIList:Resize()
  self._uiObjs.fragmentUIList:Reposition()
end
def.method().UpdateActivityList = function(self)
  self:ClearActivityList()
  self._activityCfgList = CarnivalData.Instance():GetValidActivities(constant.ActivitiesGuidelineConsts.ACTIVITY_ID)
  local itemAmount = self._activityCfgList and #self._activityCfgList or 0
  if itemAmount <= 0 then
    return
  end
  self._uiObjs.actUIList.itemCount = itemAmount
  self._uiObjs.actUIList:Resize()
  self._uiObjs.actUIList:Reposition()
  for index, actCfg in ipairs(self._activityCfgList) do
    self:SetActivityListItem(index, actCfg)
  end
end
def.method("number", "table").SetActivityListItem = function(self, index, actCfg)
  if nil == actCfg then
    warn("[ERROR][CarnivalPanel:SetActivityListItem] actCfg nil at index:", index)
    return
  end
  local listItem = self._uiObjs.List_Activity:FindDirect("Game_" .. index)
  if nil == listItem then
    warn("[ERROR][CarnivalPanel:SetActivityListItem] listItem nil at index:", index)
    return
  end
  local Img_BgIcon = listItem:FindDirect(string.format("Img_BgIcon_%d", index))
  GUIUtils.FillIcon(Img_BgIcon:GetComponent("UITexture"), actCfg.activityIcon)
  local Label_Name = listItem:FindDirect(string.format("Label_Name_%d", index))
  GUIUtils.SetText(Label_Name, actCfg.activityName)
  local bComplete = false
  local Label_N = listItem:FindDirect("Label_1_" .. index)
  local Label_Num = listItem:FindDirect("Label_Num_" .. index)
  local activityInfo = activityInterface:GetActivityInfo(actCfg.id)
  local recommendCount = actCfg.recommendCount
  local isSpecialRecommendNum, num = activityInterface:isSpecialRecommendNum(actCfg.id)
  if isSpecialRecommendNum then
    recommendCount = num
  end
  if recommendCount > 0 then
    GUIUtils.SetActive(Label_N, true)
    GUIUtils.SetActive(Label_Num, true)
    local count = 0
    if activityInfo ~= nil then
      bComplete = recommendCount <= activityInfo.count
      count = math.min(activityInfo.count, recommendCount)
      if ActivityMain.Instance():IsSpecialActiviy(actCfg.id) then
        count, recommendCount = ActivityMain.Instance():GetSpecialActiviyInfo(actCfg.id)
        bComplete = count >= recommendCount
      end
    end
    GUIUtils.SetText(Label_Num, count .. "/" .. recommendCount)
  elseif recommendCount == 0 then
    GUIUtils.SetActive(Label_N, true)
    GUIUtils.SetActive(Label_Num, true)
    GUIUtils.SetText(Label_Num, textRes.activity[60])
  else
    GUIUtils.SetActive(Label_N, false)
    GUIUtils.SetActive(Label_Num, false)
  end
  local additional = self._activityCompleteCustomCondition[actCfg.id]
  if additional ~= nil then
    bComplete = additional(activityInfo, actCfg, bComplete)
  end
  local Img_Sign = listItem:FindDirect("Img_Sign_" .. index)
  if actCfg.jiaoBiaoId ~= 0 then
    GUIUtils.SetActive(Img_Sign, true)
    GUIUtils.FillIcon(Img_Sign:GetComponent("UITexture"), actCfg.jiaoBiaoId)
  else
    GUIUtils.SetActive(Img_Sign, false)
  end
  local Img_New = listItem:FindDirect("Img_New_" .. index)
  if activityInterface._newTimeOpenActivitiesSet[actCfg.id] ~= nil or activityInterface._newFestivalActivitiesSet[actCfg.id] ~= nil or activityInterface.activityRedPoint[actCfg.id] then
    Img_New:SetActive(true)
  else
    Img_New:SetActive(false)
  end
  local wordTip = actCfg.wordTip
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp.level < actCfg.levelMin then
    wordTip = string.format(textRes.activity[162], actCfg.levelMin)
  elseif heroProp.level > actCfg.levelMax then
    wordTip = string.format(textRes.activity[163], actCfg.levelMax)
  end
  local Btn_Join = listItem:FindDirect(string.format("Btn_Join_%d", index))
  local Label_Time = listItem:FindDirect("Label_Time_" .. index)
  GUIUtils.SetActive(Label_Time, false)
  while true do
    if wordTip ~= "" then
      break
    end
    local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
    local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
    local nowSec = GetServerTime()
    local inPeriod = actCfg.activityType == ActivityType.Daily
    if inPeriod == false then
      inPeriod = activityInterface._activityInPeriod[actCfg.id] ~= nil
    end
    local isInDate = true
    local timeLimitCommonCfg = TimeCfgUtils.GetTimeLimitCommonCfg(actCfg.activityLimitTimeid)
    if timeLimitCommonCfg ~= nil then
      local beginTime = TimeCfgUtils.GetTimeSec(timeLimitCommonCfg.startYear, timeLimitCommonCfg.startMonth, timeLimitCommonCfg.startDay, timeLimitCommonCfg.startHour, timeLimitCommonCfg.startMinute, 0)
      local endTime = TimeCfgUtils.GetTimeSec(timeLimitCommonCfg.endYear, timeLimitCommonCfg.endMonth, timeLimitCommonCfg.endDay, timeLimitCommonCfg.endHour, timeLimitCommonCfg.endMinute, 0)
      isInDate = nowSec >= beginTime and nowSec <= endTime
    end
    if isInDate == true and inPeriod == false then
      local isToday = false
      local hasBeenToday = false
      local recentDayWeek = 8
      local recentDayWeek2 = 0
      local isRecentDayWeek = false
      local isRecentDayWeek2 = false
      local curTimeTable = AbsoluteTimer.GetServerTimeTable(nowSec)
      local nowYear = curTimeTable.year
      local nowMonth = curTimeTable.month
      local nowDayWeek = curTimeTable.wday
      local nowDay = curTimeTable.day
      local oneDayFirst = true
      for idx, timeDurationCommonCfg in pairs(actCfg.activityTimeCfgs) do
        local start = false
        local stop = true
        local beginHour = timeDurationCommonCfg.timeCommonCfg.activeHour
        local beginMinute = timeDurationCommonCfg.timeCommonCfg.activeMinute
        if timeDurationCommonCfg.timeCommonCfg.activeWeekDay ~= 0 then
          isToday = nowDayWeek == timeDurationCommonCfg.timeCommonCfg.activeWeekDay
          inPeriod = isToday
          if isToday == true then
            local beginHour = timeDurationCommonCfg.timeCommonCfg.activeHour
            local beginMinute = timeDurationCommonCfg.timeCommonCfg.activeMinute
            local beginTime = TimeCfgUtils.GetTimeSec(nowYear, nowMonth, nowDay, beginHour, beginMinute, 0)
            local durationSec = timeDurationCommonCfg.lastDay * 86400 + timeDurationCommonCfg.lastHour * 3600 + timeDurationCommonCfg.lastMinute * 60
            local endTime = beginTime + durationSec
            start = nowSec >= beginTime
            if start == false then
              if oneDayFirst == true and actCfg.recommendCount > 0 then
                GUIUtils.SetText(Label_Num, "0/" .. actCfg.recommendCount)
              end
              bComplete = false
            elseif bComplete == true then
              break
            end
            oneDayFirst = false
            stop = nowSec > endTime
            inPeriod = start == true and stop == false
            isRecentDayWeek = false
            isRecentDayWeek2 = false
          else
            if (nowDayWeek < timeDurationCommonCfg.timeCommonCfg.activeWeekDay or nowDayWeek == 7) and recentDayWeek > timeDurationCommonCfg.timeCommonCfg.activeWeekDay then
              recentDayWeek = timeDurationCommonCfg.timeCommonCfg.activeWeekDay
              isRecentDayWeek = true
            end
            if nowDayWeek > timeDurationCommonCfg.timeCommonCfg.activeWeekDay and recentDayWeek2 < timeDurationCommonCfg.timeCommonCfg.activeWeekDay then
              recentDayWeek2 = timeDurationCommonCfg.timeCommonCfg.activeWeekDay
              isRecentDayWeek2 = true
            end
          end
        else
          isToday = true
          local beginTime = TimeCfgUtils.GetTimeSec(nowYear, nowMonth, nowDay, beginHour, beginMinute, 0)
          local duration = timeDurationCommonCfg.lastDay * 86400 + timeDurationCommonCfg.lastHour * 3600 + timeDurationCommonCfg.lastMinute * 60
          local endTime = beginTime + duration
          start = nowSec >= beginTime
          if start == false then
            if actCfg.recommendCount > 0 then
              GUIUtils.SetText(Label_Num, "0/" .. actCfg.recommendCount)
            end
            bComplete = false
          elseif bComplete == true then
            break
          end
          stop = nowSec > endTime
          inPeriod = start == true and stop == false
        end
        if isToday == true then
          if inPeriod == true then
            GUIUtils.SetActive(Label_Time, false)
            break
          else
            if start == false then
              local strStartTime = string.format("%02d:%02d", beginHour, beginMinute)
              GUIUtils.SetText(Label_Time, strStartTime)
              GUIUtils.SetActive(Label_Time, true)
              break
            end
            if stop == true then
              GUIUtils.SetText(Label_Time, textRes.activity[40])
              GUIUtils.SetActive(Label_Time, true)
            end
          end
        elseif isRecentDayWeek == true then
          GUIUtils.SetText(Label_Time, textRes.activity[recentDayWeek])
          GUIUtils.SetActive(Label_Time, true)
        elseif isRecentDayWeek2 == true then
          GUIUtils.SetText(Label_Time, textRes.activity[recentDayWeek2])
          GUIUtils.SetActive(Label_Time, true)
        end
      end
    end
    if actCfg.activityTimeCfgs and #actCfg.activityTimeCfgs == 0 then
      inPeriod = isInDate
    end
    GUIUtils.SetActive(Label_Time, isInDate == true and inPeriod == false)
    if 0 < actCfg.awardActiveTimes and 0 < actCfg.awardActiveValue and inPeriod == true and heroProp.level >= actCfg.levelMin and heroProp.level <= actCfg.levelMax then
      local times = activityInterface:GetActivityActiveTimes(actCfg.id)
      local value = 0
      if times >= 0 then
        value = actCfg.awardActiveValue * times
      end
      if times < 0 then
        times = 0
      end
    else
    end
    GUIUtils.SetActive(Btn_Join, inPeriod == true)
    break
  end
  if bComplete then
    Img_New:SetActive(false)
  end
  if bComplete == true or wordTip ~= "" then
    if wordTip == "" then
      Label_Time:GetComponent("UILabel"):set_text(textRes.activity[50])
    else
      Label_Time:GetComponent("UILabel"):set_text(wordTip)
    end
    GUIUtils.SetActive(Label_Time, true)
    GUIUtils.SetActive(Btn_Join, false)
  end
  local isForceOpen = activityInterface:isForceOpenActivity(actCfg.id)
  if isForceOpen then
    GUIUtils.SetActive(Label_Time, false)
    GUIUtils.SetActive(Btn_Join, true)
  end
end
def.method().UpdateActivity = function(self, activityId)
  if self._activityCfgList then
    for index, actCfg in ipairs(self._activityCfgList) do
      if actCfg.id == activityId then
        self:SetActivityListItem(index, actCfg)
      end
    end
  end
end
def.method().UpdateAwardList = function(self)
  self:ClearAwardList()
  self._awardItems = CarnivalData.Instance():GetCarnivalAwards(constant.ActivitiesGuidelineConsts.ACTIVITY_ID)
  local itemAmount = self._awardItems and #self._awardItems or nil
  if itemAmount <= 0 then
    return
  end
  itemAmount = math.min(itemAmount, CarnivalPanel.AWARD_MAX_SHOW_NUM)
  self._uiObjs.awardUIList.itemCount = itemAmount
  self._uiObjs.awardUIList:Resize()
  self._uiObjs.awardUIList:Reposition()
  for index, awardItemId in ipairs(self._awardItems) do
    if index <= itemAmount then
      self:SetAwardListItem(index, awardItemId)
    end
  end
end
def.method("number", "number").SetAwardListItem = function(self, index, itemId)
  local ItemUtils = require("Main.Item.ItemUtils")
  local itemBase = ItemUtils.GetItemBase(itemId)
  if nil == itemBase then
    warn("[ERROR][CarnivalPanel:SetAwardListItem] itemBase nil for awardItemId:", itemId)
    return
  end
  local listItem = self._uiObjs.List_Reward:FindDirect("item_" .. index)
  if nil == listItem then
    warn("[ERROR][CarnivalPanel:SetAwardListItem] listItem nil at index:", index)
    return
  end
  local Img_Icon = listItem:FindDirect("Img_Icon")
  GUIUtils.SetTexture(Img_Icon, itemBase.icon)
  local Img_Lv = listItem:FindDirect("Img_Lv")
  GUIUtils.SetSprite(Img_Lv, string.format("Cell_%02d", itemBase.namecolor))
  local Label_Number = listItem:FindDirect("Label_Number")
  GUIUtils.SetActive(Label_Number, false)
end
def.method().UpdateExchange = function(self)
  self:UpdateFragmentList()
  self:UpdateExchangeBtn()
end
def.method().UpdateExchangeBtn = function(self)
  local canExchange = CarnivalData.Instance():CanCarnivalExchange(constant.ActivitiesGuidelineConsts.ACTIVITY_ID)
  GUIUtils.EnableButton(self._uiObjs.Btn_Exchange, canExchange)
  GUIUtils.SetActive(self._uiObjs.Img_Red, canExchange)
  warn("[CarnivalData:UpdateExchangeBtn] enable Btn_Exchange:", canExchange)
end
def.method().UpdateFragmentList = function(self)
  self:ClearFragmentList()
  self._exchangeFragments = {}
  local exchangeCfgs = CarnivalData.Instance():GetCarnivalExchangeCfgs(constant.ActivitiesGuidelineConsts.ACTIVITY_ID)
  if exchangeCfgs and #exchangeCfgs > 0 then
    for index, exchangeCfg in ipairs(exchangeCfgs) do
      if exchangeCfg.itemList and #exchangeCfg.itemList then
        for _, itemInfo in ipairs(exchangeCfg.itemList) do
          local exchangeItemInfo = {}
          exchangeItemInfo.itemId = itemInfo.itemId
          exchangeItemInfo.itemNum = itemInfo.itemNum
          exchangeItemInfo.exchange_type = exchangeCfg.exchange_type
          table.insert(self._exchangeFragments, exchangeItemInfo)
        end
      end
    end
  end
  local itemAmount = self._exchangeFragments and #self._exchangeFragments or nil
  if itemAmount <= 0 then
    return
  end
  itemAmount = math.min(itemAmount, CarnivalPanel.EXCHANGE_MAX_SHOW_NUM)
  self._uiObjs.fragmentUIList.itemCount = itemAmount
  self._uiObjs.fragmentUIList:Resize()
  self._uiObjs.fragmentUIList:Reposition()
  for index, exchangeItemInfo in ipairs(self._exchangeFragments) do
    if index <= itemAmount then
      self:SetFragmentListItem(index, exchangeItemInfo)
    end
  end
end
def.method("number", "table").SetFragmentListItem = function(self, index, exchangeItemInfo)
  if nil == exchangeItemInfo then
    warn("[ERROR][CarnivalPanel:SetFragmentListItem] exchangeItemInfo nil for index:", index)
    return
  end
  local listItem = self._uiObjs.List_Fragment:FindDirect("item_" .. index)
  if nil == listItem then
    warn("[ERROR][CarnivalPanel:SetFragmentListItem] listItem nil at index:", index)
    return
  end
  local ItemUtils = require("Main.Item.ItemUtils")
  local ExchangeType = require("consts.mzm.gsp.exchange.confbean.ExchangeType")
  local itemData = require("Main.Item.ItemData").Instance()
  local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
  local itemId = exchangeItemInfo.itemId
  warn("[CarnivalPanel:SetFragmentListItem] exchangeItemInfo.itemId:", exchangeItemInfo.itemId)
  local count = 0
  local icon = 0
  if exchangeItemInfo.exchange_type == ExchangeType.USE_SAME_PRICE_ITEM_ID then
    local filterCfg = ItemUtils.GetItemFilterCfg(itemId)
    icon = filterCfg.icon
    for index, siftCfg in ipairs(filterCfg.siftCfgs) do
      count = count + itemData:GetNumberByItemId(BagInfo.BAG, siftCfg.idvalue)
    end
  else
    local itemBase = ItemUtils.GetItemBase(itemId)
    count = itemData:GetNumberByItemId(BagInfo.BAG, exchangeItemInfo.itemId)
    icon = itemBase.icon
  end
  local Img_IconCW = listItem:FindDirect("Img_IconCW")
  GUIUtils.SetTexture(Img_IconCW, icon)
  local Label_Num = listItem:FindDirect("Label_Tips")
  local numStr
  if count >= exchangeItemInfo.itemNum then
    numStr = string.format("[00ff00]%d[-]/%d", count, exchangeItemInfo.itemNum)
  else
    numStr = string.format("[ff0000]%d[-]/%d", count, exchangeItemInfo.itemNum)
  end
  Label_Num:GetComponent("UILabel"):set_text(numStr)
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Bth_Close" then
    self:DestroyPanel()
  elseif id == "Bth_Help" then
    self:OnBtn_Rule()
  elseif id == "Btn_Exchange" then
    self:OnBtn_Exchange()
  elseif string.find(id, "Btn_Join_") then
    self:OnBtn_Join(id)
  elseif string.find(id, "item_") then
    self:OnBtn_Award(clickObj)
  elseif string.find(id, "Img_Mg_") then
    self:OnActivityBGClick(id)
  elseif string.find(id, "Img_BgIcon_") then
    self:OnActivityIconClick(id)
  end
end
def.method().OnBtn_Rule = function(self)
  GUIUtils.ShowHoverTip(CarnivalData.Instance():GetCarnivalTipId(constant.ActivitiesGuidelineConsts.ACTIVITY_ID), 0, 0)
end
def.method().OnBtn_Exchange = function(self)
  require("Main.Exchange.ui.ExchangePanel").Instance():ShowPanelByActivityId(constant.ActivitiesGuidelineConsts.ACTIVITY_ID)
end
def.method("string").OnBtn_Join = function(self, id)
  local togglePrefix = "Btn_Join_"
  local index = tonumber(string.sub(id, string.len(togglePrefix) + 1))
  local actCfg = self._activityCfgList and self._activityCfgList[index]
  self:_DoJoinActivity(actCfg)
end
def.method("table")._DoJoinActivity = function(self, actCfg)
  if gmodule.moduleMgr:GetModule(ModuleId.HERO):IsInState(RoleState.ESCORT) then
    warn("[CarnivalPanel:_DoJoinActivity] join fail! hero in oleState.ESCORT.")
    return
  end
  if actCfg == nil then
    warn("[ERROR][CarnivalPanel:_DoJoinActivity] join fail! actCfg nil.")
    return
  end
  if not ActivityMain.Instance():IsSpecialActiviy(actCfg.id) then
    self:DestroyPanel()
  end
  local ECMSDK = require("ProxySDK.ECMSDK")
  ECMSDK.SendTLogToServer(_G.TLOGTYPE.JOINACTIVITY, {
    actCfg.id
  })
  if PlayerIsInFight() and not ActivityMain.Instance():isInFightCanJoin(actCfg.id) then
    Toast(textRes.activity[379])
    return
  end
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, {
    actCfg.id
  })
end
def.method("userdata").OnBtn_Award = function(self, clickObj)
  local id = clickObj.name
  local togglePrefix = "item_"
  local index = tonumber(string.sub(id, string.len(togglePrefix) + 1))
  local itemId, listItem
  local parentName = clickObj.parent.name
  if parentName == self._uiObjs.List_Reward.name then
    warn("[CarnivalData:OnBtn_Award] self._uiObjs.List_Reward item clicked.")
    itemId = self._awardItems and self._awardItems[index]
    listItem = self._uiObjs.List_Reward:FindDirect(id)
  elseif parentName == self._uiObjs.List_Fragment.name then
    warn("[CarnivalData:OnBtn_Award] self._uiObjs.List_Fragment item clicked.")
    local itemInfo = self._exchangeFragments and self._exchangeFragments[index]
    itemId = itemInfo and itemInfo.itemId
    listItem = self._uiObjs.List_Fragment:FindDirect(id)
  else
    warn("[CarnivalData:OnBtn_Award] clickObj.parent:", clickObj.parent.name)
  end
  if itemId and itemId > 0 and listItem then
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, listItem, 0, false)
  end
end
def.method("string").OnActivityBGClick = function(self, id)
  local togglePrefix = "Img_Mg_"
  local index = tonumber(string.sub(id, string.len(togglePrefix) + 1))
  local actCfg = self._activityCfgList and self._activityCfgList[index]
  self:_ShowActivityTip(actCfg)
end
def.method("string").OnActivityIconClick = function(self, id)
  local togglePrefix = "Img_BgIcon_"
  local index = tonumber(string.sub(id, string.len(togglePrefix) + 1))
  local actCfg = self._activityCfgList and self._activityCfgList[index]
  self:_ShowActivityTip(actCfg)
end
def.method("table")._ShowActivityTip = function(self, actCfg)
  if actCfg == nil then
    warn("[ERROR][CarnivalPanel:_ShowActivityTip] actCfg nil at index:", index)
    return
  end
  local activityID = actCfg.id
  local activityTip = require("Main.activity.ui.ActivityTip").Instance()
  if activityTip:IsShow() == false then
    if activityID > 0 then
      activityTip:SetActivityID(activityID)
      activityTip:ShowDlg()
    end
  else
    activityTip:HideDlg()
  end
end
def.method("boolean").HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
    eventFunc(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_ListChanged, CarnivalPanel.OnActivityListChanged)
    eventFunc(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_InfoChanged, CarnivalPanel.OnActivityInfoChanged)
    eventFunc(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, CarnivalPanel.OnActivityStart)
    eventFunc(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_End, CarnivalPanel.OnActivityEnd)
    eventFunc(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Active_Changed, CarnivalPanel.OnActiveChanged)
    eventFunc(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Active_Award_Chged, CarnivalPanel.OnActiveAwardChged)
    eventFunc(ModuleId.ACTIVITY, gmodule.notifyId.activity.Special_Activity_Change, CarnivalPanel.OnSpecialActiveChanged)
    eventFunc(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, CarnivalPanel.OnActivityListReset)
    eventFunc(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Refresh_RedPoint, CarnivalPanel.OnSetActivityRedPoint)
    eventFunc(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, CarnivalPanel.OnHeroLevelUp)
    eventFunc(ModuleId.EXCHANGE, gmodule.notifyId.Exchange.EXCHANGE_RED_POINT_CHANGE, CarnivalPanel.OnExchangeInfoChange)
    eventFunc(ModuleId.CARNIVAL, gmodule.notifyId.CARNIVAL.CARNIVAL_REDDOT_UPDATE, CarnivalPanel.OnReddotChange)
    eventFunc(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, CarnivalPanel.OnFunctionOpenChange)
  end
end
def.static("table", "table").OnActivityListChanged = function(p1, p2)
  if instance:IsShow() then
    instance:UpdateActivityList()
  end
end
def.static("table", "table").OnActivityInfoChanged = function(p1, p2)
  local activityID = p1[1]
  if instance:IsShow() == true and activityID ~= 0 then
    instance:UpdateActivity(activityID)
  end
end
def.static("table", "table").OnActivityStart = function(activityIDs, p2)
  local self = instance
  if self:IsShow() == false then
    return
  end
  if self._activityCfgList == nil then
    self:UpdateActivityList()
  end
  local IDs = {}
  for idx, id in pairs(activityIDs) do
    IDs[id] = id
  end
  for idx, cfg in pairs(self._activityCfgList) do
    if IDs[cfg.id] ~= nil then
      self:SetActivityListItem(idx, cfg)
    end
  end
end
def.static("table", "table").OnActivityEnd = function(activityIDs, p2)
  local self = instance
  if self:IsShow() == false then
    return
  end
  if self._activityCfgList == nil then
    self:UpdateActivityList()
  end
  local IDs = {}
  for idx, id in pairs(activityIDs) do
    IDs[id] = id
  end
  for idx, cfg in pairs(self._activityCfgList) do
    if IDs[cfg.id] ~= nil then
      self:SetActivityListItem(idx, cfg)
    end
  end
end
def.static("table", "table").OnActiveChanged = function(p1, p2)
  local self = instance
  if self:IsShow() == true then
    self:UpdateActivityList()
  end
end
def.static("table", "table").OnActiveAwardChged = function(p1, p2)
  local self = instance
  if self:IsShow() == true then
    self:UpdateActivityList()
  end
end
def.static("table", "table").OnSpecialActiveChanged = function(p1, p2)
  local self = instance
  if self:IsShow() then
    self:UpdateActivityList()
  end
end
def.static("table", "table").OnActivityListReset = function(p1, p2)
  local self = instance
  if self:IsShow() then
    if not self._isNeedRefreshList then
      GameUtil.AddGlobalTimer(2, true, function()
        if self.m_panel then
          self:UpdateActivityList()
          self._isNeedRefreshList = false
        end
      end)
    end
    self._isNeedRefreshList = true
  end
end
def.static("table", "table").OnSetActivityRedPoint = function()
  if instance then
    instance:UpdateActivityList()
  end
end
def.static("table", "table").OnHeroLevelUp = function(p1, p2)
  if instance then
    instance:UpdateActivityList()
  end
end
def.static("table", "table").OnExchangeInfoChange = function()
  if instance then
    instance:UpdateFragmentList()
  end
end
def.static("table", "table").OnReddotChange = function()
  if instance then
    instance:UpdateExchange()
  end
end
def.static("table", "table").OnFunctionOpenChange = function()
  if instance then
    instance:UpdateActivityList()
  end
end
CarnivalPanel.Commit()
return CarnivalPanel
