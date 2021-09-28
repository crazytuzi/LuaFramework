local magic = import("..magic")
local mapDef = require("mir2.scenes.main.map.def")
local autoFindPath = import("..autoFindPath")
local util = import(".util")
local common = import("..common")
dummy = class("dummy", function ()
	local obj = {}

	setmetatable(obj, {
		__index = function (_, k)
			return obj.role[k]
		end
	})

	return obj
end)
util.dummy = dummy

table.merge(dummy, {})

dummy.roleid = 1
dummy.say_default_bgColor = cc.c4b(150, 84, 13, 100)
dummy.say_default_fontSize = 17
dummy.say_default_strWidth = 300
dummy.say_default_duration = 4
dummy.setEvtCallback = function (func)
	rawset(dummy, "evtCallback", func)

	if main_scene and not main_scene.ground.helper:isHiding() then
		main_scene.ground.helper.obj.evtCallback_ = func
	end

	return 
end
dummy.getEvtCallback = function ()
	return rawget(dummy, "evtCallback")
end
dummy.setRunner = function (runner)
	rawset(dummy, "runner", runner)

	return 
end
dummy.getMap = function ()
	return dummy.runner.getMap()
end
dummy.WALK_INTERVAL = 0.7
dummy.FOLLOW_DISTANCE = 4
dummy.FOLLOW_DISTANCE_LIMIT = 20
dummy.GUIDE_DISTANCE_LIMIT = 7
dummy.GUIDE_DEFAULT_TIP = "∏˙Œ“¿¥"
dummy.acts = {
	WALK = SM_WALK,
	RUN = SM_RUN,
	TURN = SM_TURN,
	BACKSTEP = SM_BACKSTEP,
	DEATH = SM_DEATH,
	NOWDEATH = SM_NOWDEATH,
	HIT = SM_HIT,
	HEAVYHIT = SM_HEAVYHIT,
	BIGHIT = SM_BIGHIT,
	POWERHIT = SM_POWERHIT,
	LONGHIT = SM_LONGHIT,
	WIDEHIT = SM_WIDEHIT,
	FIREHIT = SM_FIREHIT,
	FOURFIREHIT = SM_4FIREHIT,
	HERO_LONGHIT = SM_HERO_LONGHIT,
	HERO_LASTHIT = SM_HERO_LASTHIT,
	SWORD_HIT = SM_SWORD_HIT,
	RUSH = SM_RUSH,
	RUSHKUNG = SM_RUSHKUNG,
	STRUCK = SM_STRUCK,
	SKELETON = SM_SKELETON,
	DIGUP = SM_DIGUP,
	DIGDOWN = SM_DIGDOWN,
	ALIVE = SM_ALIVE,
	SPACEMOVE_SHOW = SM_SPACEMOVE_SHOW,
	FLYAXE = SM_FLYAXE,
	BUTCH = SM_BUTCH,
	SPELL = SM_SPELL,
	HERO_LOGON = SM_HERO_LOGON,
	UNITEHIT0 = SM_UNITEHIT0,
	UNITEHIT1 = SM_UNITEHIT1,
	UNITEHIT2 = SM_UNITEHIT2,
	FEATURECHANGED = SM_FEATURECHANGED
}
dummy.state = {
	stOpenHealth = "stOpenHealth",
	csAssCritHit = "csAssCritHit",
	csAttPoisonMove = "csAttPoisonMove",
	csDingShen = "csDingShen",
	stHidden = "stHidden",
	stStone = "stStone",
	csRelive = "csRelive",
	stPoisonYellow = "stPoisonYellow",
	csTmpSSk = "csTmpSSk",
	csTmpStrength = "csTmpStrength",
	csTmpQR = "csTmpQR",
	stPoisonGreen = "stPoisonGreen",
	csVioletPoision = "csVioletPoision",
	StSskTaoist = "StSskTaoist",
	StDzxyFull = "StDzxyFull",
	csNil_47 = "csNil_47",
	csNoDieState = "csNoDieState",
	stPoisonRed = "stPoisonRed",
	stZeroShield = "stZeroShield",
	StBlueDiamond = "StBlueDiamond",
	stBloodWarrior = "stBloodWarrior",
	stNil_UsedByClient = "stNil_UsedByClient",
	stHackQuest = "stHackQuest",
	stWEBS = "stWEBS",
	csTmpMaxHP = "csTmpMaxHP",
	csAttYLB = "csAttYLB",
	csWJD = "csWJD",
	csWJZQ = "csWJZQ",
	csTmpHQ = "csTmpHQ",
	csBurn = "csBurn",
	csDominateBuf = "csDominateBuf",
	csNil_48 = "csNil_48",
	csTmpSC = "csTmpSC",
	csHMSF = "csHMSF",
	csTmpNearHit = "csTmpNearHit",
	csSXSL = "csSXSL",
	csBleeding = "csBleeding",
	csTmpMC = "csTmpMC",
	csHorseRider = "csHorseRider",
	csZaiMaShang = "csZaiMaShang",
	csAssXJRS = "csAssXJRS",
	csNB = "csNB",
	stPoisonStone = "stPoisonStone",
	stReleaseStone = "stReleaseStone",
	stDenyMagic = "stDenyMagic",
	stMACShield = "stMACShield",
	csTmpDC = "csTmpDC",
	stFreeze = "stFreeze",
	stHeroLongHit = "stHeroLongHit",
	stJFBF = "stJFBF",
	stDragonState = "stDragonState",
	csDurativeVioletDmg = "csDurativeVioletDmg",
	csTmpMAC = "csTmpMAC",
	csTmpUnion = "csTmpUnion",
	csRevenge = "csRevenge",
	csTmpDCSpeed = "csTmpDCSpeed",
	StSskWizard = "StSskWizard",
	csDecTmpDefence = "csDecTmpDefence",
	csNoDamage = "csNoDamage",
	csZLHT = "csZLHT",
	csTmpAM = "csTmpAM",
	csJinghun = "csJinghun",
	stPoisonFuchsia = "stPoisonFuchsia",
	StYellowDiamond = "StYellowDiamond",
	stManaProtected = "stManaProtected",
	csPoisonMove = "csPoisonMove",
	csRealHide = "csRealHide",
	csTmpMaxMP = "csTmpMaxMP",
	stACShield = "stACShield",
	csDurativeSdsDmg = "csDurativeSdsDmg",
	csAssLK = "csAssLK",
	stMagicShieldEx = "stMagicShieldEx",
	stAlwaysShowName = "stAlwaysShowName",
	csTmpAC = "csTmpAC",
	csAttHLKW = "csAttHLKW",
	stMagicShield = "stMagicShield",
	csAssRXPK = "csAssRXPK",
	csTmpCC = "csTmpCC",
	csLieHun = "csLieHun",
	stAutoLFTrain = "stAutoLFTrain",
	csDominaterPet = "csDominaterPet",
	stPoisonBlue = "stPoisonBlue"
}
dummy.ctor = function (self, name, race, dress, weapon, sex, hair, offset, realPos, time)
	if type(name) == "table" then
		local name = params.name
		local race = params.race
		local dress = params.dress
		local weapon = params.weapon
		local sex = params.sex
		local hair = params.hair
		local offset = params.offset
		local realPos = params.pos
		slot18 = params.time or 5
		name = name or ""
	end

	local roleid = name .. dummy.roleid
	dummy.roleid = dummy.roleid + 1
	self.evtCallback_ = dummy.evtCallback

	if race == nil or race == "hero" then
		race = 0
		self.dressid = dress or 0
		self.weaponid = weapon or 0
		local items = def.items
		local dressData = items[dress]

		if dressData then
			dress = dressData.shape
		end

		local weaponData = items[weapon]

		if weaponData then
			weapon = weaponData.shape
		end
	end

	local feature = getRecord("TFeature")

	feature.set(feature, "race", race or 0)
	feature.set(feature, "sex", sex or 0)
	feature.set(feature, "dress", dress or 0)
	feature.set(feature, "weapon", weapon or 0)
	feature.set(feature, "hair", hair or 0)

	self.feature = feature
	local map = dummy.getMap()
	local model = self.getRoleModel(self)
	model.feature = feature
	model.roleid = roleid
	self.roleid = roleid

	if not realPos then
		if offset.off2 then
			model.y = offset.y
			model.x = offset.x
		else
			local offsetTo = map.player
			model.x = offsetTo.x + (offset and (offset.x or 1))
			model.y = offsetTo.y + (offset and (offset.y or 0))
		end
	else
		model.x = realPos.x
		model.y = realPos.y
	end

	model.name = name
	self.role = map.newRole(map, model)
	self.role.isDummy = true

	self.role.info:setName(name)

	self.role.name = name

	if time ~= nil and 0 < time then
		self.role.node:performWithDelay(handler(self, self.removeSelf), time)
	end

	self.pathFinder = autoFindPath.new()
	getmetatable(self).__newindex = function (t, k, v)
		if k == "walkFunc" then
			rawset(self, k, v)

			return 
		elseif k == "name" then
			self.role.info:setName(tostring(v))
		elseif (k ~= "clickCallback" or false) and k == "dir" then
			assert(v)

			if not self.role.node:isRunning() then
				self.role.last.dir = v
			end

			self.role:processMsg(SM_TURN, self.x, self.y, v, feature, state)
		end

		self.role[k] = v

		return 
	end

	return 
