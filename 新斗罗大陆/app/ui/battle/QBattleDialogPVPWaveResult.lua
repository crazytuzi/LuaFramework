local QBattleDialog = import(".QBattleDialog")
local QBattleDialogPVPWaveResult = class("QBattleDialogPVPWaveResult", QBattleDialog)

local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QBattleDialogPVPWaveResult:ctor(options,owner)
	local ccbFile = "ccb/Dialog_StormArena_oncewin.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerNext", callback = handler(self, QBattleDialogPVPWaveResult._onTriggerNext)},
	}
	if owner == nil then 
		owner = {}
	end

	if not options then
		options = {}
	end
	
	local curWave = app.battle:getPVPMultipleNewCurWave()

	local isWin = options.isWin
	self._callBack = options.callBack
	local dungeonConfig = app.battle:getDungeonConfig()
	local teamInfo = app.battle:getDungeonConfig().pvpMultipleTeams[curWave]
	local info = {team1Heros = teamInfo.hero.heroes, team2Heros = teamInfo.enemy.heroes, team1Name = dungeonConfig.myInfo.name, team2Name = dungeonConfig.rivalsInfo.name, team1Force = teamInfo.hero.force, team2Force = teamInfo.enemy.force}
	self.info = info

	self:setNodeEventEnabled(true)
	QBattleDialogPVPWaveResult.super.ctor(self,ccbFile,owner,callBacks)
	
	q.setButtonEnableShadow(self._ccbOwner.btn_next)
	
	local index = 1
	local force = 0
	if self.info.team1Heros then
		for _,value in pairs(self.info.team1Heros) do
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
			if value.force then
				force = force + value.force
			end
			index = index +1
		end
	end
	if teamInfo.hero.supports then
		for _,value in ipairs(teamInfo.hero.supports) do
			local heroHead = QUIWidgetHeroHead.new()
			self._ccbOwner["team1_hero_node_" .. index]:addChild(heroHead)
			heroHead:setHeroSkinId(value.skinId)
			heroHead:setHero(value.actorId)
			heroHead:setLevel(value.level)
			heroHead:setBreakthrough(value.breakthrough)
            heroHead:setGodSkillShowLevel(value.godSkillGrade)
			heroHead:setStar(value.grade)
			heroHead:showSabc()

			local skill_idx = nil
			if app.battle:getSupportSkillHero() then
				if app.battle:getSupportSkillHero():getActorID() == value.actorId then
					skill_idx = 1
				end
			end
			if app.battle:getSupportSkillHero2() then
				if app.battle:getSupportSkillHero2():getActorID() == value.actorId then
					skill_idx = 2
				end
			end
			if skill_idx then
				heroHead:setSkillTeam(skill_idx)
			else
				heroHead:setTeam(2)
			end
			if value.force then
				force = force + value.force
			end
			index = index +1
		end
	end
	index = 9	
	if teamInfo.hero.soulSpirits then
		for _,value in ipairs(teamInfo.hero.soulSpirits) do
			local heroHead = QUIWidgetHeroHead.new()
			self._ccbOwner["team1_hero_node_" .. index]:addChild(heroHead)
			heroHead:setHero(value.id)
			heroHead:setLevel(value.level)
			heroHead:setBreakthrough(value.breakthrough)
            heroHead:setGodSkillShowLevel(value.godSkillGrade)
			heroHead:setStar(value.grade)
			heroHead:setTeam(1)
			heroHead:showSabc()
			if value.force then
				force = force + value.force
			end
			index = index +1
		end
	end

	index = 11	
	if teamInfo.hero.godArmIdList then
		for i,fighter in pairs(teamInfo.hero.godArmIdList) do
			local heroHead = QUIWidgetHeroHead.new()
			self._ccbOwner["team1_hero_node_" .. index]:addChild(heroHead)
	        local godarmInfo = string.split(fighter, ";")  
	        local widgetHead = QUIWidgetHeroHead.new()
	        heroHead:setHero(tonumber(godarmInfo[1]))
	        heroHead:setTeam(i,false,false,true)
	        heroHead:setStar(tonumber(godarmInfo[2]))
	        heroHead:showSabc()
	        heroHead:setTeam(1)	
	        local godarmForce = remote.godarm:getGodarmbattleForce(tonumber(godarmInfo[1]),tonumber(godarmInfo[2]))
	        print("战斗力--------godarmForce",godarmForce)
			force = force + godarmForce 
			index = index +1	        
		end
	end

	local num,unit = q.convertLargerNumber(force or 0)
	self._ccbOwner.team1Force:setString(num..unit)

	-- local heroNum = #self.team1HeroBox
	-- if heroNum < 4 and heroNum > 0 then
	-- 	self._ccbOwner.team1_node_hero:setPositionX(-(heroNum - 1) * 147/2)
	-- end

	self.team2HeroBox = {}
	local index = 1
	force = 0
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
			if value.force then
				force = force + value.force
			end
			index = index +1
		end
	end
	if teamInfo.enemy.supports then
		for _,value in ipairs(teamInfo.enemy.supports) do
			local heroHead = QUIWidgetHeroHead.new()
			self._ccbOwner["team2_hero_node_" .. index]:addChild(heroHead)
			heroHead:setHeroSkinId(value.skinId)
			heroHead:setHero(value.actorId)
			heroHead:setLevel(value.level)
			heroHead:setBreakthrough(value.breakthrough)
            heroHead:setGodSkillShowLevel(value.godSkillGrade)
			heroHead:setStar(value.grade)
			heroHead:showSabc()

			local skill_idx = nil
			if app.battle:getSupportSkillEnemy() then
				if app.battle:getSupportSkillEnemy():getActorID() == value.actorId then
					skill_idx = 1
				end
			end
			if app.battle:getSupportSkillEnemy2() then
				if app.battle:getSupportSkillEnemy2():getActorID() == value.actorId then
					skill_idx = 2
				end
			end
			if skill_idx then
				heroHead:setSkillTeam(skill_idx)
			else
				heroHead:setTeam(2)
			end
			if value.force then
				force = force + value.force
			end
			index = index +1
		end
	end	

	index = 9
	if teamInfo.enemy.soulSpirits then
		for _,value in ipairs(teamInfo.enemy.soulSpirits) do
			local heroHead = QUIWidgetHeroHead.new()
			self._ccbOwner["team2_hero_node_" .. index]:addChild(heroHead)
			heroHead:setHero(value.id)
			heroHead:setLevel(value.level)
			heroHead:setBreakthrough(value.breakthrough)
            heroHead:setGodSkillShowLevel(value.godSkillGrade)
			heroHead:setStar(value.grade)
			heroHead:setTeam(1)
			heroHead:showSabc()
			if value.force then
				force = force + value.force
			end
			index = index +1
		end
	end

	index = 11
	if teamInfo.enemy.godArmIdList then
		for i,fighter in pairs(teamInfo.enemy.godArmIdList) do
			local heroHead = QUIWidgetHeroHead.new()
			self._ccbOwner["team2_hero_node_" .. index]:addChild(heroHead)
	        local godarmInfo = string.split(fighter, ";")  
	        local widgetHead = QUIWidgetHeroHead.new()
	        heroHead:setHero(tonumber(godarmInfo[1]))
	        heroHead:setTeam(i,false,false,true)
	        heroHead:setStar(tonumber(godarmInfo[2]))
	        heroHead:showSabc()
	        heroHead:setTeam(1)	
	        local godarmForce = remote.godarm:getGodarmbattleForce(tonumber(godarmInfo[1]),tonumber(godarmInfo[2]))
			force = force + godarmForce
			index = index +1	        
		end
	end

	local num,unit = q.convertLargerNumber(force)
	self._ccbOwner.team2Force:setString(num..unit)
	
	-- heroNum = #self.team2HeroBox
	-- if heroNum < 4 and heroNum > 0 then
	-- 	self._ccbOwner.team2_node_hero:setPositionX(-(heroNum - 1) * 90/2)
	-- end

	self._ccbOwner.team1Name:setString(self.info.team1Name or "")
	self._ccbOwner.team2Name:setString(self.info.team2Name or "")

	if isWin then
		makeNodeFromNormalToGray(self._ccbOwner.team2_heros)
		self._ccbOwner.node_win:setVisible(true)
		self._ccbOwner.node_loss:setVisible(false)
		self:setTitleFrame(QResPath("StormArena_Title_Win")[curWave])
	else
		makeNodeFromNormalToGray(self._ccbOwner.team1_heros)
		self:setTitleFrame(QResPath("StormArena_Title_Loss")[curWave])
		self._ccbOwner.node_win:setVisible(false)
		self._ccbOwner.node_loss:setVisible(true)
	end

	local animationManager = tolua.cast(self._ccbNode:getUserObject(), "CCBAnimationManager")

	local score_1 = app.battle:getPVPMultipleWaveNewScoreInfo().heroScore
	local score_2 = app.battle:getPVPMultipleWaveNewScoreInfo().enemyScore

	self._ccbOwner.firstCup:setString(score_1)
	self._ccbOwner.secondCup:setString(score_2)

	-- local texture_1 = CCTextureCache:sharedTextureCache():addImage(QResPath("storm_arena_num")[score_1 + 1])
	-- local texture_2 = CCTextureCache:sharedTextureCache():addImage(QResPath("storm_arena_num")[score_2 + 1])

	-- self._ccbOwner.firstCup:setTexture(texture_1)
	-- self._ccbOwner.secondCup:setTexture(texture_2)

 	animationManager:runAnimationsForSequenceNamed("timeline2")

	self._isExist = true
	self._isPlayAnimation = true
	-- if fightScore >= 2 or curWave == 3 or ( curWave == 2 and fightScore == 0)then
	-- 	self.stayTime = 3
	-- 	self._ccbOwner.nextNode:setVisible(false)
	-- else
		self.stayTime = 5
	-- end
	
	self._ccbOwner.countdownTime:setString(string.format("%sS", self.stayTime))
	self.stayTime = self.stayTime - 1
	animationManager:connectScriptHandler(function(name)
      	if self._isExist then
      		self._isPlayAnimation = nil
			self._countdownScheduler = scheduler.scheduleGlobal(function(  )
				-- body
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

function QBattleDialogPVPWaveResult:setTitleFrame( frameName )
	-- body
    --local texture = CCTextureCache:sharedTextureCache():addImage("ui/stormarena/"..frameName)
    local texture = CCTextureCache:sharedTextureCache():addImage(frameName)
    if texture then
		self._ccbOwner.title1:setTexture(texture)
		self._ccbOwner.title2:setTexture(texture)
		self._ccbOwner.title3:setTexture(texture)
		self._ccbOwner.title4:setTexture(texture)
		self._ccbOwner.title_loss:setTexture(texture)
    end
end

function QBattleDialogPVPWaveResult:onEnter()
    
end

function QBattleDialogPVPWaveResult:onExit()
   self._isExist = nil
   if self._countdownScheduler then
   		scheduler.unscheduleGlobal(self._countdownScheduler)
   		self._countdownScheduler = nil
   end
end

function QBattleDialogPVPWaveResult:_onTriggerNext()
  	app.sound:playSound("common_item")
  	if self._isPlayAnimation then
  		return
  	end
	self:onClose()
end

function QBattleDialogPVPWaveResult:onClose()
	audio.stopSound(self._audioHandler)
	if self._callBack then
		self._callBack()
	end
end
return QBattleDialogPVPWaveResult


