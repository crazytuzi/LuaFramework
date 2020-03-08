local Lplus = require("Lplus")
local ActivityProtocols = Lplus.Class("ActivityProtocols")
local def = ActivityProtocols.define
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
local ThumbsupMgr = require("Main.activity.thumbsup.ThumbsupMgr")
local thumbsupMgr = ThumbsupMgr.Instance()
local UseType = require("consts.mzm.gsp.giftaward.confbean.UseType")
def.static("table").OnSAcceptCircleTaskRes = function(p)
  Toast(string.format(textRes.activity[86]))
end
def.static("table").OnSisContinueZhenyao = function(p)
  local protocolsCache = require("Main.Common.ProtocolsCache").Instance()
  if protocolsCache:CacheProtocol(ActivityProtocols.OnSisContinueZhenyao, p) == true then
    return
  end
  local ECSoundMan = require("Sound.ECSoundMan")
  ECSoundMan.Instance():Play2DInterruptSoundByID(constant.ZhenYaoActivityCfgConsts.ZhenYao_MUSIC_TIP_FOR_LEADER)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirmCoundDown(textRes.activity[87], textRes.activity[88], textRes.Login[105], textRes.Login[106], 1, 30, ActivityProtocols.OnContinueZhenyaoConfirm, {self})
end
def.static("number", "table").OnContinueZhenyaoConfirm = function(id, tag)
  if id == 1 then
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, {
      constant.ZhenYaoActivityCfgConsts.ZhenYao_ACTIVITY_ID
    })
  end
end
def.static("table").OnSShimenDayPerfectAward = function(p)
  local str = textRes.activity[92]
  local awardInfo = p.awardBean
  local personAward = {}
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  table.insert(personAward, {
    PersonalHelper.Type.Text,
    str
  })
  if awardInfo.yuanbao and awardInfo.yuanbao:gt(0) then
    table.insert(personAward, {
      PersonalHelper.Type.Yuanbao,
      awardInfo.yuanbao
    })
  end
  if 0 < awardInfo.roleExp then
    table.insert(personAward, {
      PersonalHelper.Type.RoleExp,
      awardInfo.roleExp
    })
  end
  if awardInfo.gold and awardInfo.gold:gt(0) then
    table.insert(personAward, {
      PersonalHelper.Type.Gold,
      awardInfo.gold
    })
  end
  if awardInfo.silver and awardInfo.silver:gt(0) then
    table.insert(personAward, {
      PersonalHelper.Type.Silver,
      awardInfo.silver
    })
  end
  if awardInfo.itemMap and next(awardInfo.itemMap) then
    table.insert(personAward, {
      PersonalHelper.Type.Text,
      ","
    })
    table.insert(personAward, {
      PersonalHelper.Type.ItemMap,
      awardInfo.itemMap
    })
  end
  if awardInfo.petExpMap and next(awardInfo.petExpMap) then
    table.insert(personAward, {
      PersonalHelper.Type.Text,
      ","
    })
    table.insert(personAward, {
      PersonalHelper.Type.Text,
      textRes.Common[151]
    })
    table.insert(personAward, {
      PersonalHelper.Type.PetExpMap,
      awardInfo.petExpMap
    })
  end
  if #personAward > 1 then
    PersonalHelper.CommonTableMsg(personAward)
  end
