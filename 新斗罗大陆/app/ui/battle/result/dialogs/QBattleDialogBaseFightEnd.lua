--
-- Author: Kumo
-- Date: 2017-09-29
--
local QBattleDialog = import("...QBattleDialog")
local QBattleDialogBaseFightEnd = class(".QBattleDialogBaseFightEnd", QBattleDialog)

local QBattleDialogAgainstRecord = import(".....ui.battle.QBattleDialogAgainstRecord")
local QTutorialDefeatedGuide = import(".....tutorial.defeated.QTutorialDefeatedGuide")
local QUIDialogMystoryStoreAppear = import("....dialogs.QUIDialogMystoryStoreAppear")
local QUIWidgetBattleWinHeroHead = import("....widgets.QUIWidgetBattleWinHeroHead")
local QUIWidgetAnimationPlayer = import("....widgets.QUIWidgetAnimationPlayer")
local QStaticDatabase = import(".....controllers.QStaticDatabase")
local QBattleLog = import(".....controllers.QBattleLog")
local QDialogChooseCard = import(".....ui.battle.QDialogChooseCard")
local QUIViewController = import("....QUIViewController")
local QUIWidgetItemsBox = import("....widgets.QUIWidgetItemsBox")
local QUIWidgetTutorialHandTouch = import("....widgets.QUIWidgetTutorialHandTouch")
local QUIWidgetFightEndLostHelp = import("....widgets.QUIWidgetFightEndLostHelp")
local QSoundEffect = import("..utils.QSoundEffect")

