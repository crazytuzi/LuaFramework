--
-- Author: Your Name
-- Date: 2014-05-19 10:58:04
--
local QBattleDialogBaseFightEnd = import(".QBattleDialogBaseFightEnd")
local QBattleDialogWelfareInstance = class(".QBattleDialogWelfareInstance", QBattleDialogBaseFightEnd)

local QUIWidgetItemsBox = import("....widgets.QUIWidgetItemsBox")
local QUIViewController = import("....QUIViewController")
local QTextFiledScrollUtils = import(".....utils.QTextFiledScrollUtils")

function QBattleDialogWelfareInstance:ctor(options,owner)
	print("<<<QBattleDialogWelfareInstance>>>")
	--设置该节点启用enter事件
	self:setNodeEventEnabled(true)
	QBattleDialogWelfareInstance.super.ctor(self, options, owner)
	self._audioHandler = app.sound:playSound("battle_complete")

	local isWin = options.isWin

	if isWin then
		local teamExp = options.teamExp
		local heroExp = options.heroExp
		local money = options.money
		local awards = options.awards
		local yield = options.yield or 1

		self._ccbOwner.node_bg_win:setVisible(true)

	    self._ccbOwner.node_win_client:setVisible(true)

	    self._ccbOwner.node_win_text_title:setVisible(true)
	    self:setWinTextTitle({"zhan", "dou", "sheng", "li"})

	    -- exp money score
		self._ccbOwner.node_exp:setVisible(true)
		self._ccbOwner.node_money:setVisible(true)
		self._ccbOwner.node_exp_money_score:setVisible(true)
		self._expUpdate = QTextFiledScrollUtils.new()
		self._moneyUpdate = QTextFiledScrollUtils.new()
		self._updateScheduler = scheduler.performWithDelayGlobal(function()
				self._expUpdate:addUpdate(0, teamExp, handler(self, self.onExpUpdate), 17/30)
				self._moneyUpdate:addUpdate(0, money, handler(self, self.onMoneyUpdate), 17/30, function()end)
				if remote.activity:checkMonthCardActive(1) then
    				self._ccbOwner.tf_money:setString(money)
    				local width = self._ccbOwner.tf_money:getContentSize().width
					self._ccbOwner.tf_double:setPositionX(self._ccbOwner.tf_money:getPositionX()+width+20)
					self._ccbOwner.tf_double:setVisible(true)
    			end
			end, 0)
	    -- hero head
		-- self._ccbOwner.ly_hero_head_size:setVisible(false)
		self._ccbOwner.node_hero_head:setVisible(true)
	   	self:setHeroInfo(heroExp)
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

	 	local betAwardCountList = {}
	 	local items = {}
	    local i = 1
		for _, value in ipairs(awards) do
			if value.type ~= ITEM_TYPE.TEAM_EXP and value.type ~= ITEM_TYPE.MONEY and value.type ~= "TOKEN" then
		    	betAwardCountList[i] = math.ceil(value.count / yield)
		    	items[#items+1] = value
				i = i + 1
			end
		end
		local awardsNum = i
		self._itemBox = self:showDropItems(items)

		local maxBetAwardCountIndex = table.nums(betAwardCountList)
		if yield ~= nil and yield > 1 and q.isEmpty(self._itemBox) == false then
			self._yieldScheduler = scheduler.performWithDelayGlobal(function()
				local pos = ccp(105, -30)
				local itemBox = self._itemBox[#self._itemBox]
				for index, betAwardCount in pairs(betAwardCountList) do
					self:setYieldInfo(yield, "battlefield_box_crit", betAwardCount, itemBox, 1, pos, false, true, itemBox)
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

function QBattleDialogWelfareInstance:onEnter()
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self._onFrame))
    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)
end

function QBattleDialogWelfareInstance:onExit()
   self:removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
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
end

function QBattleDialogWelfareInstance:_onTriggerNext()
	--@qinyuanji, wow-6314


    if self.invasion and self.invasion.bossId and self.invasion.bossId > 0 then
    	   local unlockLevel = app.unlock:getConfigByKey("UNLOCK_FORTRESS").team_level
    	local isUnlockInvasion = self.oldTeamLevel < unlockLevel and remote.user.level >= unlockLevel
	    --xurui: 要塞解锁时不弹要塞跳转界面，先拉取要塞完整信息
	    if isUnlockInvasion == false then
	    	local level = self.invasion.fightCount + 1
			local maxLevel = db:getIntrusionMaximumLevel(self.invasion.bossId)
		    level = math.min(level, maxLevel)
	        app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogInvasionEncounter", 
	            options = {actorId = self.invasion.bossId, level = level, inbattle = true, cancelCallback = function ( ... )
				  	app.sound:playSound("common_item")
				  	self:_onClose()
	            end, fightCallback = function ( ... )
				  	app.sound:playSound("common_item")
				  	self:_onClose()
	            end}}, {isPopCurrentDialog = false})
	    else
            remote.invasion:getInvasionRequest()
		  	app.sound:playSound("common_item")
		  	self:_onClose()
	    end
    else
	  	app.sound:playSound("common_item")
	  	self:_onClose()
    end
end

return QBattleDialogWelfareInstance