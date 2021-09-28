local mapDef = import("..map.def")
local common = import("..common.common")
local autoFindPath = class("autoFindPath")
autoFindPath.pathFinder = pathFinder:create()

table.merge(autoFindPath, {
	sprMark,
	openlist,
	closelist,
	points,
	destx,
	desty,
	destmap,
	scriptAuto,
	NetCmd
})

autoFindPath.singleMapPathStop = function (self)
	if self.sprMark then
		self.sprMark:removeSelf()

		self.sprMark = nil
	end

	self.points = nil
	self.destx = nil
	self.desty = nil

	if main_scene and main_scene.ui.panels.bigmap then
		main_scene.ui.panels.bigmap:removeAllFindPath()
	end

	if main_scene and main_scene.ui.panels.bigmapOther then
		main_scene.ui.panels.bigmapOther:removeAllFindPath()
	end

	return 
end
autoFindPath.multiMapPathStop = function (self)
	self.destmap = nil
	self.scriptAuto = false

	self.singleMapPathStop(self)

	self.curIndex = nil
	self.linkPoints = nil

	return 
end
autoFindPath.isEnabled = function (self)
	if self.points and #self.points ~= 0 then
		return true
	end

	return false
end
autoFindPath.removePoint = function (self)
	if self.points and 0 < #self.points then
		if main_scene.ui.panels.bigmap then
			main_scene.ui.panels.bigmap:removePoint(self.key(self, self.points[1].x, self.points[1].y))
		end

		if main_scene.ui.panels.bigmapOther then
			main_scene.ui.panels.bigmapOther:removePoint(self.key(self, self.points[1].x, self.points[1].y))
		end

		table.remove(self.points, 1)
	end

	return 
end
autoFindPath.key = function (self, x, y)
	return x*10000 + y
end
autoFindPath.search__ = function (self, startX, startY, destX, destY, searchLimit, ignoreRole, closeTo)
	local start = cc.p(startX, startY)
	start.priority = 0
	local startKey = self.key(self, startX, startY)
	local openlist = {
		[startKey] = start
	}
	local costlist = {
		[startKey] = 0
	}
	local map = main_scene.ground.map
	local toBanPoint = def.map.isBanPoint(destX, destY, main_scene.ground.map.mapid)
	local checkBlock = nil

	if ignoreRole then
		function checkBlock(block, banBlock)
			return (not block and not banBlock) or block == "hero" or block == "mon" or block == "npc"
		end
	else
		function checkBlock(block, banBlock)
			return not block and not banBlock
		end
	end

	local function getNeighbors(x, y)
		local n = {}

		for ox = -1, 1, 1 do
			for oy = -1, 1, 1 do
				n[self:key(x + ox, y + oy)] = cc.p(x + ox, y + oy)
			end
		end

		n[self:key(x, y)] = nil

		return n
	end

	local diagCost = math.sqrt(2)

	local function getCost(pre, next)
		if pre.x == next.x or pre.y == next.y then
			return 1
		else
			return diagCost
		end

		return 
	end

	local function heuristic(from)
		local dx = from.x - destX
		local dy = from.y - destY

		return math.sqrt(dx*dx + dy*dy)
	end

	local last = nil
	local cnt = 0

	while true do
		if searchLimit then
			cnt = cnt + 1

			if searchLimit < cnt then
				return nil
			end
		end

		local bestf = inf
		local current, curkey = nil

		for k, v in pairs(slot10) do
			if v.priority < bestf then
				bestf = v.priority
				current = v
				curkey = k
			end
		end

		if not current then
			return nil
		end

		local x = current.x
		local y = current.y

		if x == destX and y == destY then
			last = current

			break
		end

		if closeTo and math.max(math.abs(x - destX), math.abs(y - destY)) < closeTo then
			last = current

			break
		end

		openlist[curkey] = nil

		for _, neiPos in pairs(getNeighbors(x, y)) do
			local banBlock = (not toBanPoint and def.map.isBanPoint(neiPos.x, neiPos.y, main_scene.ground.map.mapid)) or nil
			local neikey = self.key(self, neiPos.x, neiPos.y)
			local curCost = getCost(current, neiPos) + costlist[curkey]

			if (not costlist[neikey] or curCost < costlist[neikey]) and checkBlock(map.canWalk(map, neiPos.x, neiPos.y, {
				useBlockInfo = true
			}).block, banBlock) then
				costlist[neikey] = curCost
				neiPos.priority = heuristic(neiPos)
				openlist[neikey] = neiPos
				neiPos.parent = current
			end
		end
	end

	if not last then
		return nil
	end

	local points = {}

	while last do
		table.insert(points, 1, {
			x = last.x,
			y = last.y,
			key = self.key(self, last.x, last.y)
		})

		last = last.parent
	end

	return points
