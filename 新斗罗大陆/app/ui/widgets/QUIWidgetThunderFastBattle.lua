local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetThunderFastBattle = class("..widgets.QUIWidgetThunderFastBattle", QUIWidget)
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIWidgetThunderFastBattle:ctor(options)
	local ccbFile = "ccb/Widget_EliteBattleAgain_thunderking.ccbi"
	local callbacks = {}
	--设置该节点启用enter事件
	self:setNodeEventEnabled(true)
	QUIWidgetThunderFastBattle.super.ctor(self, ccbFile, callbacks, options)
	self._itemsBox = {}
	-- self._ccbOwner.tf_exp:setString("+0")
	self._ccbOwner.tf_money:setString("+0")--设置动画时长
	self._animationTime = 0.5
	self._showItemsTime = 0.5
	self._isShow = false

	self._moneyTotal = 0
	self._expTotal = 0

	self._ccbOwner.tf_tips:setVisible(false)
end

function QUIWidgetThunderFastBattle:onExit()
	if self._yieldAnimation ~= nil then
		self._yieldAnimation:disappear()
		self._yieldAnimation = nil
	end
end 

function QUIWidgetThunderFastBattle:getHeight()
	return self._ccbOwner.node_size:getContentSize().height + 10
end

function QUIWidgetThunderFastBattle:getWidth()
	return self._ccbOwner.node_size:getContentSize().width
end

function QUIWidgetThunderFastBattle:setTitle(str)
	self._ccbOwner.tf_count:setString(str)
end

function QUIWidgetThunderFastBattle:setTitleExtra(str)
	self:setTitle(str or "")

	-- self._ccbOwner.sprite_icon:setVisible(false)
	-- self._ccbOwner.tf_money:setVisible(false)

	-- self._ccbOwner.tf_tips:setPositionY(self._ccbOwner.tf_tips:getPositionY() + 50)
	-- self._ccbOwner.goods1:setPositionY(self._ccbOwner.goods1:getPositionY() + 50)
	-- self._ccbOwner.goods2:setPositionY(self._ccbOwner.goods2:getPositionY() + 50)
	-- self._ccbOwner.goods3:setPositionY(self._ccbOwner.goods3:getPositionY() + 50)
	-- self._ccbOwner.goods4:setPositionY(self._ccbOwner.goods4:getPositionY() + 50)
	-- self._ccbOwner.goods5:setPositionY(self._ccbOwner.goods5:getPositionY() + 50)
	-- self._ccbOwner.goods6:setPositionY(self._ccbOwner.goods6:getPositionY() + 50)
end

function QUIWidgetThunderFastBattle:setInfo(info, yield, activityYield, userComeBackRatio)
	local awards = {}
	local config = QStaticDatabase:sharedDatabase():getConfig()
	for i = 1, #info do
		local typeName = remote.items:getItemType(info[i].type)
		if typeName == ITEM_TYPE.MONEY then
			self._moneyTotal = info[i].count
			self._ccbOwner.tf_money:setString("+"..tostring(self._moneyTotal))
		else
			local index = #self._itemsBox + 1
			local item = QUIWidgetItemsBox.new({ccb = "small"})
			self._itemsBox[index] = item
			item:setGoodsInfo(info[i].id, typeName, info[i].count)
			self._ccbOwner["goods"..index]:addChild(item)
			item:setVisible(false)
  			local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(info[i].id)
  			if userComeBackRatio and userComeBackRatio > 0 then
  				activityYield = ((activityYield or 1) - 1) + ((userComeBackRatio or 1) - 1) + 1
  			end
  			if activityYield and activityYield > 1 and typeName == ITEM_TYPE.THUNDER_MONEY then
				item:setRateActivityState(true, activityYield)	
			end
		end
	end

	if yield ~= nil and yield > 1 and self._ccbOwner["goods"..#self._itemsBox] ~= nil then
		self:setYieldInfo(yield)
	end
end

-- 显示货币暴击特效
function QUIWidgetThunderFastBattle:setYieldInfo(yield)
	local yieldLevel = QStaticDatabase:sharedDatabase():getYieldLevelByYieldData(yield, "thunder_money_crit")

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

function QUIWidgetThunderFastBattle:startAnimation(callFunc)
	self._animationEndCallback = callFunc
    local animationManager = tolua.cast(self:getCCBView():getUserObject(), "CCBAnimationManager")
    animationManager:runAnimationsForSequenceNamed("TitleExperienceAndMoney")
    animationManager:connectScriptHandler(function(animationName)
    	animationManager:disconnectScriptHandler()
        self:_startPlayItemAnimation()
    end)
end

function QUIWidgetThunderFastBattle:_startPlayItemAnimation()
	if #self._itemsBox == 0 then
		self._ccbOwner.tf_tips:setVisible(true)
		if self._animationEndCallback ~= nil then
			self._animationEndCallback()
		end
	else
		self:_playItemAnimation(1)
	end
end

function QUIWidgetThunderFastBattle:_playItemAnimation(index)
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
        actionArrayIn:addObject(CCEaseBackInOut:create(CCScaleTo:create(0.23, 1, 1)))
        actionArrayIn:addObject(CCCallFunc:create(function ()
	        self:_playItemAnimation(index + 1)
        end))
	    local ccsequence = CCSequence:create(actionArrayIn)
		local handler = widgetItem:runAction(ccsequence)
	end
end

function QUIWidgetThunderFastBattle:showByNoAnimation()
	if self._yieldAnimation ~= nil then
		self._yieldAnimation:setVisible(true)
	end
	if #self._itemsBox == 0 then
        self._ccbOwner.tf_tips:setVisible(true)
    else
        for j = 1, #self._itemsBox, 1 do
            self._itemsBox[j]:setVisible(true)
        end
    end
end

return QUIWidgetThunderFastBattle
