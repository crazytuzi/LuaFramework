local mp = class("MagicPreview")
local magic = import("..common.magic")
local mapDef = import("..map.def")

table.merge(mp, {})

mp.ctor = function (self, lock)
	self.lock_ = lock

	return 
end
mp.showSelectedEffectPreview = function (self)
	local map = main_scene.ground.map

	if self.lock_.skill.config.type ~= "area" and self.ssSelectedSpr_ == nil then
		local ssapHitAni = res.getani2("pic/effect/singleattackhit/%d.png", 1, 4, 0.1)
		self.ssSelectedSpr_ = display.newSprite(ssapHitAni.getFrames(ssapHitAni)[1]:getSpriteFrame()):addto(map.singleSpr):pos(map.singleSpr:centerPos())

		self.ssSelectedSpr_:run(cc.RepeatForever:create(cc.Animate:create(ssapHitAni)))
	end

	return 
end
mp.hideSelectedEffectPreview = function (self)
	if not self.lock_.skill or not self.lock_.skill.config or not self.lock_.skill.config.type then
		return 
	end

	local map = main_scene.ground.map

	if self.lock_.skill.config.type ~= "area" and self.ssSelectedSpr_ then
		self.ssSelectedSpr_:removeSelf()

		self.ssSelectedSpr_ = nil
	end

	return 
