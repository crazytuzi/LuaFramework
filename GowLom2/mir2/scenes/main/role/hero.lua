local role = import(".role")
local hero = class("hero", role)

table.merge(hero, {
	lastAttackTime = 0,
	lastSpellTime = 0
})

hero.ctor = function (self, params)
	hero.super.ctor(self, params)

	self.sex = nil
	self.job = nil
	self.level = params.level or 0
	self.guildName = params.guildName or ""
	self.marryName = params.marryName

	if params.marryName == "" then
		self.marryName = nil
	end

	self.isHelper = params.isHelper
	self.lastAttackTime = 0
	self.endWarModeAction = nil

	self.initEnd(self)

	if params.isPlayer and main_scene.ui.console.autoRat.enableRat then
		self.showAutoRatHint(self)
	end

	return 
end
hero.showAutoRatHint = function (self)
	if not self.autoRatHintSpr then
		local x, y = self.node:centerPos()
		local pic = "pic/console/autoRat.png"

		if g_data.login:isChangeSkinCheckServer() then
			pic = "rs/pic/checkSvrRes/autoRat.png"
		end

		if g_data.map.state == 10 then
			pic = "pic/console/autoRat2.png"
		end

		self.autoRatHintSpr = res.get2(pic):add2(self.node, 1):pos(x, 108)
	end

	return 
end
hero.hideAutoRatHint = function (self)
	if self.autoRatHintSpr then
		self.autoRatHintSpr:removeSelf()

		self.autoRatHintSpr = nil
	end

	return 
end
hero.getParts = function (self, feature)
	local parts = {}
	local sex = feature.sex
	local weapon, dress = nil

	if 0 < feature.fweapon then
		weapon = def.role.getHeroWeapon(feature.fweapon*2 + sex)
	else
		weapon = def.role.getHeroWeapon(feature.weapon*2 + sex)
	end

	local frameid = 0

	if 0 < feature.riding then
		dress = def.role.getHeroHorse(feature.riding*2 + sex)
		frameid = 1
	elseif 0 < feature.wing then
		dress = def.role.getHeroDress(feature.wing*2 + sex)
	elseif 0 < feature.fcloth then
		dress = def.role.getHeroDress(feature.fcloth*2 + sex)
	else
		dress = def.role.getHeroDress(feature.dress*2 + sex)
	end

	local hairImg, hair = def.role.hair(feature)
	self.sex = sex
	self.hair = hair
	local frame = def.role.getDressFrame(frameid)
	parts.dress = {
		id = dress.Id,
		imgid = string.lower(dress.WhichLib or ""),
		offset = dress.OffSet,
		frame = frame or {}
	}
	parts.weapon = {
		id = weapon.Id,
		imgid = string.lower(weapon.WhichLib or ""),
		offset = weapon.OffSet,
		frame = frame or {}
	}

	if self.sex == 1 then
		parts.weapon.delete = weapon.Id == 1
	else
		parts.weapon.delete = not weapon.Id
	end

	parts.hair = {
		id = hair,
		imgid = hairImg,
		offset = def.role.humFrame*hair,
		frame = frame or {},
		delete = hair == 0
	}

	if dress.WihichEffectLib then
		parts.humEffect = {
			blend = true,
			id = dress.Id,
			imgid = string.lower(dress.WihichEffectLib or ""),
			offset = dress.EffectOffSet,
			offsetEnd = dress.offsetEnd,
			delay = dress.delay,
			alwaysPlay = dress.alwaysPlay,
			frame = frame
		}
	else
		parts.humEffect = {
			delete = true
		}
	end

	if 0 < feature.riding then
		parts.hair.imgid = ""
		parts.hair.delete = true
		parts.weapon.imgid = ""
		parts.weapon.delete = true
	end

	return parts, sex
end
hero.addAct = function (self, params)
	if self.endWarModeAction then
		self.node:stopAction(self.endWarModeAction)

		self.endWarModeAction = nil
	end

	self.isWarMode = false

	if 0 < DEBUG and g_data.playerActLog then
		local interval = g_data.client:getIntervalTime("addact")

		g_data.client:setLastTime("addact", true)

		local curTime = socket.gettime()

		p2("autoRat", "add " .. params.type .. " act - time interval: " .. math.ceil(interval*1000) .. ", curTime: " .. math.ceil(curTime*1000))
	end

	if params.type == "hit" or params.type == "spell" or params.type == "heavyHit" or params.type == "bigHit" then
		if params.type == "spell" then
			lastSpellTime = socket.gettime()
		elseif 0 < DEBUG and g_data.playerHitActLog then
			local interval = g_data.client:getIntervalTime("hitAct")

			g_data.client:setLastTime("hitAct", true)

			local curTime = socket.gettime()

			p2("autoRat", "hitAct - time interval: " .. math.ceil(interval*1000) .. ", curTime: " .. math.ceil(curTime*1000))
		end

		self.lastAttackTime = socket.gettime()
	elseif params.type == "die" then
		if self.isPlayer then
			self.map:setGrayState()
			main_scene.ui.console.autoRat:stop()
		end

		if not params.corpse then
			sound.playSound(sound.s_man_die + self.sex)
		end
	end

	hero.super.addAct(self, params)

	return 
end
local warModeType = {
	spell = true,
	bigHit = true,
	heavyHit = true,
	hit = true
}
local standDelay = 0.1
hero.allExecuteEnd = function (self)
	local speedUpOther = g_data.speedUpOther

	if not self.die and self.last.act then
		local time = socket.gettime() - self.lastAttackTime
		local lastType = self.last.act.type

		if time < 4 and warModeType[lastType] then
			local act = {
				type = "warMode",
				dir = self.last.act.dir or self.dir
			}

			for k, v in pairs(self.sprites) do
				v.play(v, act)
			end

			_, self.endWarModeAction = self.node:runs({
				cc.DelayTime:create(time - 4),
				cc.CallFunc:create(function ()
					self:addStandAct()

					self.endWarModeAction = nil

					return 
				end)
			})
		elseif speedUpOther and not self.isPlayer then
			if self.last.act.type ~= "stand" then
				self.isExecuteEnd = true

				self.node.runs(slot4, {
					cc.DelayTime:create(standDelay),
					cc.CallFunc:create(function ()
						if self.isExecuteEnd then
							self:addStandAct()
						end

						return 
					end)
				})
			end
		else
			hero.super.allExecuteEnd(warModeType)
		end
	end

	self.isExecuteEnd = true

	return 
end
hero.getHitTime = function (self)
	local hitSpeed = tonumber(avoidPlugValue(self.hitSpeed, true)) or 0
	local ret = math.max(0, def.role.speed.attack - math.min(300, hitSpeed*60)/1000)

	return ret
end
hero.canNextHit = function (self)
	return self.getHitTime(self) < socket.gettime() - self.lastAttackTime
end
hero.getNextMagicDelay = function (self, magicId)
	local magicDelay = g_data.player:getMagicDelay(magicId)
	magicDelay = magicDelay or 0
	local time = def.role.speed.spell + magicDelay/1000

	return (self.lastSpellTime + time) - socket.gettime()
end
hero.canNextSpell = function (self, magicId)
	if self.isLocked(self) then
		return false
	end

	return self.getNextMagicDelay(self, magicId) <= 0
end

return hero
