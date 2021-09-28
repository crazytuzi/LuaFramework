local def = import(".def")
local maptile = class("maptile")

table.merge(maptile, {
	mapFixArtifactsByStrechingTexel = true
})

local __position = cc.Node.setPosition
maptile.remove = function (self)
	for k, v in pairs(self.sprites) do
		v.removeSelf(v)
	end

	return 
end
maptile.ctor = function (self, map, x, y)
	self.sprites = {}
	local mapfile = res.loadmap(map.replaceMapid or map.mapid)
	local data = mapfile.gettile(mapfile, x, y)

	if map.hasRes then
		if not data then
			return 
		end

		if 0 < data.bgidx and x%2 == 0 and y%2 == 0 then
			local img = "tiles"

			if 0 < data.tileLib then
				img = img .. data.tileLib + 1
			end

			local bg = m2spr.new(img, data.bgidx - 1, {
				asyncPriority = 2
			}).spr:anchor(0, 0):flipX(data.r1):addto(map.layers.bg, y)

			if bg ~= nil and bg.setFixArtifactsByStrechingTexel ~= nil then
				bg.setFixArtifactsByStrechingTexel(bg, self.mapFixArtifactsByStrechingTexel)
			end

			self.sprites.bg = bg

			__position(bg, x*def.tile.w, (map.h - y - 1)*def.tile.h)
		end

		if 0 < data.mididx then
			local img = "smtiles"

			if 0 < data.smTileLib then
				img = img .. data.smTileLib + 1
			end

			local mid = m2spr.new(img, data.mididx - 1, {
				asyncPriority = 1
			}).spr:anchor(0, 0):flipX(data.r2):addto(map.layers.mid, y)

			if mid ~= nil and mid.setFixArtifactsByStrechingTexel ~= nil then
				mid.setFixArtifactsByStrechingTexel(mid, self.mapFixArtifactsByStrechingTexel)
			end

			self.sprites.mid = mid

			__position(mid, x*def.tile.w, (map.h - y)*def.tile.h)

			if data.smTilesAniFrameAndSpeed ~= 0 and 0 < data.midAniOfs and 0 < data.midAniCnt then
				self.sprites.midAni = m2spr.playAnimation(img, data.mididx - 1, data.midAniCnt, nil, data.midAniBlend, nil, nil, nil, nil, 1, data.midAniOfs):anchor(0, 0):flipX(reverse):addto(map.layers.mid, y)

				if self.sprites.midAni ~= nil and self.sprites.midAni.setFixArtifactsByStrechingTexel ~= nil then
					self.sprites.midAni:setFixArtifactsByStrechingTexel(self.mapFixArtifactsByStrechingTexel)
				end

				__position(self.sprites.midAni, x*def.tile.w, (map.h - y)*def.tile.h)
			end
		end

		if 0 < data.objidx then
			local img = "objects"

			if 0 < data.objFileIdx then
				img = img .. data.objFileIdx + 1
			end

			local animF = data.objidx

			if 0 < data.aniFrame then
				self.sprites.obj = m2spr.playAnimation(img, data.objidx - 1, data.aniFrame, nil, data.blend, nil, nil, nil, nil, 1)

				if self.sprites.obj ~= nil and self.sprites.obj.setFixArtifactsByStrechingTexel ~= nil then
					self.sprites.obj:setFixArtifactsByStrechingTexel(self.mapFixArtifactsByStrechingTexel)
				end

				local curTex, curTexInfo = res.gettex(img, data.objidx - 1)
				local isSpecialPos = false

				if curTexInfo ~= nil then
					isSpecialPos = curTexInfo.w == 48 or curTexInfo.h == 32
				end

				if isSpecialPos then
					__position(self.sprites.obj, x*def.tile.w, (map.h - y)*def.tile.h)
				else
					__position(self.sprites.obj, x*def.tile.w, (map.h - y + 3)*def.tile.h)
				end
			else
				self.sprites.obj = m2spr.new(img, data.objidx - 1, {
					asyncPriority = 1
				}):pos(x*def.tile.w, (map.h - y)*def.tile.h)

				if self.sprites.obj ~= nil and self.sprites.obj.setFixArtifactsByStrechingTexel ~= nil then
					self.sprites.obj:setFixArtifactsByStrechingTexel(self.mapFixArtifactsByStrechingTexel)
					self.sprites.obj:anchor(0, 0)
				end
			end

			self.sprites.obj:flipX(data.r3):addto(map.layers.obj, y)

			if data.doorIndex ~= 0 then
				data.doorOpen = false

				map.addDoorTile(map, data, x, y)
			end
		end

		if 0 < data.aniNo and 0 < data.aniOfs and 0 < data.aniCnt then
			self.sprites.ani = m2spr.playAnimation("anitiles" .. data.aniLib + 1, data.aniNo - 1, data.aniCnt - 1, nil, data.aniBlend, nil, nil, nil, nil, 1, data.aniOfs):anchor(0, 0):flipX(data.r4):addto(map.layers.obj, y)

			if self.sprites.ani ~= nil and self.sprites.ani.setFixArtifactsByStrechingTexel ~= nil then
				self.sprites.ani:setFixArtifactsByStrechingTexel(self.mapFixArtifactsByStrechingTexel)
			end

			__position(self.sprites.ani, x*def.tile.w, (map.h - y)*def.tile.h)
		end
	else
		self.sprites.bg = res.get2("pic/maptile/bg.png", nil, nil, {
			class = cc.FilteredSpriteWithOne
		}):anchor(0, 0):addto(map.layers.bg, y)

		__position(self.sprites.bg, x*def.tile.w, (map.h - y)*def.tile.h)

		if data and not data.canWalk then
			self.sprites.obj = res.get2("pic/maptile/obj" .. math.random(3) .. ".png", nil, nil, {
				class = cc.FilteredSpriteWithOne
			}):anchor(0, 0):addto(map.layers.bg, y)

			__position(self.sprites.obj, x*def.tile.w, (map.h - y)*def.tile.h)
		end
	end

	return 
