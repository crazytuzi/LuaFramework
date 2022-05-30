local selectItem = class("selectItem", function()
	return CCTableViewCell:new()
end)
local selectItemSize = cc.size(120, 170)

function selectItem:create(param)
	self.touchIconFunc = param.touchIconFunc
	local node = display.newSprite()
	node:setContentSize(cc.size(95, 95))
	self:addChild(node)
	node:setPosition(60, 117.5)
	self.iconNode = node
	self.isShow = param.isShow
	if param.effecttype == 10 then
		local quas = {
		"",
		"pinzhikuangliuguang_lv",
		"pinzhikuangliuguang_lan",
		"pinzhikuangliuguang_zi",
		"pinzhikuangliuguang_jin",
		"pinzhikuangliuguang_jin"
		}
		local holoName = "pinzhikuangliuguang_jin"
		local suitArma = ResMgr.createArma({
		resType = ResMgr.UI_EFFECT,
		armaName = holoName,
		isRetain = true
		})
		self:addChild(suitArma, 5)
		suitArma:setPosition(60, 117.5)
	end
	if not self.isShow then
		local duigou_bg = display.newSprite("ui/ui_9Sprite/duigou_bg.png")
		duigou_bg:setPosition(60, 20)
		self:addChild(duigou_bg)
		local duigou_png = display.newSprite("ui/ui_CommonResouces/duigou.png")
		duigou_png:setPosition(60, 20)
		self:addChild(duigou_png)
		self.duigou_png = duigou_png
	end
	self:refreshItem(param)
	return self
end

function selectItem:refreshItem(param)
	local itemData = param.itemData
	self.idx = param.idx
	self.iconNode:removeAllChildren()
	if itemData.type ~= ITEM_TYPE.zhenqi then
		ResMgr.refreshItemWithTagNumName({
		itemType = itemData.type,
		id = itemData.id,
		itemBg = self.iconNode,
		itemNum = itemData.num,
		isShowIconNum = true
		})
	else
		local icon = require("game.Spirit.SpiritIcon").new({
		resId = itemData.id,
		bShowName = true
		})
		icon:setAnchorPoint(cc.p(0.5, 0.5))
		icon:setPosition(48, 40)
		self.iconNode:addChild(icon)
	end
	self:refreshSelected(param.selected)
end

function selectItem:refreshSelected(selected)
	if not self.isShow then
		self.selected = selected
		self.duigou_png:setVisible(selected)
	end
end

local BagSelectBox = class("BagSelectBox", function()
	return require("utility.ShadeLayer").new()
end)

function BagSelectBox:ctor(param)
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("reward/reward_msg_box.ccbi", proxy, self._rootnode)
	self:addChild(node)
	self._isShow = param.isShow
	self._confirmFunc = param.confirmFunc
	local baseInfo = param.baseInfo
	self._selectIndex = nil
	self._itemData = {}
	for key, value in pairs(baseInfo.para1) do
		local tbl = {}
		tbl.type = value
		tbl.id = baseInfo.para2[key]
		tbl.num = baseInfo.para3[key]
		self._itemData[key] = tbl
	end
	local width = 563
	local height = 350
	local titleLabel = ui.newTTFLabelWithOutline({
	text = baseInfo.name,
	size = 28,
	color = cc.c3b(244, 229, 189),
	shadowColor = display.COLOR_BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_CENTER
	})
	titleLabel:setPosition(width / 2, height - 85)
	self._rootnode.title:getParent():addChild(titleLabel)
	self._rootnode.bgView:setContentSize(cc.size(width, height))
	self._rootnode.listView:setContentSize(cc.size(width - 85, 180))
	self._rootnode.closeBtn:setPosition(width - 20, height - 60)
	self._rootnode.confirmBtn:setPosition(width / 2, 0)
	local posY = self._rootnode.bgView:getPositionY()
	self._rootnode.listView:setPositionY(posY - 20)
	local function closeFun(eventName, sender)
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		self:removeSelf()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end
	
	self._rootnode.closeBtn:addHandleOfControlEvent(function()
		if self._isShow then
			self._confirmFunc()
		else
			closeFun()
		end
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.confirmBtn:addHandleOfControlEvent(function()
		if self._isShow then
			self._confirmFunc()
		elseif self._selectIndex then
			local itemId = self._itemData[self._selectIndex].id
			self._confirmFunc(itemId)
			closeFun()
		else
			local text = common:getLanguageString("xuanzeduihuan")
			show_tip_label(text)
			return
		end
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.confirmBtn:setEnabled(self._isShow)
	self._rootnode.closeBtn:setVisible(true)
	self._rootnode.confirmBtn:setVisible(true)
	self.itemList = require("utility.TableViewExt").new({
	size = self._rootnode.listView:getContentSize(),
	createFunc = function(idx)
		idx = idx + 1
		local item = selectItem.new()
		return item:create({
		isShow = self._isShow,
		effecttype = param.effecttype,
		itemData = self._itemData[idx],
		idx = idx,
		selected = self._selectIndex == idx
		})
	end,
	refreshFunc = function(cell, idx)
		idx = idx + 1
		cell:refreshItem({
		idx = idx,
		itemData = self._itemData[idx],
		selected = self._selectIndex == idx
		})
	end,
	cellNum = #self._itemData,
	cellSize = selectItemSize,
	touchFunc = function(cell)
		if cell.isShow then
			local index = cell:getIdx() + 1
			local itemData = self._itemData[index]
			local itemLayer = require("game.Huodong.ItemInformation").new(itemData)
			self:addChild(itemLayer, 100000)
		elseif not cell.selected then
			cell:refreshSelected(true)
			if self._selectIndex then
				local cell = self.itemList:cellAtIndex(self._selectIndex - 1)
				if cell then
					cell:refreshSelected(false)
				end
			end
			self._selectIndex = cell:getIdx() + 1
			self._rootnode.confirmBtn:setEnabled(true)
		end
	end
	})
	self._rootnode.listView:addChild(self.itemList)
end

return BagSelectBox