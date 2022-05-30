local data_item_item = require("data.data_item_item")
local data_pet_pet = require("data.data_pet_pet")
local data_card_card = require("data.data_card_card")
local data_error_error = require("data.data_error_error")
local TuanGouItemView = class("TuanGouItemView", function()
  return CCTableViewCell:new()
end)
function TuanGouItemView:ctor(param)
  local proxy = CCBProxy:create()
  self._rootnode = {}
  local node = CCBuilderReaderLoad("nbhuodong/tuangou_item.ccbi", proxy, self._rootnode)
  node:setAnchorPoint(cc.p(0, 0))
  self:addChild(node)
  self._iconSize = self._rootnode.reward_icon:getContentSize()
  self.callback = param.callback
  self:refresh(param)
  local toggle = true
  self._rootnode.btn_buy:addHandleOfControlEvent(function(eventName, sender)
    if toggle then
      if not self.param.isCanBuy then
        show_tip_label(common:getLanguageString("@huodongqjczbz"))
        return
      else
        self:buy()
      end
      toggle = false
    end
    self:performWithDelay(function()
      toggle = true
    end, 0.5)
  end, CCControlEventTouchUpInside)
  self._rootnode.reward_icon:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
    return self:itemIconTouch(event)
  end)
  self._rootnode.reward_icon:setTouchEnabled(true)
  self._rootnode.reward_icon:setTouchSwallowEnabled(false)
end
function TuanGouItemView:itemIconTouch(event)
  if event.name == "began" then
    self.touchIcon = true
    self.touchIconPx = event.x
    self.touchIconPy = event.y
    return true
  elseif event.name == "moved" then
    local x = event.x - self.touchIconPx
    local y = event.y - self.touchIconPy
    if x * x + y * y > 30 then
      self.touchIcon = false
    end
  elseif event.name == "ended" and self.touchIcon then
    self.touchIcon = false
    self:showInfo()
  end
end
function TuanGouItemView:createItemView(data, num, limintcount)
  local itemData = self.param.itemData
  local icon = display.newSprite()
  ResMgr.refreshItemWithTagNumName({
    id = data.id,
    itemBg = icon,
    isShowIconNum = num > 1 and 1 or 0,
    itemNum = num,
    itemType = data.type,
    resType = ResMgr.getResType(data.type)
  })
  self._rootnode.reward_icon:addChild(icon)
  icon:setPosition(self._iconSize.width * 0.5, self._iconSize.height * 0.5)
end
function TuanGouItemView:refresh(param)
  self.param = param
  local itemId = param.itemData.id
  local staticData
  local type = ResMgr.getResType(param.itemData.type)
  local staticData = ResMgr.getItemByType(param.itemData.itemId, type)
  self.staticData = staticData
  self._rootnode.reward_icon:removeAllChildrenWithCleanup(true)
  local itemData = self.param.itemData
  local icon = display.newSprite()
  ResMgr.refreshItemWithTagNumName({
    id = param.itemData.itemId,
    itemBg = icon,
    isShowIconNum = param.itemData.num > 1 and 1 or 0,
    itemNum = param.itemData.num,
    itemType = param.itemData.type,
    resType = ResMgr.getResType(param.itemData.type)
  })
  self._rootnode.reward_icon:addChild(icon)
  icon:setPosition(self._iconSize.width * 0.5, self._iconSize.height * 0.5)
  self._rootnode.vip_level_lbl:setString(param.itemData.vip)
  if param.itemData.showHalo == 1 then
    local suitArma = ResMgr.createArma({
      resType = ResMgr.UI_EFFECT,
      armaName = "pinzhikuangliuguang_jin",
      isRetain = true
    })
    suitArma:setPosition(self._iconSize.width / 2, self._iconSize.height / 2)
    suitArma:setTouchEnabled(false)
    self._rootnode.reward_icon:addChild(suitArma)
  end
  self._rootnode.remain_lbl:setString(common:getLanguageString("@tgtimeremain", self.param.itemData.lastNum))
  self._rootnode.price_old:setString(param.itemData.price)
  self._rootnode.price_now:setString(param.itemData.salPrice)
end
function TuanGouItemView:buy()
  local itemData = self.param.itemData
  local staticData = self.staticData
  local itemId = itemData.id
  local isCanBuy = self.param.isCanBuy
  local buyType = self.param.buytype
  if not isCanBuy then
    show_tip_label(data_error_error[3700001].prompt)
    return
  end
  if itemData.lastNum == 0 then
    show_tip_label(data_error_error[3700002].prompt)
    return
  end
  if game.player:getVip() < itemData.vip then
    show_tip_label(data_error_error[3700004].prompt)
    return
  end
  local itemDatas = {
    name = staticData.name,
    iconType = ResMgr.getResType(itemData.type),
    had = itemData.lastNum,
    limitNum = itemData.lastNum,
    needReputation = itemData.salPrice
  }
  local popup = require("game.nbactivity.TuanGou.ExchangeCountBox").new({
    reputation = game.player:getGold(),
    itemData = itemDatas,
    listener = function(num)
      RequestHelper.tuanGouSystem.buyGoodsInfo({
        callback = function(data)
          if data["0"] ~= "" then
            dump(data["0"])
          else
            if #data.rtnObj == 5 then
              show_tip_label(data_error_error[tonumber(data.rtnObj[5])].prompt)
            else
              local dataTemp = {}
              table.insert(dataTemp, {
                id = staticData.id,
                type = itemData.type,
                name = staticData.name,
                describe = staticData.dis,
                num = num,
                iconType = ResMgr.getResType(itemData.type)
              })
              local msgBox = require("game.Huodong.RewardMsgBox").new({
                title = common:getLanguageString("@RewardList"),
                cellDatas = dataTemp
              })
              CCDirector:sharedDirector():getRunningScene():addChild(msgBox, 1000)
            end
            self.callback(data.rtnObj, buyType)
          end
        end,
        shoppingId = itemId,
        goodsCount = num,
        groupType = buyType
      })
    end,
    closeFunc = function()
    end
  })
  popup:setPositionY(0)
  display.getRunningScene():addChild(popup, 1000000)
end
function TuanGouItemView:showInfo()
  if not self.staticData then
    return
  end
  local staticData = self.staticData
  local itemData = self.param.itemData
  if itemData.type ~= 6 then
    local closeFunc = function()
      CCDirector:sharedDirector():getRunningScene():removeChildByTag(1111, true)
    end
    local itemInfo = require("game.Huodong.ItemInformation").new({
      id = staticData.id,
      type = itemData.type,
      name = staticData.name,
      describe = staticData.dis,
      endFunc = closeFunc
    })
    CCDirector:sharedDirector():getRunningScene():addChild(itemInfo, 100000, 1111)
  else
    local closeFunc = function()
      if CCDirector:sharedDirector():getRunningScene():getChildByTag(1111) then
        CCDirector:sharedDirector():getRunningScene():removeChildByTag(1111, true)
      end
    end
    local descLayer = require("game.Spirit.SpiritInfoLayer").new(4, {
      resId = tonumber(itemData.itemId)
    }, nil, closeFunc)
    CCDirector:sharedDirector():getRunningScene():addChild(descLayer, 100000000, 1111)
  end
end
return TuanGouItemView
