
local QTutorialStage = import("..QTutorialStage")
local QTutorialStageEnrolling = class("QTutorialStageEnrolling", QTutorialStage)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("...ui.QUIViewController")
local QSkeletonViewController = import("...controllers.QSkeletonViewController")
local QFileCache = import("...utils.QFileCache")

local QTutorialPhaseEnrollingBloodElf = import(".QTutorialPhaseEnrollingBloodElf")
local QTutorialPhaseEnrollingThrall = import(".QTutorialPhaseEnrollingThrall")
local QTutorialPhaseEnrollingKaelthas = import(".QTutorialPhaseEnrollingKaelthas")
local QTutorialPhaseEnrollingMorris = import(".QTutorialPhaseEnrollingMorris")
local QTutorialPhaseLakezuo = import(".QTutorialPhaseLakezuo")
local QTutorialPhaseKresh = import(".QTutorialPhaseKresh")
local QTutorialPhaseActivityDungeon = import(".QTutorialPhaseActivityDungeon")
local QTutorialPhaseMutanus = import(".QTutorialPhaseMutanus")
local QTutorialNewEnemy = import(".QTutorialNewEnemy")
local QTutorialPhaseDungeon14 = import(".QTutorialPhaseDungeon14")
local QTutorialPhaseDungeon18 = import(".QTutorialPhaseDungeon18")

function QTutorialStageEnrolling:ctor()
	QTutorialStageEnrolling.super.ctor(self)

	local db = QStaticDatabase:sharedDatabase()
	QTutorialStageEnrolling.NAME_TAUREN = db:getCharacterByID(1004) and db:getCharacterByID(1004).name or ""
	QTutorialStageEnrolling.NAME_TITLE_TAUREN = db:getCharacterByID(1004) and db:getCharacterByID(1004).title or ""

	QTutorialStageEnrolling.NAME_BLADEMASTER = db:getCharacterByID(1001) and db:getCharacterByID(1001).name or ""
	QTutorialStageEnrolling.NAME_TITLE_BLADEMASTER = db:getCharacterByID(1001) and db:getCharacterByID(1001).title or ""

	QTutorialStageEnrolling.NAME_BLOODELF = db:getCharacterByID(1003) and db:getCharacterByID(1003).name or ""
	QTutorialStageEnrolling.NAME_TITLE_BLOODELF = db:getCharacterByID(1003) and db:getCharacterByID(1003).title or ""

	QTutorialStageEnrolling.NAME_KAELTHAS = db:getCharacterByID(1002) and db:getCharacterByID(1002).name or ""
	QTutorialStageEnrolling.NAME_TITLE_KAELTHAS = db:getCharacterByID(1002) and db:getCharacterByID(1002).title or ""

    self._enableTouch = false
end

function QTutorialStageEnrolling:_createTouchNode()
	local touchNode = CCNode:create()
    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    touchNode:setTouchSwallowEnabled(true)
    app.scene:addChild(touchNode)
    self._touchNode = touchNode
end

function QTutorialStageEnrolling:enableTouch(func)
	self._enableTouch = true
	self._touchCallBack = func
	-- self._touchNode:setTouchEnabled(true)
end

function QTutorialStageEnrolling:disableTouch()
	self._enableTouch = false
	self._touchCallBack = nil
	-- self._touchNode:setTouchEnabled(false)
end