end
mp.showBeganEffectPreview = function (self, mapX, mapY)
	local map = main_scene.ground.map
	local player = main_scene.ground.player

	if self.lock_.skill.config.type ~= "area" then
		map.singleSpr:setVisible(true)
		map.singleSpr:setPosition(mapX, mapY)
	else
		local eId = self.lock_.skill.config.effectID
		local gameX, gameY = map.getGamePos(map, mapX, mapY)
		local dir = def.role.getMoveDir(player.x, player.y, gameX, gameY)

		if eId == 8 and dir then
			local x, y = map.getMapPos(map, player.x, player.y)

			if self.asEffectSpr_ == nil then
				local magicCfg = self.lock_.skill.config.beatenFrame
				local begin = magicCfg.begin + dir*10*(magicCfg.dir or 2)
				self.asEffectSpr_ = m2spr.playAnimation(self.lock_.skill.config.rsc, begin, magicCfg.frame, magicCfg.delay, true, true, false, nil)

				self.asEffectSpr_:addto(map.layers.obj, y + mapDef.tile.h)
				self.asEffectSpr_:setOpacity(76.5)
			end

			self.asEffectSpr_:pos(x, y + mapDef.tile.h)
		elseif eId == 7 and dir then
			local info = def.role.dir["_" .. dir]
			local magicCfg = self.lock_.skill.config.beatenFrame
			self.huo1 = m2spr.playAnimation(self.lock_.skill.config.rsc, magicCfg.begin, magicCfg.frame, magicCfg.delay, true, true, false, nil)
			local x, y = map.getMapPos(map, player.x + info[1]*1, player.y + info[2]*1)

			self.huo1:addto(map.layers.obj, y + mapDef.tile.h)
			self.huo1:setOpacity(51)
			self.huo1:pos(x, y + mapDef.tile.h)

			self.huo2 = m2spr.playAnimation(self.lock_.skill.config.rsc, magicCfg.begin, magicCfg.frame, magicCfg.delay, true, true, false, nil)
			x, y = map.getMapPos(map, player.x + info[1]*2, player.y + info[2]*2)

			self.huo2:addto(map.layers.obj, y + mapDef.tile.h)
			self.huo2:setOpacity(51)
			self.huo2:pos(x, y + mapDef.tile.h)

			self.huo3 = m2spr.playAnimation(self.lock_.skill.config.rsc, magicCfg.begin, magicCfg.frame, magicCfg.delay, true, true, false, nil)
			x, y = map.getMapPos(map, player.x + info[1]*3, player.y + info[2]*3)

			self.huo3:addto(map.layers.obj, y + mapDef.tile.h)
			self.huo3:setOpacity(51)
			self.huo3:pos(x, y + mapDef.tile.h)

			self.huo4 = m2spr.playAnimation(self.lock_.skill.config.rsc, magicCfg.begin, magicCfg.frame, magicCfg.delay, true, true, false, nil)
			x, y = map.getMapPos(map, player.x + info[1]*4, player.y + info[2]*4)

			self.huo4:addto(map.layers.obj, y + mapDef.tile.h)
			self.huo4:setOpacity(51)
			self.huo4:pos(x, y + mapDef.tile.h)
		elseif eId == 20 then
			local x, y = map.getMapPos(map, gameX, gameY)
			self.huo3 = m2spr.playAnimation("magic", 1630, 6, 0.08, true, true, false):addto(map, y + mapDef.tile.h)

			self.huo3:pos(x, y + mapDef.tile.h)
			self.huo3:setOpacity(76.5)

			x, y = map.getMapPos(map, gameX - 1, gameY)
			self.huo1 = m2spr.playAnimation("magic", 1630, 6, 0.08, true, true, false):addto(map, y + mapDef.tile.h)

			self.huo1:pos(x, y + mapDef.tile.h)
			self.huo1:setOpacity(76.5)

			x, y = map.getMapPos(map, gameX + 1, gameY)
			self.huo2 = m2spr.playAnimation("magic", 1630, 6, 0.08, true, true, false):addto(map, y + mapDef.tile.h)

			self.huo2:pos(x, y + mapDef.tile.h)
			self.huo2:setOpacity(76.5)

			x, y = map.getMapPos(map, gameX, gameY - 1)
			self.huo4 = m2spr.playAnimation("magic", 1630, 6, 0.08, true, true, false):addto(map, y + mapDef.tile.h)

			self.huo4:pos(x, y + mapDef.tile.h)
			self.huo4:setOpacity(76.5)

			x, y = map.getMapPos(map, gameX, gameY + 1)
			self.huo5 = m2spr.playAnimation("magic", 1630, 6, 0.08, true, true, false):addto(map, y + mapDef.tile.h)

			self.huo5:pos(x, y + mapDef.tile.h)
			self.huo5:setOpacity(76.5)
		elseif checkExist(eId, 31, 70, 79, 27, 16, 21, 14) then
			local x, y = map.getMapPos(map, gameX, gameY)

			if self.asEffectSpr_ == nil then
				self.asEffectSpr_ = display.newSprite(res.gettex2("pic/common/areaskillpreview.png")):addto(map, y + mapDef.tile.h)
			end

			self.asEffectSpr_:pos(x, y + mapDef.tile.h)
		elseif eId == 12 then
			local x, y = map.getMapPos(map, gameX, gameY)

			if self.asEffectSpr_ == nil then
				local magicCfg = self.lock_.skill.config.beatenFrame
				self.asEffectSpr_ = m2spr.playAnimation(self.lock_.skill.config.rsc, 1355, 1, magicCfg.delay, true, true, false, nil)

				self.asEffectSpr_:addto(map.layers.obj, y + mapDef.tile.h)
				self.asEffectSpr_:setOpacity(51)
			end

			self.asEffectSpr_:pos(x, y + mapDef.tile.h)
		end
	end

	return 
