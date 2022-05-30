local data_item_nature = require("data.data_item_nature")
local data_kongfu_kongfu = require("data.data_kongfu_kongfu")
local data_refine_refine = require("data.data_refine_refine")

local Item = class("Item", function()
	return CCTableViewCell:new()
end)

function Item:getContentSize()
	return cc.size(display.width * 0.93, 158)
end

function Item:create(param)
	local _viewSize = param.viewSize
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("bag/bag_skill_choose_item.ccbi", proxy, self._rootnode)
	node:setPosition(_viewSize.width / 2, self._rootnode.itemBg:getContentSize().height / 2)
	self:addChild(node)
	
	self.nameLabel = ui.newTTFLabelWithShadow({
	text = "",
	font = FONTS_NAME.font_haibao,
	size = 28,
	color = display.COLOR_WHITE,
	shadowColor = display.COLOR_BLACK,
	})
	
	ResMgr.replaceKeyLable(self.nameLabel, self._rootnode.kongfuName, 0, 0)
	self.nameLabel:align(display.LEFT_CENTER)
	
	self.jlLabel = ui.newTTFLabelWithShadow({
	text = "",
	font = FONTS_NAME.font_haibao,
	size = 28,
	color = FONT_COLOR.GREEN_1,
	shadowColor = display.COLOR_BLACK,
	})
	ResMgr.replaceKeyLable(self.jlLabel, self._rootnode.kongfuName, self.nameLabel:getContentSize().width, 0)
	self.jlLabel:align(display.LEFT_CENTER)
	
	self._rootnode.kongfuName:removeSelf()
	
	self:refresh(param)
	return self
end

function Item:refreshLabel(itemData)
	self.nameLabel:setString(itemData.baseData.name)
	self.nameLabel:setColor(NAME_COLOR[itemData.baseData.quality])
	if 0 < itemData.data.propsN then
		local refineInfo = data_refine_refine[itemData.baseData.id]
		local propCount = #refineInfo.arr_nature2
		local num = math.floor(itemData.data.propsN / propCount)
		if num > 0 then
			self.jlLabel:setString(string.format("+%d", num))
			self.jlLabel:setPositionX(self.nameLabel:getPositionX() + self.nameLabel:getContentSize().width)
		end
	end
	local index = 1
	for i = 1, 3 do
		self._rootnode["propLabel_" .. tostring(i)]:setVisible(false)
	end
	local exp = itemData.data.curExp + data_kongfu_kongfu[itemData.data.level + 1].sumexp[itemData.baseData.quality] + itemData.baseData.exp
	if itemData.baseData.pos == 101 or itemData.baseData.pos == 102 then
		self._rootnode.propLabel_1:setVisible(true)
		self._rootnode.propLabel_1:setString(common:getLanguageString("@ExpAdd", exp))
	else
		for i = 1, 4 do
			local prop = itemData.data.baseRate[i]
			local str = ""
			if prop > 0 then
				local nature = data_item_nature[BASE_PROP_MAPPPING[i]]
				str = nature.nature
				if nature.type == 1 then
					str = string.format("%s+%d", str, prop)
				else
					str = string.format("%s+%.2f%%", str, prop / 100)
				end
				self._rootnode["propLabel_" .. tostring(index)]:setString(str)
				self._rootnode["propLabel_" .. tostring(index)]:setVisible(true)
				index = index + 1
			end
		end
	end
	self._rootnode.expNumLabel:setString(tostring(exp))
	self._rootnode.lvNum:setString(string.format("LV.%d", itemData.data.level))
	self._rootnode.qualityLabel:setString(tostring(itemData.baseData.quality))
end

function Item:selected()
	self._rootnode.selectedSprite:setDisplayFrame(display.newSpriteFrame("item_board_selected.png"))
end

function Item:unselected()
	self._rootnode.selectedSprite:setDisplayFrame(display.newSpriteFrame("item_board_unselected.png"))
end

function Item:touch()
	self:selected()
end

function Item:changeState(sel)
	if sel then
		self:selected()
	else
		self:unselected()
	end
end

