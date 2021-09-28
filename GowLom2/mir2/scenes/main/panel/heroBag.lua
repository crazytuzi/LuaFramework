local item = import("..common.item")
local heroBag = class("heroBag", function ()
	return display.newNode()
end)

table.merge(slot1, {})

heroBag.resetPanelPosition = function (self, type)
	if type == "left" then
		self.anchor(self, 0, 1):pos(100, display.height - 16)
	elseif type == "right" then
		self.anchor(self, 1, 1):pos(display.width - 60, display.height - 16)
	end

	if self.setFocus then
		self.setFocus(self)
	end

	return self
end
heroBag.ctor = function (self, from)
	self._scale = self.getScale(self)
	self._supportMove = true

	self.reloadAll(self, g_data.hero.bagSize, true, from)

	if main_scene.ui.panels and main_scene.ui.panels.bag then
		local posX = main_scene.ui.panels.bag:getPositionX() + main_scene.ui.panels.bag:getCascadeBoundingBox().width

		self.anchor(self, 0, 1):pos(posX - 16, display.height - 16)
	end

	return 
end
heroBag.bagsize2row = function (self, bagSize)
	return math.ceil(bagSize/5)
end
heroBag.reloadAll = function (self, bagSize, first, from)
	if self.bagSize == bagSize then
		return 
	end

	self.bagSize = bagSize

	if self.content then
		self.content:removeSelf()
	end

	self.content = display.newNode():add2(self)
	local space = 45
	local itemTotalHeight = self.bagsize2row(self, bagSize)*space
	local bg1 = res.get2("pic/panels/heroBag/bg1.png")
	local bg2 = res.get2("pic/panels/heroBag/bg2.png")
	local bg3 = res.get2("pic/panels/heroBag/bg3.png")

	self.size(self, cc.size(bg1.getw(bg1), (bg1.geth(bg1) + bg3.geth(bg3) + itemTotalHeight) - 12)):scale(g_data.client.lastScale.heroBag):resetPanelPosition((from == "bag" and "right") or "left")

	if not first then
		self.removeTouchFrame(self, "main")
		self.addTouchFrame(self, cc.rect(0, 0, self.getw(self), self.geth(self)), "main")
	end

	bg1.anchor(bg1, 0, 1):pos(0, self.geth(self)):add2(self.content)
	bg2.anchor(bg2, 0, 0):scaley((self.geth(self) - bg1.geth(bg1) - bg3.geth(bg3))/bg2.geth(bg2)):pos(0, bg3.geth(bg3)):add2(self.content)
	bg3.anchor(bg3, 0, 0):add2(self.content)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}).anchor(slot9, 1, 1):pos(self.getw(self) - 6, self.geth(self) - 5):addto(self.content)

	local scaleBtn = nil
	scaleBtn = an.newBtn(res.gettex2("pic/common/scaleBig20.png"), function ()
		sound.playSound("103")
		self:stopAllActions()

		local scale = self:getScale() + 0.1

		if 1.6 < scale then
			scale = 1
		end

		self._scale = scale

		self:scaleTo(0.3, scale)
		g_data.client:setLastScale("heroBag", scale)
		scaleBtn.label:setString("x" .. string.format("%01d", (scale - 1)*10 + 1))

		return 
	end, {
		pressImage = res.gettex2("pic/common/scaleBig21.png"),
		label = {
			"x" .. string.format("%01d", (self.getScale(slot0) - 1)*10 + 1),
			20,
			1,
			{
				color = def.colors.btn40
			}
		},
		labelOffset = {
			x = 13,
			y = -12
		}
	}):pos(255, 28):add2(self.content)

	for i = 1, bagSize, 1 do
		local col = (i - 1)%5
		local line = math.modf((i - 1)/5)

		res.get2("pic/common/itembg2.png"):pos(col*space + 47, self.geth(self) - 78 - line*space):add2(self.content)
	end

	self.items = {}

	self.reload(self)

	return 
end
heroBag.reload = function (self)
	for k, v in pairs(self.items) do
		v.removeSelf(v)
	end

	self.items = {}

	for i = 1, 40, 1 do
		local v = g_data.heroBag.items[i]

		if v then
			self.items[i] = item.new(v, self, {
				idx = i
			}):addto(self.content):pos(self.idx2pos(self, i))
			self.items[i].owner = "heroBag"
		end
	end

	return 
