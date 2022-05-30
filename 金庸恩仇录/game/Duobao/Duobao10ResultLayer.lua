local getNumByIndex = function(index)
	if index == 1 then
		return common:getLanguageString("@OneTxt")
	elseif index == 2 then
		return common:getLanguageString("@TwoTxt")
	elseif index == 3 then
		return common:getLanguageString("@ThreeTxt")
	elseif index == 4 then
		return common:getLanguageString("@FourTxt")
	elseif index == 5 then
		return common:getLanguageString("@FiveTxt")
	elseif index == 6 then
		return common:getLanguageString("@SixTxt")
	elseif index == 7 then
		return common:getLanguageString("@SevenTxt")
	elseif index == 8 then
		return common:getLanguageString("@EightTxt")
	elseif index == 9 then
		return common:getLanguageString("@NineTxt")
	elseif index == 10 then
		return common:getLanguageString("@TenTxt")
	end
end
local data_item_item = require("data.data_item_item")

local Item = class("Item", function()
	return CCTableViewCell:new()
end)

function Item:getContentSize()
	return cc.size(424, 170)
end

function Item:create(param)
	local _viewSize = param.viewSize
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("huodong/huodong_rob_10_result_item.ccbi", proxy, self._rootnode)
	node:setPosition(_viewSize.width / 2, node:getContentSize().height / 2)
	self:addChild(node, 0)
	local text = {
	common:getLanguageString("@SilverCoin"),
	common:getLanguageString("@Exp"),
	common:getLanguageString("@Niko")
	}
	self._label = {}
	self._rootnode.titleLabel:setString(common:getLanguageString("@dijici", getNumByIndex(param.idx)))
	for i = 1, 3 do
		local label = ui.newTTFLabelWithOutline({
		text = text[i],
		size = 20,
		outlineColor = cc.c3b(0, 0, 0),
		font = FONTS_NAME.font_fzcy
		})
		self._rootnode[string.format("lableNode_%d", i)]:addChild(label)
		local color = cc.c3b(41, 237, 225)
		if i == 3 then
			color = cc.c3b(255, 10, 10)
		end
		self._label[i] = ui.newTTFLabelWithOutline({
		text = "",
		size = 20,
		color = color,
		outlineColor = cc.c3b(0, 0, 0),
		font = FONTS_NAME.font_fzcy
		})
		self._rootnode[string.format("lableNode_%d", i)]:addChild(self._label[i])
		self._offsetX = label:getContentSize().width + 10
	end
	
	self._nameLabel = ui.newTTFLabelWithShadow({
	text = "",
	size = 20,
	shadowColor = display.COLOR_BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_CENTER
	})
	
	ResMgr.replaceKeyLableEx(self._nameLabel, self._rootnode, "nameLabel", 0, 0)
	self._nameLabel:align(display.CENTER)
	
	self:refresh(param)
	return self
end

function Item:refresh(param)
	local _itemData = param.itemData
	local _idx = param.idx
	for _, v in pairs(_itemData.coinAry) do
		local index
		if v.id == 2 then
			index = 1
		elseif v.id == 6 then
			index = 2
		else
			index = 3
		end
		if index == 3 then
			self._label[index]:setString(tostring(v.n))
		else
			self._label[index]:setString("+" .. tostring(v.n))
		end
		self._label[index]:setPositionX(self._offsetX + self._label[index]:getContentSize().width / 2)
	end
	local item = require("data.data_item_item")[_itemData.probItem.id]
	self._nameLabel:setString(item.name)
	self._nameLabel:setColor(QUALITY_COLOR[item.quality])
	self._rootnode.titleLabel:setString(common:getLanguageString("@DI") .. getNumByIndex(param.idx) .. common:getLanguageString("@Next"))
	self._rootnode.iconSprite:removeAllChildrenWithCleanup(true)
	ResMgr.refreshIcon({
	itemBg = self._rootnode.iconSprite,
	id = _itemData.probItem.id,
	resType = ResMgr.getResType(_itemData.probItem.t),
	iconNum = _itemData.probItem.n,
	itemType = _itemData.probItem.t
	})
	self._rootnode.suipianTag:setVisible(false)
	self._rootnode.canhunTag:setVisible(false)
end

local Duobao10ResultLayer = class("Duobao10ResultLayer", function()
	return require("utility.ShadeLayer").new(cc.c4b(0, 0, 0, 155))
end)