end
dummy.setName = function (self, name)
	self.role.info:setName(name)

	return 
end
dummy.actDelay = function (self, delay)
	return cca.delay(delay)
end
dummy.actAttack = function (self, skillIndex, offset, dir)
	return cca.callFunc(function ()
		self:attack(skillIndex, offset, dir)

		return 
	end)
end
dummy.actPlayAct = function (self, actid, offset, dir, feature, state)
	return cca.callFunc(function ()
		self:playAct(actid, offset, dir, feature, state)

		return 
	end)
end
dummy.actMagic = function (self, magicID, target, offset, dir)
	return cca.callFunc(function ()
		self:magic(magicID, target, offset, dir)

		return 
	end)
end
dummy.actRemoveSelf = function (self)
	return cca.callFunc(function ()
		self:removeSelf()

		return 
	end)
end
dummy.actAssign = function (self, key, value)
	return cca.callFunc(function ()
		self[key] = value

		return 
	end)
end
dummy.getRoleModel = function (self)
	local dir = def.role.dir.bottom
	local allBodyState = getRecord("TAllBodyState")

	return {
		dir = dir,
		state = allBodyState
	}
end
dummy.removeSelf = function (self)
	local map = dummy.getMap()

	if not tolua.isnull(map) and not tolua.isnull(self.role.node) then
		map.removeRole(map, self.role.roleid)
	end

	return 
