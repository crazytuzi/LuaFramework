local data_item_item = require("data.data_item_item")

local HeroDebrisCell = class("HeroDebrisCell", function()
	display.addSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
	display.addSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
	return CCTableViewCell:new()
end)

function HeroDebrisCell:getContentSize()
	return cc.size(display.width, 154)
end

function HeroDebrisCell:refresh(id)
	local cellData = HeroModel.debrisData[id]
	self.itemId = cellData.itemId
	local cut = cellData.itemCnt
	self.mCurNum = cut
	ResMgr.refreshIcon({
	id = self.itemId,
	resType = ResMgr.HERO,
	itemBg = self.headIcon
	})
	self.curNum:setString(cut)
	self.limitNum = data_item_item[self.itemId].para1
	self.starNum = data_item_item[self.itemId].quality
	self:setStars(self.starNum)
	self.maxNum:setString("/" .. self.limitNum)
	self.maxNum:setPosition(self.curNum:getPositionX() + self.curNum:getContentSize().width, self.curNum:getPositionY())
	local nameStr = data_item_item[self.itemId].name
	self.heroName:setString(nameStr)
	self.heroName:setColor(NAME_COLOR[self.starNum])
	if cut < self.limitNum then
		self.curNum:setColor(cc.c3b(255, 0, 0))
		self.doneTTF:setVisible(false)
		self.unDoneTTF:setVisible(true)
		self.checkBtn:setVisible(true)
		self.hechengBtn:setVisible(false)
	else
		self.curNum:setColor(cc.c3b(0, 167, 67))
		self.doneTTF:setVisible(true)
		self.unDoneTTF:setVisible(false)
		self.checkBtn:setVisible(false)
		self.hechengBtn:setVisible(true)
	end
end

function HeroDebrisCell:setStars(num)
	for i = 1, 5 do
		if num < i then
			self._rootnode["star" .. i]:setVisible(false)
		else
			self._rootnode["star" .. i]:setVisible(true)
		end
	end
end

function HeroDebrisCell:create(param)
	self:setNodeEventEnabled(true)
	local _id = param.id
	local hechengFunc = param.hechengFunc
	local createDiaoLuoLayer = param.createDiaoLuoLayer
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("hero/hero_soul_item.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, self._rootnode.itemBg:getContentSize().height / 2)
	self:addChild(node)
	
	--czy
	self.headIcon = self._rootnode.headIcon
	self.headIcon:setTouchEnabled(true)
	self.headIcon:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		if event.name == "began" then
			self.headIcon:setTouchEnabled(false)
			ResMgr.delayFunc(0.8, function()
				self.headIcon:setTouchEnabled(true)
			end,
			self)
			local itemInfo = require("game.Huodong.ItemInformation").new({
			id = self.itemId,
			type = 8,
			curNum = self.mCurNum,
			limitNum = self.limitNum
			})
			display.getRunningScene():addChild(itemInfo, 100000)
			return true
		end
	end)
	
	self.heroName = ui.newTTFLabelWithShadow({
	text = common:getLanguageString("@Hurrey"),
	font = FONTS_NAME.font_fzcy,
	x = 25,
	y = self:getContentSize().height * 0.57,
	size = 22,
	align = ui.TEXT_ALIGN_LEFT,
	dimensions = cc.size(200, 60),
	valign = ui.TEXT_VALIGN_CENTER,
	color = display.COLOR_WHITE,
	shadowColor = display.COLOR_BLACK,
	})
	self.heroName:align(display.LEFT_CENTER)
	
	self._rootnode.jinduNode:addChild(self.heroName)
	self.curNum = self._rootnode.curNum
	self.maxNum = self._rootnode.maxNum
	self.checkBtn = self._rootnode.checkBtn
	self.hechengBtn = self._rootnode.hechengBtn
	self.doneTTF = self._rootnode.done
	self.unDoneTTF = self._rootnode.undone
	
	self.checkBtn:addHandleOfControlEvent(function(sender, eventName)
		createDiaoLuoLayer(self.itemId)
	end,
	CCControlEventTouchUpInside)
	
	self.hechengBtn:addHandleOfControlEvent(function(sender, eventName)
		hechengFunc({
		id = self.itemId,
		num = self.limitNum
		})
	end,
	CCControlEventTouchUpInside)
	
	self:refresh(_id + 1)
	return self
end

function HeroDebrisCell:beTouched()
end

function HeroDebrisCell:onExit()
end

function HeroDebrisCell:runEnterAnim()
end

return HeroDebrisCell