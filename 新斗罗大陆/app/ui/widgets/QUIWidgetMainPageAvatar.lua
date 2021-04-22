--
-- Author: wkwang
-- Date: 2015-03-20 17:07:03
-- 主界面人物走动的模块
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMainPageAvatar = class("QUIWidgetMainPageAvatar", QUIWidget)
local QUIWidgetActorActivityDisplay = import("..widgets.actorDisplay.QUIWidgetActorActivityDisplay")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QTutorialDirector = import("...tutorial.QTutorialDirector")
local QUIWidgetQuestionAvatar = import("..widgets.question.QUIWidgetQuestionAvatar")

QUIWidgetMainPageAvatar.UNION = "union"
QUIWidgetMainPageAvatar.MAIN = "main"

function QUIWidgetMainPageAvatar:ctor(options)
	QUIWidgetMainPageAvatar.super.ctor(self,ccbFile,callBacks,options)

	self._speakTime = 0
	if not options then
		options = {}
	end
	self._heroRange = options.heroRange
	self._actorsCount = options.actorsCount or 4
	self._type = options.type 
end

function QUIWidgetMainPageAvatar:init()
	if self._actorScheduleHandle == nil then
		self._actorScheduleHandle = scheduler.scheduleGlobal(handler(self, self._updateActors), 0.5)
	end
	self:question()
end

function QUIWidgetMainPageAvatar:onEnter()
	self:init()
end

function QUIWidgetMainPageAvatar:onExit()
    if self._actorScheduleHandle then
    	scheduler.unscheduleGlobal(self._actorScheduleHandle)
    	self._actorScheduleHandle = nil
    end
	if self._heroes then
		for _, hero in pairs(self._heroes) do
			hero:removeAllEventListeners()
			hero:stopDisplay()
			hero:stopWalking()
			hero:removeFromParentAndCleanup(true)
		end
		self._heroes = nil
		self._heroRange = nil
	end
	if self._questionWidget ~= nil then
		self._questionWidget:removeFromParentAndCleanup(true)
		self._questionWidget = nil
	end
end

--问答
function QUIWidgetMainPageAvatar:question()
	if self._questionWidget == nil then
		self._questionWidget = QUIWidgetQuestionAvatar.new()
		self._questionWidget:setPositionY(display.height/2)
		self:addChild(self._questionWidget)
	end
end

function QUIWidgetMainPageAvatar:_updateActors()
	do return end

	if app.battle then
		return
	end

	if self._heroes == nil then
		self._heroes = {}
		if not self._heroRange then
			local cx = display.cx * 0.85
			self._heroRange = {
				{x1 = -3 * cx + cx * 1.5, x2 = -3 * cx + cx * 3}, 
				{x1 = -3 * cx + cx * 3, x2 = -3 * cx + cx * 4.5}, 
				{x1 = -3 * cx, x2 = -3 * cx + cx * 1.5}, 
				{x1 = -3 * cx + cx * 4.5, x2 = -3 * cx + cx * 5.5},
			}
		end
	end

	local heroRange = self._heroRange
	-- check new actors
	local newHeroes = remote.herosUtil:getHeroesSortByLevel(self._actorsCount)
	local oldHeroes = self._heroes
	for actorId, actorDisplay in pairs(oldHeroes) do
		if newHeroes[actorId] and actorDisplay:getActor():isEnchantEffectOutdated() == false then
			newHeroes[actorId] = actorDisplay
		else
			oldHeroes[actorId] = nil
			actorDisplay:removeAllEventListeners()
			actorDisplay:stopWalking()
			actorDisplay:stopDisplay()
			actorDisplay:removeFromParentAndCleanup(true)
			for i = 1, self._actorsCount do
				if heroRange[i] == nil then
					heroRange[i] = actorDisplay:getWalkRange()
					break
				end
			end
		end
	end
	for actorId, v in pairs(newHeroes) do
		if type(v) == "number" then
			local range = nil
			for i = 1, self._actorsCount do
				if heroRange[i] then
					range = heroRange[i]
					heroRange[i] = nil
					break
				end
			end
			local actorDisplay = QUIWidgetActorActivityDisplay.new(actorId, {isSelf = true})
			local extra_scale = display.height / display.width * UI_DESIGN_WIDTH / UI_DESIGN_HEIGHT
			actorDisplay:setScale(0.73 * extra_scale)
			actorDisplay:setPositionY(0 - 160 * (extra_scale - 1) * 0.73)
			actorDisplay:setPositionX(math.random(range.x1, range.x2))
			actorDisplay:setWalkRange(range)
			actorDisplay:addEventListener(actorDisplay.EVENT_CLICK, handler(self, self._actorClickHandler))
			self:addChild(actorDisplay)
			newHeroes[actorId] = actorDisplay
		end
	end
	self._heroes = newHeroes

	local selectHero = self:speakHandler() --最中间的人可以说话了

	for _, actorDisplay in pairs(self._heroes) do
		if actorDisplay ~= selectHero then --排除中间说话的人
			if actorDisplay.nextOrderTime == nil then
				actorDisplay.nextOrderTime = q.time()
			end
			if actorDisplay.nextOrderTime <= q.time() then
				if not actorDisplay:isWalking() and not actorDisplay:isActorPlaying() then
					local roll = math.random(1, 100)
					if roll < 50 or true then
						-- walk
						local distance
						local x, y = actorDisplay:getPosition()
						if self._type and self._type == QUIWidgetMainPageAvatar.UNION then
							distance = math.random(100, 170)
						else
							distance = math.random(200, 300)
						end
						
						if x - distance < actorDisplay:getWalkRange().x1 then
							x = x + distance
						elseif x + distance > actorDisplay:getWalkRange().x2 then
							x = x - distance
						else
							x = math.random(0, 100) < 50 and (x + distance) or (x - distance)

						end
						actorDisplay:walkto({x = x, y = y})
					elseif roll < 75 then
						-- victory
						actorDisplay:displayWithBehavior(ANIMATION_EFFECT.VICTORY)
					else
						-- standby
						actorDisplay:stopWalking()
						actorDisplay:stopDisplay()
					end
					actorDisplay.nextOrderTime = q.time() + math.random(350, 450) / 100
				end
			end
		end
	end
end

function QUIWidgetMainPageAvatar:_actorClickHandler(event)
	if remote.instance:checkIsPassByDungeonId("wailing_caverns_12") == false then return nil end
	if q.serverTime() - self._speakTime > 3 then
		self._speakTime = q.serverTime()
		if event.actor ~= nil then
			event.actor:playVictory()
		end
	end
end

function QUIWidgetMainPageAvatar:speakHandler()
	if remote.instance:checkIsPassByDungeonId("wailing_caverns_12") == false then return nil end
	if self._speakTime == 0 then 
		self._speakTime = q.serverTime() - 6
		return nil
	end
	if q.serverTime() - self._speakTime > 16 then
		local selectHero = nil
		local distance = nil
		for _,hero in pairs(self._heroes) do
			local posX = hero:convertToWorldSpaceAR(ccp(0,0)).x
			if selectHero == nil then
				selectHero = hero
				distance = math.abs(display.cx - posX)
			elseif distance > math.abs(display.cx - posX) then
				selectHero = hero
				distance = math.abs(display.cx - posX)
			end
		end
		if selectHero ~= nil then
			self._speakTime = q.serverTime()
			selectHero:playVictory()
			return selectHero
		end
	end
	return nil
end

return QUIWidgetMainPageAvatar