--
-- Author: Kumo
-- Date: 2014-07-14 15:41:41
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetRobotAward = class("QUIWidgetRobotAward", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIWidgetRobotAward:ctor(options)
	local ccbFile = "ccb/Widget_RobotAward.ccbi"
	local callbacks = {}
	--设置该节点启用enter事件
	self:setNodeEventEnabled(true)
	QUIWidgetRobotAward.super.ctor(self, ccbFile, callbacks, options)

	self._itemsBox = {}
	self._ccbOwner.tf_exp:setString("+0")
	self._ccbOwner.tf_money:setString("+0")
	--设置动画时长
	self._animationTime = 0.5
	self._showItemsTime = 0.5
	self._isShow = false
	self._isTotal = false

	self._ccbOwner.tf_tips:setVisible(false)
	self._ccbOwner.sp_invasionMoney:setVisible(false)
	self._ccbOwner.tf_invasionMoney:setVisible(false)
	self._ccbOwner.tf_double:setVisible(false)

	self._ccbOwner.tf_replayCount_title:setString("")
	self._ccbOwner.tf_replayCount:setString("")
	self._ccbOwner.tf_replayPrice_title:setString("")
	self._ccbOwner.tf_replayPrice:setString("")
	self._ccbOwner.sp_token:setVisible(false)
end

function QUIWidgetRobotAward:getHeight()
	local height = self._ccbOwner.node_size_small:getContentSize().height
	if self._isLong then
		height = self._ccbOwner.node_size:getContentSize().height
	end
	if self._isReplay then
		return height - 60
	end
	return height + 10
end

function QUIWidgetRobotAward:getWidth()
	return self._ccbOwner.node_size:getContentSize().width
end

function QUIWidgetRobotAward:setTitle(title)
	self._ccbOwner.tf_count:setString(title)
end

function QUIWidgetRobotAward:setDungeonType(dungeonType)
	self._dungeonType = dungeonType
end

function QUIWidgetRobotAward:setTitleExtra()
	self._ccbOwner.tf_count:setString("累计部分奖励")
	self._isTotal = true
end

function QUIWidgetRobotAward:setTitleReplay()
	self._ccbOwner.tf_count:setString("重置信息")
end

function QUIWidgetRobotAward:setReplay(count, price)
	self._ccbOwner.sp_exp:setVisible(false)
	self._ccbOwner.tf_exp:setString("")
	self._ccbOwner.sp_money:setVisible(false)
	self._ccbOwner.tf_money:setString("")
	self._ccbOwner.sp_invasionMoney:setVisible(false)
	self._ccbOwner.tf_invasionMoney:setString("")
	self._ccbOwner.tf_tips:setString("")
	self._ccbOwner.tf_double:setVisible(false)

	self._ccbOwner.tf_replayCount_title:setString("重置关卡次数：")
	self._ccbOwner.tf_replayCount:setString(count)
	self._ccbOwner.tf_replayPrice_title:setString("重置消耗：")
	self._ccbOwner.tf_replayPrice:setString(price)
	self._ccbOwner.sp_token:setVisible(true)
	self._isReplay = true
end

function QUIWidgetRobotAward:setInfo(info, yield, yieldLevel, activityYield)
	local awards = {}
	if info ~= nil then
	  	for _, value in pairs(info) do 
	  		local id = value.id
	  		if id == nil then
	  			id = "type"..value.type
	  		end
	  	 	if awards[id] == nil then
	  	 		awards[id] = clone(value)
	  	 	else
	  	 		awards[id].count = awards[id].count + value.count
	  	 	end
	  	end
	end
	for _,value in pairs(awards) do
		local typeName = remote.items:getItemType(value.type)
		if typeName == ITEM_TYPE.MONEY then
			-- 普通月卡激活翻倍
			if remote.instance:checkDungeonType(self._dungeonType) and remote.activity:checkMonthCardActive(1) then
				self._ccbOwner.tf_double:setVisible(true)
			end
			self._ccbOwner.tf_money:setString("+"..tostring(value.count))
		elseif typeName == ITEM_TYPE.TEAM_EXP then
			self._ccbOwner.tf_exp:setString("+"..tostring(value.count))
		else
			local index = #self._itemsBox + 1
			if index > 6 then self._isLong = true end
			if self._ccbOwner["goods"..index] == nil then
				break
			end
			local item = QUIWidgetItemsBox.new({ccb = "small"})
			self._itemsBox[index] = item
			item:setGoodsInfo(value.id,typeName,value.count)
			self._ccbOwner["goods"..index]:addChild(item)
			item:setVisible(false)
			item:setPromptIsOpen(true)
			
			local activityYield = value.activity_yield or 1
			if activityYield > 1 and not self._isTotal then
				self._itemsBox[index]:setRateActivityState(true)	
			end
			if value.isActivity then
				self._itemsBox[index]:setAwardName("活动")	
			end
		end
	end

	if yield ~= nil and yield > 1 and self._ccbOwner["goods"..#self._itemsBox] ~= nil then
		self:setYieldInfo(yield, yieldLevel)
	end
end

function QUIWidgetRobotAward:setInvasionMoney(invasionMoney)
	if invasionMoney == nil or invasionMoney <= 0 then return end
	self._ccbOwner.sp_invasionMoney:setVisible(true)
	self._ccbOwner.tf_invasionMoney:setVisible(true)
	self._ccbOwner.tf_invasionMoney:setString("+"..invasionMoney)
end

-- 显示货币暴击特效
function QUIWidgetRobotAward:setYieldInfo(yield, yieldLevel)
	self._yieldAnimation = QUIWidgetAnimationPlayer.new()
	self._ccbOwner["goods"..#self._itemsBox]:addChild(self._yieldAnimation)
	self._yieldAnimation:setVisible(false)
	self._yieldAnimation:setPosition(ccp(100, -35))
	self._yieldAnimation:playAnimation("ccb/effects/baoji_shuzi2.ccbi", function(ccbOwner)
			for i = 1, 3, 1 do
				ccbOwner["sp_crit"..i]:setVisible(false)
			end
			ccbOwner["sp_crit"..yieldLevel]:setVisible(true)
			ccbOwner["tf_crit"..yieldLevel]:setString(yield)
		end, function()end, false)
end

function QUIWidgetRobotAward:startAnimation(callFunc)
	self._animationEndCallback = callFunc
    local animationManager = tolua.cast(self:getCCBView():getUserObject(), "CCBAnimationManager")
    animationManager:runAnimationsForSequenceNamed("TitleExperienceAndMoney")
    animationManager:connectScriptHandler(function(animationName)
    	animationManager:disconnectScriptHandler()
        self:_startPlayItemAnimation()
    end)
end

function QUIWidgetRobotAward:_startPlayItemAnimation()
	if #self._itemsBox == 0 then
		-- self._ccbOwner.tf_tips:setVisible(true)
		if self._animationEndCallback ~= nil then
			self._animationEndCallback()
		end
	else
		self:_playItemAnimation(1)
	end
end

function QUIWidgetRobotAward:_playItemAnimation(index)
	if index == nil then
		-- 不一个一个显示
		
	elseif #self._itemsBox < index then
		if self._yieldAnimation ~= nil then
			self._yieldAnimation:setVisible(true)
		end
		if self._animationEndCallback ~= nil then
			self._animationEndCallback()
		end
	else
		local widgetItem = self._itemsBox[index]
		widgetItem:setVisible(true)
		widgetItem:setScaleX(0)
		widgetItem:setScaleY(0)
	    local actionArrayIn = CCArray:create()
        actionArrayIn:addObject(CCEaseBackInOut:create(CCScaleTo:create(0.02, 1, 1)))
        actionArrayIn:addObject(CCCallFunc:create(function ()
	        self:_playItemAnimation(index + 1)
        end))
	    local ccsequence = CCSequence:create(actionArrayIn)
		local handler = widgetItem:runAction(ccsequence)
	end
end

return QUIWidgetRobotAward