local common = import("..common.common")
local item = import("..common.item")
local itemInfo = import("..common.itemInfo")
local flyshoe = class("flyshoe", function ()
	return display.newNode()
end)

table.merge(slot3, {})

flyshoe.ctor = function (self, params)
	self._supportMove = true
	params = params or {}
	local bg = res.get2("pic/common/tabbg.png"):addTo(self):anchor(0, 0)
	local bp = res.get2("pic/common/bottompic.png"):anchor(0, 0)

	self.size(self, bg.getContentSize(bg)):anchor(0.5, 0.5):center()
	display.newScale9Sprite(res.getframe2("pic/scale/tabbg.png"), 0, 0, cc.size(130, 395)):anchor(0, 0):pos(18, 18):addTo(bg)
	display.newScale9Sprite(res.getframe2("pic/scale/tabbg.png"), 0, 0, cc.size(222, 395)):anchor(0, 0):pos(150, 18):addTo(bg)
	bp.add2(bp, bg):pos(18, 377)
	bp.clone(bp):add2(bg):pos(112, 413):setRotation(90)
	bp.clone(bp):add2(bg):pos(54, 19):setRotation(270)
	bp.clone(bp):add2(bg):pos(148, 55):setRotation(180)
	bp.clone(bp):add2(bg):pos(150, 377)
	bp.clone(bp):add2(bg):pos(336, 413):setRotation(90)
	bp.clone(bp):add2(bg):pos(186, 19):setRotation(270)
	bp.clone(bp):add2(bg):pos(372, 55):setRotation(180)
	an.newLabel("飞鞋", 22, 1, {
		color = def.colors.title
	}):addTo(bg):pos(bg.getw(bg)/2, bg.geth(bg) - 15):anchor(0.5, 1)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}).addTo(slot4, bg):pos(bg.getw(bg) - 12, bg.geth(bg) - 12):anchor(1, 1)

	local strs_ = {
		"常用传送",
		"主城传送",
		"洞穴传送",
		"魔王传送",
		"角色传送",
		"其他传送"
	}
	local shoeTips = an.newLabel("当前飞鞋:", 18, 0, {
		color = def.colors.btn
	}):anchor(0, 0.5):pos(160, 65):add2(self)
	self.shoeCountLabel = an.newLabel(g_data.player.ability.FFlyShoeCounts, 18, 0, {
		color = def.colors.text
	}):anchor(0, 0.5):pos(shoeTips.getPositionX(shoeTips) + shoeTips.getw(shoeTips) + 1, 65):add2(self)
	local useTips = an.newLabel("传送1次需消耗飞鞋:", 18, 0, {
		color = def.colors.btn
	}):anchor(0, 0.5):pos(160, 35):add2(self)
	self.useShoeLabel = an.newLabel("", 18, 0, {
		color = def.colors.text
	}):anchor(0, 0.5):pos(useTips.getPositionX(useTips) + useTips.getw(useTips) + 1, 35):add2(self)
	self.tabs = common.tabs(bg, {
		size = 20,
		strs = strs_,
		lc = {
			normal = def.colors.btn
		}
	}, function (idx, btn)
		self:processUpt(idx, g_data.flyMap[idx])

		return 
	end, {
		tabTp = 2,
		repeatClk = true,
		pos = {
			offset = 50,
			x = 30,
			y = self.geth(common) - 92,
			anchor = cc.p(0, 0.5)
		}
	})

	g_data.eventDispatcher:addListener("FLYSHOE_COUNTS", self, self.handleShoe)
	self.setNodeEventEnabled(self, true)

	return 
end
flyshoe.onExit = function (self)
	g_data.eventDispatcher:removeListener(self)

	return 
end
flyshoe.processUpt = function (self, idx, items)
	if self.curSubIdx == idx then
		return 
	end

	self.curSubIdx = idx

	if self.content then
		self.content:removeSelf()

		self.content = nil
	end

	if not items then
		return 
	end

	self.content = display.newNode():addTo(self)
	local infoView = an.newScroll(150, 74, 240, 332):add2(self.content)

	infoView.setScrollSize(infoView, 240, math.max(324, math.modf((#items - 1)/2)*25))

	local index = 0

	for k, v in ipairs(items) do
		local node = an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			if main_scene.ground.player.die then
				return 
			end

			if g_data.player.ability.FLevel < v.NeedLv then
				local strlvl = common.getLevelText(v.NeedLv)

				main_scene.ui:tip("等级达到" .. strlvl .. "级后开启此传送功能！")

				return 
			end

			if g_data.player.ability.FFlyShoeCounts < v.NeedFlyShoeCnt then
				main_scene.ui:tip("飞鞋数量不足")

				return 
			end

			local rsb = DefaultClientMessage(CM_FLY_SHOE)
			rsb.FMapId = v.PlaceIdx

			MirTcpClient:getInstance():postRsb(rsb)

			if v.CloseFlyUi == 1 then
				self:hidePanel()
			end

			common.stopAuto()

			return 
		end, {
			support = "scroll",
			pressImage = res.gettex2("pic/common/btn21.png"),
			label = {
				v.PlaceName,
				18,
				0,
				{
					color = def.colors.btn
				}
			}
		}).anchor(slot10, 0, 1)

		if g_data.player.ability.FLevel < v.NeedLv then
			res.get2("pic/panels/flyshoe/lock.png"):add2(node):pos(3, 27)
		end

		node.index = index

		node.pos(node, (index%2 ~= 0 and 120) or 8, infoView.getScrollSize(infoView).height - math.modf(index/2)*(node.geth(node) + 5)):add2(infoView)
		node.setTouchSwallowEnabled(node, false)

		index = index + 1

		self.useShoeLabel:setString(v.NeedFlyShoeCnt)
	end

	return 
end
flyshoe.handleShoe = function (self, shoeCounts)
	self.shoeCountLabel:setString(shoeCounts)

	return 
end

return flyshoe