end
mp.showMovedEffectPreview = function (self, roleId, mapX, mapY)
	local map = main_scene.ground.map
	local player = main_scene.ground.player

	if self.lock_.skill.config.type ~= "area" then
		map.singleSpr:setVisible(true)
		map.singleSpr:setPosition(mapX, mapY)

		if roleId then
			local role = map.findRole(map, roleId)

			if role then
				if not cc.rectContainsPoint(role.node:getBoundingBox(), cc.p(mapX, mapY)) then
					return 
				end

				if not role.isPlayer and role.__cname ~= "npc" and not role.isDummy and self.lock_.skill.enable then
					self.showSelectedEffectPreview(self)
				end
			end
		else
			self.hideSelectedEffectPreview(self)
		end
	else
		local gameX, gameY = map.getGamePos(map, mapX, mapY)
		local dir = def.role.getMoveDir(player.x, player.y, gameX, gameY)
		local eId = self.lock_.skill.config.effectID

		if eId == 8 then
			if self.asEffectSpr_ then
				self.asEffectSpr_.onCleanup()
				self.asEffectSpr_:removeSelf()
			end

			local x, y = map.getMapPos(map, player.x, player.y)
			local magicCfg = self.lock_.skill.config.beatenFrame

			if dir == nil then
				dir = player.dir
			end

			local begin = magicCfg.begin + dir*10*(magicCfg.dir or 2)
			self.asEffectSpr_ = m2spr.playAnimation(self.lock_.skill.config.rsc, begin, magicCfg.frame, magicCfg.delay, true, true, false, nil)

			self.asEffectSpr_:addto(map.layers.obj, y + mapDef.tile.h)
			self.asEffectSpr_:pos(x, y + mapDef.tile.h)
			self.asEffectSpr_:setOpacity(76.5)
		elseif eId == 7 then
			if dir == nil then
				dir = player.dir
			end

			local info = def.role.dir["_" .. dir]
			local x, y = map.getMapPos(map, player.x + info[1]*1, player.y + info[2]*1)

			if self.huo1 then
				self.huo1:pos(x, y + mapDef.tile.h)
			end

			x, y = map.getMapPos(map, player.x + info[1]*2, player.y + info[2]*2)

			if self.huo2 then
				self.huo2:pos(x, y + mapDef.tile.h)
			end

			x, y = map.getMapPos(map, player.x + info[1]*3, player.y + info[2]*3)

			if self.huo3 then
				self.huo3:pos(x, y + mapDef.tile.h)
			end

			x, y = map.getMapPos(map, player.x + info[1]*4, player.y + info[2]*4)

			if self.huo4 then
				self.huo4:pos(x, y + mapDef.tile.h)
			end
		elseif eId == 20 then
			local x, y = map.getMapPos(map, gameX, gameY)

			if self.huo3 then
				self.huo3:pos(x, y + mapDef.tile.h)
			end

			x, y = map.getMapPos(map, gameX - 1, gameY)

			if self.huo1 then
				self.huo1:pos(x, y + mapDef.tile.h)
			end

			x, y = map.getMapPos(map, gameX + 1, gameY)

			if self.huo2 then
				self.huo2:pos(x, y + mapDef.tile.h)
			end

			x, y = map.getMapPos(map, gameX, gameY - 1)

			if self.huo4 then
				self.huo4:pos(x, y + mapDef.tile.h)
			end

			x, y = map.getMapPos(map, gameX, gameY + 1)

			if self.huo5 then
				self.huo5:pos(x, y + mapDef.tile.h)
			end
		elseif checkExist(eId, 31, 70, 79, 27, 16, 21, 14) then
			local x, y = map.getMapPos(map, gameX, gameY)

			if self.asEffectSpr_ then
				self.asEffectSpr_:pos(x, y + mapDef.tile.h)
			end
		elseif eId == 12 then
			local x, y = map.getMapPos(map, gameX, gameY)

			if self.asEffectSpr_ then
				self.asEffectSpr_:pos(x, y + mapDef.tile.h)
			end
		end
	end

	return 
end
mp.hideEffectPreview = function (self)
	if not self.lock_.skill or not self.lock_.skill.config then
		return 
	end

	local map = main_scene.ground.map
	local eId = self.lock_.skill.config.effectID or 9999

	map.singleSpr:setVisible(false)

	if self.ssSelectedSpr_ then
		self.ssSelectedSpr_:removeSelf()

		self.ssSelectedSpr_ = nil
	end

	if self.asEffectSpr_ then
		self.asEffectSpr_.onCleanup()
		self.asEffectSpr_:removeSelf()

		self.asEffectSpr_ = nil
	end

	if self.huo1 then
		self.huo1.onCleanup()
		self.huo1:removeSelf()

		self.huo1 = nil
	end

	if self.huo2 then
		self.huo2.onCleanup()
		self.huo2:removeSelf()

		self.huo2 = nil
	end

	if self.huo3 then
		self.huo3.onCleanup()
		self.huo3:removeSelf()

		self.huo3 = nil
	end

	if self.huo4 then
		self.huo4.onCleanup()
		self.huo4:removeSelf()

		self.huo4 = nil
	end

	if self.huo5 then
		self.huo5.onCleanup()
		self.huo5:removeSelf()

		self.huo5 = nil
	end

	return 
end

return mp
