local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhaseActivityDungeon = class("QTutorialPhaseActivityDungeon", QTutorialPhase)

local QUIWidgetBattleTutorialDialogue = import("...ui.widgets.QUIWidgetBattleTutorialDialogue")
local QTimer = import("...utils.QTimer")
local QActor = import("...models.QActor")
local QBaseActorView = import("...views.QBaseActorView")
local QBaseEffectView = import("...views.QBaseEffectView")
local QStaticDatabase = import("...controls.QStaticDatabase")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QNotificationCenter = import("...controllers.QNotificationCenter")

function QTutorialPhaseActivityDungeon:start()
	local dungeon = app.battle._dungeonConfig
	local is_dwarf = type(string.find(dungeon.monster_id, "dwarf")) == "number"
	local is_booty = type(string.find(dungeon.monster_id, "booty")) == "number"
	local record_key = nil
	if is_dwarf then
		record_key = "activity_dungeon_tutorial_dwarf_count"
	elseif is_booty then
		record_key = "activity_dungeon_tutorial_booty_count"
	end

	if record_key then
		local record = app:getUserData():getUserValueForKey(record_key)
		if record == nil or tonumber(record) < 2 then
			-- O.K.
			self._record_key = record_key
			self._is_dwarf = is_dwarf
			self._is_booty = is_booty
		else
			-- self:finished()
		end
		self._targets = {}
	else
		self:finished()
	end
end

function QTutorialPhaseActivityDungeon:visit()
	if self._record_key then
		if self._target == nil then
			for _, item in ipairs(app.battle._monsters) do
				if item.npc and type(item.dead_skill) == "number" then
					self._target = item.npc
					break
				end
			end
		elseif self._qualified == nil then
			local target = self._target
	        local area = app.grid:getRangeArea()
	        local pos = target:getPosition()
	        if pos.x >= area.left + 75 and pos.x <= area.right and pos.y >= area.bottom and pos.y <= area.top then
	            self._qualified = true
	        end
		else
			app.scene:pauseBattleAndAttackEnemy(self._target, self._is_booty and 1 or 2)
			-- self:finished()

			local record_key = self._record_key
			local record = app:getUserData():getUserValueForKey(record_key)
			record = record and tonumber(record) or 0
			app:getUserData():setUserValueForKey(record_key, tostring(record + 1))
			self._record_key = nil
		end
	end

	for _, item in ipairs(app.battle._monsters) do
		if item.npc and type(item.dead_skill) == "number" then
			if self._targets[item.npc] == nil then
				self._targets[item.npc] = {actor = item.npc, glow_colored = false}
			end
		end
	end
	for _, obj in pairs(self._targets) do
		local actor, glow_colored = obj.actor, obj.glow_colored
		if actor:isDead() and glow_colored then
            local monster_view = app.scene:getActorViewFromModel(actor)
            monster_view:setGlowColor(nil)
            obj.glow_colored = false
		elseif not actor:isDead() and glow_colored == false then
            local monster_view = app.scene:getActorViewFromModel(actor)
            monster_view:setGlowColor(ccc4(255 * 0.625, 200 * 0.625, 0, 192))
            obj.glow_colored = true
		end
	end
end

function QTutorialPhaseActivityDungeon:_onBattleEnd()
	self:finished()
end

return QTutorialPhaseActivityDungeon