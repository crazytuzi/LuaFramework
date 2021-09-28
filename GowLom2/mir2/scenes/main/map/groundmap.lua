local current = ...
local mapDef = import(".def")
local maptile = import(".maptile")
local role = import("..role.role")
local hero = import("..role.hero")
local npc = import("..role.npc")
local mon = import("..role.mon")
local roleInfo = import("..role.info")
local magic = import("..common.magic")
local settingLogic = import("..common.settingLogic")
local map = class("map", function ()
	return ycMap:create()
end)
local __position = cc.Node.setPosition

ccs.ArmatureDataManager.getInstance(slot12):addArmatureFileInfo("animation/lubiao/lubiao.csb")

local lubiaoArmature = ccs.Armature:create("lubiao")

lubiaoArmature.retain(lubiaoArmature)
table.merge(map, {
	isStage = false
})

map.ctor = function (self, mapid)
	self.mapid = mapid
	self.replaceMapid = g_data.map.mapReplace[mapid]
	self.hasRes = def.map.isHasRes(self.mapid) or def.map.isHasRes(self.replaceMapid)
	self.player = nil
	self.gray = false
	self.mons = {}
	self.npcs = {}
	self.heros = {}
	self.items = {}
	self.doors = {}
	self.stalls = {}
	self.safezoneEffs = {}
	self.events = {}
	self.yantongs = {}
	self.readyTiles = {}
	self.roleXYs = {}
	self.msgs = newList()
	local file = res.loadmap(self.replaceMapid or self.mapid)
	self.h = file.geth(file)
	self.w = file.getw(file)
	self.layers = {
		bg = display.newNode():addto(self),
		mid = display.newNode():addto(self),
		obj = display.newNode():addto(self, 0, 1025),
		itemName = display.newNode():addto(self),
		itemEff = display.newNode():addto(self),
		infoHpBg = display.newNode():addto(self),
		infoHpSpr = display.newNode():addto(self),
		infoHpOut = display.newNode():addto(self)
	}
	self.tiles = {}

	self.size(self, file.getw(file)*mapDef.tile.w, file.geth(file)*mapDef.tile.h)
	self.runForever(self, transition.sequence({
		cc.DelayTime:create(20),
		cc.CallFunc:create(handler(self, self.clearTiles))
	}))

	if not self.hasRes and main_scene and main_scene.ui then
		main_scene.ui:tip("该地图的环境正在施工中.")
	end

	self.relationHandler = handler(self, self.onRelationUpdate)

	g_data.relation:addNotifyListener(self.relationHandler)

	self.onCleanup = function ()
		g_data.relation:removeNotifyListener(self.relationHandler)

		return 
	end
	self.blocks = {}

	self.updateMapScale(mapDef)

	local lubiaoParent = lubiaoArmature:getParent()

	if lubiaoParent then
		lubiaoArmature:removeSelf()
	end

	self.layers.obj:addChild(lubiaoArmature)

	self.singleSpr = display.newSprite(res.gettex2("pic/console/singleskillpreview.png"))

	if self.singleSpr then
		self.singleSpr:setVisible(false)
		self.addChild(self, self.singleSpr)
	end

	if g_data.login:isChangeSkinCheckServer() then
		local chkResPath = g_data.login:getChkResPath()

		print(chkResPath)

		self.pngMap = display.newSprite(res.gettex2(chkResPath .. "map.png")):add2(self.layers.obj):scale(1):anchor(0.5, 0.5):pos(self.getContentSize(self).width/2 - mapDef.tile.w/2, self.getContentSize(self).height/2 + mapDef.tile.h)
	end

	return 
end
map.removeSelf = function (self)
	if main_scene.ui.console.controller.mp then
		main_scene.ui.console.controller.mp:hideEffectPreview()
		main_scene.ui.console.controller.mp:hideSelectedEffectPreview()
	end

	cc.Node.removeSelf(self)

	return 
end
map.showLuBiao = function (self, mapX, mapY)
	if lubiaoArmature then
		lubiaoArmature:setPosition(mapX + mapDef.tile.w/2, mapY + mapDef.tile.h/2)
		lubiaoArmature:anchor(0.75, 0.5)
		lubiaoArmature:setVisible(true)
		lubiaoArmature:getAnimation():play("lubiao", -1, 1)
	end

	return 
end
map.hideLubiao = function (self)
	if lubiaoArmature then
		lubiaoArmature:setVisible(false)
	end

	return 
end
map.onRelationUpdate = function (self, _, rel, ole, new)
	if (rel == "attention" or rel == "attentionColor") and (ole or new) then
		local name = (ole and ole.FName) or new.FName
		local role = nil

		if self.heros then
			for k, v in pairs(self.heros) do
				print(v.info:getName(), name)

				if v.info:getName() == name then
					role = v

					break
				end
			end
		end

		if role then
			if new then
				role.info:setNameColor(new.FFocusColor)
			elseif ole.realNameColor then
				role.info:setNameColor(ole.realNameColor)
			end
		end
	end

	return 
end
map.updateMapScale = function (self, s)
	local scale = s or g_data.setting.display.mapScale
	self.screenw = math.ceil(display.width/mapDef.tile.w/scale)
	self.screenh = math.ceil(display.height/mapDef.tile.h/scale)

	return 
end
map.checkInScreen = function (self, x, y)
	local player = self.player
	local ret = math.abs(player.x - x) < self.screenw/2 + 2 and math.abs(player.y - y) < self.screenh/2 + 2

	return ret
end
map.setAllRoleInScreen = function (self, inScreen)
	for k, roles in pairs(self.roleXYs) do
		for k, v in pairs(roles) do
			if v.isInScreen ~= inScreen then
				v.isInScreen = inScreen

				v.uptIsIgnore(v)
			end
		end
	end

	return 
