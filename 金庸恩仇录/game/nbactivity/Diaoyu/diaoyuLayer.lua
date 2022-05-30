require("data.data_error_error")
require("data.data_langinfo")
local data_item_item = require("data.data_item_item")
local normal_fish_cost = 20
local advanced_fish_cost = 200
local diaoyuLayer = class("diaoyuLayer", function()
  return display.newLayer("diaoyuLayer")
end)
local diaoyuMsg = {
  getBaseInfo = function(param)
    local _callback = param.callback
    local msg = {m = "activity", a = "fishing"}
    RequestHelper.request(msg, _callback, param.errback)
  end,
  doFishing = function(param)
    local _callback = param.callback
    local msg = {
      m = "activity",
      a = "dofishing",
      t = param.type
    }
    RequestHelper.request(msg, _callback, param.errback)
  end
}
function diaoyuLayer:getData(...)
  local function init(data)
    self.costGold = data.drawConsumeGoldNum["1"]
    self.activityEndTime = data.activityEndTime
    self:refreshTime()
    self.baseItem = {}
    for k, value in pairs(data.bestItem) do
      table.insert(self.baseItem, value)
    end
    self:refreshLabel()
    self:showBestRewards()
  end
  diaoyuMsg.getBaseInfo({
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
function diaoyuLayer:onIconClick(index)
  local sceneLayer = CCDirector:sharedDirector():getRunningScene()
  local data = self.baseItem[index]
  if tonumber(data.type) ~= 6 then
    if not sceneLayer:getChildByTag(1111) then
      local function closeFunc()
        if sceneLayer:getChildByTag(1111) then
          sceneLayer:removeChildByTag(1111, true)
        end
      end
      local itemInfo = require("game.Huodong.ItemInformation").new({
        id = tonumber(data.id),
        type = tonumber(data.type),
        name = data_item_item[tonumber(data.id)].name,
        describe = data_item_item[tonumber(data.id)].describe,
        endFunc = closeFunc
      })
      sceneLayer:addChild(itemInfo, 1000, 1111)
    end
  else
    local function closeFunc()
      if sceneLayer:getChildByTag(1111) then
        sceneLayer:removeChildByTag(1111, true)
      end
    end
    if not sceneLayer:getChildByTag(1111) then
      local descLayer = require("game.Spirit.SpiritInfoLayer").new(4, {
        resId = tonumber(data.id)
      }, nil, closeFunc)
      sceneLayer:addChild(descLayer, 1000, 1111)
    end
  end
end
function diaoyuLayer:showBestRewards()
  for i = 1, 5 do
    local itemData = self.baseItem[i]
    if itemData then
      local itemBg = self._rootnode["reward_item_" .. i]
      itemBg:removeAllChildren()
      ResMgr.refreshItemWithTagNumName({
        itemType = itemData.type,
        id = itemData.id,
        itemBg = itemBg,
        itemNum = itemData.residueNum .. "/" .. itemData.num,
        isShowIconNum = true
      })
      if itemData.poolId == 3 then
        local quas = {
          "",
          "pinzhikuangliuguang_lv",
          "pinzhikuangliuguang_lan",
          "pinzhikuangliuguang_zi",
          "pinzhikuangliuguang_jin"
        }
        local holoName = quas[5]
        local suitArma = ResMgr.createArma({
          resType = ResMgr.UI_EFFECT,
          armaName = holoName,
          isRetain = true
        })
        suitArma:setPosition(itemBg:getContentSize().width / 2, itemBg:getContentSize().height / 2)
        itemBg:addChild(suitArma)
      end
    end
  end
end
function diaoyuLayer:ctor(param)
  self._proxy = CCBProxy:create()
  self._rootnode = {}
  self:setContentSize(param.size)
  local bgNode = CCBuilderReaderLoad("nbhuodong/diaoyu_layer.ccbi", self._proxy, self._rootnode, self, param.size)
  self:addChild(bgNode)
  local bgSize = bgNode:getContentSize()
  local height = param.size.height - bgSize.height
  self.actRestTime = 0
  self.freeTimes = nil
  self:getData()
  self._rootnode.act_desc:addHandleOfControlEvent(function()
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    if not CCDirector:sharedDirector():getRunningScene():getChildByTag(1000) then
      local layer = require("game.SplitStove.SplitDescLayer").new(37)
      CCDirector:sharedDirector():getRunningScene():addChild(layer, 1000)
    end
  end, CCControlEventTouchUpInside)
  local normalFishbtn = self._rootnode.diaoyu_one
  normalFishbtn:addHandleOfControlEvent(function(eventName, sender)
    self:diaoyu(1)
  end, CCControlEventTouchUpInside)
  self._rootnode.diaoyu_ten:addHandleOfControlEvent(function(eventName, sender)
    self:diaoyu(10)
  end, CCControlEventTouchUpInside)
  self:refreshLabel()
  local spine = SpineContainer:create(unpack({
    "ccs/spine/Wuxia_diaoyulaozhe",
    "Wuxia_diaoyulaozheb"
  }))
  spine:stopAllAnimations()
  spine:runAnimation(1, "Stand", -1)
  spine = tolua.cast(spine, "CCNode")
  self._rootnode.diaoyu_spine:addChild(tolua.cast(spine, "CCNode"), 100)
  self._rootnode.shade_node:setVisible(false)
  self._rootnode.shade_node:setTouchEnabled(false)
  self._rootnode.shade_node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event, x, y)
    if "began" == event.name then
      return true
    end
  end, 1)
  self._rootnode.shade_node:setTouchSwallowEnabled(true)
  self._rootnode.reward_confirm_btn:addHandleOfControlEvent(function(eventName, sender)
    self:showRewardAnim(false)
  end, CCControlEventTouchUpInside)
  for i = 1, 5 do
    do
      local bestItemBg = self._rootnode["reward_item_" .. i]
      bestItemBg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event, x, y)
        if "began" == event.name then
          self:onIconClick(i)
          return true
        end
      end, 1)
      bestItemBg:setTouchEnabled(true)
    end
  end
