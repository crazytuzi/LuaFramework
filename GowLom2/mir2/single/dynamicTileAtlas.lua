local dynamicTileAtlas = class("dynamicTileAtlas")

require("socket")
table.merge(dynamicTileAtlas, {})

local tileAtlas = {
	cntTex = 0,
	getCntTex = function ()
		return tileAtlas.cntTex
	end
}
dynamicTileAtlas.ctor = function (self, w, h, pixelFormat, depthStencilFormat, initZOrder)
	self.w = w
	self.h = h
	self.pixelFormat = pixelFormat
	self.depthStencilFormat = depthStencilFormat
	self.curMaxWidth = 0
	self.curY = 0
	self.curX = 0
	self.tileInfos = {}
	self.count = 0
	self.curOrder_ = initZOrder
	self.notDraw = {}
	self.frame = 0
	self.oleTextures = {}

	self.createTexture(self)

	self.scheduleHandler = scheduler.scheduleGlobal(function ()
		self:drawForNotDraw(true)

		return 
	end, 0.1)

	return 
end
dynamicTileAtlas.drawForNotDraw = function (self, force)
	local hasNotDraw = false
	local notDraw = self.notDraw
	local rest = #notDraw

	if rest ~= 0 then
		if 5 < rest or force then
			local r = {}
			local st = socket.gettime()

			for k, v in ipairs(notDraw) do
				r[v.renderTexture] = r[v.renderTexture] or {}
				local lst = r[v.renderTexture]
				lst[#lst + 1] = v
			end

			for renderTexture, lst in pairs(r) do
				renderTexture.begin(renderTexture)

				for k, v in ipairs(lst) do
					self.drawFrame(self, v)
					v.originTexture:release()
				end

				renderTexture.endToLua(renderTexture)
			end

			self.notDraw = {}
		elseif 1 <= #self.oleTextures then
			for k, v in ipairs(self.oleTextures) do
				local refCnt = v.getSprite(v):getTexture():getReferenceCount()

				if refCnt == 1 then
					for id, info in pairs(self.tileInfos) do
						if info.renderTexture == v then
							self.tileInfos[id] = nil
						end
					end

					v.release(v)

					self.oleTextures[k] = nil
				end
			end
		end
	end

	return 
end
dynamicTileAtlas.releaseAll = function (self)
	for k, v in ipairs(self.oleTextures) do
		v.renderTexture:release()

		tileAtlas.cntTex = tileAtlas.cntTex - 1
	end

	self.tileInfos = {}
	self.count = 0
	self.curOrder_ = 0
	self.notDraw = {}
	self.frame = 0
	self.oleTextures = {}

	self.renderTexture:beginWithClear(0, 0, 0, 0)
	self.renderTexture:endToLua()

	return 
end
dynamicTileAtlas.createTexture = function (self)
	if not tolua.isnull(self.renderTexture) then
		self.oleTextures[#self.oleTextures + 1] = {
			renderTexture = self.renderTexture,
			zOrder = self.curOrder_
		}
	end

	self.renderTexture = cc.RenderTexture:create(self.w, self.h, self.pixelFormat, self.depthStencilFormat)

	self.renderTexture:retain()

	self.texture = self.renderTexture:getSprite():getTexture()
	tileAtlas.cntTex = tileAtlas.cntTex + 1

	return 
end
dynamicTileAtlas.addAndCreate = function (self, originTexture, name, ex, spriteClass)
	local tileInfos = self.tileInfos
	local info = tileInfos[name]

	if not info then
		tileInfos[name] = {
			name = name,
			originTexture = originTexture,
			ex = ex
		}
		info = tileInfos[name]

		originTexture.retain(originTexture)

		info.y = self.curY
		info.x = self.curX
		self.curX, self.curY, self.curMaxWidth = self.put(self, info, self.curX, self.curY, self.curMaxWidth)

		if self.w < info.x + self.curMaxWidth then
			self.createTexture(self)

			info.y = 0
			info.x = 0
			self.curX, self.curY, self.curMaxWidth = self.put(self, info, 0, 0, 0)
		end

		local notDraw = self.notDraw
		notDraw[#notDraw + 1] = info
		info.texture = self.texture
		info.renderTexture = self.renderTexture
		info.gZOrder = self.curOrder_
		info.relations = {}
	end

	local sprite = spriteClass.createWithTexture(spriteClass, info.texture, info.rect)
	info.relations[#info.relations + 1] = sprite

	return sprite
end
dynamicTileAtlas.addAndCreateAsync = function (self, name, ex, spriteClass)
	local tileInfos = self.tileInfos
	local info = tileInfos[name]
	local async = nil

	if not info then
		tileInfos[name] = {
			name = name,
			ex = ex
		}
		info = tileInfos[name]

		function async(originTexture)
			info.originTexture = originTexture

			originTexture.retain(originTexture)

			local notDraw = self.notDraw
			notDraw[#notDraw + 1] = info

			return 
		end

		info.y = self.curY
		info.x = self.curX
		self.curX, self.curY, self.curMaxWidth = self.put(slot0, info, self.curX, self.curY, self.curMaxWidth)

		if self.w < info.x + self.curMaxWidth then
			self.createTexture(self)

			info.y = 0
			info.x = 0
			self.curX, self.curY, self.curMaxWidth = self.put(self, info, 0, 0, 0)
		end

		info.texture = self.texture
		info.renderTexture = self.renderTexture
		info.gZOrder = self.curOrder_
		info.relations = {}
	end

	local sprite = spriteClass.createWithTexture(spriteClass, info.texture, info.rect)
	info.relations[#info.relations + 1] = sprite

	return sprite, async
end
dynamicTileAtlas.check = function (self, name)
	return self.tileInfos[name]
end
dynamicTileAtlas.remove = function (self, name)
	local tileInfos = self.tileInfos

	tileInfos[name].originTexture:release()

	if tileInfos[name].frame then
		tileInfos[name].frame:release()
	end

	tileInfos[name] = nil

	return 
end
dynamicTileAtlas.removeAllFrame = function (self)
	local tileInfos = self.tileInfos

	for name, v in pairs(self.titleInfos) do
		tileInfos[name].originTexture:release()

		if tileInfos[name].frame then
			tileInfos[name].frame:release()
		end
	end

	self.tileInfos = {}

	return 
end
dynamicTileAtlas.put = function (self, info, x, y, maxWidth)
	if self.h < y + info.ex.h then
		x = x + maxWidth + 1
		y = 0
		maxWidth = 0
	end

	self.count = self.count + 1
	local rect = cc.rect(x, y, info.ex.w, info.ex.h)
	info.rect = rect
	y = y + info.ex.h + 1

	if maxWidth < info.ex.w then
		maxWidth = info.ex.w
	end

	return x, y, maxWidth
end
dynamicTileAtlas.drawFrame = function (self, info)
	info.originTexture:setAliasTexParameters()

	local sprite = display.newSprite(info.originTexture):pos(info.rect.x, info.rect.y):anchor(0, 0)

	sprite.flipY(sprite, true)
	sprite.visit(sprite)

	return 
end
local tile = dynamicTileAtlas.new(2048, 2048, cc.TEXTURE2D_PIXEL_FORMAT_RGBA4444, 0, -2)
local smtile = dynamicTileAtlas.new(2048, 2048, cc.TEXTURE2D_PIXEL_FORMAT_RGBA4444, 0, -3)
local mapobj = dynamicTileAtlas.new(2048, 2048, cc.TEXTURE2D_PIXEL_FORMAT_RGBA4444, 0, -1)
tileAtlas.tile = tile
tileAtlas.smtile = smtile
tileAtlas.mapobj = mapobj

return tileAtlas
