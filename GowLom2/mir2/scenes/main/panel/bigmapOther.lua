local scale = 0.8
local bigmapOther = class("bigmapOther", function ()
	return display.newNode()
end)

table.merge(slot1, {
	texSize,
	point,
	mapScale,
	mapNode,
	findPathNode,
	findPathPoint,
	dest,
	destPoint,
	playerInThisMap
})

bigmapOther.ctor = function (self, params)
	self._supportMove = true
	params = params or {}
	local tex = params.tex
	local mapData = params.mapData
	local user = params.user
	self.mapData = mapData
	local mapw = 615
	self.texSize = tex.getContentSize(tex)
	self.mapScale = mapw/self.texSize.width
	local mapSize = cc.size(mapw, self.texSize.height*self.mapScale)
	local controlHeight = 112
	local bg = display.newNode():scale(scale):add2(self)
	local b1 = res.get2("pic/panels/bigmap/bg1.png")
	local b2 = res.get2("pic/panels/bigmap/bg2.png")
	local b3 = res.get2("pic/panels/bigmap/bg3.png")

	bg.size(bg, b1.getw(b1), mapSize.height + controlHeight)
	b3.anchor(b3, 0, 0):add2(bg, -1)
	b2.anchor(b2, 0, 0):pos(0, b3.geth(b3)):scaleY((bg.geth(bg) - b1.geth(b1) - b3.geth(b3))/b2.geth(b2)):add2(bg, -1)
	b1.anchor(b1, 0, 1):pos(0, bg.geth(bg)):add2(bg, -1)

	self.mapNode = display.newNode():pos(13, 14):size(mapSize):add2(bg, 1)
	local mapSpr = display.newSprite(tex):scale(self.mapScale):anchor(0, 0):add2(self.mapNode)

	display.newScale9Sprite(res.getframe2("pic/scale/scale2.png"), 0, 0, mapSize):anchor(0, 0):add2(self.mapNode, 1)
	self.size(self, bg.getw(bg)*scale, bg.geth(bg)*scale):anchor(0.5, 0.5):center()
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png")
	}).anchor(slot13, 1, 1):pos(self.getw(self) - 4, self.geth(self) - 4):addto(self, 1)
	an.newLabelM(self.getw(self) - 30, 18, 1, {
		manual = true
	}):anchor(0, 0.5):pos(15, self.geth(self) - 58):add2(self):nextLine():addLabel(user, cc.c3b(0, 255, 0)):addLabel("当前位于"):addLabel(string.format("%s(%s,%s)", mapData.mapTitle, mapData.x, mapData.y), cc.c3b(0, 255, 0))

	if g_data.map.mapTitle == mapData.mapTitle and main_scene.ground.map.mapid == mapData.mapID then
		self.playerInThisMap = true
	end

	self.setDestPoint(self, mapData.x, mapData.y)

	if self.playerInThisMap then
		an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			local x = mapData.x
			local y = mapData.y + 1

			if main_scene.ground.map:canWalk(x, y).block and main_scene.ground.map:canWalk(x, y - 1).block then
				main_scene.ui:tip("目标是阻挡, 无法到达", 6)

				return 
			end

			main_scene.ui.console.controller.autoFindPath:searching(x, y)

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			label = {
				"寻路找ta",
				16,
				1
			}
		}).anchor(slot13, 1, 0.5):pos(self.getw(self) - 12, self.geth(self) - 58):add2(self)
		self.pointUpt(self, main_scene.ground.map, main_scene.ground.player)

		if main_scene.ui.console.controller.autoFindPath.points then
			self.loadFindPathPoint(self, main_scene.ui.console.controller.autoFindPath.points)
		end
	end

	return 
end
bigmapOther.mapPos = function (self, x, y)
	local w, h = nil

	if self.playerInThisMap then
		h = main_scene.ground.map.h
		w = main_scene.ground.map.w
	else
		local file = res.loadmap(self.mapData.mapID)
		h = file.geth(file)
		w = file.getw(file)
	end

	local percent = {
		x = self.texSize.width/w*self.mapScale,
		y = self.texSize.height/h*self.mapScale
	}

	return x*percent.x, (h - y - 1)*percent.y
end
bigmapOther.setDestPoint = function (self, x, y)
	x, y = self.mapPos(self, x, y)
	local point = res.get2("pic/panels/bigmap/p-green.png"):anchor(0.5, 0):add2(self.mapNode, 1):pos(x, self.mapNode:geth()):moveTo(0.1, x, y)

	return 
end
bigmapOther.removeAllFindPath = function (self)
	if not self.playerInThisMap then
		return 
	end

	if self.findPathNode then
		self.findPathNode:removeSelf()

		self.findPathNode = nil
	end

	self.findPathPoint = nil

	return 
end
bigmapOther.removePoint = function (self, key)
	if not self.playerInThisMap then
		return 
	end

	if self.findPathPoint and self.findPathPoint[key] then
		self.findPathPoint[key]:removeSelf()

		self.findPathPoint[key] = nil
	end

	return 
end
bigmapOther.key = function (self, x, y)
	return x*10000 + y
end
bigmapOther.loadFindPathPoint = function (self, points)
	if not self.playerInThisMap then
		return 
	end

	self.removeAllFindPath(self)

	self.findPathNode = display.newNode():size(self.mapNode:getContentSize()):add2(self.mapNode)
	self.findPathPoint = {}

	for i, v in ipairs(points) do
		local point = display.newColorLayer(cc.c4b(0, 255, 255, 255)):size(4, 4):add2(self.findPathNode)
		local x, y = self.mapPos(self, v.x, v.y)

		point.pos(point, x - self.point:getw()/2, y - self.point:geth()/2)

		if not v.key then
			v.key = self.key(self, v.x, v.y)
		end

		self.findPathPoint[v.key] = point
	end

	return 
end
bigmapOther.pointUpt = function (self, map, player)
	if not self.playerInThisMap then
		return 
	end

	if not self.point then
		self.point = display.newColorLayer(def.colors.get(251, true)):add2(self.mapNode, 1):size(6, 6)
	end

	local x, y = self.mapPos(self, player.x, player.y)

	self.point:pos(x - self.point:getw()/2, y - self.point:geth()/2)

	return 
end

return bigmapOther
