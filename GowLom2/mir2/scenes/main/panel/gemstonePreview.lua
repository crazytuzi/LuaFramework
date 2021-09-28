package.loaded["mir2.scenes.main.panel.gemstoneInfo"] = nil
local gemstoneInfo = import(".gemstoneInfo")
local gemstonePreview = class("gemstonePreview", function ()
	return display.newNode()
end)
ccui.TouchEventType = {
	moved = 1,
	began = 0,
	canceled = 3,
	ended = 2
}

table.merge(slot1, {})

gemstonePreview.ctor = function (self, targetName)
	print("gemstonePreview = ", targetName)
	self.setNodeEventEnabled(self, true)

	self._scale = self.getScale(self)
	self._supportMove = true
	self.rootPanel = ccs.GUIReader:getInstance():widgetFromBinaryFile("ui/gemstonePreview/gemstonePreview_1.csb")

	self.rootPanel:pos(0, 0)

	local bg = self.rootPanel

	self.size(self, bg.getw(bg), bg.geth(bg)):anchor(0.5, 0.5):pos(display.cx + 320, display.cy)
	self.rootPanel:add2(self)

	local function clickClose(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		sound.playSound("103")
		self:hidePanel()

		return 
	end

	local btnClose = ccui.Helper.seekWidgetByName(slot4, self.rootPanel, "Button_close")

	btnClose.addTouchEventListener(btnClose, clickClose)

	local tenGraderItems = {}
	local stepNum = 10

	if targetName == 6 then
		stepNum = 7
	end

	for k, v in pairs(def.gemstone.tConfigData) do
		if v.ID == targetName and 0 < v.DiamondLevel and v.DiamondLevel%stepNum == 0 then
			table.insert(tenGraderItems, v)
		end
	end

	local bg = ccui.Helper:seekWidgetByName(self.rootPanel, "Image_bg")
	local infoView = an.newScroll(10, 8, 175, 400):add2(bg)
	local rollbg = display.newScale9Sprite(res.getframe2("pic/scale/scale9.png"), 174, 8, cc.size(20, 400)):addTo(bg):anchor(0, 0)
	local rollCeil = res.get2("pic/common/scrollShow.png"):anchor(0.5, 0):pos(rollbg.getw(rollbg)*0.5, rollbg.geth(rollbg) - 42):add2(rollbg)

	infoView.setListenner(infoView, function (event)
		if event.name == "moved" then
			local x, y = infoView:getScrollOffset()
			local maxOffset = infoView:getScrollSize().height - infoView:geth()

			if y < 0 then
				y = 0
			end

			if maxOffset < y then
				y = maxOffset or y
			end

			local posY = (rollbg:geth() - 42)*(y/maxOffset - 1)

			rollCeil:setPositionY(posY)
		end

		return 
	end)

	local h = 76
	local num = #tenGraderItems

	if num < 6 then
		num = 6
	end

	local innerH = num*h

	infoView.setScrollSize(slot8, 175, math.max(400, innerH))

	local serverLevel = g_data.login.serverLevel
	local rangePrew = {
		5,
		5,
		6,
		7
	}
	local range = #tenGraderItems

	print("#tenGraderItems", #tenGraderItems)

	if checkExist(targetName, 0, 1, 2, 4) and serverLevel + 1 <= #rangePrew and rangePrew[serverLevel + 1] <= #tenGraderItems then
		range = rangePrew[serverLevel + 1]
	end

	function xingNum(level)
		local xing = stepNum

		return xing
	end

	for i = 1, slot16, 1 do
		local item = ccs.GUIReader:getInstance():widgetFromBinaryFile("ui/gemstoneItem/gemstoneItem_1.csb")

		item.pos(item, 0, infoView.getScrollSize(infoView).height - i*h):add2(infoView)
		ccui.Helper:seekWidgetByName(item, "Label_4_0"):setString(tenGraderItems[i].DiamondType .. "宝石")
		ccui.Helper:seekWidgetByName(item, "Label_lvl"):setString(self.numToGBK(self, math.ceil(tenGraderItems[i].DiamondLevel/stepNum)) .. "阶" .. self.numToGBK(self, xingNum(tenGraderItems[i].DiamondLevel)) .. "星")

		local iconName = self.getIconName(self, tenGraderItems[i].ID, tenGraderItems[i].DiamondLevel)
		local itemBg = ccui.Helper:seekWidgetByName(item, "Image_bg")

		print("iconNameiconName", iconName, itemBg.getName(itemBg))

		if iconName then
			local posNode = display.newNode()

			posNode.pos(posNode, 35, 36)
			posNode.add2(posNode, itemBg)

			local id = tenGraderItems[i].ID
			local level = tenGraderItems[i].DiamondLevel

			an.newBtn(res.gettex2(iconName), function ()
				local data = {
					job = g_data.player.job,
					info = {}
				}
				data.info.FID = id
				data.info.FLevel = level
				local p = posNode:convertToWorldSpace(cc.p(0, 0))
				self.infoLayer = gemstoneInfo.show(data, p, {})

				return 
			end, nil).pos(slot27, 35, 36):add2(itemBg)
		end
	end

	return 
end
gemstonePreview.getIconName = function (self, id, lvl)
	if id == 6 then
		return string.format("pic/panels/gemstones/%d_%d.png", id, math.floor(lvl/7))
	end

	local icons = {
		10,
		20,
		30,
		40,
		50,
		60,
		70,
		80,
		90,
		100
	}

	for i = 1, #icons, 1 do
		if lvl <= icons[i] then
			return string.format("pic/panels/gemstones/%d_%d.png", id, math.floor(icons[i]/10))
		end
	end

	return nil
end
gemstonePreview.numToGBK = function (self, num)
	local TXT_NUM = {
		"一",
		"二",
		"三",
		"四",
		"五",
		"六",
		"七",
		"八",
		"九",
		"十"
	}

	if TXT_NUM[num] then
		return TXT_NUM[num]
	else
		return TXT_NUM[1]
	end

	return 
end

return gemstonePreview
