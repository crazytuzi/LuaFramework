--
-- Author: wkwang
-- Date: 2014-10-13 14:57:18
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroUpgradeNew = class("QUIWidgetHeroUpgradeNew", QUIWidget)

local QUIWidgetHeroUpgradeCellNew = import("..widgets.QUIWidgetHeroUpgradeCellNew")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QQuickWay = import("...utils.QQuickWay")

function QUIWidgetHeroUpgradeNew:ctor(options)
	local ccbFile = "ccb/Widget_HeroUpgrade.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerOneGrade", callback = handler(self, self._onTriggerOneGrade)},
        {ccbCallbackName = "onTriggerFiveGrade", callback = handler(self, self._onTriggerFiveGrade)},
    }
	QUIWidgetHeroUpgradeNew.super.ctor(self, ccbFile, callBacks, options)
end

function QUIWidgetHeroUpgradeNew:onEnter()
	QUIWidgetHeroUpgradeNew.super.onEnter(self)
    self._heroProxy = cc.EventProxy.new(remote.herosUtil)
    self._heroProxy:addEventListener(remote.herosUtil.EVENT_HERO_EXP_CHECK, handler(self, self._saveExp))

    self._itemProxy = cc.EventProxy.new(remote.items)
    self._itemProxy:addEventListener(remote.items.EVENT_ITEMS_UPDATE, handler(self, self._itemUpdateHandler))
end

function QUIWidgetHeroUpgradeNew:onExit()
	QUIWidgetHeroUpgradeNew.super.onExit(self)
	self:_saveExp()
	
	self._heroProxy:removeAllEventListeners()

	self._itemProxy:removeAllEventListeners()
end

function QUIWidgetHeroUpgradeNew:showById(actorId, targetP, tfBattleP)
	self._actorId = actorId
	self._targetP = targetP
	self._tfBattleP = tfBattleP

	local expItems = remote.items.EXP_ITEMS
	self._items = {}

	for index, value in ipairs(expItems) do
		self._ccbOwner["node_item"..index]:removeAllChildren()
		local items = QUIWidgetHeroUpgradeCellNew.new()
		local itemsInfo = QStaticDatabase:sharedDatabase():getItemByID(value)
		items:setInfo(itemsInfo, self._actorId)
		items:setTargetPosition(self._targetP)
		items:setTfBattlePosition(self._tfBattleP)
		self._ccbOwner["node_item"..index]:addChild(items)
		table.insert(self._items, items)
	end
end

function QUIWidgetHeroUpgradeNew:_sortHero(a,b)
	if a.exp ~= b.exp then
		return a.exp < b.exp
	end
	return a.id < b.id
end

--[[
	保存吃卡数据到后台
]]
function QUIWidgetHeroUpgradeNew:_saveExp()
	local itemPairs = {}
	local eatNum = 0
	for _, item in ipairs(self._items) do
		local itemId, count = item:getEatExp()
		if count > 0 then
			eatNum = eatNum + count
			table.insert(itemPairs, {itemId = itemId, count = count})
		end
	end

	if eatNum > 0 then
		if nil ~= app:getClient() then
			app:getClient():intensify(self._actorId, itemPairs, function()
				remote.user:addPropNumForKey("todayHeroExpCount", eatNum)
			end, function ()
				for _,value in ipairs(itemPairs) do
					remote.items:removeItemsByID(value.itemId, -value.count, false) --在发消息失败之后把Item加回去 防止发送失败前端扣掉了 @wkwang
				end
			end)
		end
	end
end

--[[
	计算吃到对应等级需要的经验物品数量
]]
function QUIWidgetHeroUpgradeNew:upgradeLevel(level)
	local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
	local items = {}
	local targetLevel = math.min(heroInfo.level + level, remote.user.heroMaxLevel)-1
	if targetLevel < heroInfo.level then
		  app.tip:floatTip("魂师等级不能超过战队等级")
		return
	end
	local needExp = -heroInfo.exp
	for i = heroInfo.level, targetLevel do
		needExp = needExp + QStaticDatabase:sharedDatabase():getExperienceByLevel(i)
	end

	local expItems = remote.items.EXP_ITEMS
	local eatExp = 0
	for index,value in ipairs(expItems) do
		local count = remote.items:getItemsNumByID(value)
		if count > 0 then
			local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(value)
			local needCount = math.ceil(needExp/itemConfig.exp)
			local eatCount = math.min(count, needCount)
			eatExp = eatExp + eatCount * itemConfig.exp
			needExp = needExp - eatCount * itemConfig.exp
			self._items[index]:addEatNum(eatCount)
			self._items[index]:_showEatNum()
			self._items[index]:_showEffect()
			table.insert(items, {id = value, count = eatCount})
		end
		if needExp <= 0 then
			break
		end
	end

	if eatExp > 0 then
		remote.herosUtil:heroEatExp(eatExp, self._actorId)
	end
	if #items > 0 then
		self._items[#self._items]:showReport()
		self:_saveExp()
	else
    	QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, expItems[3])
	end
end

--更新物品数量
function QUIWidgetHeroUpgradeNew:_itemUpdateHandler( ... )
	for _,items in ipairs(self._items) do
		items:updateItemNum()
	end
end

function QUIWidgetHeroUpgradeNew:_onTriggerOneGrade(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_oneGrade) == false then return end
	self:upgradeLevel(1)
end

function QUIWidgetHeroUpgradeNew:_onTriggerFiveGrade(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_fiveGrade) == false then return end
	self:upgradeLevel(5)
end

return QUIWidgetHeroUpgradeNew