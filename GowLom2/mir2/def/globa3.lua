function Byte(num)
	return ycFunction:band(num, 255)
end

function Word(num)
	return ycFunction:band(num, 65535)
end

function Hibyte(num)
	return ycFunction:band(num, 65280)/256
end

function Lobyte(num)
	return ycFunction:band(num, 255)
end

function Hiword(num)
	return ycFunction:band(num, 4294901760.0)/65536
end

function Loword(num)
	return ycFunction:band(num, 65535)
end

function MakeLong(a, b)
	b = Word(b)
	a = Word(a)

	return ycFunction:bor(a, ycFunction:lshift(b, 16))
end

function MakeWord(a, b)
	b = Byte(b)
	a = Byte(a)

	return ycFunction:bor(a, ycFunction:lshift(b, 8))
end

hex2bin = {
	["0"] = "0000",
	a = "1010",
	d = "1101",
	["2"] = "0010",
	["7"] = "0111",
	["3"] = "0011",
	e = "1110",
	b = "1011",
	f = "1111",
	c = "1100",
	["6"] = "0110",
	["9"] = "1001",
	["5"] = "0101",
	["1"] = "0001",
	["8"] = "1000",
	["4"] = "0100"
}
bin2hex = {
	["0101"] = "5",
	["0000"] = "0",
	["0010"] = "2",
	["1000"] = "8",
	["0001"] = "1",
	["0111"] = "7",
	["1011"] = "B",
	["1100"] = "C",
	["1110"] = "E",
	["0011"] = "3",
	["1101"] = "D",
	["1001"] = "9",
	["1111"] = "F",
	["0100"] = "4",
	["0110"] = "6",
	["1010"] = "A"
}

function Hex2Bin(s)
	local ret = ""
	local i = 0

	for i in string.gfind(s, ".") do
		i = string.lower(i)
		ret = ret .. hex2bin[i]
	end

	return ret
end

function Bin2Dec(s)
	local num = 0
	local ex = string.len(s) - 1
	local l = 0
	l = ex + 1

	for i = 1, l, 1 do
		b = string.sub(s, i, i)

		if b == "1" then
			num = num + 2^ex
		end

		ex = ex - 1
	end

	return string.format("%u", num)
end

function Dec2Hex(s)
	s = string.format("%x", s)

	return s
end

function Hex2Dec(s)
	local s = Hex2Bin(s)

	return Bin2Dec(s)
end

function Bin2Hex(s)
	local l = 0
	local h = ""
	local b = ""
	local rem = nil
	l = string.len(s)
	rem = l%4
	l = l - 1
	h = ""

	if 0 < rem then
		s = string.rep("0", rem - 4) .. s
	end

	for i = 1, l, 4 do
		b = string.sub(s, i, i + 3)
		h = h .. bin2hex[b]
	end

	return h
end

function BMAnd(v, m)
	local bv = Hex2Bin(v)
	local bm = Hex2Bin(m)
	local i = 0
	local s = ""

	while string.len(bv) < 32 do
		bv = "0000" .. bv
	end

	while string.len(bm) < 32 do
		bm = "0000" .. bm
	end

	for i = 1, 32, 1 do
		cv = string.sub(bv, i, i)
		cm = string.sub(bm, i, i)

		if cv == cm then
			if cv == "1" then
				s = s .. "1"
			else
				s = s .. "0"
			end
		else
			s = s .. "0"
		end
	end

	return Bin2Hex(s)
end

function getStrWithSize(str, count)
	local le = string.len(str)
	local index = 0
	local char = 0
	local pos = le
	local star = false

	for i = 1, string.len(str), 1 do
		char = string.byte(string.sub(str, i, i))
		local a = Dec2Hex(char)
		local b = BMAnd(a, "c0")

		if Hex2Dec(b) ~= Hex2Dec(80) then
			index = index + 1
			star = true

			if count < index then
				pos = i - 1

				break
			end
		elseif star == true then
			index = index + 1
			star = false

			if count < index then
				pos = i - 2

				break
			end
		end
	end

	return string.sub(str, 1, pos)
end

