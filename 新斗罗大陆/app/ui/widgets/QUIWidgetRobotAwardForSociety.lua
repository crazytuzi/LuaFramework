--
-- Author: Kumo
-- Date: 2014-07-14 15:41:41
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetRobotAwardForSociety = class("QUIWidgetRobotAwardForSociety", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIWidgetRobotAwardForSociety:ctor(options)
	print("<<<QUIWidgetRobotAwardForSociety>>>")
	local ccbFile = "ccb/Widget_society_fuben_zidong2.ccbi"
	local callbacks = {}
	--设置该节点启用enter事件
	self:setNodeEventEnabled(true)
	QUIWidgetRobotAwardForSociety.super.ctor(self, ccbFile, callbacks, options)

	self._itemsBox = {}
	self._ccbOwner.tf_name:setString("")
	self._ccbOwner.tf_name_title:setString("攻击目标：")
	self._ccbOwner.tf_totalDamage:setString("0")
	self._ccbOwner.tf_totalDamage_title:setString("造成伤害：")
end

function QUIWidgetRobotAwardForSociety:getHeight()
	local height = self._ccbOwner.node_size:getContentSize().height
	return height
end

function QUIWidgetRobotAwardForSociety:getWidth()
	return self._ccbOwner.node_size:getContentSize().width
end

function QUIWidgetRobotAwardForSociety:setTitle(title)
	self._ccbOwner.tf_count:setString(title)
end

function QUIWidgetRobotAwardForSociety:setTitleExtra()
	self._ccbOwner.tf_count:setString("奖励结算")
	self._ccbOwner.tf_name:setString("")
	self._ccbOwner.tf_name_title:setString("")
	self._ccbOwner.tf_totalDamage:setString("")
	self._ccbOwner.tf_totalDamage_title:setString("")
	self._ccbOwner.sp_playerRecall:setVisible(false)
end

function QUIWidgetRobotAwardForSociety:setInfo(info, yield, yieldLevel, activityYield)
	if info.bossId then
		local character = QStaticDatabase.sharedDatabase():getCharacterByID(info.bossId)
		self._ccbOwner.tf_name:setString(character.name)
		local num, word = q.convertLargerNumber(info.totalDamage or 0)
		self._ccbOwner.tf_totalDamage:setString(num..word)
		-- if remote.playerRecall:isOpen() then
	 --        local sp = CCSprite:create("ui/dl_wow_pic/sp_comeback.png")
	 --        local node = self._ccbOwner.tf_totalDamage:getParent()
	 --        sp:setAnchorPoint(ccp(0, 0.5))
	 --        sp:setPositionX(self._ccbOwner.tf_totalDamage:getPositionX() + self._ccbOwner.tf_totalDamage:getContentSize().width)
	 --        sp:setPositionY(self._ccbOwner.tf_totalDamage:getPositionY())
	 --        node:addChild(sp)
	 --    end
	    self._ccbOwner.sp_playerRecall:setVisible(remote.playerRecall:isOpen())
	    self._ccbOwner.sp_playerRecall:setAnchorPoint(ccp(0, 0.5))
        self._ccbOwner.sp_playerRecall:setPositionX(self._ccbOwner.tf_totalDamage:getPositionX() + self._ccbOwner.tf_totalDamage:getContentSize().width)
        self._ccbOwner.sp_playerRecall:setPositionY(self._ccbOwner.tf_totalDamage:getPositionY())
	end

	if table.nums(info.award) == 4 then
		-- 有击杀奖励
        self._ccbOwner.node_item:setPositionX(0)
        self._ccbOwner.node_item:setPositionY(-126)
    elseif table.nums(info.award) == 1 then
    	-- 最后总结
        self._ccbOwner.node_item:setPositionX(-520)
        self._ccbOwner.node_item:setPositionY(-106)
    else
        self._ccbOwner.node_item:setPositionX(-87)
        self._ccbOwner.node_item:setPositionY(-126)
    end

	local i = 1
	while(true) do
		if self._ccbOwner["item"..i] then
			self._ccbOwner["item"..i]:setVisible(false)
			i = i + 1
		else
			break
		end
	end

	for index, value in ipairs(info.award or {}) do
    	self._itemsBox[index] = QUIWidgetItemsBox.new()
    	self._itemsBox[index]:setPromptIsOpen(true)
		if self._ccbOwner["item"..index] then
			self._ccbOwner["item"..index]:addChild(self._itemsBox[index])
			self._itemsBox[index]:setGoodsInfo(value.id, value.type, value.count)
			self._ccbOwner["item"..index]:setVisible(true)
		end
		if value.activityYield and value.activityYield > 1 then
        	self._itemsBox[index]:setRateActivityState(true)
    	end
	end
end

function QUIWidgetRobotAwardForSociety:startAnimation(callFunc)
	self._animationEndCallback = callFunc
    local animationManager = tolua.cast(self:getCCBView():getUserObject(), "CCBAnimationManager")
    animationManager:runAnimationsForSequenceNamed("Default Timeline")
    animationManager:connectScriptHandler(function(animationName)
    	animationManager:disconnectScriptHandler()
        self:_startPlayItemAnimation()
    end)
end

function QUIWidgetRobotAwardForSociety:_startPlayItemAnimation()
	if #self._itemsBox == 0 then
		if self._animationEndCallback ~= nil then
			self._animationEndCallback()
		end
	else
		self:_playItemAnimation(1)
	end
end

function QUIWidgetRobotAwardForSociety:_playItemAnimation(index)
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

return QUIWidgetRobotAwardForSociety