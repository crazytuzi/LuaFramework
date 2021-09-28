local CommonItem = import("..common.item")
local CommonItemInfo = import("..common.itemInfo")
local horseSoulCompSelect = class("horseSoulCompSelect", import(".panelBase"))
horseSoulCompSelect.ctor = function (self, params)
	self.super.ctor(self)
	self.setMoveable(self, true)

	self.levelScrollItems = {}
	self.levelScrollLabels = {}
	self.typeScrollItems = {}
	self.typeScrollLabels = {}
	self.curSelectType = params.selStoneType
	self.curSelectLevel = params.selStoneLevel
	self.scheduleHandles = {}

	return 
end
horseSoulCompSelect.onEnter = function (self)
	self.initPanelUI(self, {
		closeOffsetY = 4,
		title = "请选择合成目标",
		bg = "pic/common/msgbox.png",
		titleOffsetY = 4
	})
	display.newScale9Sprite(res.getframe2("pic/scale/scale56.png")):anchor(0, 0):pos(9, 52):size(400, 194):addTo(self.bg)
	an.newLabel("注：相同等级3颗兽魂石可合成1颗高一级目标兽魂石", 16, 0, {
		color = cc.c3b(197, 158, 100)
	}):anchor(0.5, 0.5):addTo(self.bg):pos(self.bg:getw()/2, self.bg:geth()/2 - 80)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		def.horseSoul.setSelComSoulStone(self.curSelectType, self.curSelectLevel)
		g_data.eventDispatcher:dispatch("HorseSoul_SelStone")

		if self:onCloseWindow() then
			self:hidePanel()
		else
			print("阻止了窗口关闭")
		end

		return 
	end, {
		clickSpace = 1,
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			"确   定",
			18,
			0,
			{
				color = def.colors.Cf0c896
			}
		}
	}).add2(slot1, self.bg):pos(self.bg:getw()/2, self.bg:geth()/2 - 113)
	display.newScale9Sprite(res.getframe2("pic/scale/scale13.png")):anchor(0, 0):pos(10, 75):size(200, 170):addTo(self.bg)
	display.newScale9Sprite(res.getframe2("pic/scale/scale14.png")):anchor(0, 0):pos(212, 75):size(97, 170):addTo(self.bg)
	display.newScale9Sprite(res.getframe2("pic/scale/scale14.png")):anchor(0, 0):pos(311, 75):size(97, 170):addTo(self.bg)

	local height = 166
	self.leftScroll = an.newScroll(12, 77, 196, height):addto(self.bg)
	self.levelScroll = an.newScroll(214, 77, 93, height):addto(self.bg)
	self.typeScroll = an.newScroll(313, 77, 93, height):addto(self.bg)
	local selectBorder = display.newScale9Sprite(res.getframe2("pic/common/select_1.png")):anchor(0, 0):pos(212, 160):size(196, 47):addTo(self.bg)
	local stoneType = def.horseSoul.getAllMonSoulStoneType()

	self.updateStoneType(self, stoneType)

	if self.curSelectType ~= "" and self.curSelectLevel ~= 0 then
		self.setScrollPos(self, self.curSelectType, self.curSelectLevel)
	end

	self.getScrollData(self)

	return 
end
horseSoulCompSelect.onCloseWindow = function (self)
	for k, v in ipairs(self.scheduleHandles) do
		scheduler.unscheduleGlobal(v)
	end

	self.scheduleHandles = {}

	return self.super.onCloseWindow(self)
end
horseSoulCompSelect.setScrollPos = function (self, type, level)
	local typeIdx = 0
	local levelIdx = 0
	local lineHeight = 40

	for k, v in ipairs(self.typeScrollItems) do
		if v == type then
			typeIdx = k
		end
	end

	for k, v in ipairs(self.levelScrollItems) do
		if v == level then
			levelIdx = k
		end
	end

	if typeIdx ~= 0 and levelIdx ~= 0 then
		self.typeScroll:setScrollOffset(0, lineHeight*(typeIdx - 1))
		self.levelScroll:setScrollOffset(0, lineHeight*(levelIdx - 1))
	end

	return 
