local current = ...
local autoRat = class("autoRat", function ()
	local tbl = {}

	return tbl
end)
local magic = import("..common.magic")
local common = import("..common.common")
local settingLogic = import("..common.settingLogic")
local mapDef = require("mir2.scenes.main.map.def")
local noAutoRatMap = def.noAutoRatMap
autoRat.current = current

table.merge(slot1, {})

autoRat.checkInterval = 0.1
autoRat.maxLoseAtkTime = 12
autoRat.maxTryCallPetTime = 10
autoRat.avoidInterval = 2
autoRat.amuletInterval = 3
autoRat.spellTime = 1
autoRat.maxActFail = 3
autoRat.closeAtkDis = 2
autoRat.rangeAtkDis = 9
autoRat.itemProperty = -10
autoRat.ctor = function (self, console)
	self.console = console
	self.pathFinder = import("..common.autoFindPath", current).new()
	self.checkedAtkCnt = 0
	self.roarTimer = 0
	self.tryCallPetTimer = 0
	self.lastExpUpdateTime = -1
	self.cntActFail = 0
	self.settings = g_data.setting.autoRat
	self.tempData = {}

	setmetatable(self.tempData, {
		__mode = "k"
	})

	return 
end
autoRat.setTaskMonsters = function (self, targets)
	self.taskMonsters = targets

	return 
end
autoRat.setTempData = function (self, target, key, value)
	if target then
		self.tempData[target] = self.tempData[target] or {}
		self.tempData[target][key] = value

		return true
	end

	return 
end
autoRat.tempMarkObject = function (self, target, key, time)
	if self.setTempData(self, target, key, true) then
		scheduler.performWithDelayGlobal(function ()
			self:setTempData(target, key, nil)

			return 
		end, slot3)
	end

	return 
end
autoRat.getTempData = function (self, target, key)
	return self.tempData[target] and self.tempData[target][key]
end
autoRat.isCanWalk = function (self, x, y)
	local map = main_scene.ground.map
	local block = map.canWalk(map, x, y).block

	if block then
		return false
	end

	local points = mapDef.doorPoint[map.mapid] or {}

	for k, v in pairs(points) do
		if v.x == x and v.y == y then
			return false
		end
	end

	return true
end
autoRat.isCanAutoRatMap = function (self, mapid)
	for i, v in ipairs(noAutoRatMap) do
		if tostring(v.map_id) == mapid then
			return false
		end
	end

	return true
end
autoRat.lowProperty = {
	蝙蝠 = 4
}

local function pStack(...)
	p2("autoRat", ...)

	return 
end

autoRat.updateModifyProperty = function (self)
	self.modifyProperty = {}
	local itemSettings = g_data.setting.item.filt or {}
	local items = def.items

	for k, v in pairs(items) do
		if type(v) == "table" and v.get then
			local itemName = v.get(v, "name")

			if itemName == "金币1" then
				itemName = "金币"
			end

			if settingLogic.isRattingItem(itemName) then
				self.modifyProperty[itemName] = autoRat.itemProperty
			end
		end
	end

	setmetatable(self.modifyProperty, {
		__index = autoRat.lowProperty
	})

	return 
end
autoRat.checkClose = function (self, target, closeTo)
	local player = main_scene.ground.player

	return self.pathFinder:checkClose(player.x, player.y, target.x, target.y, 400, false, closeTo)
end
autoRat.checkIsTaskMonster = function (self, mon)
	local name = self.mon.info:getName()
	slot3 = pair
	slot4 = self.taskMonsters or {}

	for k, v in slot3(slot4) do
		if v == name then
			return true
		end
	end

	return 
end

local function getDis(a, b)
	return math.max(math.abs(a.x - b.x), math.abs(a.y - b.y))
end

autoRat.checkMonster = function (self, mon)
	assert(self.atkRangeDis, "self.atkRangeDis is nil")

	if self.isTask and not self.checkIsTaskMonster(self, mon) then
		return false
	end

	local player = main_scene.ground.player

	if getDis(player, mon) < (self.getTempData(self, mon, "tempAttackRange") or self.atkRangeDis) then
		return true
	end

	return self.checkClose(self, mon, self.atkRangeDis)
