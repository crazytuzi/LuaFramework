--
-- Author: MOUSECUTE
-- Date: 2016-07-30
--
local QBattleDialogBaseFightEnd = import(".QBattleDialogBaseFightEnd")
local QBattleDialogSilverMine = class("QBattleDialogSilverMine", QBattleDialogBaseFightEnd)

local QUIWidgetItemsBox = import("....widgets.QUIWidgetItemsBox")
local QDialogPlunderChooseCard = import(".....ui.dialogs.QDialogPlunderChooseCard")

function QBattleDialogSilverMine:ctor(options,owner)
	print("<<<QBattleDialogSilverMine>>>")
	--设置该节点启用enter事件
	self:setNodeEventEnabled(true)
	QBattleDialogSilverMine.super.ctor(self, options, owner)
	self._audioHandler = app.sound:playSound("battle_complete")

	local isWin = options.isWin
	self.isPlunder = options.isPlunder

	if isWin then
		local exp = options.exp
		local money = options.money
		local awards = options.awards
		local yield = options.yield
		local activityYeild = options.activityYeild

		self._ccbOwner.node_bg_win:setVisible(true)

	    self._ccbOwner.node_win_client:setVisible(true)

	    self._ccbOwner.node_win_text_title:setVisible(true)
	    self:setWinTextTitle({"zhan", "dou", "sheng", "li"})

	    -- exp money score
	    self._ccbOwner.tf_exp:setString("+"..exp)
		self._ccbOwner.node_exp:setVisible(true)
		self._ccbOwner.tf_money:setString("+"..money)
		self._ccbOwner.node_money:setVisible(true)
		self._ccbOwner.node_exp_money_score:setVisible(true)
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
	    -- print("yield = ", yield)
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
					if activityYeild and activityYeild > 1 and value.type == ITEM_TYPE.ARENA_MONEY then
						itemsBox[i]:setRateActivityState(true)
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
						self:setYieldInfo(yield, "arena_money_crit", betAwardCount, node, 1, ccp(node:getPositionX() + 35, node:getPositionY() - 35), false, true, itemsBox[index])
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

function QBattleDialogSilverMine:onEnter()
    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)
end

function QBattleDialogSilverMine:onExit()
   	if self.prompt ~= nil then
   		self.prompt:removeItemEventListener()
   	end
    if self._yieldScheduler ~= nil then
    	scheduler.unscheduleGlobal(self._yieldScheduler)
    	self._yieldScheduler = nil
    end
end

function QBattleDialogSilverMine:_backClickHandler()
	if not self.openTime then self.openTime = q.time() end
	
	local time = 3.5
	if not self._options.isWin  then
		time = 1.1
	end
	if q.time() - self.openTime > time then
  		self:_onTriggerNext()
  	end
end


function QBattleDialogSilverMine:_onTriggerNext()
  	app.sound:playSound("common_item")
	if self.isPlunder then
  		local lootRandomAward = remote.plunder:getLootRandomAward()
    	if lootRandomAward and lootRandomAward ~= "" then
  			self.dialogCard = QDialogPlunderChooseCard.new({rewrad = lootRandomAward}, {onCloseCard = handler(self, QBattleDialogSilverMine._onClose)})
  		else
  			self:_onClose()
  		end
  	else
		self:_onClose()
	end
end

return QBattleDialogSilverMine