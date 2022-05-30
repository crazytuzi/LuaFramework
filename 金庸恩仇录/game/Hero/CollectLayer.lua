local data_item_item = require("data.data_item_item")

local CollectLayer = class("CollectLayer", function()
	return require("utility.ShadeLayer").new()
end)

function CollectLayer:ctor(itemId, itemType)
	local colType = itemType or ResMgr.HERO
	local trName = ""
	if colType == ResMgr.HERO then
		trName = common:getLanguageString("@Hero")
	elseif colType == ResMgr.PET then
		trName = common:getLanguageString("@pet")
	elseif colType == ResMgr.CHEATS then
		trName = common:getLanguageString("@Cheats")
	elseif data_item_item[itemId].para2 == ITEM_TYPE.shizhuang then
		trName = common:getLanguageString("@shizhuang")
	else
		trName = common:getLanguageString("@Equit")
	end
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("hero/hero_collect.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	
	local closeBtn = self._rootnode.closeBtn
	closeBtn:addHandleOfControlEvent(function()
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	local headIcon = display.newSprite()
	headIcon:setPosition(self._rootnode.head_node:getContentSize().width / 2, self._rootnode.head_node:getContentSize().height / 2)
	self._rootnode.head_node:addChild(headIcon)
	ResMgr.refreshIcon({
	itemBg = headIcon,
	id = itemId,
	resType = colType
	})
	self.iconName = ui.newTTFLabelWithShadow({
	text = common:getLanguageString("@Hurrey"),
	font = FONTS_NAME.font_haibao,
	size = 28,
	align = ui.TEXT_ALIGN_CENTER,
	color = display.COLOR_WHITE,
	shadowColor = display.COLOR_BLACK,
	})
	self.iconName:setPosition(self._rootnode.name:getContentSize().width / 2, self._rootnode.name:getContentSize().height / 2)
	self._rootnode.name:addChild(self.iconName)
	self.starNum = data_item_item[itemId].quality
	local nameStr = data_item_item[itemId].name
	self.iconName:setString(nameStr)
	self.iconName:setColor(NAME_COLOR[self.starNum])
	
	local colMsg = ui.newTTFLabel({
	text = common:getLanguageString("@Gether") .. data_item_item[itemId].para1 .. common:getLanguageString("@GetherPieceToCompound") .. trName,
	size = 24,
	color = cc.c3b(87, 53, 34),
	align = ui.TEXT_ALIGN_LEFT,
	dimensions = cc.size(350, 60),
	valign = ui.TEXT_VALIGN_TOP,
	})
	colMsg:setAnchorPoint(cc.p(0, 0.5))
	self._rootnode.desc:addChild(colMsg)
	
	local boardBg = self._rootnode.inner_bg
	self._curLevel = {}
	local function createList()
		self._rootnode.not_loot:setVisible(false)
		local function createFunc(idx)
			local item = require("game.Hero.HeroCollectCell").new()
			return item:create({
			id = idx,
			viewSize = cc.size(boardBg:getContentSize().width, boardBg:getContentSize().height * 0.95),
			listData = data_item_item[itemId].output,
			lvlData = self.lvlData
			})
		end
		local refreshFunc = function(cell, idx)
			cell:refresh(idx + 1)
		end
		local itemList = require("utility.TableViewExt").new({
		size = self._rootnode.inner_bg:getContentSize(),
		direction = kCCScrollViewDirectionVertical,
		createFunc = createFunc,
		refreshFunc = refreshFunc,
		cellNum = #data_item_item[itemId].output,
		cellSize = require("game.Hero.HeroCollectCell").new():getContentSize()
		})
		self._rootnode.inner_bg:addChild(itemList)
	end
	local function createNothingFont()
		self._rootnode.not_loot:setVisible(true)
	end
	local function _callback(errorCode, mapData)
		if errorCode == "" then
			self.lvlData = mapData
			if data_item_item[itemId].output ~= nil and #data_item_item[itemId].output ~= 0 then
				createList()
			else
				createNothingFont()
			end
		else
			CCMessageBox(errorCode, "server data error")
		end
	end
	MapModel:requestMapData(bigMapID, _callback)
end

return CollectLayer