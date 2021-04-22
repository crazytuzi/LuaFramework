-- @Author: xurui
-- @Date:   2019-01-10 16:37:11
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-03-18 14:40:31
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetInvasionFastFightAwardClient = class("QUIWidgetInvasionFastFightAwardClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIWidgetInvasionFastFightAwardClient:ctor(options)
	local ccbFile = "ccb/Widget_EliteBattleAgain_zidongsaodang.ccbi"
    local callBacks = {
		-- {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetInvasionFastFightAwardClient.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._itemsBox = {}
end

function QUIWidgetInvasionFastFightAwardClient:onEnter()
end

function QUIWidgetInvasionFastFightAwardClient:onExit()
end

function QUIWidgetInvasionFastFightAwardClient:setTitle(title)
	self._ccbOwner.tf_fight_count_title:setString(title)
end

function QUIWidgetInvasionFastFightAwardClient:setInfo(info, bossInfo, userComeBackRatio)
	self._ccbOwner.node_award:setVisible(true)
	self._ccbOwner.node_total_award:setVisible(false)

	for index, value in ipairs(info.award or {}) do
    	self._itemsBox[index] = QUIWidgetItemsBox.new()
    	self._itemsBox[index]:setPromptIsOpen(true)
		if self._ccbOwner["item"..index] then
			self._ccbOwner["item"..index]:addChild(self._itemsBox[index])
			self._itemsBox[index]:setGoodsInfo(value.id, value.type, value.count)
			self._ccbOwner["item"..index]:setVisible(true)
		end

		if index == 1 then
			if userComeBackRatio > 0 then
				value.activityYield = ((value.activityYield or 1) - 1) + (userComeBackRatio - 1) + 1
			end
			if value.activityYield and value.activityYield > 1 then
	        	self._itemsBox[index]:setRateActivityState(true, value.activityYield)
	    	end
	    end
	end

	local num, str = q.convertLargerNumber(info.damage)
	self._ccbOwner.tf_damage:setString(num..str)

    -- local level = invasion.fightCount + 1
    -- local maxLevel = db:getIntrusionMaximumLevel(invasion.bossId)
    -- level = math.min(level, maxLevel)
    local name = QStaticDatabase:sharedDatabase():getCharacterByID(bossInfo.bossId).name
    -- local title = string.format("%s(LV.%d)", name, level)
	self._ccbOwner.tf_boos_name:setString(name)
    local fontColor = remote.invasion:getBossColorByType(bossInfo.boss_type)

    self._ccbOwner.tf_boos_name:setColor(fontColor)
    self._ccbOwner.tf_boos_name = setShadowByFontColor(self._ccbOwner.tf_boos_name, fontColor)
end

function QUIWidgetInvasionFastFightAwardClient:setAllAwardInfo(info, oldInvasion, newInvasion)
	self._ccbOwner.node_award:setVisible(false)
	self._ccbOwner.node_total_award:setVisible(true)

	local offsetX = 0
	for index, value in ipairs(info.award or {}) do
    	self._itemsBox[index] = QUIWidgetItemsBox.new()
    	self._itemsBox[index]:setPromptIsOpen(true)
    	self._itemsBox[index]:setPositionX(offsetX)
		self._itemsBox[index]:setGoodsInfo(value.id, value.type, value.count)
		self._ccbOwner.node_all_item:addChild(self._itemsBox[index])

		offsetX = offsetX + self._itemsBox[index]:getContentSize().width + 30
	end

	self._ccbOwner.tf_fight_count:setString(string.format("魂兽入侵攻击次数%s", info.fightCount))
	local num, str = q.convertLargerNumber(info.totalDamage)
	self._ccbOwner.tf_all_damage:setString(num..str)
	
	self._ccbOwner.tf_old_rank:setString(oldInvasion.allHurtRank or 0)
	self._ccbOwner.tf_new_rank:setString(newInvasion.allHurtRank or 0)
	self._ccbOwner.node_rank:setVisible(oldInvasion.allHurtRank ~= newInvasion.allHurtRank)
	self._ccbOwner.tf_old_damage_rank:setString(oldInvasion.maxHurtRank or 0)
	self._ccbOwner.tf_new_damage_rank:setString(newInvasion.maxHurtRank or 0)
	self._ccbOwner.node_damage_rank:setVisible(oldInvasion.maxHurtRank ~= newInvasion.maxHurtRank)
end


function QUIWidgetInvasionFastFightAwardClient:startAnimation(callFunc)
	self._animationEndCallback = callFunc
    local animationManager = tolua.cast(self:getCCBView():getUserObject(), "CCBAnimationManager")
    animationManager:runAnimationsForSequenceNamed("Default Timeline")
    animationManager:connectScriptHandler(function(animationName)
    	animationManager:disconnectScriptHandler()
        self:_startPlayItemAnimation()
    end)
end

function QUIWidgetInvasionFastFightAwardClient:_startPlayItemAnimation()
	if #self._itemsBox == 0 then
		if self._animationEndCallback ~= nil then
			self._animationEndCallback()
		end
	else
		self:_playItemAnimation(1)
	end
end

function QUIWidgetInvasionFastFightAwardClient:_playItemAnimation(index)
	if #self._itemsBox < index then
		if self._yieldAnimation ~= nil then
			self._yieldAnimation:setVisible(true)
		end
		if self._animationEndCallback ~= nil then
			self._animationEndCallback()
		end
	else
		local widgetItem = self._itemsBox[index]
		widgetItem:setVisible(true)
		-- widgetItem:setScaleX(0)
		widgetItem:setScaleX(1)
		-- widgetItem:setScaleY(0)
		widgetItem:setScaleY(1)
	    local actionArrayIn = CCArray:create()
        actionArrayIn:addObject(CCEaseBackInOut:create(CCScaleTo:create(0.11, 1, 1)))
        actionArrayIn:addObject(CCCallFunc:create(function ()
	        self:_playItemAnimation(index + 1)
        end))
	    local ccsequence = CCSequence:create(actionArrayIn)
		local handler = widgetItem:runAction(ccsequence)
	end
end

function QUIWidgetInvasionFastFightAwardClient:getContentSize()
	return self._ccbOwner.ly_size:getContentSize()
end

return QUIWidgetInvasionFastFightAwardClient
