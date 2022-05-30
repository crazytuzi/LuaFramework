local HandBookCell = class("HandBookCell", function(data)
	return display.newNode()
end)

function HandBookCell:ctor(param)
	local cellData = param.cellData
	local cellStar = param.cellStar
	self._proxy = CCBProxy:create()
	self._touchs = {}
	self._rootnode = {}
	local bgNode = CCBuilderReaderLoad("handbook/handbook_cell.ccbi", self._proxy, self._rootnode)
	self:addChild(bgNode)
	local orX = -self._rootnode.cell_bg:getContentSize().width / 2 + 75
	local orY = -45 - self._rootnode.star_bg:getContentSize().height / 2 - 40
	local curX = orX
	local curY = orY
	local arrId = cellData.data.arr_id
	local star = cellData.data.star
	for i = 1, 5 do
		if i > star then
			self._rootnode["star_" .. i]:setVisible(false)
		end
	end
	local resType = ResMgr.HERO
	local itemType = 8
	local item_hero_type = 8
	local item_equip_type = 1
	local item_wugong_type = 4
	if cellData.data.mainTab == 1 then
		resType = ResMgr.HERO
		itemType = ITEM_TYPE.xiake
	elseif cellData.data.mainTab == 2 then
		if cellData.data.subTab == 5 then
			resType = ResMgr.FASHION
			itemType = ITEM_TYPE.shizhuang
		else
			resType = ResMgr.EQUIP
			itemType = ITEM_TYPE.zhuangbei
		end
	elseif cellData.data.mainTab == 3 then
		resType = ResMgr.EQUIP
		itemType = ITEM_TYPE.wuxue
	elseif cellData.data.mainTab == 4 then
		resType = ResMgr.CHEATS
		itemType = ITEM_TYPE.cheats
	elseif cellData.data.mainTab == 5 then
		resType = ResMgr.PET
		itemType = ITEM_TYPE.chongwu
	end
	
	local iconHeight = 105
	local iconCount = 1
	local exNum = 0
	local isIconGray = true
	for i = 1, #arrId do
		do
			local headIcon = display.newSprite()
			isIconGray = true
			if cellData.isExist[i] == 1 then
				isIconGray = false
				exNum = exNum + 1
			end
			ResMgr.refreshItemWithTagNumName({
			id = arrId[i],
			itemBg = headIcon,
			resType = resType,
			isShowIconNum = 0,
			isGray = isIconGray,
			cls = 0
			})
			headIcon:setPosition(curX, curY)
			self:addChild(headIcon)
			local iconWidth = headIcon:getContentSize().width
			local touchNode = require("utility.MyLayer").new({
			size = cc.size(iconWidth, iconHeight),
			swallow = false,
			touch = false,
			touchHandler = function(event, btn)
				if event.name == "ended" and math.abs(event.y - event.startY) <= 5 then
					local itemInfo = require("game.Huodong.ItemInformation").new({
					id = arrId[i],
					type = itemType
					})
					display.getRunningScene():addChild(itemInfo, 100000)
				end
			end
			})
			
			headIcon:addChild(touchNode)
			table.insert(param._touchs, touchNode)
			
			curX = curX + headIcon:getContentSize().height + 20
			if i % 5 == 0 then
				curY = curY - headIcon:getContentSize().height - 32
				curX = orX
			end
			if i > 1 and (i - 1) % 5 == 0 then
				iconCount = iconCount + 1
			end
			iconHeight = headIcon:getContentSize().height + 32
		end
	end
	self._rootnode.cell_bg:setContentSize(cc.size(self._rootnode.cell_bg:getContentSize().width, iconCount * iconHeight + self._rootnode.star_bg:getContentSize().height + 20))
	
	local x = self._rootnode.cell_bg:getContentSize().width - 20
	local y = self._rootnode.cell_bg:getContentSize().height - 25
	
	local totalNum = #arrId
	local totalTTF = ui.newTTFLabelWithShadow({
	text = "/" .. totalNum,
	size = 24,
	color = display.COLOR_WHITE,
	shadowColor = display.COLOR_BLACK,
	font = FONTS_NAME.font_haibao,
	align = ui.TEXT_ALIGN_RIGHT
	})
	self._rootnode.cell_bg:addChild(totalTTF)
	totalTTF:align(display.RIGHT_CENTER, x, y)
	
	local exTTF = ui.newTTFLabelWithShadow({
	text = exNum,
	size = 24,
	color = cc.c3b(36, 255, 0),
	shadowColor = display.COLOR_BLACK,
	font = FONTS_NAME.font_haibao,
	align = ui.TEXT_ALIGN_RIGHT
	})
	self._rootnode.cell_bg:addChild(exTTF)
	exTTF:align(display.RIGHT_CENTER, x - totalTTF:getContentSize().width, y)
end

function HandBookCell:getHeight()
	return self._rootnode.cell_bg:getContentSize().height + self._rootnode.star_bg:getContentSize().height / 2
end

return HandBookCell