end
maptile.setDoorState = function (self, data)
	local img = "objects"

	if 0 < data.objFileIdx then
		img = img .. data.objFileIdx + 1
	end

	self.sprites.obj:setImg(img, data.objidx - 1 + ((data.doorOpen and data.doorOffset) or 0))

	return 
end
maptile.addTile = function (data, x, y, bgLayer, midLayer, objLayer, maph, maxh)
	local prioty = 0

	if 0 < data.bgidx and x%2 == 0 and y%2 == 0 then
		local img = "tiles"

		if 0 < data.tileLib then
			img = img .. data.tileLib + 1
		end

		local spr = res.get(img, data.bgidx - 1, nil, prioty):anchor(0, 0):pos(x*def.tile.w, (maph - y - 1)*def.tile.h):flipX(data.r1):addto(bgLayer, y)
		maxh = math.max(maxh, spr.getPositionY(spr) + spr.getContentSize(spr).height)
	end

	if 0 < data.mididx then
		local img = "smtiles"

		if 0 < data.smTileLib then
			img = img .. data.smTileLib + 1
		end

		local spr = res.get(img, data.mididx - 1, nil, prioty):anchor(0, 0):pos(x*def.tile.w, (maph - y)*def.tile.h):flipX(data.r2):addto(midLayer, y)
		maxh = math.max(maxh, spr.getPositionY(spr) + spr.getContentSize(spr).height)
	end

	if 0 < data.objidx then
		local img = "objects"

		if 0 < data.objFileIdx then
			img = img .. data.objFileIdx + 1
		end

		if data.aniFrame == 0 then
			local spr = res.get(img, data.objidx - 1, nil, prioty):anchor(0, 0):pos(x*def.tile.w, (maph - y)*def.tile.h):flipX(data.r3):addto(objLayer, y)
			maxh = math.max(maxh, spr.getPositionY(spr) + spr.getContentSize(spr).height)
		end
	end

	return maxh
end

return maptile