end
def.static("table").OnSShimenWeekPerfectAward = function(p)
  local str = textRes.activity[93]
  local awardInfo = p.awardBean
  local personAward = {}
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  table.insert(personAward, {
    PersonalHelper.Type.Text,
    str
  })
  if awardInfo.yuanbao and awardInfo.yuanbao:gt(0) then
    table.insert(personAward, {
      PersonalHelper.Type.Yuanbao,
      awardInfo.yuanbao
    })
  end
  if 0 < awardInfo.roleExp then
    table.insert(personAward, {
      PersonalHelper.Type.RoleExp,
      awardInfo.roleExp
    })
  end
  if awardInfo.gold and awardInfo.gold:gt(0) then
    table.insert(personAward, {
      PersonalHelper.Type.Gold,
      awardInfo.gold
    })
  end
  if awardInfo.silver and awardInfo.silver:gt(0) then
    table.insert(personAward, {
      PersonalHelper.Type.Silver,
      awardInfo.silver
    })
  end
  if awardInfo.itemMap and next(awardInfo.itemMap) then
    table.insert(personAward, {
      PersonalHelper.Type.Text,
      ","
    })
    table.insert(personAward, {
      PersonalHelper.Type.ItemMap,
      awardInfo.itemMap
    })
  end
  if awardInfo.petExpMap and next(awardInfo.petExpMap) then
    table.insert(personAward, {
      PersonalHelper.Type.Text,
      ","
    })
    table.insert(personAward, {
      PersonalHelper.Type.Text,
      textRes.Common[151]
    })
    table.insert(personAward, {
      PersonalHelper.Type.PetExpMap,
      awardInfo.petExpMap
    })
  end
  if #personAward > 1 then
    PersonalHelper.CommonTableMsg(personAward)
  end
end
def.static("table").OnSSyncLegendTime = function(p)
  local TaskInterface = require("Main.task.TaskInterface")
  local taskInterface = TaskInterface.Instance()
  if p.endTime:eq(0) then
    taskInterface:_SetLegendTime(p.taskId, p.graphId, nil)
  else
    local endTime = p.endTime:div(1000)
    taskInterface:_SetLegendTime(p.taskId, p.graphId, endTime)
  end
  Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_InfoChanged, {
    p.taskId,
    p.graphId
  })
end
def.static("table").OnSSyncLegendTimeReward = function(p)
  local itemMap = {}
  itemMap[p.itemId] = p.itemNum
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.Common[150], PersonalHelper.Type.ItemMap, itemMap)
end
def.static("table").OnSCircleTaskNormalResult = function(p)
  warn("----OnSCircleTaskNormalResult:", p.result)
  local str = textRes.activity.CircleTaskNormalResult[p.result]
  if str then
    Toast(str)
  end
end
def.static("table").OnSSyncRenXingYiXiaCount = function(p)
  activityInterface:_SetRexXingCount(p.count)
end
def.static("table").OnSynActivityChangeRes = function(p)
  activityInterface:SetActivityInfo(p.activityInfo.actvityId, p.activityInfo.count, p.activityInfo.awarded, p.activityInfo.clearTime:ToNumber())
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_InfoChanged, {
    p.activityInfo.actvityId
  })
  gmodule.moduleMgr:GetModule(ModuleId.DUNGEON):UpdateDungeonNum(p.activityInfo.actvityId, p.activityInfo.count)
  SafeLuckDog(function()
    return p.activityInfo.actvityId == 350000006 and (p.activityInfo.count == 100 or p.activityInfo.count == 200)
  end)
end
def.static("table").OnSynActivityInitRes = function(p)
  local curTime = GetServerTime()
  for i, data in pairs(p.activityInfos) do
    activityInterface:SetActivityInfo(data.actvityId, data.count, data.awarded, data.clearTime:ToNumber())
    local cfg = ActivityInterface.GetActivityCfgById(data.actvityId)
    if data.count > 0 then
      local openTime, activeTimeList, closeTime = activityInterface:getActivityStatusChangeTime(data.actvityId)
      local isStart = activityInterface:isForceOpenActivity(data.actvityId)
      if not isStart then
        for _, v in ipairs(activeTimeList) do
          if curTime >= v.beginTime and curTime < v.resetTime then
            isStart = true
            break
          end
        end
      end
      if not isStart then
        if cfg.bigReset then
          local clearTime = activityInterface:getBigTurnActivityClearTime(data.actvityId)
          if curTime >= clearTime then
            activityInterface:SetActivityInfoCount(data.actvityId, 0)
          end
        else
          activityInterface:SetActivityInfoCount(data.actvityId, 0)
        end
      end
    end
  end
  activityInterface:RefreshActivityList()
