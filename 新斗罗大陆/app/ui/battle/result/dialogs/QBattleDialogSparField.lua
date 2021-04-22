local QBattleDialog = import("...QBattleDialog")
local QBattleDialogSparField = class("QBattleDialogSparField", QBattleDialog)

local QUIWidgetHeroHead = import("....widgets.QUIWidgetHeroHead")
local QBattleDialogAgainstRecord = import(".....ui.battle.QBattleDialogAgainstRecord")
local QUIWidgetItemsBox = import("....widgets.QUIWidgetItemsBox")
local QUIWidgetAnimationPlayer = import("....widgets.QUIWidgetAnimationPlayer")
local QUIWidgetAvatar = import("....widgets.QUIWidgetAvatar")
local QStaticDatabase = import(".....controllers.QStaticDatabase")
local QUIWidgetTitelEffect = import("....widgets.QUIWidgetTitelEffect")

function QBattleDialogSparField:ctor(options,owner)
	local ccbFile = "ccb/Dialog_StormArena_fightwin.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerNext", callback = handler(self, QBattleDialogSparField._onTriggerNext)},
		{ccbCallbackName = "onTriggerData", callback = handler(self, QBattleDialogSparField._onTriggerData)},
	}
	if owner == nil then 
		owner = {}
	end
	--
	self:setNodeEventEnabled(true)
	QBattleDialogSparField.super.ctor(self,ccbFile,owner,callBacks)
	
	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)
	
	-- setShadow5(self._ccbOwner.tip)
	local difficulty = options.difficulty or 0
	for i=1,6 do 
		self._ccbOwner["star"..i]:setVisible(options.isWin and difficulty >= i)
	end
	
	self._ccbOwner.node_title_win:setVisible(options.isWin)
	self._ccbOwner.node_title_lose:setVisible(not options.isWin)

	self.info = options.info
	self._ccbOwner.node_normal:setVisible(false)
	self._ccbOwner.node_score:setVisible(false)
	self._ccbOwner.tf_exp:setString("+0")
	self._ccbOwner.tf_money:setString("+0")
	self._ccbOwner.tf_score:setString("+"..(self.info.arenaRewardIntegral or 0))

	local spriteFrame = QSpriteFrameByPath(QResPath("StormArena_S")[self.info.team1Score+1])
    if spriteFrame then
		self._ccbOwner.team1Score1:setDisplayFrame(spriteFrame)
		self._ccbOwner.team1Score2:setDisplayFrame(spriteFrame)
	end

	spriteFrame = QSpriteFrameByPath(QResPath("StormArena_S")[self.info.team2Score+1])
    if spriteFrame then
		self._ccbOwner.team2Score1:setDisplayFrame(spriteFrame)
		self._ccbOwner.team2Score2:setDisplayFrame(spriteFrame)
	end
	

	self._ccbOwner.team1Name:setString(self.info.team1Name or "")
	self._ccbOwner.team2Name:setString(self.info.team2Name or "")

	local team1avatar = QUIWidgetAvatar.new(self.info.team1avatar)
	local team2avatar = QUIWidgetAvatar.new(self.info.team2avatar)
    self._ccbOwner.team1Head:addChild(team1avatar)
    self._ccbOwner.team2Head:addChild(team2avatar)
	
 --    self.rankInfo = {}
	-- if options.rankInfo ~= nil then
	--    self.rankInfo = options.rankInfo
	-- end
	
 	self._itemsBox = {}
	local awards = {}
	local response = options.response
	if response and response.gfEndResponse and response.gfEndResponse.sparFieldFightEndResponse and response.gfEndResponse.sparFieldFightEndResponse.fightEndReward then
		local awardStr = response.gfEndResponse.sparFieldFightEndResponse.fightEndReward
		awardStr = string.split(awardStr, ";")
		for _,str in ipairs(awardStr) do
			if str ~= "" then
				local v = string.split(str, "^")
				local count = tonumber(v[2])
				local typeName = remote.items:getItemType(v[1])
				local id = nil
				if typeName == nil then
					typeName = ITEM_TYPE.ITEM
					id = tonumber(v[1])
				end
				table.insert(awards, {id = id, type = typeName, count = count or 0})
			end
		end
	end
	
	-- if options.rankInfo and type(options.rankInfo.extraExpItem) == "table" then
	-- 	for _, value in pairs(options.rankInfo.extraExpItem) do
	-- 		table.insert(awards, {id = value.id or 0, type = value.type, count = value.count or 0})
	-- 	end
	-- end

	local yield = 1
	-- local activityYield
	-- local currencyType = ITEM_TYPE.STORM_MONEY
	-- local count = self.info.stormMoney
	-- if options.isMaritime then
	-- 	currencyType = ITEM_TYPE.MARITIME_MONEY
	-- 	count = self.info.maritimeMoney or 0
	-- 	self._ccbOwner.node_score:setVisible(false)
	-- 	if count > 0 then
	-- 		table.insert(awards,{type = currencyType, count = count})
	-- 	end
	-- else
	-- 	table.insert(awards,{type = currencyType, count = count})
	-- end
	-- yield = self.rankInfo.stormMoneyYield or 1
	-- activityYield = self.rankInfo.stormMoneyActivityYield or 1
	
	

	local itemCount = 0
	for index,value in ipairs(awards) do
    	self._itemsBox[index] = QUIWidgetItemsBox.new()
    	self._itemsBox[index]:setPromptIsOpen(true)
		if self._ccbOwner["item"..index] then
			self._ccbOwner["item"..index]:addChild(self._itemsBox[index])
			itemCount = math.ceil((value.count or 0) / yield)
			self._itemsBox[index]:setGoodsInfo(value.id,value.type,itemCount)
		end
		-- if activityYield > 1 and value.type == ITEM_TYPE.STORM_MONEY then
		-- 	self._itemsBox[index]:setRateActivityState(true)	
		-- end
	end

	local awardsNum = #awards
	if awardsNum < 5 and awardsNum > 0 then
		self._ccbOwner.node_item:setPositionX(-(awardsNum - 1) * 96/2)
	end


	centerAlignBattleDialogVictory2(self._ccbOwner, nil, nil, self._itemsBox, awardsNum)

	-- if yield ~= nil and yield > 1 and self._ccbOwner["item"..#self._itemsBox] ~= nil then
	-- 	self._yieldScheduler = scheduler.performWithDelayGlobal(function()
	-- 		self:setYieldInfo(yield, itemCount)
	-- 	end, 3)
	-- end

	-- if options.isWin == true and options.rivalId and options.isMaritime == nil then
		
	-- 	remote.stormArena:setTopRankUpdate(self.rankInfo, options.rivalId)
		
	-- end
  	
  	if options.isWin then
		self._audioHandler = app.sound:playSound("battle_complete")
	else
		self._audioHandler = app.sound:playSound("battle_failed")
	end
    audio.stopBackgroundMusic()
	
	self._openTime = q.time()
end

function QBattleDialogSparField:onEnter()
    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)