function getJobStr(job)
	if job == 0 then
		return "战士"
	elseif job == 1 then
		return "法师"
	elseif job == 2 then
		return "道士"
	end

	return "刺客"
end

function getSexStr(sex)
	if sex == 0 then
		return "男"
	end

	return "女"
end

function getMapStateStr(state)
	if state == cAreaStateFight then
		return "[战斗]", cc.c3b(255, 255, 0)
	elseif state == cAreaStateSafe then
		return "[安全]", cc.c3b(0, 255, 0)
	elseif state == cAreaStateGuildWar then
		return "[攻城]", cc.c3b(255, 0, 0)
	elseif state == cAreaStateDareWar then
		return "[挑战]", cc.c3b(255, 255, 0)
	elseif state == cAreaStateReliveable then
		return "[可复活]", cc.c3b(0, 255, 0)
	end

	return "", cc.c3b(255, 255, 255)
end

function getTakeOnPosition(smode)
	if smode == 5 or smode == 6 then
		return U_WEAPON
	elseif smode == 10 or smode == 11 then
		return U_DRESS
	elseif smode == 30 then
		return U_RIGHTHAND
	elseif smode == 19 or smode == 20 or smode == 21 then
		return U_NECKLACE
	elseif smode == 15 then
		return U_HELMET
	elseif smode == 16 then
		return U_MASK
	elseif smode == 24 or smode == 26 then
		return U_ARMRINGR
	elseif smode == 22 or smode == 23 then
		return U_RINGL
	elseif smode == 25 then
		return U_BUJUK
	elseif smode == 27 then
		return U_BELT
	elseif smode == 28 then
		return U_BOOTS
	elseif smode == 7 then
		return U_CHARM
	elseif smode == 32 then
		return U_R_DP
	elseif smode == 33 then
		return U_R_YP
	elseif smode == 35 then
		return U_R_BF
	elseif smode == 36 then
		return U_R_HL
	elseif smode == 37 then
		return U_MINGZHONG
	end

	return 
end

function newList()
	local first, last, list = nil
	local listManager = {
		pushFront = function (value)
			first = first - 1
			list[first] = value

			return 
		end,
		pushBack = function (value)
			last = last + 1
			list[last] = value

			return 
		end,
		popFront = function ()
			if first <= last then
				local value = list[first]
				list[first] = nil
				first = first + 1

				return value
			end

			return 
		end,
		popBack = function ()
			if first <= last then
				local value = list[last]
				list[last] = nil
				last = last - 1

				return value
			end

			return 
		end,
		clear = function ()
			list = {}
			last = 0
			first = 1

			return 
		end,
		isEmpty = function ()
			if last < first then
				last = 0
				first = 1
			end

			return last < first
		end,
		size = function ()
			if last < first then
				return 0
			end

			return last - first + 1
		end
	}

	listManager.clear()

	return listManager
end

function testNetList()
	local lst = newList()

	for k = 1, 100, 1 do
		lst.pushBack(k)
	end

	while not lst.isEmpty() do
		local k = lst.popFront()

		print(k)

		if k < 50 and 40 < k then
			lst.pushBack(k + 23487)
		end
	end

	for k = 1, 100, 1 do
		lst.pushBack(k)
	end

	while not lst.isEmpty() do
		print(lst.popFront())
	end

	print(lst.popFront())

	return 
end

function printscreen(node, args)
	local sp = true
	local file, filters, filterParams = nil

	if args then
		if args.sprite ~= nil then
			sp = args.sprite
		end

		file = args.file
		filters = args.filters
		filterParams = args.filterParams
	end

	local size = node.getContentSize(node)
	local canvas = cc.RenderTexture:create(size.width, size.height)

	canvas.begin(canvas)
	node.visit(node)
	canvas.endToLua(canvas)

	if sp then
		local texture = canvas.getSprite(canvas):getTexture()

		if filters then
			sp = display.newFilteredSprite(texture, filters, filterParams)
		else
			sp = display.newSprite(texture)
		end

		sp.flipY(sp, true)
	end

	if file then
		canvas.saveToFile(canvas, file)
	end

	return sp, file
end