end
def.static("table").OnSynLimitTimeActivityOpened = function(p)
  activityInterface._activityInPeriod = p.activityids
end
def.static("table").OnSynActivityStart = function(p)
  local ActivityType = require("consts.mzm.gsp.activity.confbean.ActivityType")
  local cfg = ActivityInterface.GetActivityCfgById(p.activityid)
  activityInterface:displayActivityTip(p.activityid, false)
  if cfg ~= nil and cfg.activityType == ActivityType.Daily then
    return
  end
  if cfg.activityType == ActivityType.TimeLimit then
    activityInterface._activityInPeriod[p.activityid] = p.activityid
    local weekly = activityInterface:GetWeeklyActivityList()
    for idx, cfg in pairs(weekly) do
      if cfg.id == p.activityid then
        activityInterface._newActivitiesSet[p.activityid] = p.activityid
        table.insert(activityInterface._newActivitiesVector, p.activityid)
        activityInterface._newTimeOpenActivitiesSet[p.activityid] = p.activityid
        table.insert(activityInterface._newTimeOpenActivitiesVector, p.activityid)
        break
      end
    end
  end
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, {
    p.activityid
  })
end
def.static("table").OnSynActivityEnd = function(p)
  activityInterface._activityInPeriod[p.activityid] = nil
  activityInterface._newActivitiesSet[p.activityid] = nil
  local oldList = activityInterface._newActivitiesVector
  activityInterface._newActivitiesVector = {}
  for idx, id in pairs(oldList) do
    if p.activityid ~= id then
      table.insert(activityInterface._newActivitiesVector, id)
    end
  end
  activityInterface._newTimeOpenActivitiesSet[p.activityid] = nil
  local newlist = {}
  for i = 1, #activityInterface._newTimeOpenActivitiesVector do
    if activityInterface._newTimeOpenActivitiesVector[i] ~= p.activityid then
      table.insert(newlist, activityInterface._newTimeOpenActivitiesVector[i])
    end
  end
  activityInterface._newTimeOpenActivitiesVector = newlist
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_End, {
    p.activityid
  })
end
def.static("table").OnSNoBaoTuRes = function(p)
  local protocolsCache = require("Main.Common.ProtocolsCache").Instance()
  if protocolsCache:CacheProtocol(ActivityProtocols.OnSNoBaoTuRes, p) == true then
    return
  end
  Toast(string.format(textRes.activity[150]))
end
def.static("table").OnSResItemYuanbaoPrice = function(p)
  local NpcExchangePanel = require("Main.Exchange.ui.NpcExchangePanel")
  local npcExchangePanel = NpcExchangePanel.Instance()
  if npcExchangePanel:IsShow() then
    npcExchangePanel:OnSyncItemPrice(p.itemid2yuanbao)
  end
end
def.static("table").OnBaotuAdvancedExchangeCallback = function(param)
  if param ~= nil then
    param[1]()
  end
end
def.static("number", "table").OnBaotuAdvancedExchangeConfirm = function(id, tag)
  if id == 1 then
    local allUUIDs = tag[1]
    local exchangeID = tag[2]
    local uuid = allUUIDs[1]
    if uuid == nil then
      uuid = Int64.new(-1)
    end
    local p = require("netio.protocol.mzm.gsp.item.CExchangeUseItem").new(exchangeID, uuid)
    gmodule.network.sendProtocol(p)
    activityInterface.npcExchangeItemId = 0
  end
end
def.static("table").OnSDoublePointTip = function(p)
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_DoubleTip, nil)
end
def.static("table").OnSActivityEndTimeResp = function(p)
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_QueryEndingTimeFromServerRes, {
    p.activityId,
    p.endTime
  })
end
def.static("table").OnSActivityStageEndTimeRes = function(p)
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_QueryPhaseFromServerRes, {
    p.activityId,
    p.stage,
    p.endTime
  })
