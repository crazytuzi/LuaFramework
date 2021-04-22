--
-- Kumo.Wang
-- 西尔维斯大斗魂场战斗单场结算
-- 

local QBattleDialog = import(".QBattleDialog")
local QBattleDialogSilvesArenaResult = class("QBattleDialogSilvesArenaResult", QBattleDialog)

local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QBattleDialogSilvesArenaResult:ctor(options, owner)
	local ccbFile = "ccb/Dialog_SilvesArena_OnceWin.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerNext", callback = handler(self, self._onTriggerNext)},
	}
	if owner == nil then 
		owner = {}
	end

	if not options then
		options = {}
	end
	
	self:setNodeEventEnabled(true)
	QBattleDialogSilvesArenaResult.super.ctor(self,ccbFile,owner,callBacks)

	q.setButtonEnableShadow(self._ccbOwner.btn_next)

    CalculateUIBgSize(self._ccbOwner.ly_bg)

	local isWin = options.isWin
	local curIndex = options.index
	self._callback = options.callback
	local dungeonConfig = app.battle:getDungeonConfig()
	-- QKumo(dungeonConfig)
	local teamInfo = {}
	if q.isEmpty(remote.silvesArena.fightInfo) then
		self:_onTriggerNext()
	else
		local attackFightInfo = remote.silvesArena.fightInfo.attackFightInfo or {}
		for _, info in pairs(attackFightInfo) do
			if info.silvesArenaFightPos == curIndex then
				teamInfo.hero = info
				break
			end
		end

		local defenseFightInfo = remote.silvesArena.fightInfo.defenseFightInfo or {}
		for _, info in pairs(defenseFightInfo) do
			if info.silvesArenaFightPos == curIndex then
				teamInfo.enemy = info
				break
			end
		end
	end
	if q.isEmpty(teamInfo) then
		self:_onTriggerNext()
	else
		self.info = {team1Heros = teamInfo.hero.heros, team2Heros = teamInfo.enemy.heros, team1Name = dungeonConfig.team1Name, team2Name = dungeonConfig.team2Name, team1Force = teamInfo.hero.force, team2Force = teamInfo.enemy.force}
	end
	
	if q.isEmpty(self.info) then
		self:_onTriggerNext()
	else
		local index = 1
		if self.info.team1Heros then
			for _, value in pairs(self.info.team1Heros) do
				local heroHead = QUIWidgetHeroHead.new()
				self._ccbOwner["team1_hero_node_" .. index]:addChild(heroHead)
				heroHead:setHeroSkinId(value.skinId)
				heroHead:setHero(value.actorId)
				heroHead:setLevel(value.level)
				heroHead:setBreakthrough(value.breakthrough)
	            heroHead:setGodSkillShowLevel(value.godSkillGrade)
				heroHead:setStar(value.grade)
				heroHead:setTeam(1)
				heroHead:showSabc()
				index = index +1
			end
		end
		index = 9	
		if teamInfo.hero.soulSpirit then
			for _,value in ipairs(teamInfo.hero.soulSpirit) do
				local heroHead = QUIWidgetHeroHead.new()
				self._ccbOwner["team1_hero_node_" .. index]:addChild(heroHead)
				heroHead:setHero(value.id)
				heroHead:setLevel(value.level)
				heroHead:setBreakthrough(value.breakthrough)
	            heroHead:setGodSkillShowLevel(value.godSkillGrade)
				heroHead:setStar(value.grade)
				heroHead:setTeam(1)
				heroHead:showSabc()
				index = index +1
			end
		end

		index = 11	
		if teamInfo.hero.godArm1List then
			for i,fighter in pairs(teamInfo.hero.godArm1List) do
				local heroHead = QUIWidgetHeroHead.new()
				self._ccbOwner["team1_hero_node_" .. index]:addChild(heroHead)
		        local widgetHead = QUIWidgetHeroHead.new()
		        heroHead:setHero(fighter.id)
		        heroHead:setTeam(i,false,false,true)
		        heroHead:setStar(fighter.grade)
		        heroHead:showSabc()
		        heroHead:setTeam(1)	
				index = index +1	        
			end
		end

		local num,unit = q.convertLargerNumber(self.info.team1Force)
		self._ccbOwner.team1Force:setString(num..unit)

		local index = 1
		if self.info.team2Heros then
			for _, value in pairs(self.info.team2Heros) do
				local heroHead = QUIWidgetHeroHead.new()
				self._ccbOwner["team2_hero_node_" .. index]:addChild(heroHead)
				heroHead:setHeroSkinId(value.skinId)
				heroHead:setHero(value.actorId)
				heroHead:setLevel(value.level)
				heroHead:setBreakthrough(value.breakthrough)
	            heroHead:setGodSkillShowLevel(value.godSkillGrade)
				heroHead:setStar(value.grade)
				heroHead:setTeam(1)
				heroHead:showSabc()
				index = index +1
			end
		end
		index = 9
		if teamInfo.enemy.soulSpirit then
			for _,value in ipairs(teamInfo.enemy.soulSpirit) do
				local heroHead = QUIWidgetHeroHead.new()
				self._ccbOwner["team2_hero_node_" .. index]:addChild(heroHead)
				heroHead:setHero(value.id)
				heroHead:setLevel(value.level)
				heroHead:setBreakthrough(value.breakthrough)
	            heroHead:setGodSkillShowLevel(value.godSkillGrade)
				heroHead:setStar(value.grade)
				heroHead:setTeam(1)
				heroHead:showSabc()
				index = index +1
			end
		end

		index = 11
		if teamInfo.enemy.godArm1List then
			for i,fighter in pairs(teamInfo.enemy.godArm1List) do
				local heroHead = QUIWidgetHeroHead.new()
				self._ccbOwner["team2_hero_node_" .. index]:addChild(heroHead)
		        local widgetHead = QUIWidgetHeroHead.new()
		        heroHead:setHero(fighter.id)
		        heroHead:setTeam(i,false,false,true)
		        heroHead:setStar(fighter.grade)
		        heroHead:showSabc()
		        heroHead:setTeam(1)	
				index = index +1	        
			end
		end

		local num,unit = q.convertLargerNumber(self.info.team2Force)
		self._ccbOwner.team2Force:setString(num..unit)
	

		self._ccbOwner.team1Name:setString(self.info.team1Name or "")
		self._ccbOwner.team2Name:setString(self.info.team2Name or "")
	end

	if isWin then
		makeNodeFromNormalToGray(self._ccbOwner.team2_heros)
		self._ccbOwner.node_win:setVisible(true)
		self._ccbOwner.node_loss:setVisible(false)
		self:setTitleFrame(QResPath("StormArena_Title_Win")[curIndex])
	else
		makeNodeFromNormalToGray(self._ccbOwner.team1_heros)
		self:setTitleFrame(QResPath("StormArena_Title_Loss")[curIndex])
		self._ccbOwner.node_win:setVisible(false)
		self._ccbOwner.node_loss:setVisible(true)
	end

	local animationManager = tolua.cast(self._ccbNode:getUserObject(), "CCBAnimationManager")

	if q.isEmpty(remote.silvesArena.fightInfo.scoreList) then
		self:_onTriggerNext()
	else
		local score_1 = 0
		local score_2 = 0

		for i = 1, curIndex, 1 do
			local score = remote.silvesArena.fightInfo.scoreList[i] or 0
			if score then
				if score == 1 then
					score_1 = score_1 + 1
				end
				if score == 0 then
					score_2 = score_2 + 1
				end
			end
		end

		self._ccbOwner.firstCup:setString(score_1)
		self._ccbOwner.secondCup:setString(score_2)
	end

 	animationManager:runAnimationsForSequenceNamed("timeline")

	self._isExist = true
	self._isPlayAnimation = true
	self.stayTime = 5
	
	self._ccbOwner.countdownTime:setString(string.format("%sS", self.stayTime))
	self.stayTime = self.stayTime - 1
	animationManager:connectScriptHandler(function(name)
      	if self._isExist then
      		self._isPlayAnimation = nil
			self._countdownScheduler = scheduler.scheduleGlobal(function(  )
				if self._isExist then
					self._ccbOwner.countdownTime:setString(string.format("%sS", self.stayTime))
					if self.stayTime > 0 then
						self.stayTime = self.stayTime - 1
					else
						self:onClose()
					end
				end
			end,1)
		end
    end)

	if isWin then
		self._audioHandler = app.sound:playSound("battle_complete")
	else
		self._audioHandler = app.sound:playSound("battle_failed")
	end
	
    audio.stopBackgroundMusic()
