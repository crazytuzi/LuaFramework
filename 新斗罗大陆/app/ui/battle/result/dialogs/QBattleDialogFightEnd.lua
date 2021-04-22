--
-- Author: Kumo
-- Date: 2017-09-29
--
local QBattleDialogBaseFightEnd = import(".QBattleDialogBaseFightEnd")
local QBattleDialogFightEnd = class(".QBattleDialogFightEnd", QBattleDialogBaseFightEnd)

local QTutorialDefeatedGuide = import(".....tutorial.defeated.QTutorialDefeatedGuide")
local QUIDialogMystoryStoreAppear = import("....dialogs.QUIDialogMystoryStoreAppear")
local QUIWidgetBattleWinHeroHead = import("....widgets.QUIWidgetBattleWinHeroHead")
local QTextFiledScrollUtils = import(".....utils.QTextFiledScrollUtils")
local QStaticDatabase = import(".....controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("....widgets.QUIWidgetItemsBox")
local QUIViewController = import("....QUIViewController")
local QBattleLog = import(".....controllers.QBattleLog")
local QBuriedPoint = import(".....utils.QBuriedPoint")
local QUIWidget = import(".....ui.widgets.QUIWidget")

function QBattleDialogFightEnd:ctor(options, owner)
	print("<<<QBattleDialogFightEnd>>>")
	--设置该节点启用enter事件
	self:setNodeEventEnabled(true)
	QBattleDialogFightEnd.super.ctor(self, options, owner)
	app:getUserData():setDungeonIsPass("pass")
	remote.welfareInstance:setBattleEnd(true)
	
    -- self._animationManager:connectScriptHandler(handler(self, self.animationEndHandler))
	self:resetAll()

	--保存传递数据 awards
	local data = options.config
	--显示胜负背景和client
	local isWin = options.isWin
	--显示星星title或文字title
	local star = options.star or 0
	local text = options.text or ""
	--显示经验、银币、积分
	local isExpMoneyScore = options.isExpMoneyScore
	local exp = options.exp or 0
	local money = options.money or 0
	local score = options.score or 0
	--显示比赛信息、魂师、数据
	local isMatch = options.isMatch
	local isHero = options.isHero
	local isFightData = options.isFightData
	--显示奖励
	local isAward = options.isAward
	--显示物品奖励或等式奖励
	local isEquation = options.isEquation
	-- QPrintTable(data)
	-- 活动副本专用
	local bossMinimumHp = options.bossMinimumHp or 0
	local killEnemyCount = options.killEnemyCount or 0
	local totalKillEnemyCount = options.totalKillEnemyCount or 0
	local oldPassInfo = options.oldPassInfo or {}
	
	--计算总共经验获取
	self._expTotal = exp
	--计算总共银币获取
	self._moneyTotal = money
	--计算总共积分获取
	self._scoreTotal = score
	-- 是否屏蔽打星震动的效果
	self._donotShakeScreen = false
	self._isWin = isWin
	self._schedulerHandlers = {}

	local items = {}
	local awards = {}
	local awardsNum = 0
	
	local dungeonType = DUNGEON_TYPE.NORMAL
	local isDungeon = false
	if remote.instance:getDungeonById(data.id) then
		dungeonType = remote.instance:getDungeonById(data.id).dungeon_type
		isDungeon = true
	end
	local isActivityDungeon = remote.activityInstance:checkIsActivityByDungenId(data.id)

	print("[Kumo] Battle_Dialog_FightEnd ", isWin, star, text)
	if isWin then
		self._audioHandler = app.sound:playSound("battle_complete")
		makeNodeFromGrayToNormal(self._ccbOwner.node_bg_mvp)

		self._ccbOwner.node_win_client:setVisible(true)
		self._ccbOwner.node_bg_win:setVisible(true)

		self._dungeonID = data.id
	
		--节日活动掉落
		if options and type(options.extAward) == "table" then
			for _, value in pairs(options.extAward) do
				local id = value.id
		  		if id == nil then
		  			id = "type"..value.type
		  		end
		  	 	if items[id] == nil then
		  	 		items[id] = clone(value)
		  	 		items[id].isExtAward = true
		  	 	else
		  	 		items[id].count = items[id].count + value.count
		  	 	end
			end
		end
		-- 券掉落
		if data.prizeWheelMoneyGot and data.prizeWheelMoneyGot > 0 then
		  	items[ITEM_TYPE.PRIZE_WHEEL_MONEY] = {type = ITEM_TYPE.PRIZE_WHEEL_MONEY, count = data.prizeWheelMoneyGot, isActivity = true}
		end

		if app.battle and app.battle:isActiveDungeon() == true and app.battle:getActiveDungeonType() == DUNGEON_TYPE.ACTIVITY_TIME then
			local deadAwards = app.battle:getDeadEnemyRewards(true)
			for k, value in pairs(deadAwards) do 
		  		local id = value.id
		  		if id == nil then
		  			id = "type"..value.type
		  		end
		  	 	if items[id] == nil then
		  	 		items[id] = clone(value)
		  	 	else
		  	 		items[id].count = items[id].count + value.count
		  	 	end
		  	end
		  	items[ITEM_TYPE.TEAM_EXP] = {type = ITEM_TYPE.TEAM_EXP, count = data.team_exp}
		else
			printTable(data.awards)
			if data.awards ~= nil then
			  	for k, value in pairs(data.awards) do 
			  		local id = value.id
			  		if id == nil then
			  			id = "type"..value.type
			  		end
			  	 	if items[id] == nil then
			  	 		items[id] = clone(value)
			  	 	else
			  	 		items[id].count = items[id].count + value.count
			  	 	end
			  	end
			end
			if data.awards2 ~= nil then
			  	for k, value in pairs(data.awards2) do 
			  		local id = value.id
			  		if id == nil then
			  			id = "type"..value.type
			  		end
			  	 	if items[id] == nil then
			  	 		items[id] = clone(value)
			  	 	else
			  	 		items[id].count = items[id].count + value.count
			  	 	end
			  	end
		  	end

		  	if data.dailyAwards ~= nil and bossMinimumHp >= 0 then
				local level = math.floor((1-bossMinimumHp)*10000)/100
				local maxLevel = 0
				if level >= 100 then
					maxLevel = 4
				elseif level >= 75 then
					maxLevel = 3
				elseif level >= 50 then
					maxLevel = 2
				elseif level >= 25 then
					maxLevel = 1
				end
				for i = 1, maxLevel, 1 do
					local a = data.dailyAwards[i].awards
					for _, value in ipairs(a) do 
				  		local id = value.id
				  		if id == nil then
				  			id = "type"..value.type
				  		end
				  	 	if items[id] == nil then
				  	 		items[id] = clone(value)
				  	 	else
				  	 		items[id].count = items[id].count + value.count
				  	 	end
				  	end
				end
		  	end
		  	items[ITEM_TYPE.TEAM_EXP] = {type = ITEM_TYPE.TEAM_EXP, count = data.team_exp}
		end
		-- QPrintTable(items)
		for _, value in pairs(items) do
	    	local itemInfo = QStaticDatabase.sharedDatabase():getItemByID(value.id)
	    	if itemInfo ~= nil and itemInfo.type == ITEM_CONFIG_TYPE.CONSUM_MONEY and isActivityDungeon then
	    		self._moneyTotal = self._moneyTotal + (itemInfo.selling_price or 0) * value.count
	    	else
				local typeName = remote.items:getItemType(value.type)
				if typeName == ITEM_TYPE.ITEM then
					table.insert(awards, {id = value.id, type = ITEM_TYPE.ITEM, count = value.count, isExtAward = value.isExtAward, isActivity = value.isActivity})
				elseif typeName == ITEM_TYPE.MONEY then
					self._moneyTotal = self._moneyTotal + value.count
				elseif typeName == ITEM_TYPE.TEAM_EXP then
					self._expTotal = value.count
				elseif typeName == ITEM_TYPE.HERO then
					table.insert(awards, {id = value.id, type = ITEM_TYPE.HERO, count = value.count, isExtAward = value.isExtAward, isActivity = value.isActivity})
				elseif data.isWelfare and typeName == ITEM_TYPE.TOKEN_MONEY then
					table.insert(awards, {type = value.type, count = value.count, isExtAward = value.isExtAward, isActivity = value.isActivity})
				elseif typeName ~= ITEM_TYPE.TOKEN_MONEY then
					table.insert(awards, {type = value.type, count = value.count, isExtAward = value.isExtAward, isActivity = value.isActivity})
				end
			end
		end

		self._ccbOwner.tf_award_title:setString("战斗奖励")
		self._ccbOwner.node_award_title:setVisible(true)
	else
		self._audioHandler = app.sound:playSound("battle_failed")
		makeNodeFromNormalToGray(self._ccbOwner.node_bg_mvp)

		self._ccbOwner.node_bg_lost:setVisible(true)
		self._ccbOwner.node_lost_client:setVisible(true)

		self:hideAllPic()
		self:chooseBestGuide()
	end

	if star > 0 then
	    if (app.battle and not app.battle:isActiveDungeon()) or data.isActiveDungeon then
			self._ccbOwner.node_win_star_title:setVisible(true)
			local handler = scheduler.performWithDelayGlobal(function()
				app.sound:preloadSound("common_star")
				local common_star_hdl = nil
				local additional_latency = (device.platform == "android") and 0.23 or 0
				for i=1, 3, 1 do
					if i <= star then
						self._ccbOwner["sp_star_done_"..i]:setVisible(true)
						if i == 1 then
							common_star_hdl = app.sound:playSound("common_star")
						else
							local timeHandler = scheduler.performWithDelayGlobal(function ()
									if common_star_hdl then
										app.sound:stopSound(common_star_hdl)
									end
									common_star_hdl = app.sound:playSound("common_star")
								end, additional_latency + 0.60 * ( i - 1 ))
							self._schedulerHandlers[timeHandler] = timeHandler
						end
					else
						self._ccbOwner["sp_star_done_"..i]:setVisible(false)
					end
				end
			end, 20/30)
			self._schedulerHandlers[handler] = handler

			if data.title == nil then
				local dungeonTargetConfig = db:getDungeonTargetByID(data.monster_id)
				if dungeonTargetConfig then
					if dungeonType == DUNGEON_TYPE.NORMAL then
						if star == 3 then
							local titleStr = dungeonTargetConfig[1].target_text or "无魂师阵亡"
							self._ccbOwner.tf_win_title:setString("三星（"..titleStr.."）")
						elseif star == 2 then
							local titleStr = dungeonTargetConfig[2].target_text or "一名魂师阵亡"
							self._ccbOwner.tf_win_title:setString("二星（"..titleStr.."）")
						else
							local titleStr = dungeonTargetConfig[3].target_text or "多名魂师阵亡"
							self._ccbOwner.tf_win_title:setString("一星（"..titleStr.."）")
						end
					else
						if star == 3 then
							local titleStr = dungeonTargetConfig[1].target_text or "60秒内获得胜利"
							self._ccbOwner.tf_win_title:setString("三星（"..titleStr.."）")
						elseif star == 2 then
							local titleStr = dungeonTargetConfig[2].target_text or "90秒内获得胜利"
							self._ccbOwner.tf_win_title:setString("二星（"..titleStr.."）")
						else
							local titleStr = dungeonTargetConfig[3].target_text or "消灭所有怪物"
							self._ccbOwner.tf_win_title:setString("一星（"..titleStr.."）")
						end
					end
				end
			else
				self._ccbOwner.tf_win_title:setString(data.title)
			end
		else
			self._donotShakeScreen = true
			self._ccbOwner.node_win_text_title:setVisible(true)
		end

		-- 打三星的时候，相应的震动
	    if self._donotShakeScreen == false then
	    	if star == 3 then
				scheduler.performWithDelayGlobal(function()
					q.shakeScreen(8, 0.1)
				end, 20/30)
				scheduler.performWithDelayGlobal(function()
					q.shakeScreen(8, 0.1)
				end, 35/30)
				scheduler.performWithDelayGlobal(function()
					q.shakeScreen(8, 0.1)
				end, 51/30)
			elseif star == 2 then
				scheduler.performWithDelayGlobal(function()
					q.shakeScreen(8, 0.1)
				end, 20/30)
				scheduler.performWithDelayGlobal(function()
					q.shakeScreen(8, 0.1)
				end, 35/30)
			elseif star == 1 then
				scheduler.performWithDelayGlobal(function()
					q.shakeScreen(8, 0.1)
				end, 20/30)
			end
	    end
	elseif text ~= "" then
		self._ccbOwner.node_win_text_title:setVisible(true)
	else
		print("no this title model !")
		if app.battle and app.battle:getActiveDungeonType() == DUNGEON_TYPE.ACTIVITY_TIME or app.battle:getActiveDungeonType() == DUNGEON_TYPE.ACTIVITY_CHALLENGE then
			self._ccbOwner.node_win_text_title:setVisible(true)
		end
	end

	if isHero then
		if app.battle and app.battle:isActiveDungeon() then
			self._ccbOwner.node_fight_progress:setVisible(true)
			
			self._ccbOwner.node_fightProgress_damage:setVisible(false)
			self._ccbOwner.node_fightProgress_count:setVisible(false)
			if bossMinimumHp and bossMinimumHp >= 0 then
				self:setProgressBoxEffect(bossMinimumHp)
				self._ccbOwner.node_fightProgress_progress:setVisible(true)
				self._ccbOwner.tf_fightProgress_damage_title:setString("造成伤害："..(math.floor((1-bossMinimumHp)*10000)/100).."%")
				self._ccbOwner.tf_fightProgress_damage_title:setVisible(true)
				self._ccbOwner.node_fightProgress_damage:setVisible(true)
				self._ccbOwner.sp_great:setVisible((oldPassInfo.hisMaxKillEnemyCount or 0) < ((1-bossMinimumHp)*10000))

				self._ccbOwner.node_fightProgress_progress:setVisible(true)
			else
				self._ccbOwner.tf_fightProgress_count_title:setString("击杀数量："..killEnemyCount.."/"..totalKillEnemyCount)
				self._ccbOwner.tf_fightProgress_count_title:setVisible(true)
				self._ccbOwner.node_fightProgress_count:setVisible(true)
				self._ccbOwner.sp_great:setVisible((oldPassInfo.hisMaxKillEnemyCount or 0) < killEnemyCount)
				self._ccbOwner.sp_great:setPositionY(35)
				self._ccbOwner.node_fightProgress_count:setPositionY(-20)

				self._ccbOwner.node_fightProgress_progress:setVisible(false)
			end
		else
			self._ccbOwner.node_hero_head:setVisible(true)
			-- self._heroBox = {}
		   	local heroHeadCount = self:setHeroInfo(data.heroExp)
			if self.heroBox and heroHeadCount > 0 then
				local heroTotalWidth = self.heroHeadWidth * (heroHeadCount - 1) + (self.heroBox[1]:getSize().width * 1.5)
				self._ccbOwner.node_hero_head:setPositionX( self._ccbOwner.node_hero_head:getPositionX() + (self._ccbOwner.ly_hero_head_size:getContentSize().width - heroTotalWidth) / 2 )
			end
		end
		
	elseif isMatch then
		self._ccbOwner.node_team_match:setVisible(true)
	elseif isFightData then
		self._ccbOwner.node_fight_data:setVisible(true)
	else
		print("no this info model !")
	end
	
	if isAward then
		self._ccbOwner.node_award_title:setVisible(true)
		if isEquation then
			self._ccbOwner.node_award_equation:setVisible(true)
			self._ccbOwner.node_award_equation_client:setVisible(true)
		else
			self._ccbOwner.node_award_normal:setVisible(true)
			self._ccbOwner.node_award_normal_client:setVisible(true)
			
    		local activityYield1 = remote.activity:getActivityMultipleYield(602)
    		local activityYield2 = remote.activity:getActivityMultipleYield(701)
	 		local items = {}
			for _, value in ipairs(awards) do
				if value.type ~= "TOKEN" or not options.isFirst then
			    	items[#items+1] = value
				end
				local itemInfo = db:getItemByID(value.id)
				if app.battle and itemInfo and not value.isExtAward then
					if itemInfo.type == ITEM_CONFIG_TYPE.MATERIAL and app.battle:getActiveDungeonType() == DUNGEON_TYPE.NORMAL then
						value.activityYield = activityYield2
					elseif itemInfo.type == ITEM_CONFIG_TYPE.SOUL and app.battle:getActiveDungeonType() == DUNGEON_TYPE.ELITE then
						value.activityYield = activityYield1
					end
				end
			end

			--掉落物品显示
		 	self:showDropItems(items)
		end
	end

	if isExpMoneyScore or self._expTotal > 0 or self._moneyTotal > 0 or self._scoreTotal > 0 then
		self._ccbOwner.node_exp_money_score:setVisible(true)
		self._ccbOwner.node_exp:setVisible(true)
		self._ccbOwner.node_money:setVisible(true)
		self._expUpdate = QTextFiledScrollUtils.new()
		self._moneyUpdate = QTextFiledScrollUtils.new()
		self._updateScheduler = scheduler.performWithDelayGlobal(function()
				self._expUpdate:addUpdate(0, self._expTotal, handler(self, self.onExpUpdate), 17/30)
				self._moneyUpdate:addUpdate(0, self._moneyTotal, handler(self, self.onMoneyUpdate), 17/30)
    			if remote.activity:checkMonthCardActive(1) and isDungeon then
    				self._ccbOwner.tf_money:setString(self._moneyTotal)
    				local width = self._ccbOwner.tf_money:getContentSize().width
					self._ccbOwner.tf_double:setPositionX(self._ccbOwner.tf_money:getPositionX()+width+20)
					self._ccbOwner.tf_double:setVisible(true)
    			end
			end, 2)
	end

	self._openTime = q.time()
	self._isFirst = options.isFirst
end

function QBattleDialogFightEnd:onMoneyUpdate(value)
	local valueStr = "+"..tostring(math.ceil(value))
    self._ccbOwner.tf_money:setString(valueStr)
end

function QBattleDialogFightEnd:setProgressBoxEffect(bossMinimumHp)
	for i = 1, 4 do
		self._ccbOwner["sp_fightProgressBox_open_"..i]:setVisible(false)
		self._ccbOwner["ccb_fightProgressBox_light_"..i]:setVisible(false)
		self._ccbOwner["sp_fightProgressBox_close_"..i]:setVisible(true)
	end
	self._ccbOwner.sp_fightProgress_bar:setScaleX(0)
	self._ccbOwner.node_award_normal:setVisible(false) 
	self._ccbOwner.node_fight_progress:setVisible(false) 
	local gap = 1/4

	local totalScale = 1-bossMinimumHp
	local effectScaleX = 0
	local effectIndex = 1
	local effectFunc
	effectFunc = function()
		local scaleX = totalScale >= gap and gap or totalScale
		effectScaleX = effectScaleX + scaleX
		local ccArrary = CCArray:create()
		ccArrary:addObject(CCScaleTo:create(gap/2, effectScaleX, 1))
		ccArrary:addObject(CCCallFunc:create(function ( ... )
			if totalScale >= gap then
				totalScale = totalScale - scaleX
				self._ccbOwner["sp_fightProgressBox_open_"..effectIndex]:setVisible(true)
				self._ccbOwner["ccb_fightProgressBox_light_"..effectIndex]:setVisible(true)
				self._ccbOwner["sp_fightProgressBox_close_"..effectIndex]:setVisible(false)
				effectIndex = effectIndex + 1

				if totalScale > 0 then
					effectFunc()
				else
					self._ccbOwner.node_award_normal:setVisible(true)
				end
			else
				self._ccbOwner.node_award_normal:setVisible(true)
			end 
		end))

		self._ccbOwner.sp_fightProgress_bar:runAction(CCSequence:create(ccArrary))
	end

	self._effectScheduler = scheduler.performWithDelayGlobal(function()
		self._ccbOwner.node_fight_progress:setVisible(true) 
			effectFunc()
		end, 1.5)
end

function QBattleDialogFightEnd:onEnter()
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self._onFrame))
    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)