end
def.static("table").OnSSynZheyaoCount = function(p)
  activityInterface._singleCount = p.singleCount
  activityInterface._doubleCount = p.doubleCount
end
def.static("table").OnSCurrentWeekCannotAccept = function(p)
  Toast(string.format(textRes.activity[320]))
end
def.static("table").OnSGangeTaskNormalResult = function(p)
  Toast(textRes.activity.GangeTaskNormalResult[p.result])
end
def.static("table").OnSSeasonNormalResult = function(p)
  local SeasonNormalResult = require("netio.protocol.mzm.gsp.activity.SSeasonNormalResult")
  if p.result == SeasonNormalResult.JOIN_ACTIVITY_MULTI_ERROR__NOT_ENOUGH_PEOPLE then
    Toast(string.format(textRes.activity.SeasonNormalResult[p.result], p.args[1]))
  else
    Toast(textRes.activity.SeasonNormalResult[p.result])
  end
end
def.static("table").OnSZheyaoAwardCountToMaxRes = function(p)
  Toast(textRes.activity[342])
end
def.static("table").OnSTmpActivityNormalResult = function(p)
  warn("+++++++++++++++OnSTmpActivityNormalResult=========", p.result)
  local msg = textRes.activity.ZhongQiuResult[p.result]
  if msg then
    Toast(msg)
  end
end
def.static("table").OnSStartLotteryViewRes = function(p)
  if p.itemnum > 0 then
    require("Main.activity.ui.ShimenLottery").Instance():ShowPanel(p.finalIndex, p.itemid, p.itemnum)
  end
end
def.static("table").OnSSyncTreasureBoxActivityLeftTime = function(p)
  local FeatureType = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
  local open = feature:CheckFeatureOpen(FeatureType.TYPE_ONLINE_GIVE_AWARD)
  if not open then
    warn("!!!!!!!!!!OnlineBox not open")
    return
  end
  local activityTime = p.endLeftTime - p.startLeftTime
  if p.startLeftTime > 0 then
    do
      local AnnouncementTip = require("GUI.AnnouncementTip")
      local ChatModule = require("Main.Chat.ChatModule")
      local HtmlHelper = require("Main.Chat.HtmlHelper")
      local ChatMsgData = require("Main.Chat.ChatMsgData")
      if p.startLeftTime >= 295 and p.startLeftTime <= 305 then
        local str = string.format(textRes.activity[372], 5)
        AnnouncementTip.Announce(str)
        ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
      end
      if p.startLeftTime >= 60 then
        GameUtil.AddGlobalTimer(p.startLeftTime - 60, true, function()
          local str = string.format(textRes.activity[372], 1)
          AnnouncementTip.Announce(str)
          ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = str})
        end)
      end
      GameUtil.AddGlobalTimer(p.startLeftTime, true, function()
        if IsEnteredWorld() then
          activityInterface:getOnlineAwardExpStart(activityTime)
        end
      end)
    end
  elseif activityTime > 0 then
    activityInterface:getOnlineAwardExpStart(activityTime)
  end
end
def.static("table").OnSSyncTreasureBoxActivityStartRes = function(p)
  local FeatureType = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
  local open = feature:CheckFeatureOpen(FeatureType.TYPE_ONLINE_GIVE_AWARD)
  if not open then
    warn("!!!!!!!!!!OnlineBox not open")
    return
  end
  local sec = math.random(1, 5)
  GameUtil.AddGlobalTimer(sec, true, function()
    local OnlineBox = require("Main.activity.ui.OnlineAwardBox")
    OnlineBox.Instance():ShowDlg()
  end)
