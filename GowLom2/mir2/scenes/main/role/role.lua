local magic = import("..common.magic")
local mapDef = import("..map.def")
local ani = import(".ani")
local info = import(".info")
local role = class("role")
local __position = cc.Node.setPosition

table.merge(role, {
	isUnderOtherRole,
	playingOtherEffect = false,
	actFastNum = 2
})

role.ctor = function (self, params)
	params = params or {}
	self.node = display.newNode()
	self.node.onEnter = function (node)
		self:onEnter()

		return 
	end
	self.map = params.map
	self.isPlayer = params.isPlayer
	self.roleid = params.roleid
	self.y = params.y or 0
	self.x = params.x or 0
	self.dir = params.dir or def.role.dir.bottom
	self.feature = params.feature
	self.state = params.state or {}
	self.level = params.level or 1
	self.hitSpeed = avoidPlugValue(0)
	self.shield = nil
	self.sounds = {}
	self.filters = {}
	self.acts = {}
	self.parts = {}
	self.sprites = {}
	self.cur = {}
	self.last = {
		x = self.x,
		y = self.y,
		dir = self.dir,
		state = self.state,
		pos = cc.p(-1, -1)
	}
	self.lock = {
		execute = false
	}
	self.waits = {}
	self.actions = nil

	self.node.setCascadeOpacityEnabled(slot2, true)

	local size = def.role.size

	self.node:size(size.w, size.h)

	self.info = info.new(self, self.map)

	self.node:setNodeEventEnabled(true)

	self.isIgnore = false
	self.lastSpeEffect = {}

	self.firstEnter(self)

	return 
end
role.firstEnter = function (self)
	if self.isPlayer and #self.acts <= 0 then
		self.addAct(self, {
			loadMap = true,
			type = "stand",
			dir = self.dir,
			x = self.x,
			y = self.y
		})
	end

	return 
end
role.initEnd = function (self)
	return 
end
role.onEnter = function (self)
	self.changeFeature(self, self.feature, true)

	if #self.acts <= 0 then
		self.addAct(self, {
			loadMap = true,
			type = "stand",
			dir = self.dir,
			x = self.x,
			y = self.y
		})
	end

	self.uptInfoShow(self)
	self.uptSelfShow(self)

	return 
end
role.uptIsIgnore = function (self)
	local isIgnore = not self.isInScreen or (self.isUnderOtherRole and not self.die and not self.isMoving and not self.isPlayer)

	if isIgnore ~= self.isIgnore then
		self.isIgnore = isIgnore

		self.uptInfoShow(self)
		self.uptSelfShow(self)
	end

	return 
end
role.setIsUnderOtherRole = function (self, b)
	if self.isUnderOtherRole ~= b then
		self.isUnderOtherRole = b
	end

	return 
end
role.uptInfoShow = function (self)
	if self.noInfo or self.isIgnore or self.die or g_data.login:isChangeSkinCheckServer() then
		self.info:hide()
	else
		self.info:show()
	end

	return 
end
role.uptSelfShow = function (self)
	local show = not self.isIgnore

	if show and self.die then
		show = not g_data.setting.base.hideCorpse
	end

	for k, v in pairs(self.sprites) do
		v.setVisible(v, show)

		if self.die and show then
			v.play(v, {
				corpse = true,
				type = "die",
				dir = self.dir
			})
		end
	end

	return 
end
role.clearLock = function (self)
	if not main_scene then
		return 
	end

	local lock = main_scene.ui.console.controller.lock

	if lock.target.skill == self.roleid then
		lock.target.skill = nil
	end

	if lock.target.select == self.roleid then
		lock.target.select = nil
	end

	if type(tonumber(lock.target.attack)) == "number" then
		if lock.target.attack == self.roleid then
			lock.target.attack = nil
		end
	elseif lock.target.attack == self then
		lock.target.attack = nil
	end

	return 
end
role.getDis = function (self, other)
	local x = math.abs(self.x - other.x)
	local y = math.abs(self.y - other.y)

	return math.sqrt(x*x + y*y)
end
role.getRace = function (self)
	return self.feature.race
end
role.getAppr = function (self)
	return self.feature.dress
end
role.getWeapon = function (self)
	return self.feature.weapon
end
role.openFilter = function (self, name)
	if not self.filters[name] then
		self.filters[name] = true
	end

	self.checkFilter(self)

	return 
end
role.closeFilter = function (self, name)
	if self.filters[name] then
		self.filters[name] = nil
	end

	self.checkFilter(self)

	return 
