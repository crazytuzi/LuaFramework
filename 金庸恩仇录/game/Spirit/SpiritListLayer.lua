local data_item_nature = require("data.data_item_nature")
local data_shangxiansheding_shangxiansheding = require("data.data_shangxiansheding_shangxiansheding")

local SpiritListLayer = class("SpiritListLayer", function ()
	return display.newNode()
end)

local SpiritItem = class("SpiritItem", function ()
	return CCTableViewCell:new()
end)

function SpiritItem:getContentSize()
	return cc.size(display.width * 0.93, 160)
end

function SpiritItem:ctor()
end

function SpiritItem:create(param)
	local _itemData = param.itemData
	local _viewSize = param.viewSize
	local _idx = param.idx
	local _listener = param.listener
	local proxy = CCBProxy:create()
	self._rootnode = {}
	self._infoListener = param.infoListener
	local node = CCBuilderReaderLoad("spirit/spirit_item.ccbi", proxy, self._rootnode)
	node:setContentSize(cc.size(_viewSize.width, CONFIG_SCREEN_HEIGHT))
	node:setPosition(_viewSize.width / 2, self._rootnode.itemBg:getContentSize().height / 2 - 3)
	self:addChild(node)
	
	self._rootnode.upgradeBtn:addHandleOfControlEvent(function (sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		self._rootnode.upgradeBtn:setEnabled(false)
		if _listener then
			_listener(self:getIdx())
		end
	end,
	CCControlEventTouchDown)
	
	self:refresh(param)
	return self
end

function SpiritItem:setBtnEnabled(b)
	self._rootnode.upgradeBtn:setEnabled(b)
end

function SpiritItem:refreshLabel(itemData)
	self._rootnode.itemNameLabel:setString(itemData.baseData.name)
	self._rootnode.itemNameLabel:setColor(QUALITY_COLOR[itemData.baseData.quality or 1])
	if itemData.baseData.arr_nature then
		self._rootnode.upgradeBtn:setVisible(true)
		for i = 1, 2 do
			local prop = itemData.data.props[i]
			local str = " "
			if prop then
				local nature = data_item_nature[prop.idx]
				str = nature.nature
				if nature.type == 1 then
					str = str .. "+" .. tostring(prop.val)
				else
					str = str .. "+%" .. tostring(prop.val)
				end
			end
			self._rootnode["propLabel_" .. tostring(i)]:setString(str)
		end
	else
		self._rootnode.upgradeBtn:setVisible(false)
		for i = 1, 2 do
			local str = " "
			if i == 1 then
				str = str .. common:getLanguageString("@jingyan1") .. tostring(itemData.baseData.price)
			end
			self._rootnode["propLabel_" .. tostring(i)]:setString(str)
		end
	end
	self._rootnode.lvLabel:setString(string.format("LV.%d", itemData.data.level))
	self._rootnode.qualitySprite:setDisplayFrame(display.newSpriteFrame(string.format("item_board_num_%d.png", itemData.baseData.quality)))
	if itemData.data.cid and itemData.data.cid > 0 then
		local card = ResMgr.getCardData(itemData.data.cid)
		if card.id == 1 or card.id == 2 then
			self._rootnode.equipHeroName:setString(common:getLanguageString("@zhuangbeiyu") .. game.player:getPlayerName())
		else
			self._rootnode.equipHeroName:setString(common:getLanguageString("@zhuangbeiyu") .. card.name)
		end
	else
		self._rootnode.equipHeroName:setString("")
	end
end

function SpiritItem:refresh(param)
	self._rootnode.upgradeBtn:setEnabled(true)
	local _itemData = param.itemData
	local _idx = param.idx
	self:refreshLabel(_itemData)
	self._rootnode.iconSprite:removeAllChildrenWithCleanup(true)
	
	self._spiritIcon = require("game.Spirit.SpiritIcon").new({
	id = _itemData.data._id,
	resId = _itemData.data.resId,
	lv = _itemData.data.level,
	exp = _itemData.data.curExp or 0
	})
	
	self._rootnode.iconSprite:addChild(self._spiritIcon)
end

function SpiritItem:tableCellTouched(x, y)
	if self._infoListener then
		local icon = self._spiritIcon:getSprite()
		dump(size)
		dump(icon:getBoundingBox())
		dump(icon:convertToNodeSpace(cc.p(x, y)))
		if cc.rectContainsPoint(icon:getBoundingBox(), icon:convertToNodeSpace(cc.p(x, y))) then
			self._infoListener(self:getIdx())
		end
	end
end

function SpiritListLayer:ctor(param)
	display.addSpriteFramesWithFile("ui/ui_spirit_list.plist", "ui/ui_spirit_list.png")
	local _sz = param.sz
	local _items = param.items
	local bg = display.newScale9Sprite("ui_common/common_bg.png")
	bg:setContentSize(cc.size(_sz.width, _sz.height))
	bg:setPosition(_sz.width / 2, _sz.height / 2)
	self:addChild(bg)
	local hw = display.newSprite("ui_common/common_huawen.png")
	hw:setPosition(_sz.width * 0.514, _sz.height)
	hw:setAnchorPoint(cc.p(0.5, 1))
	self:addChild(hw)
	local bg2 = display.newScale9Sprite("ui_common/common_bg2.png")
	bg2:setContentSize(cc.size(_sz.width + 40, _sz.height + 12))
	bg2:setPosition(_sz.width / 2, _sz.height / 2)
	self:addChild(bg2)
	local sort = function (item1, item2)
		if item1.data.cid and item1.data.cid > 0 and item2.data.cid and item2.data.cid == 0 then
			return true
		elseif item1.data.cid > 0 and item2.data.cid > 0 then
			if item1.baseData.quality == item2.baseData.quality then
				return item1.data.level > item2.data.level
			else
				return item1.baseData.quality > item2.baseData.quality
			end
		elseif item1.data.cid == 0 and item2.data.cid == 0 then
			if item1.baseData.pos ~= 51 and item2.baseData.pos == 51 then
				return true
			elseif item1.baseData.pos ~= 51 and item2.baseData.pos ~= 51 then
				return item1.baseData.quality > item2.baseData.quality
			elseif item1.baseData.pos == 51 and item2.baseData.pos == 51 then
				return item1.baseData.quality > item2.baseData.quality
			end
		else
			return false
		end
	end
	table.sort(_items, sort)
	
	local function onUpgradeBtn(idx)
		printf(idx)
		if _items[idx + 1].data.level < data_shangxiansheding_shangxiansheding[5].level then
			SpiritCtrl.pushUpgradeScene(idx + 1)
		else
			show_tip_label(common:getLanguageString("@zhenqidjzd"))
			self._scrollItemList:cellAtIndex(idx):setBtnEnabled(true)
		end
	end
	
	local function onIcon(idx)
		idx = idx + 1
		local descLayer = require("game.Spirit.SpiritInfoLayer").new(2, _items[idx].data, function ()
			SpiritCtrl.pushUpgradeScene(idx)
		end)
		game.runningScene:addChild(descLayer, 100)
	end
	
	self._scrollItemList = require("utility.TableViewExt").new({
	size = cc.size(_sz.width, _sz.height),
	direction = kCCScrollViewDirectionVertical,
	createFunc = function (idx)
		local item = SpiritItem.new()
		idx = idx + 1
		return item:create({
		viewSize = _sz,
		itemData = _items[idx],
		idx = idx,
		listener = onUpgradeBtn,
		infoListener = onIcon
		})
	end,
	refreshFunc = function (cell, idx)
		idx = idx + 1
		cell:refresh({
		idx = idx,
		itemData = _items[idx]
		})
	end,
	cellNum = #_items,
	cellSize = SpiritItem.new():getContentSize(),
	touchFunc = function ()
	end
	})
	self._scrollItemList:setPosition(0, 0)
	self:addChild(self._scrollItemList)
	function self.refresh()
		self._scrollItemList:resetCellNum(#_items)
	end
end

return SpiritListLayer