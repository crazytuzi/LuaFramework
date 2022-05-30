require("data.data_error_error")
local LuckyPoolLayer = class("LuckyPoolLayer", function()
  return require("utility.ShadeLayer").new()
end)
local LuckyType = {commonType = 1, supperType = 2}
local LuckyShopType = {cardType = 1, petType = 2}
local LuckyCostType = {pointType = 1, moneyType = 2}
function LuckyPoolLayer:ctor(param)
  self._scheduler = require("framework.scheduler")
  self._curInfoIndex = -1
  self._state = -1
  self._withData = false
  local viewSize = param.viewSize
  local proxy = CCBProxy:create()
  self._rootnode = {}
  local node = CCBuilderReaderLoad("nbhuodong/lucky_pool_layer.ccbi", proxy, self._rootnode, self, viewSize)
  self:addChild(node)
  self._rootnode.btn_rankList:addHandleOfControlEvent(function(eventName, sender)
    self:rankClick()
  end, CCControlEventTouchUpInside)
  local function func()
    self:setTimeStr(param)
    self._type = LuckyType.supperType
    self:initView()
    self:changePageByType(LuckyType.supperType)
  end
  self:getBaseData(func)
end
function LuckyPoolLayer:initView()
  self:resetPoint()
  if self._shopType == LuckyShopType.cardType then
    self._rootnode.time_lbl:setString(common:getLanguageString("@Luckysm1"))
  else
    self._rootnode.time_lbl:setString(common:getLanguageString("@Luckysm2"))
  end
  if self._costType == LuckyCostType.pointType then
    self._rootnode.middleNode:setVisible(true)
  else
    self._rootnode.middleNode:setVisible(false)
  end
  self._countDownTime = GameModel.getRestTimeInMS(self.activityEndTime)
  self._rootnode.timeCountDown:setString(self:timeFormat(self._countDownTime))
  self._rootnode.btn_dis:addHandleOfControlEvent(function(eventName, sender)
    local type = 13
    if self._costType == LuckyCostType.pointType then
      if self._shopType == LuckyShopType.cardType then
        type = 12
      end
    else
      type = 39
    end
    local layer = require("game.SplitStove.SplitDescLayer").new(type)
    CCDirector:sharedDirector():getRunningScene():addChild(layer, 100)
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
  end, CCControlEventTouchUpInside)
  local function countDown()
    self._countDownTime = GameModel.getRestTimeInMS(self.activityEndTime)
    if self._countDownTime <= 0 then
      self._scheduler.unscheduleGlobal(self._scheduleTime)
      self._scheduleTime = nil
      self._rootnode.timeCountDown:setString(common:getLanguageString("@ActivityOver"))
      show_tip_label(common:getLanguageString("@ActivityOver"))
    else
      self._rootnode.timeCountDown:setString(self:timeFormat(self._countDownTime))
    end
  end
  self._scheduleTime = self._scheduler.scheduleGlobal(countDown, 1, false)
  self:TurntableSystem()
  self._rootnode.btn_common:addHandleOfControlEvent(function(eventName, event)
    self:changePageByType(LuckyType.commonType)
  end, CCControlEventTouchUpInside)
  self._rootnode.btn_supper:addHandleOfControlEvent(function(eventName, event)
    self:changePageByType(LuckyType.supperType)
  end, CCControlEventTouchUpInside)
  self.commomIndex = 1
  self.supperIndex = 1
  self:reSetButtonState()
  self._rootnode.btn_charge:addHandleOfControlEvent(function(eventName, sender)
    if self._costType == LuckyCostType.pointType then
      if self._point >= self._cost[self._type] then
        local loadingLayer = require("utility.LoadingLayer")
        loadingLayer.start(0.1)
        self:getLuckGetItem({
          actType = self._type,
          callback = function(data)
            dump(data)
            self._rootnode.btn_charge:setEnabled(false)
            if data["0"] ~= "" then
              dump(data["0"])
            else
              self:extract(data.rtnObj.index, data.rtnObj.getItem)
              self._point = data.rtnObj.point
              self:reSetButtonState()
              self:resetPoint()
            end
          end
        })
      else
        self:gotoZhaoMu()
      end
    elseif game.player:getGold() >= self._cost[self._type] then
      local loadingLayer = require("utility.LoadingLayer")
      loadingLayer.start(0.1)
      self:getLuckGetItem({
        actType = self._type,
        callback = function(data)
          self._rootnode.btn_charge:setEnabled(false)
          if data["0"] ~= "" then
            dump(data["0"])
          else
            self:extract(data.rtnObj.index, data.rtnObj.getItem)
            game.player:setGold(game.player:getGold() - self._cost[self._type])
            self:reSetButtonState()
            self:resetPoint()
          end
        end
      })
    else
      local tips = common:getLanguageString("@PriceEnough")
      show_tip_label(tips)
    end
  end, CCControlEventTouchUpInside)
  if self._costType == LuckyCostType.moneyType then
    self._rootnode.lucky_probar_node:setVisible(false)
    self._rootnode.goldNode:setVisible(true)
  else
    self._rootnode.lucky_probar_node:setVisible(true)
    self._rootnode.goldNode:setVisible(false)
  end