end
role.checkFilter = function (self)
	if table.nums(self.filters) == 0 then
		for k, v in pairs(self.sprites) do
			v.spr:clearFilter()
		end

		return 
	end

	local f = nil

	if self.filters.die or self.filters.gray then
		f = res.getFilter("gray")
	elseif self.filters.outline then
		f = res.getFilter("outline_role")
	end

	if f then
		for k, v in pairs(self.sprites) do
			v.spr:setFilter(f)
		end
	end

	return 
end
role.getParts = function (self, feature)
	return {}, 0
end
role.changeFeature = function (self, newFeature, force)
	local oldSpeEffect = self.lastSpeEffect or {}
	local newSpeEffect = newFeature.speEffect or {}

	for oldKey, oldEffectId in ipairs(oldSpeEffect) do
		local bStillEffect = false

		for newKey, newEffectId in ipairs(newSpeEffect) do
			if newEffectId == oldEffectId then
				bStillEffect = true
			end
		end

		if not bStillEffect then
			force = true

			self.stopSpecialEffect(self, oldEffectId)
		end
	end

	for newKey, newEffectId in ipairs(newSpeEffect) do
		local bHasEffect = false

		for oldKey, oldEffectId in ipairs(oldSpeEffect) do
			if newEffectId == oldEffectId then
				bHasEffect = true
			end
		end

		if not bHasEffect then
			force = true

			self.playSpecialEffect(self, newEffectId)
		end
	end

	self.lastSpeEffect = newFeature.speEffect
	local diff = false

	for k, v in pairs(self.feature) do
		if type(v) == "number" and v ~= newFeature[k] then
			diff = true

			break
		end
	end

	if not diff and not force then
		return 
	end

	local parts, sex = self.getParts(self, newFeature)

	for k, v in pairs(parts) do
		if not self.parts[k] or v.delete or self.parts[k].imgid ~= v.imgid or self.parts[k].id ~= v.id then
			v.type = k

			self.addAct(self, v)
		end
	end

	self.parts = parts
	self.sex = sex
	self.feature = newFeature

	return 
end
role.updateSpriteForState = function (self, type, sprite)
	local function update(t, spr)
		local state = self.last.state or {}
		local showWudi, hasColor = nil

		if def.role.stateHas(state, "stNoDie") then
			self:closeFilter("gray")
			self:playWudiEffect()

			showWudi = true
		elseif def.role.isRoleStone(state) then
			self:openFilter("gray")
		elseif def.role.stateHas(state, "stPoisonBlue") then
			self:closeFilter("gray")

			if t == "dress" or t == "hair" then
				spr.setColor(spr, cc.c3b(0, 255, 255))

				hasColor = true
			end
		else
			self:closeFilter("gray")

			if def.role.stateHas(state, "stPoisonFuchsia") then
				spr.setColor(spr, cc.c3b(255, 60, 255))

				hasColor = true
			end

			if def.role.stateHas(state, "stPoisonGreen") and (t == "dress" or t == "hair") then
				spr.setColor(spr, display.COLOR_GREEN)

				hasColor = true
			end

			if def.role.stateHas(state, "stPoisonRed") and (t == "dress" or t == "hair") then
				spr.setColor(spr, display.COLOR_RED)

				hasColor = true
			end
		end

		if not showWudi then
			self:playWudiEffect(1)
		end

		if not hasColor then
			spr.setColor(spr, display.COLOR_WHITE)
		end

		if def.role.stateHas(state, "stHidden") then
			spr.opacity(spr, 128)
		else
			spr.opacity(spr, 255)
		end

		if def.role.stateHas(state, "stMagicShield") then
			if not self.shield then
				self.shield = m2spr.playAnimation("magic", 3890, 2, 0.15, true):add2(self.node, 2)

				__position(self.shield, 0, mapDef.tile.h)
			end

			self.shield:show()
		elseif self.shield then
			self.shield:hide()
		end

		return 
	end

	if type and sprite then
		return slot3(type, sprite.spr)
	end

	for k, v in pairs(self.sprites) do
		update(k, v.spr)
	end

	return 
end
role.selected = function (self)
	if not self.selectedSpr and not WIN32_OPERATE then
		local x, y = self.node:centerPos()
		self.selectedSpr = res.get2("pic/common/selectRole.png"):add2(self.node, -1):pos(x, 15)
	end

	return 