end
map.updateRoleInScreen = function (self, x, y, endx, endy, inScreen)
	if endx < x then
		endx = x
		x = endx
	end

	if endy < y then
		endy = y
		y = endy
	end

	local uptIsIgnore = role.uptIsIgnore

	for mx = x, endx, 1 do
		mx = mx*10000

		for my = y + mx, endy + mx, 1 do
			local roles = self.roleXYs[my]

			if roles then
				for k, v in pairs(roles) do
					if v.isInScreen ~= inScreen then
						v.isInScreen = inScreen

						uptIsIgnore(v)
					else
						break
					end
				end
			end
		end
	end

	return 
end
map.load = function (self, x, y, ofsx, ofsy)
	local function loadArea(beginx, beginy, endx, endy)
		beginx = math.max(0, math.min(self.w, beginx))
		endx = math.max(0, math.min(self.w, endx))
		beginy = math.max(0, math.min(self.h, beginy))
		endy = math.max(0, math.min(self.h, endy))

		for i = beginx, endx, 1 do
			for j = beginy, endy, 1 do
				self:addTile(i, j)
			end
		end

		return 
	end

	local screenw = self.screenw
	local screenh = self.screenh
	local rangew = screenw + mapDef.loadOutsideArea*2
	local newx = slot1
	local newy = y
	local beginx, endx, beginy, endy = nil

	if ofsx and ofsy then
		newy = y + ofsy
		newx = x + ofsx

		if ofsx ~= 0 then
			local rbeginx, rendx, ey = nil

			if 0 < ofsx then
				beginx = math.floor(x + rangew/2)
				endx = beginx + ofsx
				rendx = math.floor(x - rangew/2) - 1
				rbeginx = rendx - ofsx - 1
			else
				endx = math.floor(x - rangew/2) - 1
				beginx = (endx + ofsx) - 1
				rbeginx = math.floor(x + rangew/2)
				rendx = rbeginx - ofsx
			end

			beginy = math.floor(y - screenh/2 - mapDef.loadOutsideArea) + ofsy
			ey = beginy + screenh
			endy = ey + mapDef.loadOutsideAreaBottom + mapDef.loadOutsideArea

			loadArea(beginx, beginy, endx, endy)

			if screenw <= 24 then
				self.updateRoleInScreen(self, rbeginx, beginy, rendx, ey, false)
				self.updateRoleInScreen(self, beginx, beginy, endx, ey, true)
			end
		end

		if ofsy ~= 0 then
			local rbeginy, rendy, by, ey = nil

			if 0 < ofsy then
				beginy = math.floor(y + screenh/2 + mapDef.loadOutsideAreaBottom)
				by = beginy - mapDef.loadOutsideAreaBottom
				endy = beginy + ofsy
				ey = endy
				rendy = math.floor(y - screenh/2)
				rbeginy = rendy - ofsy
			else
				endy = math.floor(y - screenh/2 - mapDef.loadOutsideArea)
				ey = endy + mapDef.loadOutsideArea
				beginy = endy + ofsy
				by = beginy
				rbeginy = math.floor(y + screenh/2)
				rendy = rbeginy - ofsy
			end

			beginx = math.floor(x - rangew/2 + ofsx)
			endx = beginx + rangew

			loadArea(beginx, beginy, endx, endy)

			if screenh <= 24 then
				self.updateRoleInScreen(self, beginx, rbeginy + 2, endx, rendy + 1, false)
				self.updateRoleInScreen(self, beginx, by, endx, ey, true)
			end
		end
	else
		endx = math.floor(x + rangew/2)
		beginx = math.floor(x - rangew/2)
		endy = math.floor(y + screenh/2 + mapDef.loadOutsideAreaBottom)
		beginy = math.floor(y - screenh/2 - mapDef.loadOutsideArea)

		loadArea(beginx, beginy, endx, endy)

		if 24 < screenh and 24 < screenw then
			self.setAllRoleInScreen(self, true)
		else
			self.setAllRoleInScreen(self, false)
			self.updateRoleInScreen(self, beginx, math.floor(y - screenh/2), endx, math.floor(y + screenh/2), true)
		end
	end

	local safezonexDatas = g_data.map:isSeeSafeZoneEdge(self.mapid, newx, newy, screenw, screenh)

	if safezonexDatas then
		for i, v in ipairs(safezonexDatas) do
			self.addSafeZoneEff(self, v.x, v.y, v.rang)
		end
	end

	return 
end
map.updateLookArea = function (self, x, y)
	self.lookArea = cc.rect(x - display.cx/g_data.setting.display.mapScale, y - display.cy/g_data.setting.display.mapScale, display.width/g_data.setting.display.mapScale, display.height/g_data.setting.display.mapScale)

	return 
end
map.scroll = function (self, isAnima, dura)
	local tw = mapDef.tile.w
	local th = mapDef.tile.h
	local x, y = self.player.node:getPosition()

	if isAnima then
		self.moveTo(self, dura or 0.2, (-x + display.cx) - tw/2, (-y + display.cy) - th/2)
	else
		self.pos(self, (-x + display.cx) - tw/2, (-y + display.cy) - th/2)
	end

	self.updateLookArea(self, x, y)

	return 
end
map.setGrayState = function (self)
	self.gray = true
	local f = res.getFilter("gray")

	for k, v in pairs(self.tiles) do
		for k2, v2 in pairs(v) do
			if v2.sprites.bg then
				v2.sprites.bg:setFilter(f)
			end

			if v2.sprites.mid then
				v2.sprites.mid:setFilter(f)
			end

			if v2.sprites.midAni then
				v2.sprites.midAni:setFilter(f)
			end

			if v2.sprites.obj then
				v2.sprites.obj:setFilter(f)
			end

			if v2.sprites.ani then
				v2.sprites.ani:setFilter(f)
			end
		end
	end

	for k, v in pairs(self.heros) do
		v.openFilter(v, "die")
	end

	for k, v in pairs(self.mons) do
		v.openFilter(v, "die")
	end

	for k, v in pairs(self.npcs) do
		v.openFilter(v, "die")
	end

	return 
