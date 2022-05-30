local data_item_item = require("data.data_item_item")

local EquipDebrisCellVTwo = class("EquipDebrisCellVTwo", function()
	display.addSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
	display.addSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
	return CCTableViewCell:new()
end)

function EquipDebrisCellVTwo:getContentSize()
	return cc.size(display.width, 154)
end

function EquipDebrisCellVTwo:refresh(id, listData)
	local cellData = listData[id]
	self.itemId = cellData.itemId
	local cut = cellData.itemCnt
	self.mCurNum = cut
	ResMgr.refreshIcon({
	id = self.itemId,
	resType = self.resType,
	itemBg = self.headIcon
	})
	self.curNum:setString(cut)
	self._rootnode.item_num:setString(common:getLanguageString("@Count", cut))
	self.limitNum = data_item_item[self.itemId].para1
	self.starNum = data_item_item[self.itemId].quality
	self:setStars(self.starNum)
	self.maxNum:setString("/" .. self.limitNum)
	self.maxNum:setPosition(self.curNum:getPositionX() + self.curNum:getContentSize().width, self.curNum:getPositionY())
	local nameStr = data_item_item[self.itemId].name
	self.heroName:setString(nameStr)
	self.heroName:setColor(NAME_COLOR[self.starNum])
	--self.heroName:setPosition(self.heroName:getContentSize().width / 2, 0)
	if cut < self.limitNum then
		self.curNum:setColor(cc.c3b(255, 0, 0))
		self.doneTTF:setVisible(false)
		self.unDoneTTF:setVisible(true)
		self.checkBtn:setVisible(true)
		if self.resType == ResMgr.CHEATS then
			self.checkBtn:setVisible(false)
		end
		self.hechengBtn:setVisible(false)
	else
		self.curNum:setColor(cc.c3b(0, 167, 67))
		self.doneTTF:setVisible(true)
		self.unDoneTTF:setVisible(false)
		self.checkBtn:setVisible(false)
		self.hechengBtn:setVisible(true)
	end
end

function EquipDebrisCellVTwo:setStars(num)
	self._rootnode.starNumSprite:setDisplayFrame(display.newSpriteFrame(string.format("item_board_num_%d.png", num)))
end

function EquipDebrisCellVTwo:create(param)
	local _id = param.id
	self.resType = param.resType or ResMgr.EQUIP
	local hechengFunc = param.hechengFunc
	local createDiaoLuoLayer = param.createDiaoLuoLayer
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("equip/equip_debris_item.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, self._rootnode.itemBg:getContentSize().height / 2)
	self:addChild(node)
	self.headIcon = self._rootnode.headIcon
	self.headIcon:setTouchEnabled(true)
	self.itemType = 3
	if self.resType == ResMgr.CHEATS then
		self.itemType = ITEM_TYPE.cheats
	end
	
	self.heroName = ui.newTTFLabelWithShadow({
	text = "",
	font = FONTS_NAME.font_fzcy,
	size = 24,
	color = display.COLOR_WHITE,
	shadowColor = display.COLOR_BLACK,
	})
	
	ResMgr.replaceKeyLableEx(self.heroName, self._rootnode, "heroName", 0, 0)
	self.heroName:align(display.LEFT_CENTER)
	
	self.curNum = self._rootnode.curNum
	self.maxNum = self._rootnode.maxNum
	self.checkBtn = self._rootnode.checkBtn
	self.hechengBtn = self._rootnode.hechengBtn
	self.doneTTF = self._rootnode.done
	self.unDoneTTF = self._rootnode.undone
	
	--掉落来源
	self.checkBtn:addHandleOfControlEvent(function(sender, eventName)
		createDiaoLuoLayer(self.itemId)
	end,
	CCControlEventTouchUpInside)
	
	--合成
	self.hechengBtn:addHandleOfControlEvent(function(sender, eventName)
		hechengFunc({
		id = self.itemId,
		num = self.limitNum
		})
	end,
	CCControlEventTouchUpInside)
	
	self:refresh(_id + 1, param.listData)
	return self
end

function EquipDebrisCellVTwo:tableCellTouched(x, y)
	local icon = self.headIcon
	local bound = icon:getContentSize()
	if cc.rectContainsPoint(cc.rect(0,0, bound.width, bound.height), icon:convertToNodeSpace(cc.p(x, y))) then
		local itemInfo = require("game.Huodong.ItemInformation").new({
		id = self.itemId,
		type = self.itemType,
		curNum = self.mCurNum,
		limitNum = self.limitNum
		})
		display.getRunningScene():addChild(itemInfo, 100000)
	end
end

function EquipDebrisCellVTwo:beTouched()
end

function EquipDebrisCellVTwo:onExit()
end

function EquipDebrisCellVTwo:runEnterAnim()
end

return EquipDebrisCellVTwo