function QBattleDialogBaseFightEnd:ctor(options, owner)
	print("<<<QBattleDialogBaseFightEnd>>>")
	self._options = options or {}
	local ccbFile = "ccb/Battle_Dialog_FightEnd.ccbi"
	if not self._options.isWin  then
		ccbFile = "ccb/Battle_Dialog_FightEnd_Lost.ccbi"
	end
	self._isCollegeTrain = self._options.isCollegeTrain or false
	self._skipLocal =  false
	if  self._options.skipLocal then
		self._skipLocal = self._options.skipLocal
	end
	
	print("ccbFile = "..ccbFile)
	local callBacks = {
		{ccbCallbackName = "onTriggerNext", callback = handler(self, self.onTriggerNext)},
		{ccbCallbackName = "onTriggerData", callback = handler(self, self.onTriggerData)},
		{ccbCallbackName = "onTriggerGoto", callback = handler(self, self.onTriggerGoto)},
		{ccbCallbackName = "onTriggerBossIntroduce", callback = handler(self, self.onTriggerBossIntroduce)},
		{ccbCallbackName = "onTriggerStronger", callback = handler(self, self.onTriggerStronger)},
	}

	if owner == nil then 
		owner = {}
	end

	QBattleDialogBaseFightEnd.super.ctor(self, ccbFile, owner, callBacks)
	if app.battle then
		app.battle:resume()
	end
	audio.stopMusic()
	
    CalculateUIBgSize(self._ccbOwner.bj)
    q.setButtonEnableShadow(self._ccbOwner.btn_data)
	self._animationManager = tolua.cast(self._ccbNode:getUserObject(), "CCBAnimationManager")
	print("<<<QBattleDialogBaseFightEnd>>>", self._options.isNeedTutorial)
	if self._options.isNeedTutorial and self._ccbOwner.node_tutorial then
		self._ccbOwner.node_tutorial:removeAllChildren()
		self._CP = self._ccbOwner.node_tutorial:convertToWorldSpaceAR(ccp(0,0))
		self._size = self._ccbOwner.btn_next:getContentSize()
		self:_createTouchNode()
		self._animationManager:connectScriptHandler(function()
				self._animationManager:disconnectScriptHandler()
				self._handTouch = QUIWidgetTutorialHandTouch.new({attack = true})
				self._ccbOwner.node_tutorial:addChild(self._handTouch)
			end)
	end
	if not self._options.isWin  then
		-- self._guidePrompts = {
		-- 	{title = "魂师升星", typeName = "hero_star", sp = "sp_upgrade", strongerId = "hero_grade", condition = handler(self, self.checkStarupPass), event = QTutorialDefeatedGuide.STARUP},
		-- 	{title = "魂技升级", typeName = "up_skill", sp = "sp_skill", strongerId = "hero_skill", condition = handler(self, self.checkSkillPass), event = QTutorialDefeatedGuide.SKILL},
		-- 	{title = "体技升级", typeName = "up_glyph", sp = "sp_glyph", strongerId = "hero_glyph", condition = handler(self, self.checkGlyphPass), event = QTutorialDefeatedGuide.GLYPH},
		-- 	{title = "魂师升级", typeName = "up_hero", sp = "sp_exp", strongerId = "hero_level", condition = handler(self, self.checkUpgradePass), event = QTutorialDefeatedGuide.UPGRADE},
		-- 	{title = "魂师培养", typeName = "up_train", sp = "sp_train", strongerId = "hero_train", condition = handler(self, self.checkUpTrainPass), event = QTutorialDefeatedGuide.TRAIN},
		-- 	{title = "装备突破", typeName = "break_through", sp = "sp_equip_break", strongerId = "hero_break", condition = handler(self, self.checkEvolve1Pass), event = QTutorialDefeatedGuide.EVOLVE1},
		-- 	{title = "装备强化", typeName = "enhance", sp = "sp_equip_enhance", strongerId = "equip_enhance", condition = handler(self, self.checkEnhancePass), event = QTutorialDefeatedGuide.ENHANCE},
		-- 	{title = "装备觉醒", typeName = "enchant", sp = "sp_equip_enchant", strongerId = "equip_enchant", condition = handler(self, self.checkEnchantPass), event = QTutorialDefeatedGuide.ENCHANTE},
		-- 	{title = "魂骨突破", typeName = "gemstone_break", sp = "sp_stone_break", strongerId = "gemstone_break", condition = handler(self, self.checkGemstoneBreakthrough), event = QTutorialDefeatedGuide.GEMSTONE_EVOLVE},
		-- 	-- {title = "成长大师", typeName = "grow_up", sp = "sp_exp", condition = handler(self, self.checkHeroGrow), event = QTutorialDefeatedGuide.GROW},
		-- 	-- {title = "酒馆召唤", typeName = "tavern_summon", sp = "sp_exp", event = QTutorialDefeatedGuide.TAVERN},
		-- }
		self._animationManager:runAnimationsForSequenceNamed("1")
	else
		if self._options.timeType ~= nil and self._options.timeType == "2" then
			self._animationManager:runAnimationsForSequenceNamed(self._options.timeType)
		else
			self._animationManager:runAnimationsForSequenceNamed("1")
		end
	end
	self.teamName = self._options.teamName or remote.teamManager.INSTANCE_TEAM
	self.stores = self._options.stores
	self.invasion = self._options.invasion
	self.heroOldInfo = self._options.heroOldInfo
	self.oldTeamLevel = self._options.oldTeamLevel

	self:resetAll()
	
	self.mvpHeroId = self:getMvpActorId()
	self:_playVictorySound(self.mvpHeroId)
	self:changeActorBg(self.mvpHeroId)
	-- win elements
	if not self.openTime then self.openTime = q.time() end
	
	-- 初始化进度条
	if not self._percentBarClippingNode and self._options.isWin then
		self._totalStencilPosition = self._ccbOwner.sp_fightProgress_bar:getPositionX() -- 这个坐标必须sp_fightProgress_bar节点的锚点为(0, 0.5)
		self._percentBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.sp_fightProgress_bar)
		self._totalStencilWidth = self._ccbOwner.sp_fightProgress_bar:getContentSize().width * self._ccbOwner.sp_fightProgress_bar:getScaleX()
	end

	-- boss介绍（输的时候）
	-- if not self._options.isWin  then
	-- 	if self._options.config then
	-- 		local id = self._options.config.monster_id
	-- 		local monstersConfig = QStaticDatabase.sharedDatabase():getMonstersById(id)
	-- 		if monstersConfig then
	-- 			for _, config in ipairs(monstersConfig) do
	-- 				if config.boss_show then
	-- 					self._bossId = config.npc_id
	-- 					self._enemyTips = config.boss_show
	-- 					self._ccbOwner.node_btn_bossIntroduce:setVisible(false)
	-- 					break
	-- 				else
	-- 					self._bossId = nil
	-- 					self._enemyTips = nil
	-- 					self._ccbOwner.node_btn_bossIntroduce:setVisible(false)
	-- 				end
	-- 			end
	-- 		end
	-- 	else
	-- 		self._bossId = nil
	-- 		self._enemyTips = nil
	-- 		self._ccbOwner.node_btn_bossIntroduce:setVisible(false)
	-- 	end
	-- end
end

function QBattleDialogBaseFightEnd:onEnter()
end

function QBattleDialogBaseFightEnd:onExit()
end

