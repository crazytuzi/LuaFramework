local data_item_item = require("data.data_item_item")
local data_kongfu_kongfu = require("data.data_kongfu_kongfu")
local data_refine_refine = require("data.data_refine_refine")

local SkillItem = class("SkillItem", function()
	return CCTableViewCell:new()
end)

function SkillItem:getContentSize()
	return cc.size(display.width * 0.98, 158)
end

local ITEM_TYPE_USE = 1
local ITEM_TYPE_SALE = 2

function SkillItem:create(param)
	local _viewSize = param.viewSize
	self._useListener = param.useListener
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("bag/bag_skill_item.ccbi", proxy, self._rootnode)
	node:setPosition(_viewSize.width / 2, self._rootnode.itemBg:getContentSize().height / 2)
	self:addChild(node, 0)
	self.typeNode = display.newNode()
	node:addChild(self.typeNode)
	
	--强化
	self._rootnode.qianghuaBtn:addHandleOfControlEvent(function()
		if self._useListener then
			self._rootnode.qianghuaBtn:setEnabled(false)
			self._useListener(self, 1)
		end
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end,
	CCControlEventTouchUpInside)
	
	--精炼
	self._rootnode.jinglianBtn:addHandleOfControlEvent(function()
		local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.NeiWaiGong_JingLian, game.player:getLevel(), game.player:getVip())
		if not bHasOpen then
			show_tip_label(prompt)
		elseif self._useListener then
			self._useListener(self, 2)
		end
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end,
	CCControlEventTouchUpInside)
	
	local _itemData = param.itemData
	self.itemName = ui.newTTFLabelWithShadow({
	text = "",
	font = FONTS_NAME.font_fzcy,
	size = 24,
	color = NAME_COLOR[_itemData.star],
	shadowColor = display.COLOR_BLACK,
	})
	self._rootnode.itemNameLabel:addChild(self.itemName)
	self.jlLabel = ui.newTTFLabelWithShadow({
	text = "",
	font = FONTS_NAME.font_haibao,
	size = 20,
	color = FONT_COLOR.GREEN_1,
	shadowColor = display.COLOR_BLACK,
	})
	self._rootnode.itemNameLabel:addChild(self.jlLabel)
	self.jlIconLabel = ui.newTTFLabelWithShadow({
	text = "",
	font = FONTS_NAME.font_haibao,
	size = 20,
	color = FONT_COLOR.GREEN_1,
	shadowColor = display.COLOR_BLACK,
	})
	self._rootnode.iconJLSprite:addChild(self.jlIconLabel)
	
	--等级
	self.pjLabel = ui.newTTFLabelWithOutline({
	text = "",
	font = FONTS_NAME.font_haibao,
	size = 20,
	color = FONT_COLOR.GREEN_1,
	outlineColor = display.COLOR_BLACK,
	})
	self._rootnode.pjLabel:addChild(self.pjLabel)
	self:refresh(param)
	return self
end

function SkillItem:touch(bChoose)
	if bChoose then
		self._rootnode.itemSelectedSprite:setDisplayFrame(display.newSpriteFrame("item_board_selected.png"))
	else
		self._rootnode.itemSelectedSprite:setDisplayFrame(display.newSpriteFrame("item_board_unselected.png"))
	end
end

function SkillItem:tableCellTouched(x, y)
	local icon = self._rootnode["iconSprite"]
	local size = icon:getContentSize()
	if cc.rectContainsPoint(cc.rect(0, 0, size.width, size.height), icon:convertToNodeSpace(cc.p(x, y))) then
		if  self._useListener then
			self._useListener(self, 3)
		end
	end
end