end
map.getMapPosWithScreenPos = function (self, x, y)
	local tw = mapDef.tile.w
	local th = mapDef.tile.h
	local diffx = x - display.cx
	local diffy = y - display.cy
	local node = self.player.node

	return node.getPositionX(node) + tw/2 + diffx/main_scene.ground:getScale(), node.getPositionY(node) + th/2 + diffy/main_scene.ground:getScale()
end
map.getScreenPosWithMapPos = function (self, mapX, mapY)
	local tw = mapDef.tile.w
	local th = mapDef.tile.h
	local node = self.player.node
	local playX = node.getPositionX(node)
	local playY = node.getPositionY(node)
	local mapScale = main_scene.ground:getScale()
	local sx = (mapX - playX - tw/2)*mapScale + display.cx
	local sy = (mapY - playY - th/2)*mapScale + display.cy

	return sx, sy
end
map.getPlayerHW = function (self)
	local node = self.player.node
	local mapScale = main_scene.ground:getScale()
	local playW = node.getContentSize(node).width*mapScale
	local playH = node.getContentSize(node).height*mapScale

	return playW, playH
end
map.getMapPos = function (self, gameX, gameY)
	return gameX*mapDef.tile.w, (self.h - gameY)*mapDef.tile.h
end
map.getGamePos = function (self, mapX, mapY)
	return math.floor(mapX/mapDef.tile.w), math.floor(self.h - mapY/mapDef.tile.h + 1)
end
map.addDoorTile = function (self, data, x, y)
	local idx = ycFunction:band(data.doorIndex, 127)
	local door = self.doors[idx]

	if not door then
		door = {}
		self.doors[idx] = door
	end

	for k, v in pairs(door) do
		if v.x == x and v.y == y then
			return 
		end
	end

	door[#door + 1] = {
		x = x,
		y = y,
		data = data
	}

	return 
end
map.setDoorState = function (self, isOpen, x, y)
	p2("res", "map:setDoorState: file:gettile")

	local file = res.loadmap(self.replaceMapid or self.mapid)
	local data = file.gettile(file, x, y)

	if data then
		local idx = ycFunction:band(data.doorIndex, 127)
		local door = self.doors[idx]

		if door then
			for k, v in pairs(door) do
				local tile = self.tiles[v.x][v.y]

				if tile then
					v.data.doorOpen = isOpen

					tile.setDoorState(tile, v.data)
				end
			end
		end
	end

	return 
end
map.addSafeZoneEff = function (self, x, y, range)
	local key = self.xy2key(self, x, y)

	if self.safezoneEffs[key] then
		return 
	end

	self.safezoneEffs[key] = true
	local points = {
		{
			flag = 0,
			x = x - range,
			y = y - range - 1
		},
		{
			flag = 2,
			x = x + range,
			y = y - range - 1
		},
		{
			flag = 4,
			x = x + range,
			y = (y + range) - 1
		},
		{
			flag = 6,
			x = x - range,
			y = (y + range) - 1
		}
	}

	for i = 1, range*2 + 1, 1 do
		points[#points + 1] = {
			flag = 1,
			x = (x - range + i) - 1,
			y = y - range - 1
		}
		points[#points + 1] = {
			flag = 3,
			x = x + range,
			y = (y - range + i) - 2
		}
		points[#points + 1] = {
			flag = 5,
			x = (x - range + i) - 1,
			y = y + range + 1
		}
		points[#points + 1] = {
			flag = 7,
			x = x - range - 2,
			y = (y - range + i) - 2
		}
	end

	for i, v in ipairs(points) do
		local x = v.x
		local y = v.y

		if self.mapid ~= "0" or 319 > x or x > 337 or 261 > y or y > 276 or false then
			local spr = m2spr.playAnimation("magic10", v.flag*10 + 2040, 4, 0.2, true, nil, nil, nil, nil, 1):addto(self.layers.mid, 99999)

			__position(spr, x*mapDef.tile.w, (self.h - y)*mapDef.tile.h)
		end
	end

	return 
end
map.canWalk = function (self, gamex, gamey, params)
	local ret = {}
	local file = res.loadmap(self.replaceMapid or self.mapid)

	if params and params.useBlockInfo then
		if file.getblock(file, gamex, gamey) then
			ret.block = "block"
		end
	else
		local data = file.gettile(file, gamex, gamey)

		if data then
			if 0 < ycFunction:band(data.doorIndex, 128) and not data.doorOpen then
				ret.block = "door"
				ret.data = data
			elseif not data.canWalk then
				ret.block = "map"
			end
		end
	end

	if not ret.block then
		ret = self.isObjblock(self, gamex, gamey)
	end

	return ret
end
map.canFly = function (self, gamex, gamey, params)
	p2("res", "map:canFly: file:gettile")

	local file = res.loadmap(self.replaceMapid or self.mapid)
	local data = file.gettile(file, gamex, gamey)

	return data.canFly