function QBattleDialogBaseFightEnd:changeActorBg(actorId)
	if not self._options.isWin then return end
	local actorInfo = QStaticDatabase:sharedDatabase():getActorSABC(actorId)
	if actorInfo == nil then return end
	local texture
    if actorInfo.lower == "b" then
    	texture = CCTextureCache:sharedTextureCache():addImage("res/map/battle_bj1.jpg")
	elseif actorInfo.lower == "s" then
    	texture = CCTextureCache:sharedTextureCache():addImage("res/map/battle_bj3.jpg")
	elseif actorInfo.lower == "ss" then
    	texture = CCTextureCache:sharedTextureCache():addImage("res/map/battle_bj4.jpg")
    else
    	texture = CCTextureCache:sharedTextureCache():addImage("res/map/battle_bj2.jpg")
    end
    self._ccbOwner.bj:setTexture(texture)
    if not self._options.isWin then
		makeNodeFromNormalToGray(self._ccbOwner.bj)
	end
end

function QBattleDialogBaseFightEnd:_createTouchNode()
  	self._touchNode = CCNode:create()
    self._touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    self._touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self._touchNode:setTouchSwallowEnabled(true)
    self:addChild(self._touchNode)
	self._touchNode:setTouchEnabled( true )
	self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self._onTouch))
end

function QBattleDialogBaseFightEnd:_onTouch(event)
	if event.name == "began" then
		return true
	elseif event.name == "ended" then
		if self._CP ~= nil and event.x >=  self._CP.x - self._size.width/2 and event.x <= self._CP.x + self._size.width/2 and
			event.y >=  self._CP.y - self._size.height/2 and event.y <= self._CP.y + self._size.height/2  then
			self:onTriggerNext()
		else
			if self._handTouch and self._handTouch.showFocus then
				self._handTouch:showFocus( self._CP )
			end
		end
	end
end

function QBattleDialogBaseFightEnd:resetAll()
	self.heroHeadWidth = 96 -- ccb里node_heroHead_2和node_heroHead_1的X坐标差
	self.awardNormalWidth = 80 -- ccb里node_award_normal_item_2和node_award_normal_item_1的X坐标差
	self.awardEquationWidth = 110 -- ccb里node_award_equation_item_2和node_award_equation_item_1的X坐标差

	-- lost
	-- self.tiltleOver = ccp(self._ccbOwner.sp_over:getPosition()) --要塞用战斗结束

	if not self._options.isWin then
		-- self.gotoPos1 = ccp(self._ccbOwner.sp_train:getPosition())
		-- self.gotoPos2 = ccp(self._ccbOwner.sp_equip_break:getPosition())
		-- self.gotoPos3 = ccp(self._ccbOwner.sp_upgrade:getPosition())

		-- lost client
		self._ccbOwner.node_lost_client:setVisible(false)
		self._ccbOwner.node_bg_lost:setVisible(false)
		-- lost goto
		self._ccbOwner.node_lost_1:setVisible(false) 
		self._ccbOwner.node_lost_2:setVisible(false)
		self._ccbOwner.node_lost_3:setVisible(false)
	else
		-- win or lost bg
		-- self._ccbOwner.node_bg:setVisible(false)
		self._ccbOwner.node_bg_lost:setVisible(false)
		-- self._ccbOwner.s9s_bg_lost:setVisible(false)
		self._ccbOwner.node_bg_win:setVisible(false)
		-- self._ccbOwner.s9s_bg_win:setVisible(false)
		-- win client
		self._ccbOwner.node_win_client:setVisible(false)
		-- << TOP >>
		-- win star title
		-- self._ccbOwner.node_win_title:setVisible(false)
		self._ccbOwner.node_win_star_title:setVisible(false)
		self._ccbOwner.sp_great:setVisible(false)

		self._ccbOwner.node_win_text_title:setVisible(false)
		self._ccbOwner.tf_win_title:setString("")
		-- exp money score
		self._ccbOwner.tf_exp:setString("")
		self._ccbOwner.node_exp:setVisible(false)
		self._ccbOwner.tf_money:setString("")
		self._ccbOwner.node_money:setVisible(false)
		self._ccbOwner.tf_score:setString("")
		self._ccbOwner.node_score:setVisible(false)
		self._ccbOwner.node_exp_money_score:setVisible(false)
		-- << MIDDLE >>
		-- pvp
		self._ccbOwner.node_team_match:setVisible(false)
		-- hero head
		self._ccbOwner.ly_hero_head_size:setVisible(false)
		for i = 1, 5 do
			self._ccbOwner["node_heroHead_"..i]:setVisible(false)
			self._ccbOwner["node_heroHead_icon_"..i]:setVisible(false)
			self._ccbOwner["node_heroHead_icon_"..i]:removeAllChildren()
		end
		self._ccbOwner.node_hero_head:setVisible(false)
		self._ccbOwner.tf_double:setVisible(false)
		self._ccbOwner.node_fight_club:setVisible(false)
		self._ccbOwner.node_soulTower_data:setVisible(false)

		-- fight data
		self._ccbOwner.tf_fightData_damage_title:setString("")
		self._ccbOwner.tf_fightData_damage_value:setString("")
		self._ccbOwner.sp_fightData_playerRecall:setVisible(false)
		self._ccbOwner.tf_warning:setVisible(false)
		self._ccbOwner.node_fightData_damage:setVisible(false)
		self._ccbOwner.tf_fightData_meritorious_title:setString("")
		self._ccbOwner.tf_fightData_meritorious_value:setString("")
		self._ccbOwner.node_fightData_meritorious:setVisible(false)
		self._ccbOwner.tf_fightData_damageRank_title:setString("")
		self._ccbOwner.tf_fightData_damageRank_old:setString("")
		self._ccbOwner.tf_fightData_damageRank_new:setString("")
		self._ccbOwner.node_fightData_damage_rank:setVisible(false)
		self._ccbOwner.tf_fightData_meritoriousRank_title:setString("")
		self._ccbOwner.tf_fightData_meritoriousRank_old:setString("")
		self._ccbOwner.tf_fightData_meritoriousRank_new:setString("")
		self._ccbOwner.node_fightData_meritorious_rank:setVisible(false)
		-- << BOTTOM >>
		-- award title
		self._ccbOwner.tf_award_title:setString("")
		self._ccbOwner.node_award_title:setVisible(false)
		-- award normal
		self._ccbOwner.ly_award_normal_size:setVisible(false)
		for i = 1, 8 do
			self._ccbOwner["node_award_normal_item_"..i]:removeAllChildren()
		end
		self._ccbOwner.node_award_normal_client:setVisible(false)
		self._ccbOwner.node_award_normal:setVisible(false)
		-- award equation
		self._ccbOwner.ly_award_equation_size:setVisible(false)
		for i = 1, 3 do
			self._ccbOwner["node_plus_"..i]:setVisible(false)
		end
		self._ccbOwner.node_equal:setVisible(false)
		for i = 1, 5 do
			self._ccbOwner["tf_award_equation_item_"..i]:setString("")
			self._ccbOwner["node_award_equation_item_"..i]:removeAllChildren()
		end
		self._ccbOwner.node_award_equation:setVisible(false)
	end
