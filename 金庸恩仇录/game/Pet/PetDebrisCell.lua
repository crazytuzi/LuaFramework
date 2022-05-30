local data_item_item = require("data.data_item_item")

local PetDebrisCell = class("PetDebrisCell", function()
	display.addSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
	display.addSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
	return CCTableViewCell:new()
end)

function PetDebrisCell:getContentSize()
	return cc.size(display.width, 154)
end

function PetDebrisCell:refresh(id)
	local cellData = PetModel.getPetDebrisData()[id]
	self.itemId = cellData.itemId
	local cut = cellData.itemCnt
	self.mCurNum = cut
	ResMgr.refreshIcon({
	id = self.itemId,
	resType = ResMgr.PET,
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
		self.hechengBtn:setVisible(false)
	else
		self.curNum:setColor(cc.c3b(0, 167, 67))
		self.doneTTF:setVisible(true)
		self.unDoneTTF:setVisible(false)
		self.hechengBtn:setVisible(true)
	end
end

function PetDebrisCell:setStars(num)
	for i = 1, 5 do
		if num < i then
			self._rootnode["star" .. i]:setVisible(false)
		else
			self._rootnode["star" .. i]:setVisible(true)
		end
	end
end

function PetDebrisCell:create(param)
	local _id = param.id
	local hechengFunc = param.hechengFunc
	local createDiaoLuoLayer = param.createDiaoLuoLayer
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("pet/pet_soul_item.ccbi", proxy, self._rootnode)
	node:setPosition(display.width * 0.5, self._rootnode.itemBg:getContentSize().height / 2)
	self:addChild(node)
	self.headIcon = self._rootnode.headIcon
	
	self.heroName = ui.newTTFLabelWithShadow({
	text = common:getLanguageString("@Hurrey"),
	font = FONTS_NAME.font_fzcy,
	x = self._rootnode.jinduNode:getContentSize().width * 0.2,
	y = self:getContentSize().height * 0.57,
	size = 22,
	align = ui.TEXT_ALIGN_LEFT,
	color = FONT_COLOR.WHITE,
	shadowColor = FONT_COLOR.BLACK,
	})
	self._rootnode.jinduNode:addChild(self.heroName)
	self.curNum = self._rootnode.curNum
	self.maxNum = self._rootnode.maxNum
	self._rootnode.checkBtn:setVisible(false)
	self.hechengBtn = self._rootnode.hechengBtn
	self.doneTTF = self._rootnode.done
	self.unDoneTTF = self._rootnode.undone
	
	--ºÏ³É Ç×  ²â Ô´ Âë  Íø  w w w. q c y  m w .c o m
	self.hechengBtn:addHandleOfControlEvent(function(eventName, sender)
		hechengFunc({
		id = self.itemId,
		num = self.limitNum
		})
	end,
	CCControlEventTouchUpInside)
	
	self:refresh(_id + 1)
	return self
end


function PetDebrisCell:tableCellTouched(x, y)
	local icon = self.headIcon
	if cc.rectContainsPoint(icon:getBoundingBox(), icon:convertToNodeSpace(cc.p(x, y))) then
		--[[self.headIcon:setTouchEnabled(false)
		ResMgr.delayFunc(0.8, function()
			self.headIcon:setTouchEnabled(true)
		end,
		self)]]
		local itemInfo = require("game.Huodong.ItemInformation").new({
		id = self.itemId,
		type = ITEM_TYPE.chongwu_suipian,
		curNum = self.mCurNum,
		limitNum = self.limitNum
		})
		display.getRunningScene():addChild(itemInfo, 1000)
	end
	
end

function PetDebrisCell:beTouched()
end

function PetDebrisCell:onExit()
end

function PetDebrisCell:runEnterAnim()
end

return PetDebrisCell