end

function QBattleDialogFightEnd:onExit()
   self:removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
   	if self._schedulerHandlers ~= nil then
	   	for _,v in pairs(self._schedulerHandlers) do
	   		scheduler.unscheduleGlobal(v)
	   	end
   	end
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
	if self._effectScheduler ~= nil then
		scheduler.unscheduleGlobal(self._effectScheduler)
		self._effectScheduler = nil
	end
end

function QBattleDialogFightEnd:_onTriggerNext()
	-- 埋点: “结算关卡X-Y点击”
	app:triggerBuriedPoint(QBuriedPoint:getDungeonWinBuriedPointID(self._dungeonID))
	if self._isWin then
		local dungeonData = remote.instance:getDungeonById(self._dungeonID)
		if dungeonData then
			local nextDungeonData = remote.instance:getDungeonById(remote.instance:getNextIDForDungeonID(self._dungeonID, dungeonData.dungeon_type))
			if nextDungeonData and dungeonData.dungeon_type == DUNGEON_TYPE.NORMAL and self._isFirst and dungeonData.instance_id ~= nextDungeonData.instance_id then
				local passInfo = {
					title = dungeonData.instance_name or "", 
					currentIndex = dungeonData.instanceIndex or 1,
					text = dungeonData.end_aside or "", 
					isAnimation = false,
				}
				remote.instance:setChapterPassInfo(passInfo)
			end
			self:checkIvasion()
		else
			app.sound:playSound("common_item")
	  		self:_onClose()
		end
	else
		app.sound:playSound("common_item")
	  	self:_onClose()
	end
end

function QBattleDialogFightEnd:checkIvasion()
	local unlockLevel = app.unlock:getConfigByKey("UNLOCK_FORTRESS").team_level
    local isUnlockInvasion = self.oldTeamLevel < unlockLevel and remote.user.level >= unlockLevel
    if self.invasion and self.invasion.bossId and self.invasion.bossId > 0 then
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

function QBattleDialogFightEnd:animationEndHandler(name)
	self._animationStage = name
end

return QBattleDialogFightEnd