end
function LuckyPoolLayer:resetPoint()
  if self._costType == LuckyCostType.pointType then
    self._rootnode.mValue:setString(tostring(self._point) .. "/" .. self._cost[self._type])
    local percent = self._point / self._cost[self._type]
    if percent > 1 then
      percent = 1
    end
    local normalBar = self._rootnode.energyBg
    local bar = self._rootnode.energy
    local rotated = false
    if bar:isTextureRectRotated() == true then
      rotated = true
    end
    bar:setTextureRect(CCRectMake(bar:getTextureRect().origin.x, bar:getTextureRect().origin.y, normalBar:getContentSize().width * percent, bar:getTextureRect().size.height), rotated, CCSizeMake(normalBar:getContentSize().width * percent, normalBar:getContentSize().height * percent))
  else
    self._rootnode.goldLabel:setString(self._cost[self._type])
  end
end
function LuckyPoolLayer:gotoZhaoMu()
  if self._shopType == LuckyShopType.cardType then
    GameStateManager:ChangeState(GAME_STATE.STATE_SHOP)
  else
    local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.TianJiangMengChong, game.player:getLevel(), game.player:getVip())
    if not bHasOpen then
      show_tip_label(prompt)
      return
    end
    local scene = require("game.nbactivity.ActivityScene").new(nbActivityShowType.chongwuchouka)
    display.replaceScene(scene)
  end
end
function LuckyPoolLayer:reSetButtonState()
  local btnState = {
    CCControlStateNormal,
    CCControlStateHighlighted,
    CCControlStateDisabled,
    CCControlStateSelected
  }
  if self._costType == LuckyCostType.pointType then
    if self._point >= self._cost[self._type] then
      for k, state in pairs(btnState) do
        self._rootnode.btn_charge:setTitleForState(CCString:create(common:getLanguageString("@Luckycq")), state)
      end
    else
      for k, state in pairs(btnState) do
        self._rootnode.btn_charge:setTitleForState(CCString:create(common:getLanguageString("@Luckyqzm")), state)
      end
    end
  else
    for k, state in pairs(btnState) do
      self._rootnode.btn_charge:setTitleForState(CCString:create(common:getLanguageString("@Luckycq")), state)
    end
  end