end
autoRat.checkHero = function (self, hero)
	assert(self.atkRangeDis, "self.atkRangeDis is nil")

	local player = main_scene.ground.player

	if getDis(player, hero) < (self.getTempData(self, hero, "tempAttackRange") or self.atkRangeDis) then
		return true
	end

	return self.checkClose(self, hero, self.atkRangeDis)
end
autoRat.checkCanAtkHero = function (self)
	if g_data.map.state == 10 then
		return true
	end

	return false
end
autoRat.getNearestTarget = function (self, noItem)
	local targets = {}

	for k, v in pairs(main_scene.ground.map.mons) do
		local name = v.info:getName()

		if not v.die and not v.isPolice(v) and not v.isDummy and name and not string.find(name, "%(") and not self.getTempData(self, v, "tooStronger") and not self.getTempData(self, v, "cannotClose") then
			targets[#targets + 1] = v
		end
	end

	if self.checkCanAtkHero(self) then
		for k, v in pairs(main_scene.ground.map.heros) do
			if v.roleid ~= main_scene.ground.player.roleid and not v.die then
				targets[#targets + 1] = v
			end
		end
	end

	local player = main_scene.ground.player
	local modifyProperty = self.modifyProperty
	local items = main_scene.ground.map.items
	local itemSettings = g_data.setting.item.filt or {}
	local pickUpRatting = self.settings.pickUpRatting
	local pickGoodAttItem = g_data.setting.getGoodAttItemSetting() and g_data.setting.getGoodAttItemSetting().pickOnRatting

	if not noItem and pickUpRatting then
		local ability = g_data.player.ability

		for _, item in pairs(items) do
			local id1 = item.owner
			local id2 = player.roleid

			if item.owner == player.roleid and not self.getTempData(self, item, "cannotPick") and getDis(player, item) <= 10 then
				local itemName = item.itemName

				if 0 < g_data.bag:getFreeCount() or itemName == "金币" then
					if 0 < item.state and pickGoodAttItem then
						table.insert(targets, item)
					end

					if modifyProperty[itemName] then
						table.insert(targets, item)
					end
				end
			end
		end
	end

	table.sort(targets, function (a, b)
		local disA = getDis(player, a)

		if self:isEnemy(a) then
			disA = disA + (modifyProperty[a.info and a.info:getName()] or 0)

			if def.role.stateHas(a.last.state, "stStone") then
				disA = disA + 3
			end
		elseif 0 < a.state and pickGoodAttItem then
			disA = disA + autoRat.itemProperty
		else
			disA = disA + (modifyProperty[a.itemName] or 0)
		end

		local disB = getDis(player, b)

		if self:isEnemy(b) then
			disB = disB + (modifyProperty[b.info and b.info:getName()] or 0)

			if def.role.stateHas(b.last.state, "stStone") then
				disB = disB + 3
			end
		elseif 0 < b.state and pickGoodAttItem then
			disB = disB + autoRat.itemProperty
		else
			disB = disB + (modifyProperty[b.itemName] or 0)
		end

		return disA < disB
	end)

	for k, v in ipairs(slot2) do
		if v.__cname == "mon" then
			if not self.getTempData(self, v, "attacked") and self.settings.ignoreCripple and v.info.hp and v.info.hp.max ~= v.info.hp.cur then
				local preHp = v.info.hp.cur
				local handler = nil
				slot16 = scheduler.scheduleGlobal(function ()
					if not tolua.isnull(v.node) then
						if preHp == v.info.hp.cur then
							v.info.hp.cur = v.info.hp.max
						else
							return 
						end
					end

					scheduler.unscheduleGlobal(handler)

					return 
				end, 50)
				handler = slot16
			else
				local dis = getDis(player, v)
				local cls = self.checkMonster(self, v)

				if not cls then
					self.tempMarkObject(self, target, "cannotClose", 10)
				end

				if dis ~= 0 and (dis < self.atkRangeDis or cls) then
					return v
				end
			end
		elseif self.checkCanAtkHero(self) and self.isHero(self, v) then
			local dis = getDis(player, v)
			local cls = self.checkHero(self, v)

			if not cls then
				self.tempMarkObject(self, target, "cannotClose", 10)
			end

			if dis ~= 0 and (dis < self.atkRangeDis or cls) then
				return v
			end
		elseif (player.x == v.x and player.y == v.y) or self.checkClose(self, v) then
			return v
		end
	end

	return 
end
autoRat.isEnemy = function (self, target)
	if target and target.__cname == "mon" then
		return true
	elseif self.checkCanAtkHero(self) and self.isHero(self, target) then
		return true
	end

	return false
end
autoRat.isHero = function (self, target)
	return target and target.__cname == "hero"
end
autoRat.checkTarget = function (self)
	local target = self.target
	local nearestTarget = self.getNearestTarget(self, false, true)

	if target == nearestTarget then
		return target
	end

	if (target and not self.isEnemy(self, target)) or tolua.isnull(target and target.node) or not self.checkMonster(self, target) or not not target.die then
		if target and target.die then
			self.tempData[target.roleid] = nil
		end

		target = nearestTarget

		if self.isEnemy(self, target) and self.target ~= nearestTarget then
			self.preTargetHP = target.info.hp.max
			self.checkedAtkCnt = 0
		end
	elseif not nearestTarget then
		return target
	else
		local player = main_scene.ground.player

		if self.atkRangeDis <= getDis(player, target) then
			target = nearestTarget

			if self.isEnemy(self, target) then
				self.preTargetHP = target.info.hp.max
				self.checkedAtkCnt = 0
			end
		end
	end

	if self.target ~= target then
		self.checkedAtkCnt = 0
	end

	self.target = target

	return target
end
autoRat.isCloseAttack = function (self, skipAmulet)
	if g_data.player.job == 1 and self.settings.atkMagic.enable == nil and g_data.player:getMagic(1) and self.console:get("skill1") then
		self.settings.atkMagic.enable = true
		self.settings.atkMagic.magicId = 1
	end

	if not skipAmulet and self.settings.atkMagic.enable and self.settings.atkMagic.magicId == 48 then
		local data = g_data.player:getMagic(48)

		if not data then
			return true
		end

		if g_data.player.ability.FMP < data.FNeedMp then
			if g_data.client:checkLastTime("autoRatUseMagic", 1) then
				g_data.client:setLastTime("autoRatUseMagic", true)
				main_scene.ui:tip("没有足够的魔法点数")
			end

			return true
		end
	end

	return not self.settings.atkMagic.enable or not g_data.player:getMagic(self.settings.atkMagic.magicId) or self.settings.autoSkillAndAttack
end
autoRat.setAttackRange = function (self, range)
	assert(range)

	self.atkRangeDis = range

	return 
end
autoRat.enable = function (self, isTask)
	local mapid = main_scene.ground.map.replaceMapid or main_scene.ground.map.mapid

	if not self.isCanAutoRatMap(self, mapid) then
		main_scene.ui:tip("挑战地图不可挂机", 6)

		return 
	end

	common.stopAuto()

	self.isTask = isTask
	self.console.controller.autoFindPath.autoRatting = self.enableRat
	self._dt = 0
	self.checkedAtkCnt = 0
	self.roarTimer = 0
	self.tryCallPetTimer = 0
	self.avoidedDCnter = 0
	self.amuletAttack = 0
	self.lastExpUpdateTime = os.time()

	self.updateModifyProperty(self)

	if self.checkCanAtkHero(self) then
		main_scene.ui:tip("开启自动战斗")
	else
		main_scene.ui:tip("开启自动打怪")
	end

	self.enableRat = true

	main_scene.ground.player:showAutoRatHint()

	return 
end
autoRat.clearAllAct = function (self)
	self.console:setWidgetSelect("btnAutoRat", false)
	self.console:setWidgetSelect("btnAutoRat2", false)

	self.controller = self.console.controller
	local findPath = self.controller.autoFindPath

	findPath.multiMapPathStop(findPath)

	if not tolua.isnull(main_scene.ground.player.node) then
		main_scene.ground.player:hideAutoRatHint()
	end

	self.console.controller.move.enable = false
	self.target = nil
	local lock = self.controller.lock

	lock.setAttackTarget(lock, nil)

	return 
end
autoRat.stop = function (self)
	if self.enableRat then
		self.enableRat = false

		if self.checkCanAtkHero(self) then
			main_scene.ui:tip("自动战斗已关闭")
		else
			main_scene.ui:tip("自动打怪已关闭")
		end

		self.clearAllAct(self)

		self.isTask = false
	end

	return 
end
autoRat.getPets = function (self, petid)
	if petid == 30 then
		name = string.format("神兽(%s)", common.getPlayerName())
	elseif petid == 17 then
		name = string.format("变异骷髅(%s)", common.getPlayerName())
	else
		return false
	end

	local pets = {}

	for k, v in pairs(main_scene.ground.map.mons) do
		if not v.die and v.info:getName() == name then
			v.isPet = true

			table.insert(pets, v)
		end
	end

	return pets
end
autoRat.getRegionRoleCnt = function (self, pos, radio, type)
	local cnt = 0
	local map = main_scene.ground.map
	local roles = {}

	for x = -radio, radio, 1 do
		for y = -radio, radio, 1 do
			local role = map.findRoleWithPos(map, pos.x + x, pos.y + y, type)

			if role and not role.die then
				roles[#roles + 1] = role
				cnt = cnt + 1
			end
		end
	end

	return cnt, roles
end
autoRat.checkRoar = function (self)
	local setting = self.settings.autoRoar

	if setting.enable and g_data.player:getMagic(43) then
		local player = main_scene.ground.player

		if 0 < self.roarTimer then
			self.roarTimer = self.roarTimer - 1

			return 
		end

		local cnt = self.getRegionRoleCnt(self, player, 2, "mon")

		if setting.cnt <= cnt then
			self.roarTimer = setting.space/autoRat.checkInterval

			if self.useMagic(self, nil, 43) then
				return true
			end
		end
	end

	return 
end
autoRat.checkPets = function (self)
	local name, petid = nil

	if self.settings.autoPet.enable then
		petid = tonumber(self.settings.autoPet.magicId)
	else
		return false
	end

	if not g_data.player:getMagic(petid) then
		return false
	end

	if not g_data.player:hasSlave() then
		self.tryCallPetTimer = self.tryCallPetTimer - 1

		if autoRat.maxTryCallPetTime/2 < self.tryCallPetTimer then
			self.useMagic(self, nil, petid)

			return true
		elseif self.tryCallPetTimer < -autoRat.maxTryCallPetTime then
			self.tryCallPetTimer = autoRat.maxTryCallPetTime
		end
	end

	return 
end
autoRat.checkCureSelf = function (self)
	local setting = self.settings.autoCure

	if setting.enable then
		if not g_data.player:getMagic(setting.magicId) then
			return false
		end

		local player = main_scene.ground.player

		if not player.info.hp.cur then
			return 
		end

		local curHpPercent = player.info.hp.cur/player.info.hp.max

		if curHpPercent*100 <= setting.percent then
			return self.useMagic(self, player, setting.magicId)
		end
	end

	return false
end
autoRat.checkCurePet = function (self)
	local setting = self.settings.autoCurePet

	if setting.enable then
		if not g_data.player:getMagic(setting.magicId) then
			return false
		end

		for _, petid in ipairs({
			30,
			17
		}) do
			local pets = self.getPets(self, petid)

			for k, v in ipairs(pets) do
				if v.info and v.info.hp.cur and self.getTempData(self, v, "preHP") ~= v.info.hp.cur then
					local curHpPercent = v.info.hp.cur/v.info.hp.max

					if curHpPercent*100 <= setting.percent then
						self.setTempData(self, v, "preHP", v.info.hp.cur)

						return self.useMagic(self, v, setting.magicId)
					end
				end
			end
		end
	end

	return false
end
autoRat.checkPoison = function (self)
	local player = main_scene.ground.player
	local tar = self.target

	if self.settings.autoPoison and self.isEnemy(self, tar) and not tar.die and getDis(player, tar) <= autoRat.rangeAtkDis and g_data.player:getMagic(6) and not def.role.stateHas(tar.state, "stPoisonGreen") then
		local ret = self.useMagic(self, tar, 6)

		return ret
	end

	return 
end
autoRat.usePet = function (self, petid)
	self.petid = petid

	return 
end
autoRat.setMagic = function (self, magicid)
	local data = g_data.player:getMagic(magicid)

	if data then
		local skillLvl = g_data.player:getMagicLvl(magicid)
		local config = def.magic.getMagicConfigByUid(magicid, skillLvl)

		self.console.skills:select(tostring(magicID))
		self.console:call("lock", "useSkill", data, config)
	end

	return 
end
local explorer = class("explorer")
explorer.ctor = function (self, map, findPath, autoRater)
	self.map = map
	self.findPath = findPath
	self.autoRater = autoRater
	self.expDis = math.floor(math.pow(map.w + 5, 0.6))
	self.maxExplorePoints = (map.w*map.h)/math.pow(self.expDis*2, 2)*0.7
	self.points = {}
	self.complete = false

	return 
end
explorer._tryTarget = function (self, curPos, pos)
	local findPath = self.findPath

	if pos and self.autoRater:isCanWalk(pos.x, pos.y) then
		findPath.singleMapPathStop(findPath)
		findPath.searchForRun(findPath, curPos.x, curPos.y, pos.x, pos.y, nil, false, 1)

		if findPath.points and 0 < #findPath.points then
			self.preTargetPosition = pos

			return true
		end
	end

	return 
end
explorer.tryExploredPoints = function (self, curPos)
	local findPath = self.findPath

	for tryCnt = 1, 10, 1 do
		local index = math.random(#self.points)
		local pos = self.points[index]

		if self._tryTarget(self, curPos, pos) then
			return true
		end
	end

	return 
end
explorer.getNext = function (self, curPos)
	local findPath = self.findPath
	local pos = nil

	if not self.complete and self.maxExplorePoints <= #self.points then
		self._generatePatrolPath(self)
	end

	if self.preTargetPosition and self.expDis/2 < getDis(self.preTargetPosition, curPos) then
		pos = self.preTargetPosition
	elseif self.complete then
		if self.preTargetPosition then
			pos = self.preTargetPosition.next

			if not pos then
				pos = self.points[1]
			end
		elseif self.tryExploredPoints(self, curPos) then
			return 
		end
	end

	if not pos or not self._tryTarget(self, curPos, pos) then
		local startPos = curPos
		local dis = self.expDis
		local dbdis = dis*2

		for tryCnt = 1, 15, 1 do
			local x = math.random(-dbdis, dbdis)
			local y = math.random(-dbdis, dbdis)
			local pos = cc.p(startPos.x + x, startPos.y + y)
			local ok = true

			for k, v in ipairs(self.points) do
				if getDis(v, pos) < dis then
					local index = math.random(#self.points)
					startPos = self.points[index]
					ok = false

					break
				end
			end

			if ok and self._tryTarget(self, curPos, pos) then
				self.addNewPos(self, pos)

				return 
			end
		end
	else
		return 
	end

	self.tryExploredPoints(self, curPos)

	return 
end
explorer._generatePatrolPath = function (self)
	if self.complete then
		return 
	end

	local findPath = self.findPath

	local function generater()
		local ignore = {}
		local cur = nil

		for index, _ in ipairs(self.points) do
			cur = cur or _
			ignore[cur] = true
			local min = 99999999
			local minPoint = nil

			for _, pos in ipairs(self.points) do
				local dis = getDis(cur, pos)

				if dis and not ignore[pos] and dis < min then
					min = dis
					minPoint = pos
				end
			end

			if minPoint then
				cur.next = minPoint
				minPoint.pre = cur
				cur = minPoint
			end
		end

		self.complete = true
		self.co_patrolPathGenerater = nil

		return 
	end

	slot2()

	return 
end
explorer.addNewPos = function (self, pos)
	table.insert(self.points, pos)

	return 
end
autoRat.reExpore = function (self)
	local findPath = self.controller.autoFindPath

	if findPath.points and 0 < #findPath.points then
		findPath.points = nil
	end

	self.explore(self)

	return 
end
autoRat.explore = function (self)
	local findPath = self.controller.autoFindPath
	local lock = self.controller.lock

	lock.setAttackTarget(lock, nil)

	if findPath.points and 0 < #findPath.points then
		return 
	end

	local map = main_scene.ground.map
	local player = main_scene.ground.player

	if map.mapid ~= self.curmapid then
		self.curmapid = map.mapid
		self.explorer = explorer.new(map, findPath, self)
	end

	self.explorer:getNext(player)

	return 
end
autoRat.checkAttackRange = function (self)
	local dis = nil
	local player = main_scene.ground.player
	local atkMagic = self.settings.atkMagic

	if self.isCloseAttack(self) then
		dis = 2
	else
		dis = self.atkRangeDis
	end

	if atkMagic and atkMagic.enable and g_data.player:getMagic(atkMagic.magicId) then
		if checkExist(atkMagic.magicId, 1, 5, 13) then
			local map = main_scene.ground.map

			if not map.checkFlyTo(map, player, self.target) then
				self.setTempData(self, self.target, "tempAttackRange", 2)

				dis = 2
			else
				self.setTempData(self, self.target, "tempAttackRange", dis)
			end
		end

		if 3 < dis and def.role.stateHas(self.target.last.state, "stStone") then
			dis = 3
		end
	end

	self.setAttackRange(self, dis)

	return 
end
autoRat.closeToTarget = function (self)
	local dis = nil
	local tar = self.target
	local player = main_scene.ground.player

	if self.isEnemy(self, self.target) then
		self.checkAttackRange(self)

		dis = self.atkRangeDis
	end

	local findPath = self.controller.autoFindPath

	findPath.singleMapPathStop(findPath)

	if dis then
		if math.abs(player.x - tar.x) < dis and math.abs(player.y - tar.y) < dis then
			return true
		end
	elseif player.x == tar.x and player.y == tar.y then
		return true
	end

	local lock = self.controller.lock

	lock.setAttackTarget(lock, nil)
	findPath.searchForRun(findPath, player.x, player.y, tar.x, tar.y, nil, false, dis)

	return false
end
autoRat.useMagic = function (self, target, magicId)
	local lock = self.controller.lock

	if target then
		lock.setSkillTarget(lock, target)
	else
		target = main_scene.ground.player
	end

	local function filterBtnSkills(skillId)
		local flag = false

		if main_scene.ui.console:get("skill" .. skillId) ~= nil then
			flag = true
		end

		return flag
	end

	local data = g_data.player.getMagic(slot5, magicId)

	if not data then
		if g_data.client:checkLastTime("autoRatUseMagic", 1) then
			g_data.client:setLastTime("autoRatUseMagic", true)
			main_scene.ui:tip("挂机技能不可用!请打开设置界面重新设置")
		end

		return false
	end

	if g_data.player.ability.FMP < data.FNeedMp then
		if g_data.client:checkLastTime("autoRatUseMagic", 1) then
			g_data.client:setLastTime("autoRatUseMagic", true)
			main_scene.ui:tip("没有足够的魔法点数")
		end

		return false
	end

	self.setMagic(self, magicId)
	self.controller:useMagic(target.x, target.y, nil, data)

	local player = main_scene.ground.player

	return true
end
autoRat.isCdAndLongCdMagic = function (self, magicId)
	local longCds = {
		64
	}

	if magicId and table.keyof(longCds, magicId) and g_data.player:getMagic(magicId) then
		local data = g_data.player:getMagic(magicId)

		if data.iscdBegin then
			return true
		end
	end

	return false
end
autoRat.attackUseMagic = function (self)
	local tar = self.target

	if tar.die then
		return false
	end

	if g_data.player.job == 1 then
		local areaMagic = self.settings.areaMagic

		if areaMagic.enable and areaMagic.magicId and g_data.player:getMagic(areaMagic.magicId) then
			local cnt, roles = self.getRegionRoleCnt(self, tar, 1, "mon")

			if areaMagic.cnt <= cnt then
				for k, v in pairs(roles) do
					if not v.info.hp.cur or v.info.hp.cur == v.info.hp.max then
						self.setTempData(self, v, "attacked", true)
					end
				end

				if not self.isCdAndLongCdMagic(self, areaMagic.magicId) then
					self.useMagic(self, tar, areaMagic.magicId)

					return true
				end
			end
		end
	end

	local atkMagic = self.settings.atkMagic

	if atkMagic.enable and atkMagic.magicId and g_data.player:getMagic(atkMagic.magicId) then
		local sklDis = 10

		self.useMagic(self, tar, atkMagic.magicId)

		return true
	end

	return 
end
autoRat.attack = function (self)
	local tar = self.target

	if tar.die then
		return false
	end

	local lock = self.controller.lock

	lock.setAttackTarget(lock, tar)

	local player = main_scene.ground.player

	if self.settings.atkMagic.enable and self.amuletAttack <= 0 then
		if player.canNextSpell(player, self.settings.atkMagic.magicId) then
			self.useMagic(self, tar, self.settings.atkMagic.magicId)
		end

		if player.isLocked(player) then
			self.amuletAttack = autoRat.amuletInterval

			return true
		end
	end

	if not player.canNextHit(player) then
		return true
	end

	self.controller:attackRole(main_scene.ground.map, player, tar)

	self.amuletAttack = self.amuletAttack - 1

	return true
end
autoRat.pickUpItem = function (self)
	local tar = self.target

	if self.picking then
		return true
	end

	local player = main_scene.ground.player
	local map = main_scene.ground.map

	if not self.isEnemy(self, tar) and player.x == tar.x and player.y == tar.y then
		self.picking = true

		scheduler.performWithDelayGlobal(function ()
			self.picking = false

			if map.items and map.items[tar.itemid] then
				self:setTempData(tar, "cannotPick", true)

				self.target = nil

				scheduler.performWithDelayGlobal(function ()
					if map.items ~= nil and not map.items[tar.itemid] then
						self:setTempData(tar, "cannotPick", nil)
					end

					return 
				end, 15)
			end

			return 
		end, 2)

		return true
	end

	return 
end
autoRat.checkHit = function (self)
	local target = self.target

	if target.info.hp.cur == self.preTargetHP then
		local player = main_scene.ground.player

		if player.isLocked(player) then
			self.checkedAtkCnt = self.checkedAtkCnt + 1
		end

		if autoRat.maxLoseAtkTime < self.checkedAtkCnt then
			self.tempMarkObject(self, target, "tooStronger", 30)

			self.target = nil
		end
	else
		self.checkedAtkCnt = 0
		self.preTargetHP = target.info.hp.cur
	end

	return 
end
autoRat.useItem = function (self, itemName)
	local item = g_data.bag:getItemWithName(itemName)

	if item then
		g_data.bag:use("eat", item.FItemIdent, {
			quick = true
		})
		sound.play("item", item)

		local rsb = DefaultClientMessage(CM_EAT)
		rsb.FItemIdent = item.FItemIdent
		rsb.FUseType = 0

		MirTcpClient:getInstance():postRsb(rsb)
		g_data.bag:delItem(item.FItemIdent)

		if g_data.bag:delItem(makeIndex) and self.panels.bag then
			self.panels.bag:delItem(makeIndex)
		end
	end

	return 
end
autoRat.checkAvoid = function (self)
	if not self.isEnemy(self, self.target) then
		return 
	end

	if self.settings.atkMagic.enable then
		if 0 < self.avoidedDCnter then
			self.avoidedDCnter = self.avoidedDCnter - 1

			return 
		end

		local player = main_scene.ground.player
		local nearObjsPos = {}
		local nearObjsDir = {}
		local map = main_scene.ground.map
		minDis = 4

		for k, v in pairs(map.mons) do
			local name = v.info:getName()
			local disX = math.abs(player.x - v.x)
			local disY = math.abs(player.y - v.y)
			local dis = math.max(disX, disY) + (self.modifyProperty[v.info:getName()] or 0)

			if not v.die and not v.isPolice(v) and not v.isDummy and (not name or not string.find(name, "%(")) and dis < 4 then
				if dis < minDis then
					minDis = dis
				end

				local dir = def.role.getMoveDir(player.x, player.y, v.x, v.y)

				if dir == nil then
					dir = v.dir
				end

				nearObjsDir[dir] = (nearObjsDir[dir] or 0) + dis/4
			end
		end

		if 2 < minDis then
			return 
		end

		local wDirs = {}

		for k = 0, 7, 1 do
			local cnt = nearObjsDir[k] or 0.01
			wDirs[k] = cnt/1
		end

		local goodDirs = {}

		for k = 0, 7, 1 do
			goodDirs[k] = (wDirs[(k + 7)%8] or 0)/3 + (wDirs[(k + 1)%8] or 0)/3 + wDirs[k]
		end

		local max = 0
		local dir = 0

		for k, v in pairs(goodDirs) do
			local config = def.role.dir["_" .. k]

			if not self.isCanWalk(self, player.x + config[1], player.y + config[2]) then
				v = 0
			elseif not self.isCanWalk(self, player.x + config[1]*2, player.y + config[2]*2) then
				v = v*0.4
			elseif not self.isCanWalk(self, player.x + config[1]*3, player.y + config[2]*3) then
				v = v*0.6
			elseif not self.isCanWalk(self, player.x + config[1]*4, player.y + config[2]*4) then
				v = v*0.8
			end

			if max < v then
				max = v
				dir = k
			elseif max == v and math.random() < 0.5 then
				dir = k
			end
		end

		local config = def.role.dir["_" .. dir]

		if not self.isCanWalk(self, player.x + config[1], player.y + config[2]) then
			self.controller.move.enable = false

			return false
		end

		step = 2

		if not self.isCanWalk(self, player.x + config[1]*2, player.y + config[2]*2) then
			step = 1
		end

		self.controller.move.enable = "dir"
		self.controller.move.dir = dir
		self.controller.move.step = step
		self.avoidedDCnter = autoRat.avoidInterval

		return true
	end

	return 
end
autoRat.checkAutoSpaceMove = function (self)
	local setting = self.settings.autoSpaceMove

	if setting.enable then
		if self.lastExpUpdateTime <= 0 then
			self.lastExpUpdateTime = os.time()

			return 
		end

		local curtime = os.time()

		if curtime - self.lastExpUpdateTime < setting.space*60 then
			return false
		end

		self.lastExpUpdateTime = os.time()

		self.useItem(self, setting.use)

		return true
	end

	return 
end
autoRat.onExpUpdate = function (self)
	self.lastExpUpdateTime = os.time()

	return 
end
autoRat.onActFail = function (self, x, y, dir)
	self.cntActFail = self.cntActFail + 1

	if autoRat.maxActFail < self.cntActFail then
		local player = main_scene.ground.player
		local cnt, mon = self.getRegionRoleCnt(self, player, 1, "mon")

		for k, v in pairs(mon) do
			self.tempMarkObject(self, v, "tooStronger", 6)
		end

		self.tempMarkObject(self, self.target, "tooStronger", 6)

		self.target = nil
		self.cntActFail = 0
	end

	return 
end
autoRat.onActGood = function (self, x, y, dir)
	self.cntActFail = 0

	return 
end
autoRat.updateAttackRange = function (self, skipAmulet)
	if self.isCloseAttack(self, skipAmulet) then
		self.setAttackRange(self, autoRat.closeAtkDis)
	else
		self.setAttackRange(self, autoRat.rangeAtkDis)
	end

	return 
end
autoRat.executeTest = function (self, dt)
	if not self.enableRat then
		return 
	end

	local player = main_scene.ground.player

	if 0 < DEBUG and not tolua.isnull(main_scene.ui.panels.bigmap) and self.explorer and self.explorer.points then
		main_scene.ui.panels.bigmap:loadFlagPoints("explore", self.explorer.points, (self.explorer.complete and cc.c4b(0, 255, 255, 255)) or cc.c4b(0, 255, 0, 255))
	end

	if def.role.isRoleStone(player.state) then
		return 
	end

	if tolua.isnull(main_scene) then
		self.enable(self)

		return 
	end

	self.controller = self.console.controller
	self.controller.move.enable = false

	self.updateAttackRange(self, false)

	if (g_data.player.job ~= 0 or not self.checkRoar(self)) and (g_data.player.job ~= 2 or (not self.checkPets(self) and not self.checkCureSelf(self) and not self.checkCurePet(self) and (not self.checkPoison(self) or false))) then
		if self.checkTarget(self) then
			self.updateAttackRange(self, true)

			if self.closeToTarget(self) then
				if self.isEnemy(self, self.target) then
					self.setTempData(self, self.target, "attacked", true)

					if self.isCloseAttack(self) then
						self.attack(self)
					else
						self.attackUseMagic(self)
					end

					self.checkHit(self)
				elseif self.pickUpItem(self) then
				end
			end
		else
			self.explore(self)
		end
	end

	self.checkAutoSpaceMove(self)

	if player.isLocked(player) then
		return true
	elseif not self.isCloseAttack(self) then
		self.checkAvoid(self)
	end

	return 
end

return autoRat
