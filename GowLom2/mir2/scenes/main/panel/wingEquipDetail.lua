local wingEquipDetail = class("wingEquipDetail", import(".panelBase"))
wingEquipDetail.ctor = function (self, wingEquipType)
	self.super.ctor(self)
	self.setMoveable(self, true)

	self.wingEquipType = wingEquipType

	return 
end
wingEquipDetail.onEnter = function (self)
	local tabstr = {
		"爆\n率",
		"记\n录"
	}
	local tabcb = {
		self.loadBaoLv,
		self.loadRecord
	}
	self.tabCallbacks = tabcb
	self.page = 1

	self.initPanelUI(self, {
		bg = "pic/common/tabbg.png",
		titleOffsetY = -5,
		closeOffsetY = -5,
		title = "爆率查看",
		tab = {
			lableOffestX = -4,
			leftmargin = 415,
			strs = tabstr,
			default = self.page,
			file = {
				select = "pic/common/btn113.png",
				normal = "pic/common/btn112.png"
			}
		}
	})
	self.pos(self, display.cx + 200, display.cy)
	self.bindNetEvent(self, SM_QueryWEDropOutInfo, self.onSM_QueryWEDropOutInfo)

	return 
end
wingEquipDetail.onTabClick = function (self, idx, btn)
	self.clearContentNode(self)

	self.curTab = self.tabCallbacks[idx]
	self.curIdx = idx

	self.tabCallbacks[idx](self)

	return 
end
wingEquipDetail.clearContentNode = function (self)
	if self.contentNode then
		self.contentNode:removeAllChildren()
	end

	self.contentNode = display.newNode():addTo(self.bg)
	self.contentNode.controls = {}
	self.contentNode.data = {}

	return 