end
dummy.addState = function (self, stateName)
	if tolua.isnull(self.role.node) then
		return 
	end

	local last = self.role.last

	def.role.addState(last.state, stateName)
	self.role:processMsg(SM_CHARSTATUSCHANGED, nil, nil, nil, last.state)

	return 
end
dummy.removeState = function (self, stateName)
	if tolua.isnull(self.role.node) then
		return 
	end

	local last = self.role.last

	def.role.removeState(last.state, stateName)
	self.role:processMsg(SM_CHARSTATUSCHANGED, nil, nil, nil, last.state)

	return 
end
dummy.say = function (self, text, bgColor, fontSize, strWidth, dur)
	if tolua.isnull(self.role.node) then
		return 
	end

	if type(text) == "table" and not bgColor then
		local params = text
		text = params.text
		bgColor = params.bgColor
		fontSize = params.fontSize
		strWidth = params.strWidth
	end

	bgColor = bgColor or self.say_default_bgColor
	local adapt = nil

	if type(bgColor) == "function" then
		adapt = bgColor
		bgColor = nil
	end

	local msg = {
		bgColor = 255,
		channel = "dummy",
		color = 0,
		data = {
			{
				str = text,
				bgColor = bgColor
			}
		},
		ident = SM_HEAR,
		target = self.name,
		user = self.name,
		adapt = adapt,
		duration = dur or self.say_default_duration,
		fontSize = fontSize or self.say_default_fontSize,
		strWidth = strWidth or self.say_default_strWidth
	}
	local info = self.role.info

	info.say(info, msg)
	common.addMsg(string.format("%s:%s", self.name, text), 255, bgColor, true, self.name)

	return 
