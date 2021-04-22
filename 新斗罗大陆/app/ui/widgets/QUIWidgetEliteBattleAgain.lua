--
-- Author: wkwang
-- Date: 2014-07-14 15:41:41
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetEliteBattleAgain = class("QUIWidgetEliteBattleAgain", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIWidgetEliteBattleAgain:ctor(options)
	local ccbFile = "ccb/Widget_EliteBattleAgain.ccbi"
	local callbacks = {}
	--设置该节点启用enter事件
	self:setNodeEventEnabled(true)
	QUIWidgetEliteBattleAgain.super.ctor(self, ccbFile, callbacks, options)

	self._itemsBox = {}
	self._ccbOwner.tf_exp:setString("+0")
	self._ccbOwner.tf_money:setString("+0")
	--设置动画时长
	self._animationTime = 0.5
	self._showItemsTime = 0.5
	self._isShow = false

	self._ccbOwner.tf_tips:setVisible(false)
	self._ccbOwner.sp_score:setVisible(false)
	self._ccbOwner.tf_score:setVisible(false)
	self._ccbOwner.tf_double:setVisible(false)
end

function QUIWidgetEliteBattleAgain:getHeight()
	return self._ccbOwner.node_size:getContentSize().height + 10
end

function QUIWidgetEliteBattleAgain:getWidth()
	return self._ccbOwner.node_size:getContentSize().width
end

function QUIWidgetEliteBattleAgain:setTitle(title)
	self._ccbOwner.tf_count:setString(title)
end

function QUIWidgetEliteBattleAgain:setDungeonType(dungeonType)
	self._dungeonType = dungeonType
end

function QUIWidgetEliteBattleAgain:setTitleExtra()
	self._ccbOwner.tf_count:setString("额外奖励")

	self._ccbOwner.sprite_exp:setVisible(false)
	self._ccbOwner.tf_exp:setVisible(false)
	self._ccbOwner.sprite_icon:setVisible(false)
	self._ccbOwner.tf_money:setVisible(false)

	self._ccbOwner.tf_tips:setPositionY(self._ccbOwner.tf_tips:getPositionY() + 50)
	self._ccbOwner.goods1:setPositionY(self._ccbOwner.goods1:getPositionY() + 50)
	self._ccbOwner.goods2:setPositionY(self._ccbOwner.goods2:getPositionY() + 50)
	self._ccbOwner.goods3:setPositionY(self._ccbOwner.goods3:getPositionY() + 50)
	self._ccbOwner.goods4:setPositionY(self._ccbOwner.goods4:getPositionY() + 50)
	self._ccbOwner.goods5:setPositionY(self._ccbOwner.goods5:getPositionY() + 50)
	self._ccbOwner.goods6:setPositionY(self._ccbOwner.goods6:getPositionY() + 50)
end

function QUIWidgetEliteBattleAgain:setInfo(info, yield, yieldLevel, activityYield, userComeBackRatio)
	local awards = {}
	if info ~= nil then
	  	for _, value in pairs(info) do 
	  		if value.type == nil then
	  			value.type = value.typeName
	  		end
	  		local id = value.id
	  		if id == nil then
	  			id = "type"..(value.type)
	  		end
	  	 	if awards[id] == nil then
	  	 		awards[id] = clone(value)
	  	 	else
	  	 		awards[id].count = awards[id].count + value.count
	  	 	end
	  	end
	end

	local index = 1
	local sortAward = {}
  	for _, value in pairs(awards) do 
  		sortAward[index] = value
  		index = index + 1
  	end
	table.sort( sortAward, function(a, b)
		local typeName1 = remote.items:getItemType(a.type)
		local typeName2 = remote.items:getItemType(b.type)
		if typeName1 ~= typeName2 then
			return typeName1 == "item"
		end
	end)

	local config = QStaticDatabase:sharedDatabase():getConfig()
	for _,value in pairs(sortAward) do
		local typeName = remote.items:getItemType(value.type)
		if typeName == ITEM_TYPE.MONEY then
			-- 普通月卡激活翻倍
			if remote.instance:checkDungeonType(self._dungeonType) and remote.activity:checkMonthCardActive(1) then
				self._ccbOwner.tf_double:setVisible(true)
			end
			self._ccbOwner.tf_money:setString(string.format("+%d", value.count))
		elseif typeName == ITEM_TYPE.TEAM_EXP then
			self._ccbOwner.tf_exp:setString("+"..tostring(value.count))
		else
			local index = #self._itemsBox + 1
			if self._ccbOwner["goods"..index] == nil then
				break
			end
			local item = QUIWidgetItemsBox.new({ccb = "small"})
			self._itemsBox[index] = item
			item:setGoodsInfo(value.id,typeName,value.count)
			self._ccbOwner["goods"..index]:addChild(item)
			item:setVisible(false)
			item:setPromptIsOpen(true)
			if userComeBackRatio and userComeBackRatio > 0 then
				value.activity_yield = ((value.activity_yield or 1) - 1) + ((activityYield or 1) - 1) + ((userComeBackRatio or 1) - 1) + 1
			else
				value.activity_yield = ((value.activity_yield or 1) - 1) + ((activityYield or 1) - 1) + 1
			end
			-- 这里是很多快速扫荡都调用的，typeName == ITEM_TYPE.STORM_MONEY可补充，不可随意删除。
			if userComeBackRatio and userComeBackRatio > 1 then
				if value.activity_yield and value.activity_yield > 1 and typeName == ITEM_TYPE.STORM_MONEY then
					self._itemsBox[index]:setRateActivityState(true, value.activity_yield)
				end
			else
				if value.activity_yield and value.activity_yield > 1 then
					self._itemsBox[index]:setRateActivityState(true, value.activity_yield)
				end
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

function QUIWidgetEliteBattleAgain:setScore(score)
	if score == nil or score <= 0 then return end
	self._ccbOwner.sp_score:setVisible(true)
	self._ccbOwner.tf_score:setVisible(true)
	self._ccbOwner.tf_score:setString("+"..score)
end

-- 显示货币暴击特效
function QUIWidgetEliteBattleAgain:setYieldInfo(yield, yieldLevel)
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

function QUIWidgetEliteBattleAgain:startAnimation(callFunc)
	self._animationEndCallback = callFunc
    local animationManager = tolua.cast(self:getCCBView():getUserObject(), "CCBAnimationManager")
    animationManager:runAnimationsForSequenceNamed("TitleExperienceAndMoney")
    animationManager:connectScriptHandler(function(animationName)
    	animationManager:disconnectScriptHandler()
        self:_startPlayItemAnimation()
    end)
end

function QUIWidgetEliteBattleAgain:_startPlayItemAnimation()
	if #self._itemsBox == 0 then
		-- self._ccbOwner.tf_tips:setVisible(true)
		if self._animationEndCallback ~= nil then
			self._animationEndCallback()
		end
	else
		self:_playItemAnimation(1)
	end
end

function QUIWidgetEliteBattleAgain:_playItemAnimation(index)
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
		widgetItem:setScaleX(0)
		widgetItem:setScaleY(0)
	    local actionArrayIn = CCArray:create()
        actionArrayIn:addObject(CCEaseBackInOut:create(CCScaleTo:create(0.11, 1, 1)))
        actionArrayIn:addObject(CCCallFunc:create(function ()
	        self:_playItemAnimation(index + 1)
        end))
	    local ccsequence = CCSequence:create(actionArrayIn)
		local handler = widgetItem:runAction(ccsequence)
	end
end

return QUIWidgetEliteBattleAgain