end

function QBattleDialogBaseFightEnd:setBoxInfo(box, itemID, itemType, num)
	if box ~= nil then
		box:setGoodsInfo(itemID,itemType,num)
		box:setVisible(true)
		
		if itemID ~= nil and remote.stores:checkItemIsNeed(itemID, num) then
			box:showGreenTips(true)
		end
	end
end

function QBattleDialogBaseFightEnd:setHeroInfo(exp)
	if not self.teamName or not exp or not self.heroOldInfo then return end
	self.heroBox = {}
	local heroHeadCount =  0
	if self._skipLocal then
		local teamCount = #self.heroOldInfo or 0
		for i = 1, teamCount, 1 do
			local hero = self.heroOldInfo[i]
			self.heroBox[i] = QUIWidgetBattleWinHeroHead.new()
			self.heroBox[i]:setHeroHeadInfo(hero.actorId, hero.level, hero.grade)
			self.heroBox[i]:isMvp( false ) 
			if hero.breakthrough then
				self.heroBox[i]:setHeroBreakthrough(hero.breakthrough)
			end
			if hero.godSkillGrade then
				self.heroBox[i]:setGodSkillShowLevel(hero.godSkillGrade)
			end
			self._ccbOwner["node_heroHead_icon_" .. i]:addChild(self.heroBox[i])
			self.heroBox[i]:expOldFull()
			self._ccbOwner["node_heroHead_" .. i]:setVisible(true)
			self._ccbOwner["node_heroHead_icon_" .. i]:setVisible(true)
		end

		heroHeadCount =  teamCount
	else
		local actorIds = remote.teamManager:getActorIdsByKey(self.teamName, 1)
		local teamCount = #actorIds
		if self._options.isQuickPass then
			teamCount = #self.heroOldInfo or 0
		end
		for i = 1, teamCount, 1 do
			local hero = remote.herosUtil:getHeroByID(actorIds[i])
			if self._options.isQuickPass then
				hero = self.heroOldInfo[i]
			end
			self.heroBox[i] = QUIWidgetBattleWinHeroHead.new()
			self.heroBox[i]:setHeroHead(hero.actorId, hero.level, hero.grade)
			self.heroBox[i]:isMvp( false ) 
			self._ccbOwner["node_heroHead_icon_" .. i]:addChild(self.heroBox[i])
			
			local curLevelExp = QStaticDatabase.sharedDatabase():getExperienceByLevel(hero.level)
			local heroInfo = clone(hero)
			local heroOldInfo = clone(self.heroOldInfo[i])
			local oldLevel, oldExp = remote.herosUtil:subHerosExp(heroInfo.level, heroInfo.exp, exp)
			heroOldInfo.level = oldLevel
			heroOldInfo.exp = oldExp
			local heroMaxLevel = remote.herosUtil:getHeroMaxLevel()
			local oldCurLevelExp = QStaticDatabase.sharedDatabase():getExperienceByLevel(heroOldInfo.level)

			if heroMaxLevel == hero.level and hero.exp == (curLevelExp - 1) then
				if heroOldInfo.level == hero.level and heroOldInfo.exp == (curLevelExp - 1) then
					self.heroBox[i]:expOldFull()
				else
					self.heroBox[i]:expFull(heroOldInfo.exp, curLevelExp)
				end
			elseif heroOldInfo.level == hero.level then
				self.heroBox[i]:setExpBar(hero.exp, exp, curLevelExp)
			elseif heroOldInfo.level == hero.level and heroOldInfo.exp == hero.exp then
				self.heroBox[i]:noExpAdd(heroOldInfo.exp, curLevelExp)
			else
				self.heroBox[i]:setUpExpBar(heroOldInfo, oldCurLevelExp, exp , hero, curLevelExp)
			end
			self._ccbOwner["node_heroHead_" .. i]:setVisible(true)
			self._ccbOwner["node_heroHead_icon_" .. i]:setVisible(true)
		end 
		heroHeadCount =  teamCount
	end

	return heroHeadCount