end
dummy.sayDialogAdapt = function (node, digImg, offset)
	local sz = node.getContentSize(node)
	sz.width = sz.width + 20
	sz.height = sz.height + 35
	local w = sz.width

	if sz.height < 65 then
		sz.height = 65
	end

	if sz.width < 316 then
		sz.width = 316
	end

	local dig = display.newScale9Sprite(res.getframe2(digImg), 0, 0, sz):pos(offset.x, offset.y):anchor(0, 0)

	node.add2(node, dig):pos(sz.width/2, 25):anchor(0.5, 0)
	dig.setCapInsets(dig, cc.rect(20, 20, 10, 50))
	dig.setScale(dig, (g_data.setting.display.mapScale or 1.5)/1)

	local p = display.newNode()

	p.setContentSize(p, sz.width, sz.height)
	dig.add2(dig, p)

	return p
end
dummy.sayDL = function (self, text, fontSize, strWidth, dur)
	self.say(self, text, function (node)
		return dummy.sayDialogAdapt(node, "pic/helperScript/dialog_box.png", cc.p(20, -20))
	end, slot2, strWidth, dur)

	return 
end
dummy.sayDR = function (self, text, fontSize, strWidth, dur)
	self.say(self, text, function (node)
		return dummy.sayDialogAdapt(node, "pic/helperScript/dialog_box02.png", cc.p(75, -20))
	end, slot2, strWidth, dur)

	return 
end
dummy.createSayDL = function (texts, strWidth, fontSize)
	if type(texts) == "string" then
		texts = {
			texts
		}
	end

	local msg = {
		data = texts,
		strWidth = strWidth or dummy.say_default_strWidth,
		fontSize = fontSize or dummy.say_default_fontSize
	}
	local node = common.createChatLabel(msg)

	return dummy.sayDialogAdapt(node, "pic/helperScript/dialog_box.png", cc.p(40, 0))
end
dummy.createSayDR = function (texts, strWidth, fontSize)
	if type(texts) == "string" then
		texts = {
			texts
		}
	end

	local msg = {
		data = texts,
		strWidth = strWidth or dummy.say_default_strWidth,
		fontSize = fontSize or dummy.say_default_fontSize
	}
	local node = common.createChatLabel(msg)

	return dummy.sayDialogAdapt(node, "pic/helperScript/dialog_box02.png", cc.p(75, 0))
end
dummy.moveTo_ = function (self, pos)
	local myObj = self.role

	if myObj.x ~= pos.x or myObj.y ~= pos.y or false then
		local dir = util.getDir(myObj, pos)

		if cc.pGetDistance(cc.p(myObj.x, myObj.y), pos) < 2 then
			myObj.processMsg(myObj, SM_WALK, pos.x, pos.y, dir)
		else
			myObj.processMsg(myObj, SM_RUN, pos.x, pos.y, dir)
		end
	end

	return 
end
dummy.walkTo = function (self, x, y, mapid, tip, guideDis, maxDis, waitEvt, arriveEvt, faildEvt, unshowRoute)
	if tolua.isnull(self.role.node) then
		return 
	end

	if type(x) == "table" then
		local params = x
		x = params.x
		y = params.y
		mapid = params.mapid
		waitEvt = params.waitEvt
		arriveEvt = params.arriveEvt
		maxDis = params.maxDis
		unshowRoute = params.unshowRoute
	end

	if type(mapid) == "number" then
		mapid = "" .. mapid
	end

	if not unshowRoute then
		local size = def.role.size
		self.guideTipSpr = res.get2("pic/common/guideTip.png"):add2(self.role):pos(size.w/2, size.h + 25)

		self.guideTipSpr:setGlobalZOrder(self.role.node:getGlobalZOrder() + 1)
		self.guideTipSpr:runForever(transition.sequence({
			cc.MoveBy:create(1, cc.p(0, 15)),
			cc.MoveBy:create(1, cc.p(0, -15))
		}))
	end

	self.walkFunc = {
		function (...)
			self:walkTo_(x, y, mapid, tip, guideDis, maxDis, waitEvt, arriveEvt, faildEvt)

			if not unshowRoute then
				local myObj = self.role
				local map = dummy.getMap()
				local player = main_scene.ground.player

				self.pathFinder:singleMapPathStop()

				local routePoints = self.pathFinder:search(player.x, player.y, myObj.x, myObj.y, nil, true, true)
				local effect = res.getani2("pic/effect/followHelper/%d.png", 1, 6, 0.1)

				for k, off in ipairs(routePoints) do
					if off then
						local x, y = map.getMapPos(map, off.x, off.y)
						slot12 = display.newSprite():addto(map.layers.mid, y + mapDef.tile.h):pos(x + mapDef.tile.w/2, y + mapDef.tile.h/2):runs({
							cc.DelayTime:create(k*0.1),
							cc.Animate:create(effect),
							cc.RemoveSelf:create()
						})
					else
						break
					end
				end
			end

			return 
		end,
		{}
	}

	return 
