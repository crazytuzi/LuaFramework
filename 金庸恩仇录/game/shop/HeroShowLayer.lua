local data_jiuguan_jiuguan = require("data.data_jiuguan_jiuguan")

local Item = class("Item", function()
	return CCTableViewCell:new()
end)

local CELLSIZE = cc.size(display.width, 140)
function Item:getContentSize()
	return CELLSIZE
end

function Item:create(param)
	local _viewSize = param.viewSize
	local proxy = CCBProxy:create()
	self._rootnode = {}
	self._bg = CCBuilderReaderLoad("shop/shop_show_item.ccbi", proxy, self._rootnode, display.newNode(), _viewSize)
	self._bg:setPosition(_viewSize.width / 2, 0)
	self:addChild(self._bg)
	for i = 1, 5 do
		local heroNameLabel = ui.newTTFLabelWithShadow({
		text = "",
		size = 20,
		font = FONTS_NAME.font_fzcy,
		dimensions = cc.size(120, 80),
		align = ui.TEXT_ALIGN_CENTER,
		valign = ui.TEXT_VALIGN_CENTER,
		color = FONT_COLOR.WHITE,
		shadowColor = FONT_COLOR.BLACK,
		})
		local name = string.format("heroNameLabel_%d", i)
		ResMgr.replaceKeyLableEx(heroNameLabel, self._rootnode, name, 0, 0, 10000)
		heroNameLabel:align(display.CENTER)
	end
	self:refresh(param)
	return self
end

function Item:refresh(param)
	local _itemData = param.itemData
	for i = 1, 5 do
		if _itemData[i] then
			self._rootnode[string.format("headIcon_%d", i)]:setVisible(true)
			self._rootnode[string.format("heroNameLabel_%d", i)]:setString(_itemData[i].name)
			self._rootnode[string.format("heroNameLabel_%d", i)]:setColor(NAME_COLOR[_itemData[i].star[1]])
			ResMgr.refreshIcon({
			id = _itemData[i].id,
			resType = ResMgr.HERO,
			itemBg = self._rootnode[string.format("iconSprite_%d", i)]
			})
		else
			self._rootnode[string.format("headIcon_%d", i)]:setVisible(false)
		end
	end
end

local HeroShowLayer = class("HeroShowLayer", function()
	return require("utility.ShadeLayer").new(ccc4(0, 0, 0, 0))
end)

local HEROTYPE = {
HAOJIE = 1,
GAOSHO = 2,
XINXIU = 3
}

function HeroShowLayer:ctor()
	self:performWithDelay(function()
		self:setOpacity(170)
		self:init()
	end,
	0.01)
end

function HeroShowLayer:init()
	local tip = {
	[HEROTYPE.HAOJIE] = common:getLanguageString("@huodexk1"),
	[HEROTYPE.GAOSHO] = common:getLanguageString("@huodexk2"),
	[HEROTYPE.XINXIU] = common:getLanguageString("@huodexk3")
	}
	self._viewType = HEROTYPE.HAOJIE
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("shop/shop_hero_show.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	local tipLabel = ui.newTTFLabelWithShadow({
	text = tip[self._viewType],
	font = FONTS_NAME.font_fzcy,
	color = cc.c3b(255, 161, 26),
	shadowColor = display.COLOR_BLACK,
	align = ui.TEXT_ALIGN_LEFT,
	size = 22
	})
	
	ResMgr.replaceKeyLableEx(tipLabel, self._rootnode, "tipLabelNode", 0, 0)
	tipLabel:align(display.LEFT_CENTER)
	
	local function close()
		self:removeSelf()
	end
	
	local function onTabBtn(tag)
		local function handle()
			for i = 1, 3 do
				if tag == i then
					self._rootnode["tab" .. tostring(i)]:setEnabled(false)
					self._rootnode["tab" .. tostring(i)]:setZOrder(4)
				else
					self._rootnode["tab" .. tostring(i)]:setEnabled(true)
					self._rootnode["tab" .. tostring(i)]:setZOrder(3 - i)
				end
			end
			self._viewType = tag
			self._scrollView:resetCellNum(#self._listData[self._viewType])
			local num = #self._listData[self._viewType]
			self._scrollView:setContentOffset(ccp(0, self._rootnode.scrollView:getContentSize().height - num * CELLSIZE.height))
			tipLabel:setString(tip[tag])
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian))
		end
		return handle
	end
	local function initTab()
		for i = 1, 3 do
			self._rootnode["tab" .. tostring(i)]:addHandleOfControlEvent(onTabBtn(i), CCControlEventTouchUpInside)
		end
	end
	self._rootnode.closeBtn:addHandleOfControlEvent(close, CCControlEventTouchUpInside)
	self._listData = {
	[HEROTYPE.HAOJIE] = {},
	[HEROTYPE.GAOSHO] = {},
	[HEROTYPE.XINXIU] = {}
	}
	self:initScrollView()
	initTab()
	self:groupHero()
	onTabBtn(self._viewType)()
end

function HeroShowLayer:groupHero()
	local heroGroup = {}
	heroGroup[HEROTYPE.HAOJIE] = {}
	heroGroup[HEROTYPE.GAOSHO] = {}
	heroGroup[HEROTYPE.XINXIU] = {}
	for _, v in ipairs(data_jiuguan_jiuguan) do
		for _, vv in pairs(HEROTYPE) do
			if v.arr_zhaomu[vv] == 1 then
				table.insert(heroGroup[vv], v.cardid)
			end
		end
	end
	for _, heroType in pairs(HEROTYPE) do
		local t = self._listData[heroType]
		for k, v in ipairs(heroGroup[heroType]) do
			if k % 5 == 1 then
				table.insert(t, {})
			end
			table.insert(t[#t], ResMgr.getCardData(v))
		end
	end
end

function HeroShowLayer:initScrollView()
	self._scrollView = require("utility.TableViewExt").new({
	size = cc.size(self._rootnode.scrollView:getContentSize().width, self._rootnode.scrollView:getContentSize().height),
	direction = kCCScrollViewDirectionVertical,
	createFunc = function(idx)
		idx = idx + 1
		return Item.new():create({
		viewSize = self._rootnode.scrollView:getContentSize(),
		idx = idx,
		itemData = self._listData[self._viewType][idx]
		})
	end,
	refreshFunc = function(cell, idx)
		idx = idx + 1
		cell:refresh({
		idx = idx,
		itemData = self._listData[self._viewType][idx]
		})
	end,
	cellNum = #self._listData[self._viewType],
	cellSize = CELLSIZE
	})
	self._scrollView:setPosition(0, 0)
	self._rootnode.scrollView:addChild(self._scrollView)
end

return HeroShowLayer