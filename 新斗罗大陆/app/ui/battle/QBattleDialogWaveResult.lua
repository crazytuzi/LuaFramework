--
-- Author: nie ming
-- Date: 2016-10-8 10:58:04
--
local QBattleDialog = import(".QBattleDialog")
local QBattleDialogWaveResult = class("QBattleDialogWaveResult", QBattleDialog)

local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QBattleDialogWaveResult:ctor(options,owner)
	local ccbFile = "ccb/Dialog_StormArena_oncewin.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerNext", callback = handler(self, QBattleDialogWaveResult._onTriggerNext)},
	}
	if owner == nil then 
		owner = {}
	end

	if not options then
		options = {}
	end
	
	local fightScore = options.fightScore or 0
	local curWave = options.curWave or 0

	local isWin = options.isWin
	self._callBack = options.callBack
	self.info = options.info

	self:setNodeEventEnabled(true)
	QBattleDialogWaveResult.super.ctor(self,ccbFile,owner,callBacks)
	
	self.team1HeroBox = {}
	if self.info.team1Heros then
		for index,value in pairs(self.info.team1Heros) do
			local heroHead = QUIWidgetHeroHead.new()
			self._ccbOwner["team1_hero_node_" .. index]:addChild(heroHead)
			heroHead:setHero(value.actorId)
			heroHead:setLevel(value.level)
			heroHead:setBreakthrough(value.breakthrough)
            heroHead:setGodSkillShowLevel(value.godSkillGrade)
			heroHead:setStar(value.grade)
			heroHead:showSabc()
			table.insert(self.team1HeroBox, heroHead)
		end
	end

	-- local heroNum = #self.team1HeroBox
	-- if heroNum < 4 and heroNum > 0 then
	-- 	self._ccbOwner.team1_node_hero:setPositionX(-(heroNum - 1) * 147/2)
	-- end

	self.team2HeroBox = {}
	if self.info.team2Heros then
		for index,value in pairs(self.info.team2Heros) do
			local heroHead = QUIWidgetHeroHead.new()
			self._ccbOwner["team2_hero_node_" .. index]:addChild(heroHead)
			heroHead:setHero(value.actorId)
			heroHead:setLevel(value.level)
			heroHead:setBreakthrough(value.breakthrough)
            heroHead:setGodSkillShowLevel(value.godSkillGrade)
			heroHead:setStar(value.grade)
			heroHead:showSabc()
			table.insert(self.team2HeroBox, heroHead)
		end
	end

	-- heroNum = #self.team2HeroBox
	-- if heroNum < 4 and heroNum > 0 then
	-- 	self._ccbOwner.team2_node_hero:setPositionX(-(heroNum - 1) * 90/2)
	-- end

	self._ccbOwner.team1Name:setString(self.info.team1Name or "")
	self._ccbOwner.team2Name:setString(self.info.team2Name or "")
	
	local num,unit = q.convertLargerNumber(self.info.team1Force or 0)
	self._ccbOwner.team1Force:setString(num..unit)
	local num,unit = q.convertLargerNumber(self.info.team2Force or 0)
	self._ccbOwner.team2Force:setString(num..unit)


	if isWin then
		makeNodeFromNormalToGray(self._ccbOwner.team2_heros)
		self:setTitleFrame(QResPath("StormArena_S_blhs")[curWave + 1])
	else
		makeNodeFromNormalToGray(self._ccbOwner.team1_heros)
		self:setTitleFrame(QResPath("StormArena_S_shibai")[curWave + 1])
		self._ccbOwner.firstCupEffect1:setVisible(false)
		self._ccbOwner.firstCupEffect2:setVisible(false)
		self._ccbOwner.firstCup:setVisible(false)
	end

	local animationManager = tolua.cast(self._ccbNode:getUserObject(), "CCBAnimationManager")

	if fightScore == 1 then
		if animationManager ~= nil and isWin then 
			animationManager:runAnimationsForSequenceNamed("timeline1")
		else
			self._ccbOwner.firstCupEffect1:setVisible(false)
			self._ccbOwner.firstCupEffect2:setVisible(false)
			self._ccbOwner.firstCup:setVisible(true)
		end
	elseif fightScore == 2 then
		self._ccbOwner.firstCupEffect1:setVisible(false)
		self._ccbOwner.firstCupEffect2:setVisible(false)
		self._ccbOwner.firstCup:setVisible(true)
		if animationManager ~= nil and isWin then 
			animationManager:runAnimationsForSequenceNamed("timeline2")
		else
			self._ccbOwner.secondCupEffect1:setVisible(false)
			self._ccbOwner.secondCupEffect2:setVisible(false)
			self._ccbOwner.secondCup:setVisible(true)
    	end
	else
		self._ccbOwner.firstCupEffect1:setVisible(false)
		self._ccbOwner.firstCupEffect2:setVisible(false)
		self._ccbOwner.firstCup:setVisible(false)

		self._ccbOwner.secondCupEffect1:setVisible(false)
		self._ccbOwner.secondCupEffect2:setVisible(false)
		self._ccbOwner.secondCup:setVisible(false)
	end

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

function QBattleDialogWaveResult:setTitleFrame( frameName )
	-- body
	-- local spriteFrameCache = CCSpriteFrameCache:sharedSpriteFrameCache()
 --    spriteFrameCache:addSpriteFramesWithFile("ui/StormArena.plist")
 --   	local spriteFrame = spriteFrameCache:spriteFrameByName(frameName)
   	local spriteFrame = QSpriteFrameByPath(frameName)
    if spriteFrame then
		self._ccbOwner.title1:setDisplayFrame(spriteFrame)
		self._ccbOwner.title2:setDisplayFrame(spriteFrame)
		self._ccbOwner.title3:setDisplayFrame(spriteFrame)
		self._ccbOwner.title4:setDisplayFrame(spriteFrame)
    end
end

function QBattleDialogWaveResult:onEnter()
    
end

function QBattleDialogWaveResult:onExit()
   self._isExist = nil
   if self._countdownScheduler then
   		scheduler.unscheduleGlobal(self._countdownScheduler)
   		self._countdownScheduler = nil
   end
end

function QBattleDialogWaveResult:_onTriggerNext()
  	app.sound:playSound("common_item")
  	if self._isPlayAnimation then
  		return
  	end
	self:onClose()
end

-- function QBattleDialogWaveResult:_backClickHandler()
-- 	if q.time() - self._openTime > 3.5 then
-- 		self._ccbOwner:onChoose()
--   	end
-- end

function QBattleDialogWaveResult:onClose()
	audio.stopSound(self._audioHandler)
	if self._callBack then
		self._callBack()
	end
	self:close()
end


return QBattleDialogWaveResult