end
function LuckyPoolLayer:extract(index, rewardData)
  local tempIndex
  if self._type == LuckyType.commonType then
    tempIndex = self.commomIndex
  else
    tempIndex = self.supperIndex
  end
  local MAX_NUM = 30
  local dstIndex = MAX_NUM + index - tempIndex
  local step = 1
  local time = 0.08
  local runAct
  function runAct()
    tempIndex = tempIndex + 1
    self:changeBox(tempIndex)
    self._scheduler.unscheduleGlobal(self._schedulerExtract)
    if step < dstIndex * 0.3 then
      time = time - 0.01
    elseif step > dstIndex * 0.7 then
      time = time + 0.025
    end
    if step < dstIndex then
      time = time
      step = step + 1
      self._schedulerExtract = self._scheduler.scheduleGlobal(runAct, time, false)
    else
      self._rootnode.btn_charge:setEnabled(true)
      if self._type == LuckyType.commonType then
        self.commomIndex = tempIndex % 10
      else
        self.supperIndex = tempIndex % 10
      end
      self._scheduler.performWithDelayGlobal(function()
        local itemData = {}
        dump(rewardData)
        for k, v in pairs(rewardData) do
          local item = ResMgr.getRefreshIconItem(v.id, v.type)
          item.num = v.num or 0
          table.insert(itemData, item)
        end
        local title = common:getLanguageString("GetRewards")
        local msgBox = require("game.Huodong.RewardMsgBox").new({title = title, cellDatas = itemData})
        self:addChild(msgBox, 100000)
      end, 0.5)
    end
  end
  self._schedulerExtract = self._scheduler.scheduleGlobal(runAct, time, false)
end
function LuckyPoolLayer:changeBox(index)
  local itemData
  if self._type == LuckyType.commonType then
    itemData = self.itemCellData
  else
    itemData = self.itemCellData2
  end
  local SUM_NUM = #itemData
  local num = index % SUM_NUM
  local lastnum = num - 1
  if num == 0 then
    num = SUM_NUM
    lastnum = 9
  elseif num == 1 then
    lastnum = SUM_NUM
  end
  itemData[num]:changeBox(true)
  itemData[lastnum]:changeBox(false)
end
function LuckyPoolLayer:TurntableSystem()
  self.itemCellData = {}
  self.itemCellData2 = {}
  local goodsPanel = self._rootnode.goodsPanel
  goodsPanel:setVisible(false)
  local goodsPanelHeight = goodsPanel:getContentSize().height
  local MAX_LINE = 5
  local OFFSET_X = 8
  local OFFSET_Y = 8
  for i = 0, 1 do
    for j = 1, MAX_LINE do
      local index = i * MAX_LINE + j
      local itemCell = require("game.nbactivity.LuckyPool.LuckyPoolItem").new({
        itemData = self._bonus[index]
      })
      if i == 1 then
        itemCell:setPosition((MAX_LINE - j) * itemCell:getContentSize().width + OFFSET_X, goodsPanelHeight / 2 - i * itemCell:getContentSize().height - OFFSET_Y)
      else
        itemCell:setPosition((j - 1) * itemCell:getContentSize().width + OFFSET_X, goodsPanelHeight / 2 - i * itemCell:getContentSize().height)
      end
      table.insert(self.itemCellData, itemCell)
      self:addTouchShowView(itemCell, index)
      goodsPanel:addChild(itemCell)
    end
  end
  local goodsPanel_2 = self._rootnode.goodsPanel_2
  goodsPanel_2:setVisible(false)
  for i = 2, 3 do
    for j = 1, MAX_LINE do
      local index = i * MAX_LINE + j
      local itemCell = require("game.nbactivity.LuckyPool.LuckyPoolItem").new({
        itemData = self._bonus[index]
      })
      if i == 3 then
        itemCell:setPosition((MAX_LINE - j) * itemCell:getContentSize().width + OFFSET_X, goodsPanelHeight / 2 - (i - 2) * itemCell:getContentSize().height - OFFSET_Y)
      else
        itemCell:setPosition((j - 1) * itemCell:getContentSize().width + OFFSET_X, goodsPanelHeight / 2 - (i - 2) * itemCell:getContentSize().height)
      end
      table.insert(self.itemCellData2, itemCell)
      self:addTouchShowView(itemCell, index)
      goodsPanel_2:addChild(itemCell)
    end
  end
end
function LuckyPoolLayer:addTouchShowView(itemCell, index)
  addTouchListener(itemCell, function(sender, eventType)
    if eventType == EventType.began then
      local tempData = self._bonus[index]
      local itemData = ResMgr.getRefreshIconItem(tempData.id, tempData.type)
      itemData.num = tempData.num or 0
      local itemInfo = require("game.Huodong.ItemInformation").new({
        id = itemData.id,
        type = itemData.type,
        name = itemData.name,
        describe = itemData.describe,
        endFunc = function()
        end
      })
      CCDirector:sharedDirector():getRunningScene():addChild(itemInfo, 100000)
    end
  end)