end
dummy.walkTo_ = function (self, x, y, mapid, tip, guideDis, maxDis, waitEvt, arriveEvt, faildEvt)
	if tolua.isnull(self.role.node) then
		self.walkFunc = nil

		return 
	end

	local player = main_scene.ground.player
	local myObj = self.role
	local map = dummy.getMap()

	if mapid and map.mapid ~= mapid then
		if not tolua.isnull(self.guideTipSpr) then
			self.guideTipSpr:removeFromParent()
		end

		if type(faildEvt) == "function" then
			faildEvt("faild")
		elseif self.evtCallback_ and faildEvt then
			self.evtCallback_(faildEvt, self)
		end

		self.walkFunc = {
			self.followPlayer,
			{
				self
			}
		}

		return 
	end

	local dis = player.getDis(player, myObj)

	if (guideDis or dummy.GUIDE_DISTANCE_LIMIT) < dis then
		if (maxDis or dummy.FOLLOW_DISTANCE_LIMIT) < dis then
			myObj.processMsg(myObj, SM_SPACEMOVE_SHOW, player.x, player.y, 0)

			self.points = nil

			return 
		else
			if type(waitEvt) == "function" then
				waitEvt("wait")
			elseif self.evtCallback_ and waitEvt then
				self.evtCallback_(waitEvt, self)
			end

			return 
		end
	end

	if self.x == x and self.y == y then
		self.walkFunc = nil

		if not tolua.isnull(self.guideTipSpr) then
			self.guideTipSpr:removeFromParent()
		end

		if type(arriveEvt) == "function" then
			arriveEvt("arrive")
		elseif self.evtCallback_ and arriveEvt then
			self.evtCallback_(arriveEvt, self)
		end

		return 
	end

	if not self.points or #self.points == 0 then
		self.pathFinder:singleMapPathStop()

		local points = self.pathFinder:search(myObj.x, myObj.y, x, y, nil, true)

		if points then
			self.points = points
		else
			self.walkFunc = {
				self.followPlayer,
				{
					self
				}
			}

			return 
		end
	end

	table.remove(self.points, 1)

	local pos = self.points[1]

	if pos then
		self.moveTo_(self, pos)
	end

	if tip then
		self.say(self, tip)
	end

	return 
end
dummy.followPlayer = function (self, followDistance, distanceLimit)
	if tolua.isnull(self.role.node) then
		return 
	end

	if type(followDistance) == "table" then
		local params = followDistance
		followDistance = params.followDistance
		distanceLimit = params.distanceLimit
	end

	self.walkFunc = {
		dummy.followPlayer_,
		{
			self,
			followDistance or dummy.FOLLOW_DISTANCE,
			distanceLimit or dummy.FOLLOW_DISTANCE_LIMIT
		}
	}

	return 
end
dummy.followPlayer_ = function (self, followDistance, distanceLimit)
	local player = main_scene.ground.player
	local myObj = self.role
	local map = dummy.getMap()
	local dis = player.getDis(player, myObj)

	if dis < followDistance then
		return 
	end

	if dis <= distanceLimit then
		local x = player.x
		local y = player.y
		local points = self.pathFinder:search(myObj.x, myObj.y, x, y, math.pow(distanceLimit, 2), true, followDistance)

		if points then
			local pos = points[2]

			if pos then
				self.moveTo_(self, pos)
			end

			return 
		end
	end

	self.playAct(self, SM_SPACEMOVE_SHOW, util.off2p(1, 0), def.role.dir.bottom)

	return 