function TDateTimeToUnixDate(time)
	local startTm = 25569.33333333

	return math.floor((time - startTm)*86400)
end

function makeMinimap(mapid, path, w)
	local file = res.loadmap(mapid)

	if not file or file.getw(file) == 0 or file.geth(file) == 0 then
		return 
	end

	local def = require("mir2.scenes.main.map.def")
	local maptile = require("mir2.scenes.main.map.maptile")
	local mapw = file.getw(file)
	local maph = file.geth(file)
	w = w or math.max(math.min((mapw*def.tile.w)/8, 2048), 512)
	local mapNode = display.newNode():scale(w/(mapw*def.tile.w))
	local bgLayer = display.newNode():addto(mapNode)
	local midLayer = display.newNode():addto(mapNode)
	local objLayer = display.newNode():addto(mapNode)
	local maxh = 0

	for i = 1, mapw, 1 do
		for j = 1, maph, 1 do
			local data = file.gettile(file, i, j)

			if data then
				maxh = maptile.addTile(data, i, j, bgLayer, midLayer, objLayer, maph, maxh)
			end
		end
	end

	maxh = maxh*mapNode.getScale(mapNode)
	local node = display.newNode():size(w, maxh):add(mapNode, 1)

	display.newColorLayer(cc.c4b(0, 0, 0, 255)):size(node.getContentSize(node)):add2(node)
	printscreen(node, {
		file = path
	})

	return true
end

function trim0str(str)
	local ret = ""

	for s in string.gmatch(str, "[^%z]") do
		ret = ret .. s
	end

	return ret
end

function traversalNodeTree(n, cb)
	if tolua.isnull(n) then
		return true
	end

	if not cb(n) then
		return false
	end

	for k, v in ipairs(n.getChildren(n)) do
		if not traversalNodeTree(v, cb) then
			return false
		end
	end

	return true
end

function setGlobalZOrderCascade(n, zorder)
	traversalNodeTree(n, function (n)
		n.setGlobalZOrder(n, zorder)

		return 
	end)

	return 
end

function isChildOf(testNode, parent)
	local ok = false

	traversalNodeTree(parent, function (n)
		if n == testNode then
			ok = true
		else
			return true
		end

		return 
	end)

	return ok
end

function parseJson(jsonFile)
	local config_json = res.getfile(jsonFile)

	if config_json == "" then
		assert(false, "can't find file " .. jsonFile)

		return nil
	end

	assert(jsonFile ~= config_json, "WTF???")

	local jsonParse = require("cjson")
	local config = jsonParse.decode(config_json)

	return config
end

