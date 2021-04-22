--
-- Author: Your Name
-- Date: 2015-01-19 20:39:10
--
local QBattleDialogBaseFightEnd = import(".QBattleDialogBaseFightEnd")
local QBattleDialogSunWell = class("QBattleDialogSunWell", QBattleDialogBaseFightEnd)

local QUIWidgetHeroHead = import("....widgets.QUIWidgetHeroHead")
local QUIWidgetItemsBox = import("....widgets.QUIWidgetItemsBox")
local QTextFiledScrollUtils = import(".....utils.QTextFiledScrollUtils")
local QUIWidgetAnimationPlayer = import("....widgets.QUIWidgetAnimationPlayer")
local QStaticDatabase = import(".....controllers.QStaticDatabase")

function QBattleDialogSunWell:ctor(options, owner)
	print("<<<QBattleDialogSunWell>>>")
	--设置该节点启用enter事件
	self:setNodeEventEnabled(true)
	QBattleDialogSunWell.super.ctor(self, options, owner)
	self._audioHandler = app.sound:playSound("battle_complete")

	local isWin = options.isWin

	if isWin then
		local exp = options.exp
		local money = options.money
		local awards = options.awards
		local yield = options.yield
		local activityYield = options.activityYield
		local isTimeOver = options.isTimeOver

		self._ccbOwner.node_bg_win:setVisible(true)

	    self._ccbOwner.node_win_client:setVisible(true)

	    self._ccbOwner.node_win_text_title:setVisible(true)
	    self:setWinTextTitle({"zhan", "dou", "jie", "shu"})
	    if isTimeOver then
	    	self._ccbOwner.tf_win_title:setString("战斗若超时，则双方所有魂师同归于尽")
	    end
	    -- exp money score
		-- self._ccbOwner.tf_exp:setString(exp)
		self._ccbOwner.node_exp:setVisible(true)
		-- self._ccbOwner.tf_money:setString(money)
		self._ccbOwner.node_money:setVisible(true)
		self._ccbOwner.node_exp_money_score:setVisible(true)
		self._expUpdate = QTextFiledScrollUtils.new()
		self._moneyUpdate = QTextFiledScrollUtils.new()
		self._updateScheduler = scheduler.performWithDelayGlobal(function()
				self._expUpdate:addUpdate(0, exp, handler(self, self.onExpUpdate), 17/30)
				self._moneyUpdate:addUpdate(0, money, handler(self, self.onMoneyUpdate), 17/30, function()end)
			end, 0)
	    -- hero head
		-- self._ccbOwner.ly_hero_head_size:setVisible(false)
		self._ccbOwner.node_hero_head:setVisible(true)
	   	self:setHeroInfo(exp)
	   	-- hero head 中心对齐
	    local teamHero = remote.teamManager:getActorIdsByKey(self.teamName, 1)
	    local heroHeadCount = #teamHero
		if heroHeadCount > 0 then
			local heroTotalWidth = self.heroHeadWidth * (heroHeadCount - 1) + (self.heroBox[1]:getSize().width * 1.5)
			self._ccbOwner.node_hero_head:setPositionX( self._ccbOwner.node_hero_head:getPositionX() + (self._ccbOwner.ly_hero_head_size:getContentSize().width - heroTotalWidth) / 2 )
		end
		-- award title
		self._ccbOwner.tf_award_title:setString("战斗奖励")
    	self._ccbOwner.node_award_title:setVisible(true)
    	-- award normal
    	self._ccbOwner.node_award_normal:setVisible(true)
		self._ccbOwner.node_award_normal_client:setVisible(true)
		local itemsBox = {}
	 	local boxWidth = 0
	 	local betAwardCountList = {}
	    local i = 1
		for _, value in ipairs(awards) do
			local node = self._ccbOwner["node_award_normal_item_"..i]
			if node then
				if value.type ~= ITEM_TYPE.TEAM_EXP and value.type ~= ITEM_TYPE.MONEY and value.type ~= "TOKEN" then
					itemsBox[i] = QUIWidgetItemsBox.new()
			    	itemsBox[i]:setVisible(false)
			    	itemsBox[i]:setPromptIsOpen(true)
			    	itemsBox[i]:resetAll()
			    	betAwardCountList[i] = math.ceil(value.count / yield)
					self:setBoxInfo(itemsBox[i], value.id, value.type, betAwardCountList[i])
					if activityYield and activityYield > 1 and value.type == ITEM_TYPE.SUNWELL_MONEY then
						itemsBox[i]:setRateActivityState(true, activityYield)
					end
					if boxWidth == 0 then
			    		boxWidth = itemsBox[i]:getContentSize().width
			    	end
					node:addChild(itemsBox[i])
					i = i + 1
				end
			else
				break
			end
		end

		local awardsNum = i - 1
		-- award normal 中心对齐
		if awardsNum > 0 then
			local posX = self._ccbOwner.node_award_normal_client:getPositionX() + 10
			self._ccbOwner.node_award_normal_client:setPositionX(posX + ((6 - awardsNum) * 79 / 2))
		end

		local maxBetAwardCountIndex = table.nums(betAwardCountList)
		if yield ~= nil and yield > 1 then
			self._yieldScheduler = scheduler.performWithDelayGlobal(function()
				-- self:setYieldInfo(yield, "battlefield_box_crit", 0, self._ccbOwner.node_money, 0.7, ccp(self._ccbOwner.tf_money:getPositionX() + 130, self._ccbOwner.tf_money:getPositionY() - 10))
				for index, betAwardCount in pairs(betAwardCountList) do
					local node = self._ccbOwner["node_award_normal_item_"..index]
					if index >= maxBetAwardCountIndex then
						self:setYieldInfo(yield, "battlefield_box_crit", betAwardCount, node, 1, ccp(70, node:getPositionY() - 45), false, true, itemsBox[index])
					end
				end
			end, 0)
		end
	else
		makeNodeFromNormalToGray(self._ccbOwner.node_bg_mvp)

		self._ccbOwner.node_bg_lost:setVisible(true)
		self._ccbOwner.node_lost_client:setVisible(true)

		self:hideAllPic()
		self:chooseBestGuide()
	end
end

function QBattleDialogSunWell:onEnter()
    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)
end

function QBattleDialogSunWell:onExit()
   	if self.prompt ~= nil then
   		self.prompt:removeItemEventListener()
   	end
   	if self._updateScheduler ~= nil then
		scheduler.unscheduleGlobal(self._updateScheduler)
		self._updateScheduler = nil
   	end
   	if self._expUpdate then
        self._expUpdate:stopUpdate()
        self._expUpdate = nil
    end
    if self._moneyUpdate then
        self._moneyUpdate:stopUpdate()
        self._moneyUpdate = nil
    end
    if self._yieldScheduler ~= nil then
    	scheduler.unscheduleGlobal(self._yieldScheduler)
    	self._yieldScheduler = nil
    end
end

function QBattleDialogSunWell:_onTriggerNext()
  	app.sound:playSound("common_item")
	self:_onClose()
end

return QBattleDialogSunWell