end
function diaoyuLayer:refreshTime()
  self.scheduler = require("framework.scheduler")
  self.actTimeLabel = self._rootnode.timeCountDown
  self.actRestTime = GameModel.getRestTimeInSec(self.activityEndTime)
  local function actUpdate()
    local updateStr = ""
    if self.actRestTime > 0 then
      self.actRestTime = GameModel.getRestTimeInSec(self.activityEndTime)
      updateStr = format_time(self.actRestTime)
    else
      updateStr = common:getLanguageString("@ActivityOver")
      self.scheduler.unscheduleGlobal(self.timeData)
      self:stopAct()
    end
    self.actTimeLabel:setString(updateStr)
  end
  actUpdate()
  if self.timeData ~= nil then
    self.scheduler.unscheduleGlobal(self.timeData)
  end
  self.timeData = self.scheduler.scheduleGlobal(actUpdate, 1, false)
end
function diaoyuLayer:refreshLabel()
  if self.costGold then
    self._rootnode.diaoyu_one:setEnabled(true)
    self._rootnode.diaoyu_ten:setEnabled(true)
  else
    self._rootnode.diaoyu_one:setEnabled(false)
    self._rootnode.diaoyu_ten:setEnabled(false)
  end
end
function diaoyuLayer:diaoyu(diaoyuType)
  local costGold = self.costGold * diaoyuType
  if costGold > game.player:getGold() then
    show_tip_label(common:getLanguageString("@PriceEnough"))
    self._rootnode.diaoyu_one:setEnabled(true)
    self._rootnode.diaoyu_ten:setEnabled(true)
    return false
  end
  diaoyuMsg.doFishing({
    type = diaoyuType,
    callback = function(data)
      dump(data)
      if #data["0"] > 0 then
        show_tip_label(data["0"])
        self:getData()
      else
        game.player:setGold(data.rtnObj.gold)
        self.baseItem = data.rtnObj.items
        self:showBestRewards()
        self:showRewards(data.rtnObj.rewardItem, data.rtnObj.poolId)
      end
    end,
    errback = function(data)
      self._rootnode.diaoyu_one:setEnabled(true)
      self._rootnode.diaoyu_ten:setEnabled(true)
      if data and data.errCode == 2111 then
        for key, item in pairs(self.baseItem) do
          item.residueNum = 0
        end
        self:showBestRewards()
      else
        self:getData()
      end
    end
  })
  self._rootnode.diaoyu_one:setEnabled(false)
  self._rootnode.diaoyu_ten:setEnabled(false)
  return true