end
autoFindPath.getPath = function (self, startX, startY, destX, destY, map, searchLimit)
	local map = map or main_scene.ground.map
	local mapfile = res.loadmap(map.replaceMapid or map.mapid)

	if not mapfile.isValid(mapfile) then
		return nil
	end

	local start = cc.p(startX, startY)
	local goal = cc.p(destX, destY)

	if self.pathFinder:find({}, mapfile, start, goal, 1, searchLimit or -1) then
		return self.pathFinder:getCurrentPath()
	end

	return 
end
autoFindPath.search = function (self, startX, startY, destX, destY, searchLimit, ignoreRole, closeTo, ignoreDoorPoint)
	if device.platform == "windows" and IS_PLAYER_DEBUG then
		return self.search__(self, startX, startY, destX, destY, searchLimit, ignoreRole, closeTo)
	else
		local map = main_scene.ground.map
		local mapfile = res.loadmap(map.replaceMapid or map.mapid)

		if not mapfile.isValid(mapfile) then
			return nil
		end

		closeTo = closeTo or 1

		if closeTo <= 1 and map.canWalk(map, destX, destY).block then
			return nil
		end

		local objBlocks = nil

		if ignoreRole then
			objBlocks = {}
		else
			objBlocks = map.getObjeBlocks(map)
		end

		if not ignoreDoorPoint then
			local map = main_scene.ground.map

			if mapDef.doorPoint[map.mapid] then
				for k, v in pairs(mapDef.doorPoint[map.mapid]) do
					if v.x ~= destX and v.y ~= destY then
						table.insert(objBlocks, cc.p(v.x, v.y))
					end
				end
			end
		end

		local start = cc.p(startX, startY)
		local dest = cc.p(destX, destY)
		local mapfile = res.loadmap(map.replaceMapid or map.mapid)

		if self.pathFinder:find(objBlocks, mapfile, start, dest, closeTo, searchLimit or -1) then
			return self.pathFinder:getCurrentPath()
		end
	end

	return 
end
autoFindPath.checkClose = function (self, startX, startY, destX, destY, searchLimit, ignoreRole, closeTo)
	if device.platform == "windows" and IS_PLAYER_DEBUG then
		return self.search__(self, startX, startY, destX, destY, searchLimit, ignoreRole, closeTo)
	else
		local roles = nil
		local map = main_scene.ground.map
		local mapfile = res.loadmap(map.replaceMapid or map.mapid)

		if not mapfile.isValid(mapfile) then
			return nil
		end

		if ignoreRole then
			roles = {}
		else
			roles = map.getObjeBlocks(map)
		end

		local start = cc.p(startX, startY)
		local goal = cc.p(destX, destY)

		return self.pathFinder:find(roles, mapfile, start, goal, closeTo or 1, searchLimit or -1)
	end

	return 
end
autoFindPath.getNeighbors = function (self, prex, prey, map, blockChecker, toBanPoint)
	local neighbors = {}

	for i = 0, 7, 1 do
		local cfg = def.role.dir["_" .. i]
		local x = prex + cfg[1]
		local y = prey + cfg[2]
		local info = map.canWalk(map, x, y, {
			useBlockInfo = true
		})
		local banBlock = (not toBanPoint and def.map.isBanPoint(x, y, main_scene.ground.map.mapid)) or nil

		if blockChecker(info.block, banBlock) then
			table.insert(neighbors, cc.p(x, y))

			local x = prex + cfg[1]*2
			local y = prey + cfg[2]*2
			local info = map.canWalk(map, x, y, {
				useBlockInfo = true
			})
			local banBlock = (not toBanPoint and def.map.isBanPoint(x, y, main_scene.ground.map.mapid)) or nil

			if blockChecker(info.block, banBlock) then
				local pos = cc.p(x, y)
				pos.isRun = true

				table.insert(neighbors, cc.p(x, y))
			end
		end
	end

	return neighbors