end
horseSoulCompSelect.updateStoneLevel = function (self, stoneLevel, bReOffset)
	if not self.levelScroll then
		return 
	end

	self.levelScroll:removeAllChildren()

	self.levelScrollItems = {}
	self.levelScrollLabels = {}
	local lineHeight = 40
	local levelNum = #stoneLevel

	self.levelScroll:setScrollSize(93, (levelNum + 3)*lineHeight)

	for k = 1, levelNum + 3, 1 do
		local cellBg = res.getframe2((k%2 == 0 and "pic/scale/scale18.png") or "pic/scale/scale19.png")
		local itemBg = display.newScale9Sprite(cellBg):anchor(0.5, 1):pos(self.levelScroll:getw()/2, (levelNum + 3)*lineHeight - (k - 1)*lineHeight):size(100, lineHeight):addTo(self.levelScroll)

		if 1 < k and k <= levelNum + 1 then
			local label = an.newLabel(stoneLevel[k - 1] .. "级", 20, 0, {
				color = cc.c3b(197, 158, 100)
			}):anchor(0.5, 0.5):addTo(itemBg):pos(itemBg.getw(itemBg)/2, itemBg.geth(itemBg)/2)
			self.levelScrollItems[#self.levelScrollItems + 1] = stoneLevel[k - 1]
			self.levelScrollLabels[#self.levelScrollLabels + 1] = label
		end
	end

	if bReOffset then
		self.levelScroll:setScrollOffset(0, 0)
	end

	self.levelScroll:setListenner(function (event)
		self:doScroll(event, self.levelScroll)

		return 
	end)

	return 
end
horseSoulCompSelect.updateStoneType = function (self, stoneType)
	if not self.typeScroll then
		return 
	end

	self.typeScroll:removeAllChildren()

	self.typeScrollItems = {}
	self.typeScrollLabels = {}
	local lineHeight = 40
	local typeNum = #stoneType

	if typeNum == 0 then
		return 
	end

	self.typeScroll:setScrollSize(93, (typeNum + 3)*lineHeight)

	for k = 1, typeNum + 3, 1 do
		local cellBg = res.getframe2((k%2 == 0 and "pic/scale/scale18.png") or "pic/scale/scale19.png")
		local itemBg = display.newScale9Sprite(cellBg):anchor(0.5, 1):pos(self.typeScroll:getw()/2, (typeNum + 3)*lineHeight - (k - 1)*lineHeight):size(100, lineHeight):addTo(self.typeScroll)

		if 1 < k and k <= typeNum + 1 then
			local label = an.newLabel(stoneType[k - 1], 20, 0, {
				color = cc.c3b(197, 158, 100)
			}):anchor(0.5, 0.5):addTo(itemBg):pos(itemBg.getw(itemBg)/2, itemBg.geth(itemBg)/2)
			self.typeScrollItems[#self.typeScrollItems + 1] = stoneType[k - 1]
			self.typeScrollLabels[#self.typeScrollLabels + 1] = label
		end
	end

	self.typeScroll:setScrollOffset(0, 0)
	self.updateStoneLevel(self, def.horseSoul.getComStoneLevelByType(stoneType[1] or ""), true)
	self.typeScroll:setListenner(function (event)
		self:doScroll(event, self.typeScroll)

		return 
	end)

	return 
end
horseSoulCompSelect.getScrollData = function (self)
	local typeOffX, typeOffY = self.typeScroll:getScrollOffset()
	local levelOffX, levelOffY = self.levelScroll:getScrollOffset()
	local lineHeight = 40

	if #self.typeScrollItems <= 0 then
		return 
	end

	local typeIdx = math.floor(typeOffY/lineHeight + 1)

	if typeIdx <= 0 then
		typeIdx = 1
	end

	if #self.typeScrollItems <= typeIdx then
		typeIdx = #self.typeScrollItems
	end

	local type = self.typeScrollItems[typeIdx]

	if not type then
		return 
	end

	if type ~= self.curSelectType then
		self.curSelectType = type

		self.updateStoneLevel(self, def.horseSoul.getComStoneLevelByType(type), false)
		self.correctOffset(self, self.levelScroll)

		return 
	end

	if #self.levelScrollItems <= 0 then
		return 
	end

	local levelIdx = math.floor(levelOffY/lineHeight + 1)

	if levelIdx <= 0 then
		levelIdx = 1
	end

	if #self.levelScrollItems <= levelIdx then
		levelIdx = #self.levelScrollItems
	end

	local level = self.levelScrollItems[levelIdx]

	if not level then
		return 
	end

	self.curSelectType = type
	self.curSelectLevel = level

	for k, v in ipairs(self.levelScrollLabels) do
		if v then
			v.setColor(v, cc.c3b(197, 158, 100))
		end
	end

	for k, v in ipairs(self.typeScrollLabels) do
		if v then
			v.setColor(v, cc.c3b(197, 158, 100))
		end
	end

	if self.levelScrollLabels[levelIdx] then
		self.levelScrollLabels[levelIdx]:setColor(cc.c3b(255, 255, 255))
	end

	if self.typeScrollLabels[typeIdx] then
		self.typeScrollLabels[typeIdx]:setColor(cc.c3b(255, 255, 255))
	end

	self.updateLeftScroll(self)

	return 
end
horseSoulCompSelect.correctOffset = function (self, scroll)
	if not scroll then
		return 
	end

	local lineHeight = 40
	local x, y = scroll.getScrollOffset(scroll)
	local height = scroll.getScrollSize(scroll).height
	local allLineNum = math.floor(height/lineHeight)

	if y < 0 then
		scroll.setScrollOffset(scroll, 0, y)
	elseif (allLineNum - 4)*lineHeight < y then
		scroll.setScrollOffset(scroll, x, (allLineNum - 4)*lineHeight)
	else
		local passLineHeight = math.floor(y/lineHeight)*lineHeight
		local offset = y - passLineHeight

		if offset ~= 0 or false then
			if offset < lineHeight/2 then
				scroll.setScrollOffset(scroll, x, passLineHeight)
			else
				scroll.setScrollOffset(scroll, x, passLineHeight + lineHeight)
			end
		end
	end

	self.getScrollData(self)

	return 
end
horseSoulCompSelect.doScroll = function (self, event, scroll)
	if event.name == "ended" then
		local lastOffX, lastOffY = scroll.getScrollOffset(scroll)
		scroll.scrollHandle = scheduler.scheduleGlobal(function ()
			if self and self.correctOffset and scroll then
				local curOffX, curOffY = scroll:getScrollOffset()

				if curOffY == lastOffY then
					scheduler.unscheduleGlobal(scroll.scrollHandle)

					local bFind = false

					for k, v in ipairs(self.scheduleHandles) do
						if v == scroll.scrollHandle then
							bFind = true

							table.remove(self.scheduleHandles, k)
						end
					end

					if not bFind then
						for k, v in ipairs(self.scheduleHandles) do
							scheduler.unscheduleGlobal(v)
						end

						self.scheduleHandles = {}
					end

					self:correctOffset(scroll)
				else
					lastOffY = curOffY
				end
			end

			return 
		end, 0.1)
		self.scheduleHandles[#self.scheduleHandles + 1] = scroll.scrollHandle
	end

	return 
end
horseSoulCompSelect.updateLeftScroll = function (self)
	if not self.leftScroll then
		return 
	end

	self.leftScroll:removeAllChildren()

	local texts = {}
	local stoneName = self.curSelectLevel .. "级" .. self.curSelectType
	local itemIdx = def.items.getItemIdByName(stoneName)

	if not itemIdx then
		return 
	end

	local stoneCfg = def.horseSoul.getComSoulStoneByIndex(itemIdx)
	texts[#texts + 1] = stoneName .. ":"

	if stoneCfg and 0 < stoneCfg.CompNeedMonSoulLv then
		texts[#texts + 1] = "需兽魂等级：" .. def.horseSoul.level2str(stoneCfg.CompNeedMonSoulLv)
	end

	local selStoneData = def.items.getStdItemById(itemIdx)
	local selStonePropStr = def.horseSoul.getHorseSoulStoneProps(selStoneData)
	local props = def.property.dumpPropertyStr(selStonePropStr):clearZero():toStdProp()

	for i, v in ipairs(props.props) do
		local p = props.formatPropString(props, v[1], "%s:+%s", "%s:%s-%s")

		table.insert(texts, p)
	end

	for k, v in ipairs(texts) do
		an.newLabel(v, 18, 0, {
			color = cc.c3b(197, 158, 100)
		}):anchor(0, 1):addTo(self.leftScroll):pos(10, self.leftScroll:geth() - k*25 + 25)
	end

	return 
end

return horseSoulCompSelect