end

function QBattleDialogBaseFightEnd:onExpUpdate(value)
    self._ccbOwner.tf_exp:setString("+"..tostring(math.ceil(value)))
end

function QBattleDialogBaseFightEnd:onMoneyUpdate(value)
    self._ccbOwner.tf_money:setString("+"..tostring(math.ceil(value)))
end

function QBattleDialogBaseFightEnd:hideAllPic()
	-- for _, v in ipairs(self._guidePrompts) do 
	-- 	self._ccbOwner[v.sp]:setVisible(false)
	-- end
end

function QBattleDialogBaseFightEnd:setWinTextTitle(strTBl)
	if not strTBl or #strTBl == 0 then return end
	for _, str in ipairs(strTBl) do
		local sp = self._ccbOwner["sp_"..str]
		if sp then
			sp:setVisible(true)
		else
			print("Not found <<sp_"..str..">> in [[Battle_Dialog_FightEnd.ccbi]] !")
		end
	end
end

--选出最适合的几个
function QBattleDialogBaseFightEnd:chooseBestGuide()
	if (remote.user.level or 1) < 5 then
		self._ccbOwner.btn_stronger:setVisible(false)
		return
	end

	local lostHelpList = remote.strongerUtil:getStrongerHelpList()
	table.sort(lostHelpList, function(a, b)
		local aValue = (a.curValue or 0)/(a.standardValue or 999)
		local bValue = (b.curValue or 0)/(b.standardValue or 999)
		if aValue ~= bValue then
			return aValue < bValue
		elseif a.weight ~= b.weight then
			return a.weight > b.weight
		end
		return a.id < b.id
	end)

	local maxCount = 3
	for i = 1, maxCount, 1 do
		local node = self._ccbOwner["node_lost_"..i]
		local info = lostHelpList[i]
		if node and info then
			node:removeAllChildren()
			node:setVisible(true)

			local lostWidget = QUIWidgetFightEndLostHelp.new()
			lostWidget:setInfo(info)
			lostWidget:addEventListener(QUIWidgetFightEndLostHelp.EVENT_GO_CLICK, handler(self, self._lostHelpClickHandler))
			node:addChild(lostWidget)
		else
			break
		end
	end
end

function QBattleDialogBaseFightEnd:_lostHelpClickHandler(e)
	-- self:onTriggerNext()
	self:_onClose()
	remote.strongerUtil:gotoByInfo(e.info)
end

function QBattleDialogBaseFightEnd:getDefeatHero()
	local heros = remote.herosUtil:getMaxForceHeros()
	if next(heros) == nil then
		return false
	end
	local equpmentId = EQUIPMENT_TYPE.BRACELET
	return true, heros[1].id, equpmentId
end