end

function QBattleDialogSilvesArenaResult:setTitleFrame( frameName )
    local texture = CCTextureCache:sharedTextureCache():addImage(frameName)
    if texture then
		self._ccbOwner.title1:setTexture(texture)
		self._ccbOwner.title2:setTexture(texture)
		self._ccbOwner.title3:setTexture(texture)
		self._ccbOwner.title4:setTexture(texture)
		self._ccbOwner.title_loss:setTexture(texture)
    end
end

function QBattleDialogSilvesArenaResult:onEnter()
end

function QBattleDialogSilvesArenaResult:onExit()
   self._isExist = nil

   if self._countdownScheduler then
   		scheduler.unscheduleGlobal(self._countdownScheduler)
   		self._countdownScheduler = nil
   end
end

function QBattleDialogSilvesArenaResult:_onTriggerNext()
  	app.sound:playSound("common_item")
  	if self._isPlayAnimation then
  		return
  	end
	self:onClose()
end

function QBattleDialogSilvesArenaResult:onClose()
	if self._callback then
		print("QBattleDialogSilvesArenaResult:onClose(1)  onRestart")
		self._callback(handler(self._ccbOwner, self._ccbOwner.onRestart), handler(self._ccbOwner, self._ccbOwner.onNext))
	else
		print("QBattleDialogSilvesArenaResult:onClose(2)  onNext")
		self._ccbOwner:onNext()
	end
	audio.stopSound(self._audioHandler)
end

return QBattleDialogSilvesArenaResult


