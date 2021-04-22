--
-- Author: Kumo
-- Date: 2014-07-14 15:41:41
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetRobotInvasionAward = class("QUIWidgetRobotInvasionAward", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIWidgetRobotInvasionAward:ctor(options)
	local ccbFile = "ccb/Widget_RobotInvasionAward.ccbi"
	local callbacks = {}
	--设置该节点启用enter事件
	self:setNodeEventEnabled(true)
	QUIWidgetRobotInvasionAward.super.ctor(self, ccbFile, callbacks, options)

	self._itemsBox = {}
	self._ccbOwner.tf_useCount:setString("")
	self._ccbOwner.tf_hurtNum:setString("")
	self._ccbOwner.tf_intrusionMoney:setString("0")
	self._ccbOwner.tf_oldValue_1:setString("")
	self._ccbOwner.tf_newValue_1:setString("")
	self._ccbOwner.tf_oldValue_2:setString("")
	self._ccbOwner.tf_newValue_2:setString("")
	self._ccbOwner.tf_titleName:setString("")
	self._ccbOwner.node_token:setVisible(false)
	self._ccbOwner.node_killed:setVisible(false)
	self._ccbOwner.tf_titleName_title:setString("遭遇")
	self._ccbOwner.tf_titleName_title:setColor(COLORS.m)
	--设置动画时长
	self._animationTime = 0.5
	self._showItemsTime = 0.5
	self._isShow = false
end

function QUIWidgetRobotInvasionAward:getHeight()
	return self._ccbOwner.node_size:getContentSize().height + 10
end

function QUIWidgetRobotInvasionAward:getWidth()
	return self._ccbOwner.node_size:getContentSize().width
end

-- function QUIWidgetRobotInvasionAward:getInvasionMoney()
-- 	return self._intrusionMoney or 0
-- end

function QUIWidgetRobotInvasionAward:setInfo(info)
	-- QPrintTable(info)
	if not info then return end
	
	local level = info.fightCount

	if info.bossHp == 0 then
		-- self._ccbOwner.node_killed:setVisible(true)
		self._ccbOwner.tf_titleName_title:setString("击杀")
		self._ccbOwner.tf_titleName_title:setColor(COLORS.j)
	else
		level = info.fightCount + 1
	end
	
    local maxLevel = db:getIntrusionMaximumLevel(info.bossId)
    level = math.min(level, maxLevel)
	local name = string.format("%s(LV.%d)", QStaticDatabase:sharedDatabase():getCharacterByID(info.bossId).name, level)
	self._ccbOwner.tf_titleName:setString( name )
	self._ccbOwner.tf_killedName:setString( name )
	
	-- Show boss color
	local bossColor = remote.invasion:getBossColorByType(info.boss_type)
    self._ccbOwner.tf_titleName:setColor(bossColor)
    self._ccbOwner.tf_titleName = setShadowByFontColor(self._ccbOwner.tf_titleName, bossColor)
    self._ccbOwner.tf_killedName:setColor(bossColor)
    
	self._ccbOwner.tf_useCount:setString( "魂兽入侵攻击次数 "..(info.criticalHit or 0) )
	local num, unit = q.convertLargerNumber( info.totalDamage or 0 )
	self._ccbOwner.tf_hurtNum:setString( num..(unit or "") )
	self._intrusionMoney = remote.user.intrusion_money - (info.oldInvasionMoney or 0)
	self._ccbOwner.tf_intrusionMoney:setString( self._intrusionMoney or 0 )
	self._ccbOwner.tf_oldValue_1:setString( info.oldAllHurtRank or 0 )
	self._ccbOwner.tf_newValue_1:setString( info.allHurtRank or 0 )
	self._ccbOwner.tf_oldValue_2:setString( info.oldMaxHurtRank or 0 )
	self._ccbOwner.tf_newValue_2:setString( info.maxHurtRank or 0 )
end

function QUIWidgetRobotInvasionAward:startAnimation(callFunc)
	self._animationEndCallback = callFunc
    local animationManager = tolua.cast(self:getCCBView():getUserObject(), "CCBAnimationManager")
    animationManager:runAnimationsForSequenceNamed("TitleExperienceAndMoney")
    animationManager:connectScriptHandler(function(animationName)
    	animationManager:disconnectScriptHandler()
        self:_startPlayItemAnimation()
    end)
end

function QUIWidgetRobotInvasionAward:_startPlayItemAnimation()
	if #self._itemsBox == 0 then
		-- self._ccbOwner.tf_tips:setVisible(true)
		if self._animationEndCallback ~= nil then
			self._animationEndCallback()
		end
	else
		self:_playItemAnimation(1)
	end
end

function QUIWidgetRobotInvasionAward:_playItemAnimation(index)
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

return QUIWidgetRobotInvasionAward