end

function QBattleDialogSparField:onExit()
   	if self.prompt ~= nil then
   		self.prompt:removeItemEventListener()
   	end
    -- if self._yieldScheduler ~= nil then
    -- 	scheduler.unscheduleGlobal(self._yieldScheduler)
    -- 	self._yieldScheduler = nil
    -- end
end

-- 
-- function QBattleDialogSparField:setYieldInfo(yield, itemCount)
-- 	local yieldLevel = QStaticDatabase:sharedDatabase():getYieldLevelByYieldData(yield, "arena_money_crit")

-- 	self._yieldAnimation = QUIWidgetAnimationPlayer.new()
-- 	self._ccbOwner["item"..#self._itemsBox]:addChild(self._yieldAnimation)
-- 	self._yieldAnimation:setPosition(ccp(145, -35))
-- 	self._yieldAnimation:playAnimation("ccb/effects/baoji_shuzi.ccbi", function(ccbOwner)
-- 			for i = 1, 3, 1 do
-- 				ccbOwner["sp_crit"..i]:setVisible(false)
-- 			end
-- 			ccbOwner["sp_crit"..yieldLevel]:setVisible(true)
-- 			ccbOwner["tf_crit"..yieldLevel]:setString(yield)
-- 			-- self:setItemBoxShakeEffect(self._ccbOwner["item"..#self._itemsBox])
-- 		end, function()
-- 			self._itemsBox[#self._itemsBox]:_scrollItemNum(itemCount, itemCount*yield)
-- 		end, false)
-- end

-- function QBattleDialogSparField:setItemBoxShakeEffect(node)
-- 	local time = 0.032
-- 	local ccArray = CCArray:create()
-- 	ccArray:addObject(CCScaleTo:create(time, 0.96))
-- 	ccArray:addObject(CCScaleTo:create(time, 1))
-- 	node:runAction(CCSequence:create(ccArray))
-- end

function QBattleDialogSparField:_onTriggerNext(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_next) == false then return end
  	app.sound:playSound("common_item")
	self:onClose()
end

function QBattleDialogSparField:_backClickHandler()
	if q.time() - self._openTime > 3.5 then
		self._ccbOwner:onChoose()
  	end
end

function QBattleDialogSparField:onClose()
	self._ccbOwner:onChoose()
	audio.stopSound(self._audioHandler)
end

function QBattleDialogSparField:_onTriggerData(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_data) == false then return end
    app.sound:playSound("common_small")
    QBattleDialogAgainstRecord.new({},{}) 
end

return QBattleDialogSparField