function QTutorialStageEnrolling:_createPhases()
	if self._battle._dungeonConfig.monster_id == nil then
	elseif self._battle._dungeonConfig.monster_id == "wailing_caverns_1" then
		table.insert(self._phases, QTutorialPhaseMutanus.new(self))
	elseif self._battle._dungeonConfig.monster_id == "wailing_caverns_3" then
    	table.insert(self._phases, QTutorialPhaseEnrollingKaelthas.new(self))
	elseif self._battle._dungeonConfig.monster_id == "wailing_caverns_4" then
    	table.insert(self._phases, QTutorialPhaseKresh.new(self))
    	table.insert(self._phases, QTutorialPhaseDungeon14.new(self)) 
    elseif self._battle._dungeonConfig.monster_id == "wailing_caverns_8" then
    	table.insert(self._phases, QTutorialPhaseDungeon18.new(self))
    elseif self._battle._dungeonConfig.monster_id == "wailing_caverns_9" then
    	table.insert(self._phases, QTutorialPhaseEnrollingBloodElf.new(self))
    --xurui: 暂时屏蔽
    -- elseif self._battle._dungeonConfig.monster_id == "wailing_caverns_12" then
    -- 	table.insert(self._phases, QTutorialPhaseEnrollingThrall.new(self))
    elseif self._battle._dungeonConfig.monster_id == "wailing_caverns_22" then
    	table.insert(self._phases, QTutorialPhaseEnrollingMorris.new(self))
    elseif self._battle._dungeonConfig.monster_id == "deadmine_8" then
    	table.insert(self._phases, QTutorialPhaseLakezuo.new(self))
    elseif type(string.find(self._battle._dungeonConfig.monster_id, "dwarf")) == "number" or type(string.find(self._battle._dungeonConfig.monster_id, "booty")) == "number" then
    	table.insert(self._phases, QTutorialPhaseActivityDungeon.new(self))
    end
    table.insert(self._phases, QTutorialNewEnemy.new(self))
	self._phaseCount = table.nums(self._phases)

	self._phaseCount = table.nums(self._phases)
end

function QTutorialStageEnrolling:start(battle)
	self._battle = battle
	self:_createTouchNode()
	self._touchNode:setTouchEnabled(false)
	self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QTutorialStageEnrolling._onTouch))
	QTutorialStageEnrolling.super.start(self)
end

function QTutorialStageEnrolling:ended()

end

function QTutorialStageEnrolling:_onTouch(event)
	if self._enableTouch == true and self._touchCallBack ~= nil then
		return self._touchCallBack(event)
    elseif event.name == "began" then
        return true
    end
end

function QTutorialStageEnrolling:enableCircleOfHealingTutorial()
	self._disableCircleOfHealingTutorial = false
end

function  QTutorialStageEnrolling:disableCircleOfHealingTutorial()
	self._disableCircleOfHealingTutorial = true
end

function QTutorialStageEnrolling:visit()
	QTutorialStageEnrolling.super.visit(self)

	if app.battle._dungeonConfig.monster_id == nil then
		return
	end

	if self._circle_of_healing == false or self._disableCircleOfHealingTutorial then
		return
	end

	if self._circle_of_healing == nil then
		if not app.battle or not app.battle._dungeonConfig then
			return
		end

		local dungeonid = app.battle._dungeonConfig.monster_id
		local dungeonprefixindex = string.find(dungeonid, "wailing_caverns_")
		if dungeonprefixindex ~= 1 then
			self._circle_of_healing = false
			return
		end

		local dungeonindex = tonumber(string.sub(dungeonid, 17))
		if type(dungeonindex) ~= "number" then
			self._circle_of_healing = false
			return
		end

		local heroes = app.battle:getHeroes()
		local found = false
		for _, hero in ipairs(heroes) do
			if hero:getActorID() == 1003 then
				found = true
				break
			end
		end
		if not found then
			self._circle_of_healing = false
			return
		end

		self._circle_of_healing = true
	end

	local heroes = app.battle:getHeroes()
	local bloodelf = nil
	local circleofhealing = nil
	local hp_under_30 = false
	local cd_ok = false
	local skills
	for _, hero in ipairs(heroes) do
		if hero:getActorID() == 1003 then
			bloodelf = hero
			skills = bloodelf:getManualSkills()
			circleofhealing = skills[next(skills)]
			cd_ok = circleofhealing:isReadyAndConditionMet()
		end
		hp_under_30 = (hero:getHp() / hero:getMaxHp(false)) < 0.3 or hp_under_30
	end

	if hp_under_30 and cd_ok and not app.battle._paused and not app.battle._pauseBetweenWaves and not bloodelf:isForceAuto() and not self._no_circleofhealing
		and bloodelf:canAttack(circleofhealing) and bloodelf:canAttackWithBuff(circleofhealing) and remote.instance:checkIsPassByDungeonId("wailing_caverns_13") == false then
		app.battle:removeAllBattleTutorialHandtouches()
		app.scene:pauseBattleAndUseSkill(bloodelf, circleofhealing)
		self._circle_of_healing = false
	end
end

return QTutorialStageEnrolling