-- 显示货币暴击特效
function QBattleDialogBaseFightEnd:setYieldInfo(yield, key, curCount, node, scale, pos, isShake, isUpdate, updateItem)
	local yieldLevel = QStaticDatabase:sharedDatabase():getYieldLevelByYieldData(yield, key)
	local yieldAnimation = QUIWidgetAnimationPlayer.new()
	if pos then
		node:addChild(yieldAnimation)
		yieldAnimation:setPosition(pos.x, pos.y)
	end
	if scale then
		yieldAnimation:setScale(scale)
	end
	yieldAnimation:playAnimation("ccb/effects/baoji_shuzi.ccbi", function(ccbOwner)
			for i = 1, 3, 1 do
				ccbOwner["sp_crit"..i]:setVisible(false)
			end
			ccbOwner["sp_crit"..yieldLevel]:setVisible(true)
			ccbOwner["tf_crit"..yieldLevel]:setString(yield)
			-- if isShake then
			-- 	self:_setItemBoxShakeEffect(node)
			-- end
		end, function()
			if isUpdate and updateItem then
				updateItem:_scrollItemNum(curCount, curCount * yield)
			end
		end, false)
end

function QBattleDialogBaseFightEnd:_setItemBoxShakeEffect(node)
	local time = 0.032
	local ccArray = CCArray:create()
	ccArray:addObject(CCScaleTo:create(time, 0.96))
	ccArray:addObject(CCScaleTo:create(time, 1))
	node:runAction(CCSequence:create(ccArray))
end

function QBattleDialogBaseFightEnd:_getGuidePromptsByType(typeName)
	for _, v in ipairs(self._guidePrompts) do
		if v.typeName == typeName then
			return v
		end
	end
end

function QBattleDialogBaseFightEnd:onTriggerNext(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_next) == false then return end
	if self._touchNode then
		self._touchNode:removeFromParent()
		self._touchNode = nil
	end
	if self._options.isNeedTutorial and self._ccbOwner.node_tutorial then
		self._ccbOwner.node_tutorial:removeAllChildren()
	end
	self:_onTriggerNext()
end

-- 播放胜利语音
function QBattleDialogBaseFightEnd:_playVictorySound(heroId)
	print("QBattleDialogBaseFightEnd:_playVictorySound--",heroId)
	if not heroId then return end
	local cheerSound = nil
	local strHeroId = tostring(heroId)
	local info = db:getCharacterByID(strHeroId)
	local heroInfo = remote.herosUtil:getHeroByID(strHeroId)
	if heroInfo ~= nil then
		local skinInfo = remote.heroSkin:getHeroSkinBySkinId(strHeroId, heroInfo.skinId)
		cheerSound = skinInfo.cheer
	end
	if not cheerSound then
		cheerSound = info.cheer or nil
	end
	if cheerSound then
    	local soundEffect = QSoundEffect.new(cheerSound)
    	soundEffect:play(false)
	end
end