function Duobao10ResultLayer:ctor(data, resId)
	ResMgr.createBefTutoMask(self)
	self._resultInfo = data
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("huodong/huodong_rob_10_result.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node, 1)
	
	self._rootnode.confirmBtn:addHandleOfControlEvent(function(sender, eventName)
		self._rootnode.confirmBtn:setEnabled(false)
		if self._resultInfo.isGetItem == 1 then
			pop_scene()
		else
			self:removeSelf()
		end
		TutoMgr.removeBtn("jiesuan_confirm_btn")
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
	end,
	CCControlEventTouchUpInside)
	
	local size = 22
	local yellow = cc.c3b(255, 210, 0)
	local green = cc.c3b(85, 210, 68)
	local black = cc.c3b(0, 0, 0)
	local white = cc.c3b(255, 255, 255)
	if self._resultInfo.isGetItem == 1 then
		local item = data_item_item[data_item_item[resId].para3]
		local partIndex = 1
		for k, v in ipairs(item.para1) do
			if resId == v then
				partIndex = getNumByIndex(k)
				break
			end
		end
		local rowOne = {
		ResMgr.createOutlineMsgTTF({
		text = common:getLanguageString("@DI"),
		color = yellow,
		outlineColor = black,
		size = size
		}),
		ResMgr.createOutlineMsgTTF({
		text = tostring(self._resultInfo.getIndex),
		color = green,
		outlineColor = black,
		size = size
		}),
		ResMgr.createOutlineMsgTTF({
		text = common:getLanguageString("@Deprive"),
		color = yellow,
		outlineColor = black,
		size = size
		}),
		ResMgr.createOutlineMsgTTF({
		text = common:getLanguageString("@Fragment", tostring(item.name), tostring(partIndex)),
		color = green,
		outlineColor = black,
		size = size
		})
		}
		local rowTwoTable = {
		ResMgr.createOutlineMsgTTF({
		text = common:getLanguageString("@TotalDeprive"),
		color = yellow,
		outlineColor = black,
		size = size
		}),
		ResMgr.createOutlineMsgTTF({
		text = tostring(self._resultInfo.getIndex),
		color = green,
		outlineColor = black,
		size = size
		}),
		ResMgr.createOutlineMsgTTF({
		text = common:getLanguageString("@DepriveEnd"),
		color = yellow,
		outlineColor = black,
		size = size
		})
		}
		local rowAll = {rowOne, rowTwoTable}
		for row = 1, #rowAll do
			local node = ResMgr.getArrangedNode(rowAll[row])
			node:setPosition(self._rootnode.descNode:getContentSize().width / 2 - node.rowWidth / 2, -(row - 1) * 25)
			self._rootnode.descNode:addChild(node)
		end
	else
		local rowOne = {
		ResMgr.createOutlineMsgTTF({
		text = common:getLanguageString("@Deprive2"),
		color = yellow,
		outlineColor = black,
		size = size
		}),
		ResMgr.createOutlineMsgTTF({
		text = tostring(#self._resultInfo.rtnAry),
		color = green,
		outlineColor = black,
		size = size
		}),
		ResMgr.createOutlineMsgTTF({
		text = common:getLanguageString("@CI"),
		color = yellow,
		outlineColor = black,
		size = size
		}),
		ResMgr.createOutlineMsgTTF({
		text = common:getLanguageString("@NoFragment"),
		color = white,
		outlineColor = black,
		size = size
		})
		}
		local node = ResMgr.getArrangedNode(rowOne)
		node:setPosition(self._rootnode.descNode:getContentSize().width / 2 - node.rowWidth / 2, 0)
		self._rootnode.descNode:addChild(node)
	end
	self:showLevelUp()
	self:initList()
	TutoMgr.addBtn("jiesuan_confirm_btn", self._rootnode.confirmBtn)
	TutoMgr.active()
end

function Duobao10ResultLayer:showLevelUp()
	local curLv = game.player:getLevel()
	if curLv < self._resultInfo.level then
		--dump("Duobao10ResultLayer_showLevelUp")
		--dump(curLv)
		--dump(self._resultInfo)
		local curNail = game.player:getNaili()
		local levelUpLayer = UIManager:getLayer("game.LevelUp.LevelUpLayer", nil, {
		level = curLv,
		uplevel = self._resultInfo.level,
		naili = curNail,
		curExp = self._resultInfo.exp
		})
		self:addChild(levelUpLayer, 101)
	end
end

function Duobao10ResultLayer:initList()
	local listView = require("utility.TableViewExt").new({
	size = self._rootnode.scrollView:getContentSize(),
	direction = kCCScrollViewDirectionVertical,
	createFunc = function(idx)
		idx = idx + 1
		return Item.new():create({
		viewSize = self._rootnode.scrollView:getContentSize(),
		itemData = self._resultInfo.rtnAry[idx],
		idx = idx
		})
	end,
	refreshFunc = function(cell, idx)
		idx = idx + 1
		cell:refresh({
		itemData = self._resultInfo.rtnAry[idx],
		idx = idx
		})
	end,
	cellNum = #self._resultInfo.rtnAry,
	cellSize = Item.new():getContentSize()
	})
	listView:setPosition(0, 0)
	self._rootnode.scrollView:addChild(listView)
end

return Duobao10ResultLayer