end
dummy.jumpToPlayer = function (self)
	local player = main_scene.ground.player
	self.points = nil

	self.playAct(self, SM_SPACEMOVE_SHOW, util.off2p(0, 0), 0)

	return 
end
dummy._showEvents = function (map, pos, type, delay)
	local ids = {}

	for k, v in pairs(pos) do
		local id = string.format("%d,%d", v.x, v.y)

		map.showEvent(map, id, v.x, v.y, type)
		table.insert(ids, id)
	end

	map.performWithDelay(map, function ()
		for k, v in ipairs(ids) do
			map:hideEvent(v)
		end

		return 
	end, slot3)

	return 
end
dummy.magic = function (self, magicID, target, offset, dir)
	if magicID == 4 then
		return 
	end

	if tolua.isnull(self.role.node) then
		return 
	end

	if type(magicID) == "table" then
		local params = magicID
		magicID = params.magicID
		target = params.target
		offset = params.offset
	end

	local noTarget = false

	if target == "player" then
		target = main_scene.ground.player
	elseif target == nil then
		if dir == def.role.dir.up then
			target = util.off2t(0, -1, self)
		elseif dir == def.role.dir.rightUp then
			target = util.off2t(1, -1, self)
		elseif dir == def.role.dir.right then
			target = util.off2t(1, 0, self)
		elseif dir == def.role.dir.rightBottom then
			target = util.off2t(1, 1, self)
		elseif dir == def.role.dir.bottom then
			target = util.off2t(0, 1, self)
		elseif dir == def.role.dir.leftBottom then
			target = util.off2t(-1, 1, self)
		elseif dir == def.role.dir.left then
			target = util.off2t(-1, 0, self)
		elseif dir == def.role.dir.leftUp then
			target = util.off2t(-1, -1, self)
		else
			noTarget = true
			target = self
		end
	end

	offset = offset or cc.p(0, 0)

	if util.inSet(magicID, {
		3,
		7,
		12,
		25,
		26,
		27,
		58,
		300,
		301
	}) then
		dir = dir or util.getDir(self, target)

		self.attack(self, magicID, offset, dir)

		return 
	end

	self.dir = dir or self.dir
	local map = dummy.getMap()
	local skill = def.magic.getMagicConfigByUid(magicID)
	local effectID = skill and skill.effectID

	if effectID then
		local params = {
			effect = {
				effectID = effectID - 1,
				magicId = magicID
			},
			targetX = target.x,
			targetY = target.y
		}

		self.role:processMsg(SM_SPELL, nil, nil, self.dir, nil, nil, params)
	end

	local x, y = nil

	if offset.off2 then
		y = offset.y
		x = offset.x
	else
		x = target.x + offset.x
		y = target.y + offset.y
	end

	if effectID then
		map.performWithDelay(map, function ()
			if not tolua.isnull(map) then
				if "" .. magicID == "22" and not noTarget then
					local pos = {}

					table.insert(pos, cc.p(x, y))
					table.insert(pos, cc.p(x + 1, y))
					table.insert(pos, cc.p(x - 1, y))
					table.insert(pos, cc.p(x, y + 1))
					table.insert(pos, cc.p(x, y - 1))
					dummy._showEvents(map, pos, mapDef.ET_FIRE, 15)
				elseif "" .. magicID == "31" then
					self:addState("stMagicShield")
					self.role.node:performWithDelay(function ()
						self:removeState("stMagicShield")

						return 
					end, 15)
				elseif "" .. magicID == "18" and noTarget then
					self.addState(map, "stHidden")
					self.role.node:performWithDelay(function ()
						self:removeState("stHidden")

						return 
					end, 15)
				elseif "" .. magicID == "16" then
					local pos = {}

					table.insert(map, cc.p(x + 2, y - 1))
					table.insert(pos, cc.p(x + 2, y + 1))
					table.insert(pos, cc.p(x - 2, y - 1))
					table.insert(pos, cc.p(x - 2, y + 1))
					table.insert(pos, cc.p(x + 1, y - 2))
					table.insert(pos, cc.p(x - 1, y - 2))
					table.insert(pos, cc.p(x + 1, y + 2))
					table.insert(pos, cc.p(x - 1, y + 2))
					dummy._showEvents(map, pos, mapDef.ET_HOLYCURTAIN, 15)
				elseif not noTarget and not tolua.isnull(self.role.node) then
					magic.showMagic(map, self.role, target.roleid, x, y, effectID)
				end
			end

			return 
		end, 0.5)
	end

	return 
