local GuildBattleXunluoLayer = class("GuildBattleXunluoLayer", function()
  return require("utility.ShadeLayer").new()
end)
local xunluoMsg = {
  getXunluoInfo = function(param)
    local _callback = param.callback
    local msg = {
      m = "union",
      a = "patrolStatus"
    }
    RequestHelper.request(msg, _callback, param.errback)
  end,
  startXunluoInfo = function(param)
    local _callback = param.callback
    local msg = {
      m = "union",
      a = "patrol",
      type = param.type
    }
    RequestHelper.request(msg, _callback, param.errback)
  end
}
local data_xunluo_xunluo = require("data.data_xunluo_xunluo")
function GuildBattleXunluoLayer:ctor(param)
  self._proxy = CCBProxy:create()
  self._rootnode = {}
  local bgNode = CCBuilderReaderLoad("guild/guild_battle_xunluo.ccbi", self._proxy, self._rootnode)
  self:addChild(bgNode)
  bgNode:setPosition(display.cx, display.cy)
  self._rootnode.titleLabel:setString(common:getLanguageString("@GuildBattlePatrol"))
  self._rootnode.tag_close:addHandleOfControlEvent(function(eventName, sender)
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
    self:removeFromParentAndCleanup(true)
  end, CCControlEventTouchUpInside)
  local data_item_item = require("data.data_item_item")
  for i = 1, 3 do
    do
      local xunluoData = data_xunluo_xunluo[i]
      self._rootnode["cost_lbl_" .. i]:setString(xunluoData.expendNums .. data_item_item[xunluoData.expendItem].name)
      self._rootnode["cost_time_" .. i]:setString(xunluoData.time .. common:getLanguageString("@TimeHourLbl"))
      self._rootnode["xunluo_btn_" .. i]:addHandleOfControlEvent(function(eventName, sender)
        self:startXunluo(i)
      end, CCControlEventTouchUpInside)
      self._rootnode["xunluo_btn_" .. i]:setEnabled(false)
    end
  end
  local xunluoData = data_xunluo_xunluo[1]
  for key = 1, 3 do
    ResMgr.refreshItemWithTagNumName({
      itemType = xunluoData.rewardTypes[key],
      id = xunluoData.rewardIds[key],
      itemBg = self._rootnode["reward_icon_" .. key],
      itemNum = xunluoData.rewardNums[key],
      isShowIconNum = true
    })
  end
  self.xunluoInfo = {}
  self.timeLabel = {}
  self.timeNode = display.newNode()
  self:addChild(self.timeNode)
end
function GuildBattleXunluoLayer:startXunluo(xunluoType)
  if self.xunluoHasState then
    if self.xunluoInfo.type == 4 then
      show_tip_label(common:getLanguageString("@GuildBattleNotYours"))
      return
    elseif self.cityInfo.fight_status == GuildBattleFightStatus.war then
      show_tip_label(common:getLanguageString("@GuildBattleWarTips1"))
      return
    end
    local xunluoData = data_xunluo_xunluo[xunluoType]
    if xunluoData.expendItem == 4 then
      if game.player:getNaili() < xunluoData.expendNums then
        show_tip_label(data_error_error[100006].prompt)
        return
      end
    elseif xunluoData.expendItem == 1 and game.player:getGold() < xunluoData.expendNums then
      show_tip_label(data_error_error[1602].prompt)
      return
    end
    self.xunluoHasState = false
    xunluoMsg.startXunluoInfo({
      type = xunluoType,
      callback = function(data)
        self.xunluoHasState = true
        self.xunluoInfo.time = data.rtnObj.time / 1000
        self.xunluoInfo.type = data.rtnObj.type
        self:resetData()
      end
    })
  end
end
function GuildBattleXunluoLayer:resetData()
  local btnState = true
  local btnLbl = "@GuildBattlePatrol"
  if self.xunluoInfo.type > 0 and self.xunluoInfo.type < 4 then
    btnState = false
    btnLbl = "@GuildBattlePatrolIng"
  end
  for i = 1, 3 do
    local str = common:getLanguageString(btnLbl)
    if self.xunluoInfo.type == i then
      str = ""
    end
    self._rootnode["xunluo_btn_" .. i]:setTitleForState(CCString:create(str), CCControlStateDisabled)
    self._rootnode["xunluo_btn_" .. i]:setEnabled(btnState)
  end
  self:resetTimeLabel()
end
function GuildBattleXunluoLayer:getData()
  self.xunluoHasState = false
  xunluoMsg.getXunluoInfo({
    callback = function(data)
      self.xunluoInfo.type = data.rtnObj.type
      self.xunluoInfo.time = data.rtnObj.time / 1000
      self.xunluoHasState = true
      self:resetData()
      self.cityInfo = GuildBattleModel.getCityInfo()
      if #data.rtnObj.rtnAry > 0 then
        local layer = require("game.Yabiao.YabiaoCompletePopup").new({
          confirmFunc = function()
          end,
          type = 2,
          itemData = data.rtnObj.rtnAry
        })
        display.getRunningScene():addChild(layer, 10000)
      end
    end
  })
end
function GuildBattleXunluoLayer:resetTimeLabel()
  if self.xunluoHasState and self.xunluoInfo.type ~= 0 and self.xunluoInfo.type ~= 4 then
    local serverTime = GameModel.getServerTimeInSec()
    local needTime = self.xunluoInfo.time - GameModel.getServerTimeInSec()
    if needTime <= 0 then
      self:getData()
      self.xunluoHasState = false
      if self.timeLabel[self.xunluoInfo.type] then
        self.timeLabel[self.xunluoInfo.type]:setVisible(false)
      end
    else
      local timeStr = format_time(needTime)
      if not self.timeLabel[self.xunluoInfo.type] then
        local timeLabel = ui.newTTFLabelWithOutline({
          text = "",
          size = 22,
          color = ccc3(227, 227, 227),
          shadowColor = ccc3(0, 0, 0),
          font = FONTS_NAME.font_fzcy,
          align = ui.TEXT_ALIGN_CENTER
        })
        self.timeLabel[self.xunluoInfo.type] = timeLabel
        local btn = self._rootnode["xunluo_btn_" .. self.xunluoInfo.type]
        btn:getParent():addChild(timeLabel)
        local cx, cy = timeLabel:getPosition()
        timeLabel:setPosition(btn:getPosition())
      end
      self.timeLabel[self.xunluoInfo.type]:setString(timeStr)
      self.timeLabel[self.xunluoInfo.type]:setVisible(true)
    end
  end
end
function GuildBattleXunluoLayer:onEnter()
  local function update(dt)
    self:resetTimeLabel()
  end
  self.timeNode:schedule(update, 1)
  self:getData()
end
function GuildBattleXunluoLayer:onExit()
  self.timeNode:stopAllActions()
end
return GuildBattleXunluoLayer
