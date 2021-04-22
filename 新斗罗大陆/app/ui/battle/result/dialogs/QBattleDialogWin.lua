--
-- Author: Your Name
-- Date: 2014-05-19 10:58:04
--
local QBattleDialog = import("...QBattleDialog")
local QBattleDialogWin = class(".QBattleDialogWin", QBattleDialog)

local QStaticDatabase = import(".....controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("....widgets.QUIWidgetItemsBox")
local QUIWidgetBattleWinHeroHead = import("....widgets.QUIWidgetBattleWinHeroHead")
local QUIDialogMystoryStoreAppear = import("....dialogs.QUIDialogMystoryStoreAppear")
local QBattleDialogAgainstRecord = import(".....ui.battle.QBattleDialogAgainstRecord")
local QUIViewController = import("....QUIViewController")
local QTextFiledScrollUtils = import(".....utils.QTextFiledScrollUtils")
local QBuriedPoint = import(".....utils.QBuriedPoint")

function QBattleDialogWin:ctor(options,owner)
	local ccbFile = "ccb/Battle_Dialog_Victory2.ccbi"
	-- if app.battle:isActiveDungeon() then ccbFile = "ccb/Battle_Dialog_Victory.ccbi" end
	local callBacks = {
		{ccbCallbackName = "onTriggerNext", callback = handler(self, QBattleDialogWin._onTriggerNext)},
		{ccbCallbackName = "onTriggerData", callback = handler(self, QBattleDialogWin._onTriggerData)},
		{ccbCallbackName = "onTriggerAgain", callback = handler(self, QBattleDialogWin._onTriggerAgain)},
	}

	if owner == nil then 
		owner = {}
	end
	--设置该节点启用enter事件
	self:setNodeEventEnabled(true)
	QBattleDialogWin.super.ctor(self,ccbFile,owner,callBacks)

	-- move to line 301
	-- self._ccbOwner.tip = setShadow5(self._ccbOwner.tip)

	local database = QStaticDatabase:sharedDatabase()
	local config = database:getConfig()

	--保存传递数据 awards
	local data = options.config
	-- QPrintTable(data)
	self._dungeonID = data.id
	self._teamName = data.teamName
	if self._teamName == nil then self._teamName = remote.teamManager.INSTANCE_TEAM end
	self._oldUser = options.oldUser
	self._oldTeamLevel = self._oldUser.level
	self._teamLevel = self._oldTeamLevel
	self._oldTeamExp = self._oldUser.exp
	self._oldTotalExp = database:getExperienceByTeamLevel(self._teamLevel)
	self._oldExpBuff = 0
	self._oldExpStartBuff = self._oldTeamExp
	self._heroOldInfo = options.heroInfo
	self._stores = options.shops
	self._invasion = options.invasion

	self._ccbOwner.sunwell_tips:setVisible(false)
	self._ccbOwner.node_star:setVisible(false)
	self._ccbOwner.node_title:setVisible(false)
	self._ccbOwner.node_title_lose:setVisible(false)
	self._ccbOwner.tip:setString("")
	self._ccbOwner.money_baoji:setVisible(false)
	self._ccbOwner.node_normal:setVisible(true)
	self._ccbOwner.node_score:setVisible(false)
	self._ccbOwner.node_blackrock:setVisible(false)
	self._ccbOwner.node_again:setVisible(false)
	
	self._ccbOwner.node_normal:setVisible(true)
	self._ccbOwner.node_score:setVisible(false)

	self._ccbOwner.tf_exp:setString("+0")
	self._ccbOwner.tf_money:setString("+0")
	remote.welfareInstance:setBattleEnd(true)
	
	--计算总共经验获取
	self._expTotal = 0

	--计算总共金魂币获取
	self._moneyTotal = 0

	-- 是否屏蔽打星震动的效果
	self._donotShakeScreen = false

	--掉落物品显示
 	 self._itemsBox = {}
    for i=1,5,1 do 
    	self._itemsBox[i] = QUIWidgetItemsBox.new()
    	self._ccbOwner["item"..i]:addChild(self._itemsBox[i])
    	self._itemsBox[i]:setVisible(false)
    	self._itemsBox[i]:setPromptIsOpen(true)
    end

	local config = QStaticDatabase:sharedDatabase():getConfig()
	local itmes = {}

		--节日活动掉落
	if options and type(options.extAward) == "table" then
		for _, value in pairs(options.extAward) do
			local id = value.id
	  		if id == nil then
	  			id = "type"..value.type
	  		end
	  	 	if itmes[id] == nil then
	  	 		itmes[id] = clone(value)
	  	 	else
	  	 		itmes[id].count = itmes[id].count + value.count
	  	 	end
		end
	end


	if app.battle:isActiveDungeon() == true and app.battle:getActiveDungeonType() == DUNGEON_TYPE.ACTIVITY_TIME then
		local awards = app.battle:getDeadEnemyRewards(true)
		for k, value in pairs(awards) do 
	  		local id = value.id
	  		if id == nil then
	  			id = "type"..value.type
	  		end
	  	 	if itmes[id] == nil then
	  	 		itmes[id] = clone(value)
	  	 	else
	  	 		itmes[id].count = itmes[id].count + value.count
	  	 	end
	  	end
	  	itmes[ITEM_TYPE.TEAM_EXP] = {type = ITEM_TYPE.TEAM_EXP, count = data.team_exp}
	else
		if data.awards ~= nil then
		  	for k, value in pairs(data.awards) do 
		  		local id = value.id
		  		if id == nil then
		  			id = "type"..value.type
		  		end
		  	 	if itmes[id] == nil then
		  	 		itmes[id] = clone(value)
		  	 	else
		  	 		itmes[id].count = itmes[id].count + value.count
		  	 	end
		  	end
		end

		if data.awards2 ~= nil then
		  	for k, value in pairs(data.awards2) do 
		  		local id = value.id
		  		if id == nil then
		  			id = "type"..value.type
		  		end
		  	 	if itmes[id] == nil then
		  	 		itmes[id] = clone(value)
		  	 	else
		  	 		itmes[id].count = itmes[id].count + value.count
		  	 	end
		  	end
	  	end
	end
	
	local awards = {}
	local isActivityDungeon = remote.activityInstance:checkIsActivityByDungenId(self._dungeonID)
	for _,value in pairs(itmes) do
    	local itemInfo = QStaticDatabase.sharedDatabase():getItemByID(value.id)
    	if itemInfo ~= nil and itemInfo.type == ITEM_CONFIG_TYPE.CONSUM_MONEY and isActivityDungeon then
    		self._moneyTotal = self._moneyTotal + (itemInfo.selling_price or 0) * value.count
    	else
			local typeName = remote.items:getItemType(value.type)
			if typeName == ITEM_TYPE.ITEM then
				table.insert(awards, {id = value.id, type = ITEM_TYPE.ITEM, count = value.count})
			elseif typeName == ITEM_TYPE.MONEY then
				self._moneyTotal = self._moneyTotal + value.count
			elseif typeName == ITEM_TYPE.TEAM_EXP then
				self._expTotal = value.count
			elseif typeName == ITEM_TYPE.HERO then
				table.insert(awards, {id = value.id, type = ITEM_TYPE.HERO, count = value.count})
			elseif data.isWelfare and typeName == ITEM_TYPE.TOKEN_MONEY then
				table.insert(awards, {type = value.type, count = value.count})
			elseif typeName ~= ITEM_TYPE.TOKEN_MONEY then
				table.insert(awards, {type = value.type, count = value.count})
			end
		end
	end
	-- if self._expTotal > 0 then
	-- 	table.insert(awards, 1, {type = ITEM_TYPE.TEAM_EXP, count = self._expTotal})
	-- end
	-- if self._moneyTotal > 0 then
	-- 	table.insert(awards, 1, {type = ITEM_TYPE.MONEY, count = self._moneyTotal})
	-- end
	for _,value in ipairs(awards) do
		if value.type ~= ITEM_TYPE.TEAM_EXP and value.type ~= ITEM_TYPE.MONEY then
			local item = self:_getEmptyBox()
			-- print(item, value.id, value.type, value.count)
			-- if value.type ~= "TOKEN" and options.isFirst then
			if value.type ~= "TOKEN" or not options.isFirst then
				self:_setBoxInfo(item,value.id,value.type,value.count)
			end
		end
	end
	local awardsNum = #awards
	if awardsNum < 5 and awardsNum > 0 then
		self._ccbOwner.node_item:setPositionX(-(awardsNum - 1) * 96/2)
	end
	
	--初始化魂师头像
	self.heroBox = {}
	self.hero_exp = data.heroExp
	for i = 1, 4, 1 do
	 self.heroBox[i] = QUIWidgetBattleWinHeroHead.new()
	 self._ccbOwner["hero_node" .. i]:addChild(self.heroBox[i])
	 self._ccbOwner["hero_node" .. i]:setVisible(false)
	end
    local teamHero = remote.teamManager:getActorIdsByKey(self._teamName, 1)
    local heroNum = #teamHero
	if heroNum < 4 and heroNum > 0 then
		self._ccbOwner.node_hero:setPositionX(-(heroNum - 1) * 147/2)
	end
   self:_setHeroInfo(self.hero_exp)

	-- 中心对齐
	centerAlignBattleDialogVictory2(self._ccbOwner, self.heroBox, teamHero, self._itemsBox, awardsNum)

	--设置动画时长
	self._animationTime = 0.5

    app:getUserData():setDungeonIsPass("pass")

	app.battle:resume()
  	self._audioHandler = app.sound:playSound("battle_complete")
    audio.stopBackgroundMusic()

    -- @qinyuanji, wow-6198
    local star = options.star
    if not app.battle:isActiveDungeon() and options.isShowStar ~= false then
		self._ccbOwner.node_star:setVisible(true)
		app.sound:preloadSound("common_star")
		local common_star_hdl = nil
		local additional_latency = (device.platform == "android") and 0.23 or 0
		for i=1,3,1 do
			if i <= star then
				self._ccbOwner["bstar_done"..i]:setVisible(true)
				if i == 1 then
					common_star_hdl = app.sound:playSound("common_star")
				else
					local timeHandler = scheduler.performWithDelayGlobal(function ()
						if common_star_hdl then
							app.sound:stopSound(common_star_hdl)
						end
						common_star_hdl = app.sound:playSound("common_star")
					end, additional_latency + 0.30*(i-1))
				end
			else
				self._ccbOwner["bstar_done"..i]:setVisible(false)
			end
		end

		local dungeonType = DUNGEON_TYPE.NORMAL
		if remote.instance:getDungeonById(data.id) then
			dungeonType = remote.instance:getDungeonById(data.id).dungeon_type
		end

		if dungeonType == DUNGEON_TYPE.NORMAL then
			if star == 3 then
				self._ccbOwner.tip:setString("三星（无魂师阵亡）")
			elseif star == 2 then
				self._ccbOwner.tip:setString("二星（一名魂师阵亡）")
			else
				self._ccbOwner.tip:setString("一星（多名魂师阵亡）")
			end
		else
			if star == 3 then
				self._ccbOwner.tip:setString("三星（60秒内获得胜利）")
			elseif star == 2 then
				self._ccbOwner.tip:setString("二星（90秒内获得胜利）")
			else
				self._ccbOwner.tip:setString("一星（消灭所有怪物）")
			end
		end

		--xurui:检查 再打一次 是否解锁
		if app.unlock:checkLock("UNLOCK_ZAILAIYICI") then
		    local passInfo = remote.instance:getPassInfoForDungeonID(data.id)
		    if passInfo == nil or passInfo.star == nil or passInfo.star < 3 then
		    	self._ccbOwner.node_again:setVisible(true)
		    end
		end
	else
		self._ccbOwner.node_title:setVisible(true)
		self._donotShakeScreen = true
		if app.battle:isActiveDungeon() == true then
			self._ccbOwner.node_title_over:setVisible(true)
			self._ccbOwner.node_title_win:setVisible(false)
		else
			self._ccbOwner.node_title_over:setVisible(false)
			self._ccbOwner.node_title_win:setVisible(true)
		end
	end

	-- 打三星的时候，相应的震动
    -- print("QBattleDialogWin.star", star)
    -- print("QBattleDialogWin._donotShakeScreen", self._donotShakeScreen)
    if self._donotShakeScreen == false then
    	if star == 3 then
			scheduler.performWithDelayGlobal(function()
				q.shakeScreen(8, 0.1)
			end, 7/30)
			scheduler.performWithDelayGlobal(function()
				q.shakeScreen(8, 0.1)
			end, 14/30)
			scheduler.performWithDelayGlobal(function()
				q.shakeScreen(8, 0.1)
			end, 21/30)
		elseif star == 2 then
			scheduler.performWithDelayGlobal(function()
				q.shakeScreen(8, 0.1)
			end, 7/30)
			scheduler.performWithDelayGlobal(function()
				q.shakeScreen(8, 0.1)
			end, 14/30)
			-- scheduler.performWithDelayGlobal(function()
			-- 	q.shakeScreen()
			-- end, 21/30)
		elseif star == 1 then
			scheduler.performWithDelayGlobal(function()
				q.shakeScreen(8, 0.1)
			end, 7/30)
			-- scheduler.performWithDelayGlobal(function()
			-- 	q.shakeScreen()
			-- end, 14/30)
			-- scheduler.performWithDelayGlobal(function()
			-- 	q.shakeScreen()
			-- end, 21/30)
		end
    end
	
	self._expUpdate = QTextFiledScrollUtils.new()
	self._moneyUpdate = QTextFiledScrollUtils.new()

	self._updateScheduler = scheduler.performWithDelayGlobal(function()
			self._expUpdate:addUpdate(0, self._expTotal, handler(self, self._onExpUpdate), 17/30)
			self._moneyUpdate:addUpdate(0, self._moneyTotal, handler(self, self._onMoneyUpdate), 17/30)
		end, 0)
	self._openTime = q.time()
end

function QBattleDialogWin:onEnter()
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self._onFrame))
    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)

    self._shadowScheduler = scheduler.performWithDelayGlobal(function()
    	if self._ccbOwner.tip:getScale() == 1 then
			self._ccbOwner.tip = setShadow5(self._ccbOwner.tip)
			if self._shadowScheduler then
				scheduler.unscheduleGlobal(self._shadowScheduler)
				self._shadowScheduler = nil
			end
	    end
    end, 35/30)