end
dummy.attack = function (self, skillIndex, offset, dir)
	if tolua.isnull(self.role.node) then
		return 
	end

	if type(skillIndex) == "table" then
		local params = skillIndex
		x = params.x
		y = params.y
		dir = params.dir
	end

	if skillIndex == 3 then
		self.playAct(self, dummy.acts.HIT, offset, dir)
	elseif skillIndex == 7 then
		self.playAct(self, dummy.acts.POWERHIT, offset, dir)
	elseif skillIndex == 12 then
		self.playAct(self, dummy.acts.LONGHIT, offset, dir)
	elseif skillIndex == 25 then
		self.playAct(self, dummy.acts.WIDEHIT, offset, dir)
	elseif skillIndex == 26 then
		self.playAct(self, dummy.acts.FIREHIT, offset, dir)
	elseif skillIndex == 12 then
		self.playAct(self, dummy.acts.FOURFIREHIT, offset, dir)
	elseif skillIndex == 27 then
		self.playAct(self, dummy.acts.RUSH, offset, dir)
	elseif skillIndex == 58 then
		self.playAct(self, dummy.acts.SWORD_HIT, offset, dir)
	end

	return 
end
dummy.playBigSkill = function (self)
	local sprs = {
		m2spr.playAnimation("cbohum", 24580, 10, 0.1, false, false, true):addto(self.role.node, 1):pos(0, mapDef.tile.h),
		m2spr.playAnimation("cboweapon", 104580, 10, 0.1, false, false, true):addto(self.role.node, 1):pos(0, mapDef.tile.h),
		m2spr.playAnimation("cbohair", 4580, 10, 0.1, false, false, true):addto(self.role.node, 1):pos(0, mapDef.tile.h)
	}

	m2spr.playAnimation("cboeffect", 580, 10, 0.1, true, true, true):addto(self.role.node, 1):pos(0, mapDef.tile.h)

	for k, v in pairs(self.role.sprites) do
		v.setVisible(v, false)
	end

	self.role.node:performWithDelay(function ()
		sound.playSound("cboZs4_start")

		return 
	end, 0.1)
	self.role.node.performWithDelay(slot2, function ()
		for k, v in pairs(self.role.sprites) do
			v.setVisible(v, true)
		end

		for k, v in pairs(sprs) do
			v.removeSelf(v)
		end

		return 
	end, 1.4000000000000001)

	return 
end
dummy.playBigSkill1 = function (self)
	local time = 1
	local sprs = {
		m2spr.playAnimation("hum", 7408, 5, 0.1, false, false, true):addto(self.role.node, 0):pos(0, mapDef.tile.h),
		m2spr.playAnimation("weapon", 31408, 5, 0.1, false, false, true):addto(self.role.node, 1):pos(0, mapDef.tile.h),
		m2spr.playAnimation("hair", 2608, 5, 0.1, false, false, true):addto(self.role.node, 2):pos(0, mapDef.tile.h)
	}

	self.role.node:performWithDelay(function ()
		sound.playSound("m12-1")

		return 
	end, 0.3)
	m2spr.playAnimation("magic2", 760, 14, 0.08, true, true, true).addto(slot3, self.role.node, 2):pos(0, mapDef.tile.h)

	for k, v in pairs(self.role.sprites) do
		v.setVisible(v, false)
	end

	self.role.node:performWithDelay(function ()
		for k, v in pairs(self.role.sprites) do
			v.setVisible(v, true)
		end

		for k, v in pairs(sprs) do
			v.removeSelf(v)
		end

		return 
	end, slot1)

	return 
