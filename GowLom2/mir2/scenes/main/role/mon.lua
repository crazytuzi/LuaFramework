local role = import(".role")
local mon = class("mon", role)

table.merge(mon, {})

mon.ctor = function (self, params)
	mon.super.ctor(self, params)
	self.initEnd(self)

	if SM_DEATH ~= params.form then
		sound.play("born", self.sounds.born)
	end

	self.isHaveMaster = params.isHaveMaster

	return 
end
mon.onEnter = function (self)
	self.super.onEnter(self)

	if self.isGuard(self) then
		self.guardData = {
			x = self.x,
			y = self.y,
			dir = self.dir,
			handler = self.node:schedule(function ()
				if (self.x ~= self.guardData.x or self.y ~= self.guardData.y) and #self.acts <= 0 then
					if self.dir ~= self.guardData.dir then
						self:processMsg(SM_TURN, self.guardData.x, self.guardData.y, self.guardData.dir)
					else
						self.node:pos(main_scene.ground.map:getMapPos(self.guardData.x, self.guardData.y))

						self.x = self.guardData.x
						self.y = self.guardData.y

						self.map:uptRoleXY(self, true, self.x, self.y)
					end
				end

				return 
			end, 0.5)
		}
	end

	return 
end
mon.isGuard = function (self)
	local race = self.getRace(self)
	local appr = self.getAppr(self)

	if (race == 12 and appr == 0) or (race == 12 and appr == 102) or (race == 24 and appr == 2) then
		return true
	else
		return false
	end

	return 
end
mon.getParts = function (self, feature)
	local parts = {}
	local race = feature.race
	local appr = feature.dress
	self.appr = appr
	self.race = race
	local monsterId = def.role.getRoleId(race, appr)
	local imgid = def.role.getMonImg(monsterId)

	if imgid then
		local dressFrame = def.role.getDressFrame(monsterId)
		parts.dress = {
			id = appr,
			imgid = imgid,
			offset = def.role.getOffset(monsterId),
			frame = dressFrame or {},
			cannotMove = not def.role.getMonster(monsterId).canMove
		}
		local hairFrame = def.role.getHairFrame(monsterId)

		if special then
			parts.hair = {
				id = appr,
				imgid = imgid,
				offset = def.role.getOffset(monsterId),
				frame = hairFrame,
				cannotMove = not def.role.getMonster(monsterId).canMove,
				blend = def.role.getMonster(monsterId).blend
			}
		end
	else
		appr = 27
		race = 18
		local monsterId = def.role.getRoleId(race, appr)
		parts.dress = {
			imgid = "mon3",
			id = appr,
			offset = def.role.getOffset(monsterId),
			frame = def.role.getFrame(monsterId)
		}
	end

	if race == 153 then
		dump(parts)
	end

	if race ~= 50 then
		self.sounds = sound.monSounds(appr)
	end

	return parts
end
mon.isPolice = function (self)
	if checkExist(self.getRace(self), 50, 12) then
		return true
	end

	local name = self.info:getName()

	if (name and name == "¹­¼ý»¤ÎÀ") or name == "¹­¼ýÊØÎÀ" then
		return true
	end

	return 
end
mon.addAct = function (self, params)
	local monsterId = def.role.getRoleId(self.getRace(self), self.feature.dress)
	local frame = def.role.getFrame(monsterId)

	if frame[params.type] and frame[params.type].otherEffect then
		params.otherEffect = frame[params.type].otherEffect
	end

	self.addActSign(self, params)
	mon.super.addAct(self, params)

	return 
end
mon.addActSign = function (self, params)
	if self.race == 99 then
		if self.info.hp.cur and self.info.hp.cur < 8500 and 5000 < self.info.hp.cur then
			params.sign = "SabukDoor-1"
		elseif self.info.hp.cur and self.info.hp.cur < 5000 then
			params.sign = "SabukDoor-2"
		end
	end

	return 
end

return mon