end

function QBattleDialogWin:onExit()
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
	if self._shadowScheduler ~= nil then
		scheduler.unscheduleGlobal(self._shadowScheduler)
		self._shadowScheduler = nil
	end
end
	
function QBattleDialogWin:_setBoxInfo(box,itemID,itemType,num)
	if box ~= nil then
		box:setGoodsInfo(itemID,itemType,num)
		box:setVisible(true)
		
		if itemID ~= nil and remote.stores:checkItemIsNeed(itemID, num) then
			box:showGreenTips(true)
		end
	end
end

function QBattleDialogWin:_setHeroInfo(exp)
  
	local actorIds = remote.teamManager:getActorIdsByKey(self._teamName, 1)
	local teamCount = #teamHero
  for i = 1, teamCount, 1 do
    self._hero = remote.herosUtil:getHeroByID(actorIds[i])
    self.heroBox[i]:setHeroHead(self._hero.actorId, self._hero.level)
    
    local database = QStaticDatabase:sharedDatabase()
    local curLevelExp = database:getExperienceByLevel(self._hero.level)
    
    local heroInfo = clone(self._hero)
    local heroOldInfo = self._heroOldInfo[i]
    local oldLevel,oldExp = remote.herosUtil:subHerosExp(heroInfo.level, heroInfo.exp, exp)
    heroOldInfo.level = oldLevel
    heroOldInfo.exp = oldExp
    local heroMaxLevel = remote.herosUtil:getHeroMaxLevel()
    local oldCurLevelExp = database:getExperienceByLevel(heroOldInfo.level)
    
    if heroMaxLevel == self._hero.level and self._hero.exp == (curLevelExp - 1) then
      if heroOldInfo.level == self._hero.level and heroOldInfo.exp == (curLevelExp - 1) then
        self.heroBox[i]:expOldFull()
      else
        self.heroBox[i]:expFull(heroOldInfo.exp, curLevelExp)
      end
    elseif heroOldInfo.level == self._hero.level then
      self.heroBox[i]:setExpBar(self._hero.exp, exp, curLevelExp)
    elseif heroOldInfo.level == self._hero.level and heroOldInfo.exp == self._hero.exp then
      self.heroBox[i]:noExpAdd(heroOldInfo.exp, curLevelExp)
    else
      self.heroBox[i]:setUpExpBar(heroOldInfo, oldCurLevelExp,exp , self._hero, curLevelExp)
    end
    self._ccbOwner["hero_node" .. i]:setVisible(true)
  end 