end
function diaoyuLayer:showRewardAnim(isOpen)
  local baseNode = self._rootnode.shade_node
  local shade_bg = self._rootnode.shade_bg
  shade_bg:setOpacity(0)
  if isOpen then
    local addEffect = ResMgr.createArma({
      resType = ResMgr.UI_EFFECT,
      armaName = "xiakejinjie_qishou",
      isRetain = false,
      frameFunc = function()
        baseNode:setVisible(true)
        baseNode:setTouchEnabled(true)
        baseNode:setScale(0.1)
        baseNode:runAction(CCScaleTo:create(0.1, 1))
        shade_bg:runAction(CCFadeTo:create(0.1, 122))
      end,
      finishFunc = function()
      end
    })
    CCDirector:sharedDirector():getRunningScene():addChild(addEffect, 11)
    addEffect:setPosition(ccp(display.width * 0.5, display.height * 0.5))
  else
    baseNode:runAction(transition.sequence({
      CCScaleTo:create(0.1, 0.1),
      CCCallFunc:create(function()
        baseNode:setVisible(false)
        baseNode:setTouchEnabled(false)
      end)
    }))
    self._rootnode.diaoyu_one:setEnabled(true)
    self._rootnode.diaoyu_ten:setEnabled(true)
  end
end
function diaoyuLayer:showRewards(rewards, poolId)
  if #rewards == 1 then
    local picId = poolId[1] <= 4 and 1 or 2
    local reward_bg_name = "ui/ui_CommonResouces/ui_luckypool_jar_0" .. picId .. ".png"
    self._rootnode.reward_bg:setDisplayFrame(display.newSprite(reward_bg_name):getDisplayFrame())
    self._rootnode.reward_node:removeAllChildren()
    ResMgr.refreshItemWithTagNumName({
      itemType = rewards[1].t,
      id = rewards[1].id,
      itemNum = rewards[1].n,
      itemBg = self._rootnode.reward_node
    })
    self:showRewardAnim(true)
  else
    do
      local itemData = {}
      for key, item in pairs(rewards) do
        local iconType = ResMgr.getResType(item.t)
        itemData[key] = {}
        itemData[key].type = item.t
        itemData[key].id = item.id
        itemData[key].iconType = iconType
        itemData[key].num = item.n
        itemData[key].name = ResMgr.getItemNameByType(item.id, iconType)
      end
      local addEffect = ResMgr.createArma({
        resType = ResMgr.UI_EFFECT,
        armaName = "xiakejinjie_qishou",
        isRetain = false,
        frameFunc = function()
          local msgBox = require("game.Huodong.RewardMsgBox").new({cellDatas = itemData})
          CCDirector:sharedDirector():getRunningScene():addChild(msgBox, 1000)
        end,
        finishFunc = function()
          self._rootnode.diaoyu_one:setEnabled(true)
          self._rootnode.diaoyu_ten:setEnabled(true)
        end
      })
      CCDirector:sharedDirector():getRunningScene():addChild(addEffect, 11)
      addEffect:setPosition(ccp(display.width * 0.5, display.height * 0.5))
    end
  end
  for key, item in pairs(rewards) do
    if poolId[key] == 3 and item.t == ITEM_TYPE.wuxue then
      local iconType = ResMgr.getResType(item.t)
      local itemName = ResMgr.getItemNameByType(item.id, iconType)
      game.broadcast:showPlayerGetSkill(itemName, 5)
    end
  end
end
function diaoyuLayer:onExit()
  if self.timeData then
    self.scheduler.unscheduleGlobal(self.timeData)
  end
end
function diaoyuLayer:clear(...)
  if self.timeData then
    self.scheduler.unscheduleGlobal(self.timeData)
  end
end
return diaoyuLayer