end
map.getObjeBlocks = function (self)
	local objects = {}

	local function checkRoles(roles)
		for k, v in pairs(roles) do
			if not v.isDummy and not v.die then
				objects[#objects + 1] = cc.p(v.x, v.y)
			end
		end

		return 
	end

	slot2(self.mons)
	checkRoles(self.npcs)
	checkRoles(self.heros)

	return objects
end
map.isObjblock = function (self, gamex, gamey)
	local ret = {}

	if not ret.block then
		for k, v in pairs(self.mons) do
			if not v.isDummy and gamex == v.x and gamey == v.y and not v.die then
				ret.block = "mon"

				break
			end
		end
	end

	if not ret.block then
		for k, v in pairs(self.npcs) do
			if not v.isDummy and gamex == v.x and gamey == v.y and not v.die then
				ret.block = "npc"

				break
			end
		end
	end

	if not ret.block then
		for k, v in pairs(self.heros) do
			if not v.isDummy and gamex == v.x and gamey == v.y and not v.die then
				ret.block = "hero"

				break
			end
		end
	end

	slot4 = ret.block or slot4

	return ret
end
map.procAllRoles = function (self, f)
	for k, roles in ipairs({
		self.heros,
		self.npcs,
		self.mons
	}) do
		for k, v in pairs(roles) do
			f(v)
		end
	end

	return 
end
map.findRole = function (self, roleid, params)
	local role = nil
	role = self.heros[roleid]

	if role then
		return role
	end

	role = self.npcs[roleid]

	if role then
		return role
	end

	role = self.mons[roleid]

	if role then
		return role
	end

	if params and params.feature then
		return self.newRole(self, params), true
	end

	return 
end
map.findRoleByNameColor = function (self, colorIndex)
	local ret = {}

	for k, v in pairs(self.heros) do
		if v.info.name.color == colorIndex and v.roleid ~= self.player.roleid then
			ret[#ret + 1] = v
		end
	end

	return ret
end
map.findRoleWithPos = function (self, x, y, type)
	if not type or type == "hero" then
		for k, v in pairs(self.heros) do
			if v.x == x and v.y == y then
				return v
			end
		end
	end

	if not type or type == "mon" then
		for k, v in pairs(self.mons) do
			if v.x == x and v.y == y then
				return v
			end
		end
	end

	if not type or type == "npc" then
		for k, v in pairs(self.npcs) do
			if v.x == x and v.y == y then
				return v
			end
		end
	end

	return 
end
map.findHeroWithName = function (self, name)
	for k, v in pairs(self.heros) do
		if v.info:getName() == name then
			return v
		end
	end

	return 
end
map.findNPCWithName = function (self, name)
	for k, v in pairs(self.npcs) do
		if v.info:getName() == name then
			return v
		end
	end

	return 
end
map.findNearMon = function (self)
	local bestDis, bestMon = nil

	for k, v in pairs(self.mons) do
		local name = v.info:getName()

		if not v.die and not v.isPolice(v) and v.isHaveMaster == false then
			local x = math.abs(self.player.x - v.x)
			local y = math.abs(self.player.y - v.y)
			local dis = math.sqrt(x*x + y*y)

			if not bestDis or dis < bestDis then
				bestDis = dis
				bestMon = v
			end
		end
	end

	return bestMon
end
map.newRole = function (self, params)
	assert(params.roleid, "map.newRole -> roleid must be not nil")

	params.map = self
	local race = params.feature.race
	local ret = nil

	if race == 0 or race == 1 or race == 150 then
		ret = hero.new(params)

		ret.node:addTo(self.layers.obj)

		self.heros[params.roleid] = ret

		if params.isPlayer then
			self.setPlayer(self, ret)
		end
	elseif race == 50 then
		ret = npc.new(params)

		ret.node:addTo(self.layers.obj)

		self.npcs[params.roleid] = ret
	else
		ret = mon.new(params)

		ret.node:addTo(self.layers.obj)

		self.mons[params.roleid] = ret
	end

	if main_scene and main_scene.ui.panels.minimap then
		main_scene.ui.panels.minimap:addPoint(ret)
	end

	self.uptRoleXY(self, ret, false, params.x, params.y)

	return ret
end
map.removeRole = function (self, roleid)
	local role = nil
	role = self.heros[roleid]

	if role then
		self.uptRoleXY(self, role, true)
		role.info:remove()
		role.node:removeSelf()
	end

	self.heros[roleid] = nil
	role = self.npcs[roleid]

	if role then
		self.uptRoleXY(self, role, true)
		role.info:remove()
		role.node:removeSelf()
	end

	self.npcs[roleid] = nil
	role = self.mons[roleid]

	if role then
		self.uptRoleXY(self, role, true)
		role.info:remove()
		role.node:removeSelf()
	end

	self.mons[roleid] = nil

	if main_scene and main_scene.ui and main_scene.ui.panels.minimap then
		main_scene.ui.panels.minimap:removePoint(roleid)
	end

	return 
end
map.setPlayer = function (self, player)
	if self.player then
		self.removeTopRenderNode(self, self.player)
		self.player.node:removeSelf()
	end

	self.player = player

	self.addTopRenderNode(self, self.player.node)

	return 
end
map.xy2key = function (self, x, y)
	return x*10000 + y
end
map.uptRoleXY = function (self, role, isRemove, x, y)
	local oldKey = role.xyKey
	local newKey = x and y and self.xy2key(self, x, y)

	if oldKey == newKey then
		return 
	end

	if oldKey then
		local roles = self.roleXYs[oldKey]

		if roles then
			for i, v in ipairs(roles) do
				if v == role then
					table.remove(roles, i)

					break
				end
			end

			if not role.isUnderOtherRole then
				for i, v in ipairs(roles) do
					if not v.die then
						v.setIsUnderOtherRole(v, false)
						v.uptIsIgnore(v)

						break
					end
				end
			end
		end
	end

	if isRemove then
		return 
	end

	local roles = self.roleXYs[newKey]

	if not roles then
		roles = {}
		self.roleXYs[newKey] = roles
	end

	roles[#roles + 1] = role

	if self.player and not self.isStage then
		role.isInScreen = math.abs(x - self.player.x + 1) <= self.screenw/2 + 1 and math.abs(y - self.player.y) < self.screenh/2 + 2
	else
		role.isInScreen = true
	end

	for i, v in ipairs(roles) do
		v.setIsUnderOtherRole(v, false)
		v.uptIsIgnore(v)
	end

	role.uptIsIgnore(role)

	role.xyKey = newKey

	return 
end
local movedt = 1.5
map.showPickUp = function (self, gameX, gameY, imgid)
	local mapX, mapY = self.getMapPos(self, gameX, gameY)
	local sx, sy = self.getScreenPosWithMapPos(self, mapX, mapY)
	local playW, playerH = self.getPlayerHW(self)
	local spr = m2spr.new("dnitems", imgid, {
		asyncPriority = 1
	}):addto(main_scene.ui, mapY):anchor(0, 0):pos(sx, sy + playerH)

	local function hideSpr()
		spr.spr:removeSelf()

		return 
	end

	local function spin()
		local sprSpin = m2spr.playAnimation("prguse", 410, 9, 0.08, true, true, true, nil, nil, 1)

		sprSpin.addto(sprSpin, spr)

		return 
	end

	local destX = 60
	local destY = display.height - 10

	spr.runs(slot10, {
		cc.MoveTo:create(movedt, cc.p(destX, destY)),
		cc.RepeatForever:create(transition.sequence({
			cc.CallFunc:create(spin),
			cc.DelayTime:create(0.54)
		}))
	})
	spr.run(spr, transition.sequence({
		cc.DelayTime:create(movedt),
		cc.CallFunc:create(hideSpr)
	}))

	return 
end
map.showItem = function (self, isPickUp, isshow, itemid, gamex, gamey, name, imgid, owner, state)
	if isshow ~= self.items[itemid] ~= nil then
		if isshow then
			if name == "金币" then
				print("显示金币", itemid, gamex, gamey, name, imgid, state)
			end

			local x, y = self.getMapPos(self, gamex, gamey)
			local item = {
				x = gamex,
				y = gamey,
				owner = owner,
				imgid = imgid,
				itemid = itemid,
				state = state,
				spr = m2spr.new("dnitems", imgid, {
					asyncPriority = 1
				}):addto(self.layers.obj, gamey):anchor(0.5, 0.5):pos(x + mapDef.tile.w/2, y + mapDef.tile.h/3):runs({
					cc.DelayTime:create(math.random(3000)/1000),
					cc.RepeatForever:create(transition.sequence({
						cc.CallFunc:create(function ()
							local spr = m2spr.playAnimation("prguse", 410, 9, 0.08, true, true, true, nil, nil, 1):addto(self.layers.itemEff)

							__position(spr, x, y + mapDef.tile.h)

							return 
						end),
						cc.DelayTime.create(slot20, 0.54),
						cc.DelayTime:create(5)
					}))
				})
			}
			local isGood = false
			local showName = false

			if state and 0 < state then
				isGood = g_data.setting.getGoodAttItemSetting().isGood
				showName = g_data.setting.getGoodAttItemSetting().hintName
			end

			isGood = isGood or settingLogic.isGoodItem(name)
			showName = showName or settingLogic.showItemName(name)

			if showName or isGood then
				local nameColor = def.colors.skyBlue

				if isGood then
					nameColor = def.colors.clRed
				end

				if state and 0 < state then
					nameColor = def.colors.clpurple
				end

				item.name = an.newLabel(name, 12, 1, {
					bufferChannel = 8,
					color = nameColor
				}):addto(self.layers.itemName):anchor(0.5, 0.5)
				local nameX = x + mapDef.tile.w/2
				local nameY = y + mapDef.tile.h/2 + 10

				__position(item.name, nameX, nameY)
			end

			self.items[itemid] = item
			item.itemName = name

			return 
		end

		local item = self.items[itemid]

		if isPickUp then
			self.showPickUp(self, item.x, item.y, item.imgid)
		end

		item.spr:removeSelf()

		if item.name then
			item.name:removeSelf()
		end

		self.items[itemid] = nil
	end
end
map.updateItems = function (self)
	local t = self.items
	self.items = {}

	for k, v in pairs(t) do
		v.spr:removeSelf()

		if v.name then
			v.name:removeSelf()
		end

		self.showItem(self, false, true, k, v.x, v.y, v.itemName, v.imgid, v.owner, v.state)
	end

	return 
end
map.getItems = function (self, x, y)
	local ret = {}

	for k, v in pairs(self.items) do
		if v.x == x and v.y == y then
			ret[#ret + 1] = v
		end
	end

	return ret
end
map.showMagic = function (self, roleid, effectType, effectID, x, y, target, playCnt)
	local role = self.findRole(self, roleid)

	if not role then
		return 
	end

	magic.showMagic(self, role, target, x, y, effectID, playCnt)

	return 
end
map.showEffectForName = function (self, name, params)
	magic.showWithName(self, name, params)

	return 
end
local __position = cc.Node.setPosition
map.showEvent = function (self, serverID, x, y, type, eventMsg)
	self.hideEvent(self, serverID)

	if mapDef.ET_FIRE == type then
		local imgid = "magic"
		local begin = 1630
		local frame = 6
		x, y = self.getMapPos(self, x, y)
		self.events[serverID] = m2spr.playAnimation(imgid, begin, frame, 0.08, true):opacity(153):addto(self.layers.obj, y + mapDef.tile.h)
	elseif mapDef.ET_HOLYCURTAIN == type then
		local imgid = "magic"
		local begin = 1390
		local frame = 10
		x, y = self.getMapPos(self, x, y)
		self.events[serverID] = m2spr.playAnimation(imgid, begin, frame, 0.08, true):addto(self.layers.obj, y + mapDef.tile.h)
	elseif mapDef.ET_PILESTONES == type then
		local imgid = "effect"
		local begin = 64
		local frame = 5
		x, y = self.getMapPos(self, x, y)
		self.events[serverID] = m2spr.playAnimation(imgid, begin, frame, 0.12, false, false, true):addto(self.layers.mid, 99999)
	elseif mapDef.ET_DIGOUTZOMBI == type then
		local imgid = "mon6"
		local begin = 420
		local frame = 6
		x, y = self.getMapPos(self, x, y)
		self.events[serverID] = m2spr.playAnimation(imgid, begin, frame, 0.3, false, false, true):addto(self.layers.mid, 99999)
	elseif mapDef.ET_YanHuaTextEvent == type then
		x, y = self.getMapPos(self, x, y)
		x = x - 130
		self.events[serverID] = an.newLabel(eventMsg, 100, 0.5, {
			color = cc.c3b(255, 255, 0),
			sc = display.COLOR_WHITE
		}):addto(self.layers.obj, 99999)

		self.events[serverID]:setGlobalZOrder(999999)
	elseif mapDef.ET_CAKEFIRE == type then
		local imgid = "prguse3"
		local begin = mapDef.CAKEFIREBASE
		local frame = 30
		x, y = self.getMapPos(self, x, y)
		self.events[serverID] = m2spr.playAnimation(imgid, begin, frame, 0.08, true):addto(self.layers.obj, y + mapDef.tile.h)
	elseif mapDef.ET_INTENTLY <= type and type <= mapDef.ET_SUCHASFOGDREAM then
		local frameBegin = {
			20,
			20,
			16,
			16,
			16,
			16,
			16
		}
		local imgid = "magic3"
		local begin = (type - mapDef.ET_INTENTLY)*20 + 60
		local frame = frameBegin[type - mapDef.ET_INTENTLY + 1]
		x, y = self.getMapPos(self, x, y)

		m2spr.playAnimation(imgid, begin, frame, 0.12, true, true, true):addto(self.layers.mid, 99999):pos(x, y + mapDef.tile.h)
	elseif type == mapDef.ET_YEARFIRE1 then
		local begin = {
			1020,
			1040
		}
		local frame = {
			4,
			18
		}
		local time = {
			0.12,
			0.12
		}
		local imgid = "mon25"
		x, y = self.getMapPos(self, x, y)
		self.yantongs[serverID] = {
			spr = m2spr.playAnimation(imgid, begin[1], frame[1], time[1], false):addto(self.layers.mid, 99999):pos(x, y),
			x = x,
			y = y
		}
		self.events[serverID] = m2spr.playAnimation(imgid, begin[2], frame[2], time[2], true):addto(self.layers.mid, 99999):pos(x, y)
	elseif type == mapDef.ET_YEARFIRE2 then
		local begin = {
			1020,
			1060
		}
		local frame = {
			4,
			18
		}
		local time = {
			0.12,
			0.12
		}
		local imgid = "mon25"
		x, y = self.getMapPos(self, x, y)
		self.yantongs[serverID] = {
			spr = m2spr.playAnimation(imgid, begin[1], frame[1], time[1], false):addto(self.layers.mid, 99999):pos(x, y),
			x = x,
			y = y
		}
		self.events[serverID] = m2spr.playAnimation(imgid, begin[2], frame[2], time[2], true):addto(self.layers.mid, 99999):pos(x, y)
	elseif mapDef.ET_STALL_EVENT ~= type or false then
		if mapDef.ET_WATER == type then
			x, y = self.getMapPos(self, x, y)
			self.events[serverID] = m2spr.playAnimation("prguse2", 550, 12, 0.12, true):addto(self.layers.obj, y + mapDef.tile.h)
		elseif type == mapDef.ET_Group5v5 then
			local imgid = "magic"
			local begin = 1630
			local frame = 6
			x, y = self.getMapPos(self, x, y)
			self.events[serverID] = m2spr.playAnimation(imgid, begin, frame, 0.08, true):opacity(153):addto(self.layers.obj, y + mapDef.tile.h)
		elseif type == mapDef.ET_WARFLAG then
			x, y = self.getMapPos(self, x, y)
			local paramArr = string.split(eventMsg, ";")
			local level = 0
			local cor = "red"
			local text = ""

			for k, v in ipairs(paramArr) do
				local param = string.split(v, ":")

				if param[1] == "Et_Lv" then
					level = tonumber(param[2])
				elseif param[1] == "Et_Name" then
					text = param[2]
				elseif param[1] == "Et_Color" then
					cor = param[2]
				end
			end

			local img = def.militaryEquip.getFlagImg(level, cor):add2(self.layers.obj, y + mapDef.tile.h):anchor(0.5, 0)
			local label = an.newLabel(text, 16, 1, {
				color = display.COLOR_WHITE,
				sc = display.COLOR_BLACK
			}):add2(img):anchor(0.5, 0.5):pos(img.getw(img)/2, img.geth(img)/2)

			label.setGlobalZOrder(label, mapDef.topTag)

			self.events[serverID] = img
		end
	end

	if self.events[serverID] then
		self.events[serverID]:pos(x, y + mapDef.tile.h)
	end

	return 
end
map.hideEvent = function (self, serverID)
	if self.events[serverID] then
		self.events[serverID]:removeSelf()

		self.events[serverID] = nil
	end

	if self.yantongs[serverID] then
		self.yantongs[serverID].spr:removeSelf()

		self.yantongs[serverID].spr = nil
		self.yantongs[serverID] = nil
	end

	return 
end
map.removeStall = function (self, serverID)
	return 
end
map.getHeroNameList = function (self)
	local ret = {}

	for k, v in pairs(self.heros) do
		if not v.isPlayer and v.info:getName() and not v.info:isHero() and not v.isDummy then
			ret[#ret + 1] = v.info:getName()
		end
	end

	return ret
end
map.getHeroInfoList = function (self)
	local ret = {}

	for k, v in pairs(self.heros) do
		if not v.isPlayer and not v.info:isHero() and not v.isDummy then
			local record = {
				FName = v.info:getName(),
				FSex = v.sex,
				FJob = v.job,
				FLevel = v.level,
				FGuildName = v.guildName,
				FUserId = tonumber(k)
			}
			ret[#ret + 1] = record
		end
	end

	return ret
end
map.addTile = function (self, x, y)
	self.readyTiles[self.xy2key(self, x, y)] = {
		x,
		y
	}

	return 
end
map.processTile = function (self, x, y)
	if not self.tiles[x] then
		self.tiles[x] = {}
	end

	if not self.tiles[x][y] then
		self.tiles[x][y] = maptile.new(self, x, y)

		return true
	end

	return 
end
map.processTiles = function (self, dt)
	local cnt = 0

	for k, v in pairs(self.readyTiles) do
		self.readyTiles[k] = nil

		if self.processTile(self, v[1], v[2]) then
			cnt = cnt + 1

			if mapDef.loadNum < cnt then
				return 
			end
		end
	end

	if self.gray then
		self.setGrayState(self)
	end

	return 
end
map.clearTiles = function (self)
	local x = self.player.x
	local y = self.player.y
	local dis = math.floor(display.width/mapDef.tile.w) + mapDef.loadOutsideAreaBottom*2

	for k, v in pairs(self.tiles) do
		for k2, v2 in pairs(v) do
			if dis < math.abs(x - k) or dis < math.abs(y - k2) then
				v2.remove(v2)

				self.tiles[k][k2] = nil
			end
		end
	end

	for k, v in pairs(self.readyTiles) do
		if dis < math.abs(x - v[1]) or dis < math.abs(y - v[2]) then
			self.readyTiles[k] = nil
		end
	end

	return 
end
local protoId2Name = {
	[SM_WALK] = "SM_WALK",
	[SM_RUN] = "SM_RUN",
	[SM_SPELL] = "SM_SPELL",
	[SM_Turn] = "SM_Turn"
}
local hitProtoId2Name = {
	[AttackType.ATT_HIT] = "AttackType.ATT_HIT",
	[AttackType.ATT_HIT] = "ATT_HIT",
	[AttackType.ATT_HEAVYHIT] = "ATT_HEAVYHIT",
	[AttackType.ATT_BIGHIT] = "ATT_BIGHIT",
	[AttackType.ATT_POWERHIT] = "ATT_POWERHIT",
	[AttackType.ATT_LONGHIT] = "ATT_LONGHIT",
	[AttackType.ATT_WIDEHIT] = "ATT_WIDEHIT",
	[AttackType.ATT_FIREHIT] = "ATT_FIREHIT",
	[AttackType.ATT_UNITEHIT0] = "ATT_UNITEHIT0",
	[AttackType.ATT_UNITEHIT1] = "ATT_UNITEHIT1",
	[AttackType.ATT_UNITEHIT2] = "ATT_UNITEHIT2",
	[AttackType.ATT_SQUARE_HIT] = "ATT_SQUARE_HIT",
	[AttackType.ATT_FOURFIREHIT] = "ATT_FOURFIREHIT",
	[AttackType.ATT_SWORD_HIT] = "ATT_SWORD_HIT"
}
map.addMsg = function (self, params)
	if 0 < DEBUG and g_data.openOtherMoveLog then
		local protoName = protoId2Name[params.ident] or hitProtoId2Name[params.ident]

		if protoName and 4000000000.0 < tonumber(params.roleid) then
			local curTime = socket.gettime()

			p2("net", "receive rsb " .. protoName .. ", curTime: " .. math.ceil(curTime*1000) .. " -- roleid: " .. params.roleid)
		end
	end

	if params.remove then
		local tmpList = newList()

		while not self.msgs.isEmpty() do
			local msg = self.msgs.popFront()

			if msg.roleid ~= params.roleid then
				tmpList.pushBack(msg)
			end
		end

		self.msgs = tmpList

		self.removeRole(self, params.roleid)

		return 
	end

	self.msgs.pushBack(params)

	return 
end
map.processMsg = function (self, v)
	if v.roleid then
		local role, isNewCreate = self.findRole(self, v.roleid, v)

		if role then
			if v.ident then
				role.processMsg(role, v.ident, v.x, v.y, v.dir, v.feature, v.state, v.roleParams)
			end

			if v.job then
				role.job = v.job
			end

			if v.guildName then
				role.guildName = v.guildName
			end

			if v.name then
				local race = role.getRace(role)

				if race ~= 98 and (race ~= 153 or false) then
					role.info:setName(v.name)
				end
			end

			if v.honourTitleIDArr then
				local race = role.getRace(role)

				if race ~= 98 and (race ~= 153 or false) then
					table.sort(v.honourTitleIDArr)

					local titles = {}

					for hi, hv in pairs(v.honourTitleIDArr) do
						if def.honortitle and def.honortitle[hv] then
							titles[hi] = def.honortitle[hv].Name
						end
					end

					role.info:setTitle(titles, true)
				end
			end

			if v.bufftype then
				local race = role.getRace(role)

				if race ~= 98 and (race ~= 153 or false) then
					if v.bufftype == 0 then
						role.info:removeAllBuffType()
					else
						role.info:removeAllBuffType()
						role.info:addBuffType(v.bufftype)
					end
				end
			end

			while true do
				if role.__cname == "hero" then
					local pName = role.info:getName()
					local attData = g_data.relation:getAttention(pName)

					if attData then
						local colorIdx = attData.FFocusColor

						role.info:setNameColor(colorIdx)

						if v.nameColor then
							attData.realNameColor = v.nameColor
						end

						break
					end
				end

				if v.nameColor then
					role.info:setNameColor(v.nameColor)
				end

				break
			end

			if v.hp and v.maxhp then
				role.info:setHP(v.hp, v.maxhp, v.outhp, v.flag)
			end

			if v.effectId then
				role.info:setDamageEffect(v.effectId)
			end

			if v.skillEffectId then
				role.info:setskillEffect(v.skillEffectId)
			end

			if isNewCreate and v.roleid == g_data.hero.roleid then
				self.player.hero = role
			end
		else
			p2("error", "map:processMsg ------ role is nil!!!", v.roleid, v.ident)
		end
	end

	if v.magic then
		self.showMagic(self, unpack(v.magic))
	end

	if v.effect then
		self.showEffectForName(self, v.effect[1], v.effect[2])
	end

	return 
end
map.processMsgs = function (self, dt)
	local begin = socket.gettime()

	while not self.msgs.isEmpty() do
		self.processMsg(self, self.msgs.popFront())

		if 0.01 < socket.gettime() - begin then
			break
		end
	end

	return 
end
map.update = function (self, dt)
	self.processTiles(self, dt)
	self.processMsgs(self, dt)

	local roleSize = def.role.size
	local infoUpdate = roleInfo.update
	local roleUpdate = role.update
	local uptIsIgnore = role.uptIsIgnore
	local getPosition = role.getPosition
	local effectUpdate = roleInfo.effectUpdate
	local skillEffectUpdate = roleInfo.skillEffectUpdate
	local rnum = 0

	for k, roles in ipairs({
		self.heros,
		self.npcs,
		self.mons
	}) do
		for k, v in pairs(roles) do
			if 0 < #v.acts or v.isPlayer then
				rnum = rnum + 1

				roleUpdate(v, dt)
			end

			if v.info.dirty then
				infoUpdate(v.info, dt)
			end

			if 0 < #v.info.effects then
				effectUpdate(v.info, dt)
			end

			if 0 < #v.info.skillEffects then
				skillEffectUpdate(v.info, dt)
			end
		end
	end

	self.current_frame_updatedRoles = rnum

	return 
end
map.checkFlyTo = function (self, from, to)
	local i, adist, dist, dir = nil
	local x = from.x
	local y = from.y
	local tx = to.x
	local ty = to.y
	adist = math.abs(x - tx) + math.abs(y - ty)

	for i = 0, 8, 1 do
		dir = self.getNextDirection(self, x, y, tx, ty)
		local ok = nil
		x, y, ok = self.getNextPosition(self, x, y, dir, 1)

		if not ok or not self.canFly(self, x, y) then
			return false
		end

		if x == tx and y == ty then
			return true
		else
			dist = math.abs(x - tx) + math.abs(y - ty)

			if adist < dist then
				return true
			end
		end
	end

	return true
end
map.getNextDirection = function (self, x, y, tx, ty)
	local fx, fy = nil

	if x < tx then
		fx = 1
	elseif x == tx then
		fx = 0
	else
		fx = -1
	end

	if 2 < math.abs(y - ty) and tx - 1 <= x and x <= tx + 1 then
		fx = 0
	end

	if y < ty then
		fy = 1
	elseif y == ty then
		fy = 0
	else
		fy = -1
	end

	if 2 < math.abs(x - tx) and ty - 1 < y and y < ty + 1 then
		fy = 0
	end

	if fx == 0 and fy == -1 then
		return def.role.dir.up
	elseif fx == 1 and fy == -1 then
		return def.role.dir.rightUp
	elseif fx == 1 and fy == 0 then
		return def.role.dir.right
	elseif fx == 1 and fy == 1 then
		return def.role.dir.rightBottom
	elseif fx == 0 and fy == 1 then
		return def.role.dir.bottom
	elseif fx == -1 and fy == 1 then
		return def.role.dir.leftBottom
	elseif fx == -1 and fy == 0 then
		return def.role.dir.left
	elseif fx == -1 and fy == -1 then
		return def.role.dir.leftUp
	else
		return def.role.dir.up
	end

	return 
end
map.getNextPosition = function (self, nx, ny, dir, step)
	local x = nx
	local y = ny

	if dir == def.role.dir.up then
		if step - 1 < y then
			y = y - step
		end
	elseif dir == def.role.dir.rightUp then
		if step - 1 < x and y < self.h - step then
			x = x + step
			y = y - step
		end
	elseif dir == def.role.dir.right then
		if x < self.w - step then
			x = x + step
		end
	elseif dir == def.role.dir.rightBottom then
		if x < self.w - step and y < self.h - step then
			x = x + step
			y = y + step
		end
	elseif dir == def.role.dir.bottom then
		if y < self.h - step then
			y = y + step
		end
	elseif dir == def.role.dir.leftBottom then
		if x < self.w - step and step - 1 < y then
			x = x - step
			y = y + step
		end
	elseif dir == def.role.dir.left then
		if step - 1 < x then
			x = x - step
		end
	elseif dir == def.role.dir.leftUp and step - 1 < x and step - 1 < y then
		x = x - step
		y = y - step
	end

	return x, y, x ~= nx or y ~= ny
end
map.updateMarryName = function (self, roleid, marryname)
	local role = self.heros[roleid]

	if not role then
		return 
	end

	role.marryName = marryname

	role.info:setName(role.info.name.texts, true)

	return 
end

return map