end

function QBattleDialogWin:_getEmptyBox()
	for _,box in pairs(self._itemsBox) do
		if box:isVisible() == false then
			box:resetAll()
			return box
		end
	end
	return nil
end

function QBattleDialogWin:_backClickHandler()
	if q.time() - self._openTime > 3.5 then
  		self:_onClose()
  	end
end

function QBattleDialogWin:_onTriggerNext()
	-- 埋点: “结算关卡X-Y点击”
	app:triggerBuriedPoint(QBuriedPoint:getDungeonWinBuriedPointID(self._dungeonID))

	--@qinyuanji, wow-6314
    local unlockLevel = app.unlock:getConfigByKey("UNLOCK_FORTRESS").team_level
    local isUnlockInvasion = self._oldTeamLevel < unlockLevel and remote.user.level >= unlockLevel

    if self._invasion and self._invasion.bossId and self._invasion.bossId > 0 then

	    --xurui: 要塞解锁时不弹要塞跳转界面，先拉取要塞完整信息
	    if isUnlockInvasion == false then
	    	local level = self._invasion.fightCount + 1
			local maxLevel = db:getIntrusionMaximumLevel(self._invasion.bossId)
		    level = math.min(level, maxLevel)
	        app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogInvasionEncounter", 
	            options = {actorId = self._invasion.bossId, level = level, inbattle = true, cancelCallback = function ( ... )
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

function QBattleDialogWin:_onClose()
  	if self._stores ~= nil and self._invasion == nil then
	  	app.sound:playSound("common_next")
	    local unlockVlaue = QStaticDatabase:sharedDatabase():getConfiguration()
	    for _, value in pairs(self._stores) do 
            if value.id == tonumber(SHOP_ID.goblinShop) and self._oldTeamLevel >= app.unlock:getConfigByKey("UNLOCK_SHOP_1").team_level then
                app.tip:addUnlockTips(QUIDialogMystoryStoreAppear.FIND_GOBLIN_SHOP)
            elseif value.id == tonumber(SHOP_ID.blackShop) and self._oldTeamLevel >= app.unlock:getConfigByKey("UNLOCK_SHOP_2").team_level then
                app.tip:addUnlockTips(QUIDialogMystoryStoreAppear.FIND_BLACK_MARKET_SHOP)
            end
      	end
  	end 
	self._ccbOwner:onChoose()
	audio.stopSound(self._audioHandler)
end

function QBattleDialogWin:_onTriggerData(event)
    app.sound:playSound("common_small")
    QBattleDialogAgainstRecord.new({},{}) 
end

function QBattleDialogWin:_onTriggerAgain(event)
    app.sound:playSound("common_small")
	-- local info = remote.instance:getDungeonById(self._dungeonID)
	-- app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogDungeon", 
	-- 	options = {info = event.info}})
    remote.instance:setAgain(true, self._dungeonID)
    self:_onClose()
end

function QBattleDialogWin:_onCloseWelfareFirstWin()
  if self.firstWin ~= nil then
     self.firstWin:close()
     self.firstWin = nil
  end
end

function QBattleDialogWin:_onExpUpdate(value)
    self._ccbOwner.tf_exp:setString("+"..tostring(math.ceil(value)))
end

function QBattleDialogWin:_onMoneyUpdate(value)
    self._ccbOwner.tf_money:setString("+"..tostring(math.ceil(value)))
end

return QBattleDialogWin