function QBattleDialogBaseFightEnd:getMvpActorId()
	if not self._options.isWin then return end

	local log = nil
	local heroId = nil

	local heros = {}
	if app.battle then
		local maxDamage = 0
		local rawBattleLogFromServer = app.battle:getRawBattleLogFromServer()
		if rawBattleLogFromServer then
			log = QBattleLog.new()
			log:setBattleLogFromServer(rawBattleLogFromServer)
			log = log:getBattleLog()
		else
			log = app.battle:getBattleLog()
		end
		for _, hero in pairs(log.heroStats) do
			if not app.battle:isGhost(hero.actor) and hero.show and hero.actor then
				if not hero.actor:isSupport() or app.battle:getSupportSkillHero() == hero.actor or app.battle:getSupportSkillHero2() == hero.actor then
					table.insert(heros, hero.actor:getActorID(true))
					-- if hero.damage >= maxDamage then
					-- 	maxDamage = hero.damage
					-- 	heroId = hero.actor:getActorID()
					-- end
				end
			end
		end
	else
		for _, value in pairs(self.heroOldInfo) do
			table.insert(heros, value.actorId)
		end
	end
	-- 随机展示英雄
	if q.isEmpty(heros) == false then
		local index = math.random(1, #heros)
		heroId = heros[index]
	end
	

	if heroId then
		local db = QStaticDatabase:sharedDatabase()
		local info = db:getCharacterByID(tostring(heroId))
		local dialogDisplay = db:getDialogDisplay()[tostring(heroId)]
		local card = "icon/hero_card/art_snts.png"
		
		local x = 0
		local y = 0
		local scale = 1
		local rotation = 0
		local turn = 1

		local _heroInfo = remote.herosUtil:getHeroByID(tostring(heroId))
		
		-- QPrintTable(_heroInfo)
    	local _cardPath = ""
    	local cheerDialog
    	if not self._skipLocal and not self._isCollegeTrain then
			if _heroInfo and _heroInfo.skinId and _heroInfo.skinId > 0 then
				local skinConfig = remote.heroSkin:getHeroSkinBySkinId(tostring(heroId), _heroInfo.skinId)
				if not self._options.isWin and skinConfig.battle_lose_hide then
					skinConfig = {}
				end
		        if skinConfig.fightEnd_card then
		        	-- print("use skin handBookCard", heroId, skinConfig.skins_name)
		        	_cardPath = skinConfig.fightEnd_card
					if skinConfig.fightEnd_display then
						local skinDisplaySetConfig = remote.heroSkin:getSkinDisplaySetConfigById(skinConfig.fightEnd_display)
						x = skinDisplaySetConfig.x or 0
						y = skinDisplaySetConfig.y or 0
						scale = skinDisplaySetConfig.scale or 1
						rotation = skinDisplaySetConfig.rotation or 0
						turn = skinDisplaySetConfig.isturn or 1
					end
		        end
		        cheerDialog = skinConfig.cheer_dialog
			end
		end
		if _cardPath == "" then
			if dialogDisplay and dialogDisplay.fightEnd_card then
				card = dialogDisplay.fightEnd_card
				x = dialogDisplay.fightEnd_x
				y = dialogDisplay.fightEnd_y
				scale = dialogDisplay.fightEnd_scale
				rotation = dialogDisplay.fightEnd_rotation
				turn = dialogDisplay.fightEnd_isturn
			end
		else
			card = _cardPath
		end
		local frame = QSpriteFrameByPath(card)
		if frame then
			self._ccbOwner.sp_bg_mvp:setDisplayFrame(frame)
			self._ccbOwner.sp_bg_mvp:setPosition(x, y)
			self._ccbOwner.sp_bg_mvp:setScaleX(scale*turn)
			self._ccbOwner.sp_bg_mvp:setScaleY(scale)
			self._ccbOwner.sp_bg_mvp:setRotation(rotation)
			self._ccbOwner.sp_bg_mvp_icon:setVisible(false)
		else
			assert(false, "<<<"..card..">>>not exist!")
		end
		self._ccbOwner.label_name_title:setString(info.title or "")
		self._ccbOwner.label_name:setString(info.name or "")

		if self._options.isWin then
		    if not cheerDialog then
		        cheerDialog = info.cheer_dialog
		    end
			self._ccbOwner.tf_hero_tip:setString(cheerDialog or "")
		else
			makeNodeFromNormalToGray(self._ccbOwner.sp_bg_mvp)
		end
	end

	return heroId
end

function QBattleDialogBaseFightEnd:onTriggerData(event)
    app.sound:playSound("common_small")
    QBattleDialogAgainstRecord.new({},{}) 
end

function QBattleDialogBaseFightEnd:resetBattleState()
	remote.arena:setInBattle(false)
	remote.sparField:setInBattle(false)
	remote.fightClub:setInBattle(false)
end

function QBattleDialogBaseFightEnd:onTriggerGoto(event, target)
	app.sound:playSound("common_small")
	if self._options.dialogType == "blackRock" then
		app.tip:floatTip("魂师大人，请等待队伍结算后才可以前往其他界面噢~")
		return
	end

	self:resetBattleState()
	for i, v in ipairs(self._curGuides) do 
		if self._ccbOwner["btn_lost_"..i] == target then
			self._ccbOwner:onChoose({name = v.event, options = {actorId = v.actorId, equipmentId = v.equipmentId}})
			return
		end
	end
end
	
function QBattleDialogBaseFightEnd:onTriggerBossIntroduce(event)
	app.sound:playSound("common_small")
	if self._bossId and self._enemyTips then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBossIntroducePic",
				options = {bossId = self._bossId, enemyTips = self._enemyTips}})
	end
end
	
function QBattleDialogBaseFightEnd:onTriggerStronger(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_stronger) == false then return end
	app.sound:playSound("common_small")
  	self:_onClose()
	self:resetBattleState()
   	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogStrongerHelp"})
end

function QBattleDialogBaseFightEnd:_backClickHandler()
	if not self.openTime then self.openTime = q.time() end
	
	local time = 3.5
	if not self._options.isWin  then
		time = 1.1
	end
	if q.time() - self.openTime > time then
  		self:_onClose()
  	end
end

function QBattleDialogBaseFightEnd:_onClose()
	if self.dialogCard ~= nil then
		self.dialogCard:removeFromParent()
		self.dialogCard = nil
	end
  	if self.stores and self.oldTeamLevel and self.invasion == nil then
	  	app.sound:playSound("common_next")
	    local unlockVlaue = QStaticDatabase.sharedDatabase():getConfiguration()
	    for _, value in pairs(self.stores) do 
            if value.id == tonumber(SHOP_ID.goblinShop) and self.oldTeamLevel >= app.unlock:getConfigByKey("UNLOCK_SHOP_1").team_level then
                app.tip:addUnlockTips(QUIDialogMystoryStoreAppear.FIND_GOBLIN_SHOP)
            elseif value.id == tonumber(SHOP_ID.blackShop) and self.oldTeamLevel >= app.unlock:getConfigByKey("UNLOCK_SHOP_2").team_level then
                app.tip:addUnlockTips(QUIDialogMystoryStoreAppear.FIND_BLACK_MARKET_SHOP)
            end
      	end
  	end 
	self._ccbOwner:onChoose()
	if self._audioHandler then
		audio.stopSound(self._audioHandler)
	end