function playAni(parent, pattern, frame, delay, blend, isProg)
	local texs = {}

	for i = 1, frame, 1 do
		local tex = cc.Director:getInstance():getTextureCache():addImage(string.format(pattern .. "0_%05d.png", i - 1))

		if tex then
			texs[#texs + 1] = tex
		end
	end

	local texIdx = 1
	local sprite = display.newSprite(texs[texIdx]):addTo(parent)

	local function uptBlendFunc()
		if blend then
			sprite:setBlendFunc(spr, gl.SRC_ALPHA, gl.ONE)
		end

		return 
	end

	slot9()
	sprite.addNodeEventListener(sprite, cc.NODE_ENTER_FRAME_EVENT, function (dt)
		if sprite.lasttime then
			local nowtime = socket.gettime()

			if (delay or 0.3) <= nowtime - sprite.lasttime then
				sprite.lasttime = nowtime
				texIdx = texIdx + 1
				texIdx = (frame < texIdx and 1) or texIdx

				sprite:setTexture(texs[texIdx])
				uptBlendFunc()
			end
		else
			sprite.lasttime = socket.gettime()
		end

		return 
	end)
	sprite.scheduleUpdate(slot8)

	return sprite
end

valueScopeTimer = class("valueScopeTimer")
valueScopeTimer.ctor = function (self, from, to, cb, duration)
	self.from = from
	self.to = to
	self.cb = cb
	self.duration = duration
	self.consume = 0
	self.isRunning = nil

	return 
end
valueScopeTimer.start = function (self, host)
	self.host = host
	local listener = handler(self, self.update)

	if host then
		self.handler = host.schedule(host, listener, 0)
	else
		self.handler = scheduler.scheduleUpdateGlobal(listener)
	end

	self.isRunning = true
	self.consume = 0

	return 
end
valueScopeTimer.stop = function (self)
	if self.isRunning then
		if self.host then
			self.host:stopAction(self.handler)
		else
			scheduler.unscheduleGlobal(self.handler)
		end

		self.isRunning = false
	end

	return 
end
valueScopeTimer.update = function (self, dt)
	if type(dt) ~= "number" then
		dt = cc.Director:getInstance():getDeltaTime()
	end

	self.consume = self.consume + dt
	local per = self.consume/self.duration

	if 1 <= per then
		per = 1

		self.stop(self)
	end

	self.cb(self.from + per*(self.to - self.from))

	return 
end

function tip(str, func)
	an.newMsgbox(str, func)

	return 
end

function luaBuglyLog(level, key, msg)
	level = level or ""
	key = key or ""
	msg = msg or ""

	if buglyLog then
		buglyLog(level, key, msg)
	end

	if p2 then
		p2("other", msg)
	end

	return 
end

local buglyException = {}

function luaReportException(errName, errMsg, logMsg)
	errName = errName or ""
	errMsg = errMsg or ""
	logMsg = logMsg or ""

	luaBuglyLog(2, "mirys_log", "res ver: " .. (MIR2_VERSION or 0) .. "  base ver: " .. (MIR2_VERSION_BASE or 0))
	luaBuglyLog(2, "mirys_log", logMsg)

	local exceptionKey = errName .. errMsg

	if not buglyException[exceptionKey] then
		buglyReportLuaException(errName, errMsg)

		buglyException[exceptionKey] = true
	end

	return 
end

function arrayFilter(array, func)
	local ret = {}

	for i, v in ipairs(array) do
		if func then
			if type(func) == "function" then
				local r = func(v)
				r = r and table.insert(ret, v)
			elseif func == v then
				table.insert(ret, v)
			end
		else
			table.insert(ret, v)
		end
	end

	return ret
end

function stringPadding(str, len, placehoder)
	local ret = str
	placehoder = placehoder or " "

	if str then
		local l = string.utf8len(str)

		if len > l or false then
			local pp = {}

			for i = 1, len - l, 1 do
				pp[#pp + 1] = placehoder
			end

			ret = ret .. table.concat(pp, "")
		end
	end

	return ret
end

local function utf8bytes(ch)
	if ch <= 127 then
		return 1
	elseif ch < 192 then
		return 0
	elseif ch < 224 then
		return 2
	elseif ch < 240 then
		return 3
	elseif ch < 248 then
		return 4
	elseif ch < 252 then
		return 5
	end

	return 6
end

string.utf8sub = function (str, starti, endi)
	local starti = starti or 1
	local endi = endi or 1
	local index = 0
	local startIndex = 0
	local endIndex = 0

	for i = 1, #str, 1 do
		local ch = string.byte(str, i)

		if 128 > ch or ch >= 192 or false then
			index = index + 1

			if index == starti then
				startIndex = i
			end

			if index == endi then
				endIndex = (i + utf8bytes(ch)) - 1
			end
		end
	end

	return string.sub(str, startIndex, endIndex)
end

function reStart()
	local function keyInMod(name, modT)
		if name == "mir2.single.m2debug" then
			return false
		end

		local flag = false

		for _, v in pairs(modT) do
			local match = string.find(name, v)

			if match == 1 then
				flag = true

				break
			end
		end

		return flag
	end

	local mod_preload = {
		mir2 = "mir2%.",
		csv2cfg = "csv2cfg%.",
		framework = "framework%.",
		an = "an%."
	}

	local function clearPreloadChunks()
		for k, v in pairs(package.preload) do
			if keyInMod(k, mod_preload) then
				package.preload[k] = nil
			end
		end

		return 
	end

	local function loadChunksFromZip()
		if not USE_SOURCE_LUA then
			print("cc.LuaLoadChunksFromZIP begin")

			if mod_preload.an then
				cc.LuaLoadChunksFromZIP(string.format("an%s.zip", (USE_ARM64 and "64") or ""))
			end

			if mod_preload.mir2 then
				cc.LuaLoadChunksFromZIP(string.format("mir2%s.zip", (USE_ARM64 and "64") or ""))
			end

			if mod_preload.csv2cfg then
				cc.LuaLoadChunksFromZIP(string.format("csv2cfg%s.zip", (USE_ARM64 and "64") or ""))
			end

			if mod_preload.framework then
				local frwkFilePath = string.format("res/framework_precompiled%s.zip", (USE_ARM64 and "64") or "")

				if cc.FileUtils:getInstance():isFileExist(WRITABLEPATH .. frwkFilePath) then
					frwkFilePath = WRITABLEPATH .. frwkFilePath
				end

				print("quick framework path:" .. frwkFilePath)
				cc.LuaLoadChunksFromZIP(frwkFilePath)
			end

			print("cc.LuaLoadChunksFromZIP end")
		end

		return 
	end

	local mod_loaded = {
		mir2 = "mir2%.",
		csv2cfg = "csv2cfg%.",
		an = "an%."
	}

	local function clearLoadedChunks()
		for k, v in pairs(package.loaded) do
			if keyInMod(k, mod_loaded) then
				package.loaded[k] = nil
			end
		end

		return 
	end

	local function requireLuaModuleAndStart()
		if mod_loaded.framework then
			print("require framework.init")
			require("framework.init")
		end

		if mod_loaded.an then
			an = nil

			print("require an.init")
			require("an.init")
		end

		if mod_loaded.mir2 then
			mir2 = nil
			g_data = nil

			print("require mir2.init")
			require("mir2.init")
		end

		return 
	end

	local protocolmod = {
		"SM_",
		"CM_",
		"ClassID_"
	}

	local function clearProtocols()
		MirTcpClient:getInstance():disconnect(false)
		MirTcpClient:getInstance():clearRemoteHosts()
		MirTcpClient:getInstance():clearAllSunscribeScriptOnProtocol()
		MirTcpClient:getInstance():clearAllSubscribeOnState()

		NEED_LOAD_PROTOCOL = unRegisterLuaProtocols()

		if NEED_LOAD_PROTOCOL then
			for k, v in pairs(_G) do
				if keyInMod(k, protocolmod) then
					_G[k] = nil
				end
			end
		end

		return 
	end

	if debugInfoScheduler then
		scheduler.unscheduleGlobal(debugInfoScheduler)

		debugInfoScheduler = nil
	end

	slot8()
	res.purgeCachedData()

	if not g_data.testOldRestart and PlatformUtils:getInstance() and PlatformUtils:getInstance().reCreateLuaEngineOnEmptyScene then
		PlatformUtils:getInstance():reCreateLuaEngineOnEmptyScene()
	else
		cc.FileUtils:getInstance():purgeCachedEntries()
		clearPreloadChunks()
		clearLoadedChunks()
		loadChunksFromZip()
		requireLuaModuleAndStart()
	end

	return 
end

function walkdir(path)
	local files = {}
	local style = "\n        "
	local str = ""
	local split = "/"
	local tail = string.sub(path, string.len(path))

	if tail and tail ~= split then
		path = path .. split
	end

	local function _walkdir(path)
		str = str .. style .. "walkdir - " .. path

		if io.exists(path) or device.platform == "windows" then
			local lfs = require("lfs")
			local iter, dir_obj = lfs.dir(path)

			while true do
				local dir = iter(dir_obj)

				if dir == nil then
					break
				end

				xpcall(function ()
					if dir ~= "." and dir ~= ".." and dir ~= "" then
						local curDir = path .. dir
						local mode = lfs.attributes(curDir, "mode") or "unknown"

						if mode == "directory" then
							_walkdir(curDir .. "/")
						elseif mode == "file" and curDir ~= "" then
							table.insert(files, curDir)
						end
					end

					return 
				end, function (err)
					print("=====err=====", err)

					str = str .. style .. "err : " .. err

					return 
				end)
			end
		end

		return 
	end

	slot6(path)
	print("-----str-----", str)

	return files
end

return 