end
def.static("table").OnSSendAwardPoolRes = function(p)
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
  for i, v in pairs(p.awardMoney) do
    if v > 0 then
      if i == p.MONEY_YUANBAO then
        PersonalHelper.GetMoneyMsgByType(MoneyType.YUANBAO, v .. "")
      elseif i == p.MONEY_GOLD then
        PersonalHelper.GetMoneyMsgByType(MoneyType.GOLD, v .. "")
      elseif i == p.MONEY_SILVER then
        PersonalHelper.GetMoneyMsgByType(MoneyType.SILVER, v .. "")
      end
    end
  end
  for i, v in pairs(p.awardItems) do
    PersonalHelper.GetItemMsg(i, v)
  end
end
def.static("table").OnSSynMoshouExchangeCountRes = function(p)
  if p.canExchangeMoshou > 0 then
    activityInterface._canExchangeMoshou = true
  else
    activityInterface._canExchangeMoshou = false
  end
end
def.static("table").OnSUseMoshuFragmentRes = function(p)
end
def.static("table").OnSCommonErrorInfo = function(p)
  if p.errorCode == p.MOSHOU_EXCAHNGE_COUNT_ERROR then
    Toast(textRes.activity[378])
  elseif p.errorCode == p.EXCHANGE_ITEM_NEED_YUANBAO_COUNT_EEEOR then
    Toast(textRes.activity[400])
    local NpcExchangePanel = require("Main.Exchange.ui.NpcExchangePanel")
    local npcExchangePanel = NpcExchangePanel.Instance()
    if npcExchangePanel:IsShow() then
      npcExchangePanel:reqItemYubaoPrice()
    end
  end
end
def.static("table").OnSynActivitySpecialControlRes = function(p)
  warn("-------OnSynActivitySpecialControlRes")
  for _, v in ipairs(p.specialControlDatas) do
    if v.openState ~= 0 then
      activityInterface:setSpecialActivity(v.actvityId, v.openState, v.endTime:ToNumber())
    end
  end
end
def.static("table").OnSynActivitySpecialControlChangeRes = function(p)
  local info = p.specialControlData
  warn("--------OnSynActivitySpecialControlChangeRes")
  activityInterface:setSpecialActivity(info.actvityId, info.openState, info.endTime:ToNumber())
  activityInterface:RefreshActivityList()
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Special_Activity_Change, {
    info.actvityId
  })
end
def.static("table").OnSFinishGangTaskeNotice = function(p)
  local str = textRes.activity[385]
  local awardInfo = require("Main.Award.AwardUtils").GetHtmlTextsFromAwardBean(p.targetAwardBean, str)
  for _, v in ipairs(awardInfo) do
    require("Main.Chat.PersonalHelper").SendOut(v)
  end
end
def.static("table").OnSSingleTaskNormalRes = function(p)
  warn("!!!!!!!OnSSingleTaskNormalRes:", p.result)
  if p.result == p.ALREADY_OWN_GRAPH then
    Toast(textRes.activity[389])
  end
end
def.static("table").OnSGetGiftRep = function(p)
  warn("[ActivityProtocols:OnSGetGiftRep] receive SGetGiftRep:", p.useType, p.alCount)
  if UseType.FACE_BOOK__PRAISE == p.useType then
    thumbsupMgr:SetThumbsupCount(p.alCount)
  elseif UseType.JIERI_SHARE__GUOQING == p.useType then
    activityInterface:SetActivityInfoCount(constant.CNationalHolidayConst.NATIONAL_HOLIDAY_SHARE_ID, p.alCount)
  end
end
def.static("table").OnSCanGetGifts = function(p)
  warn("[ActivityProtocols:OnSCanGetGifts] receive SCanGetGifts.useTypeInfo[UseType.FACE_BOOK__PRAISE]:", p.useTypeInfo[UseType.FACE_BOOK__PRAISE])
  thumbsupMgr:SetThumbsupCount(p.useTypeInfo[UseType.FACE_BOOK__PRAISE] or 0)
end
def.static("table").OnSCanGetGiftAward = function(p)
  warn("[ActivityProtocols:OnSCanGetGiftAward] receive SCanGetGiftAward:", giftAwardCfgIds)
end
ActivityProtocols.Commit()
return ActivityProtocols