end
autoFindPath.search__ = function (self, startX, startY, destX, destY, searchLimit, ignoreRole, closeTo)
	self.closelist = {}
	self.openlist = {
		[self.key(self, startX, startY)] = {
			g = 0,
			f = 0,
			h = 0,
			x = startX,
			y = startY
		}
	}
	local map = main_scene.ground.map
	local player = main_scene.ground.player
	local x = destX
	local y = destY

	local function getg(dir)
		return 10
	end

	local function geth(x, y)
		return math.abs(x) + math.abs(y)
	end

	local checkBlock = nil

	if ignoreRole then
		function checkBlock(block, banBlock)
			return (not block and not banBlock) or block == "hero" or block == "mon" or block == "npc"
		end
	else
		function checkBlock(block, banBlock)
			return not block and not banBlock
		end
	end

	local toBanPoint = def.map.isBanPoint(slot10, y, main_scene.ground.map.mapid)
	local stepCnt = 0

	local function go()
		while true do
			local best = nil
			local fbest = inf
			stepCnt = stepCnt + 1

			if searchLimit and searchLimit < stepCnt then
				return false
			end

			for _, v in pairs(self.openlist) do
				local f = v.f

				if f < fbest then
					fbest = f
					best = v
				end
			end

			if not best then
				return false
			end

			if closeTo then
				if math.abs(best.x - x) < closeTo and math.abs(best.y - y) < closeTo then
					return best
				end
			elseif best.x == x and best.y == y then
				return best
			end

			local key = self:key(best.x, best.y)
			self.closelist[key] = best
			self.openlist[key] = nil

			for i = 0, 7, 1 do
				local config = def.role.dir["_" .. i]
				local nextx = best.x + config[1]
				local nexty = best.y + config[2]
				local info = map:canWalk(nextx, nexty, {
					useBlockInfo = true
				})
				local banBlock = (not toBanPoint and def.map.isBanPoint(nextx, nexty, main_scene.ground.map.mapid)) or nil

				if checkBlock(info.block, banBlock, nextx, nexty) then
					local key = self:key(nextx, nexty)

					if not self.closelist[key] and (not self.openlist[key] or false) then
						local dis = geth(nextx - x, nexty - y)
						self.openlist[key] = {
							x = nextx,
							y = nexty,
							g = getg(i) + best.g,
							h = dis,
							f = getg(i) + dis,
							parent = best
						}
					end
				end
			end
		end

		return 
	end

	local last = nil

	if not closeTo then
		local block = map.canWalk(slot8, x, y, {
			useBlockInfo = true
		}).block
		local isBanPoint = (not toBanPoint and def.map.isBanPoint(x, y, main_scene.ground.map.mapid)) or nil

		if checkBlock(block, isBanPoint) then
			last = go()
		end
	else
		last = go()
	end

	self.openlist = nil
	self.closelist = nil

	if not last then
		return nil
	end

	local points = {}

	while last do
		table.insert(points, 1, {
			x = last.x,
			y = last.y,
			key = self.key(self, last.x, last.y)
		})

		last = last.parent
	end

	return points