end
dummy.magicEffect = function (self, magicID, offset)
	if tolua.isnull(self.role.node) then
		return 
	end

	if type(magicID) == "table" then
		local params = magicID
		magicID = params.magicID
		offset = params.offset
	end

	offset = offset or cc.p(0, 0)
	local map = dummy.getMap()
	local skill = def.magic.getMagicConfigByUid(magicID)
	local effectID = skill and skill.effectID
	local x, y = nil

	if offset.off2 then
		y = offset.y
		x = offset.x
	else
		x = self.role.x + offset.x
		y = self.role.y + offset.y
	end

	if not tolua.isnull(map) then
		magic.showMagic(map, self.role, self.role, x, y, effectID)
	end

	return 
end
dummy.playAct = function (self, actid, offset, dir, feature, state)
	if tolua.isnull(self.role.node) then
		return 
	end

	if type(actid) == "table" then
		local params = actid
		actid = params.actid
		offset = params.offset
		dir = params.dir
		feature = params.feature
		state = params.state
	end

	offset = offset or cc.p(0, 0)
	local feature = self.role.feature

	if feature.race then
		feature.set(feature, "race", feature.race)
	end

	if feature.dress then
		feature.set(feature, "dress", feature.dress)
	end

	if feature.weapon then
		feature.set(feature, "weapon", feature.weapon)
	end

	if feature.hair then
		feature.set(feature, "hair", feature.hair)
	end

	local x, y = nil

	if offset.off2 then
		y = offset.y
		x = offset.x
	else
		x = offset.x + self.role.x
		y = offset.y + self.role.y
	end

	local dir = dir or self.dir

	self.role:processMsg(actid, x, y, dir, feature, state)

	if actid == dummy.acts.SPACEMOVE_SHOW then
		magic.showWithName(dummy.getMap(), "spaceMoveShow", {
			roleid = self.roleid
		})
	end

	return 
end
dummy.showEquip = function (self, time, dressid, weaponid)
	if tolua.isnull(self.role.node) then
		return 
	end

	if type(time) == "table" then
		local params = time
		dressid = params.dressid
		weaponid = params.weaponid
	end

	dressid = dressid or self.dressid
	weaponid = weaponid or self.weaponid
	local model = getRecord("TUserStateInfo")
	local items = model.get(model, "userItems")
	local itemDress, itemWeapon = nil

	if dressid then
		itemDress = getRecord("TClientItem")

		itemDress.set(itemDress, "Index", dressid)
		itemDress.set(itemDress, "makeIndex", -1)
	end

	if weaponid then
		itemWeapon = getRecord("TClientItem")

		itemWeapon.set(itemWeapon, "Index", weaponid)
		itemWeapon.set(itemWeapon, "makeIndex", -1)
	end

	model.set(model, "nameColorIndex", self.nameColorIndex or 255)
	model.set(model, "userItems", {
		itemDress,
		itemWeapon
	})

	local role = self.role

	model.set(model, "userName", role.info:getName())

	local pnl = main_scene.ui:showPanel("equipOther", model)

	if time and 0 < time then
		pnl.performWithDelay(pnl, function ()
			self:hideEquip()

			return 
		end, slot1)
	end

	return 
end
dummy.hideEquip = function (self)
	if not tolua.isnull(main_scene) then
		main_scene.ui:hidePanel("equipOther")
	end

	return 
end
dummy.setNameColor = function (self, color, delay)
	self.role.node:performWithDelay(function ()
		self.role.info:setNameColor(color)

		return 
	end, delay or 0.1)

	return 
end
dummy.dirTo = function (self, pos)
	if tolua.isnull(self.role.node) then
		return 
	end

	if pos == "player" then
		pos = main_scene.ground.player
	end

	self.role.dir = util.getDir(self, pos)

	return 
end
dummy.update = function (self, dt)
	if self.walkFunc then
		self.walkFunc[1](unpack(self.walkFunc[2]))
	end

	return 
end

local function unableModify(tbl)
	local metatable = getmetatable(tbl)

	if not metatable then
		metatable = {}

		setmetatable(tbl, metatable)
	end

	metatable.__newindex = function (_, n)
		error("unable to write current table " .. n, 2)

		return 
	end

	return 
end

slot5(dummy)

return dummy
