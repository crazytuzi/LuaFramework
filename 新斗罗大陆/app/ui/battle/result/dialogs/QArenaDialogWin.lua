--
-- Author: Your Name
-- Date: 2015-01-19 20:39:10
--
local QBattleDialogBaseFightEnd = import(".QBattleDialogBaseFightEnd")
local QArenaDialogWin = class("QArenaDialogWin", QBattleDialogBaseFightEnd)

local QUIWidgetItemsBox = import("....widgets.QUIWidgetItemsBox")

function QArenaDialogWin:ctor(options, owner)
	print("<<<QArenaDialogWin>>>")
	--设置该节点启用enter事件
	self:setNodeEventEnabled(true)
	QArenaDialogWin.super.ctor(self, options, owner)
	self._audioHandler = app.sound:playSound("battle_complete")

	local isWin = options.isWin

	if isWin then
		local exp = options.exp
		local score = options.score
		local money = options.money
		local awards = options.awards
		local yield = options.yield
		local activityYield = options.activityYield
		local isMockBattle = options.isMockBattle or false

		self._ccbOwner.node_bg_win:setVisible(true)

	    self._ccbOwner.node_win_client:setVisible(true)

	    self._ccbOwner.node_win_text_title:setVisible(true)
	    self:setWinTextTitle({"zhan", "dou", "sheng", "li"})

	    -- exp money score
		self._ccbOwner.tf_score:setString("+"..score)
		self._ccbOwner.node_score:setVisible(true)
		self._ccbOwner.tf_money:setString("+"..money)
		self._ccbOwner.node_money:setVisible(true)
		self._ccbOwner.node_exp_money_score:setVisible(true)
		if isMockBattle then
			self._ccbOwner.node_exp_money_score:setVisible(false)
			self._ccbOwner.node_no_tips:setVisible(true)
			self._ccbOwner.node_no_tips:setString("本轮挑战结束后统一发放")
		end
	    -- hero head
		-- self._ccbOwner.ly_hero_head_size:setVisible(false)
		self._ccbOwner.node_hero_head:setVisible(true)
	   	local heroHeadCount = self:setHeroInfo(exp)
	   	-- hero head 中心对齐
		if self.heroBox and heroHeadCount > 0 then
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
	    
	    -- print("yield = ", yield)
	    QPrintTable(awards)
		for _, value in ipairs(awards) do
			local node = self._ccbOwner["node_award_normal_item_"..i]
			if node then
				if value.type ~= ITEM_TYPE.TEAM_EXP and value.type ~= ITEM_TYPE.MONEY and value.type ~= "TOKEN" and value.type ~= "token" then
					itemsBox[i] = QUIWidgetItemsBox.new()
			    	itemsBox[i]:setVisible(false)
			    	itemsBox[i]:setPromptIsOpen(true)
			    	itemsBox[i]:resetAll()
			    	betAwardCountList[i] = value.count
					self:setBoxInfo(itemsBox[i], value.id, value.type, betAwardCountList[i])
					if activityYield and activityYield > 1 and (value.type == ITEM_TYPE.ARENA_MONEY or value.type == ITEM_TYPE.TOWER_MONEY) then
						itemsBox[i]:setRateActivityState(true, activityYield)
					end
					if boxWidth == 0 then
			    		boxWidth = itemsBox[i]:getContentSize().width
			    	end
					node:addChild(itemsBox[i])
					i = i + 1
				elseif isMockBattle then
					if value.type == "TOKEN" or  value.type == "token" then
						itemsBox[i] = QUIWidgetItemsBox.new()
				    	itemsBox[i]:setVisible(false)
				    	itemsBox[i]:setPromptIsOpen(true)
				    	itemsBox[i]:resetAll()
				    	betAwardCountList[i] = math.ceil(value.count / yield)
						self:setBoxInfo(itemsBox[i], value.id, value.type, betAwardCountList[i])
						if activityYield and activityYield > 1 and (value.type == ITEM_TYPE.ARENA_MONEY or value.type == ITEM_TYPE.TOWER_MONEY) then
							itemsBox[i]:setRateActivityState(true, activityYield)
						end
						if boxWidth == 0 then
				    		boxWidth = itemsBox[i]:getContentSize().width
				    	end
				    	itemsBox[i]:setFirstAward(true)
						node:addChild(itemsBox[i])
						i = i + 1
					end
				end
			else
				break
			end
		end

		if options.extraAwards then
			local extraAwards = string.split(options.extraAwards, ";")
			if extraAwards[1] then
				local award = string.split(extraAwards[1], "^")

				local node = self._ccbOwner["node_award_normal_item_"..i]
				if node then
					itemsBox[i] = QUIWidgetItemsBox.new()
			    	itemsBox[i]:setPromptIsOpen(true)
			    	itemsBox[i]:resetAll()
			    	local itemType = ITEM_TYPE.ITEM
			    	if tonumber(award[1]) == nil then
			    		itemType = award[1]
			    	end
					self:setBoxInfo(itemsBox[i], tonumber(award[1]), itemType, tonumber(award[2]))
					node:addChild(itemsBox[i])
					itemsBox[i]:setGloryTowerType(true)
				end
			end
		end

		-- award normal 中心对齐
		local awardsNum = i - 1
		if awardsNum > 0 then
			local posX = self._ccbOwner.node_award_normal_client:getPositionX() + 10
			self._ccbOwner.node_award_normal_client:setPositionX(posX + ((6 - awardsNum) * 79 / 2))
		end

		local maxBetAwardCountIndex = table.nums(betAwardCountList)
		print("maxBetAwardCountIndex = ", maxBetAwardCountIndex)
		if yield ~= nil and yield > 1 then
			self._yieldScheduler = scheduler.performWithDelayGlobal(function()
				for index, betAwardCount in pairs(betAwardCountList) do
					local node = self._ccbOwner["node_award_normal_item_"..index]
					if index >= maxBetAwardCountIndex then
						self:setYieldInfo(yield, "arena_money_crit", betAwardCount, node, 1, ccp( 120, -40 ), false, true, itemsBox[index])
					end
				end
			end, 0)
		end
	else
		-- makeNodeFromNormalToGray(self._ccbOwner.node_bg_mvp)

		self._ccbOwner.node_bg_lost:setVisible(true)
		self._ccbOwner.node_lost_client:setVisible(true)

		self:hideAllPic()
		self:chooseBestGuide()
	end
end

function QArenaDialogWin:onEnter()
    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)
end

function QArenaDialogWin:onExit()
   	if self.prompt ~= nil then
   		self.prompt:removeItemEventListener()
   	end
    if self._yieldScheduler ~= nil then
    	scheduler.unscheduleGlobal(self._yieldScheduler)
    	self._yieldScheduler = nil
    end
end

function QArenaDialogWin:_onTriggerNext()
  	app.sound:playSound("common_item")
	self:_onClose()
end

return QArenaDialogWin