end
autoFindPath.mergeRoute = function (self, startX, startY, points)
	local tmp = {
		x = startX,
		y = startY,
		key = self.key(self, startX, startY)
	}
	local tpoints = {}
	local i = 1

	while i <= #points do
		local v = points[i]
		local v2 = points[i + 1]

		if v and v2 then
			if v.x - tmp.x == v2.x - v.x and v.y - tmp.y == v2.y - v.y and math.max(math.abs(v2.x - tmp.x), math.abs(v2.y - tmp.y)) <= 2 then
				tpoints[#tpoints + 1] = v2
				tmp = v2
				i = i + 2
			else
				tpoints[#tpoints + 1] = v
				tmp = v
				i = i + 1
			end
		else
			tpoints[#tpoints + 1] = v
			i = i + 1
		end
	end

	return tpoints
end
autoFindPath.searchForRun = function (self, startX, startY, destX, destY, searchLimit, ignoreRole, closeTo)
	self.closeTo = closeTo
	local points = self.search(self, startX, startY, destX, destY, searchLimit, ignoreRole, closeTo)

	if not points then
		return false
	end

	self.destx = destX
	self.desty = destY
	self.points = self.mergeRoute(self, startX, startY, points)

	return true
end
autoFindPath.searching = function (self, x, y, destMapid, searchLimit, closeTo, tNetCmd, isSuccess)
	if tNetCmd or self.linkPoints == nil then
		common.stopAuto()
	end

	local map = main_scene.ground.map
	local player = main_scene.ground.player
	local destx = x
	local desty = y

	if not destMapid or destMapid == main_scene.ground.map.mapid then
		self.destmap = nil
		self.curIndex = nil
		self.linkPoints = nil
	else
		if self.linkPoints then
			if isSuccess then
				self.curIndex = self.curIndex + 1
			end
		else
			self.linkPoints = {}

			def.map.getRoute({
				mid = map.mapid
			}, destMapid, self.linkPoints)

			if #self.linkPoints == 0 then
				self.multiMapPathStop(self)

				return main_scene.ui:tip("寻找不到前往目标点的路径 ", 6)
			else
				self.linkPoints = def.map.orderPoints(self.linkPoints)
				self.curIndex = 1
			end
		end

		if self.curIndex <= #self.linkPoints then
			y = self.linkPoints[self.curIndex].y
			x = self.linkPoints[self.curIndex].x
		end

		self.destmap = {
			id = destMapid,
			x = destx,
			y = desty
		}
	end

	if tNetCmd then
		self.NetCmd = tNetCmd
	end

	if self.searchForRun(self, player.x, player.y, x, y, searchLimit, false, closeTo) then
		if main_scene.ui.panels.bigmap then
			main_scene.ui.panels.bigmap:change2CurMap()
			main_scene.ui.panels.bigmap:loadFindPathPoint(self.points)
		end

		if main_scene.ui.panels.bigmapOther then
			main_scene.ui.panels.bigmapOther:loadFindPathPoint(self.points)
		end
	else
		main_scene.ui:tip("寻找不到前往目标点的路径 ", 6)
		self.multiMapPathStop(self)
	end

	return 
end
autoFindPath.research = function (self, isSuccess)
	if self.scriptAuto then
		self.scriptAutoPath(self)
	elseif self.destmap then
		self.searching(self, self.destmap.x, self.destmap.y, self.destmap.id, nil, nil, nil, isSuccess)
	elseif self.destx and self.desty then
		self.searching(self, self.destx, self.desty, nil, nil, self.closeTo)
	else
		self.multiMapPathStop(self)
	end

	return 
end
autoFindPath.scriptAutoPath = function (self)
	local path = g_data.bigmap:getScriptPath(main_scene.ground.map.mapid)

	if path then
		self.scriptAuto = true

		self.searching(self, path.x, path.y)
	else
		self.scriptAuto = false
	end

	return 
end
autoFindPath.getNearstUnBlockPoint = function (self)
	local player = main_scene.ground.player
	local ep, nPoints = nil

	if 5 < #self.points then
		table.remove(self.points, 1)
		table.remove(self.points, 1)
		table.remove(self.points, 1)
		table.remove(self.points, 1)

		ep = self.points[1]

		table.remove(self.points, 1)

		nPoints = self.search(self, player.x, player.y, ep.x, ep.y)
	elseif 0 < #self.points and #self.points <= 5 then
		ep = self.linkPoints[self.curIndex]
	end

	if not nPoints then
		ep = self.linkPoints[self.curIndex]
		nPoints = self.search(self, player.x, player.y, ep.x, ep.y)
	end

	if not nPoints then
		return false
	end

	print(" _______autoFindPath:getNearstUnBlockPoint ")

	for i = #nPoints, 1, -1 do
		table.insert(self.points, 1, nPoints[i])
	end

	return true
end

return autoFindPath