end
function LuckyPoolLayer:timeFormat(timeAll)
  local basehour = 3600
  local basemin = 60
  local hour = math.floor(timeAll / basehour)
  local time = timeAll - hour * basehour
  local min = math.floor(time / basemin)
  local time = time - basemin * min
  local sec = math.floor(time)
  if hour < 10 then
    hour = "0" .. hour or hour
  end
  if min < 10 then
    min = "0" .. min or min
  end
  if sec < 10 then
    sec = "0" .. sec or sec
  end
  local nowTimeStr = ""
  local days = 0
  local x = hour / 24
  if x <= 0 then
    days = math.ceil(x)
  end
  if math.ceil(x) == x then
    days = math.ceil(x)
  else
    days = math.ceil(x) - 1
  end
  hour = hour % 24
  nowTimeStr = days .. common:getLanguageString("@Tian") .. hour .. ":" .. min .. ":" .. sec
  return nowTimeStr
end
function LuckyPoolLayer:changePageByType(type)
  if self._rootnode.btn_charge:isEnabled() then
    self._type = type
    if self._type == LuckyType.commonType then
      self._rootnode.btn_common:setEnabled(false)
      self._rootnode.btn_supper:setEnabled(true)
      self._rootnode.goodsPanel:setVisible(true)
      self._rootnode.goodsPanel_2:setVisible(false)
    else
      self._rootnode.btn_common:setEnabled(true)
      self._rootnode.btn_supper:setEnabled(false)
      self._rootnode.goodsPanel:setVisible(false)
      self._rootnode.goodsPanel_2:setVisible(true)
    end
    self:reSetButtonState()
    self:resetPoint()
  end
end
function LuckyPoolLayer:rankClick()
  local layer = require("game.nbactivity.LuckyPool.LuckyPoolRankLayer").new()
  CCDirector:sharedDirector():getRunningScene():addChild(layer, 100)
  GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
end
function LuckyPoolLayer:getBaseData(func)
  local function init(data)
    self._shopType = data.activityType
    self._start = data.startTime
    self._end = data.endTime
    self.activityEndTime = data.endTimeMS
    self._bonus = data.bonus
    self._point = data.point
    self._cost = data.cost
    self._costType = data.costType
    func()
  end
  self:getBaseInfo({
    callback = function(data)
      dump(data)
      if data["0"] ~= "" then
        dump(data["0"])
      else
        init(data.rtnObj)
      end
    end
  })
end
function LuckyPoolLayer:setTimeStr(param)
  local viewSize = param.viewSize
  self._actLabel = ui.newTTFLabelWithOutline({
    text = "2012-10-10 20:23:20至2012-10-10 20:23:20",
    size = 23,
    color = ccc3(0, 254, 60),
    outlineColor = ccc3(0, 0, 0),
    align = ui.TEXT_ALIGN_CENTE,
    font = FONTS_NAME.font_fzcy
  })
  self._actLabel:setString(common:getLanguageString("ActivityTime", self._start, self._end))
  self._actLabel:setPosition(viewSize.width * 0.15, viewSize.height - 30)
  self:addChild(self._actLabel)
end
function LuckyPoolLayer:clear()
  if self._scheduleTime then
    self._scheduler.unscheduleGlobal(self._scheduleTime)
    self._scheduleTime = nil
  end
  if self._schedulerExtract then
    self._scheduler.unscheduleGlobal(self._schedulerExtract)
    self._schedulerExtract = nil
  end
end
function LuckyPoolLayer:getBaseInfo(param)
  local _callback = param.callback
  local msg = {m = "activity", a = "luckInfo"}
  RequestHelper.request(msg, _callback, param.errback)
end
function LuckyPoolLayer:getLuckGetItem(param)
  dump(param)
  local _callback = param.callback
  local msg = {
    m = "activity",
    a = "luckGetItem",
    actType = param.actType
  }
  dump(msg)
  RequestHelper.request(msg, _callback, param.errback)
end
return LuckyPoolLayer