function Item:refresh(param)
	local _itemData = param.itemData
	local _sel = param.sel
	self:changeState(_sel)
	ResMgr.refreshIcon({
	itemBg = self._rootnode.headIcon,
	id = _itemData.data.resId,
	resType = ResMgr.EQUIP
	})
	self:refreshLabel(_itemData)
	if _itemData.baseData.pos == 5 or _itemData.baseData.pos == 101 then
		self._rootnode.flagSprite:setDisplayFrame(display.newSpriteFrame("item_board_ng.png"))
	else
		self._rootnode.flagSprite:setDisplayFrame(display.newSpriteFrame("item_board_wg.png"))
	end
end


local BaseScene = require("game.BaseScene")
local SkillChooseScene = class("SkillChooseScene", BaseScene)

function SkillChooseScene:ctor(param)
	SkillChooseScene.super.ctor(self, {
	contentFile = "public/window_content_scene.ccbi",
	subTopFile = "formation/formation_skill_sub_top.ccbi",
	bottomFile = "skill/skill_select_bottom.ccbi",
	bgImage = "ui_common/common_bg.png",
	imageFromBottom = true
	})
	
	ResMgr.removeBefLayer()
	local _callback = param.callback
	local _sel = param.sel or {}
	local _listData = param.listData
	self.curExpValue = 0
	self.needExpValue = param.needExpValue
	game.runningScene = self
	local _sz = self._rootnode.listView:getContentSize()
	local _selected = {}
	for k, v in pairs(_sel) do
		_selected[k] = v
	end
	local function close()
		if _callback then
			_callback(_sel)
		end
		pop_scene()
	end
	
	self._rootnode.backBtn:addHandleOfControlEvent(function(sender, event)
		sender:setEnabled(false)
		close()
	end,
	CCControlEventTouchDown)
	
	self._rootnode.confirmBtn:addHandleOfControlEvent(function()
		_sel = _selected
		close()
	end,
	CCControlEventTouchDown)
	
	local function countSelected()
		local i = 0
		local exp = 0
		for k, v in pairs(_selected) do
			if v then
				i = i + 1
				exp = exp + _listData[k].data.curExp + data_kongfu_kongfu[_listData[k].data.level + 1].sumexp[_listData[k].baseData.quality] + _listData[k].baseData.exp
			end
		end
		return i, exp
	end
	local function refreshLabel()
		local i, exp = countSelected()
		self.curExpValue = exp
		self._rootnode.selectedLabel:setString(tostring(i))
		self._rootnode.expNumLabel:setString(tostring(exp))
	end
	local function touch(idx)
		if _selected[idx] then
			_selected[idx] = nil
		else
			local n, _ = countSelected()
			if n >= 5 then
				show_tip_label(common:getLanguageString("@xuewx", 5))
				return
			else
				if self.needExpValue and self.curExpValue >= self.needExpValue then
					show_tip_label(common:getLanguageString("@GuildLvMax"))
					return
				end
				_selected[idx] = true
			end
		end
		refreshLabel()
	end
	refreshLabel()
	self._scrollItemList = require("utility.TableViewExt").new({
	size = cc.size(_sz.width, _sz.height),
	direction = kCCScrollViewDirectionVertical,
	createFunc = function(idx)
		local item = Item.new()
		idx = idx + 1
		return item:create({
		viewSize = _sz,
		itemData = _listData[idx],
		idx = idx,
		sel = _selected[idx]
		})
	end,
	refreshFunc = function(cell, idx)
		idx = idx + 1
		cell:refresh({
		idx = idx,
		itemData = _listData[idx],
		sel = _selected[idx]
		})
	end,
	cellNum = #_listData,
	cellSize = Item.new():getContentSize(),
	touchFunc = function(cell)
		local idx = cell:getIdx() + 1
		touch(idx)
		cell:refresh({
		idx = idx,
		itemData = _listData[idx],
		sel = _selected[idx]
		})
	end
	})
	self._scrollItemList:setPosition(0, 0)
	self._rootnode.listView:addChild(self._scrollItemList)
end

function SkillChooseScene:onEnter()
	game.runningScene = self
	SkillChooseScene.super.onEnter(self)
	PostNotice(NoticeKey.UNLOCK_BOTTOM)
end

return SkillChooseScene