end

-- 进度条宝箱的显示
function QBattleDialogBaseFightEnd:setProgressBox(curProportion, goalProportionList)
	if not curProportion then curProportion = 0 end
	curProportion = tonumber(curProportion)
	if not goalProportionList or not next(goalProportionList) then goalProportionList = {0.25, 0.5, 0.75, 1} end
	local stencil = self._percentBarClippingNode:getStencil()
    stencil:setPositionX(-self._totalStencilWidth + curProportion*self._totalStencilWidth)
    -- print(self._totalStencilPosition, self._totalStencilWidth, curProportion, -self._totalStencilWidth + curProportion*self._totalStencilWidth)
    for index, goalProportion in ipairs(goalProportionList) do
    	local node = self._ccbOwner["node_fightProgress_box_"..index]
    	if node then
			self._ccbOwner["sp_fightProgressBox_open_"..index]:setVisible(false)
    		self._ccbOwner["ccb_fightProgressBox_light_"..index]:setVisible(false)
    		self._ccbOwner["sp_fightProgressBox_close_"..index]:setVisible(false)

	    	node:setPositionX(goalProportion*self._totalStencilWidth + self._totalStencilPosition)
	    	-- print(self._totalStencilPosition, self._totalStencilWidth, goalProportion, goalProportion*self._totalStencilWidth + self._totalStencilPosition)
	    	node:setVisible(true)
	    	if curProportion >= tonumber(goalProportion) then
	    		self._ccbOwner["sp_fightProgressBox_open_"..index]:setVisible(true)
	    		self._ccbOwner["ccb_fightProgressBox_light_"..index]:setVisible(true)
	    	else
	    		self._ccbOwner["sp_fightProgressBox_close_"..index]:setVisible(true)
	    	end
	    else
	    	break
	    end
    end
end

--掉落的道具展示
function QBattleDialogBaseFightEnd:showDropItems(items)
	local itemsBox = {}
	local index = 1
	local gapX, gapY = 75, 65
	local startPosX, startPosY, scale = 0, 10, 0.8
	local maxLinNum = 5

	self._ccbOwner.node_award_normal_client:setPositionX(130)
	self._ccbOwner.node_award_normal_client:setPositionY(-137)
	if #items <= maxLinNum then
		startPosX = (maxLinNum - #items) * (gapX / 2)
		startPosY = 25
	else
		self._ccbOwner.node_btn_next:setPositionY(-252)
		self._ccbOwner.node_award_normal_client:setPositionY(-130)
		scale = 0.7
	end
	for i, value in ipairs(items) do
		local itemInfo = items[i]
		if itemInfo then 
			itemsBox[i] = QUIWidgetItemsBox.new()
	    	itemsBox[i]:setScale(0)
	    	itemsBox[i]:setPromptIsOpen(true)
	    	itemsBox[i]:setPosition(startPosX, - startPosY)
	    	itemsBox[i]:resetAll()
			self:setBoxInfo(itemsBox[i], itemInfo.id, itemInfo.type, itemInfo.count)
			if itemInfo.activityYield and itemInfo.activityYield > 1 then
				itemsBox[i]:setRateActivityState(true)	
			end
			if itemInfo.isActivity then
				itemsBox[i]:setAwardName("活动")
			end
			self._ccbOwner.node_award_normal_client:addChild(itemsBox[i])

			startPosX = startPosX + gapX
			if i % maxLinNum == 0 then
				startPosY = startPosY + gapY
				startPosX = 0
			end
		end
	end

	local showItemFunc
	showItemFunc = function()
		if itemsBox[index] then
			local ccarray = CCArray:create()
			ccarray:addObject(CCScaleTo:create(1/15, scale))
			ccarray:addObject(CCScaleTo:create(1/15, scale-0.02))
			ccarray:addObject(CCCallFunc:create(function()
					index = index + 1
					showItemFunc()
				end))
			itemsBox[index]:runAction(CCSequence:create(ccarray))
		end
	end
	RunActionDelayTime(self._ccbOwner.node_award_normal_client, function ()
		if q.isEmpty(items) == false then
			showItemFunc()
		end
	end, 2)

	return itemsBox
end

return QBattleDialogBaseFightEnd