end
wingEquipDetail.loadBaoLv = function (self)
	self.setTitle(self, "爆率查看")

	local wingEquipTypes = def.wingEquip.getWingEquipTypes()
	self.contentNode.controls.typeItems = {}

	local function onTypeSelect(btn)
		local typeItems = self.contentNode.controls.typeItems

		for k, v in ipairs(typeItems) do
			if v.type ~= btn.type then
				v.unselect(v)
				v.setTouchEnabled(v, true)
				v.setLocalZOrder(v, 0)
				v.label:setColor(def.colors.Ca58566)
			end
		end

		btn.select(btn)
		btn.setTouchEnabled(btn, false)
		btn.setLocalZOrder(btn, 1)
		btn.label:setColor(def.colors.Ce3c396)
		self:upgradeBaoLvScroll(btn.type)

		return 
	end

	local typeItems = {}

	for k, v in ipairs(slot1) do
		local item = an.newBtn(res.gettex2("pic/panels/equip/btn0.png"), function (btn)
			sound.playSound("103")
			onTypeSelect(btn)

			return 
		end, {
			select = {
				res.gettex2("pic/panels/equip/btn1.png")
			},
			label = {
				v,
				18,
				0,
				{
					color = def.colors.Ce3c396
				}
			}
		}).anchor(slot9, 0, 0):pos((k - 1)*80 + 20, 387):addTo(self.contentNode)
		item.type = v
		typeItems[#typeItems + 1] = item
	end

	self.contentNode.controls.typeItems = typeItems

	display.newSprite(res.gettex2("pic/panels/wingUpgrade/wingEquip/line.png")):anchor(0, 0):pos(14, 375):add2(self.contentNode)

	local Titlelabel = {
		"等级",
		"爆率",
		"损失"
	}
	local titlebg = display.newScale9Sprite(res.getframe2("pic/panels/guild/titlebg.png"), 0, 0, cc.size(333, 42)):anchor(0, 1):pos(15, 376):add2(self.contentNode)

	display.newScale9Sprite(res.getframe2("pic/panels/guild/split.png"), 0, 0, cc.size(4, 42)):anchor(0, 0):pos(111, 0):add2(titlebg)
	display.newScale9Sprite(res.getframe2("pic/panels/guild/split.png"), 0, 0, cc.size(4, 42)):anchor(0, 0):pos(222, 0):add2(titlebg)

	for k, v in ipairs(Titlelabel) do
		an.newLabel(v, 20, 0, {
			color = def.colors.Cf0c896
		}):anchor(0.5, 0.5):pos((k - 1)*111 + 55.5, titlebg.geth(titlebg)/2):addTo(titlebg)
	end

	local rect = cc.rect(10, 16, 340, 319)
	local scroll = self.newListView(self, rect.x, rect.y, rect.width, rect.height, 4, {}):add2(self.contentNode)
	local rollbg = display.newScale9Sprite(res.getframe2("pic/common/sliderBg4.png"), 350, 16, cc.size(20, 400)):addTo(self.contentNode):anchor(0, 0)
	local rollCeil = res.get2("pic/common/scrollShow.png"):anchor(0.5, 0):pos(rollbg.getw(rollbg)*0.5, rollbg.geth(rollbg) - 42):add2(rollbg)

	scroll.setListenner(scroll, function (event)
		if event.name == "moved" then
			local x, y = scroll:getScrollOffset()
			local maxOffset = scroll:getScrollSize().height - scroll:geth()

			if y < 0 then
				y = 0
			end

			if maxOffset < y then
				y = maxOffset or y
			end

			local s = (rollbg:geth() - 42)*(y/maxOffset - 1)

			rollCeil:setPositionY(s)
		end

		return 
	end)

	self.contentNode.controls.scroll = scroll
	self.contentNode.controls.rollbg = rollbg
	self.contentNode.controls.rollCeil = rollCeil

	if 0 < #typeItems and self.wingEquipType then
		for k, v in ipairs(slot3) do
			if v.type == self.wingEquipType then
				onTypeSelect(v)
			end
		end
	end

	return 
end
wingEquipDetail.upgradeBaoLvScroll = function (self, type)
	if not type or type == "" then
		return 
	end

	local scroll = self.contentNode.controls.scroll

	if scroll then
		scroll.removeAllChildren(scroll)
		scroll.setScrollOffset(scroll, 0, 0)
	end

	local baolvTable = def.wingEquip.getBaoLv(type)
	local cellHeight = 42
	local rect = cc.rect(10, 16, 340, 319)

	scroll.setScrollSize(scroll, rect.width, math.max(rect.height + 1, #baolvTable*cellHeight))

	local posY = math.max(rect.height + 1, #baolvTable*cellHeight)

	for k, v in ipairs(baolvTable) do
		local cellBg = res.getframe2((k%2 == 0 and "pic/scale/scale18.png") or "pic/scale/scale19.png")
		local cell = an.newBtn(cellBg, function ()
			return 
		end, {
			support = "scroll",
			scale9 = cc.size(340, slot4)
		}):anchor(0, 1):pos(5, posY):addto(scroll)

		an.newLabel(v.level .. "级", 20, 0, {
			color = def.colors.Cf0c896
		}):anchor(0.5, 0.5):pos(55.5, cell.geth(cell)/2):addTo(cell)
		an.newLabel(v.percent .. "%", 20, 0, {
			color = def.colors.Cf0c896
		}):anchor(0.5, 0.5):pos(166.5, cell.geth(cell)/2):addTo(cell)
		an.newLabel(v.value .. "羽灵", 20, 0, {
			color = def.colors.Cf0c896
		}):anchor(0.5, 0.5):pos(277.5, cell.geth(cell)/2):addTo(cell)

		posY = posY - cellHeight
	end

	local rollbg = self.contentNode.controls.rollbg
	local rollCeil = self.contentNode.controls.rollCeil

	rollCeil.pos(rollCeil, rollbg.getw(rollbg)*0.5, rollbg.geth(rollbg) - 42)

	return 
end
wingEquipDetail.loadRecord = function (self)
	self.setTitle(self, "爆出记录")

	local Titlelabel = {
		"时间",
		"爆出羽装",
		"损失羽灵"
	}
	local titlebg = display.newScale9Sprite(res.getframe2("pic/panels/guild/titlebg.png"), 0, 0, cc.size(333, 42)):anchor(0, 1):pos(15, 417):add2(self.contentNode)

	display.newScale9Sprite(res.getframe2("pic/panels/guild/split.png"), 0, 0, cc.size(4, 42)):anchor(0, 0):pos(111, 0):add2(titlebg)
	display.newScale9Sprite(res.getframe2("pic/panels/guild/split.png"), 0, 0, cc.size(4, 42)):anchor(0, 0):pos(222, 0):add2(titlebg)

	for k, v in ipairs(Titlelabel) do
		an.newLabel(v, 20, 0, {
			color = def.colors.Cf0c896
		}):anchor(0.5, 0.5):pos((k - 1)*111 + 55.5, titlebg.geth(titlebg)/2):addTo(titlebg)
	end

	local rect = cc.rect(0, 0, 340, 360)
	local scroll = self.newListView(self, 10, 16, rect.width, rect.height, 4, {}):add2(self.contentNode)

	scroll.setScrollSize(scroll, rect.width, math.max(rect.height + 1, 0))

	local rollbg = display.newScale9Sprite(res.getframe2("pic/common/sliderBg4.png"), 350, 16, cc.size(20, 400)):addTo(self.contentNode):anchor(0, 0)
	local rollCeil = res.get2("pic/common/scrollShow.png"):anchor(0.5, 0):pos(rollbg.getw(rollbg)*0.5, rollbg.geth(rollbg) - 42):add2(rollbg)

	scroll.setListenner(scroll, function (event)
		if event.name == "moved" then
			local x, y = scroll:getScrollOffset()
			local scrollHeight = self.scrollHeight
			local maxOffset = scroll:getScrollSize().height - scroll:geth()

			if y < 0 then
				y = 0
			end

			if maxOffset < y then
				y = maxOffset or y
			end

			local s = (rollbg:geth() - 42)*(y/maxOffset - 1)

			rollCeil:setPositionY(s)
		end

		return 
	end)

	self.contentNode.controls.scroll = scroll
	local rsb = DefaultClientMessage(CM_QueryWEDropOutInfo)

	MirTcpClient.getInstance(slot8):postRsb(rsb)

	return 
end
wingEquipDetail.UpdateRecord = function (self, result)
	local scroll = self.contentNode.controls.scroll

	if scroll then
		scroll.removeAllChildren(scroll)
	end

	local cellHeight = 42
	local rect = cc.rect(0, 0, 340, 360)

	scroll.setScrollSize(scroll, rect.width, math.max(rect.height + 1, #result.FWEDropOutInfoList*cellHeight))

	local posY = math.max(rect.height + 1, #result.FWEDropOutInfoList*cellHeight)

	for k, v in ipairs(result.FWEDropOutInfoList) do
		local cellBg = res.getframe2((k%2 == 0 and "pic/scale/scale18.png") or "pic/scale/scale19.png")
		local cell = an.newBtn(cellBg, function ()
			return 
		end, {
			support = "scroll",
			scale9 = cc.size(330, slot3)
		}):anchor(0, 1):pos(5, posY):addto(scroll)
		local timeStr = os.date("%Y-%m-%d|%H:%M:%S", v.FLossTime)
		local strs = string.split(timeStr, "|")

		if #strs == 2 then
			an.newLabel(strs[1], 18, 0, {
				color = def.colors.Cf0c896
			}):anchor(0.5, 0.5):pos(55.5, cell.geth(cell)/2 + 10):addTo(cell)
			an.newLabel(strs[2], 18, 0, {
				color = def.colors.Cf0c896
			}):anchor(0.5, 0.5):pos(55.5, cell.geth(cell)/2 - 10):addTo(cell)
		end

		local typeName = def.wingEquip.getWingEquipTypeName(v.FID)

		an.newLabel(typeName, 18, 0, {
			color = def.colors.Cf0c896
		}):anchor(0.5, 0.5):pos(166.5, cell.geth(cell)/2):addTo(cell)
		an.newLabel(v.FLossValue, 18, 0, {
			color = def.colors.Cf0c896
		}):anchor(0.5, 0.5):pos(277.5, cell.geth(cell)/2):addTo(cell)

		posY = posY - cellHeight
	end

	return 
end
wingEquipDetail.onSM_QueryWEDropOutInfo = function (self, result)
	if not result then
		return 
	end

	if self.curTab == self.loadRecord then
		self.UpdateRecord(self, result)
	end

	return 
end

return wingEquipDetail