function SkillItem:refresh(param)
	local _itemData = param.itemData
	local _itemType = param.itemType
	self.itemName:setString(data_item_item[_itemData.resId].name)
	self.itemName:setColor(NAME_COLOR[_itemData.star])
	self.itemName:setPosition(self.itemName:getContentSize().width / 2, 0)
	self.jlLabel:setString("")
	self._rootnode.iconJLSprite:setVisible(false)
	self._rootnode.qianghuaBtn:setEnabled(true)
	for i = 1, 3 do
		self._rootnode["propLabel_" .. tostring(i)]:setString("")
	end
	if data_item_item[_itemData.resId].pos == 101 or data_item_item[_itemData.resId].pos == 102 then
		self._rootnode["propLabel_" .. tostring(1)]:setString(common:getLanguageString("@ExpAdd", tostring(data_item_item[_itemData.resId].exp + _itemData.curExp)))
		self._rootnode.qianghuaBtn:setVisible(false)
		self._rootnode.jinglianBtn:setVisible(false)
	elseif data_item_item[_itemData.resId].pos == 103 or data_item_item[_itemData.resId].pos == 104 then
		self._rootnode.qianghuaBtn:setVisible(false)
		self._rootnode.jinglianBtn:setVisible(false)
	else
		self._rootnode.qianghuaBtn:setVisible(true)
		if data_refine_refine[_itemData.resId] and data_refine_refine[_itemData.resId].Refine and 0 < data_refine_refine[_itemData.resId].Refine then
			self._rootnode.jinglianBtn:setVisible(true)
			local refineInfo = data_refine_refine[_itemData.resId]
			local propCount = #refineInfo.arr_nature2
			local num = math.floor(_itemData.propsN / propCount)
			if num > 0 then
				self.jlLabel:setString(string.format("+%d", num))
				self.jlLabel:setPositionX(self.itemName:getContentSize().width + self.jlLabel:getContentSize().width / 2)
				self._rootnode.iconJLSprite:setVisible(true)
				self.jlIconLabel:setString(tostring(num))
				self.jlIconLabel:setPosition(self._rootnode.iconJLSprite:getContentSize().width + self.jlIconLabel:getContentSize().width / 2, self._rootnode.iconJLSprite:getContentSize().height / 2)
			end
		else
			self._rootnode.jinglianBtn:setVisible(false)
		end
		local index = 1
		for i = 1, 4 do
			local prop = _itemData.baseRate[i]
			local str = ""
			if prop > 0 then
				local data_item_nature = require("data.data_item_nature")
				local nature = data_item_nature[BASE_PROP_MAPPPING[i]]
				str = nature.nature
				if nature.type == 1 then
					str = str .. string.format("+%d", prop)
				else
					str = str .. string.format("+%.2f%%", prop / 100)
				end
				self._rootnode["propLabel_" .. tostring(index)]:setString(str)
				index = index + 1
			end
		end
	end
	self._rootnode.lvLabel:setString("LV." .. tostring(_itemData.level))
	self.pjLabel:setString(tostring(data_item_item[_itemData.resId].equip_level))
	if _itemType == ITEM_TYPE_SALE then
		self._rootnode.useView:setVisible(false)
		self._rootnode.saleView:setVisible(true)
		local silver = (data_kongfu_kongfu[_itemData.level + 1].sumexp[_itemData.star] + _itemData.curExp) * 5 * (_itemData.star - 1)
		silver = silver + data_item_item[_itemData.resId].price
		self._rootnode.silverLabel:setString(tostring(silver))
		self:touch(param.bChoose)
	else
		self._rootnode.useView:setVisible(true)
		self._rootnode.saleView:setVisible(false)
		self._rootnode.qualitySprite:setDisplayFrame(display.newSpriteFrame(string.format("item_board_num_%d.png", _itemData.star)))
		if 0 < _itemData.cid then
			local card = ResMgr.getCardData(_itemData.cid)
			if card.id == 1 or card.id == 2 then
				self._rootnode.equipHeroName:setString(common:getLanguageString("@EquipAt", game.player:getPlayerName()))
			else
				self._rootnode.equipHeroName:setString(common:getLanguageString("@EquipAt", card.name))
			end
		else
			self._rootnode.equipHeroName:setString("")
		end
	end
	if data_item_item[_itemData.resId].pos == 5 or data_item_item[_itemData.resId].pos == 101 then
		self._rootnode.flagSprite:setDisplayFrame(display.newSpriteFrame("item_board_ng.png"))
	else
		self._rootnode.flagSprite:setDisplayFrame(display.newSpriteFrame("item_board_wg.png"))
	end
	ResMgr.refreshIcon({
	itemBg = self._rootnode.iconSprite,
	id = _itemData.resId,
	resType = ResMgr.EQUIP
	})
end

return SkillItem