end
heroBag.idx2pos = function (self, idx)
	idx = idx - 1
	local h = idx%5
	local v = math.modf(idx/5)

	return h*item.w + 47, self.geth(self) - 78 - v*item.h
end
heroBag.pos2idx = function (self, x, y)
	local h = (x - 47)/item.w + 0.5
	local v = (self.geth(self) - 78 - y)/item.h + 0.5

	if 0 < h and h < 5 and 0 < v and v < 8 then
		return math.floor(v)*5 + math.floor(h) + 1
	end

	return -1
end
heroBag.addItem = function (self, makeIndex)
	local i, v = g_data.heroBag:getItem(makeIndex)

	if v then
		if self.items[i] then
			self.items[i]:removeSelf()
		end

		self.items[i] = item.new(v, self, {
			idx = i
		}):addto(self.content):pos(self.idx2pos(self, i))
		self.items[i].owner = "heroBag"
	end

	return 
end
heroBag.delItem = function (self, makeIndex)
	for k, v in pairs(self.items) do
		if v.data.FItemIdent == tonumber(makeIndex) then
			self.items[k]:removeSelf()

			self.items[k] = nil

			break
		end
	end

	return 
end
heroBag.uptItem = function (self, makeIndex)
	local i, v = g_data.heroBag:getItem(makeIndex)

	if v and self.items[i] then
		self.items[i].data = v
	end

	return 
end
heroBag.putInItem = function (self, item)
	if not g_data.client.heroPutInItem then
		local data = item.data

		if main_scene.ui.panels.bag then
			main_scene.ui.panels.bag:delItem(data.FItemIdent)
		end

		g_data.bag:delItem(data.FItemIdent)
		g_data.client:setHeroPutInItem(data)

		local makeIndex = data.FItemIdent

		net.send({
			CM_HERO_TOHEROBAG,
			recog = makeIndex
		}, {
			data.getVar(data, "name")
		})
	end

	return 
end
heroBag.getBackItem = function (self, item)
	if not g_data.client.heroGetBackItem then
		local data = item.data

		self.delItem(self, data.FItemIdent)
		g_data.heroBag:delItem(data.FItemIdent)
		g_data.client:setHeroGetBackItem(data)

		local makeIndex = data.FItemIdent

		net.send({
			CM_HERO_TOHUMBAG,
			recog = makeIndex
		}, {
			data.getVar(data, "name")
		})
	end

	return 
end
heroBag.putItem = function (self, item, x, y)
	local form = item.formPanel.__cname

	if form == "bag" then
		self.putInItem(self, item)
	elseif form == "heroEquip" then
		item.takeOff(item)
	elseif form == "heroBag" then
		local putIdx = self.pos2idx(self, x/self.getScale(self), y/self.getScale(self))

		if putIdx == -1 or item.params.idx == putIdx then
			return 
		end

		local srcIdx = item.params.idx

		if g_data.heroBag:isAallCanPileUp(srcIdx, putIdx) then
			local item1 = self.items[putIdx].data
			local makeIndex2 = self.items[srcIdx].data.FItemIdent

			if item1.isNeedResetPos(item1, self.items[srcIdx].data) then
				self.items[putIdx]:pos(self.idx2pos(self, putIdx))
				self.items[srcIdx]:pos(self.idx2pos(self, srcIdx))
			end

			net.send({
				CM_PILEUPITEM,
				series = 1,
				recog = item1.FItemIdent,
				param = Loword(makeIndex2),
				tag = Hiword(makeIndex2)
			})
			g_data.player:setIsinPileUping(true)
		else
			item.params.idx = putIdx

			item.pos(item, self.idx2pos(self, putIdx))

			local target = self.items[putIdx]

			if target then
				target.params.idx = srcIdx

				target.pos(target, self.idx2pos(self, srcIdx))
			end

			self.items[putIdx] = item
			self.items[srcIdx] = target

			g_data.heroBag:changePos(srcIdx, putIdx)
		end

		return true
	end

	return 
end
heroBag.duraChange = function (self, makeindex)
	for k, v in pairs(self.items) do
		if makeindex == v.data.FItemIdent then
			v.duraChange(v)

			return 
		end
	end

	return 
end

return heroBag