end
role.unselected = function (self)
	if not tolua.isnull(self.selectedSpr) then
		self.selectedSpr:removeFromParent()

		self.selectedSpr = nil
	end

	return 
end
role.highLight = function (self)
	for _, sprite in pairs(self.sprites) do
		sprite.setFilter(sprite, res.getFilter("high_light"))
	end

	return 
end
role.unHighLight = function (self)
	for _, sprite in pairs(self.sprites) do
		sprite.clearFilter(sprite)
	end

	return 
end
role.getSize = function (self)
	if self.parts.dress and self.parts.dress.ani then
		return self.parts.dress.ani:getContentSizeInPixels()
	end

	return self.node:getContentSize()
end
role.isHeroForPlayer = function (self)
	return g_data.hero == self.roleid
end
role.isLocked = function (self)
	if self.lock.execute and self.cur.act and self.cur.act.type == "struck" then
		return false
	end

	return self.lock.execute
end
role.forceUnlock = function (self)
	self.lock.execute = false
	local acts = self.acts
	self.acts = {}

	self.executeEnd(self)

	for k, v in ipairs(acts) do
		if v.type == "state" then
			self.acts[#self.acts + 1] = v
		end
	end

	if self.isPlayer and 1 <= #self.acts then
		self.executeAct(self)
	end

	p2("error", "role:forceUnlock!!!!!")

	return 
end
g_data.speedUpOther = true
local rushTimeSpace = 2.73
role.executeAct = function (self)
	self.lock.execute = true
	self.curActEnd = false
	self.cur.act = self.acts[1]
	local act = self.cur.act
	local checkExist = checkExist
	self.last.x = act.x or self.last.x
	self.last.y = act.y or self.last.y
	self.last.dir = act.dir or self.last.dir
	self.last.state = act.state or self.last.state

	if checkExist(act.type, "weapon", "hair") and g_data.login:isChangeSkinCheckServer() then
		return self.executeEnd(self)
	end

	if act.type == "state" then
		self.updateSpriteForState(self)

		return self.executeEnd(self)
	end

	if checkExist(act.type, "dress", "weapon", "hair", "humEffect") then
		if self.sprites[act.type] then
			self.sprites[act.type]:removeSelf()

			self.sprites[act.type] = nil
		end

		if not act.delete then
			local z = (checkExist(act.type, "hair", "humEffect") and 1) or 0
			local spr = ani.new(act, self):addto(self.node, z):pos(0, mapDef.tile.h)
			self.sprites[act.type] = spr

			self.updateSpriteForState(self, act.type, self.sprites[act.type])

			if self.isIgnore then
				self.sprites[act.type]:hide()
			end
		end

		self.executeSound(self)

		return self.executeEnd(self)
	end

	local delay = nil
	local speed = def.role.speed
	local speedUpOther = g_data.speedUpOther

	if speedUpOther and self.__cname == "hero" and not self.isPlayer then
		speed = def.role.speedOtherPlayer
	end

	if self.isExecuteFast(self) then
		delay = speed.fast

		if 0 < DEBUG then
			print("人物动作加速播放，动作队列长度：" .. #self.acts)
			print_r(self.acts)
		end
	elseif checkExist(act.type, "rushLeft", "rushRight") then
		delay = speed.rush
	elseif act.type == "rushKung" then
		delay = speed.rushKung
	elseif checkExist(act.type, "run", "walk", "hit", "spell", "heavyHit", "bigHit") then
		delay = speed.normal
	end

	for k, v in pairs(self.sprites) do
		delay = v.play(v, act, delay)
	end

	delay = delay or speed.normal

	if self.sprites.weapon then
		self.sprites.weapon.spr:setLocalZOrder(((def.role.dir.rightBottom < act.dir or act.dir == def.role.dir.up) and -1) or 1)
	end

	if not self.isIgnore then
		if act.hitEffect then
			magic.showHitEffect(act.hitEffect.magicId, {
				x = act.x,
				y = act.y,
				dir = act.dir,
				delay = delay,
				type = act.hitEffect.type,
				effectID = act.hitEffect.effectID,
				effectType = act.hitEffect.effectType,
				role = self
			})
		end

		if act.effect then
			local dir = nil

			if act.hasDir and act.dir then
				dir = act.dir
			end

			magic.showSpellEffect(act.effect.effectID, {
				x = act.x,
				y = act.y,
				dir = dir,
				delay = delay,
				job = self.job
			})
		end

		local canShowRushEffect = true

		if self.lastRushTime and socket.gettime() - self.lastRushTime < rushTimeSpace then
			canShowRushEffect = false
		end

		if act.rushEffect and canShowRushEffect then
			self.lastRushTime = socket.gettime()

			magic.showRushEffect(act.rushEffect.effectID, {
				x = act.x or act.rushx,
				y = act.y or act.rushy,
				dir = act.dir,
				delay = delay,
				job = self.job
			})
		end
	end

	if act.flyaxe then
		local params = {
			role = self
		}

		table.merge(params, act.flyaxe)
		self.map:showEffectForName("flyaxe", params)
	end

	if act.otherEffect then
		if self.playingOtherEffect == true then
			return 
		end

		local begin = nil

		if act.otherEffect.isFixed then
			begin = act.otherEffect.begin
		else
			begin = act.otherEffect.begin + act.dir*(act.otherEffect.frame + act.otherEffect.skip)
		end

		local spr = m2spr.new(nil, nil, {
			blend = true,
			setOffset = true
		}):addto(self.node):pos(0, mapDef.tile.h)
		local noForever = true

		if act.otherEffect.noForever ~= nil then
			noForever = act.otherEffect.noForever

			if noForever == false then
				self.playingOtherEffect = true
			end
		end

		if act.otherEffect.ftime ~= nil then
			delay = act.otherEffect.ftime/1000*act.otherEffect.frame*delay/speed.normal*2
		end

		if act.otherEffect.delayFrame and act.otherEffect.delayMax then
			spr.runs(spr, {
				cc.DelayTime:create(delay/act.otherEffect.delayMax*act.otherEffect.delayFrame),
				cc.Show:create(),
				cc.CallFunc:create(function ()
					spr:playAni(act.otherEffect.img, begin, act.otherEffect.frame, delay/act.otherEffect.frame, true, true, noForever)

					return 
				end)
			})
		else
			spr.playAni(slot7, act.otherEffect.img, begin, act.otherEffect.frame, delay/act.otherEffect.frame, true, true, noForever)
		end
	end

	local acttype = act.type

	if acttype == "stand" then
		__position(self.node, self.map:getMapPos(act.x, act.y))
		self.executeEnd(self)
	elseif acttype == "walk" or acttype == "run" or acttype == "rushLeft" or acttype == "rushRight" then
		local disx = math.abs(self.last.x - act.x)
		local disy = math.abs(self.last.y - act.y)

		if disx <= 2 and disy <= 2 and (disx == disy or disx == 0 or disy == 0) then
			local x, y = self.getPosition(self)
			local destx, desty = self.map:getMapPos(act.x, act.y)

			self.addAction(self, {
				{
					"moveto",
					delay,
					x,
					y,
					destx,
					desty
				},
				{
					"function",
					handler(self, self.executeEnd)
				}
			})
			self.map:uptRoleXY(self, true)
		else
			act.type = "stand"

			self.node:pos(self.map:getMapPos(act.x, act.y))
			self.executeEnd(self)
		end
	elseif acttype == "hit" or acttype == "attack" or acttype == "heavyHit" or acttype == "bigHit" then
		self.node:pos(self.map:getMapPos(act.x, act.y))
		self.addAction(self, {
			{
				"delay",
				delay
			},
			{
				"function",
				handler(self, self.executeEnd)
			}
		})
	elseif acttype == "rushKung" then
		local x, y = self.getPosition(self)
		local destx, desty = self.map:getMapPos(act.x, act.y)

		self.addAction(self, {
			{
				"moveto",
				delay/2,
				x,
				y,
				destx,
				desty
			},
			{
				"moveto",
				delay/2,
				destx,
				desty,
				x,
				y
			},
			{
				"function",
				handler(self, self.executeEnd)
			}
		})
		self.map:uptRoleXY(self, true)
	elseif acttype == "digdown" and self.__cname == "mon" then
		self.addAction(self, {
			{
				"delay",
				delay
			},
			{
				"function",
				function ()
					self.readyRemove = true

					return 
				end
			}
		})
	elseif acttype == "spell" and self.isPlayer then
		if act.x and act.y then
			self.node.pos(slot7, self.map:getMapPos(act.x, act.y))
		end

		self.addAction(self, {
			{
				"delay",
				delay
			},
			{
				"function",
				handler(self, self.executeEnd)
			}
		})
	elseif act == "struck" then
		self.addAction(self, {
			{
				"delay",
				delay
			},
			{
				"function",
				function ()
					if act == self.cur.act and self.cur.act.type == "struck" then
						self:executeEnd()
					end

					return 
				end
			}
		})
	else
		if act.x and act.y then
			__position(self.node, self.map.getMapPos(slot9, act.x, act.y))
		end

		self.addAction(self, {
			{
				"delay",
				delay
			},
			{
				"function",
				handler(self, self.executeEnd)
			}
		})
	end

	self.executeSound(self, delay)

	return 
end
role.addAction = function (self, params)
	self.actions = params
	self.actionsCache = {}

	return 
end
role.executeActions = function (self, dt)
	local v = self.actions[1]

	if v[1] == "moveto" then
		if 0 < DEBUG and g_data.openRealTimeAction and self.lastPostTime == nil then
			self.lastPostTime = socket.gettime()
		end

		local delay = v[2]
		local x = v[3]
		local y = v[4]
		local destx = v[5]
		local desty = v[6]
		self.actionsCache.dt = (self.actionsCache.dt or 0) + dt

		if 0 < DEBUG and g_data.openRealTimeAction then
			self.actionsCache.dt = socket.gettime() - self.lastPostTime
		end

		self.isMoving = true
		local cur = self.actionsCache.dt

		if delay <= cur then
			if 0 < DEBUG and g_data.openRealTimeAction and self.lastPostTime then
				self.lastPostTime = nil
			end

			self.isMoving = false

			self.node:pos(destx, desty)

			self.actionsCache = {}

			table.remove(self.actions, 1)

			if 0 < #self.actions then
				self.executeActions(self, cur - delay)
			end
		else
			self.actionsCache.speed = self.actionsCache.speed or {
				(destx - x)/delay,
				(desty - y)/delay
			}

			__position(self.node, x + self.actionsCache.dt*self.actionsCache.speed[1], y + self.actionsCache.dt*self.actionsCache.speed[2])
		end
	elseif v[1] == "delay" then
		if 0 < DEBUG and g_data.openRealTimeAction and self.lastPostTime == nil then
			self.lastPostTime = socket.gettime()
		end

		local delay = v[2]
		self.actionsCache.dt = (self.actionsCache.dt or 0) + dt

		if 0 < DEBUG and g_data.openRealTimeAction then
			self.actionsCache.dt = socket.gettime() - self.lastPostTime
		end

		local cur = self.actionsCache.dt

		if delay <= cur then
			if 0 < DEBUG and g_data.openRealTimeAction and self.lastPostTime then
				self.lastPostTime = nil
			end

			self.actionsCache = {}

			table.remove(self.actions, 1)

			if 0 < #self.actions then
				self.executeActions(self, cur - delay)
			end
		end
	elseif v[1] == "function" then
		table.remove(self.actions, 1)
		v[2]()
	end

	return 
end
role.isExecuteFast = function (self)
	local actNum = #self.acts

	return self.actFastNum <= actNum
end
role.executeSound = function (self, delay)
	local act = self.cur.act

	if not act then
		return 
	end

	if self.isPlayer and checkExist(act.type, "walk", "run", "rushLeft", "rushRight", "rushKung") then
		sound.play("footStep", {
			role = self,
			map = self.map,
			delay = delay
		})

		return 
	end

	if self.__cname ~= "npc" or false then
		if self.__cname == "mon" then
			sound.play("mon", {
				role = self,
				act = act,
				map = self.map
			})
		elseif self.__cname == "hero" and not self.isIgnore then
			if act.type == "hit" or act.type == "heavyHit" or act.type == "bigHit" then
				sound.play("hit", {
					role = self,
					effect = act.hitEffect,
					delay = delay
				})
			elseif act.type == "spell" and act.effect then
				sound.play("skillSpell", {
					role = self,
					magicId = act.effect.magicId
				})
			end
		end
	end

	return 
end
role.spellDone = function (self)
	if not main_scene then
		return 
	end

	local controller = main_scene.ui.console.controller
	local map = main_scene.ground.map

	if controller.stopAttack then
		controller.stopAttack = false
	end

	return 
end
role.executeEnd = function (self, act)
	self.curActEnd = true

	if 0 < #self.waits then
		return 
	end

	self.actions = nil
	self.lock.execute = false
	self.last.act = act or self.cur.act
	self.cur.act = nil

	table.remove(self.acts, 1)
	self.map:uptRoleXY(self, false, self.last.x, self.last.y)

	if self.isPlayer then
		if 0 < #self.acts then
			self.executeAct(self)
		end

		if self.last.act and (self.last.act.type == "spell" or self.last.act.type == "state" or self.last.act.type == "immediateMagicHit") then
			self.spellDone(self)
		end
	elseif #self.acts == 0 and not self.isExecuteEnd then
		self.allExecuteEnd(self)
	end

	return 
end
role.allExecuteEnd = function (self)
	self.isExecuteEnd = true

	if self.last.act.type ~= "stand" then
		self.addStandAct(self)
	end

	return 
end
role.executeFail = function (self, x, y, dir)
	local act = nil

	if 0 < #self.waits then
		act = self.waits[1]
		self.dir = dir or act.wait.dir or self.dir
		self.y = y or act.wait.y or self.y
		self.x = x or act.wait.x or self.x
		self.waits = {}
	end

	for k, v in pairs(self.parts) do
		if v.ani then
			v.ani:play("stand", self.dir)
		end
	end

	self.node:stopAllActions()

	self.lastPostTime = nil

	self.node:pos(self.map:getMapPos(self.x, self.y))
	self.executeEnd(self, act)

	return 
end
role.executeSuccess = function (self)
	table.remove(self.waits, 1)

	if self.curActEnd then
		self.executeEnd(self)
	end

	return 
end
role.addAct = function (self, params)
	if self.die and params.type ~= "die" and not params.gutou then
		return 
	elseif params.type == "die" and not self.node:isRunning() then
		self.onEnter(self)
	end

	if self.cur.act and self.cur.act.type == "struck" then
		self.executeEnd(self)
	elseif params.type == "struck" and 0 < #self.acts then
		return 
	end

	local function loadMapTest()
		if self.isPlayer and params.x and params.y then
			if params.type == "walk" or params.type == "run" or params.type == "rushLeft" or params.type == "rushRight" then
				self.map:load(self.x, self.y, params.x - self.x, params.y - self.y)
			elseif self.x ~= params.x or self.y ~= params.y or params.loadMap then
				self.map:load(params.x, params.y)
			end
		end

		return 
	end

	slot2()

	params.x = params.x or self.x
	params.y = params.y or self.y
	params.dir = params.dir or self.dir

	if params.wait then
		self.waits[#self.waits + 1] = params
	end

	self.acts[#self.acts + 1] = params
	self.dir = params.dir
	self.x = params.x
	self.y = params.y
	self.isExecuteEnd = false

	if params.type == "die" then
		self.die = true

		self.uptInfoShow(self)
		self.uptSelfShow(self)
		self.clearLock(self)

		if main_scene and main_scene.ui.panels.minimap then
			main_scene.ui.panels.minimap:removePoint(self.roleid)
		end

		if self.isHeroForPlayer(self) and main_scene and main_scene.ui.panels.heroHead and main_scene.ui.panels.heroHead.headshot then
			main_scene.ui.panels.heroHead.headshot:setFilter(res.getFilter("gray"))
		end
	end

	if self.isPlayer and #self.acts == 1 then
		self.executeAct(self)
	end

	return 
end
role.addStandAct = function (self)
	self.addAct(self, {
		type = "stand",
		dir = self.dir,
		x = self.x,
		y = self.y
	})

	return 
end
role.processMsg = function (self, ident, x, y, dir, feature, state, params)
	if SM_Turn == ident then
		self.addAct(self, {
			type = "stand",
			x = x,
			y = y,
			dir = dir,
			stone = state and def.role.stateHas(state, "stStone")
		})
	elseif SM_Appear == ident then
		self.addAct(self, {
			type = "stand",
			x = x,
			y = y,
			dir = dir,
			stone = state and def.role.stateHas(state, "stStone")
		})
	elseif SM_WALK == ident or SM_NPCWALK == ident then
		self.addAct(self, {
			type = "walk",
			x = x,
			y = y,
			dir = dir
		})
	elseif SM_RUN == ident then
		self.addAct(self, {
			type = "run",
			x = x,
			y = y,
			dir = dir
		})
	elseif SM_BACKSTEP == ident then
		self.addAct(self, {
			type = "walk",
			x = x,
			y = y,
			dir = dir
		})
	elseif SM_DEATH == ident then
		if params == nil then
			params = {
				flag = 0
			}
		end

		if params.flag == 0 then
			self.addAct(self, {
				type = "die",
				x = x,
				y = y,
				dir = dir
			})
		elseif params.flag == 1 then
			self.addAct(self, {
				type = "die",
				corpse = true,
				x = x,
				y = y,
				dir = dir
			})
		elseif params.flag == 2 then
			self.addAct(self, {
				gutou = true,
				type = "die",
				dir = 0,
				x = x,
				y = y
			})
		end
	elseif AttackType.ATT_HIT == ident then
		self.addAct(self, {
			type = (self.__cname == "hero" and "hit") or "attack",
			x = x,
			y = y,
			dir = dir
		})
	elseif AttackType.ATT_HEAVYHIT == ident then
		self.addAct(self, {
			type = "heavyHit",
			x = x,
			y = y,
			dir = dir
		})
	elseif AttackType.ATT_BIGHIT == ident then
		self.addAct(self, {
			type = "bigHit",
			x = x,
			y = y,
			dir = dir
		})
	elseif AttackType.ATT_POWERHIT == ident then
		self.addAct(self, {
			type = "hit",
			x = x,
			y = y,
			dir = dir,
			hitEffect = {
				magicId = 7,
				type = "pow"
			}
		})
	elseif AttackType.ATT_LONGHIT == ident then
		self.addAct(self, {
			type = "hit",
			x = x,
			y = y,
			dir = dir,
			hitEffect = {
				magicId = 12,
				type = "long"
			}
		})
	elseif AttackType.ATT_WIDEHIT == ident then
		self.addAct(self, {
			type = "hit",
			x = x,
			y = y,
			dir = dir,
			hitEffect = {
				magicId = 25,
				type = "wide"
			}
		})
	elseif AttackType.ATT_FIREHIT == ident then
		self.addAct(self, {
			type = "hit",
			x = x,
			y = y,
			dir = dir,
			hitEffect = {
				magicId = 26,
				type = "fire",
				effectID = params.effectId,
				effectType = params.effectType
			}
		})
	elseif SM_4FIREHIT == ident then
		self.addAct(self, {
			type = "hit",
			x = x,
			y = y,
			dir = dir,
			hitEffect = {
				magicId = 26,
				type = "fire4"
			}
		})
	elseif SM_HERO_LONGHIT == ident then
		self.addAct(self, {
			type = "hit",
			x = x,
			y = y,
			dir = dir,
			hitEffect = {
				magicId = 34,
				type = "twn1"
			}
		})
	elseif SM_HERO_LASTHIT == ident then
		self.addAct(self, {
			type = "hit",
			x = x,
			y = y,
			dir = dir,
			hitEffect = {
				magicId = 34,
				type = "twn2"
			}
		})
	elseif AttackType.ATT_SWORD_HIT == ident then
		self.addAct(self, {
			type = "bigHit",
			x = x,
			y = y,
			dir = dir,
			hitEffect = {
				magicId = 58,
				type = "sword",
				effectID = params.effectId or 75,
				effectType = params.effectType
			}
		})
	elseif AttackType.ATT_BIGHEARTHIT == ident then
		self.addAct(self, {
			type = "hit",
			x = x,
			y = y,
			dir = dir,
			hitEffect = {
				magicId = 26,
				type = "fire"
			}
		})
	elseif SM_RUSH == ident then
		local rushEffect = nil

		if params and params.effectId and params.effectId ~= 0 then
			rushEffect = {
				type = "rushEffect",
				effectID = params.effectId
			}
		end

		self.addAct(self, {
			type = (self.lastRushLeft and "rushRight") or "rushLeft",
			x = x,
			y = y,
			dir = dir,
			rushEffect = rushEffect
		})

		self.lastRushLeft = not self.lastRushLeft
	elseif SM_RUSHKUNG == ident then
		local rushEffect = nil

		if params and params.effectId and params.effectId ~= 0 then
			rushEffect = {
				type = "rushEffect",
				effectID = params.effectId
			}
		end

		self.addAct(self, {
			type = "rushKung",
			x = self.x,
			y = self.y,
			dir = self.dir,
			rushEffect = rushEffect
		})
	elseif SM_STRUCK == ident then
		self.addAct(self, {
			type = "struck",
			hiter = x
		})
	elseif SM_FEATURE_CHANGED == ident then
		self.changeFeature(self, feature)
	elseif SM_CHGSTATUS == ident then
		self.state = state

		self.addAct(self, {
			type = "state",
			state = self.state
		})
	elseif SM_DIGUP == ident then
		self.addAct(self, {
			type = "digup"
		})
		sound.play("appr", self.sounds.appr)
	elseif SM_DIGDOWN == ident then
		self.addAct(self, {
			type = "digdown",
			x = x,
			y = y
		})
	elseif SM_RELIVE == ident then
		self.die = false

		self.changeFeature(self, feature)
		self.uptInfoShow(self)
		self.addAct(self, {
			type = "death"
		})
		sound.play("born", self.sounds.born)
	elseif SM_SPACEMOVE_SHOW == ident or SM_SPACEMOVE_SHOW2 == ident then
		self.addAct(self, {
			type = "spacemove",
			x = x,
			y = y,
			dir = dir
		})
		self.spellDone(self)
	elseif SM_FLYAXE == ident then
		self.addAct(self, {
			type = "attack",
			x = x,
			y = y,
			dir = def.role.getMoveDir(x, y, params.x, params.y),
			flyaxe = params
		})
	elseif SM_BUTCH == ident then
		self.addAct(self, {
			type = "sitdown"
		})
	elseif SM_SPELL == ident then
		local hasDir = false

		if params.effect.effectID == 80 then
			hasDir = true
		end

		self.addAct(self, {
			type = "spell",
			dir = def.role.getMoveDir(self.x, self.y, params.targetX, params.targetY) or self.dir,
			hasDir = hasDir,
			effect = params.effect
		})
	elseif (SM_HERO_LOGON ~= ident or false) and (SM_HEALTHSPELLCHANGED ~= ident or false) then
		if SM_UNITEHIT0 == ident then
			self.addAct(self, {
				type = "hit",
				x = x,
				y = y,
				dir = dir,
				hitEffect = {
					magicId = 50,
					type = "zz"
				}
			})
		elseif SM_UNITEHIT1 == ident then
			self.addAct(self, {
				type = "hit",
				x = x,
				y = y,
				dir = dir,
				hitEffect = {
					magicId = 52,
					type = "zf"
				}
			})
		elseif SM_UNITEHIT2 == ident then
			self.addAct(self, {
				type = "hit",
				x = x,
				y = y,
				dir = dir,
				hitEffect = {
					magicId = 51,
					type = "zd"
				}
			})
		end
	end

	return self
end
local __getPosition = cc.Node.getPosition
role.getPosition = function (self)
	return __getPosition(self.node)
end
role.update = function (self, dt)
	if not self.isPlayer and not self.lock.execute and 0 < #self.acts then
		self.executeAct(self)
	end

	if self.actions and #self.actions ~= 0 then
		self.executeActions(self, dt)
	end

	if self.readyRemove then
		self.map:addMsg({
			remove = true,
			roleid = self.roleid
		})

		return 
	end

	local x, y = self.getPosition(self)
	local lpos = self.last.pos

	if lpos.x ~= x or lpos.y ~= y then
		lpos.x = x
		lpos.y = y

		self.info:uptPos(x, y)

		local _, y = self.map:getGamePos(x, y)

		self.node:setLocalZOrder(y)

		if main_scene and main_scene.ui.panels.minimap then
			main_scene.ui.panels.minimap:pointUpt(self.map, self)
		end

		if self.isPlayer then
			self.map:scroll()

			if main_scene.ui.panels.minimap then
				main_scene.ui.panels.minimap:scroll(self.map, self)
			end

			if main_scene.ui.panels.bigmap then
				main_scene.ui.panels.bigmap:pointUpt(self.map, self)
			end

			if main_scene.ui.panels.bigmapOther then
				main_scene.ui.panels.bigmapOther:pointUpt(self.map, self)
			end
		end
	end

	return 
end
role.playWaterEffect = function (self)
	m2spr.playAnimation("prguse2", 670, 20, 0.12, true, true, true):addto(self.node, 2)

	return 
end
role.playWudiEffect = function (self, del)
	local effect = self.node:getChildByName("wudi_effect")

	if del then
		if effect then
			effect.removeSelf(effect)
		end
	elseif not effect then
		m2spr.playAnimation("effect_wudi", 0, 11, 0.12, true, true, false):addto(self.node, 2):scale(0.7):setName("wudi_effect")
	end

	return 
end
role.playSpecialEffect = function (self, effectId)
	local ani = common.getSpeEffect(effectId)

	if not ani then
		return 
	end

	ani.addto(ani, self.node, 2):setName("SpeEffect" .. effectId)

	return 
end
role.stopSpecialEffect = function (self, effectId)
	local effect = self.node:getChildByName("SpeEffect" .. effectId)

	if effect then
		effect.removeSelf(effect)
	end

	return 
end

return role
